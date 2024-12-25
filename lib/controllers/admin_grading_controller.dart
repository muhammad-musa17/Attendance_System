import 'package:get/get.dart';
import '../database/database_helper.dart';

class AdminGradingController extends GetxController {
  RxList<Map<String, dynamic>> grades = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchGrades() async {
    try {
      isLoading.value = true;
      final db = await DatabaseHelper.instance.database;

      final result = await db.query('grades', orderBy: 'min_days ASC');

      grades.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch grades: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGrade(String grade, int minDays, int maxDays) async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.insert('grades', {
        'grade': grade,
        'min_days': minDays,
        'max_days': maxDays,
      });

      Get.snackbar('Success', 'Grade added successfully');
      await fetchGrades();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add grade: $e');
    }
  }

  Future<void> updateGrade(
      int id, String grade, int minDays, int maxDays) async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.update(
        'grades',
        {
          'grade': grade,
          'min_days': minDays,
          'max_days': maxDays,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      Get.snackbar('Success', 'Grade updated successfully');
      await fetchGrades();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update grade: $e');
    }
  }

  Future<void> deleteGrade(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.delete('grades', where: 'id = ?', whereArgs: [id]);

      Get.snackbar('Success', 'Grade deleted successfully');
      await fetchGrades();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete grade: $e');
    }
  }

  Future<void> editGrade(int id, String grade, int minDays, int maxDays) async {
    // Alias to updateGrade for consistency with the UI
    await updateGrade(id, grade, minDays, maxDays);
  }

  Future<List<Map<String, dynamic>>> generateGradingReport() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT u.id AS user_id, u.name AS user_name, COUNT(a.id) AS attendance_days
      FROM users AS u
      LEFT JOIN attendance AS a ON u.id = a.user_id AND a.status = 'present'
      WHERE u.role != 'admin'
      GROUP BY u.id
    ''');

    List<Map<String, dynamic>> gradingReport = [];

    for (var user in result) {
      final attendanceDays = user['attendance_days'] as int? ?? 0;

      final gradeResult = await db.rawQuery('''
        SELECT grade FROM grades
        WHERE ? BETWEEN min_days AND max_days
      ''', [attendanceDays]);

      final grade = gradeResult.isNotEmpty ? gradeResult.first['grade'] : 'N/A';

      gradingReport.add({
        'user_name': user['user_name'],
        'attendance_days': attendanceDays,
        'grade': grade,
      });
    }

    return gradingReport;
  }
}
