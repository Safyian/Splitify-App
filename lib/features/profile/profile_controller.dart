// lib/features/profile/profile_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:splittify/features/profile/profile_service.dart';
import 'package:splittify/features/profile/user_model.dart';

import '../auth/Views/login_view.dart';

class ProfileController extends GetxController {
  final _service = ProfileService();
  final storage = const FlutterSecureStorage();

  var user = UserModel().obs;
  var isUpdatingName = false.obs;
  var isDeletingAccount = false.obs;

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<bool> getUserDetails() async {
    try {
      user.value = await _service.getUser();
      return true;
    } catch (e) {
      // Only clear token on actual auth failure, not network errors
      if (e is DioException && e.response?.statusCode == 401) {
        await storage.delete(key: 'token');
        return false;
      }
      // network/other error — keep token, let caller decide
      rethrow;
    }
  }

  Future<bool> updateName(String newName) async {
    if (newName.trim().isEmpty) return false;
    try {
      isUpdatingName.value = true;
      user.value = await _service.updateName(newName.trim());
      return true;
    } catch (e) {
      return false;
    } finally {
      isUpdatingName.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isDeletingAccount.value = true;
      await _service.deleteAccount();
      await storage.delete(key: 'token');
      Get.offAll(() => LoginView());
    } catch (e) {
      Get.snackbar('Error', 'Could not delete account. Try again.');
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
