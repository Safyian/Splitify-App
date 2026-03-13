import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final c = Get.find<AuthController>();
  final _obscure = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // ── Branding ──────────────────────────────────────
              SvgPicture.asset(
                Constants.splitifyLogo,
                height: 44,
              ),

              const SizedBox(height: 48),

              // ── Heading ───────────────────────────────────────
              Text(
                'Create your account ✨',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Constants.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Split expenses fairly with anyone',
                style: AppTheme.normalText.copyWith(color: Colors.grey.shade500),
              ),

              const SizedBox(height: 40),

              // ── Name ──────────────────────────────────────────
              const AuthLabel('Full name'),
              const SizedBox(height: 8),
              AuthInputField(
                controller: c.nameCtrl,
                hint: 'John Doe',
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 20),

              // ── Email ─────────────────────────────────────────
              const AuthLabel('Email'),
              const SizedBox(height: 8),
              AuthInputField(
                controller: c.emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
              ),

              const SizedBox(height: 20),

              // ── Password ──────────────────────────────────────
              const AuthLabel('Password'),
              const SizedBox(height: 8),
              Obx(() => AuthInputField(
                    controller: c.passCtrl,
                    hint: '••••••••',
                    obscure: _obscure.value,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffix: GestureDetector(
                      onTap: () => _obscure.value = !_obscure.value,
                      child: Icon(
                        _obscure.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )),

              const SizedBox(height: 36),

              // ── Create account button ─────────────────────────
              Obx(() => c.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Constants.activeColor),
                    )
                  : AuthPrimaryButton(
                      label: 'Create account', onTap: c.register)),

              const SizedBox(height: 28),

              // ── Login link ────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Already have an account? ',
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
