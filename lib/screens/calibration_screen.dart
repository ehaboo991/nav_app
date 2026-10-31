import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'map_calibration.dart';

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);

class _Landmark {
  final String name;
  final LatLng geo;
  const _Landmark(this.name, this.geo);
}

/// نفس إحداثيات _mutahBuildings في campus_map_screen.dart
const List<_Landmark> _landmarks = [
  _Landmark('مكتبة الجامعة', LatLng(31.093450, 35.717138)),
  _Landmark('كلية الأعمال', LatLng(31.094403, 35.716600)),
  _Landmark('كلية العلوم التربوية', LatLng(31.094044, 35.718114)),
  _Landmark('عمادة شؤون الطلبة', LatLng(31.094029, 35.718945)),
  _Landmark('كلية العلوم 1', LatLng(31.094596, 35.716964)),
  _Landmark('كلية العلوم 2', LatLng(31.094865, 35.717738)),
  _Landmark('رئاسة الجامعة', LatLng(31.095585, 35.717192)),
  _Landmark('كلية الحقوق', LatLng(31.095533, 35.719281)),
  _Landmark('كلية الآداب', LatLng(31.094840, 35.718444)),
  _Landmark('برج الساعة', LatLng(31.096278, 35.717286)),
  _Landmark('المالية', LatLng(31.093342, 35.716109)),
  _Landmark('مركز الحاسوب', LatLng(31.093502, 35.715549)),
  _Landmark('مختبرات الطب 1 & 2', LatLng(31.092551, 35.715973)),
  _Landmark('بنك القاهرة عمان', LatLng(31.092451, 35.715279)),
  _Landmark('كلية الصيدلة', LatLng(31.091842, 35.717046)),
  _Landmark('مجمع الشهيد', LatLng(31.091112, 35.717106)),
  _Landmark('المركز الصحي', LatLng(31.091015, 35.714448)),
  _Landmark('كلية الطب', LatLng(31.091723, 35.714779)),
  _Landmark('كلية الرياضة', LatLng(31.089274, 35.717876)),
  _Landmark('المجمع الإداري', LatLng(31.093622, 35.720001)),
  _Landmark('كلية الهندسة', LatLng(31.094331, 35.721555)),
  _Landmark('كلية تكنولوجيا المعلومات', LatLng(31.094607, 35.722020)),
  _Landmark('مجمع الكندي', LatLng(31.094291, 35.722713)),
  _Landmark('المجمع القديم', LatLng(31.095080, 35.716167)),
  _Landmark('ZINC', LatLng(31.094681, 35.715960)),
  _Landmark('الصالة الهاشمية', LatLng(31.093407, 35.718105)),
  _Landmark('كلية طب الاسنان', LatLng(31.093045444601803, 35.71896601399411)),
  _Landmark('دوار البوابة الشمالية', LatLng(31.09725965458263, 35.71721395489304)),
  _Landmark('مسجد الجامعة', LatLng(31.097309498696667, 35.71638383995787)),
  _Landmark('البوابة الجنوبية', LatLng(31.091815521545527, 35.71409326768668)),
  _Landmark('البوابة الشمالية', LatLng(31.097603855083996, 35.717205984320266)),
];

