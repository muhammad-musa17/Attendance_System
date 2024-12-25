import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:attendance_system/database/database_helper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AdminReportsController extends GetxController {
  Future<List<BarChartGroupData>> getAttendanceDataForGraph() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT strftime('%m', date) AS month, COUNT(*) AS count
      FROM attendance
      WHERE status = 'present'
      GROUP BY strftime('%m', date)
    ''');

    return result.map((data) {
      return BarChartGroupData(
        x: int.parse(data['month'] as String),
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: (data['count'] as int).toDouble(),
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  Future<List<PieChartSectionData>> getLeaveDataForGraph() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT status, COUNT(*) AS count
      FROM leave_requests
      GROUP BY status
    ''');

    final colors = [Colors.green, Colors.orange, Colors.red];
    return result.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: (data['count'] as int).toDouble(),
        title: '${data['status']}',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  String getMonthName(int monthIndex) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[monthIndex];
  }

  Future<String> calculateGrade(int presentDays) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'grades',
      where: 'min_days <= ? AND max_days >= ?',
      whereArgs: [presentDays, presentDays],
    );

    if (result.isNotEmpty) {
      return result.first['grade'] as String;
    } else {
      return 'No Grade';
    }
  }

  Future<Map<String, dynamic>> generateUserReport(
      int userId, String fromDate, String toDate) async {
    final db = await DatabaseHelper.instance.database;

    final attendanceResult = await db.rawQuery('''
      SELECT COUNT(*) AS present_days
      FROM attendance
      WHERE user_id = ? AND date BETWEEN ? AND ?
    ''', [userId, fromDate, toDate]);

    final presentDays = attendanceResult.first['present_days'] as int;

    final grade = await calculateGrade(presentDays);

    return {
      'present_days': presentDays,
      'grade': grade,
    };
  }

  Future<void> saveReportsToLocalStorage() async {
    final attendanceData = await getAttendanceDataForGraph();
    final leaveData = await getLeaveDataForGraph();

    final attendanceReport = attendanceData
        .map((data) =>
            "Month: ${getMonthName(data.x)}, Count: ${data.barRods.first.toY.toInt()}")
        .join("\n");

    final leaveReport = leaveData
        .map((data) => "Type: ${data.title}, Count: ${data.value.toInt()}")
        .join("\n");

    final reportContent = "Attendance Report:\n$attendanceReport\n\n"
        "Leave Report:\n$leaveReport";

    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory?.path}/admin_reports.txt';

      final file = File(filePath);
      await file.writeAsString(reportContent);

      Get.snackbar(
        'Success',
        'Reports saved to local storage at $filePath',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save reports: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
