import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../core/utils/onboarding_helper.dart';
import 'widgets/hero_start_group.dart';
import 'widgets/hero_split_expense.dart';
import 'widgets/hero_settle_up.dart';

class _Page {
  const _Page({required this.hero, required this.title, required this.subtitle});
  final Widget hero;
  final String title;
  final String subtitle;
}

/// Educational onboarding shown once after the first login.
///
/// Pass [onDone] to control where it goes when finished/skipped (e.g.
/// navigate to your NavigationView). The onboarding itself only marks the
/// local "seen" flag — it doesn't know about your routes.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_Page>[
    _Page(
      hero: HeroStartGroup(),
      title: 'Start a group',
      subtitle:
          'Add friends, flatmates, or travel buddies — anyone you share costs with.',
    ),
    _Page(
      hero: HeroSplitExpense(),
      title: 'Split any expense',
      subtitle:
          'Equally, by exact amounts, or by percentage — Splittify does the math.',
    ),
    _Page(
      hero: HeroSettleUp(),
      title: 'Settle up, stress-free',
      subtitle:
          'See who owes who at a glance, then settle in the fewest payments.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    await OnboardingHelper.markSeen();
    widget.onDone();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip (fades out on the last page)
            SizedBox(
              height: 48.h,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: _isLast,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: AppTheme.normalText.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero animation (fixed stage)
                        p.hero,
                        SizedBox(height: 36.h),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: AppTheme.headingText.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Constants.textDark,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTheme.normalText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: i == _page ? 24.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? Constants.activeColor
                        : Constants.activeColor.withAlpha(60),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),

            // Next / Get Started
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.activeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isLast ? 'Get Started' : 'Next',
                      key: ValueKey(_isLast),
                      style: AppTheme.subHeadingText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
