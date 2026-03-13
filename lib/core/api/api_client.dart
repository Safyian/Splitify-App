import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late Dio dio;

  final storage = const FlutterSecureStorage();
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: !isProduction
            ? "https://splitify-backend-production.up.railway.app"
            : "http://localhost:3000",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: "token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
      ),
    );
  }
}
