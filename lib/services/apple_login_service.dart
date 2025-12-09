import 'dart:io';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_service.dart';

class AppleLoginService {
  static final AppleLoginService _instance = AppleLoginService._internal();
  factory AppleLoginService() => _instance;
  AppleLoginService._internal();

  final AuthService _authService = AuthService();

  // 檢查 Apple Sign In 是否可用
  Future<bool> isAvailable() async {
    if (!Platform.isIOS) {
      return false;
    }
    return await SignInWithApple.isAvailable();
  }

  // Apple 登入
  Future<Map<String, dynamic>> login() async {
    try {
      // 調用 Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('Apple 登入成功:');
      print('  User ID: ${credential.userIdentifier}');
      print('  Email: ${credential.email}');
      print('  Family Name: ${credential.familyName}');
      print('  Given Name: ${credential.givenName}');

      if (credential.userIdentifier == null) {
        return {
          'success': false,
          'message': 'Apple 登入失敗，未獲取到用戶 ID',
        };
      }

      // 調用後端 API
      final apiResult = await _authService.appleLogin(
        appleUserId: credential.userIdentifier!,
        appleEmail: credential.email,
        appleFamilyName: credential.familyName,
        appleGivenName: credential.givenName,
      );

      return apiResult;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('Apple 登入授權錯誤: ${e.code} - ${e.message}');
      
      // 處理 Apple Sign In 特定錯誤
      if (e.code == AuthorizationErrorCode.canceled) {
        return {
          'success': false,
          'message': '已取消 Apple 登入',
          'cancelled': true,
        };
      } else if (e.code == AuthorizationErrorCode.failed) {
        return {
          'success': false,
          'message': 'Apple 登入認證失敗',
        };
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        return {
          'success': false,
          'message': 'Apple 登入回應無效',
        };
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        return {
          'success': false,
          'message': 'Apple 登入請求未處理',
        };
      } else if (e.code == AuthorizationErrorCode.notInteractive) {
        return {
          'success': false,
          'message': 'Apple 登入需要互動式授權',
        };
      }
      
      return {
        'success': false,
        'message': 'Apple 登入失敗: ${e.message}',
        'error': e.toString(),
      };
    } catch (e) {
      print('Apple 登入未知錯誤: $e');
      return {
        'success': false,
        'message': 'Apple 登入失敗，請稍後再試',
        'error': e.toString(),
      };
    }
  }
}

