// lib/features/navigation/nav_controller.dart

import 'package:get/get.dart';

import '../activity/activity_controller.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    // Only fetch activity if cache is stale — not on every single tap
    if (index == 3 && Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().fetchActivity();
    }
    currentIndex.value = index;
  }
}
