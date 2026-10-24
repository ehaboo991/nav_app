import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

class MapViewerScreen extends StatefulWidget {
  final String? destination;
  final int? buildingNumber;

  const MapViewerScreen({
    super.key,
    this.destination,
    this.buildingNumber,
  });

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState();
}

class _MapViewerScreenState extends State<MapViewerScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _routeProgress;
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _routeProgress.dispose();
    super.dispose();
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
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 6.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1058 / 1322,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'Mutah_Map',
                        child: Image.asset(
                          'image/Mutah_Map.png',
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
                    ],
                  ),
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