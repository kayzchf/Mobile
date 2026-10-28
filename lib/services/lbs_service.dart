import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LbsService {
  static final LbsService instance = LbsService._init();
  LbsService._init();

  // Arcanova Offline Mystic Sanctuary: Malioboro, Yogyakarta
  static const String sanctuaryName = "Arcanova Mystic Sanctuary Yogyakarta";
  static const String sanctuaryAddress = "Jl. Malioboro No. 56, Sosromenduran, Gedong Tengen, Kota Yogyakarta, D.I. Yogyakarta 55271";
  static const double malioboroLat = -7.792849;
  static const double malioboroLng = 110.365851;

  // Check and request location permission
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current device position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 7),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // Calculate distance in kilometers to Malioboro Sanctuary
  Future<double?> getDistanceToSanctuaryKm() async {
    try {
      final pos = await getCurrentPosition();
      if (pos == null) return null;

      final meters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        malioboroLat,
        malioboroLng,
      );

      return double.parse((meters / 1000.0).toStringAsFixed(2));
    } catch (_) {
      return null;
    }
  }

  // Get User's City and Province using OpenStreetMap Nominatim Reverse Geocoding API
  // Link API: https://nominatim.openstreetmap.org/reverse
  Future<String> getCurrentCityName() async {
    try {
      final pos = await getCurrentPosition();
      if (pos == null) {
        return "Kota Semarang, Jawa Tengah (Estimasi)";
      }

      // Check if running on default Android emulator location (Mountain View, California)
      if ((pos.latitude - 37.42).abs() < 0.1 && (pos.longitude - (-122.08)).abs() < 0.1) {
        return "Kota Semarang, Jawa Tengah (Mode Emulator)";
      }

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=10&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ArcanovaTarotApp/1.0 (contact@arcanova.com)'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final city = addr['city'] ?? addr['town'] ?? addr['county'] ?? addr['municipality'] ?? addr['city_district'] ?? "Kota Terdeteksi";
          final state = addr['state'] ?? addr['region'] ?? addr['province'] ?? "Indonesia";
          return "$city, $state";
        }
      }
      return "Kota Semarang, Jawa Tengah";
    } catch (_) {
      return "Kota Semarang, Jawa Tengah";
    }
  }

  // Check if user is within the "Secret Astral Aura" radius (< 1.5 km)
  Future<bool> isWithinAuraDiscountZone() async {
    final distanceKm = await getDistanceToSanctuaryKm();
    if (distanceKm == null) return false;
    return distanceKm <= 1.5;
  }

  // Open Google Maps route to Malioboro Sanctuary
  Future<void> openSanctuaryInMaps() async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$malioboroLat,$malioboroLng&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}
