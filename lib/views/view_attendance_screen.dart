import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../utils/session_manager.dart';

class ViewAttendanceScreen extends StatelessWidget {
  final AttendanceController attendanceController =
      Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    final int? userId = SessionManager.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Attendance History'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Error: User ID not found. Please log in again.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    attendanceController.fetchAttendanceHistory(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Attendance History'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (attendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceController.attendanceHistory.isEmpty) {
          return Center(
            child: Text(
              "No attendance records found.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: attendanceController.attendanceHistory.length,
            itemBuilder: (context, index) {
              final record = attendanceController.attendanceHistory[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: record['status'] == 'present'
                        ? Colors.green
                        : Colors.red,
                    child: Icon(
                      record['status'] == 'present'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "Date: ${record['date']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Status: ${record['status']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: record['status'] == 'present'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => attendanceController.fetchAttendanceHistory(userId),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
