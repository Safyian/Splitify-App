import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/bottom_navBar.dart';
import '../activity/activity_controller.dart';
import '../activity/activity_view.dart';
import '../friends/friends_view.dart';
import '../groups/groups_controller.dart';
import '../groups/groups_view.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_view.dart';
import 'nav_controller.dart';

class NavigationView extends StatelessWidget {
  NavigationView({super.key});

  final navigationCtrl = Get.put(NavigationController());
  final groupCtrl = Get.put(GroupsController());
  final profileCtrl = Get.put(ProfileController());
  final actCrel = Get.put(ActivityController());
  final pages = [
    FriendsScreen(),
    GroupsScreen(),
    SizedBox(),
    ActivityScreen(),
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
