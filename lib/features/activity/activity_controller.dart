import 'package:get/get.dart';

import 'activity_model.dart';
import 'activity_services.dart';

typedef ActivitySection = ({String label, List<ActivityModel> items});

class ActivityController extends GetxController {
  final _service = ActivityService();

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<ActivitySection> grouped = <ActivitySection>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxString error = ''.obs;
  int _currentPage = 1;

  @override
  void onInit() {
    // Recompute grouped whenever activities changes
    ever(activities, (_) => _regroup());
    fetchActivity();
    super.onInit();
  }

  Future<void> fetchActivity({bool refresh = false}) async {
    if (refresh) _currentPage = 1;
    error.value = '';
    try {
      isLoading.value = true;
      final result = await _service.getActivity(page: 1);
      activities.value = result.activities;
      hasMore.value = result.pagination.hasMore;
      _currentPage = 1;
    } catch (e, stack) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
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
      // ignore load-more errors silently
    } finally {
      isLoadingMore.value = false;
    }
  }

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