/// شاشة معايرة (للتطوير): اختر مبنى من القائمة واضغط على مركزه بصورة الكامبس.
/// بعد 3 نقاط على الأقل بتشتغل المعايرة فوراً، وبتقدر تنسخ الكود وتلصقه
/// بـ kCalibrationPoints عشان يضل دائماً.
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final TransformationController _controller = TransformationController();

  /// فهرس المبنى -> مكانه على الصورة (0..1)
  final Map<int, Offset> _placed = {};
  int _current = 0;

  /// خطأ كل نقطة (بنفس ترتيب _placed)
  List<double> _errors = const [];

  @override
  void initState() {
    super.initState();
    // نحمّل النقاط الموجودة مسبقاً (إذا في)
    for (final p in MapCalibration.points) {
      final i = _landmarks.indexWhere((l) =>
          (l.geo.latitude - p.geo.latitude).abs() < 1e-7 &&
          (l.geo.longitude - p.geo.longitude).abs() < 1e-7);
      if (i >= 0) _placed[i] = p.img;
    }
    _errors = MapCalibration.pointErrorsMeters;
    _current = _nextUnplaced(-1) ?? 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _nextUnplaced(int after) {
    for (var i = after + 1; i < _landmarks.length; i++) {
      if (!_placed.containsKey(i)) return i;
    }
    return null;
  }

  void _apply() {
    final pts = [
      for (final e in _placed.entries)
        CalibrationPoint(geo: _landmarks[e.key].geo, img: e.value),
    ];
    MapCalibration.setPoints(pts);
    _errors = MapCalibration.pointErrorsMeters;
  }

  void _onTap(Offset local, Size box) {
    final img = Offset(
      (local.dx / box.width).clamp(0.0, 1.0).toDouble(),
      (local.dy / box.height).clamp(0.0, 1.0).toDouble(),
    );
    HapticFeedback.selectionClick();
    setState(() {
      _placed[_current] = img;
      _apply();
      final next = _nextUnplaced(_current);
      if (next != null) _current = next;
    });
  }

  String _code() {
    final b = StringBuffer('const List<CalibrationPoint> kCalibrationPoints = [\n');
    for (final e in _placed.entries) {
      final l = _landmarks[e.key];
      b.writeln(
        '  CalibrationPoint(geo: LatLng(${l.geo.latitude}, ${l.geo.longitude}), '
        'img: Offset(${e.value.dx.toStringAsFixed(4)}, '
        '${e.value.dy.toStringAsFixed(4)})), // ${l.name}',
      );
    }
    b.write('];');
    return b.toString();
  }

  Future<void> _copy() async {
    if (_placed.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _code()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text('تم نسخ الكود، الصقه بـ kCalibrationPoints'),
        ),
      ));
  }

  void _clearAll() {
    setState(() {
      _placed.clear();
      MapCalibration.setPoints(const []);
      _errors = const [];
      _current = 0;
    });
  }

  void _removeCurrent() {
    if (!_placed.containsKey(_current)) return;
    setState(() {
      _placed.remove(_current);
      _apply();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = MapCalibration.isReady;
    final rms = MapCalibration.rmsErrorMeters;

    // أسوأ نقطة (غالباً هي اللي انحطت بمكان غلط)
    String worst = '';
    if (ready && _placed.length >= 4 && _errors.length == _placed.length) {
      var wi = 0;
      for (var i = 1; i < _errors.length; i++) {
        if (_errors[i] > _errors[wi]) wi = i;
      }
      final key = _placed.keys.elementAt(wi);
      worst = 'أكبر خطأ: ${_landmarks[key].name} '
          '(${_errors[wi].toStringAsFixed(0)} م)';
    }

    final String status = _placed.length < 3
        ? 'سجّل ${3 - _placed.length} نقاط على الأقل'
        : !ready
            ? 'النقاط على خط واحد تقريباً، وزّعها أكثر'
            : _placed.length < 5
                ? 'جاهزة. سجّل 5 نقاط أو أكثر لدقة أفضل'
                : 'جاهزة • متوسط الخطأ ${rms.toStringAsFixed(1)} م';

    final keys = _placed.keys.toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: _cyberTeal,
          foregroundColor: _aquaFoam,
          title: const Text('معايرة الخريطة'),
        ),
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 8.0,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1058 / 1322,
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final size = Size(box.maxWidth, box.maxHeight);
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('image/MUU.jpeg', fit: BoxFit.fill),
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTapUp: (d) => _onTap(d.localPosition, size),
                              ),
                            ),
                            for (var n = 0; n < keys.length; n++)
                              Positioned(
                                left: _placed[keys[n]]!.dx * size.width - 10,
                                top: _placed[keys[n]]!.dy * size.height - 10,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: keys[n] == _current
                                          ? Colors.amber
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: Text(
                                      '${n + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: _cyberTeal,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر المبنى ثم اضغط على مركزه بالصورة',
                      style: TextStyle(
                          color: _aquaFoam.withAlpha(200), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int>(
                        value: _current,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (var i = 0; i < _landmarks.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                '${_placed.containsKey(i) ? '✓ ' : ''}'
                                '${_landmarks[i].name}',
                              ),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _current = v);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_placed.length} نقطة • $status',
                      style: const TextStyle(
                        color: _aquaFoam,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (worst.isNotEmpty)
                      Text(worst,
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _aquaFoam,
                              foregroundColor: _cyberTeal,
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('نسخ الكود'),
                            onPressed: _placed.isEmpty ? null : _copy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'حذف نقطة المبنى المختار',
                          color: _aquaFoam,
                          icon: const Icon(Icons.undo_rounded),
                          onPressed:
                              _placed.containsKey(_current) ? _removeCurrent : null,
                        ),
                        IconButton(
                          tooltip: 'مسح الكل',
                          color: _aquaFoam,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: _placed.isEmpty ? null : _clearAll,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}