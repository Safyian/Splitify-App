// lib/features/navigation/nav_controller.dart

import 'package:get/get.dart';

import '../activity/activity_controller.dart';
import '../friends/friends_controller.dart';
import '../groups/Controllers/groups_controller.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    switch (index) {
      case 0: // Friends
        if (Get.isRegistered<FriendsController>(tag: 'friends')) {
          Get.find<FriendsController>(tag: 'friends').fetchFriends();
        }
        break;
      case 1: // Groups
        if (Get.isRegistered<GroupsController>()) {
          Get.find<GroupsController>().fetchSummary();
        }
        break;
      case 3: // Activity
        if (Get.isRegistered<ActivityController>()) {
          Get.find<ActivityController>().fetchActivity();
        }
        break;
      default:
        break;
    }
  }
}
