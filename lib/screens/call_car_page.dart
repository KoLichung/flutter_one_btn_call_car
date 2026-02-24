import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import '../services/ride_service.dart';
import '../services/storage_service.dart';
import '../models/driver.dart';
import 'chat_page.dart';

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
  
  // 静态方法：检查是否有活动案件
  static bool hasActiveCase(GlobalKey<State<CallCarPage>> key) {
    final state = key.currentState;
    if (state == null || state is! _CallCarPageState) return false;
    
    final callCarState = state.currentState;
    return callCarState != CallCarState.idle && callCarState != CallCarState.finished;
  }
}

class _CallCarPageState extends State<CallCarPage> {
  GoogleMapController? _mapController;
  final RideService _rideService = RideService();
  final StorageService _storage = StorageService();
  
  CallCarState _state = CallCarState.idle;
  LatLng _currentPosition = const LatLng(25.0330, 121.5654); // Default Taipei
  LatLng? _driverPosition;
  String _currentAddress = '';
  
  // 訂單信息
  int? _currentCaseId;
  String? _caseNumber;
  String _caseState = '';
  
  // 司機信息
  Driver? _driver;
  
  // 未讀消息數
  int _unreadMessagesCount = 0;
  
  // 司機預計到達時間（秒）
  int? _userExpectSecond;
  
  // UI 狀態
  BitmapDescriptor? _carIcon;
  bool _isLoading = false;

  // Android 音效播放（找到司機/司機抵達）
  AudioPlayer? _notificationSoundPlayer;

  // 暴露当前状态给外部访问
  CallCarState get currentState => _state;

