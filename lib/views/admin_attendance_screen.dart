import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_attendance_controller.dart';

class AdminAttendanceScreen extends StatelessWidget {
  AdminAttendanceScreen({super.key}) {
    if (!Get.isRegistered<AdminAttendanceController>()) {
      Get.lazyPut(() => AdminAttendanceController());
    }
  }

  final AdminAttendanceController adminAttendanceController = Get.find();

  @override
  Widget build(BuildContext context) {
    adminAttendanceController.fetchAttendanceRecords();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Attendance Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (adminAttendanceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminAttendanceController.attendanceRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'No attendance records found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: adminAttendanceController.attendanceRecords.length,
          itemBuilder: (context, index) {
            final record = adminAttendanceController.attendanceRecords[index];
            return _buildAttendanceCard(record);
          },
        );
      }),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final statusColor =
        record['status'] == 'present' ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  "Name: ${record['user_name']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  "Date: ${record['date']}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.check_circle, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  "Status: ${record['status'].toUpperCase()}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
