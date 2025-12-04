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
    // 使用实际的订单位置
    _pickupLocation = LatLng(widget.ride.onLat, widget.ride.onLng);
    
    // 检查是否有下车位置
    if (widget.ride.offLat != null && widget.ride.offLng != null) {
      // 有终点，使用实际位置
      _dropoffLocation = LatLng(widget.ride.offLat!, widget.ride.offLng!);
      
      // 生成路线点（起点 -> 中间点 -> 终点）
      _routePoints = [
        _pickupLocation,
        LatLng(
          (_pickupLocation.latitude + _dropoffLocation.latitude) / 2,
          (_pickupLocation.longitude + _dropoffLocation.longitude) / 2,
        ),
        _dropoffLocation,
      ];
    } else {
      // 没有终点，只有起点
      _dropoffLocation = _pickupLocation;
      _routePoints = [_pickupLocation]; // 只有一个点
    }
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
                          _formatDateTime(widget.ride.createDateTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Pickup Address
                        Text(
                          widget.ride.onAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.ride.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Fare
                      Text(
                        widget.ride.caseMoney != null
                            ? 'NT\$ ${widget.ride.caseMoney!.toStringAsFixed(0)}'
                            : '-',
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
    Set<Marker> markers = {
      // 起点（绿色）
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '上車地點',
          snippet: widget.ride.onAddress,
        ),
      ),
    };
    
    // 只有在有终点且不同于起点时才添加终点标记
    if (widget.ride.offLat != null && 
        widget.ride.offLng != null &&
        (widget.ride.offLat != widget.ride.onLat || 
         widget.ride.offLng != widget.ride.onLng)) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoffLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '下車地點',
            snippet: widget.ride.offAddress ?? '',
          ),
        ),
      );
    }
    
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    // 只有在有多个点时才画线
    if (_routePoints.length < 2) {
      return {};
    }
    
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
    if (_mapController == null) return;
    
    // 如果只有一个点，直接居中显示
    if (_routePoints.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _routePoints[0],
            zoom: 15,
          ),
        ),
      );
      return;
    }
    
    // 有多个点，计算边界
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor() {
    switch (widget.ride.caseState) {
      case 'finished':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'wait':
      case 'dispatching':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

