import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/constants.dart';
import 'connector_painter.dart';
import 'onboarding_motion.dart';

/// Hero 1 — "Start a group".
/// A group emoji tile springs in at center, connecting lines draw outward,
/// and member avatars pop in around it. Loops forever.
class HeroStartGroup extends StatefulWidget {
  const HeroStartGroup({super.key});

  @override
  State<HeroStartGroup> createState() => _HeroStartGroupState();
}

class _HeroStartGroupState extends State<HeroStartGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: OnboardingMotion.loop,
  )..repeat();

  // Avatar corner positions as fractional offsets of the 260x250 stage.
  static const _avatarSpots = [
    _Avatar('A', Offset(0.17, 0.20), Color(0xFFE1F5EE), Color(0xFF0F6E56)),
    _Avatar('B', Offset(0.80, 0.24), Color(0xFFFAECE7), Color(0xFF993C1D)),
    _Avatar('J', Offset(0.20, 0.80), Color(0xFFEEEDFE), Color(0xFF3C3489)),
    _Avatar('M', Offset(0.80, 0.82), Color(0xFFFBEAF0), Color(0xFF993556)),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = OnboardingMotion.popIn(_c, start: 0.0, appearSpan: 0.14);
    final lineProgress = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.12, 0.42, curve: Curves.easeOut),
    );

    return SizedBox(
      width: 260.w,
      height: 250.h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Connecting lines
              Positioned.fill(
                child: CustomPaint(
                  painter: ConnectorPainter(
                    center: const Offset(0.5, 0.5),
                    points: _avatarSpots.map((a) => a.pos).toList(),
                    progress: lineProgress.value,
                    color: const Color(0xFF9FE1CB),
                    strokeWidth: 2.5.w,
                  ),
                ),
              ),

              // Center emoji tile
              Align(
                alignment: Alignment.center,
                child: PresenceTransform(
                  value: tile.value,
                  fromScale: 0.2,
                  child: Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Constants.activeColor.withAlpha(46),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text('🏠', style: TextStyle(fontSize: 42.sp)),
                  ),
                ),
              ),

              // Member avatars (staggered pop-in)
              for (var i = 0; i < _avatarSpots.length; i++)
                _positioned(
                  _avatarSpots[i],
                  OnboardingMotion.popIn(
                    _c,
                    start: 0.08 + i * 0.045,
                    appearSpan: 0.12,
                  ).value,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _positioned(_Avatar a, double presence) {
    const stageW = 260.0;
    const stageH = 250.0;
    const size = 52.0;
    final left = a.pos.dx * stageW - size / 2;
    final top = a.pos.dy * stageH - size / 2;
    return Positioned(
      left: left.w,
      top: top.h,
      child: PresenceTransform(
        value: presence,
        fromScale: 0.2,
        child: Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: a.bg,
            shape: BoxShape.circle,
            border: Border.all(color: Constants.bgColorLight, width: 3.w),
          ),
          alignment: Alignment.center,
          child: Text(
            a.initial,
            style: TextStyle(
              color: a.fg,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar {
  const _Avatar(this.initial, this.pos, this.bg, this.fg);
  final String initial;
  final Offset pos;
  final Color bg;
  final Color fg;
}
