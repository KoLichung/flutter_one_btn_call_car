import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;
  final String baseUrl = 'https://ai-taxi-api-5koy2twboa-de.a.run.app/api/one-btn-call-car/';
  final StorageService _storage = StorageService();

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Token 认证拦截器 - 自动添加 Authorization header
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 从本地存储加载 token
        final token = await _storage.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Token $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        if (error.response?.statusCode == 401) {
          print('Unauthorized - Token 无效或已过期，需要重新登录');
        }
        return handler.next(error);
      },
    ));

    // 日志拦截器（开发环境）
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ));
  }

  // 通用 GET 请求
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await dio.get(path, queryParameters: params);
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  // 通用 POST 请求
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      print('POST Error: $e');
      rethrow;
    }
  }

  // 通用 PUT 请求
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } catch (e) {
      print('PUT Error: $e');
      rethrow;
    }
  }

  // 通用 DELETE 请求
  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }
}

