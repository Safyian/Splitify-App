import 'package:get/get.dart';

import '../activity/activity_controller.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    // Refresh activity feed whenever the user taps back to that tab
    if (index == 3 && Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().fetchActivity(refresh: true);
    }
    currentIndex.value = index;
  }
}
