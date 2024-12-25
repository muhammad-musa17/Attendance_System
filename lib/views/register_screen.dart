import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RxString selectedRole = ''.obs;
  final RxString profilePicturePath = ''.obs;

  final List<String> roles = ['user', 'admin'];

  RegisterScreen({super.key});

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profilePicturePath.value = pickedFile.path;
    } else {
      Get.snackbar('Error', 'No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return authController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Select Role",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole.value.isEmpty
                            ? null
                            : selectedRole.value,
                        hint: const Text('Select Role'),
                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) selectedRole.value = value;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        return Column(
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: profilePicturePath
                                        .value.isNotEmpty
                                    ? FileImage(File(profilePicturePath.value))
                                    : const AssetImage(
                                            'assets/default_profile.jpg')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: TextButton.icon(
                                onPressed: pickImage,
                                icon: const Icon(Icons.upload,
                                    color: Colors.blueAccent),
                                label: const Text("Upload Profile Picture",
                                    style: TextStyle(color: Colors.blueAccent)),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              Get.snackbar(
                                'Error',
                                'Passwords do not match',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (selectedRole.value.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please select a role',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            authController.registerUser(
                              _nameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              selectedRole.value,
                              profilePicturePath.value.isEmpty
                                  ? 'assets/default_profile.jpg'
                                  : profilePicturePath.value,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Register',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }
}
