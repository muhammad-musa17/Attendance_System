import 'package:get/get.dart';
import '../database/database_helper.dart';

class LeaveController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> leaveRequests = <Map<String, dynamic>>[].obs;

  Future<void> requestLeave(int userId, String reason) async {
    isLoading.value = true;
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('leave_requests', {
        'user_id': userId,
        'reason': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      await fetchLeaveRequests(userId);
      Get.snackbar('Success', 'Leave request submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeaveRequests(int userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'leave_requests',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      leaveRequests.value = result.map((leave) {
        return {
          'id': leave['id'],
          'reason': leave['reason'],
          'status': leave['status'],
          'created_at': leave['created_at'],
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leave requests: $e');
    }
  }
}
