import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_themes.dart';
import '../Controllers/auth_controller.dart';
import '../auth_widgets.dart';
import 'login_view.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final c = Get.find<AuthController>();

  static const int _cooldownSeconds = 60; // adjust as you like
  int _countdown = _cooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown(); // start disabled on landing (email already sent by register)
  }

  void _startCountdown() {
    setState(() => _countdown = _cooldownSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _onResend() async {
    if (_countdown > 0) return;
    await c.resendVerification(widget.email);
    _startCountdown(); // restart cooldown after a resend
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _countdown == 0;
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
                  widget.email,
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
              Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Constants.activeColor),
                  );
                }
                if (_countdown > 0) {
                  return Opacity(
                    opacity: 0.5,
                    child: AuthPrimaryButton(
                      label: 'Resend available in ${_countdown}s',
                      onTap: () {},
                    ),
                  );
                }
                return AuthPrimaryButton(
                  label: 'Resend verification email',
                  onTap: _onResend,
                );
              }),

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
