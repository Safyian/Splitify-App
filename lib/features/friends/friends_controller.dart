import 'package:get/get.dart';
import 'package:splitify/core/utils/cache_manager.dart';

import '../../shared/widgets/alert_widgets.dart';
import '../groups/groups_controller.dart';
import 'friends_model.dart';
import 'friends_services.dart';

class FriendsController extends GetxController {
  final FriendService _service = FriendService();
  final _cache = CacheManager();

  RxList<Friend> friends = <Friend>[].obs;
  RxBool isLoading = false.obs;

  double get overallNet {
    return friends.fold(0.0, (sum, f) => sum + f.balance.net);
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchFriends({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache.isFresh(CacheKeys.friends) &&
        friends.isNotEmpty) return;
    try {
      isLoading.value = true;
      friends.value = await _service.getFriends();
      _cache.markFetched(CacheKeys.friends);
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<void> addFriend({required String email}) async {
    try {
      await _service.addFriend(email: email);
      _cache.invalidate(CacheKeys.friends);
      await fetchFriends(forceRefresh: true);
      AlertWidgets.showSnackBar(message: 'Friend added successfully');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  Future<void> removeFriend({required String friendId}) async {
    final idx = friends.indexWhere((f) => f.id == friendId);
    if (idx == -1) return;

    final original = friends[idx];
    // Optimistic update
    if (original.isGroupContact) {
      friends[idx] = Friend(
        id: original.id,
        name: original.name,
        email: original.email,
        isExplicitFriend: false,
        isGroupContact: true,
        balance: original.balance,
      );
    } else {
      friends.removeAt(idx);
    }

    try {
      await _service.removeFriend(friendId: friendId);
      _cache.invalidate(CacheKeys.friends);
      AlertWidgets.showSnackBar(message: 'Friend removed');
    } catch (e) {
      // Rollback
      await fetchFriends(forceRefresh: true);
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Shared groups ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> sharedGroupsWithFriend(String friendId) {
    final groupsCtrl = Get.find<GroupsController>();
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < groupsCtrl.summaries.length; i++) {
      final summary = groupsCtrl.summaries[i];
      final previewEntry =
          summary.preview.where((p) => p.userId == friendId).firstOrNull;
      if (previewEntry != null) {
        result.add({
          'index': i,
          'name': summary.name,
          'emoji': summary.emoji,
          'groupId': summary.id,
          'status': summary.balance.status,
          'preview': previewEntry,
        });
      }
    }
    return result;
  }

  @override
  void onInit() {
    fetchFriends();
    super.onInit();
  }
}
