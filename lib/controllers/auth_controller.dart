import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../views/user_dashboard.dart';
import '../views/admin_dashboard.dart';
import '../utils/session_manager.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final String _rememberMeKey = 'remember_me';
  final String _userIdKey = 'user_id';

  void loginUser(String email, String password,
      {bool rememberMe = false}) async {
    isLoading.value = true;
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        final user = result.first;
        SessionManager.userId = user['id'] as int;

        final role = user['role'] as String;
        if (rememberMe) {
          if (SessionManager.userId != null) {
            await _saveRememberedUser(SessionManager.userId!);
          }
        } else {
          await _clearRememberedUser();
        }

        if (role == 'admin') {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => UserDashboard());
        }
      } else {
        Get.snackbar('Error', 'Invalid email or password');
      }
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser(String name, String email, String password,
      String role, String profilePicturePath) async {
    isLoading.value = true;
    try {
      final db = await DatabaseHelper.instance.database;

      await db.insert(
        'users',
        {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'profile_picture': profilePicturePath,
        },
      );

      Get.snackbar('Success', 'Registration successful');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to register user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveRememberedUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, true);
    await prefs.setInt(_userIdKey, userId);
  }

  Future<void> _clearRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_userIdKey);
  }

  Future<int?> getRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
    if (isRemembered) {
      return prefs.getInt(_userIdKey);
    }
    return null;
  }
}
