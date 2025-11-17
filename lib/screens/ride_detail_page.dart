import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_record.dart';

class RideDetailPage extends StatefulWidget {
  final RideRecord ride;

  const RideDetailPage({super.key, required this.ride});

  @override
  State<RideDetailPage> createState() => _RideDetailPageState();
}

class _RideDetailPageState extends State<RideDetailPage> {
  GoogleMapController? _mapController;
  
  // Mock route positions
  late LatLng _pickupLocation;
  late LatLng _dropoffLocation;
  late List<LatLng> _routePoints;

  @override
  void initState() {
    super.initState();
    _initializeMockRoute();
  }

  void _initializeMockRoute() {
    // Mock coordinates for Taipei area
    _pickupLocation = const LatLng(25.0330, 121.5654);
    _dropoffLocation = const LatLng(25.0420, 121.5750);
    
    // Mock route points between pickup and dropoff
    _routePoints = [
      _pickupLocation,
      LatLng(25.0350, 121.5680),
      LatLng(25.0380, 121.5710),
      LatLng(25.0400, 121.5730),
      _dropoffLocation,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程詳情'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map showing route
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pickupLocation,
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMapToRoute();
              },
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              zoomControlsEnabled: false,
            ),
          ),
          
          // Details Section - Simplified
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Row(
                children: [
                  // Left side - Time and Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Time
                        Text(
                          _formatDateTime(widget.ride.dateTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Pickup Address
                        Text(
                          widget.ride.pickupAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side - Status and Fare
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '已完成',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Fare
                      Text(
                        'NT\$ ${widget.ride.fare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '上車地點',
          snippet: widget.ride.pickupAddress,
        ),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: _dropoffLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: '下車地點',
          snippet: widget.ride.dropoffAddress,
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  void _fitMapToRoute() {
    if (_mapController != null) {
      double minLat = _routePoints[0].latitude;
      double maxLat = _routePoints[0].latitude;
      double minLng = _routePoints[0].longitude;
      double maxLng = _routePoints[0].longitude;

      for (var point in _routePoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80, // padding
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

