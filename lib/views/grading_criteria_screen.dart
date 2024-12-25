import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_grading_controller.dart';

class GradingCriteriaScreen extends StatelessWidget {
  GradingCriteriaScreen({super.key}) {
    if (!Get.isRegistered<AdminGradingController>()) {
      Get.lazyPut(() => AdminGradingController());
    }
  }

  final AdminGradingController gradingController = Get.find();

  @override
  Widget build(BuildContext context) {
    gradingController.fetchGrades();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Grading Criteria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (gradingController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: gradingController.grades.length,
          itemBuilder: (context, index) {
            final grade = gradingController.grades[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('Grade: ${grade['grade']}'),
                subtitle: Text(
                    'Days: ${grade['min_days']} - ${grade['max_days']} days'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditGradeDialog(
                          context,
                          grade['id'] as int,
                          grade['grade'] as String,
                          grade['min_days'] as int,
                          grade['max_days'] as int,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        gradingController.deleteGrade(grade['id'] as int);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGradeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context) {
    final gradeController = TextEditingController();
    final minDaysController = TextEditingController();
    final maxDaysController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Grade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Grade'),
              ),
              TextField(
                controller: minDaysController,
                decoration: const InputDecoration(labelText: 'Minimum Days'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxDaysController,
                decoration: const InputDecoration(labelText: 'Maximum Days'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                final grade = gradeController.text.trim();
                final minDays = int.tryParse(minDaysController.text.trim());
                final maxDays = int.tryParse(maxDaysController.text.trim());

                if (grade.isEmpty || minDays == null || maxDays == null) {
                  Get.snackbar('Error', 'Please fill out all fields correctly');
                  return;
                }

                gradingController.addGrade(grade, minDays, maxDays);
                Get.back();
              },
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showEditGradeDialog(
    BuildContext context,
    int id,
    String grade,
    int minDays,
    int maxDays,
  ) {
    final gradeController = TextEditingController(text: grade);
    final minDaysController = TextEditingController(text: minDays.toString());
    final maxDaysController = TextEditingController(text: maxDays.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Grade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Grade'),
              ),
              TextField(
                controller: minDaysController,
                decoration: const InputDecoration(labelText: 'Minimum Days'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxDaysController,
                decoration: const InputDecoration(labelText: 'Maximum Days'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedGrade = gradeController.text.trim();
                final updatedMinDays =
                    int.tryParse(minDaysController.text.trim());
                final updatedMaxDays =
                    int.tryParse(maxDaysController.text.trim());

                if (updatedGrade.isEmpty ||
                    updatedMinDays == null ||
                    updatedMaxDays == null) {
                  Get.snackbar('Error', 'Please fill out all fields correctly');
                  return;
                }

                gradingController.editGrade(
                  id,
                  updatedGrade,
                  updatedMinDays,
                  updatedMaxDays,
                );
                Get.back();
              },
              child:
                  const Text('Update', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
