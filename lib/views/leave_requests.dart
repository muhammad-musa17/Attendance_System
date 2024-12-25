import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leave_controller.dart';
import '../utils/session_manager.dart';

class LeaveRequestScreen extends StatelessWidget {
  final LeaveController leaveController = Get.put(LeaveController());
  final _reasonController = TextEditingController();

  LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int? userId = SessionManager.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Leave Requests'),
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

    leaveController.fetchLeaveRequests(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Leave Requests'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Leave',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Obx(() {
              return leaveController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () {
                        final reason = _reasonController.text.trim();
                        if (reason.isEmpty) {
                          Get.snackbar('Error', 'Reason cannot be empty',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                          return;
                        }
                        leaveController.requestLeave(userId, reason);
                        _reasonController.clear();
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Submit Leave Request',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
            }),
            const SizedBox(height: 20),
            Obx(() {
              if (leaveController.leaveRequests.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      'No leave requests found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: leaveController.leaveRequests.length,
                  itemBuilder: (context, index) {
                    final leave = leaveController.leaveRequests[index];
                    final statusColor = _getStatusColor(leave['status']);
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.request_page,
                          color: statusColor,
                        ),
                        title: Text(
                          leave['reason'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                        subtitle: Text(
                          'Status: ${leave['status']}',
                          style: TextStyle(color: statusColor),
                        ),
                        trailing: Text(
                          leave['created_at'] ?? 'Pending',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
