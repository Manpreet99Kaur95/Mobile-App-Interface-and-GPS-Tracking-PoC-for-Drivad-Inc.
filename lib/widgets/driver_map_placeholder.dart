import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;

class DriverMapPlaceholder extends StatefulWidget {
  final String statusLabel;

  const DriverMapPlaceholder({super.key, this.statusLabel = "Active Zone"});

  @override
  State<DriverMapPlaceholder> createState() => _DriverMapPlaceholderState();
}

class _DriverMapPlaceholderState extends State<DriverMapPlaceholder> {
  MapboxMap? mapboxMap;
  geo.Position? userPosition;
  String locationText = "Getting GPS location...";
  bool isLoading = true;

  // Default fallback to Calgary
  final double defaultLat = 51.0447;
  final double defaultLng = -114.0719;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationText = "GPS disabled - Using default location";
          isLoading = false;
        });
        return;
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          setState(() {
            locationText = "Location permission denied";
            isLoading = false;
          });
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          locationText = "Location permission denied forever";
          isLoading = false;
        });
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        userPosition = position;
        locationText =
            "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        isLoading = false;
      });

      if (mapboxMap != null) {
        _updateCameraToUserLocation();
      }
    } catch (e) {
      setState(() {
        locationText = "GPS error - Using default location";
        isLoading = false;
      });
      debugPrint('Location error: $e');
    }
  }

  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    // Enable gestures through MapboxMap.gestures
    await map.gestures.updateSettings(
      GesturesSettings(
        rotateEnabled: false,
        pitchEnabled: false,
        scrollEnabled: true,
        pinchToZoomEnabled: true,
        doubleTapToZoomInEnabled: true,
        quickZoomEnabled: true,
      ),
    );

    // Enable user location puck on map
    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    if (userPosition != null) {
      _updateCameraToUserLocation();
    } else {
      await Future.delayed(const Duration(seconds: 12));
      if (userPosition == null) {
        _showDefaultLocation();
      }
    }
  }

  Future<void> _updateCameraToUserLocation() async {
    if (mapboxMap == null || userPosition == null) return;

    final userPos = Position(userPosition!.longitude, userPosition!.latitude);

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: userPos),
        zoom: 16.0,
        pitch: 0.0,
        bearing: 0.0,
      ),
      MapAnimationOptions(duration: 1000),
    );

    // Wait longer for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));
    await _addZoneCircle(userPos);
  }

  Future<void> _showDefaultLocation() async {
    if (mapboxMap == null) return;

    final defaultPos = Position(defaultLng, defaultLat);

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: defaultPos),
        zoom: 10.0,
        pitch: 0.0,
        bearing: 0.0,
      ),
      MapAnimationOptions(duration: 1000),
    );

    // Wait longer for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));
    await _addZoneCircle(defaultPos);
  }

  Future<void> _addZoneCircle(Position center) async {
    try {
      // Try to remove existing circle first
      try {
        await mapboxMap!.annotations.removeAnnotationManagerById("zone-circle");
      } catch (e) {
        // Ignore if doesn't exist
      }

      // MUCH SMALLER RADIUS - 0.0002 (~20m)
      final points = _createCircle(center, 0.0001);

      final manager = await mapboxMap!.annotations
          .createPolygonAnnotationManager(id: "zone-circle");

      await manager.create(
        PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [points]),
          fillColor: const Color(0xFF1D4ED8).withValues(alpha: 0.15).toARGB32(),
          fillOutlineColor: const Color(0xFF1D4ED8).toARGB32(),
        ),
      );

      debugPrint(
        'Circle created with radius: 0.0002 at ${center.lat}, ${center.lng}',
      );
    } catch (e) {
      debugPrint('Zone circle error: $e');
    }
  }

  List<Position> _createCircle(Position center, double radius) {
    final List<Position> coords = [];
    for (int i = 0; i <= 360; i += 10) {
      final double angle = i * (math.pi / 180);
      coords.add(
        Position(
          center.lng +
              (radius * math.sin(angle) / math.cos(center.lat * math.pi / 180)),
          center.lat + (radius * math.cos(angle)),
        ),
      );
    }
    return coords;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: MapboxStyles.SATELLITE,
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        locationText,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.statusLabel,
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
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
