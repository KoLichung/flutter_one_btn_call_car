import 'package:dio/dio.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();
  final String _customerServiceBaseUrl = 'https://ai-taxi-api-5koy2twboa-de.a.run.app/api/customer-service/';
  final String _apiKey = 'customer_service_api_key_2024_temp';

  // 創建或獲取活躍的司機乘客對話會話
  Future<Map<String, dynamic>> createOrGetConversation({
    required int caseId,
    int? driverId,
    int? customerId,
  }) async {
    try {
      print('🔵 [ChatService] 開始創建或獲取對話會話 - caseId: $caseId, driverId: $driverId, customerId: $customerId');
      
      // 先嘗試獲取活躍的對話會話
      print('🔵 [ChatService] 嘗試獲取活躍對話會話...');
      final activeResponse = await _makeRequest(
        'GET',
        'driver-customer/conversations/active/',
        params: {
          'case_id': caseId,
          if (driverId != null) 'driver_id': driverId,
          if (customerId != null) 'customer_id': customerId,
        },
      );

      print('🔵 [ChatService] 獲取活躍對話會話響應: $activeResponse');

      if (activeResponse['status'] == 'success' && activeResponse['conversation'] != null) {
        print('🔵 [ChatService] 找到活躍對話會話: ${activeResponse['conversation']}');
        return {
          'success': true,
          'conversation': activeResponse['conversation'],
        };
      }

      // 如果沒有活躍的對話會話，創建新的對話會話
      print('🔵 [ChatService] 沒有活躍對話會話，開始創建新會話...');
      final createResponse = await _makeRequest(
        'POST',
        'driver-customer/conversations/create/',
        data: {
          'case_id': caseId,
          if (driverId != null) 'driver_id': driverId,
          if (customerId != null) 'customer_id': customerId,
        },
      );

      print('🔵 [ChatService] 創建對話會話響應: $createResponse');

      if (createResponse['status'] == 'success') {
        print('🔵 [ChatService] 成功創建對話會話: ${createResponse['conversation']}');
        return {
          'success': true,
          'conversation': createResponse['conversation'],
        };
      }

      print('🔵 [ChatService] 創建對話會話失敗: ${createResponse['message']}');
      return {
        'success': false,
        'message': createResponse['message'] ?? '創建對話會話失敗',
      };
    } catch (e, stackTrace) {
      print('🔴 [ChatService] 創建對話會話錯誤: $e');
      print('🔴 [ChatService] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': '創建對話會話失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    }
  }

  // 獲取司機乘客消息
  Future<Map<String, dynamic>> getMessages({
    required int caseId,
    int? conversationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _makeRequest(
        'GET',
        'driver-customer-messages/',
        params: {
          'case_id': caseId,
          if (conversationId != null) 'conversation_id': conversationId,
          'view_type': 'customer',
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response['status'] == 'success') {
        return {
          'success': true,
          'messages': response['messages'] ?? [],
          'pagination': response['pagination'] ?? {},
          'conversation_id': response['conversation_id'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? '獲取消息失敗',
        'messages': [],
        'pagination': {},
      };
    } catch (e) {
      print('獲取消息錯誤: $e');
      return {
        'success': false,
        'message': '獲取消息失敗，請檢查網絡連接',
        'messages': [],
        'pagination': {},
        'error': e.toString(),
      };
    }
  }

  // 發送消息
  Future<Map<String, dynamic>> sendMessage({
    required int caseId,
    required String content,
    int? conversationId,
    int? driverId,
    int? customerId,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        'driver-customer-messages/create/',
        data: {
          'case_id': caseId,
          if (conversationId != null) 'conversation_id': conversationId,
          if (driverId != null) 'driver_id': driverId,
          if (customerId != null) 'customer_id': customerId,
          'content': content,
          'sender_type': 'customer',
        },
      );

      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'] ?? '發送成功',
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? '發送消息失敗',
      };
    } catch (e) {
      print('發送消息錯誤: $e');
      return {
        'success': false,
        'message': '發送消息失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    }
  }

  // 通用請求方法
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String path, {
    Map<String, dynamic>? params,
    dynamic data,
  }) async {
    try {
      final fullUrl = '$_customerServiceBaseUrl$path';
      print('🔵 [ChatService] 發送請求 - Method: $method, URL: $fullUrl');
      print('🔵 [ChatService] Params: $params');
      print('🔵 [ChatService] Data: $data');
      
      final dio = Dio(BaseOptions(
        baseUrl: _customerServiceBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': _apiKey,
        },
      ));

      Response response;
      if (method == 'GET') {
        response = await dio.get(path, queryParameters: params);
      } else if (method == 'POST') {
        response = await dio.post(path, data: data, queryParameters: params);
      } else {
        throw Exception('Unsupported method: $method');
      }

      print('🔵 [ChatService] 響應狀態碼: ${response.statusCode}');
      print('🔵 [ChatService] 響應數據: ${response.data}');
      return response.data;
    } catch (e, stackTrace) {
      // 檢查是否是 DioException 且包含有效的業務邏輯響應
      if (e is DioException && e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        // 如果是 404 或其他 4xx 錯誤，但響應數據包含有效的 JSON（有 status 字段）
        // 說明這是業務邏輯響應，不是真正的錯誤
        if (statusCode != null && 
            statusCode >= 400 && 
            statusCode < 500 && 
            responseData is Map<String, dynamic> &&
            responseData.containsKey('status')) {
          print('🔵 [ChatService] 業務邏輯響應（狀態碼: $statusCode）: $responseData');
          return responseData;
        }
      }
      
      // 真正的錯誤才記錄並拋出
      print('🔴 [ChatService] API請求錯誤: $e');
      if (e is DioException) {
        print('🔴 [ChatService] DioException詳情:');
        print('🔴 [ChatService]   - Status Code: ${e.response?.statusCode}');
        print('🔴 [ChatService]   - Response Data: ${e.response?.data}');
        print('🔴 [ChatService]   - Request Path: ${e.requestOptions.path}');
        print('🔴 [ChatService]   - Request Data: ${e.requestOptions.data}');
        print('🔴 [ChatService]   - Request Params: ${e.requestOptions.queryParameters}');
      }
      print('🔴 [ChatService] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

