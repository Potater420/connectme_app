import 'package:connect_me_community_app/presentation/widgets/member_marker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Zoomed far out so all four cities are visible at once.
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(30, 20),
    zoom: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    final markers =
        MemberMarker.sampleMembers.map((member) => member.toMarker()).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Community Map'), centerTitle: true),
      // SafeArea keeps the map (and its zoom buttons) clear of the phone's
      // navigation bar. top: false because the AppBar already handles the top.
      body: SafeArea(
        top: false,
        child: GoogleMap(
          initialCameraPosition: _initialCamera,
          markers: markers,
        ),
      ),
    );
  }
}