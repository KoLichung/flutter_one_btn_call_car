import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'auth_service.dart';

class LineLoginService {
  static final LineLoginService _instance = LineLoginService._internal();
  factory LineLoginService() => _instance;
  LineLoginService._internal();

  final AuthService _authService = AuthService();

  // 初始化 LINE SDK
  Future<void> initialize(String channelId) async {
    try {
      await LineSDK.instance.setup(channelId);
      print('LINE SDK 初始化成功');
    } catch (e) {
      print('LINE SDK 初始化失败: $e');
    }
  }

  // LINE 登录
  Future<Map<String, dynamic>> login() async {
    try {
      // 调用 LINE 登录
      final result = await LineSDK.instance.login(
        scopes: ['profile', 'openid'],
      );

      if (result.userProfile != null) {
        final profile = result.userProfile!;
        
        print('LINE 登录成功:');
        print('  User ID: ${profile.userId}');
        print('  Display Name: ${profile.displayName}');
        print('  Picture URL: ${profile.pictureUrl}');

        // 调用后端 API
        final apiResult = await _authService.lineLogin(
          lineUserId: profile.userId,
          lineDisplayName: profile.displayName,
          linePictureUrl: profile.pictureUrl?.toString(),
        );

        return apiResult;
      }

      return {
        'success': false,
        'message': 'LINE 登錄失敗，未獲取到用戶資料',
      };
    } on PlatformException catch (e) {
      print('LINE 登录平台错误: ${e.code} - ${e.message}');
      
      // 处理 LINE SDK 特定错误
      if (e.code == 'CANCEL') {
        return {
          'success': false,
          'message': '已取消 LINE 登入',
          'cancelled': true,
        };
      } else if (e.code == 'AUTHENTICATION_AGENT_ERROR') {
        return {
          'success': false,
          'message': 'LINE 認證錯誤，請檢查是否已安裝 LINE App',
        };
      }
      
      return {
        'success': false,
        'message': 'LINE 登錄失敗: ${e.message}',
        'error': e.toString(),
      };
    } catch (e) {
      print('LINE 登录未知错误: $e');
      return {
        'success': false,
        'message': 'LINE 登錄失敗，請稍後再試',
        'error': e.toString(),
      };
    }
  }

  // 登出 LINE
  Future<void> logout() async {
    try {
      await LineSDK.instance.logout();
      print('LINE 登出成功');
    } catch (e) {
      print('LINE 登出失败: $e');
    }
  }

  // 获取当前 LINE 登录状态
  Future<bool> isLoggedIn() async {
    try {
      final result = await LineSDK.instance.currentAccessToken;
      return result != null;
    } catch (e) {
      return false;
    }
  }

  // 获取当前 LINE 用户资料
  Future<UserProfile?> getCurrentProfile() async {
    try {
      final result = await LineSDK.instance.getProfile();
      return result;
    } catch (e) {
      print('获取 LINE 用户资料失败: $e');
      return null;
    }
  }
}

