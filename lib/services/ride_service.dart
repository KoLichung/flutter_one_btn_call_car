import 'dart:async';
import 'package:dio/dio.dart';
import '../models/ride_record.dart';
import '../models/driver.dart';
import 'api_service.dart';

class RideService {
  final ApiService _api = ApiService();
  Timer? _trackingTimer;

  // 格式化經緯度，限制為6位小數（精確到約0.11米）
  // 服務器要求總位數不超過9位，格式如：25.123456 或 121.123456
  double _formatCoordinate(double coordinate) {
    return double.parse(coordinate.toStringAsFixed(6));
  }

  // 一鍵叫車
  Future<Map<String, dynamic>> callCar({
    required double onLat,
    required double onLng,
    required String onAddress,
    double? offLat,
    double? offLng,
    String? offAddress,
    String? memo,
    String? customerPhone,
    String? customerName,
  }) async {
    try {
      final response = await _api.post('call-car/', data: {
        'on_lat': _formatCoordinate(onLat),
        'on_lng': _formatCoordinate(onLng),
        'on_address': onAddress,
        if (offLat != null) 'off_lat': _formatCoordinate(offLat),
        if (offLng != null) 'off_lng': _formatCoordinate(offLng),
        if (offAddress != null) 'off_address': offAddress,
        if (memo != null) 'memo': memo,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (customerName != null) 'customer_name': customerName,
      });

      if (response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'],
          'case_id': response.data['case']['id'],
          'case_number': response.data['case']['case_number'],
          'case_state': response.data['case']['case_state'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '叫車失敗',
      };
    } catch (e) {
      print('叫車錯誤: $e');
      return {
        'success': false,
        'message': '叫車失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    }
  }

  // 追蹤訂單（單次）
  Future<Map<String, dynamic>> trackCase(int caseId) async {
    try {
      final response = await _api.get('case/$caseId/tracking/');

      if (response.data['status'] == 'success') {
        Driver? driver;
        if (response.data['driver'] != null) {
          driver = Driver.fromJson(response.data['driver']);
        }

        return {
          'success': true,
          'case_id': response.data['case_id'],
          'case_number': response.data['case_number'],
          'case_state': response.data['case_state'],
          'on_lat': response.data['on_lat'],
          'on_lng': response.data['on_lng'],
          'on_address': response.data['on_address'],
          'create_time': response.data['create_time'],
          'driver': driver,
          'driver_lat': response.data['driver_lat'],
          'driver_lng': response.data['driver_lng'],
          'case_money': response.data['case_money'],
          'off_time': response.data['off_time'],
          'unread_driver_messages_count': response.data['unread_driver_messages_count'] ?? 0,
          'user_expect_second': response.data['user_expect_second'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '追蹤訂單失敗',
      };
    } catch (e) {
      print('追蹤訂單錯誤: $e');
      return {
        'success': false,
        'message': '追蹤訂單失敗',
        'error': e.toString(),
      };
    }
  }

  // 開始持續追蹤（每3秒）
  void startTracking(int caseId, Function(Map<String, dynamic>) onUpdate) {
    stopTracking(); // 先停止之前的追蹤

    _trackingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        try {
          final result = await trackCase(caseId);
          onUpdate(result);

          // 如果訂單完成或取消，停止追蹤
          if (result['success'] == true) {
            final state = result['case_state'];
            if (state == 'finished' || state == 'canceled') {
              stopTracking();
            }
          }
        } catch (e) {
          print('追蹤失敗: $e');
        }
      },
    );
  }

  // 停止追蹤
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  // 取消訂單
  Future<Map<String, dynamic>> cancelCase(int caseId, {String? reason}) async {
    try {
      final response = await _api.post('case/$caseId/cancel/', data: {
        if (reason != null) 'reason': reason,
      });

      if (response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? '訂單已取消',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '取消訂單失敗',
      };
    } on DioException catch (e) {
      print('取消訂單錯誤: $e');
      
      // 處理服務器返回的錯誤消息（例如訂單狀態不允許取消）
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': data['message'] ?? '取消訂單失敗',
        };
      }
      
      return {
        'success': false,
        'message': '取消訂單失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    } catch (e) {
      print('取消訂單錯誤: $e');
      return {
        'success': false,
        'message': '取消訂單失敗',
        'error': e.toString(),
      };
    }
  }

  // 獲取歷史記錄
  Future<Map<String, dynamic>> getHistory({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.get('cases/history/', params: {
        'page': page,
        'page_size': pageSize,
      });

      if (response.data['status'] == 'success') {
        final casesList = response.data['cases'] as List;
        final cases = casesList.map((json) => RideRecord.fromJson(json)).toList();

        return {
          'success': true,
          'cases': cases,
          'total_count': response.data['total_count'],
          'page': response.data['page'],
          'page_size': response.data['page_size'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '獲取歷史記錄失敗',
        'cases': <RideRecord>[],
      };
    } catch (e) {
      print('獲取歷史記錄錯誤: $e');
      return {
        'success': false,
        'message': '獲取歷史記錄失敗',
        'cases': <RideRecord>[],
        'error': e.toString(),
      };
    }
  }

  // 獲取單個訂單詳情
  Future<Map<String, dynamic>> getCaseDetail(int caseId) async {
    try {
      final response = await _api.get('case/$caseId/');

      if (response.data['status'] == 'success') {
        final rideRecord = RideRecord.fromJson(response.data['case']);
        return {
          'success': true,
          'case': rideRecord,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '獲取訂單詳情失敗',
      };
    } catch (e) {
      print('獲取訂單詳情錯誤: $e');
      return {
        'success': false,
        'message': '獲取訂單詳情失敗',
        'error': e.toString(),
      };
    }
  }

  // 將司機加入黑名單
  Future<Map<String, dynamic>> blacklistDriver(int caseId) async {
    try {
      final response = await _api.post('blacklist_driver/', data: {
        'case_id': caseId,
      });

      if (response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? '已加入黑名單',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '加入黑名單失敗',
      };
    } on DioException catch (e) {
      print('加入黑名單錯誤: $e');
      
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': data['message'] ?? '加入黑名單失敗',
        };
      }
      
      return {
        'success': false,
        'message': '加入黑名單失敗，請檢查網絡連接',
        'error': e.toString(),
      };
    } catch (e) {
      print('加入黑名單錯誤: $e');
      return {
        'success': false,
        'message': '加入黑名單失敗',
        'error': e.toString(),
      };
    }
  }

  // 清理資源
  void dispose() {
    stopTracking();
  }
}
