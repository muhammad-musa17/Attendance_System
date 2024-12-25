import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_leave_controller.dart';

class AdminLeaveScreen extends StatelessWidget {
  final AdminLeaveController adminLeaveController =
      Get.put(AdminLeaveController());

  AdminLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    adminLeaveController.fetchLeaveRequests();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Manage Leave Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (adminLeaveController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminLeaveController.leaveRequests.isEmpty) {
          return const Center(
            child: Text(
              'No leave requests found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: adminLeaveController.leaveRequests.length,
          itemBuilder: (context, index) {
            final leave = adminLeaveController.leaveRequests[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${leave['user_name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Reason: ${leave['reason']}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date: ${leave['created_at']}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    leave['status'] == 'pending'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                tooltip: 'Approve',
                                onPressed: () {
                                  adminLeaveController.updateLeaveStatus(
                                      leave['leave_id'], 'approved');
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Reject',
                                onPressed: () {
                                  adminLeaveController.updateLeaveStatus(
                                      leave['leave_id'], 'rejected');
                                },
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Status: ${leave['status']}".capitalize!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: leave['status'] == 'approved'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
