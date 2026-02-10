import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/bottom_navBar.dart';
import '../activity/activity_view.dart';
import '../friends/friends_view.dart';
import '../groups/groups_view.dart';
import '../profile/profile_view.dart';
import 'nav_controller.dart';

class NavigationView extends StatelessWidget {
  NavigationView({super.key});

  final NavigationController c = Get.put(NavigationController());

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
          body: pages[c.currentIndex.value],
          bottomNavigationBar: BottomNavBar(),
        ));
  }
}
