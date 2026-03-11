// lib/features/profile/profile_controller.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:splitify/features/profile/profile_service.dart';
import 'package:splitify/features/profile/user_model.dart';

import '../auth/login_view.dart';

class ProfileController extends GetxController {
  final _service = ProfileService();
  final storage = const FlutterSecureStorage();

  var user = UserModel().obs;
  var isUpdatingName = false.obs;
  var isDeletingAccount = false.obs;

  // Persisted preference — read on init, written on change
  var defaultSplitType = 'equal'.obs; // 'equal' | 'exact' | 'percentage'

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final saved = await storage.read(key: 'defaultSplitType');
    if (saved != null) defaultSplitType.value = saved;
  }

  Future<void> setDefaultSplitType(String type) async {
    defaultSplitType.value = type;
    await storage.write(key: 'defaultSplitType', value: type);
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
      await storage.delete(key: 'defaultSplitType');
      Get.offAll(() => LoginView());
    } catch (e) {
      Get.snackbar('Error', 'Could not delete account. Try again.');
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get splitTypeLabel {
    switch (defaultSplitType.value) {
      case 'exact':
        return 'Exact';
      case 'percentage':
        return 'Percentage';
      default:
        return 'Equal';
    }
  }
}
