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
}
