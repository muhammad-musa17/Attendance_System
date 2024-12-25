import 'package:get/get.dart';
import '../database/database_helper.dart';

class AdminLeaveController extends GetxController {
  RxList<Map<String, dynamic>> leaveRequests = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchLeaveRequests() async {
    try {
      isLoading.value = true;
      final db = await DatabaseHelper.instance.database;

      final result = await db.rawQuery('''
        SELECT l.id AS leave_id, l.user_id, l.reason, l.status, l.created_at, u.name AS user_name
        FROM leave_requests AS l
        INNER JOIN users AS u ON l.user_id = u.id
        ORDER BY l.created_at DESC
      ''');

      leaveRequests.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leave requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLeaveStatus(int leaveId, String newStatus) async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.update(
        'leave_requests',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [leaveId],
      );

      await fetchLeaveRequests();

      Get.snackbar('Success', 'Leave request updated to $newStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update leave status: $e');
    }
  }
}
