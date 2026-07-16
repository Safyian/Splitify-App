import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/constants.dart';
import 'connector_painter.dart';
import 'onboarding_motion.dart';

/// Hero 3 — "Settle up, stress-free".
/// Members appear with tangled dashed debt arrows, the debts clear, a single
/// payment pill springs in, then resolves into a big checkmark. Loops forever.
class HeroSettleUp extends StatefulWidget {
  const HeroSettleUp({super.key});

  @override
  State<HeroSettleUp> createState() => _HeroSettleUpState();
}

class _HeroSettleUpState extends State<HeroSettleUp>
    with SingleTickerProviderStateMixin {
  // Slightly longer loop for the extra beat (arrows -> pay -> check).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7000),
  )..repeat();

  static const _people = [
    _Person('A', Offset(0.20, 0.20), Color(0xFFE1F5EE), Color(0xFF0F6E56)),
    _Person('B', Offset(0.80, 0.22), Color(0xFFFAECE7), Color(0xFF993C1D)),
    _Person('J', Offset(0.20, 0.80), Color(0xFFEEEDFE), Color(0xFF3C3489)),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _stage(double start, double end) {
    final t = _c.value;
    if (t < start) return 0.0;
    if (t > end) return 1.0;
    return (t - start) / (end - start);
  }

  double _window(double start, double appear, double hold, double fade) {
    final t = _c.value;
    if (t < start) return 0.0;
    if (t < start + appear) {
      return OnboardingMotion.spring
          .transform((t - start) / appear)
          .clamp(0.0, 1.0);
    }
    if (t < hold) return 1.0;
    if (t < hold + fade) {
      return (1.0 - Curves.easeIn.transform((t - hold) / fade)).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260.w,
      height: 250.h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          // Debt arrows: draw in early, fade before payment.
          final arrowsPresence = _window(0.02, 0.10, 0.36, 0.08);
          final arrowDraw = _stage(0.04, 0.20);
          // Payment pill: springs in mid-loop.
          final payPresence = _window(0.42, 0.08, 0.56, 0.06);
          // Checkmark: final beat.
          final checkPresence = _window(0.62, 0.10, 0.88, 0.06);
          // People: present until the checkmark takes over.
          final peoplePresence = _window(0.0, 0.06, 0.56, 0.08);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed debt arrows (coral = debt color)
              Positioned.fill(
                child: Opacity(
                  opacity: arrowsPresence.clamp(0.0, 1.0),
                  child: CustomPaint(
                    painter: ConnectorPainter(
                      center: const Offset(0.65, 0.5),
                      points: const [
                        Offset(0.20, 0.20),
                        Offset(0.80, 0.22),
                        Offset(0.20, 0.80),
                      ],
                      progress: arrowDraw,
                      color: Constants.redColor.withAlpha(200),
                      strokeWidth: 2.5.w,
                      dashed: true,
                    ),
                  ),
                ),
              ),

              // People
              for (final p in _people) _person(p, peoplePresence),

              // Single payment pill
              Align(
                alignment: Alignment.center,
                child: PresenceTransform(
                  value: payPresence,
                  fromScale: 0.4,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: [
                        BoxShadow(
                          color: Constants.activeColor.withAlpha(41),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            color: Constants.activeColor, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text('\$30',
                            style: TextStyle(
                                color: const Color(0xFF0F6E56),
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp)),
                      ],
                    ),
                  ),
                ),
              ),

              // Final checkmark
              Align(
                alignment: Alignment.center,
                child: PresenceTransform(
                  value: checkPresence,
                  fromScale: 0.2,
                  child: Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      color: Constants.activeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 38.sp),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _person(_Person p, double presence) {
    const stageW = 260.0;
    const stageH = 250.0;
    const size = 46.0;
    return Positioned(
      left: (p.pos.dx * stageW - size / 2).w,
      top: (p.pos.dy * stageH - size / 2).h,
      child: PresenceTransform(
        value: presence,
        fromScale: 0.5,
        child: Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: p.bg,
            shape: BoxShape.circle,
            border: Border.all(color: Constants.bgColorLight, width: 3.w),
          ),
          alignment: Alignment.center,
          child: Text(p.initial,
              style: TextStyle(
                  color: p.fg, fontWeight: FontWeight.w600, fontSize: 16.sp)),
        ),
      ),
    );
  }
}

class _Person {
  const _Person(this.initial, this.pos, this.bg, this.fg);
  final String initial;
  final Offset pos;
  final Color bg;
  final Color fg;
}
