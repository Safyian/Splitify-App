import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:splittify/core/theme/app_themes.dart';

import '../../../core/bindings/initial_binding.dart';
import '../../../core/constants/constants.dart';
import '../../navigation/navigation_view.dart';
import '../../profile/profile_controller.dart';
import '../Controllers/auth_controller.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  final AuthController auth = Get.find<AuthController>();
  final ProfileController profileCtrl = Get.find<ProfileController>();

  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _ctrl.forward();
    _runStartup();
  }

  Future<void> _runStartup() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    await auth.checkLogin();

    if (!auth.isLoggedIn.value) {
      Get.off(() => LoginView());
      return;
    }
    try {
      final ok = await profileCtrl.getUserDetails();
      if (ok) loadInitialAppData();
      Get.off(() => ok ? NavigationView() : LoginView());
    } catch (_) {
      // Token exists but network failed — offer retry instead of logging out
      Get.off(() => _ConnectionRetryView(onRetry: () {
            Get.off(() => const SplashView()); // re-run the whole startup
          }));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Stack(
        children: [
          // ── Decorative top-right blob ────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.activeColor.withOpacity(0.08),
              ),
            ),
          ),

          // ── Decorative bottom-left blob ──────────────────────
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.activeColor.withOpacity(0.06),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) => Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideUp.value),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  SvgPicture.asset(
                    Constants.splitifyLogo,
                    height: 88,
                  ),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    'Splittify',
                    style: AppTheme.headingText.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Constants.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Split smart. Settle fast.',
                    style: AppTheme.subHeadingText.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom loading indicator ─────────────────────────
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Constants.activeColor.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Getting things ready…',
                    style: AppTheme.normalText.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// retry screen when connection fails
class _ConnectionRetryView extends StatelessWidget {
  const _ConnectionRetryView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text("Couldn't connect", style: AppTheme.subHeadingText),
              const SizedBox(height: 6),
              Text(
                "Check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: AppTheme.normalText.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                  decoration: BoxDecoration(
                    color: Constants.activeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Try again',
                    style: AppTheme.subHeadingText.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
