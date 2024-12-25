import 'package:get/get.dart';
import '../views/login_screen.dart';

Future<void> logout() async {
  try {
    Get.offAll(() => LoginScreen());
  } catch (e) {
    Get.snackbar('Error', 'Failed to logout: $e');
  }
}
