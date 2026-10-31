import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:latlong2/latlong.dart';

/// نقطة معايرة: مكان معروف بالخريطة الصورة (MUU.jpeg) + إحداثياته الحقيقية
class CalibrationPoint {
  /// الإحداثيات الحقيقية (نفس القيم المستخدمة بـ _mutahBuildings)
  final LatLng geo;

  /// مكانه على الصورة كنسبة 0..1 من العرض والارتفاع (dx, dy)
  final Offset img;

  const CalibrationPoint({required this.geo, required this.img});
}

/// ═══════════════════════════════════════════════════════════
///  طريقة تعبئة النقاط (مرة وحدة):
///  1) شغّل التطبيق بوضع debug وافتح خريطة الصورة (MapViewerScreen).
///  2) اضغط أيقونة المعايرة (tune) بالأعلى: بتفتح شاشة المعايرة.
///  3) اختر مبنى من القائمة واضغط على مركزه بالصورة (5-6 مباني موزعين
///     على أطراف الكامبس، مش على خط واحد).
///  4) اضغط "نسخ الكود" والصقه هون مكان القائمة تحت.
///  (المعايرة بتشتغل فوراً بنفس الجلسة حتى قبل ما تلصق الكود)
/// ═══════════════════════════════════════════════════════════
const List<CalibrationPoint> kCalibrationPoints = [
  // مثال:
  // CalibrationPoint(geo: LatLng(31.094607, 35.722020), img: Offset(0.439, 0.405)),
];

/// تحويل بين إحداثيات GPS (LatLng) وإحداثيات صورة الخريطة (Offset 0..1)
/// بتحويل خطي (affine) بطريقة المربعات الصغرى، فبيتحمّل أي دوران أو انعكاس
/// أو اختلاف اتجاه الشمال بالصورة.
class MapCalibration {
  MapCalibration._();

  static _Fit? _cached;
  static bool _computed = false;

  /// نقاط مؤقتة من شاشة المعايرة (بتتغلب على kCalibrationPoints بنفس الجلسة)
  static List<CalibrationPoint>? _override;

  /// النقاط المستخدمة حالياً
  static List<CalibrationPoint> get points => _override ?? kCalibrationPoints;

  /// تعيين نقاط مؤقتة (null يرجّع لـ kCalibrationPoints)
  static void setPoints(List<CalibrationPoint>? pts) {
    _override = pts;
    _computed = false;
    _cached = null;
  }

  static _Fit? get _model {
    if (!_computed) {
      _cached = _fitPoints(points);
      _computed = true;
      if (kDebugMode) {
        if (_cached == null) {
          debugPrint('MapCalibration: غير جاهزة (لازم 3 نقاط غير على خط واحد)');
        } else {
          debugPrint('MapCalibration: جاهزة، متوسط الخطأ '
              '${rmsErrorMeters.toStringAsFixed(1)} متر');
        }
      }
    }
    return _cached;
  }

  /// هل المعايرة جاهزة؟
  static bool get isReady => _model != null;

  /// GPS → مكان على الصورة. null إذا المعايرة مش جاهزة.
  static Offset? geoToImage(LatLng p) {
    final m = _model;
    if (m == null) return null;
    final x = (p.longitude - m.lng0) * m.kx;
    final y = (p.latitude - m.lat0) * m.ky;
    return Offset(m.ax * x + m.bx * y + m.cx, m.ay * x + m.by * y + m.cy);
  }

  /// مكان على الصورة → GPS. null إذا المعايرة مش جاهزة.
  static LatLng? imageToGeo(Offset o) {
    final m = _model;
    if (m == null) return null;
    final det = m.ax * m.by - m.bx * m.ay;
    if (det.abs() < 1e-12) return null;
    final u = o.dx - m.cx;
    final v = o.dy - m.cy;
    final x = (m.by * u - m.bx * v) / det;
    final y = (m.ax * v - m.ay * u) / det;
    return LatLng(m.lat0 + y / m.ky, m.lng0 + x / m.kx);
  }

