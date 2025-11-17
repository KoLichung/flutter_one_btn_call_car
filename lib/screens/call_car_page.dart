import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

enum CallCarState {
  idle,
  searching,
  found,
  onBoard,
}

class CallCarPage extends StatefulWidget {
  const CallCarPage({super.key});

  @override
  State<CallCarPage> createState() => _CallCarPageState();
}

class _CallCarPageState extends State<CallCarPage> {
  GoogleMapController? _mapController;
  CallCarState _state = CallCarState.idle;
  
  // Mock data
  LatLng _currentPosition = const LatLng(25.0330, 121.5654); // Default Taipei
  LatLng? _carPosition;
  String _driverName = '';
  String _carNumber = '';
  int _estimatedTime = 0;
  double _fare = 0.0;
  BitmapDescriptor? _carIcon;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createCarIcon();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Move camera to current position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } catch (e) {
      // If location fails, use default Taipei position
      print('Error getting location: $e');
    }
  }

  Future<void> _createCarIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = 120.0;

    // Draw circle background
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 3,
      borderPaint,
    );

    // Draw car icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_car.codePoint),
        style: TextStyle(
          fontSize: 60,
          fontFamily: Icons.directions_car.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size - iconPainter.width) / 2,
        (size - iconPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    setState(() {
      _carIcon = BitmapDescriptor.fromBytes(buffer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _getCurrentLocation();
            },
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll create custom button
            zoomControlsEnabled: false,
            compassEnabled: true,
            padding: const EdgeInsets.only(
              right: 16,
              bottom: 200, // Padding to avoid bottom sheet
            ),
          ),
          
          // Custom location button
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ),
          
          // Top Info Card (when car is found or on board)
          if (_state == CallCarState.found || _state == CallCarState.onBoard)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: _buildInfoCard(),
            ),
          
          // Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    
    // Car marker (if found) - using custom circular car icon
    if (_carPosition != null && 
        _carIcon != null &&
        (_state == CallCarState.found || _state == CallCarState.onBoard)) {
      markers.add(
        Marker(
          markerId: const MarkerId('car'),
          position: _carPosition!,
          icon: _carIcon!,
          infoWindow: InfoWindow(title: '司機位置', snippet: _driverName),
          anchor: const Offset(0.5, 0.5), // Center the icon
        ),
      );
    }
    
    return markers;
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _driverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _carNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_state == CallCarState.found)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '$_estimatedTime 分鐘',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show button only in idle and searching state
            if (_state == CallCarState.idle || _state == CallCarState.searching)
              _buildActionButton(),
            
            // Show status message for found and onBoard states
            if (_state == CallCarState.found) ...[
              const Icon(
                Icons.directions_car,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                '司機正前往您的地方，請耐心等待',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (_state == CallCarState.onBoard) ...[
              const Icon(
                Icons.navigation,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                '司機正載您前往目的地，旅程紀錄中',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (_state == CallCarState.searching) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text(
                '搜索附近車輛中...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    Color buttonColor;
    VoidCallback? onPressed;

    if (_state == CallCarState.idle) {
      buttonText = '一鍵叫車';
      buttonColor = Colors.blue;
      onPressed = _startSearching;
    } else {
      // searching state
      buttonText = '取消叫車';
      buttonColor = Colors.red;
      onPressed = _cancelSearch;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startSearching() {
    setState(() {
      _state = CallCarState.searching;
    });

    // Mock: Find a car after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (_state == CallCarState.searching) {
        setState(() {
          _state = CallCarState.found;
          _carPosition = LatLng(
            _currentPosition.latitude + 0.005,
            _currentPosition.longitude + 0.005,
          );
          _driverName = '王師傅';
          _carNumber = 'ABC-1234';
          _estimatedTime = 5;
        });

        // Move camera to show car position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_carPosition!, 14),
        );

        // Auto transition to onBoard after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (_state == CallCarState.found) {
            setState(() {
              _state = CallCarState.onBoard;
              _fare = 150.0; // Mock fare
            });

            // Auto end trip after another 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              if (_state == CallCarState.onBoard) {
                _endTrip();
              }
            });
          }
        });
      }
    });
  }

  void _cancelSearch() {
    setState(() {
      _state = CallCarState.idle;
    });
  }

  void _endTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('結束行程'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('行程已結束'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('總計車資：'),
                Text(
                  'NT\$ ${_fare.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '請以現金支付司機',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _state = CallCarState.idle;
                _carPosition = null;
                _driverName = '';
                _carNumber = '';
                _estimatedTime = 0;
                _fare = 0.0;
              });
              // Reset camera
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                ),
              );
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}

