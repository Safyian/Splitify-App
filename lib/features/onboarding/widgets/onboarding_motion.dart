import 'package:flutter/material.dart';

/// Shared motion language for the onboarding hero animations.
///
/// One springy curve, one loop duration, and small helpers so all three
/// heroes feel like the same family.
class OnboardingMotion {
  OnboardingMotion._();

  /// Springy overshoot used for every pop-in (matches the approved previews:
  /// cubic-bezier(.34, 1.56, .5, 1)).
  static const Curve spring = Cubic(0.34, 1.56, 0.5, 1.0);

  /// Full loop length for each hero.
  static const Duration loop = Duration(milliseconds: 6000);

  /// Builds a staggered interval tween that pops from scale ~0 to 1 with a
  /// springy curve, visible between [start] and [end] of the loop, then
  /// fades out near the end so the loop restarts cleanly.
  static Animation<double> popIn(
    AnimationController c, {
    required double start,
    double appearSpan = 0.14,
    double holdUntil = 0.78,
  }) {
    // Opacity: 0 -> 1 during appear, hold, then 1 -> 0 before restart.
    return _StagedValue(
      parent: c,
      start: start,
      appearSpan: appearSpan,
      holdUntil: holdUntil,
    );
  }
}

/// Drives a 0..1 "presence" value: springs in, holds, fades out.
/// Used to drive both opacity and scale of hero elements.
class _StagedValue extends Animation<double>
    with AnimationWithParentMixin<double> {
  _StagedValue({
    required this.parent,
    required this.start,
    required this.appearSpan,
    required this.holdUntil,
  });

  @override
  final Animation<double> parent;
  final double start;
  final double appearSpan;
  final double holdUntil;

  @override
  double get value {
    final t = parent.value;
    final appearEnd = start + appearSpan;
    if (t < start) return 0.0;
    if (t < appearEnd) {
      final local = (t - start) / appearSpan;
      return OnboardingMotion.spring.transform(local);
    }
    if (t < holdUntil) return 1.0;
    // fade out in the last stretch
    const fadeSpan = 0.12;
    final fadeEnd = (holdUntil + fadeSpan).clamp(0.0, 1.0);
    if (t < fadeEnd) {
      final local = (t - holdUntil) / fadeSpan;
      return 1.0 - Curves.easeIn.transform(local);
    }
    return 0.0;
  }
}

/// Convenience widget: applies presence [value] as combined fade + scale.
class PresenceTransform extends StatelessWidget {
  const PresenceTransform({
    super.key,
    required this.value,
    required this.child,
    this.baseScale = 1.0,
    this.fromScale = 0.3,
    this.alignment = Alignment.center,
  });

  final double value;
  final Widget child;
  final double baseScale;
  final double fromScale;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final scale = fromScale + (baseScale - fromScale) * value;
    return Opacity(
      opacity: value.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
