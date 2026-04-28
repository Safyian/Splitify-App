import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'login_view.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final c = Get.find<AuthController>();

  // Local state: tracks whether the email was submitted successfully
  final _emailSent = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Obx(() => _emailSent.value ? _sentState() : _formState()),
      ),
    );
  }

  // ── State 1: Email input form ──────────────────────────────────────────────
  Widget _formState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── Back button ───────────────────────────────────────
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 40),

          // ── Icon ──────────────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Constants.activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                size: 36, color: Constants.activeColor),
          ),

          const SizedBox(height: 28),

          // ── Heading ───────────────────────────────────────────
          Text(
            'Forgot password?',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Constants.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No worries. Enter your email and we'll send you a reset link.",
            style: AppTheme.normalText.copyWith(
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // ── Email field ───────────────────────────────────────
          const AuthLabel('Email'),
          const SizedBox(height: 8),
          Obx(() => AuthInputField(
                controller: c.forgotEmailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                errorText: c.fieldErrors['forgotEmail'],
              )),

          const SizedBox(height: 32),

          // ── Submit button ─────────────────────────────────────
          Obx(() => c.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Constants.activeColor),
                )
              : AuthPrimaryButton(
                  label: 'Send reset link',
                  onTap: () async {
                    final success = await c.forgotPassword();
                    if (success) _emailSent.value = true;
                  },
                )),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── State 2: "Check your email" confirmation ──────────────────────────────
  Widget _sentState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 72),

          // ── Icon ──────────────────────────────────────────────
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Constants.activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_outlined,
                size: 48, color: Constants.activeColor),
          ),

          const SizedBox(height: 36),

          // ── Heading ───────────────────────────────────────────
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Constants.textDark,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "We've sent a password reset link to",
            textAlign: TextAlign.center,
            style: AppTheme.normalText.copyWith(color: Colors.grey.shade500),
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
              c.forgotEmailCtrl.text.trim(),
              style: AppTheme.normalText.copyWith(
                fontWeight: FontWeight.w600,
                color: Constants.textDark,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Click the link in the email to reset your password.\nThe link expires in 1 hour.',
            textAlign: TextAlign.center,
            style: AppTheme.normalText.copyWith(
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 48),

          // ── Resend button ─────────────────────────────────────
          Obx(() => c.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Constants.activeColor),
                )
              : AuthPrimaryButton(
                  label: 'Resend reset email',
                  onTap: () async {
                    await c.forgotPassword();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.snackbar(
                        "Email sent",
                        "A new reset link has been sent to your inbox",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                )),

          const SizedBox(height: 24),

          // ── Back to login ─────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () => Get.offAll(() => LoginView()),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Remember your password? ',
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
    );
  }
}
