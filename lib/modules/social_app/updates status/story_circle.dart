import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String imageUrl;
  final int segments;
  final double radius;
  final VoidCallback onTap;

  const StoryCircle({
    Key? key,
    required this.imageUrl,
    required this.segments,
    this.radius = 32,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CustomPaint(
          painter: _SegmentedCirclePainter(segments: segments, color: Colors.blue),
          child: Center(
            child: CircleAvatar(
              radius: radius - 6,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedCirclePainter extends CustomPainter {
  final int segments;
  final Color color;

  _SegmentedCirclePainter({required this.segments, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final double segmentAngle = 2 * 3.141592653589793 / segments;
    final double gap = 0.18; // gap between segments (radians)

    for (int i = 0; i < segments; i++) {
      double startAngle = i * segmentAngle + gap / 2;
      double sweepAngle = segmentAngle - gap;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 