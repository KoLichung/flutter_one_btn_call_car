import 'package:dio/dio.dart';

import '../models/customer.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'fcm_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  final FcmService _fcmService = FcmService();

  // 手机号注册
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

        // 注册成功后，注册 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '注册失败',
      };
    } catch (e) {
      print('注册错误: $e');
      return {
        'success': false,
        'message': '注册失败，请检查网络连接',
        'error': e.toString(),
      };
    }
  }

  // 手机号登录
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

        // 登录成功后，注册 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '登录失败',
      };
    } catch (e) {
      print('登录错误: $e');
      return {
        'success': false,
        'message': '登錄失敗，密碼或網路連線錯誤',
        'error': e.toString(),
      };
    }
  }

  // LINE 登录
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

        // LINE 登录成功后，注册 FCM
        await _fcmService.registerToServer();

        return {
          'success': true,
          'message': response.data['message'],
          'customer': customer,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'LINE 登录失败',
      };
    } on DioException catch (e) {
      print('LINE 登录错误: $e');
      
      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'LINE 登錄資料有誤';
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
        'message': 'LINE 登錄失敗，請稍後再試',
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

  // 获取用户资料
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
        'message': response.data['message'] ?? '获取用户资料失败',
      };
    } catch (e) {
      print('获取用户资料错误: $e');
      return {
        'success': false,
        'message': '获取用户资料失败',
        'error': e.toString(),
      };
    }
  }

  // 登出
  Future<void> logout() async {
    // 服务器没有提供 logout API，只清除本地存储
    try {
      // 登出时取消 FCM 注册
      await _fcmService.unregisterFromServer();
      
      // 尝试调用登出 API（如果服务器有提供的话）
      // await _api.post('auth/logout/');
      print('登出：清除本地存储');
    } catch (e) {
      print('登出 API 调用失败（忽略）: $e');
    } finally {
      // 无论 API 调用是否成功，都清除本地存储
      await _storage.clearCustomer();
    }
  }

  // 删除账号
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
        'message': response.data['message'] ?? '删除账号失败',
      };
    } catch (e) {
      print('删除账号错误: $e');
      return {
        'success': false,
        'message': '删除账号失败',
        'error': e.toString(),
      };
    }
  }

  // 获取当前用户
  Future<Customer?> getCurrentCustomer() async {
    return await _storage.getCustomer();
  }

  // 检查是否登录
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}