  // 將秒數轉換為分鐘範圍文字
  String _formatExpectedTime(int? seconds) {
    if (seconds == null) return '';
    
    // 將秒數轉換為分鐘
    final minutes = (seconds / 60).ceil();
    
    // 計算分鐘範圍
    // 0~5分鐘, 5~10分鐘, 10~15分鐘, ...
    final lowerBound = minutes <= 0 ? 0 : ((minutes - 1) ~/ 5) * 5;
    final upperBound = lowerBound + 5;
    
    // 根據語言返回不同的格式
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (isEnglish) {
      return '$lowerBound~$upperBound minutes';
    } else {
      return '$lowerBound~$upperBound分鐘';
    }
  }

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
    _notificationSoundPlayer?.dispose();
    super.dispose();
  }

  /// 僅在 Android 上播放通知音效（找到司機 / 司機抵達）
  void _playNotificationSoundOnAndroid(String assetName) {
    if (!Platform.isAndroid) return;
    try {
      _notificationSoundPlayer ??= AudioPlayer();
      _notificationSoundPlayer!.play(AssetSource(assetName));
    } catch (e) {
      print('🔴 [CallCarPage] 播放通知音效失敗: $e');
    }
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

        // 獲取地址
        await _getAddressFromLatLng(position.latitude, position.longitude);

        // Move camera to current position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        setState(() {
          _currentAddress = AppLocalizations.of(context)!.locationFailed;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    // 顯示經緯度（6位小数）
    setState(() {
      _currentAddress = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    });
  }

  void _fitBoundsToShowBothPositions() {
    if (_driverPosition == null || _mapController == null) return;

    // 計算乘客和司機的中間點
    double centerLat = (_currentPosition.latitude + _driverPosition!.latitude) / 2;
    double centerLng = (_currentPosition.longitude + _driverPosition!.longitude) / 2;

    // 移動到中間點，保持當前縮放比例
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
            title: _driver!.nickName, 
            snippet: '',
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
    
    return markers;
  }

  Widget _buildDriverInfoCard() {
    // 检查当前语言是否为英文
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isEnglish ? _buildEnglishLayout() : _buildChineseLayout(),
      ),
    );
  }

  // 英文布局：垂直排列
  Widget _buildEnglishLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.blue, size: 30),
        ),
        const SizedBox(width: 12),
        // 信息区域：垂直排列
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 司机名字
              Text(
                _driver!.nickName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // 车辆信息
              Text(
                '${_driver!.carColor} ${_driver!.carLicence}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              // 預計到達時間（僅在司機前往中顯示）
              if (_state == CallCarState.driverOnWay && _userExpectSecond != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.driverExpectedArrival(_formatExpectedTime(_userExpectSecond)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.driverExpectedArrivalNote,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              // 状态标签
              if (_state == CallCarState.driverOnWay)
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.driverOnWay,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_state == CallCarState.arrived)
                Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.driverArrived,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              if (_state == CallCarState.onBoard)
                Row(
                  children: [
                    const Icon(Icons.navigation, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.onBoard,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // 聊天按钮（旅程中不显示）
        if (_state != CallCarState.onBoard)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  print('🔵 [CallCarPage] 進入聊天頁面，停止 tracking');
                  _rideService.stopTracking();
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        driverName: _driver!.nickName,
                        driverId: _driver!.id?.toString(),
                        caseId: _currentCaseId?.toString(),
                      ),
                    ),
                  ).then((_) {
                    print('🔵 [CallCarPage] 從聊天頁面返回，恢復 tracking');
                    setState(() {
                      _unreadMessagesCount = 0;
                    });
                    
                    if (_currentCaseId != null && 
                        (_state == CallCarState.driverOnWay || 
                         _state == CallCarState.arrived || 
                         _state == CallCarState.onBoard)) {
                      _startTracking();
                    }
                  });
                },
                icon: const Icon(
                  Icons.chat,
                  color: Colors.blue,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (_unreadMessagesCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadMessagesCount > 99 ? '99+' : '$_unreadMessagesCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // 中文布局：原来的水平排列
  Widget _buildChineseLayout() {
    return Row(
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
        const SizedBox(width: 8),
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
              // 預計到達時間（僅在司機前往中顯示）
              if (_state == CallCarState.driverOnWay && _userExpectSecond != null) ...[
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.driverExpectedArrival(_formatExpectedTime(_userExpectSecond)),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.driverExpectedArrivalNote,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // 狀態標籤和對話icon靠右對齊
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 狀態標籤
            if (_state == CallCarState.driverOnWay)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.driverOnWay,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (_state == CallCarState.arrived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.driverArrived,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_state == CallCarState.onBoard)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.onBoard,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // 對話icon（旅程中狀態不顯示）
            if (_state != CallCarState.onBoard) ...[
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      print('🔵 [CallCarPage] 進入聊天頁面，停止 tracking');
                      _rideService.stopTracking();
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            driverName: _driver!.nickName,
                            driverId: _driver!.id?.toString(),
                            caseId: _currentCaseId?.toString(),
                          ),
                        ),
                      ).then((_) {
                        print('🔵 [CallCarPage] 從聊天頁面返回，恢復 tracking');
                        setState(() {
                          _unreadMessagesCount = 0;
                        });
                        
                        if (_currentCaseId != null && 
                            (_state == CallCarState.driverOnWay || 
                             _state == CallCarState.arrived || 
                             _state == CallCarState.onBoard)) {
                          _startTracking();
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.chat,
                      color: Colors.blue,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (_unreadMessagesCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _unreadMessagesCount > 99 ? '99+' : '$_unreadMessagesCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
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
            // 顯示當前地址
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
                        _currentAddress.isEmpty ? AppLocalizations.of(context)!.gettingLocation : _currentAddress,
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
            
            // 按鈕或狀態信息
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
            : Text(
                AppLocalizations.of(context)!.oneClickCallCar,
                style: const TextStyle(
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
          AppLocalizations.of(context)!.calling,
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
          AppLocalizations.of(context)!.findingDriver,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        if (_caseNumber != null) ...[
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!.orderNumber} $_caseNumber',
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
            child: Text(AppLocalizations.of(context)!.cancelCallCar),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverOnWayState() {
    return Column(
      children: [
        const Icon(
          Icons.directions_car,
          size: 48,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.driverOnWayMessage,
          style: const TextStyle(
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
    return Column(
      children: [
        const Icon(
          Icons.notifications_active,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.driverArrivedMessage,
          style: const TextStyle(
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
    return Column(
      children: [
        const Icon(
          Icons.navigation,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.onBoardMessage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // API 調用方法
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

      // 開始追蹤訂單
      _startTracking();
    } else {
      setState(() {
        _isLoading = false;
        _state = CallCarState.idle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? AppLocalizations.of(context)!.callCarFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTracking() {
    if (_currentCaseId == null) {
      print('🔴 [CallCarPage] _startTracking: _currentCaseId 為 null，無法開始追蹤');
      return;
    }

    print('🔵 [CallCarPage] 開始追蹤訂單 - caseId: $_currentCaseId');
    _rideService.startTracking(_currentCaseId!, (result) {
      if (result['success'] != true) {
        print('🔴 [CallCarPage] 追蹤結果失敗: $result');
        return;
      }

      print('🔵 [CallCarPage] 追蹤更新 - case_state: ${result['case_state']}, unread_count: ${result['unread_driver_messages_count']}');

      setState(() {
        _caseState = result['case_state'];

        // 更新司機信息
        if (result['driver'] != null) {
          _driver = result['driver'] as Driver;
          print('🔵 [CallCarPage] 更新司機信息: ${_driver!.nickName}');
        }

        //  更新司機位置
        if (result['driver_lat'] != null && result['driver_lng'] != null) {
          final newDriverPosition = LatLng(
            result['driver_lat'],
            result['driver_lng'],
          );
          
          // 只在第一次獲取司機位置或司機位置明顯變化時才更新地圖
          bool shouldUpdateMap = _driverPosition == null;
          
          _driverPosition = newDriverPosition;

          // 如果是第一次獲取司機位置，移動到中間點
          if (shouldUpdateMap && _driver != null) {
            print('🔵 [CallCarPage] 第一次獲取司機位置，移動地圖視角');
            _fitBoundsToShowBothPositions();
          }
        }

        // 更新未讀消息數
        if (result['unread_driver_messages_count'] != null) {
          final newCount = result['unread_driver_messages_count'] as int;
          if (newCount != _unreadMessagesCount) {
            print('🔵 [CallCarPage] 更新未讀消息數: $_unreadMessagesCount -> $newCount');
            _unreadMessagesCount = newCount;
          }
        }

        // 更新司機預計到達時間
        if (result['user_expect_second'] != null) {
          _userExpectSecond = result['user_expect_second'] as int;
        }

        // 更新狀態
        _updateStateFromCaseState(_caseState, result);
      });
    });
  }

  void _updateStateFromCaseState(String caseState, Map<String, dynamic> result) {
    final previousState = _state;
    switch (caseState) {
      case 'wait':
      case 'dispatching':
        _state = CallCarState.waiting;
        break;
      case 'way_to_catch':
        _state = CallCarState.driverOnWay;
        // Android: 找到司機時播放 got_a_driver
        if (previousState != CallCarState.driverOnWay) {
          _playNotificationSoundOnAndroid('got_a_driver.mp3');
        }
        break;
      case 'arrived':
        _state = CallCarState.arrived;
        // Android: 司機抵達時播放 ding_dong
        if (previousState != CallCarState.arrived) {
          _playNotificationSoundOnAndroid('ding_dong.mp3');
        }
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
    
    // 獲取車資
    final caseMoney = result['case_money'];
    
    // 顯示行程結束對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.tripFinished),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.thankYou,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (caseMoney != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.fare,
                    style: const TextStyle(fontSize: 16),
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
            const SizedBox(height: 8),
            // 黑名單按鈕（向右對齊）
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _showBlacklistConfirmDialog(context),
                icon: const Icon(Icons.person_add_disabled, size: 18),
                label: Text(AppLocalizations.of(context)!.blacklist),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 確定按鈕（左右拉滿）
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetState();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBlacklistConfirmDialog(BuildContext parentContext) async {
    final confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmBlacklist),
        content: Text(AppLocalizations.of(context)!.confirmBlacklistMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentCaseId != null) {
      // 關閉行程結束對話框
      Navigator.of(parentContext).pop();
      
      // 調用 API 加入黑名單
      final result = await _rideService.blacklistDriver(_currentCaseId!);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? AppLocalizations.of(context)!.blacklistSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? AppLocalizations.of(context)!.blacklistFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      // 重置狀態
      _resetState();
    }
  }

  void _handleTripCanceled() {
    _rideService.stopTracking();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.orderCanceled),
          content: Text(AppLocalizations.of(context)!.orderCanceledByDriver),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      );
    } else {
      _resetState();
    }
  }

  Future<void> _handleCancelCase() async {
    if (_currentCaseId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmCancel),
        content: Text(AppLocalizations.of(context)!.confirmCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.thinkAgain),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.confirmCancelButton),
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
              content: Text(result['message'] ?? AppLocalizations.of(context)!.orderCancelSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 取消失敗，顯示錯誤消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? AppLocalizations.of(context)!.orderCancelFailed),
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
      _unreadMessagesCount = 0;
      _userExpectSecond = null;
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
