import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'group_expenses_model.dart';
import 'group_summary_model.dart';

class GroupService {
  final Dio _dio = ApiClient().dio;

  // ADD THIS
  Future<List<GroupSummary>> getSummary() async {
    final res = await _dio.get("/groups/summary");
    // print("Summary = $res");
    String json = jsonEncode(res.data);
    final groupSummary = groupSummaryFromJson(json);
    return groupSummary;
  }

  Future<GroupExpenses> getExpenses({required String groupId}) async {
    final res = await _dio.get("/groups/$groupId/expenses");
    // print("Summary = $res");
    String jsonString = jsonEncode(res.data);
    final groupExpenses = groupExpensesFromJson(jsonString);
    return groupExpenses;
  }
}
