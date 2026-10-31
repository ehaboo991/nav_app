import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calibration_screen.dart';
import 'campus_map_screen.dart' show pickedStartNotifier;
import 'map_calibration.dart';
import 'user_location.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

/// لون نقطة "موقعك" على الخريطة
const Color _youBlue = Color(0xFF1A73E8);

class MapViewerScreen extends StatefulWidget {
  final String? destination;
  final int? buildingNumber;

  /// إذا true: بعد ما المستخدم يحدد موقعه الشاشة بترجع تلقائياً
  /// (بنستخدمها لما نفتح الخريطة من شاشة "ابدأ الملاحة")
  final bool popOnPick;

  const MapViewerScreen({
    super.key,
    this.destination,
    this.buildingNumber,
    this.popOnPick = false,
  });

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState();
}

class _MapViewerScreenState extends State<MapViewerScreen>
    with TickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _routeProgress;

  /// نبض نقطة موقعك (بيشتغل بس لما يكون في موقع محدد)
  late final AnimationController _pulse;
  Offset _doubleTapPos = Offset.zero;

  bool get _hasRoute =>
      _MapRoutePainter.routePoints.containsKey(widget.buildingNumber);

  @override
  void initState() {
    super.initState();
    _routeProgress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.destination != null && _hasRoute) {
      _routeProgress.forward();
    }

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    pickLocationMode.addListener(_onLocationStateChanged);
    userLocationNotifier.addListener(_onLocationStateChanged);
    _syncPickedStart();
    _syncPulse();
  }

  @override
  void dispose() {
    pickLocationMode.removeListener(_onLocationStateChanged);
    userLocationNotifier.removeListener(_onLocationStateChanged);
    _controller.dispose();
    _routeProgress.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// إذا حددت نقطة بداية على الخريطة الحقيقية (إحداثيات) ولسا ما إلها
  /// مكان على الصورة: نحوّلها للصورة إذا المعايرة جاهزة
  void _syncPickedStart() {
    if (userLocationNotifier.value != null) return;
    final picked = pickedStartNotifier.value;
    if (picked == null) return;
    final img = MapCalibration.geoToImage(picked);
    if (img != null &&
        img.dx >= 0 &&
        img.dx <= 1 &&
        img.dy >= 0 &&
        img.dy <= 1) {
      userLocationNotifier.value = img;
    }
  }

  void _onLocationStateChanged() {
    if (!mounted) return;
    _syncPulse();
    setState(() {});
  }

  void _syncPulse() {
    if (userLocationNotifier.value != null) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  /// تثبيت موقعك على النقطة [p] (نسبة من عرض/ارتفاع الخريطة من 0 لـ 1)
  void _setLocation(Offset p) {
    userLocationNotifier.value = Offset(
      p.dx.clamp(0.0, 1.0).toDouble(),
      p.dy.clamp(0.0, 1.0).toDouble(),
    );
    pickLocationMode.value = false;
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _aquaFoam,
          content: const Text(
            'تم تحديد موقعك على الخريطة',
            style: TextStyle(color: _cyberTeal, fontWeight: FontWeight.w700),
          ),
        ),
      );

    // لما نفتح الخريطة من شاشة "ابدأ الملاحة" نرجع لها مباشرة
    if (widget.popOnPick && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// يفتح شاشة المعايرة (وقت التطوير بس) وبعد ما ترجع بنعيد مزامنة النقطة
  Future<void> _openCalibration() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalibrationScreen()),
    );
    if (!mounted) return;
    _syncPickedStart();
    setState(() {});
  }

  double get _currentScale => _controller.value.getMaxScaleOnAxis();

  // تكبير/تصغير حول مركز الشاشة (للأزرار)
  void _zoomBy(double factor) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    final newScale = (_currentScale * factor).clamp(1.0, 6.0);
    final ratio = newScale / _currentScale;

    final m = _controller.value.clone();
    m.translate(center.dx, center.dy);
    m.scale(ratio);
    m.translate(-center.dx, -center.dy);
    _controller.value = m;
  }

  void _resetZoom() => _controller.value = Matrix4.identity();

  void _replayRoute() {
    _routeProgress
      ..reset()
      ..forward();
  }

  // ضغطتين: يكبّر على مكان الضغط، وإذا مكبّر يرجع
  void _handleDoubleTap() {
    if (_currentScale > 1.1) {
      _resetZoom();
    } else {
      const scale = 2.5;
      final p = _doubleTapPos;
      _controller.value = Matrix4.identity()
        ..translate(-p.dx * (scale - 1), -p.dy * (scale - 1))
        ..scale(scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final picking = pickLocationMode.value;
    final myLocation = userLocationNotifier.value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _cyberTeal,
        foregroundColor: _aquaFoam,
        title: Text(
          widget.destination == null
              ? 'خريطة جامعة مؤتة'
              : 'الملاحة إلى ${widget.destination}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // معايرة الخريطة (بوضع debug بس)
          if (kDebugMode)
            IconButton(
              tooltip: 'معايرة الخريطة',
              icon: const Icon(Icons.tune_rounded),
              onPressed: _openCalibration,
            ),
          // تفعيل/إلغاء وضع "حدد موقعك"
          IconButton(
            tooltip: picking ? 'إلغاء تحديد الموقع' : 'حدد موقعك',
            icon: Icon(
              picking ? Icons.location_searching : Icons.my_location_rounded,
              color: picking ? Colors.white : _aquaFoam,
            ),
            onPressed: () => pickLocationMode.value = !picking,
          ),
          // إزالة موقعك (بتظهر بس إذا في موقع محدد)
          if (myLocation != null)
            IconButton(
              tooltip: 'إزالة موقعي',
              icon: const Icon(Icons.location_off_rounded),
              onPressed: () => userLocationNotifier.value = null,
            ),
          IconButton(
            tooltip: 'تصغير',
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _zoomBy(1 / 1.5),
          ),
          IconButton(
            tooltip: 'تكبير',
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _zoomBy(1.5),
          ),
          IconButton(
            tooltip: 'إعادة الحجم',
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _resetZoom,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
            // بوضع تحديد الموقع منعطّل التكبير بالضغطتين عشان ما يتعارض
            onDoubleTap: picking ? null : _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 6.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1058 / 1322,
                  child: LayoutBuilder(
                    builder: (context, box) => Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'Mutah_Map',
                          child: Image.asset(
                            'image/MUU.jpeg',
                            fit: BoxFit.fill,
                            errorBuilder: (_, _, _) => const Center(
                              child: Text(
                                'تعذّر تحميل الخريطة',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        if (_hasRoute && widget.destination != null)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _routeProgress,
                              builder: (context, _) => CustomPaint(
                                painter: _MapRoutePainter(
                                  buildingNumber: widget.buildingNumber!,
                                  progress: _routeProgress.value,
                                ),
                              ),
                            ),
                          ),

                        // نقطة موقعك (زرقاء نابضة)
                        if (myLocation != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, _) => CustomPaint(
                                  painter: _UserLocationPainter(
                                    location: myLocation,
                                    pulse: _pulse.value,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // طبقة اللمس لتحديد الموقع:
                        // • بوضع التحديد: ضغطة وحدة على أي مكان
                        // • برا وضع التحديد: ضغطة مطوّلة على أي مكان
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTapUp: picking
                                ? (d) => _setLocation(Offset(
                                      d.localPosition.dx / box.maxWidth,
                                      d.localPosition.dy / box.maxHeight,
                                    ))
                                : null,
                            onLongPressStart: (d) => _setLocation(Offset(
                              d.localPosition.dx / box.maxWidth,
                              d.localPosition.dy / box.maxHeight,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // شريط التعليمات بوضع "حدد موقعك"
          if (picking)
            Positioned(
              top: (_hasRoute && widget.destination != null) ? 62 : 14,
              left: 14,
              right: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _cyberTeal.withAlpha(240),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _aquaFoam.withAlpha(110)),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_rounded,
                          color: _aquaFoam, size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'اضغط على أي مكان بالخريطة لتحديد موقعك',
                          style: TextStyle(
                            color: _aquaFoam,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'إلغاء',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded,
                            color: _aquaFoam, size: 20),
                        onPressed: () => pickLocationMode.value = false,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_hasRoute && widget.destination != null)
            Positioned(
              top: 14,
              left: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _cyberTeal.withAlpha(235),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _aquaFoam.withAlpha(100)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_walk,
                          color: _aquaFoam, size: 18),
                      SizedBox(width: 7),
                      Text(
                        'مسار مشي توضيحي',
                        style: TextStyle(
                          color: _aquaFoam,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.destination != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cyberTeal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _aquaFoam.withAlpha(80)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: _aquaFoam,
                        child: Icon(Icons.directions_walk, color: _cyberTeal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _hasRoute ? 'مسار المشي إلى' : 'الوجهة',
                              style: TextStyle(
                                color: _aquaFoam.withAlpha(190),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.destination!,
                              style: const TextStyle(
                                color: _aquaFoam,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _hasRoute
                                  ? 'من البوابة الشمالية • معاينة بدون GPS'
                                  : 'موقع المبنى غير محدد على الخريطة',
                              style: TextStyle(
                                color: _aquaFoam.withAlpha(180),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'إعادة عرض المسار',
                        onPressed: _hasRoute ? _replayRoute : null,
                        icon: Icon(
                          Icons.replay_rounded,
                          color: _hasRoute
                              ? _aquaFoam
                              : _aquaFoam.withAlpha(90),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// نقطة "موقعك": دائرة زرقاء بحلقة بيضاء + موجة بتكبر وبتتلاشى
class _UserLocationPainter extends CustomPainter {
  final Offset location; // نسبة 0..1 من حجم الخريطة
  final double pulse; // 0..1

  const _UserLocationPainter({required this.location, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      location.dx * size.width,
      location.dy * size.height,
    );
    final r = size.width * .016;

    // الموجة النابضة
    canvas.drawCircle(
      center,
      r * (1.6 + pulse * 2.8),
      Paint()..color = _youBlue.withAlpha(((1 - pulse) * 95).round()),
    );

    // ظل خفيف
    canvas.drawCircle(
      center.translate(0, r * .25),
      r * 1.6,
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // الحلقة البيضاء + النقطة الزرقاء
    canvas.drawCircle(center, r * 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(center, r * 1.15, Paint()..color = _youBlue);
  }

  @override
  bool shouldRepaint(covariant _UserLocationPainter oldDelegate) =>
      oldDelegate.location != location || oldDelegate.pulse != pulse;
}

class _MapRoutePainter extends CustomPainter {
  final int buildingNumber;
  final double progress;

  const _MapRoutePainter({
    required this.buildingNumber,
    required this.progress,
  });

  static const Map<int, List<Offset>> routePoints = {
    8: [
      Offset(.577, .922),
      Offset(.577, .865),
      Offset(.548, .833),
      Offset(.507, .797),
      Offset(.456, .766),
      Offset(.393, .756),
      Offset(.345, .719),
      Offset(.306, .668),
      Offset(.282, .619),
      Offset(.278, .590),
    ],
    11: [
      Offset(.577, .922),
      Offset(.577, .866),
      Offset(.545, .833),
      Offset(.501, .797),
      Offset(.475, .748),
      Offset(.464, .692),
      Offset(.464, .635),
      Offset(.464, .578),
      Offset(.457, .529),
      Offset(.443, .482),
      Offset(.439, .405),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final points = routePoints[buildingNumber];
    if (points == null || points.length < 2) return;

    final route = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final point in points.skip(1)) {
      route.lineTo(point.dx * size.width, point.dy * size.height);
    }

    final metric = route.computeMetrics().first;
    final end = metric.length * progress.clamp(0, 1);
    final visibleRoute = metric.extractPath(0, end);
    final routeWidth = size.width * .009;

    canvas.drawPath(
      route,
      Paint()
        ..color = _cyberTeal.withAlpha(115)
        ..style = PaintingStyle.stroke
        ..strokeWidth = routeWidth * 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.white.withAlpha(225)
        ..style = PaintingStyle.stroke
        ..strokeWidth = routeWidth * 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      visibleRoute,
      Paint()
        ..color = const Color(0xFF087EAE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = routeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final traveler = metric.getTangentForOffset(end)?.position;
    if (traveler != null) {
      final markerRadius = size.width * .018;
      canvas.drawCircle(
        traveler,
        markerRadius * 1.75,
        Paint()..color = const Color(0x44087EAE),
      );
      canvas.drawCircle(
        traveler,
        markerRadius,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        traveler,
        markerRadius * .65,
        Paint()..color = const Color(0xFF087EAE),
      );
    }

    final destination = points.last;
    final destinationCenter = Offset(
      destination.dx * size.width,
      destination.dy * size.height,
    );
    final pinRadius = size.width * .018;
    canvas.drawCircle(
      destinationCenter,
      pinRadius * 1.6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      destinationCenter,
      pinRadius * 1.15,
      Paint()..color = const Color(0xFF8A1538),
    );
    canvas.drawCircle(
      destinationCenter,
      pinRadius * .38,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MapRoutePainter oldDelegate) =>
      oldDelegate.buildingNumber != buildingNumber ||
      oldDelegate.progress != progress;
}