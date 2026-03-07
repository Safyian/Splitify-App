import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'expense_payload_model.dart';

class ExpenseService {
  final Dio _dio = ApiClient().dio;

  Future<void> addExpense({
    required String groupId,
    required AddExpenseRequest request,
  }) async {
    try {
      await _dio.post(
        '/groups/$groupId/expenses',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to add expense';
      throw Exception(message);
    }
  }

  Future<void> updateExpense({
    required String groupId,
    required String expenseId,
    required AddExpenseRequest request,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/expenses/$expenseId',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update expense';
      throw Exception(message);
    }
  }

  Future<void> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      await _dio.delete('/groups/$groupId/expenses/$expenseId');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to delete expense';
      throw Exception(message);
    }
  }

  Future<void> updateSettlement({
    required String groupId,
    required String expenseId,
    required double amount,
  }) async {
    try {
      await _dio.patch(
        '/groups/$groupId/settlements/$expenseId',
        data: {'amount': amount},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to update settlement';
      throw Exception(message);
    }
  }
}
