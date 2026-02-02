import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:splitify/Controllers/nav_controller.dart';
import 'package:splitify/Utils/themes.dart';
import 'package:splitify/Views/Bottom%20NavScreens/activity.dart';
import 'package:splitify/Views/Bottom%20NavScreens/groups.dart';

import '../Utils/constants.dart';
import '../Views/Bottom NavScreens/friends.dart';

class BottomNaviBar extends StatefulWidget {
  const BottomNaviBar({super.key});

  @override
  State<BottomNaviBar> createState() => _BottomNaviBarState();
}

class _BottomNaviBarState extends State<BottomNaviBar> {
  int selectedIdx = 0;
  final navController = Get.put(NavController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0.0,
      //   backgroundColor: Colors.transparent,
      //   onPressed: () {
      //     // Your FAB action here
      //   },
      //   child: Padding(
      //     padding: const EdgeInsets.only(top: 16),
      //     child: SvgPicture.asset(
      //       Constants.addLogo,
      //       width: 40.w,
      //       height: 40.w,
      //     ),
      //   ),
      // ),
      backgroundColor: Constants.bgColorLight,
      bottomNavigationBar: Container(
        color: Constants.bgColorLight,
        child: Obx(() {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Constants.bgColorLight,
            elevation: 1.0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: AppTheme.normalText,
            unselectedLabelStyle: AppTheme.normalText,
            selectedItemColor: Constants.activeColor,
            currentIndex: navController.selectedIdx.value,
            onTap: (int index) {
              navController.selectedIdx.value = index;
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Constants.friendsLogo,
                  width: 26,
                  height: 26,
                  color: Colors.grey[600],
                ),
                activeIcon: SvgPicture.asset(
                  Constants.friendsLogo,
                  width: 26,
                  height: 26,
                  color: Constants.activeColor,
                ),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Constants.groupsLogo,
                  width: 26,
                  height: 26,
                  color: Colors.grey[600],
                ),
                activeIcon: SvgPicture.asset(
                  Constants.groupsLogo,
                  width: 26,
                  height: 26,
                  color: Constants.activeColor,
                ),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Constants.addLogo,
                  width: 38,
                  height: 38,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Constants.activityLogo,
                  width: 26,
                  height: 26,
                  // color: Colors.grey[600],
                ),
                activeIcon: SvgPicture.asset(
                  Constants.activityLogo,
                  width: 26,
                  height: 26,
                  color: Constants.activeColor,
                ),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Constants.userLogo,
                  width: 26,
                  height: 26,
                  // color: Colors.grey[600],
                ),
                activeIcon: SvgPicture.asset(
                  Constants.userLogo,
                  width: 26,
                  height: 26,
                  // color: Constants.activeColor,
                ),
                label: 'Profile',
              ),
            ],
          );
        }),
      ),
      // ),
      body: Obx(() {
        return IndexedStack(
          index: navController.selectedIdx.value,
          children: [
            FriendsScreen(),
            GroupsScreen(),
            ActivityScreen(),
            ActivityScreen(),
          ],
        );
      }),
    );
  }
}
