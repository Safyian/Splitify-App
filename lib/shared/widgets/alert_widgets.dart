import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:splitify/core/theme/app_themes.dart';

import '../../core/constants/constants.dart';

class AlertWidgets {
  // ******* Snackbar *******
  // AlertWidgets.showSnackBar(
  // message: 'Password is invalid. Please try again.');  ***** usage *****
  static void showSnackBar({required String message}) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      titleText: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          message,
          style: AppTheme.normalText.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      messageText: const SizedBox(),
      backgroundColor: Colors.teal.withOpacity(0.2),
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(55, 0, 55, 0),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  static void showLoadingDialog(BuildContext context,
      {String message = 'Loading...'}) {
    Get.dialog(
      LoadingDialog(message: message),
      barrierDismissible:
          false, // Prevents the dialog from being dismissed by tapping outside
    );
  }

  // AlertWidgets.showLoadingDialog(
  // context,
  // message: 'Signing in ...',
  // );      ****** usage ******
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // ******* Remove Item from Cart Dialog box *******
  static void showDialogLogout({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Constants.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          title: Column(
            children: [
              Text(
                "Are you sure you want to Logout?",
                style: AppTheme.normalText,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // if (!context.mounted) return;
                      // Navigator.pop(context);
                      // showLoadingDialog(context);
                      // await Get.find<ProfileController>().logOut();
                      // if (!context.mounted) return;
                      // // Navigator.pop(context);
                      // Get.offAll(() => SplashScreen());
                    },
                    child: Container(
                      width: 0.2.sw,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Constants.activeColor,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: AppTheme.normalText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 0.2.sw,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Constants.activeColor,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No",
                        style: AppTheme.normalText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Constants.activeColor,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: AppTheme.normalText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
