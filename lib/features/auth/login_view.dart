import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final c = Get.put(AuthController());
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
                'Welcome back 👋',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Constants.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue splitting expenses',
                style: AppTheme.normalText.copyWith(color: Colors.grey.shade500),
              ),

              const SizedBox(height: 40),

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

              // ── Sign in button ────────────────────────────────
              Obx(() => c.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Constants.activeColor),
                    )
                  : AuthPrimaryButton(label: 'Sign in', onTap: c.login)),

              const SizedBox(height: 28),

              // ── Register link ─────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.to(() => RegisterView()),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: AppTheme.normalText
                            .copyWith(color: Colors.grey.shade500),
                      ),
                      TextSpan(
                        text: 'Sign up',
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
