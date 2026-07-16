import 'package:flutter/material.dart';

/// Draws lines from a set of outer points toward a center, revealed
/// progressively (stroke "grows" from center outward) via [progress] 0..1.
///
/// Used by the "Start a group" hero (solid teal lines) — pass [dashed] true
/// with a coral color for the "Settle up" debt arrows.
class ConnectorPainter extends CustomPainter {
  ConnectorPainter({
    required this.center,
    required this.points,
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
    this.dashed = false,
  });

  /// Center as fractional offset (0..1) of the canvas.
  final Offset center;

  /// Outer endpoints as fractional offsets (0..1) of the canvas.
  final List<Offset> points;

  /// 0..1 reveal for each line, staggered internally.
  final double progress;

  final Color color;
  final double strokeWidth;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length; i++) {
      // Stagger each line by a fraction of the total progress.
      final stagger = i / (points.length * 2);
      final local = ((progress - stagger) / (1 - stagger)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final end = Offset(points[i].dx * size.width, points[i].dy * size.height);
      final drawnEnd = Offset.lerp(c, end, local)!;

      if (dashed) {
        _drawDashedLine(canvas, c, drawnEnd, paint);
      } else {
        canvas.drawLine(c, drawnEnd, paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final total = (b - a).distance;
    final dir = (b - a) / (total == 0 ? 1 : total);
    var dist = 0.0;
    while (dist < total) {
      final start = a + dir * dist;
      final segEnd = dist + dash < total ? dist + dash : total;
      final end = a + dir * segEnd;
      canvas.drawLine(start, end, paint);
      dist += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.points != points ||
      old.center != center;
}