  /// خطأ كل نقطة بالأمتار (بنفس ترتيب [points]). فاضية إذا مش جاهزة.
  static List<double> get pointErrorsMeters {
    if (!isReady) return const [];
    const dist = Distance();
    final out = <double>[];
    for (final p in points) {
      final back = imageToGeo(p.img);
      out.add(back == null ? double.nan : dist.as(LengthUnit.Meter, p.geo, back));
    }
    return out;
  }

  /// متوسط خطأ المعايرة بالأمتار (للتأكد إنك سجلت النقاط صح).
  /// أقل من ~15 متر ممتاز. إذا كبير فيه نقطة مسجّلة غلط.
  /// ملاحظة: مع 3 نقاط بس الخطأ دايماً ~0، سجّل 5 أو أكثر عشان يكون مفيد.
  static double get rmsErrorMeters {
    final errs = pointErrorsMeters;
    if (errs.isEmpty || errs.any((e) => e.isNaN)) return double.nan;
    double sum = 0;
    for (final d in errs) {
      sum += d * d;
    }
    return math.sqrt(sum / errs.length);
  }
}

class _Fit {
  final double lat0, lng0, kx, ky;
  final double ax, bx, cx; // img.dx = ax*x + bx*y + cx
  final double ay, by, cy; // img.dy = ay*x + by*y + cy
  const _Fit({
    required this.lat0,
    required this.lng0,
    required this.kx,
    required this.ky,
    required this.ax,
    required this.bx,
    required this.cx,
    required this.ay,
    required this.by,
    required this.cy,
  });
}

_Fit? _fitPoints(List<CalibrationPoint> pts) {
  if (pts.length < 3) return null;

  // نحوّل لأمتار محلية حوالين مركز النقاط (أدق وأثبت رقمياً)
  final lat0 =
      pts.map((p) => p.geo.latitude).reduce((a, b) => a + b) / pts.length;
  final lng0 =
      pts.map((p) => p.geo.longitude).reduce((a, b) => a + b) / pts.length;
  const ky = 110540.0; // متر لكل درجة عرض
  final kx = 111320.0 * math.cos(lat0 * math.pi / 180); // متر لكل درجة طول

  double sxx = 0, sxy = 0, sx = 0, syy = 0, sy = 0;
  double sxu = 0, syu = 0, su = 0, sxv = 0, syv = 0, sv = 0;
  for (final p in pts) {
    final x = (p.geo.longitude - lng0) * kx;
    final y = (p.geo.latitude - lat0) * ky;
    sxx += x * x;
    sxy += x * y;
    sx += x;
    syy += y * y;
    sy += y;
    sxu += x * p.img.dx;
    syu += y * p.img.dx;
    su += p.img.dx;
    sxv += x * p.img.dy;
    syv += y * p.img.dy;
    sv += p.img.dy;
  }
  final n = pts.length.toDouble();

  final m = [sxx, sxy, sx, sxy, syy, sy, sx, sy, n];
  final u = _solve3(m, [sxu, syu, su]);
  final v = _solve3(m, [sxv, syv, sv]);
  if (u == null || v == null) return null;

  return _Fit(
    lat0: lat0,
    lng0: lng0,
    kx: kx,
    ky: ky,
    ax: u[0],
    bx: u[1],
    cx: u[2],
    ay: v[0],
    by: v[1],
    cy: v[2],
  );
}

double _det3(List<double> m) =>
    m[0] * (m[4] * m[8] - m[5] * m[7]) -
    m[1] * (m[3] * m[8] - m[5] * m[6]) +
    m[2] * (m[3] * m[7] - m[4] * m[6]);

/// حل نظام 3×3 بطريقة كرامر. بيرجّع null إذا النقاط على خط واحد تقريباً
List<double>? _solve3(List<double> m, List<double> r) {
  final d = _det3(m);
  final scale = (m[0] * m[4] * m[8]).abs();
  if (scale == 0 || d.abs() < 1e-9 * scale) return null;

  List<double> withCol(int c) {
    final t = List<double>.from(m);
    for (var row = 0; row < 3; row++) {
      t[row * 3 + c] = r[row];
    }
    return t;
  }

  return [
    _det3(withCol(0)) / d,
    _det3(withCol(1)) / d,
    _det3(withCol(2)) / d,
  ];
}