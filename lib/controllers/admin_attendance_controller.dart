import 'package:get/get.dart';
import '../database/database_helper.dart';

class AdminAttendanceController extends GetxController {
  RxList<Map<String, dynamic>> attendanceRecords = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchAttendanceRecords() async {
    try {
      isLoading.value = true;
      final db = await DatabaseHelper.instance.database;

      final results = await db.rawQuery('''
        SELECT u.name AS user_name, a.date AS date, a.status AS status
        FROM attendance AS a
        INNER JOIN users AS u ON a.user_id = u.id
        WHERE u.role != 'admin' -- Exclude admins
        ORDER BY a.date DESC
      ''');

      attendanceRecords.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance records: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
