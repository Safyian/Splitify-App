import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../navigation/navigation_view.dart';
import 'auth_services.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();
  final storage = const FlutterSecureStorage();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  RxBool isLoggedIn = false.obs;

  var isLoading = false.obs;

  Future login() async {
    try {
      isLoading.value = true;

      final res = await _service.login(
        emailCtrl.text,
        passCtrl.text,
      );
      final token = res["token"];

      await storage.write(
        key: "token",
        value: token,
      );

      Get.offAll(() => NavigationView());
    } catch (e) {
      Get.snackbar("Error", "Login failed");
    } finally {
      isLoading.value = false;
    }
  }

  Future register() async {
    try {
      isLoading.value = true;

      await _service.register(
        nameCtrl.text,
        emailCtrl.text,
        passCtrl.text,
      );

      Get.snackbar("Success", "Account created");
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Register failed");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkLogin() async {
    final token = await storage.read(key: "token");

    if (token != null) {
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: "token");
      isLoggedIn.value = false;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  void onInit() {
    checkLogin();
    super.onInit();
  }
}
