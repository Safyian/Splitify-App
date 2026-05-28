import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'alert_widgets.dart';

class AppDialogs {
  AppDialogs._();

  // ── Loading state tracker ─────────────────────────────────
  static bool _isLoadingOpen = false;

  // ── LOADING ───────────────────────────────────────────────
  static void loading({
    String message = 'Please wait...',
    String? subtitle,
    IconData icon = Icons.hourglass_empty_rounded,
  }) {
    _isLoadingOpen = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Constants.bgColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Constants.activeColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon,
                      color: Constants.activeColor, size: 28.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: AppTheme.subHeadingText,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppTheme.normalText.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 20.h),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey.withAlpha(30),
                  color: Constants.activeColor,
                  borderRadius: BorderRadius.circular(2.r),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ── CLOSE LOADING ─────────────────────────────────────────
  static Future<void> closeLoading() async {
    if (_isLoadingOpen) {
      _isLoadingOpen = false;
      Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  // ── SUCCESS ───────────────────────────────────────────────
  static void success({
    required String title,
    String? message,
    IconData icon = Icons.check_rounded,
    Color? iconColor,
    String buttonLabel = 'Done',
    VoidCallback? onDone,
    int closePop = 1,
  }) {
    final color = iconColor ?? Constants.activeColor;
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(title,
                style: AppTheme.subHeadingText,
                textAlign: TextAlign.center),
            if (message != null) ...[
              SizedBox(height: 6.h),
              Text(
                message,
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (onDone != null) {
                onDone();
              } else {
                Get.close(closePop);
              }
            },
            child: Text(
              buttonLabel,
              style: AppTheme.normalText.copyWith(
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── ERROR / INFO ──────────────────────────────────────────
  static void info({
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
    String buttonLabel = 'OK',
    VoidCallback? onDone,
  }) {
    final color = iconColor ?? Constants.activeColor;
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(title, style: AppTheme.subHeadingText),
        content: Text(message, style: AppTheme.normalText),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              onDone?.call();
            },
            child: Text(buttonLabel,
                style: AppTheme.normalText.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── CONFIRM ───────────────────────────────────────────────
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color confirmColor = Constants.redColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(title, style: AppTheme.subHeadingText),
        content: Text(message, style: AppTheme.normalText),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel,
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmLabel,
              style: AppTheme.normalText.copyWith(
                  color: confirmColor,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── INVITE ────────────────────────────────────────────────
  static void invite({
    required String name,
    required String inviteMessage,
    required BuildContext context,
    VoidCallback? onSkip,
    Future<void> Function()? onInviteConfirmed,
    int closePop = 2,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.mail_outline_rounded,
                  color: Colors.orange.shade600, size: 26.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              '$name is not on Splittify yet',
              style: AppTheme.subHeadingText.copyWith(fontSize: 15.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Add them to your friends list and send an invitation to join Splittify.',
              style: AppTheme.normalText.copyWith(
                color: Colors.grey.shade400,
                fontSize: 13.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onSkip?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Constants.bgColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: Colors.grey.withAlpha(40)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Not now',
                        style: AppTheme.normalText.copyWith(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final box =
                          context.findRenderObject() as RenderBox?;
                      Navigator.of(Get.overlayContext!,
                              rootNavigator: true)
                          .pop();
                      AppDialogs.loading(
                        message: 'Adding friend...',
                        icon: Icons.person_add_outlined,
                      );
                      try {
                        if (onInviteConfirmed != null) {
                          await onInviteConfirmed();
                        }
                        await AppDialogs.closeLoading();
                        await Future.delayed(
                            const Duration(milliseconds: 300));
                        await SharePlus.instance.share(
                          ShareParams(
                            text: inviteMessage,
                            sharePositionOrigin: box != null
                                ? box.localToGlobal(Offset.zero) &
                                    box.size
                                : const Rect.fromLTWH(
                                    0, 0, 100, 100),
                          ),
                        );
                        Get.close(closePop - 1);
                      } catch (e) {
                        await AppDialogs.closeLoading();
                        AlertWidgets.showSnackBar(
                          message: e
                              .toString()
                              .replaceAll('Exception: ', ''),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Constants.activeColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Send Invite',
                        style: AppTheme.normalText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      barrierDismissible: false,
    );
  }
}
