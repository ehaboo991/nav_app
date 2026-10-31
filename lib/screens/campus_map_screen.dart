import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'college_data.dart';
import 'map_calibration.dart';
import 'osrm_service.dart';
import 'user_location.dart';

final List<Map<String, dynamic>> kMutahBuildings = <Map<String, dynamic>>[
  {'name': 'مكتبة الجامعة', 'point': const LatLng(31.093450, 35.717138), 'icon': Icons.local_library, 'color': Colors.indigo},
  {'name': 'كلية الأعمال', 'point': const LatLng(31.094403, 35.716600), 'icon': Icons.business_center, 'color': Colors.blue},
  {'name': 'كلية العلوم التربوية', 'point': const LatLng(31.094044, 35.718114), 'icon': Icons.school, 'color': Colors.teal},
  {'name': 'عمادة شؤون الطلبة', 'point': const LatLng(31.094029, 35.718945), 'icon': Icons.groups, 'color': Colors.purple},
  {'name': 'كلية العلوم 1', 'point': const LatLng(31.094596, 35.716964), 'icon': Icons.science, 'color': Colors.green},
  {'name': 'كلية العلوم 2', 'point': const LatLng(31.094865, 35.717738), 'icon': Icons.science_outlined, 'color': Colors.lightGreen},
  {'name': 'رئاسة الجامعة', 'point': const LatLng(31.095585, 35.717192), 'icon': Icons.account_balance, 'color': Colors.red},
  {'name': 'كلية الحقوق', 'point': const LatLng(31.095533, 35.719281), 'icon': Icons.gavel, 'color': Colors.brown},
  {'name': 'كلية الآداب', 'point': const LatLng(31.094840, 35.718444), 'icon': Icons.menu_book, 'color': Colors.amber},
  {'name': 'برج الساعة', 'point': const LatLng(31.096278, 35.717286), 'icon': Icons.access_time_filled, 'color': Colors.deepOrange},
  {'name': 'المالية', 'point': const LatLng(31.093342, 35.716109), 'icon': Icons.attach_money, 'color': Colors.lightGreen},
  {'name': 'مركز الحاسوب', 'point': const LatLng(31.093502, 35.715549), 'icon': Icons.computer, 'color': Colors.cyan},
  {'name': 'مختبرات الطب 1 & 2', 'point': const LatLng(31.092551, 35.715973), 'icon': Icons.biotech, 'color': Colors.redAccent},
  {'name': 'بنك القاهرة عمان', 'point': const LatLng(31.092451, 35.715279), 'icon': Icons.account_balance_wallet, 'color': Colors.blueGrey},
  {'name': 'كلية الصيدلة', 'point': const LatLng(31.091842, 35.717046), 'icon': Icons.medication, 'color': Colors.pink},
  {'name': 'مجمع الشهيد', 'point': const LatLng(31.091112, 35.717106), 'icon': Icons.domain, 'color': Colors.blueAccent},
  {'name': 'المركز الصحي', 'point': const LatLng(31.091015, 35.714448), 'icon': Icons.local_hospital, 'color': Colors.redAccent},
  {'name': 'كلية الطب', 'point': const LatLng(31.091723, 35.714779), 'icon': Icons.medical_services, 'color': Colors.deepOrangeAccent},
  {'name': 'كلية الرياضة', 'point': const LatLng(31.089274, 35.717876), 'icon': Icons.fitness_center, 'color': Colors.orange},
  {'name': 'المجمع الإداري', 'point': const LatLng(31.093622, 35.720001), 'icon': Icons.corporate_fare, 'color': Colors.blueGrey},
  {'name': 'كلية الهندسة', 'point': const LatLng(31.094331, 35.721555), 'icon': Icons.engineering, 'color': Colors.deepOrange},
  {'name': 'كلية تكنولوجيا المعلومات', 'point': const LatLng(31.094607, 35.722020), 'icon': Icons.developer_mode, 'color': Colors.teal},
  {'name': 'مجمع الكندي', 'point': const LatLng(31.094291, 35.722713), 'icon': Icons.location_city, 'color': Colors.indigo},
  {'name': 'المجمع القديم', 'point': const LatLng(31.095080, 35.716167), 'icon': Icons.other_houses, 'color': Colors.brown},
  {'name': 'ZINC', 'point': const LatLng(31.094681, 35.715960), 'icon': Icons.lightbulb, 'color': Colors.amberAccent},
  {'name': 'الصالة الهاشمية', 'point': const LatLng(31.093407, 35.718105), 'icon': Icons.stadium, 'color': Colors.purpleAccent},
  {'name': 'كلية طب الاسنان', 'point': const LatLng(31.093045444601803, 35.71896601399411), 'icon': Icons.health_and_safety_outlined, 'color': Colors.purpleAccent},
  {'name': 'دوار البوابة الشمالية', 'point': const LatLng(31.09725965458263, 35.71721395489304), 'icon': Icons.trip_origin, 'color': Colors.blueGrey},
  {'name': 'مسجد الحسين بن طلال (مسجد الجامعة )', 'point': const LatLng(31.097309498696667, 35.71638383995787), 'icon': Icons.mosque, 'color': Colors.teal},
  {'name': 'البوابة الجنوبية', 'point': const LatLng(31.091815521545527, 35.71409326768668), 'icon': Icons.sensor_door, 'color': Colors.teal},
  {'name': 'البوابة الشمالية', 'point': const LatLng(31.097603855083996, 35.717205984320266), 'icon': Icons.sensor_door, 'color': Colors.teal},
];

