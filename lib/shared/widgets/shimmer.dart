import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Usage:
//   Wrap your skeleton layout in <Shimmer> once.
//   Use <ShimmerBox> for every placeholder rectangle / circle.
//   All boxes share the same animation controller → perfectly in-sync shimmer.
// ─────────────────────────────────────────────────────────────────────────────

class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  /// Finds the nearest [Shimmer] ancestor. Returns null if not inside one.
  static _ShimmerState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ShimmerState>();

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Expose the listenable so [ShimmerBox] can rebuild on each tick.
  Listenable get shimmerChanges => _ctrl;

  /// Sweep gradient at the current animation value.
  LinearGradient buildGradient() {
    final t = _ctrl.value; // 0.0 → 1.0
    // The highlight band travels from left (-1.5) to right (+2.5)
    final dx = -1.5 + t * 4.0;
    return LinearGradient(
      begin: Alignment(dx, 0),
      end: Alignment(dx + 1.5, 0),
      colors: const [
        Color(0xFFEBEBF4), // base
        Color(0xFFF5F5FB), // highlight
        Color(0xFFEBEBF4), // base
      ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 6,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final shimmer = Shimmer.of(context);

    // Fallback to a plain grey box if no Shimmer ancestor is found
    if (shimmer == null) {
      return _plainBox();
    }

    return AnimatedBuilder(
      animation: shimmer.shimmerChanges,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: shimmer.buildGradient(),
          borderRadius:
              shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      ),
    );
  }

  Widget _plainBox() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBF4),
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      );
}
