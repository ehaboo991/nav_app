
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final MapController _mapController = MapController();

  // مركز تقريبي للجامعة، وليس موقع كلية محددة.
  static const LatLng _campusCenter =
      LatLng(31.09262, 35.71708);

  LatLng? _myLocation;
  bool _locating = false;
  String? _message;

  Future<void> _locateMe() async {
    if (_locating) return;

    setState(() {
      _locating = true;
      _message = null;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('فعّل خدمة الموقع GPS على جهازك.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('يجب السماح للتطبيق باستخدام الموقع.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'إذن الموقع مرفوض نهائيًا. فعّله من إعدادات التطبيق.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _myLocation = location;
      });

      _mapController.move(location, 18);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!)),
      );
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة جامعة مؤتة'),
        centerTitle: true,
        backgroundColor: const Color(0xFF03303B),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 16,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'nav_app',
              ),
              MarkerLayer(
                markers: [
                  const Marker(
                    point: _campusCenter,
                    width: 150,
                    height: 65,
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          color: Color(0xFF03303B),
                          size: 34,
                        ),
                        Text(
                          'جامعة مؤتة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 38,
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'locate_me',
              onPressed: _locating ? null : _locateMe,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF03303B),
              tooltip: 'تحديد موقعي',
              child: _locating
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.my_location),
            ),
          ),
          if (_message != null)
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_message!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
