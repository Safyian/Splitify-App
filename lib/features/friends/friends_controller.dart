import 'package:get/get.dart';

import '../../shared/widgets/alert_widgets.dart';
import '../groups/groups_controller.dart';
import 'friends_model.dart';
import 'friends_services.dart';

class FriendsController extends GetxController {
  final FriendService _service = FriendService();

  RxList<Friend> friends = <Friend>[].obs;
  RxBool isLoading = false.obs;

  // ── Computed: overall net balance across all friends ──────────────────────
  double get overallNet {
    return friends.fold(0.0, (sum, f) => sum + f.balance.net);
  }

  Future<void> fetchFriends() async {
    try {
      isLoading.value = true;
      friends.value = await _service.getFriends();
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFriend({required String email}) async {
    try {
      await _service.addFriend(email: email);
      await fetchFriends();
      AlertWidgets.showSnackBar(message: 'Friend added successfully');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> removeFriend({required String friendId}) async {
    // Optimistic update — if also a group contact, keep in list as contact only
    final idx = friends.indexWhere((f) => f.id == friendId);
    if (idx == -1) return;

    final original = friends[idx];
    if (original.isGroupContact) {
      // Downgrade to contact only, stays visible in All & Contacts
      friends[idx] = Friend(
        id: original.id,
        name: original.name,
        email: original.email,
        isExplicitFriend: false,
        isGroupContact: true,
        balance: original.balance,
      );
    } else {
      // Pure explicit friend with no group relation — remove entirely
      friends.removeAt(idx);
    }

    try {
      await _service.removeFriend(friendId: friendId);
      AlertWidgets.showSnackBar(message: 'Friend removed');
    } catch (e) {
      // Rollback on failure
      await fetchFriends();
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Get shared groups between current user and a friend ───────────────────
  // Returns list of {index, name, emoji, groupId, preview} for groups they share
  List<Map<String, dynamic>> sharedGroupsWithFriend(String friendId) {
    final groupsCtrl = Get.find<GroupsController>();
    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < groupsCtrl.summaries.length; i++) {
      final summary = groupsCtrl.summaries[i];
      // Find the preview entry for this specific friend
      final previewEntry =
          summary.preview.where((p) => p.userId == friendId).firstOrNull;
      if (previewEntry != null) {
        result.add({
          'index': i,
          'name': summary.name,
          'emoji': summary.emoji,
          'groupId': summary.id,
          'status': summary.balance.status,
          'preview': previewEntry, // Preview object ready for SettleAmountView
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
