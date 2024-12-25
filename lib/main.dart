import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/user_dashboard.dart';
import 'views/admin_dashboard.dart';
import 'views/admin_attendance_screen.dart';
import 'views/grading_criteria_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/admin_attendance_controller.dart';
import 'controllers/admin_grading_controller.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.lazyPut(() => AdminAttendanceController(), fenix: true);
  Get.lazyPut(() => AdminGradingController(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartScreen() async {
    final authController = Get.find<AuthController>();
    final userId = await authController.getRememberedUser();

    if (userId != null) {
      final db = await DatabaseHelper.instance.database;
      final result =
          await db.query('users', where: 'id = ?', whereArgs: [userId]);

      if (result.isNotEmpty) {
        final user = result.first;
        if (user['role'] == 'admin') {
          return const AdminDashboard();
        } else {
          return const UserDashboard();
        }
      }
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/user_dashboard', page: () => const UserDashboard()),
        GetPage(name: '/admin_dashboard', page: () => const AdminDashboard()),
        GetPage(
          name: '/admin_attendance',
          page: () => AdminAttendanceScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => AdminAttendanceController(), fenix: true);
          }),
        ),
        GetPage(
          name: '/grading_criteria',
          page: () => GradingCriteriaScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => AdminGradingController(), fenix: true);
          }),
        ),
      ],
      home: FutureBuilder<Widget>(
        future: _determineStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
