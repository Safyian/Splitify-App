import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/constants.dart';
import 'onboarding_motion.dart';

/// Hero 2 — "Split any expense".
/// A $120 amount card springs in, holds, then shrinks as four equal share
/// pills pop out toward member avatars in the corners. Loops forever.
class HeroSplitExpense extends StatefulWidget {
  const HeroSplitExpense({super.key});

  @override
  State<HeroSplitExpense> createState() => _HeroSplitExpenseState();
}

class _HeroSplitExpenseState extends State<HeroSplitExpense>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: OnboardingMotion.loop,
  )..repeat();

  static const _shares = [
    _Share('A', '\$30', Offset(0.16, 0.16), Color(0xFFE1F5EE), Color(0xFF0F6E56), false),
    _Share('B', '\$30', Offset(0.84, 0.20), Color(0xFFFAECE7), Color(0xFF993C1D), true),
    _Share('J', '\$30', Offset(0.16, 0.84), Color(0xFFEEEDFE), Color(0xFF3C3489), false),
    _Share('M', '\$30', Offset(0.84, 0.86), Color(0xFFFBEAF0), Color(0xFF993556), true),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Amount card: present from the very start, then shrinks slightly when
    // shares appear (~0.40) and fades near the loop end.
    final amountPresence = OnboardingMotion.popIn(
      _c,
      start: 0.0,
      appearSpan: 0.14,
      holdUntil: 0.80,
    );
    final t = _c.value;
    // subtle shrink after 0.40
    final shrink = t < 0.40
        ? 1.0
        : t < 0.48
            ? 1.0 - 0.1 * ((t - 0.40) / 0.08)
            : 0.9;

    return SizedBox(
      width: 260.w,
      height: 250.h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Center amount card
              Align(
                alignment: Alignment.center,
                child: PresenceTransform(
                  value: amountPresence.value,
                  baseScale: shrink,
                  fromScale: 0.3,
                  child: Container(
                    width: 100.w,
                    height: 72.h,
                    decoration: BoxDecoration(
                      color: Constants.activeColor,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dinner',
                            style: TextStyle(
                                color: Colors.white.withAlpha(217),
                                fontSize: 11.sp)),
                        Text('\$120',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),

              // Share pills + avatars
              for (var i = 0; i < _shares.length; i++)
                _shareWidget(
                  _shares[i],
                  OnboardingMotion.popIn(
                    _c,
                    start: 0.40 + i * 0.035,
                    appearSpan: 0.10,
                    holdUntil: 0.80,
                  ).value,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _shareWidget(_Share s, double presence) {
    const stageW = 260.0;
    const stageH = 250.0;
    final avatar = Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: s.bg,
        shape: BoxShape.circle,
        border: Border.all(color: Constants.bgColorLight, width: 2.w),
      ),
      alignment: Alignment.center,
      child: Text(s.initial,
          style: TextStyle(
              color: s.fg, fontWeight: FontWeight.w600, fontSize: 14.sp)),
    );
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(s.amount,
          style: TextStyle(
              color: const Color(0xFF0F6E56),
              fontWeight: FontWeight.w600,
              fontSize: 13.sp)),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: s.pillFirst
          ? [pill, SizedBox(width: 6.w), avatar]
          : [avatar, SizedBox(width: 6.w), pill],
    );

    // Anchor by the avatar corner; approximate cluster width.
    final left = s.pos.dx * stageW - (s.pillFirst ? 78 : 20);
    final top = s.pos.dy * stageH - 19;
    return Positioned(
      left: left.w,
      top: top.h,
      child: PresenceTransform(value: presence, fromScale: 0.4, child: row),
    );
  }
}

class _Share {
  const _Share(
      this.initial, this.amount, this.pos, this.bg, this.fg, this.pillFirst);
  final String initial;
  final String amount;
  final Offset pos;
  final Color bg;
  final Color fg;
  final bool pillFirst; // pill left of avatar (right-side clusters)
}
