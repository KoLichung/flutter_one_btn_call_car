import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ride_service.dart';
import '../services/storage_service.dart';
import '../models/driver.dart';

enum CallCarState {
  idle,
  calling,
  waiting,
  driverOnWay,
  arrived,
  onBoard,
  finished,
}

class CallCarPage extends StatefulWidget {
  const CallCarPage({super.key});

  @override
  State<CallCarPage> createState() => _CallCarPageState();
}

class _CallCarPageState extends State<CallCarPage> {
  GoogleMapController? _mapController;
  final RideService _rideService = RideService();
  final StorageService _storage = StorageService();
  
  CallCarState _state = CallCarState.idle;
  LatLng _currentPosition = const LatLng(25.0330, 121.5654); // Default Taipei
  LatLng? _driverPosition;
  String _currentAddress = '獲取位置中...';
  
  // 订单信息
  int? _currentCaseId;
  String? _caseNumber;
  String _caseState = '';
  
  // 司机信息
  Driver? _driver;
  
  // UI 状态
  BitmapDescriptor? _carIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createCarIcon();
  }

  @override
  void dispose() {
    _rideService.stopTracking();
    _rideService.dispose();
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

        // 获取地址
        await _getAddressFromLatLng(position.latitude, position.longitude);

        // Move camera to current position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentAddress = '獲取位置失敗';
      });
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    // 显示经纬度（6位小数）
    setState(() {
      _currentAddress = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    });
  }

  void _fitBoundsToShowBothPositions() {
    if (_driverPosition == null || _mapController == null) return;

    // 计算乘客和司机的中间点
    double centerLat = (_currentPosition.latitude + _driverPosition!.latitude) / 2;
    double centerLng = (_currentPosition.longitude + _driverPosition!.longitude) / 2;

    // 移动到中间点，保持当前缩放比例
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(LatLng(centerLat, centerLng)),
    );
  }

  Future<void> _createCarIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = 80.0;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 3,
      borderPaint,
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_car.codePoint),
        style: TextStyle(
          fontSize: 40,
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
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            padding: const EdgeInsets.only(
              right: 16,
              bottom: 200,
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
          
          // Top Info Card (when driver is assigned)
          if (_driver != null && (_state == CallCarState.driverOnWay || 
              _state == CallCarState.arrived || 
              _state == CallCarState.onBoard))
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: _buildDriverInfoCard(),
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
    
    // Driver marker
    if (_driverPosition != null && _carIcon != null && _driver != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverPosition!,
          icon: _carIcon!,
          infoWindow: InfoWindow(
            title: '司機位置', 
            snippet: _driver!.nickName,
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
    
    return markers;
  }

  Widget _buildDriverInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                    _driver!.nickName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_driver!.carColor} ${_driver!.carLicence}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (_state == CallCarState.driverOnWay)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      '前往中',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 显示当前地址
            if (_state == CallCarState.idle)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_state == CallCarState.idle)
              const SizedBox(height: 16),
            
            // 按钮或状态信息
            if (_state == CallCarState.idle)
              _buildCallButton(),
            
            if (_state == CallCarState.calling)
              _buildLoadingState('正在叫車...'),
            
            if (_state == CallCarState.waiting)
              _buildWaitingState(),
            
            if (_state == CallCarState.driverOnWay)
              _buildDriverOnWayState(),
            
            if (_state == CallCarState.arrived)
              _buildArrivedState(),
            
            if (_state == CallCarState.onBoard)
              _buildOnBoardState(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCallCar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '一鍵叫車',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingState() {
    return Column(
      children: [
        const Icon(
          Icons.search,
          size: 48,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        Text(
          '正在尋找司機...',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        if (_caseNumber != null) ...[
          const SizedBox(height: 8),
          Text(
            '訂單號: $_caseNumber',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleCancelCase,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('取消叫車'),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverOnWayState() {
    return const Column(
      children: [
        Icon(
          Icons.directions_car,
          size: 48,
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        Text(
          '司機正前往您的位置，請耐心等待',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildArrivedState() {
    return const Column(
      children: [
        Icon(
          Icons.notifications_active,
          size: 48,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        Text(
          '司機已到達，請儘快上車',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOnBoardState() {
    return const Column(
      children: [
        Icon(
          Icons.navigation,
          size: 48,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        Text(
          '行程進行中，祝您旅途愉快',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // API 调用方法
  Future<void> _handleCallCar() async {
    setState(() {
      _isLoading = true;
      _state = CallCarState.calling;
    });

    final customer = await _storage.getCustomer();

    final result = await _rideService.callCar(
      onLat: _currentPosition.latitude,
      onLng: _currentPosition.longitude,
      onAddress: _currentAddress,
      customerPhone: customer?.phone,
      customerName: customer?.displayName,
    );

    if (result['success'] == true) {
      setState(() {
        _currentCaseId = result['case_id'];
        _caseNumber = result['case_number'];
        _caseState = result['case_state'];
        _state = CallCarState.waiting;
        _isLoading = false;
      });

      // 开始追踪订单
      _startTracking();
    } else {
      setState(() {
        _isLoading = false;
        _state = CallCarState.idle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '叫車失敗'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTracking() {
    if (_currentCaseId == null) return;

    _rideService.startTracking(_currentCaseId!, (result) {
      if (result['success'] != true) return;

      setState(() {
        _caseState = result['case_state'];

        // 更新司机信息
        if (result['driver'] != null) {
          _driver = result['driver'] as Driver;
        }

        // 更新司机位置
        if (result['driver_lat'] != null && result['driver_lng'] != null) {
          final newDriverPosition = LatLng(
            result['driver_lat'],
            result['driver_lng'],
          );
          
          // 只在第一次获取司机位置或司机位置明显变化时才更新地图
          bool shouldUpdateMap = _driverPosition == null;
          
          _driverPosition = newDriverPosition;

          // 如果是第一次获取司机位置，移动到中间点
          if (shouldUpdateMap && _driver != null) {
            _fitBoundsToShowBothPositions();
          }
        }

        // 更新状态
        _updateStateFromCaseState(_caseState, result);
      });
    });
  }

  void _updateStateFromCaseState(String caseState, Map<String, dynamic> result) {
    switch (caseState) {
      case 'wait':
      case 'dispatching':
        _state = CallCarState.waiting;
        break;
      case 'way_to_catch':
        _state = CallCarState.driverOnWay;
        break;
      case 'arrived':
        _state = CallCarState.arrived;
        break;
      case 'catched':
      case 'on_road':
        _state = CallCarState.onBoard;
        break;
      case 'finished':
        _handleTripFinished(result);
        break;
      case 'canceled':
        _handleTripCanceled();
        break;
    }
  }

  void _handleTripFinished(Map<String, dynamic> result) {
    _rideService.stopTracking();
    
    // 获取车资
    final caseMoney = result['case_money'];
    
    // 显示行程结束对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('行程結束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              '感謝您的使用',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (caseMoney != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '本次車資：',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'NT\$ ${caseMoney.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetState();
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _handleTripCanceled() {
    _rideService.stopTracking();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('訂單已取消(可能暫時附近無司機)'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    _resetState();
  }

  Future<void> _handleCancelCase() async {
    if (_currentCaseId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認取消'),
        content: const Text('確認要取消叫車嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('我再想想'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認取消'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _rideService.cancelCase(_currentCaseId!);
      
      if (result['success'] == true) {
        _rideService.stopTracking();
        _resetState();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '訂單已成功取消'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 取消失敗，顯示錯誤消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '取消訂單失敗'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resetState() {
    setState(() {
      _state = CallCarState.idle;
      _currentCaseId = null;
      _caseNumber = null;
      _caseState = '';
      _driver = null;
      _driverPosition = null;
    });

    // 重置地图视角
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: 15,
        ),
      ),
    );
  }
}
