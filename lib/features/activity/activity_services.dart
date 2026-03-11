import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import 'activity_model.dart';

class ActivityService {
  final Dio _dio = ApiClient().dio;

  Future<({List<ActivityModel> activities, ActivityPagination pagination})>
      getActivity({int page = 1, int limit = 30}) async {
    try {
      final res = await _dio
          .get('/activity', queryParameters: {'page': page, 'limit': limit});

      // Normalize: Dio may return data as Map or as a raw String
      Map<String, dynamic> data;
      if (res.data is String) {
        data = jsonDecode(res.data as String) as Map<String, dynamic>;
      } else {
        data = res.data as Map<String, dynamic>;
      }

      final rawList = data['activities'] as List;

      final activities = rawList.map((e) {
        // Each item may itself be a stringified JSON object
        final Map<String, dynamic> item;
        if (e is String) {
          item = jsonDecode(e) as Map<String, dynamic>;
        } else {
          item = e as Map<String, dynamic>;
        }
        return ActivityModel.fromJson(item);
      }).toList();

      final pagination = ActivityPagination.fromJson(
          data['pagination'] as Map<String, dynamic>);

      return (activities: activities, pagination: pagination);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load activity';
      throw Exception(message);
    }
  }
}
