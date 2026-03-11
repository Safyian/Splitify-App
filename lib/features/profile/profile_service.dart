// lib/features/profile/profile_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'user_model.dart';

class ProfileService {
  final Dio _dio = ApiClient().dio;

  Future<UserModel> getUser() async {
    final res = await _dio.get('/auth/me');
    final userModel = userModelFromJson(jsonEncode(res.data));
    return userModel;
  }

  Future<UserModel> updateName(String name) async {
    final res = await _dio.patch('/auth/me', data: {'name': name});
    final userModel = userModelFromJson(jsonEncode(res.data));
    return userModel;
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/me');
  }
}
