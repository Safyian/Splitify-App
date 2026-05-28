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

  Future<void> addFriendById({required String userId}) async {
    try {
      await _dio.post('/friends/add-by-id', data: {"userId": userId});
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add friend';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> checkContacts({
    required List<String> emailHashes,
    required List<String> phoneHashes,
  }) async {
    try {
      final res = await _dio.post('/users/check-contacts', data: {
        'emailHashes': emailHashes,
        'phoneHashes': phoneHashes,
      });
      return res.data['registered'] as List;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to check contacts';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> checkSingleContact({
    String? phoneHash,
    String? emailHash,
  }) async {
    try {
      final res = await _dio.post('/users/check-contacts', data: {
        'emailHashes': emailHash != null ? [emailHash] : [],
        'phoneHashes': phoneHash != null ? [phoneHash] : [],
      });
      final registered = (res.data['registered'] as List);
      return {
        'isRegistered': registered.isNotEmpty,
        'user': registered.isNotEmpty ? registered.first : null,
      };
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to check contact';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> inviteFriend({
    required String name,
    String? phone,
    String? email,
  }) async {
    try {
      final res = await _dio.post('/friends/invite', data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to invite friend';
      throw Exception(message);
    }
  }
}