/// دور على مبنى بالخريطة الحقيقية من اسمه (تطابق تام أو أقرب تطابق جزئي)
Map<String, dynamic>? findMapBuildingByName(String name) {
  String norm(String v) => normalizeAr(v).replaceAll(RegExp(r'\s+'), '');
  final n = norm(name);
  if (n.isEmpty) return null;
  for (final b in kMutahBuildings) {
    if (norm(b['name'] as String) == n) return b;
  }
  Map<String, dynamic>? best;
  int bestLen = 0;
  for (final b in kMutahBuildings) {
    final bn = norm(b['name'] as String);
    if (bn.length >= 4 && (n.contains(bn) || bn.contains(n))) {
      if (bn.length > bestLen) {
        best = b;
        bestLen = bn.length;
      }
    }
  }
  return best;
}

/// نقطة البداية اللي حددها المستخدم بالضغط على الخريطة (إحداثيات جغرافية).
/// مشتركة مع شاشة "ابدأ الملاحة" وما بتحتاج معايرة.
final ValueNotifier<LatLng?> pickedStartNotifier = ValueNotifier<LatLng?>(null);

class CampusMapScreen extends StatefulWidget {
  /// إذا true: الشاشة مدمجة داخل الصفحة الرئيسية (بدون AppBar)
  final bool embedded;

  /// إذا true: الشاشة تُفتح فقط لتحديد "موقعك الحالي" (من شاشة ابدأ الملاحة).
  /// أول ضغطة على الخريطة أو على مبنى بتحفظ الموقع وبترجع تلقائياً.
  final bool pickMode;

  /// اسم وجهة نفتح الخريطة وإحنا بدنا مسار إلها مباشرة (من شاشة ابدأ الملاحة)
  final String? initialDestination;

  const CampusMapScreen({
    super.key,
    this.embedded = false,
    this.pickMode = false,
    this.initialDestination,
  });

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

/// none: الخريطة العادية | directions: شاشة الاتجاهات | route: عرض المسار
enum _Panel { none, directions, route }

class _CampusMapScreenState extends State<CampusMapScreen> {
  static const Color _brand = Color(0xFF0D5C58);
  static const Color _blue = Color(0xFF1A73E8);
  static const Color _directionsTeal = Color(0xFF0E7385);
  static const LatLng _campusCenter = LatLng(31.0935, 35.7180);
  static final LatLngBounds _campusBounds = LatLngBounds(
    const LatLng(31.086, 35.710),
    const LatLng(31.099, 35.726),
  );
  static const double _labelsMinZoom = 17;
  static const Distance _dist = Distance();

  LatLng? _currentPosition;

  /// الدبوس الأحمر لنتيجة البحث (الكلية اللي بحثت عنها)
  LatLng? _searchPin;
  bool _showLabels = false;
  double _rotation = 0;
  final MapController _mapController = MapController();

  // ───────── حالة الاتجاهات ─────────
  _Panel _panel = _Panel.none;
  bool _routeLoading = false;
  bool _navigating = false;

  /// وسيلة التنقل + كل المسارات (بدائل) لكل وسيلة + المسار المختار
  TravelMode _mode = TravelMode.walk;
  Map<TravelMode, List<WalkRoute>> _all = {};
  int _sel = 0;

  /// خلفية الأقمار الصناعية
  bool _satellite = false;

  /// الدبوس الأحمر لنقطة البداية المختارة (وضع تحديد الموقع)
  LatLng? _pickedPin;

  /// آخر حالة: هل الخريطة على موقعي؟ (لتحديث أيقونة زر الموقع)
  bool _wasCentered = false;

  List<WalkRoute> get _routes => _all[_mode] ?? const [];
  WalkRoute? get _route =>
      _routes.isEmpty ? null : _routes[_sel.clamp(0, _routes.length - 1)];

  /// البداية: null يعني "موقعك الجغرافي"
  LatLng? _startLatLng;
  String? _startName;

  /// الوجهة
  LatLng? _routeDest;
  String? _routeTo;

  /// الحقل اللي عم يتعدّل داخل شاشة الاتجاهات: 'start' | 'dest' | null
  String? _editing;

  /// الاختيار من الخريطة: 'start' | 'dest' | null
  String? _pickTarget;

  final TextEditingController _fieldCtrl = TextEditingController();
  String _fieldQuery = '';
  final List<String> _recent = [];

  StreamSubscription<Position>? _posSub;

  // البحث العلوي (الخريطة العادية)
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  List<Map<String, dynamic>> get _mutahBuildings => kMutahBuildings;

