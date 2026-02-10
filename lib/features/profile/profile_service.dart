import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:splitify/features/profile/user_model.dart';

import '../../core/api/api_client.dart';

class ProfileService {
  final Dio _dio = ApiClient().dio;

  Future<UserModel> getUser() async {
    final res = await _dio.get("/auth/me");
    String jsonString = jsonEncode(res.data);
    final userModel = userModelFromJson(jsonString);
    return userModel;
  }
}
