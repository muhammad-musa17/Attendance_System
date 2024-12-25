import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProfileController extends GetxController {
  Rx<File?> profilePictureFile = Rx<File?>(null);
  RxBool isUploading = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userRole = ''.obs;

  Future<void> pickAndSaveProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        Get.snackbar('Error', 'No image selected');
        return;
      }

      final file = File(pickedFile.path);
      profilePictureFile.value = file;
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'profile',
        {'profile_picture': file.path},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Get.snackbar('Success', 'Profile picture updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile picture: $e');
    }
  }

  Future<void> fetchProfilePicture() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('profile', limit: 1);

      if (result.isNotEmpty) {
        profilePictureFile.value =
            File(result.first['profile_picture'] as String);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch profile picture: $e');
    }
  }
}
