import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future login(String email, String password) async {
    final res = await _dio.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    // print(res);
    return res.data;
  }

  Future register(String name, String email, String password) async {
    final res = await _dio.post(
      "/auth/register",
      data: {
        "name": name,
        "email": email,
        "password": password,
      },
    );

    return res.data;
  }

  Future resendVerification(String email) async {
    final res = await _dio.post(
      "/auth/resend-verification",
      data: {"email": email},
    );
    return res.data;
  }

  Future forgotPassword(String email) async {
    final res = await _dio.post(
      "/auth/forgot-password",
      data: {"email": email},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> registerWithPhone({
    required String name,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'phone': phone,
      'password': password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> sendPhoneOtp({
    required String phone,
  }) async {
    final res = await _dio.post('/auth/send-phone-otp', data: {
      'phone': phone,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await _dio.post('/auth/verify-phone-otp', data: {
      'phone': phone,
      'otp': otp,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login-phone', data: {
      'phone': phone,
      'password': password,
    });
    return res.data;
  }
}
