import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_themes.dart';
import '../Controllers/auth_controller.dart';
import '../auth_widgets.dart';
import 'login_view.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 72),

              // ── Envelope illustration ──────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Constants.activeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: Constants.activeColor,
                ),
              ),

              const SizedBox(height: 36),

              // ── Heading ───────────────────────────────────────
              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: AppTheme.headingText.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Constants.textDark,
                ),
              ),

              const SizedBox(height: 14),

              // ── Subtitle ──────────────────────────────────────
              Text(
                "We've sent a verification link to",
                textAlign: TextAlign.center,
                style:
                    AppTheme.normalText.copyWith(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  email,
                  style: AppTheme.normalText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Constants.textDark,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Click the link in the email to activate your account.\nThe link expires in 24 hours.',
                textAlign: TextAlign.center,
                style: AppTheme.normalText.copyWith(
                  color: Colors.grey.shade500,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 48),

              // ── Resend button ─────────────────────────────────
              Obx(() => c.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Constants.activeColor),
                    )
                  : AuthPrimaryButton(
                      label: 'Resend verification email',
                      onTap: () => c.resendVerification(email),
                    )),

              const SizedBox(height: 24),

              // ── Back to login ─────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.offAll(() => LoginView()),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Already verified? ',
                        style: AppTheme.normalText
                            .copyWith(color: Colors.grey.shade500),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
