import 'package:google_maps_flutter/google_maps_flutter.dart';

/// One community member's place on the map, plus the hardcoded demo list.
class MemberMarker {
  final String name;
  final String city;
  final LatLng position;

  const MemberMarker({
    required this.name,
    required this.city,
    required this.position,
  });

  /// Four members in four different cities (the brief asks for at least three).
  static const List<MemberMarker> sampleMembers = [
    MemberMarker(
      name: 'Sara Ahmed',
      city: 'Cairo',
      position: LatLng(30.0444, 31.2357),
    ),
    MemberMarker(
      name: 'James Carter',
      city: 'London',
      position: LatLng(51.5074, -0.1278),
    ),
    MemberMarker(
      name: 'Yuki Tanaka',
      city: 'Tokyo',
      position: LatLng(35.6762, 139.6503),
    ),
    MemberMarker(
      name: 'Maria Lopez',
      city: 'New York',
      position: LatLng(40.7128, -74.0060),
    ),
  ];

  /// Builds the map pin. Tapping it opens an info window with name and city.
  Marker toMarker() {
    return Marker(
      markerId: MarkerId(name),
      position: position,
      infoWindow: InfoWindow(title: name, snippet: city),
    );
  }
}