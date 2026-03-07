import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:splitify/features/profile/profile_service.dart';
import 'package:splitify/features/profile/user_model.dart';

import '../auth/login_view.dart';

class ProfileController extends GetxController {
  var user = UserModel().obs;

  Future<void> getUserDetails() async {
    try {
      user.value = await ProfileService().getUser();
    } catch (e) {
      // Token invalid/expired
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'token');
      Get.offAll(() => LoginView());
    }
  }
}
