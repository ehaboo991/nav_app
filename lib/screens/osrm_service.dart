import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum TravelMode { car, walk }

class WalkRoute {
  final List<LatLng> points;
  final double distanceMeters;
  final int minutes;

  const WalkRoute({
    required this.points,
    required this.distanceMeters,
    required this.minutes,
  });

  String get distanceText => distanceMeters >= 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(1)} كم'
      : '${distanceMeters.round()} م';
}

class OsrmService {
  static const Map<TravelMode, String> _base = {
    TravelMode.car: 'https://routing.openstreetmap.de/routed-car',
    TravelMode.walk: 'https://routing.openstreetmap.de/routed-foot',
  };

  /// كل المسارات المتاحة (الأول هو الأفضل، والباقي بدائل)
  static Future<List<WalkRoute>> routes(
    LatLng from,
    LatLng to,
    TravelMode mode,
  ) async {
    final url = '${_base[mode]}/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson&alternatives=true';
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return const [];

      final out = <WalkRoute>[];
      for (final r in (data['routes'] as List)) {
        final coords = (r['geometry']['coordinates'] as List)
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();
        if (coords.length < 2) continue;
        final dist = (r['distance'] as num).toDouble();
        final secs = (r['duration'] as num).toDouble();
        final mins = mode == TravelMode.walk
            ? (dist / 80).ceil() // ~80 متر بالدقيقة
            : (secs / 60).ceil();
        out.add(WalkRoute(
          points: coords,
          distanceMeters: dist,
          minutes: mins < 1 ? 1 : mins,
        ));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// للتوافق مع الكود القديم
  static Future<WalkRoute?> footRoute(LatLng from, LatLng to) async {
    final r = await routes(from, to, TravelMode.walk);
    return r.isEmpty ? null : r.first;
  }
}