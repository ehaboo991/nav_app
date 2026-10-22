import 'package:flutter/material.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

class MapViewerScreen extends StatefulWidget {
  const MapViewerScreen({super.key});

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState();
}

class _MapViewerScreenState extends State<MapViewerScreen> {
  final TransformationController _controller = TransformationController();
  Offset _doubleTapPos = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text('خريطة جامعة مؤتة'),
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
      body: GestureDetector(
        onDoubleTapDown: (d) => _doubleTapPos = d.localPosition,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1.0,
          maxScale: 6.0,
          child: Center(
            child: Hero(
              tag: 'Mutah_Map',
              child: Image.asset(
                'image/Mutah_Map.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text(
                    'تعذّر تحميل الخريطة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}