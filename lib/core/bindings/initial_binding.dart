import 'package:get/get.dart';

import '../../features/activity/activity_controller.dart';
import '../../features/auth/Controllers/auth_controller.dart';
import '../../features/groups/Controllers/groups_controller.dart';
import '../../features/navigation/nav_controller.dart';
import '../../features/profile/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // App-wide controllers, created once. Not permanent:true because logout
    // explicitly Get.deletes them to clear per-user state; they're recreated
    // on next login via re-put in AuthController after sign-in (see note).
    Get.put(AuthController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(GroupsController(), permanent: true);
    Get.put(ActivityController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
  }
}

/// Recreates app-wide controllers if they were deleted (e.g. after logout).
/// Safe to call on every login — skips any that already exist.
void ensureAppControllers() {
  if (!Get.isRegistered<ProfileController>()) {
    Get.put(ProfileController(), permanent: true);
  }
  if (!Get.isRegistered<GroupsController>()) {
    Get.put(GroupsController(), permanent: true);
  }
  if (!Get.isRegistered<ActivityController>()) {
    Get.put(ActivityController(), permanent: true);
  }
  if (!Get.isRegistered<NavigationController>()) {
    Get.put(NavigationController(), permanent: true);
  }
}

// load initial data on app start
void loadInitialAppData() {
  if (Get.isRegistered<GroupsController>()) {
    Get.find<GroupsController>().fetchSummary();
  }
  if (Get.isRegistered<ActivityController>()) {
    Get.find<ActivityController>().fetchActivity();
  }
}
