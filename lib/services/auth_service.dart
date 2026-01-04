import 'package:dio/dio.dart';

import '../models/customer.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'fcm_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final FcmService _fcmService = FcmService();

  // 手機號註冊
  Future<Map<String, dynamic>> register({
    required String phone,
    required String nickName,
    required String password,
  }) async {
    try {
      final response = await _api.post('auth/register/', data: {
        'phone': phone,
        'nick_name': nickName,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final customer = Customer.fromJson(response.data['customer']);
        await _storage.saveCustomer(customer);
        await _storage.saveCustomerId(response.data['customer_id']);

        // 保存 Token
        if (response.data['token'] != null) {
          await _storage.saveAuthToken(response.data['token']);
        }

        // 註冊成功後，註冊 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '註冊失敗',
      };
    } catch (e) {
      print('註冊錯誤: $e');
      return {
        'success': false,
        'message': '註冊失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    }
  }

  // 手機號登入
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _api.post('auth/login/', data: {
        'phone': phone,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final customer = Customer.fromJson(response.data['customer']);
        await _storage.saveCustomer(customer);
        await _storage.saveCustomerId(response.data['customer_id']);

        // 保存 Token
        if (response.data['token'] != null) {
          await _storage.saveAuthToken(response.data['token']);
        }

        // 登入成功後，註冊 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '登入失敗',
      };
    } catch (e) {
      print('登入錯誤: $e');
      return {
        'success': false,
        'message': '登入失敗，密碼或網路連線錯誤',
        'error': e.toString(),
      };
    }
  }

  // LINE 登入
  Future<Map<String, dynamic>> lineLogin({
    required String lineUserId,
    required String lineDisplayName,
    String? linePictureUrl,
    String? lineId,
  }) async {
    try {
      final response = await _api.post('auth/line-login/', data: {
        'line_user_id': lineUserId,
        'line_display_name': lineDisplayName,
        if (linePictureUrl != null) 'line_picture_url': linePictureUrl,
        if (lineId != null) 'line_id': lineId,
      });

      if (response.data['status'] == 'success') {
        final customer = Customer.fromJson(response.data['customer']);
        await _storage.saveCustomer(customer);
        await _storage.saveCustomerId(response.data['customer_id']);

        // 保存 Token
        if (response.data['token'] != null) {
          await _storage.saveAuthToken(response.data['token']);
        }

        // LINE 登入成功後，註冊 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'LINE 登入失敗',
      };
    } on DioException catch (e) {
      print('LINE 登入錯誤: $e');
      
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'LINE 登入資料有誤';
        return {
          'success': false,
          'message': errorMsg,
        };
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': '網路連線逾時，請檢查網路',
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': '無法連接伺服器，請檢查網路',
        };
      }
      
      return {
        'success': false,
        'message': 'LINE 登入失敗，請稍後再試',
        'error': e.toString(),
      };
    } catch (e) {
      print('LINE 登入未知錯誤: $e');
      return {
        'success': false,
        'message': 'LINE 登入失敗，請稍後再試',
        'error': e.toString(),
      };
    }
  }

  // Apple 登入
  Future<Map<String, dynamic>> appleLogin({
    required String appleUserId,
    String? appleEmail,
    String? appleFamilyName,
    String? appleGivenName,
  }) async {
    try {
      final response = await _api.post('auth/apple-login/', data: {
        'apple_user_id': appleUserId,
        if (appleEmail != null) 'apple_email': appleEmail,
        if (appleFamilyName != null) 'apple_family_name': appleFamilyName,
        if (appleGivenName != null) 'apple_given_name': appleGivenName,
      });

      if (response.data['status'] == 'success') {
        final customer = Customer.fromJson(response.data['customer']);
        await _storage.saveCustomer(customer);
        await _storage.saveCustomerId(response.data['customer_id']);

        // 保存 Token
        if (response.data['token'] != null) {
          await _storage.saveAuthToken(response.data['token']);
        }

        // Apple 登入成功後，註冊 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Apple 登入失敗',
      };
    } on DioException catch (e) {
      print('Apple 登入錯誤: $e');
      
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Apple 登入資料有誤';
        return {
          'success': false,
          'message': errorMsg,
        };
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': '網路連線逾時，請檢查網路',
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': '無法連接伺服器，請檢查網路',
        };
      }
      
      return {
        'success': false,
        'message': 'Apple 登入失敗，請稍後再試',
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

  // 獲取用戶資料
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get('auth/profile/');

      if (response.data['status'] == 'success') {
        final customer = Customer.fromJson(response.data['customer']);
        await _storage.saveCustomer(customer);

        return {
          'success': true,
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '獲取用戶資料失敗',
      };
    } catch (e) {
      print('獲取用戶資料錯誤: $e');
      return {
        'success': false,
        'message': '獲取用戶資料失敗',
        'error': e.toString(),
      };
    }
  }

  // 登出
  Future<void> logout() async {
    // 服務器沒有提供 logout API，只清除本地存儲
    try {
      // 登出時取消 FCM 註冊
      await _fcmService.unregisterFromServer();
      
      // 嘗試調用登出 API（如果服務器有提供的話）
      // await _api.post('auth/logout/');
      print('登出：清除本地存儲和 Token');
    } catch (e) {
      print('登出 API 調用失敗（忽略）: $e');
    } finally {
      // 無論 API 調用是否成功，都清除本地存儲（包括 Token）
      await _storage.clearCustomer();
    }
  }

  // 刪除帳號
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _api.delete('auth/delete/');

      if (response.data['status'] == 'success') {
        await _storage.clearCustomer();
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '刪除帳號失敗',
      };
    } catch (e) {
      print('刪除帳號錯誤: $e');
      return {
        'success': false,
        'message': '刪除帳號失敗',
        'error': e.toString(),
      };
    }
  }

  // 獲取當前用戶
  Future<Customer?> getCurrentCustomer() async {
    return await _storage.getCustomer();
  }

  // 檢查是否登入
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}
