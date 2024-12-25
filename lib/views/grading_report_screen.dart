import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_grading_controller.dart';

class GradingReportScreen extends StatelessWidget {
  final AdminGradingController gradingController =
      Get.put(AdminGradingController());

  GradingReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Grading Report',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: gradingController.generateGradingReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No grading data available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final gradingReport = snapshot.data!
              .where((report) => report['user_name'] != 'admin')
              .toList();

          if (gradingReport.isEmpty) {
            return const Center(
              child: Text(
                'No student grading data available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: gradingReport.length,
              itemBuilder: (context, index) {
                final report = gradingReport[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Colors.blueAccent),
                    ),
                    title: Text(
                      report['user_name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Attendance: ${report['attendance_days']} days',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        report['grade'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
