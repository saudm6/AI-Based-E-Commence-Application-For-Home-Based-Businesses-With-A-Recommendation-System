import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late GoogleMapController _mapController;
  LatLng? _pickedPosition;

  @override
  void initState() {
    super.initState();

    // Initialize picked position
    _pickedPosition = widget.initialLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Update maker position
  void _onTap(LatLng position) {
    setState(() {
      _pickedPosition = position;
    });
  }

  // Return coordinates
  void _onConfirm() {
    if (_pickedPosition != null) {
      Navigator.pop(context, _pickedPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = widget.initialLocation ?? const LatLng(0, 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Store Location'),
      ),
      body: GoogleMap(

        // Set initial view
        initialCameraPosition: CameraPosition(
          target: initialCamera,
          zoom: widget.initialLocation != null ? 15 : 2,
        ),
        onMapCreated: _onMapCreated,
        onTap: _onTap,

        // Display marker
        markers: _pickedPosition == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('picked'),
            position: _pickedPosition!,
          )
        },
      ),

      // Confirm button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickedPosition == null ? null : _onConfirm,
        label: const Text('Confirm'),
        icon: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


