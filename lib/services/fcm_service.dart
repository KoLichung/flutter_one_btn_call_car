import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 全局的后台消息处理函数（必须是顶级函数）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 背景通知: ${message.notification?.title}');
  print('📨 背景訊息: ${message.data}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _fcmToken;
  String? _deviceId;

  /// 获取 FCM Token
  String? get fcmToken => _fcmToken;

  /// 获取设备 ID
  String? get deviceId => _deviceId;

  /// 初始化 FCM
  Future<void> initialize() async {
    try {
      print('🚀 開始初始化 FCM...');
      print('📱 平台: ${Platform.operatingSystem}');

      // 1. 请求通知权限
      final notificationSettings = await _requestPermission();
      if (notificationSettings.authorizationStatus != AuthorizationStatus.authorized) {
        print('⚠️ 用戶拒絕通知權限');
        return;
      }

      print('✅ 通知權限已授予');

      // 2. 获取设备 ID
      _deviceId = await _getDeviceId();
      print('📱 設備 ID: $_deviceId');

      // 3. iOS: 先獲取 APNs Token，再獲取 FCM Token
      if (Platform.isIOS) {
        print('🍎 iOS 平台：等待 APNs Token...');
        try {
          final apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) {
            print('✅ APNs Token 已獲取: ${apnsToken.substring(0, 20)}...');
          } else {
            print('⚠️ APNs Token 為 null，延遲後重試...');
            // 等待一段時間讓 APNs Token 準備好
            await Future.delayed(const Duration(seconds: 2));
            final retryToken = await _messaging.getAPNSToken();
            if (retryToken != null) {
              print('✅ APNs Token 重試成功: ${retryToken.substring(0, 20)}...');
            } else {
              print('⚠️ APNs Token 仍為 null，將監聽 token 刷新事件');
            }
          }
        } catch (e) {
          print('⚠️ 獲取 APNs Token 失敗: $e');
        }
      }

      // 4. 获取 FCM Token
      print('🔑 嘗試獲取 FCM Token...');
      try {
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          print('✅ FCM Token 已獲取: ${_fcmToken!.substring(0, 50)}...');
        } else {
          print('⚠️ FCM Token 為 null');
        }
      } catch (e) {
        print('❌ 獲取 FCM Token 失敗: $e');
        _fcmToken = null;
      }

      // 5. 如果 Token 為 null，設置監聽器等待
      if (_fcmToken == null) {
        print('⚠️ FCM Token 暫時無法獲取，設置監聽器等待...');
      }

      // 6. 监听 Token 刷新（包括首次獲取）
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token 更新/首次獲取: ${newToken.substring(0, 50)}...');
        _fcmToken = newToken;
        // Token 更新后重新注册到服务器
        registerToServer();
      });

      // 7. 设置前台通知处理
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 8. 设置后台消息处理（App 在后台但未关闭）
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 9. 检查是否从通知启动 App
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 從通知啟動 App');
        _handleMessageOpenedApp(initialMessage);
      }

      print('✅ FCM 初始化完成${_fcmToken != null ? '' : '（Token 將通過監聽器獲取）'}');
    } catch (e, stackTrace) {
      print('❌ FCM 初始化失敗: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// 请求通知权限
  Future<NotificationSettings> _requestPermission() async {
    print('📋 請求通知權限...');
    
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔔 權限狀態: ${settings.authorizationStatus}');
    
    // iOS: 設置前台通知選項（前台時不顯示通知，只在背景時顯示）
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,  // 前台時不顯示通知
        badge: false,  // 前台時不更新 badge
        sound: false,  // 前台時不播放聲音
      );
    }
    
    return settings;
  }

  /// 获取设备唯一 ID
  Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // 使用 Android ID 作为设备唯一标识
        return androidInfo.id; // This is unique to each device
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // iOS 使用 identifierForVendor
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
      return 'unknown_device';
    } catch (e) {
      print('❌ 獲取設備 ID 失敗: $e');
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 注册设备到服务器
  Future<bool> registerToServer() async {
    try {
      print('🔍 檢查 FCM 註冊條件...');
      
      // 检查是否已登录
      final customer = await _storage.getCustomer();
      if (customer == null) {
        print('⚠️ 用戶未登錄，跳過 FCM 註冊');
        return false;
      }
      print('✅ 用戶已登錄: ${customer.nickName}');

      if (_fcmToken == null) {
        print('⚠️ FCM Token 不存在，嘗試重新獲取...');
        try {
          _fcmToken = await _messaging.getToken();
          if (_fcmToken != null) {
            print('✅ 重新獲取 FCM Token 成功');
          } else {
            print('❌ 重新獲取 FCM Token 失敗，Token 仍為 null');
            return false;
          }
        } catch (e) {
          print('❌ 重新獲取 FCM Token 異常: $e');
          return false;
        }
      }
      
      if (_deviceId == null) {
        print('⚠️ 設備 ID 不存在');
        return false;
      }

      print('📤 向服務器註冊 FCM...');
      print('   Token (前50字元): ${_fcmToken!.substring(0, _fcmToken!.length > 50 ? 50 : _fcmToken!.length)}...');
      print('   Device ID: $_deviceId');
      print('   Type: ${Platform.isAndroid ? 'android' : 'ios'}');

      final response = await _api.post(
        'fcm/register/',
        data: {
          'registration_id': _fcmToken,
          'device_id': _deviceId,
          'type': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      if (response.data['status'] == 'success') {
        print('✅ FCM 註冊成功: ${response.data['message']}');
        return true;
      } else {
        print('❌ FCM 註冊失敗: ${response.data['message']}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ FCM 註冊錯誤: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// 处理前台通知（App 在前台时收到）
  /// 注意：前台時不顯示通知，只在背景時顯示
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 前台通知（不顯示）: ${message.notification?.title}');
    print('📨 前台訊息內容: ${message.data}');

    // 前台時不顯示通知，只處理數據更新 UI
    // Android: FlutterFire 的 onMessage 默認不會自動顯示通知
    // iOS: 已通過 setForegroundNotificationPresentationOptions 禁用前台通知

    if (message.notification != null) {
      print('   標題: ${message.notification!.title}');
      print('   內容: ${message.notification!.body}');
    }

    // 根据消息类型处理（更新 UI，但不顯示通知）
    _handleNotificationData(message.data);
  }

  /// 处理点击通知后打开 App
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📬 點擊通知打開 App');
    print('📨 訊息內容: ${message.data}');

    // 根据消息类型跳转到相应页面
    _handleNotificationData(message.data);
  }

  /// 处理通知数据
  void _handleNotificationData(Map<String, dynamic> data) {
    print('📋 處理通知數據: $data');

    // 根据不同的通知类型进行处理
    final type = data['type'];
    
    switch (type) {
      case 'driver_assigned':
        print('🚗 司機已分配: ${data['driver_name']}');
        // 可以触发 UI 更新或导航
        break;
      case 'driver_arrived':
        print('📍 司機已到達');
        // 可以触发 UI 更新
        break;
      case 'trip_started':
        print('🚕 行程開始');
        break;
      case 'trip_finished':
        print('✅ 行程完成，費用: ${data['case_money']}');
        break;
      default:
        print('📩 其他通知類型: $type');
    }
  }

  /// 取消注册（登出时调用）
  Future<void> unregisterFromServer() async {
    try {
      if (_deviceId == null) {
        print('⚠️ 沒有設備 ID，無需取消註冊');
        return;
      }

      print('📤 取消 FCM 註冊...');
      
      // 如果服务器有取消注册的 API，可以在这里调用
      // await _api.post('one_btn_call_car_api/fcm/unregister/', data: {'device_id': _deviceId});

      // 删除 FCM Token
      await _messaging.deleteToken();
      _fcmToken = null;
      
      print('✅ FCM 取消註冊成功');
    } catch (e) {
      print('❌ FCM 取消註冊失敗: $e');
    }
  }

  /// 检查通知权限状态
  Future<bool> checkPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// 再次请求权限（如果之前被拒绝）
  Future<bool> requestPermissionAgain() async {
    final settings = await _requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 权限授予后重新初始化
      await initialize();
      return true;
    }
    return false;
  }
}

