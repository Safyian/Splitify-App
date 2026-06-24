// lib/features/activity/activity_controller.dart

import 'package:get/get.dart';
import 'package:splittify/core/utils/cache_manager.dart';

import 'activity_model.dart';
import 'activity_services.dart';

typedef ActivitySection = ({String label, List<ActivityModel> items});

class ActivityController extends GetxController {
  final _service = ActivityService();
  final _cache = CacheManager();

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<ActivitySection> grouped = <ActivitySection>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxString error = ''.obs;
  int _currentPage = 1;

  // Activity feed has a shorter TTL — changes more frequently
  static const _ttl = Duration(minutes: 2);

  @override
  void onInit() {
    ever(activities, (_) => _regroup());
    super.onInit();
  }

  Future<void> fetchActivity({bool forceRefresh = false}) async {
    // Skip if cache is fresh and we already have data
    if (!forceRefresh &&
        _cache.isFresh(CacheKeys.activity, ttl: _ttl) &&
        activities.isNotEmpty) return;

    _currentPage = 1;
    error.value = '';

    // First load → show full spinner; subsequent → refresh silently
    if (activities.isEmpty) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }

    try {
      final result = await _service.getActivity(page: 1);
      activities.value = result.activities;
      hasMore.value = result.pagination.hasMore;
      _currentPage = 1;
      _cache.markFetched(CacheKeys.activity);
    } catch (e) {
      if (activities.isEmpty) {
        error.value = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    try {
      isLoadingMore.value = true;
      final nextPage = _currentPage + 1;
      final result = await _service.getActivity(page: nextPage);
      activities.addAll(result.activities);
      hasMore.value = result.pagination.hasMore;
      _currentPage = nextPage;
    } catch (e) {
      // silent
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Call this after any mutation so next tab visit gets fresh data
  void invalidate() => _cache.invalidate(CacheKeys.activity);

  void _regroup() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<ActivityModel>> map = {};

    for (final a in activities) {
      final d = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else {
        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        label = '${months[d.month]} ${d.day}';
      }
      map.putIfAbsent(label, () => []).add(a);
    }

    grouped.value =
        map.entries.map((e) => (label: e.key, items: e.value)).toList();
  }
}
