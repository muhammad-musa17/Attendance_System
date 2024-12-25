import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_leave_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_reports_screen.dart';
import 'grading_criteria_screen.dart';
import 'grading_report_screen.dart';
import '../utils/logout.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome, Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  icon: Icons.approval,
                  title: "Manage Leave Requests",
                  color: Colors.orangeAccent,
                  onTap: () => Get.to(() => AdminLeaveScreen()),
                ),
                _buildDashboardCard(
                  icon: Icons.assignment,
                  title: "View Attendance Records",
                  color: Colors.green,
                  onTap: () => Get.to(() => AdminAttendanceScreen()),
                ),
                _buildDashboardCard(
                  icon: Icons.bar_chart,
                  title: "Generate Reports",
                  color: Colors.blue,
                  onTap: () => Get.to(() => AdminReportsScreen()),
                ),
                _buildDashboardCard(
                  icon: Icons.grade,
                  title: "Manage Grading Criteria",
                  color: Colors.purpleAccent,
                  onTap: () => Get.to(() => GradingCriteriaScreen()),
                ),
                _buildDashboardCard(
                  icon: Icons.report,
                  title: "View Grading Report",
                  color: Colors.deepPurple,
                  onTap: () => Get.to(() => GradingReportScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
