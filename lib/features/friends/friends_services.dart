import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'friends_model.dart';

class FriendService {
  final Dio _dio = ApiClient().dio;

  Future<List<Friend>> getFriends() async {
    try {
      final res = await _dio.get('/friends');
      final String jsonStr = jsonEncode(res.data);
      return friendListFromJson(jsonStr);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load friends';
      throw Exception(message);
    }
  }

  Future<void> addFriend({required String email}) async {
    try {
      await _dio.post('/friends', data: {"email": email});
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add friend';
      throw Exception(message);
    }
  }

  Future<void> removeFriend({required String friendId}) async {
    try {
      await _dio.delete('/friends/$friendId');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to remove friend';
      throw Exception(message);
    }
  }
}
