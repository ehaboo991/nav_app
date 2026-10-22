import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'app_logo.dart'; // for Pin

// تدرج خفيف
const LinearGradient _softMapGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x4D96FFDF), // aquaFoam ~30%
    Color(0x331F6B7A), // cyberTealLight ~20%
  ],
);

class _RouteGeometry {
  final Path path;
  final Offset start;
  final Offset end;

  _RouteGeometry._(this.path, this.start, this.end);

  factory _RouteGeometry(Size size) {
    final w = size.width;
    final h = size.height;

    final y1 = h * 0.92;
    final y4 = h * 0.34;
    final gap = (y1 - y4) / 3;
    final y2 = y1 - gap;
    final y3 = y1 - gap * 2;
    final r = gap / 2;

    final xl = w * 0.20;
    final xr = w * 0.80;
    final xl2 = w * 0.34;
    final xe = w * 0.40;

    final path = Path()
      ..moveTo(xl + 10, y1)
      ..lineTo(xr - r, y1)
      ..arcToPoint(Offset(xr - r, y2),
          radius: Radius.circular(r), clockwise: false)
      ..lineTo(xl2 + r, y2)
      ..arcToPoint(Offset(xl2 + r, y3),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(xr - r, y3)
      ..arcToPoint(Offset(xr - r, y4),
          radius: Radius.circular(r), clockwise: false)
      ..lineTo(xe + 10, y4);

    return _RouteGeometry._(path, Offset(xl, y1), Offset(xe, y4));
  }
}

class RouteMap extends StatelessWidget {
  final Animation<double> progress;
  const RouteMap({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final startPin = CurveTween(
      curve: const Interval(0.0, 0.2, curve: Curves.easeOutBack),
    ).animate(progress);

    final line = CurveTween(
      curve: const Interval(0.2, 0.85, curve: Curves.easeInOut),
    ).animate(progress);

    final endPin = CurveTween(
      curve: const Interval(0.85, 1.0, curve: Curves.easeOutBack),
    ).animate(progress);

    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0.0, 0.25, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: LayoutBuilder(
        builder: (context, c) {
          final geo = _RouteGeometry(Size(c.maxWidth, c.maxHeight));
          const bigPin = 56.0;
          const smallPin = 38.0;

          return Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _softMapGradient),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedRoutePainter(geo.path, line),
                ),
              ),
              Positioned(
                left: geo.start.dx - bigPin / 2,
                top: geo.start.dy - bigPin * 0.92,
                child: ScaleTransition(
                  scale: startPin,
                  alignment: Alignment.bottomCenter,
                  child: const Pin(size: bigPin),
                ),
              ),
              Positioned(
                left: geo.end.dx - smallPin / 2,
                top: geo.end.dy - smallPin * 0.92,
                child: ScaleTransition(
                  scale: endPin,
                  alignment: Alignment.bottomCenter,
                  child: const Pin(size: smallPin),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashedRoutePainter extends CustomPainter {
  final Path path;
  final Animation<double> progress;

  _DashedRoutePainter(this.path, this.progress) : super(repaint: progress);

  static const double _dash = 14;
  static const double _gap = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyberTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      final drawn = metric.length * progress.value;
      double d = 0;
      while (d < drawn) {
        final end = (d + _dash).clamp(0.0, drawn).toDouble();
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoutePainter old) =>
      old.path != path || old.progress != progress;
}