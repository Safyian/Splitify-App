import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'Models/group_balances_model.dart';
import 'Models/group_expenses_model.dart';
import 'Models/group_members_model.dart';
import 'Models/group_summary_model.dart';

class GroupService {
  final Dio _dio = ApiClient().dio;

  Future<List<GroupSummary>> getSummary() async {
    final res = await _dio.get("/groups/summary");
    String json = jsonEncode(res.data);
    final groupSummary = groupSummaryFromJson(json);
    return groupSummary;
  }

  Future<GroupExpenses> getExpenses({
    required String groupId,
    int page = 1,
  }) async {
    final res = await _dio.get(
      '/groups/$groupId/expenses',
      queryParameters: {'page': page, 'limit': 25},
    );
    return groupExpensesFromJson(jsonEncode(res.data));
  }

  Future<void> settleGroup({
    required String groupId,
    required String toUserId,
    required double amount,
  }) async {
    await _dio.post(
      '/groups/$groupId/settle',
      data: {
        "to": toUserId,
        "amount": amount,
      },
    );
  }

  Future<GroupMembersModel> getGroupMembers({required String groupId}) async {
    final result = await _dio.get("/groups/$groupId/members");
    String json = jsonEncode(result.data);
    final groupMembersModel = groupMembersModelFromJson(json);
    return groupMembersModel;
  }

  Future<GroupBalancesModel> getGroupBalances({required String groupId}) async {
    try {
      final response = await _dio.get('/groups/$groupId/balances');
      return GroupBalancesModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load balances';
      throw Exception(message);
    }
  }

  // ── NEW: Settings ────────────────────────────────────────────────────────────

  Future<Member> addMember({
    required String groupId,
    required String email,
  }) async {
    try {
      final res = await _dio.post(
        '/groups/$groupId/members',
        data: {"email": email},
      );
      return _parseMemberResponse(res.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add member';
      throw Exception(message);
    }
  }

  Future<Member> addMemberById({
    required String groupId,
    required String userId,
  }) async {
    try {
      final res = await _dio.post(
        '/groups/$groupId/members',
        data: {"userId": userId},
      );
      return _parseMemberResponse(res.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add member';
      throw Exception(message);
    }
  }

  Future<Member> addMemberByContact({
    required String groupId,
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final res = await _dio.post(
        '/groups/$groupId/members',
        data: {
          "name": name,
          if (email != null) "email": email,
          if (phone != null) "phone": phone,
        },
      );
      return _parseMemberResponse(res.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add member';
      throw Exception(message);
    }
  }

  static Member _parseMemberResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Member.fromJson(data);
    }
    throw Exception('Unexpected member response shape: $data');
  }

  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await _dio.delete('/groups/$groupId/members/$memberId');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to remove member';
      throw Exception(message);
    }
  }

  Future<void> renameGroup({
    required String groupId,
    required String name,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/name',
        data: {"name": name},
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to rename group';
      throw Exception(message);
    }
  }

  Future<void> updateEmoji({
    required String groupId,
    required String emoji,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/emoji',
        data: {"emoji": emoji},
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update emoji';
      throw Exception(message);
    }
  }

  Future<void> updateDefaultSplitType({
    required String groupId,
    required String splitType,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/settings/split-type',
        data: {"defaultSplitType": splitType},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to update split type';
      throw Exception(message);
    }
  }

  Future<void> updateBalanceMode({
    required String groupId,
    required String balanceMode,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/settings/balance-mode',
        data: {'balanceMode': balanceMode},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to update balance mode';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> createGroup({required String name}) async {
    try {
      final res = await _dio.post('/groups/new', data: {"name": name});
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to create group';
      throw Exception(message);
    }
  }

  Future<void> leaveGroup({required String groupId}) async {
    try {
      await _dio.post('/groups/$groupId/leave');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to leave group';
      throw Exception(message);
    }
  }

  Future<void> deleteGroup({required String groupId}) async {
    try {
      await _dio.delete('/groups/$groupId');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to delete group';
      throw Exception(message);
    }
  }
}
