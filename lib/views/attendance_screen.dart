import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../utils/session_manager.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceController attendanceController;

  AttendanceScreen({super.key})
      : attendanceController = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    final int? userId = SessionManager.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Mark Attendance'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Error: User ID not found. Please log in again.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    attendanceController.checkTodayAttendance(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (attendanceController.hasMarkedToday.value) {
            return _buildMarkedAttendance();
          } else {
            return _buildMarkAttendanceButton(userId);
          }
        }),
      ),
    );
  }

  Widget _buildMarkedAttendance() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Icon(Icons.check_circle, size: 80, color: Colors.green)),
        SizedBox(height: 20),
        Text(
          "Attendance already marked for today!",
          style: TextStyle(
            fontSize: 18,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMarkAttendanceButton(int userId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
            child: Icon(Icons.fingerprint, size: 80, color: Colors.blueAccent)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => attendanceController.markAttendance(userId),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Mark Attendance",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
