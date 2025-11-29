import 'dart:async';
import '../models/ride_record.dart';
import '../models/driver.dart';
import 'api_service.dart';

class RideService {
  final ApiService _api = ApiService();
  Timer? _trackingTimer;

  // 一键叫车
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
        'on_lat': onLat,
        'on_lng': onLng,
        'on_address': onAddress,
        if (offLat != null) 'off_lat': offLat,
        if (offLng != null) 'off_lng': offLng,
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
        'message': response.data['message'] ?? '叫车失败',
      };
    } catch (e) {
      print('叫车错误: $e');
      return {
        'success': false,
        'message': '叫车失败，请检查网络连接',
        'error': e.toString(),
      };
    }
  }

  // 追踪订单（单次）
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
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '追踪订单失败',
      };
    } catch (e) {
      print('追踪订单错误: $e');
      return {
        'success': false,
        'message': '追踪订单失败',
        'error': e.toString(),
      };
    }
  }

  // 开始持续追踪（每3秒）
  void startTracking(int caseId, Function(Map<String, dynamic>) onUpdate) {
    stopTracking(); // 先停止之前的追踪

    _trackingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        try {
          final result = await trackCase(caseId);
          onUpdate(result);

          // 如果订单完成或取消，停止追踪
          if (result['success'] == true) {
            final state = result['case_state'];
            if (state == 'finished' || state == 'canceled') {
              stopTracking();
            }
          }
        } catch (e) {
          print('追踪失败: $e');
        }
      },
    );
  }

  // 停止追踪
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  // 取消订单
  Future<Map<String, dynamic>> cancelCase(int caseId, {String? reason}) async {
    try {
      final response = await _api.post('case/$caseId/cancel/', data: {
        if (reason != null) 'reason': reason,
      });

      if (response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? '订单已取消',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? '取消订单失败',
      };
    } catch (e) {
      print('取消订单错误: $e');
      return {
        'success': false,
        'message': '取消订单失败',
        'error': e.toString(),
      };
    }
  }

  // 获取历史记录
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
        'message': response.data['message'] ?? '获取历史记录失败',
        'cases': <RideRecord>[],
      };
    } catch (e) {
      print('获取历史记录错误: $e');
      return {
        'success': false,
        'message': '获取历史记录失败',
        'cases': <RideRecord>[],
        'error': e.toString(),
      };
    }
  }

  // 获取单个订单详情
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
        'message': response.data['message'] ?? '获取订单详情失败',
      };
    } catch (e) {
      print('获取订单详情错误: $e');
      return {
        'success': false,
        'message': '获取订单详情失败',
        'error': e.toString(),
      };
    }
  }

  // 清理资源
  void dispose() {
    stopTracking();
  }
}

