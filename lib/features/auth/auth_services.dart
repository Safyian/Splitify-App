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
}
