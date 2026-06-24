import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/bottom_navBar.dart';
import '../activity/activity_controller.dart';
import '../activity/activity_view.dart';
import '../friends/friends_view.dart';
import '../groups/Controllers/groups_controller.dart';
import '../groups/Views/groups_view.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_view.dart';
import 'nav_controller.dart';

class NavigationView extends StatelessWidget {
  NavigationView({super.key});

  final navigationCtrl = Get.find<NavigationController>();
  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();
  final actCtrl = Get.find<ActivityController>();
  final pages = [
    FriendsScreen(),
    GroupsScreen(),
    const SizedBox(),
    const ActivityScreen(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: pages[navigationCtrl.currentIndex.value],
          bottomNavigationBar: BottomNavBar(),
        ));
  }
}
