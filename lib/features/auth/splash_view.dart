import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigation/navigation_view.dart';
import '../profile/profile_controller.dart';
import 'auth_controller.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController auth = Get.put(AuthController());

  final ProfileController profileCtrl = Get.put(ProfileController());
  Future<void> checkUser() async {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await profileCtrl.getUserDetails();
      if (auth.isLoggedIn.value && profileCtrl.user.value.user != null) {
        Get.offAll(() => NavigationView());
      } else {
        Get.offAll(() => LoginView());
      }
    });
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
