import 'package:get/get.dart';
import '../database/database_helper.dart';

class AttendanceController extends GetxController {
  RxBool hasMarkedToday = false.obs;
  RxList<Map<String, dynamic>> attendanceHistory = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> checkTodayAttendance(int userId) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month}-${today.day}";

      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'attendance',
        where: 'date = ? AND user_id = ?',
        whereArgs: [formattedDate, userId],
      );

      hasMarkedToday.value = result.isNotEmpty;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check today\'s attendance: $e');
    }
  }

  Future<void> markAttendance(int userId) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month}-${today.day}";

      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'attendance',
        where: 'date = ? AND user_id = ?',
        whereArgs: [formattedDate, userId],
      );

      if (result.isNotEmpty) {
        Get.snackbar('Error', 'Attendance already marked for today');
        return;
      }

      await db.insert('attendance', {
        'user_id': userId,
        'date': formattedDate,
        'status': 'present',
      });

      hasMarkedToday.value = true;
      Get.snackbar('Success', 'Attendance marked successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark attendance: $e');
    }
  }

  Future<void> fetchAttendanceHistory(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'attendance',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );

      attendanceHistory.value = result.map((record) {
        return {
          'date': record['date'],
          'status': record['status'],
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance history: $e');
    }
  }
}
