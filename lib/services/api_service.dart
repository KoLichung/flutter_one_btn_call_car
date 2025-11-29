import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;
  final String baseUrl = 'https://ai-taxi-api-5koy2twboa-de.a.run.app/api/one-btn-call-car/';

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

    // Cookie 管理（用于 Session 认证）
    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // 日志拦截器（开发环境）
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ));

    // 错误处理拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('API Error: ${error.message}');
        if (error.response?.statusCode == 401) {
          print('Unauthorized - 需要登录');
        }
        return handler.next(error);
      },
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

