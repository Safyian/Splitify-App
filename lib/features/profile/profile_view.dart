import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/auth/auth_controller.dart';

import '../../core/theme/app_themes.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Profile',
          style: AppTheme.headingText,
        ),
        actions: [
          SvgPicture.asset(
            Constants.premiumLogo,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      ),
      body: Container(
        color: Constants.bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () async {
                await authCtrl
                    .logout(); // logout() already calls Get.offAll internally
              },
              child: Container(
                width: Get.width,
                height: 0.05.sh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Constants.activeColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Logout",
                  style:
                      AppTheme.headingText.copyWith(color: Constants.textLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
