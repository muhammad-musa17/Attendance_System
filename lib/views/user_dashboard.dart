import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'attendance_screen.dart';
import 'view_attendance_screen.dart';
import 'leave_requests.dart';
import 'profile_screen.dart';
import '../utils/logout.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'User Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Welcome!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardOption(
                    icon: Icons.fingerprint,
                    label: "Mark Attendance",
                    onTap: () => Get.to(() => AttendanceScreen()),
                  ),
                  _buildDashboardOption(
                    icon: Icons.history,
                    label: "View Attendance",
                    onTap: () => Get.to(() => ViewAttendanceScreen()),
                  ),
                  _buildDashboardOption(
                    icon: Icons.request_page,
                    label: "Request Leave",
                    onTap: () => Get.to(() => LeaveRequestScreen()),
                  ),
                  _buildDashboardOption(
                    icon: Icons.person,
                    label: "Edit Profile",
                    onTap: () => Get.to(() => ProfileScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
