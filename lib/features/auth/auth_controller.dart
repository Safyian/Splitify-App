import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../navigation/navigation_view.dart';
import 'auth_services.dart';
import 'login_view.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();
  final storage = const FlutterSecureStorage();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  RxBool isLoggedIn = false.obs;
  var isLoading = false.obs;

  // ✅ Just reads token, NO navigation
  Future<void> checkLogin() async {
    final token = await storage.read(key: "token");
    isLoggedIn.value = token != null;
  }

  Future login() async {
    try {
      isLoading.value = true;

      final res = await _service.login(
        emailCtrl.text,
        passCtrl.text,
      );

      final token = res["token"];
      await storage.write(key: "token", value: token);

      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();

      Get.offAll(() => NavigationView());
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Login failed",
            snackPosition: SnackPosition.BOTTOM);
      });
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Success", "Account created",
            snackPosition: SnackPosition.BOTTOM);
      });
      Get.back();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Register failed",
            snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future logout() async {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.closeAllSnackbars();
    await storage.delete(key: "token");
    Get.offAll(() => LoginView());
  }

  @override
  void onInit() {
    super.onInit();
    checkLogin(); // ✅ only sets isLoggedIn, no navigation
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.onClose();
  }
}
