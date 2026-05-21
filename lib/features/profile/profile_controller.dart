// lib/features/profile/profile_controller.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:splittify/features/profile/profile_service.dart';
import 'package:splittify/features/profile/user_model.dart';

import '../auth/login_view.dart';

class ProfileController extends GetxController {
  final _service = ProfileService();
  final storage = const FlutterSecureStorage();

  var user = UserModel().obs;
  var isUpdatingName = false.obs;
  var isDeletingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> getUserDetails() async {
    try {
      user.value = await _service.getUser();
    } catch (e) {
      await storage.delete(key: 'token');
      Get.offAll(() => LoginView());
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
