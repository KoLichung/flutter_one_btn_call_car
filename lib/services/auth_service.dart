import '../models/customer.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

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
        'message': '登录失败，请检查网络连接',
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
    } catch (e) {
      print('LINE 登录错误: $e');
      return {
        'success': false,
        'message': 'LINE 登录失败，请检查网络连接',
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
    try {
      await _api.post('auth/logout/');
    } catch (e) {
      print('登出 API 调用失败: $e');
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