  // ───────── دورة الحياة ─────────

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
    userLocationNotifier.addListener(_onSharedLocationChanged);
    pickedStartNotifier.addListener(_onSharedLocationChanged);
    if (widget.pickMode) _pickedPin = pickedStartNotifier.value;
    _determinePosition();
    if (widget.initialDestination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openInitialDestination();
      });
    }
  }

  void _onSharedLocationChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    userLocationNotifier.removeListener(_onSharedLocationChanged);
    pickedStartNotifier.removeListener(_onSharedLocationChanged);
    _posSub?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _fieldCtrl.dispose();
    super.dispose();
  }

  /// موقعي الفعلي من الـ GPS (بيتحدث لحظياً). النقطة الزرقاء بتعتمد عليه فقط
  LatLng? get _myLatLng => _currentPosition;

  /// الموقع اليدوي المشترك مع شاشة الملاحة (احتياطي بس لنقطة البداية)
  LatLng? get _manualLatLng {
    final shared = userLocationNotifier.value;
    return shared == null ? null : MapCalibration.imageToGeo(shared);
  }

  LatLng? get _effectiveStart =>
      _startLatLng ??
      pickedStartNotifier.value ??
      _currentPosition ??
      _manualLatLng;

  /// اسم نقطة البداية للعرض
  String get _startLabel =>
      _startName ??
      (_startLatLng == null && pickedStartNotifier.value != null
          ? 'الموقع الذي حددته'
          : 'موقعك الجغرافي');

  /// تتبع الموقع الفعلي بشكل مستمر (بيشتغل طول ما الشاشة مفتوحة)
  void _ensureLiveTracking() {
    if (_posSub != null) return;
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen(_onGpsPosition, onError: (_) {});
  }

  Map<String, dynamic>? _buildingByName(String name) {
    for (final b in _mutahBuildings) {
      if (b['name'] == name) return b;
    }
    return null;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(msg),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _brand,
      ),
    );
  }

  // ───────── GPS ─────────

  Future<void> _determinePosition({bool userInitiated = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (userInitiated) _toast('خدمة الموقع (GPS) مغلقة');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (userInitiated) _toast('لم يتم السماح بالوصول للموقع');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (userInitiated) _toast('فعّل إذن الموقع من إعدادات الجهاز');
      return;
    }

    // نبدأ نتابع موقعك الفعلي: النقطة الزرقاء بتتحرك معك
    _ensureLiveTracking();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition!, 16.5);

      final img = MapCalibration.geoToImage(_currentPosition!);
      if (img != null &&
          img.dx >= 0 &&
          img.dx <= 1 &&
          img.dy >= 0 &&
          img.dy <= 1 &&
          (userInitiated || userLocationNotifier.value == null)) {
        userLocationNotifier.value = img;
      }
    } catch (_) {
      if (userInitiated) _toast('تعذر تحديد موقعك حالياً');
    }
  }

  // ───────── منطق الاتجاهات ─────────

  /// فتح الخريطة مع مسار جاهز للوجهة المطلوبة
  Future<void> _openInitialDestination() async {
    final b = findMapBuildingByName(widget.initialDestination!);
    if (b == null) {
      _toast('ما لقينا هالمكان على الخريطة');
      return;
    }
    if (_effectiveStart == null) await _determinePosition();
    if (!mounted) return;
    _routeToBuilding(b);
  }

  /// زر الاتجاهات الأخضر: يفتح شاشة الاتجاهات
  void _openDirectionsScreen() {
    FocusScope.of(context).unfocus();
    _stopNavigation();
    setState(() {
      _searchPin = null;
      _panel = _Panel.directions;
      _editing = null;
      _all = {};
      _sel = 0;
      _fieldCtrl.clear();
      _fieldQuery = '';
    });
  }

  /// من كارت المبنى: مباشرة لمسار (البداية = موقعي)
  void _routeToBuilding(Map<String, dynamic> b, {bool startNav = false}) {
    _stopNavigation();
    _addRecent(b['name'] as String);
    setState(() {
      _searchPin = null;
      _routeTo = b['name'] as String;
      _routeDest = b['point'] as LatLng;
      _startLatLng = null;
      _startName = null;
      _editing = null;
    });
    if (_effectiveStart == null) {
      _toast('ما قدرنا نحدد موقعك، اختر نقطة البداية');
      setState(() {
        _panel = _Panel.directions;
        _editing = 'start';
      });
      return;
    }
    _computeRoute(beginNav: startNav);
  }

  void _addRecent(String name) {
    _recent.remove(name);
    _recent.insert(0, name);
    if (_recent.length > 6) _recent.removeLast();
  }

  /// اختيار بداية/وجهة (من القائمة أو الخريطة)
  void _choose(String target, LatLng? p, String? name) {
    setState(() {
      if (target == 'start') {
        _startLatLng = p;
        _startName = name;
      } else {
        _routeDest = p;
        _routeTo = name;
        if (name != null && _buildingByName(name) != null) _addRecent(name);
      }
      _editing = null;
      _pickTarget = null;
      _fieldCtrl.clear();
      _fieldQuery = '';
    });
    FocusScope.of(context).unfocus();
    _afterChoice();
  }

  void _afterChoice() {
    if (_routeDest == null) {
      setState(() => _panel = _Panel.directions);
      return;
    }
    if (_effectiveStart == null) {
      _toast('حدد نقطة البداية');
      setState(() {
        _panel = _Panel.directions;
        _editing = 'start';
      });
      return;
    }
    _computeRoute();
  }

  Future<void> _computeRoute({bool beginNav = false}) async {
    final dest = _routeDest;
    final from = _effectiveStart;
    if (dest == null || from == null) return;
    if (_routeLoading) return;

    setState(() {
      _panel = _Panel.route;
      _routeLoading = true;
      _all = {};
      _sel = 0;
    });

    // نجيب مسارات السيارة والمشي مع بعض (عشان أوقات التبويبات)
    final res = await Future.wait([
      OsrmService.routes(from, dest, TravelMode.car),
      OsrmService.routes(from, dest, TravelMode.walk),
    ]);
    if (!mounted) return;

    final car = res[0];
    final walk = res[1];

    if (car.isEmpty && walk.isEmpty) {
      setState(() {
        _routeLoading = false;
        _panel = _Panel.directions;
      });
      _toast('تعذر جلب المسار، تأكد من الإنترنت وحاول مرة ثانية');
      return;
    }

    setState(() {
      _all = {TravelMode.car: car, TravelMode.walk: walk};
      _routeLoading = false;
      // إذا الوضع الحالي ما إله مسار نبدّل للثاني
      if (_routes.isEmpty) {
        _mode = car.isNotEmpty ? TravelMode.car : TravelMode.walk;
      }
    });

    _fitRoute();

    if (beginNav) _beginNavigation();
  }

  /// نضبط الكاميرا لتشمل كل مسارات الوضع الحالي
  void _fitRoute() {
    final from = _effectiveStart;
    final dest = _routeDest;
    if (from == null || dest == null || _routes.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          for (final r in _routes) ...r.points,
          from,
          dest,
        ]),
        padding: const EdgeInsets.fromLTRB(40, 170, 40, 320),
        maxZoom: 18,
      ),
    );
  }

  /// تبديل وسيلة التنقل (سيارة / مشي)
  void _setMode(TravelMode m) {
    if (_navigating || m == _mode) return;
    if ((_all[m] ?? const []).isEmpty) {
      _toast('ما في مسار متاح لهذا الوضع');
      return;
    }
    setState(() {
      _mode = m;
      _sel = 0;
    });
    _fitRoute();
  }

  /// مكان فقاعة الوقت على كل مسار (بنوزعها عشان ما تتراكب)
  LatLng _bubblePoint(WalkRoute r, int i) {
    final n = r.points.length;
    final shift = i == 0 ? 0.0 : (i.isOdd ? -0.18 : 0.18) * ((i + 1) ~/ 2);
    final f = (0.5 + shift).clamp(0.1, 0.9);
    return r.points[((n - 1) * f).round()];
  }

  /// تبديل البداية والوجهة
  void _swapEndpoints() {
    final s = _effectiveStart;
    final d = _routeDest;
    if (s == null || d == null) {
      _toast('حدد البداية والوجهة أولاً');
      return;
    }
    final sName = _startLabel;
    final dName = _routeTo;
    setState(() {
      _startLatLng = d;
      _startName = dName;
      _routeDest = s;
      _routeTo = sName;
    });
    _stopNavigation();
    _computeRoute();
  }

  // ───────── الملاحة المباشرة ─────────

  void _beginNavigation() {
    if (_route == null) return;
    if (_myLatLng == null) {
      _toast('الملاحة المباشرة تحتاج موقعك: فعّل الـ GPS');
      return;
    }
    setState(() => _navigating = true);
    final p = _currentPosition;
    if (p != null) _mapController.move(p, 18);
  }

  /// كل تحديث GPS: بنحرّك النقطة الزرقاء، وإذا في ملاحة بنتبعك بالكاميرا
  void _onGpsPosition(Position pos) {
    if (!mounted) return;
    final p = LatLng(pos.latitude, pos.longitude);
    setState(() => _currentPosition = p);
    if (!_navigating) return;
    final z = _mapController.camera.zoom;
    _mapController.move(p, z < 17.5 ? 18 : z);

    final dest = _routeDest;
    if (dest != null && _dist(p, dest) < 25) {
      _toast('وصلت إلى $_routeTo 🎉');
      _closeAll();
    }
  }

  void _stopNavigation() {
    if (_navigating && mounted) setState(() => _navigating = false);
    _navigating = false;
  }

  /// إغلاق كل شي والرجوع للخريطة العادية
  void _closeAll() {
    _stopNavigation();
    setState(() {
      _panel = _Panel.none;
      _all = {};
      _sel = 0;
      _routeTo = null;
      _routeDest = null;
      _startLatLng = null;
      _startName = null;
      _routeLoading = false;
      _editing = null;
      _pickTarget = null;
    });
  }

  /// وضع تحديد الموقع: الضغطة بتحط دبوس أحمر (وبتقدر تغيّره بضغطة ثانية)
  void _pickMyLocation(LatLng p) {
    setState(() => _pickedPin = p);
  }

  /// تأكيد النقطة: نحفظها كنقطة بداية ونرجع
  void _confirmPick() {
    final p = _pickedPin;
    if (p == null) return;
    pickedStartNotifier.value = p;
    // إذا المعايرة جاهزة نشاركها كمان مع شاشة صورة الكامبس
    final img = MapCalibration.geoToImage(p);
    if (img != null &&
        img.dx >= 0 &&
        img.dx <= 1 &&
        img.dy >= 0 &&
        img.dy <= 1) {
      userLocationNotifier.value = img;
    }
    Navigator.pop(context);
  }

  Widget _buildConfirmPick() {
    return Positioned(
      right: 14,
      bottom: 24,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _brand,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          icon: const Icon(Icons.check_rounded),
          label: const Text('تأكيد نقطة البداية',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onPressed: _confirmPick,
        ),
      ),
    );
  }

  double _remainingMeters() {
    final route = _route;
    if (route == null) return 0;
    final pts = route.points;
    final p = _currentPosition ?? _myLatLng ?? pts.first;
    int best = 0;
    double bestD = double.infinity;
    for (int i = 0; i < pts.length; i++) {
      final d = _dist(p, pts[i]);
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    double total = bestD;
    for (int i = best; i < pts.length - 1; i++) {
      total += _dist(pts[i], pts[i + 1]);
    }
    if (_routeDest != null) total += _dist(pts.last, _routeDest!);
    return total;
  }

  String _fmtMeters(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} كم' : '${m.round()} م';

  String _arrival(int minutes) {
    final t = DateTime.now().add(Duration(minutes: minutes));
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'م' : 'ص'}';
  }

  // ───────── واجهة: شاشة الاتجاهات (مثل الفيديو) ─────────

  Widget _fieldBox({
    required String text,
    required bool hint,
    required VoidCallback onTap,
    bool chevron = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hint ? FontWeight.w400 : FontWeight.w700,
                  color: hint ? Colors.black54 : Colors.black87,
                ),
              ),
            ),
            if (chevron)
              const Icon(Icons.chevron_left_rounded, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  /// تبويبات الوسيلة في شاشة الاتجاهات (سيارة / مشي شغالين)
  Widget _modeTabs() {
    Widget tab(IconData icon, {TravelMode? m}) {
      final selected = m != null && m == _mode;
      return Expanded(
        child: GestureDetector(
          onTap: m == null
              ? () => _toast('غير متاح داخل الحرم الجامعي')
              : () => setState(() => _mode = m),
          child: Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFB7E3E0) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? _brand : Colors.black45,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          tab(Icons.directions_car_rounded, m: TravelMode.car),
          tab(Icons.directions_bus_rounded),
          tab(Icons.directions_walk_rounded, m: TravelMode.walk),
          tab(Icons.flight_rounded),
        ],
      ),
    );
  }

  /// تبويبات الوسيلة في الورقة السفلية (مع الوقت لكل وسيلة)
  Widget _sheetTabs() {
    Widget tab(IconData icon, TravelMode? m) {
      final selected = m != null && m == _mode;
      final list = m == null ? const <WalkRoute>[] : (_all[m] ?? const []);
      final mins = list.isEmpty ? null : list.first.minutes;
      return Expanded(
        child: GestureDetector(
          onTap: m == null
              ? () => _toast('غير متاح داخل الحرم الجامعي')
              : () => _setMode(m),
          child: Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFB7E3E0) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 20, color: selected ? _brand : Colors.black45),
                if (mins != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$mins د',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? _brand : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab(Icons.directions_car_rounded, TravelMode.car),
        tab(Icons.directions_bus_rounded, null),
        tab(Icons.directions_walk_rounded, TravelMode.walk),
        tab(Icons.flight_rounded, null),
      ],
    );
  }

  Widget _placeTile(Map<String, dynamic> b, String target) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade200,
        child: Icon(b['icon'] as IconData, color: b['color'] as Color, size: 20),
      ),
      title: Text(
        b['name'] as String,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
      ),
      subtitle: const Text('جامعة مؤتة', style: TextStyle(fontSize: 12)),
      onTap: () => _choose(target, b['point'] as LatLng, b['name'] as String),
    );
  }

  Widget _buildDirectionsScreen() {
    final editing = _editing;

    Widget header;
    if (editing == null) {
      header = Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: _closeAll,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.my_location_rounded, size: 16, color: _blue),
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      shape: BoxShape.circle,
                    ),
                  ),
                const Icon(Icons.location_on_rounded, size: 20, color: Colors.red),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  _fieldBox(
                    text: _startLabel,
                    hint: false,
                    onTap: () => setState(() => _editing = 'start'),
                  ),
                  const SizedBox(height: 8),
                  _fieldBox(
                    text: _routeTo ?? 'اختيار الوجهة',
                    hint: _routeTo == null,
                    chevron: _routeTo == null,
                    onTap: () => setState(() => _editing = 'dest'),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_vert_rounded),
              onPressed: _swapEndpoints,
            ),
          ],
        ),
      );
    } else {
      header = Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () => setState(() {
                _editing = null;
                _fieldCtrl.clear();
                _fieldQuery = '';
              }),
            ),
            Expanded(
              child: TextField(
                controller: _fieldCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _fieldQuery = v),
                decoration: InputDecoration(
                  hintText: editing == 'start'
                      ? 'اختيار نقطة البداية'
                      : 'اختيار الوجهة',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget body;
    if (editing != null) {
      final nq = normalizeAr(_fieldQuery);
      final list = _mutahBuildings
          .where((b) =>
              nq.isEmpty || normalizeAr(b['name'] as String).contains(nq))
          .toList();
      body = ListView(
        padding: EdgeInsets.zero,
        children: [
          if (editing == 'start')
            ListTile(
              leading: const Icon(Icons.navigation_rounded, color: _blue),
              title: const Text('موقعك الجغرافي',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                pickedStartNotifier.value = null;
                if (_myLatLng == null) {
                  _determinePosition(userInitiated: true);
                }
                _choose('start', null, null);
              },
            ),
          ListTile(
            leading: const Icon(Icons.place_outlined, color: Colors.black54),
            title: const Text('اختيار مكان على الخريطة',
                style: TextStyle(fontWeight: FontWeight.w700)),
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _pickTarget = editing;
                _editing = null;
              });
            },
          ),
          const Divider(height: 1),
          for (final b in list) _placeTile(b, editing),
        ],
      );
    } else {
      final recents = _recent
          .map(_buildingByName)
          .whereType<Map<String, dynamic>>()
          .toList();
      final list = recents.isNotEmpty ? recents : _mutahBuildings;

      Widget chip(String name, IconData icon) {
        final b = _buildingByName(name);
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: b == null
                ? null
                : () => _choose('dest', b['point'] as LatLng, name),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFFB7E3E0),
                    child: Icon(icon, size: 18, color: _brand),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      body = ListView(
        padding: EdgeInsets.zero,
        children: [
          _modeTabs(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                chip('البوابة الجنوبية', Icons.sensor_door),
                chip('البوابة الشمالية', Icons.sensor_door_outlined),
                chip('مكتبة الجامعة', Icons.local_library),
              ],
            ),
          ),
          Container(height: 8, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              recents.isNotEmpty ? 'الأحدث' : 'أماكن في الجامعة',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          for (final b in list) _placeTile(b, 'dest'),
        ],
      );
    }

    return Positioned.fill(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                header,
                if (editing != null) const Divider(height: 1),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── واجهة: عرض المسار (كارت علوي + ورقة سفلية) ─────────

  Widget _buildRouteTopCard() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Material(
              elevation: 6,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _navigating
                    ? null
                    : () => setState(() {
                          _panel = _Panel.directions;
                          _editing = null;
                        }),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 12, color: _blue),
                          Container(
                              width: 2,
                              height: 14,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              color: Colors.grey.shade400),
                          const Icon(Icons.location_on_rounded,
                              size: 18, color: Colors.red),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _startLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _blue, fontWeight: FontWeight.w700),
                            ),
                            Divider(height: 14, color: Colors.grey.shade300),
                            Text(
                              _routeTo ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_vert_rounded),
                        onPressed: _navigating ? null : _swapEndpoints,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSheet() {
    final route = _route;
    final remaining = _navigating && route != null ? _remainingMeters() : null;
    final speed = _mode == TravelMode.walk ? 80 : 400; // متر بالدقيقة
    final minutes =
        remaining != null ? (remaining / speed).ceil() : (route?.minutes ?? 0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -2)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _mode == TravelMode.walk ? 'المشي' : 'القيادة',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _closeAll,
                  ),
                ],
              ),
              if (!_routeLoading && route != null) ...[
                _sheetTabs(),
                const SizedBox(height: 6),
              ],
              if (_routeLoading || route == null) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(color: _brand),
                const SizedBox(height: 10),
                const Text('جاري حساب المسار...'),
              ] else ...[
                Text(
                  '$minutes د',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF188038),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining != null
                      ? 'باقي ${_fmtMeters(remaining)} • وصول ${_arrival(minutes)}'
                      : 'وقت الوصول: ${_arrival(minutes)} • ${route.distanceText}',
                  style: const TextStyle(color: Colors.black87, fontSize: 13.5),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!_navigating)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _brand,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.navigation_rounded, size: 20),
                        label: const Text('ابدأ',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        onPressed: _beginNavigation,
                      )
                    else
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.stop_rounded, size: 20),
                        label: const Text('إنهاء'),
                        onPressed: _closeAll,
                      ),
                    if (!_navigating)
                      ActionChip(
                        avatar: const Icon(Icons.edit_location_alt_outlined,
                            size: 18, color: _brand),
                        label: const Text('تعديل البداية'),
                        backgroundColor: const Color(0xFFE3F3F1),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        onPressed: () => setState(() {
                          _panel = _Panel.directions;
                          _editing = 'start';
                        }),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 6,
      left: 20,
      right: 20,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.black87,
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.pickMode
                        ? 'اضغط على الخريطة لتحديد نقطة البداية'
                        : _pickTarget == 'start'
                            ? 'اضغط على الخريطة لتحديد البداية'
                            : 'اضغط على الخريطة لتحديد الوجهة',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.pickMode
                      ? Navigator.pop(context)
                      : setState(() => _pickTarget = null),
                  child: const Text('إلغاء',
                      style: TextStyle(color: Colors.amber)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── أزرار الخريطة (موقعي + الاتجاهات) مثل Google Maps ─────────

  /// هل منتصف الخريطة على موقعي الحالي؟ (بيحدد شكل الأيقونة)
  bool _isCenteredOnMe() {
    final me = _myLatLng;
    if (me == null) return false;
    try {
      return _dist(_mapController.camera.center, me) < 30;
    } catch (_) {
      return false;
    }
  }

  /// نقطة زرقاء بهالة فاتحة (لما الخريطة على موقعي)
  Widget _locationDotIcon() {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFDCE8FB),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 13,
        height: 13,
        decoration: const BoxDecoration(
          color: Color(0xFF1A5FE0),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _onMyLocationTap() {
    // نرجع الشمال لفوق ونروح لموقعي
    _mapController.rotate(0);
    final me = _myLatLng;
    if (me != null) {
      final z = _mapController.camera.zoom;
      _mapController.move(me, z < 17 ? 17 : z);
      setState(() => _wasCentered = true);
    } else {
      _determinePosition(userInitiated: true);
    }
  }

  Widget _buildMapButtons() {
    // لما ورقة المسار مفتوحة نرفع الأزرار فوقها
    final double bottom = _panel == _Panel.route ? 285 : 24;
    final bool centered = _isCenteredOnMe();
    final bool showDirectionsBtn = _panel == _Panel.none && !widget.pickMode;

    return Positioned(
      left: 14,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر موقعي: نقطة زرقاء (على موقعي) / بوصلة (بعيد عن موقعي)
          _SquircleButton(
            tooltip: 'موقعي',
            background: Colors.white,
            pressedBackground: const Color(0xFFA8DADC),
            onTap: _onMyLocationTap,
            child: centered
                ? _locationDotIcon()
                : const Icon(Icons.explore_outlined,
                    size: 28, color: Color(0xFF202124)),
          ),
          if (showDirectionsBtn) ...[
            const SizedBox(height: 12),
            // زر الاتجاهات التركوازي
            _SquircleButton(
              tooltip: 'الاتجاهات',
              background: _directionsTeal,
              pressedBackground: const Color(0xFF0A5563),
              onTap: _openDirectionsScreen,
              child: const Icon(Icons.directions_rounded,
                  size: 30, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  /// زر نوع الخريطة (أقمار صناعية) أعلى اليمين مثل Google Maps
  Widget _buildLayersButton() {
    final top = MediaQuery.of(context).padding.top +
        (_panel == _Panel.route ? 100 : 76);
    return Positioned(
      top: top,
      right: 14,
      child: _SquircleButton(
        size: 46,
        radius: 14,
        tooltip: 'نوع الخريطة',
        background: const Color(0xFFDCEFF0),
        pressedBackground: const Color(0xFFA8DADC),
        onTap: () => setState(() => _satellite = !_satellite),
        child: Icon(
          _satellite ? Icons.map_rounded : Icons.layers_rounded,
          size: 24,
          color: _brand,
        ),
      ),
    );
  }

  // ───────── بطاقة المبنى ─────────

  void _showBuildingSheet(Map<String, dynamic> building) {
    final String name = building['name'] as String;
    final IconData icon = building['icon'] as IconData;
    final Color color = building['color'] as Color;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brand,
                        side: const BorderSide(color: _brand, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('الاتجاهات'),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _routeToBuilding(building);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _brand,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('ابدأ'),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _routeToBuilding(building, startNav: true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _buildingMarker(Map<String, dynamic> building) {
    final String name = building['name'] as String;
    final IconData icon = building['icon'] as IconData;
    final Color color = building['color'] as Color;

    return Marker(
      point: building['point'] as LatLng,
      width: _showLabels ? 100.0 : 40.0,
      height: _showLabels ? 70.0 : 40.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.pickMode) {
            _pickMyLocation(building['point'] as LatLng);
            return;
          }
          if (_pickTarget != null) {
            _choose(_pickTarget!, building['point'] as LatLng, name);
            return;
          }
          _showBuildingSheet(building);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: color, size: 24.0),
            ),
            if (_showLabels) ...[
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(235),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ───────── البحث العلوي ─────────

  void _selectBuilding(Map<String, dynamic> building) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() {
      _query = '';
      _searchPin = building['point'] as LatLng; // الدبوس عند الكلية
    });
    // نروح للكلية ونزيح الكاميرا شوي لتحت عشان الدبوس يضل ظاهر فوق الكرت
    final p = building['point'] as LatLng;
    _mapController.move(LatLng(p.latitude - 0.0005, p.longitude), 17.5);
    // كرت (الاتجاهات / ابدأ) بعد ما يرسم الدبوس
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showBuildingSheet(building);
    });
  }

  Widget _buildSearchOverlay() {
    final q = normalizeAr(_query);
    final results = <Map<String, dynamic>>[
      if (q.isNotEmpty)
        for (final b in _mutahBuildings)
          if (normalizeAr(b['name'] as String).contains(q)) b,
    ].take(6).toList();

    final showResults = _searchFocus.hasFocus && q.isNotEmpty;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 4,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.black87),
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (_) {
                      if (results.isNotEmpty) _selectBuilding(results.first);
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن كلية أو مبنى...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: _brand),
                      suffixIcon: _query.isEmpty
                          ? IconButton(
                              tooltip: 'الاتجاهات',
                              icon: const Icon(Icons.directions_rounded,
                                  color: _brand),
                              onPressed: _openDirectionsScreen,
                            )
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                  _searchPin = null; // شيل الدبوس
                                });
                              },
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (showResults)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: results.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('ما لقينا مبنى بهذا الاسم',
                                style: TextStyle(color: Colors.black54)),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final b in results)
                                  ListTile(
                                    dense: true,
                                    leading: Icon(b['icon'] as IconData,
                                        color: b['color'] as Color),
                                    title: Text(
                                      b['name'] as String,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () => _selectBuilding(b),
                                  ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── البناء ─────────

  @override
  Widget build(BuildContext context) {
    final me = _myLatLng;
    final start = _effectiveStart;
    // الدبوس بيظهر فقط لما يكون في اتجاهات/نقطة بداية محددة
    final bool pinVisible = _panel != _Panel.none;
    final bool showDirectionsScreen =
        _panel == _Panel.directions && _pickTarget == null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // بوضع تحديد الموقع ما في AppBar: الرسالة بتطلع بأعلى الشاشة
      appBar: (widget.embedded || widget.pickMode)
          ? null
          : AppBar(
              title: const Text('خريطة جامعة مؤتة'),
              backgroundColor: _brand,
            ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _campusCenter,
              initialZoom: 16.5,
              minZoom: 15,
              maxZoom: 19,
              cameraConstraint: CameraConstraint.contain(bounds: _campusBounds),
              onTap: (tapPosition, point) {
                if (widget.pickMode) {
                  _pickMyLocation(point);
                  return;
                }
                if (_pickTarget != null) {
                  _choose(_pickTarget!, point, 'نقطة على الخريطة');
                  return;
                }
                FocusScope.of(context).unfocus();
              },
              // ضغطة طويلة = اجعلها نقطة البداية (وأنت بعرض المسار)
              onLongPress: (tapPosition, point) {
                if (_panel == _Panel.route && !_navigating) {
                  _choose('start', point, 'نقطة على الخريطة');
                }
              },
              onPositionChanged: (camera, hasGesture) {
                final double? z = camera.zoom;
                if (z == null) return;
                final show = z >= _labelsMinZoom;
                final rotChanged = (camera.rotation - _rotation).abs() > 0.5;
                final me = _myLatLng;
                final centered = me != null && _dist(camera.center, me) < 30;
                if (show != _showLabels ||
                    rotChanged ||
                    centered != _wasCentered) {
                  setState(() {
                    _showLabels = show;
                    _rotation = camera.rotation;
                    _wasCentered = centered;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _satellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nav_app',
              ),
              if (_route != null && _panel == _Panel.route)
                PolylineLayer(
                  polylines: [
                    if (start != null)
                      Polyline(
                        points: [start, _route!.points.first],
                        strokeWidth: 3,
                        color: Colors.blueGrey,
                      ),
                    if (_routeDest != null)
                      Polyline(
                        points: [_route!.points.last, _routeDest!],
                        strokeWidth: 3,
                        color: Colors.blueGrey,
                      ),
                    // البدائل (أزرق فاتح)
                    for (int i = 0; i < _routes.length; i++)
                      if (i != _sel)
                        Polyline(
                          points: _routes[i].points,
                          strokeWidth: 6,
                          color: const Color(0xFF8AB4F8),
                          borderStrokeWidth: 2,
                          borderColor: Colors.white,
                        ),
                    // المسار المختار (أزرق غامق) فوق الكل
                    Polyline(
                      points: _route!.points,
                      strokeWidth: 7,
                      color: const Color(0xFF1A47D6),
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              // فقاعات الوقت على كل مسار (الضغط عليها يختار المسار)
              if (_panel == _Panel.route && !_navigating && _routes.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (int i = 0; i < _routes.length; i++)
                      Marker(
                        point: _bubblePoint(_routes[i], i),
                        width: 64,
                        height: 34,
                        child: GestureDetector(
                          onTap: () => setState(() => _sel = i),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == _sel
                                  ? const Color(0xFF1A47D6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              '${_routes[i].minutes} د',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color:
                                    i == _sel ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // النقطة الزرقاء = موقعي الفعلي من الـ GPS (دائماً)
                  if (me != null)
                    Marker(
                      point: me,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                  // نقطة بداية مختارة (غير موقعي): دائرة بيضاء بحلقة زرقاء
                  if (pinVisible && _startLatLng != null)
                    Marker(
                      point: _startLatLng!,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _blue, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                  ..._mutahBuildings.map(_buildingMarker),
                  // الدبوس الأحمر لنقطة البداية في وضع تحديد الموقع
                  if (widget.pickMode && _pickedPin != null)
                    Marker(
                      point: _pickedPin!,
                      width: 60.0,
                      height: 60.0,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 52.0),
                    ),
                  // الدبوس الأحمر عند الكلية اللي بحثت عنها
                  if (_panel == _Panel.none && _searchPin != null)
                    Marker(
                      point: _searchPin!,
                      width: 60.0,
                      height: 60.0,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 52.0),
                    ),
                ],
              ),
            ],
          ),
          if (_panel == _Panel.none && !widget.pickMode) _buildSearchOverlay(),
          if (_panel == _Panel.route) _buildRouteTopCard(),
          if (_panel == _Panel.route) _buildRouteSheet(),
          if (!showDirectionsScreen && !widget.pickMode) _buildLayersButton(),
          if (!showDirectionsScreen) _buildMapButtons(),
          if (widget.pickMode && _pickedPin != null) _buildConfirmPick(),
          if (_pickTarget != null || widget.pickMode) _buildPickBanner(),
          if (showDirectionsScreen) _buildDirectionsScreen(),
        ],
      ),
    );
  }
}

/// زر مربع بزوايا مدوّرة (squircle) بنفس شكل أزرار Google Maps،
/// بيتلوّن بلون الضغط وقت اللمس.
class _SquircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color background;
  final Color pressedBackground;
  final double size;
  final double radius;
  final String? tooltip;

  const _SquircleButton({
    required this.child,
    required this.onTap,
    required this.background,
    required this.pressedBackground,
    this.size = 56,
    this.radius = 18,
    this.tooltip,
  });

  @override
  State<_SquircleButton> createState() => _SquircleButtonState();
}

class _SquircleButtonState extends State<_SquircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed ? widget.pressedBackground : widget.background,
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: widget.child,
      ),
    );
    return widget.tooltip == null
        ? btn
        : Tooltip(message: widget.tooltip!, child: btn);
  }
}