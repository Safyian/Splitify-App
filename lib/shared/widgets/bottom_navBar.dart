import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../features/navigation/nav_controller.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final NavigationController controller = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
          // bottom nav style
          type: BottomNavigationBarType.fixed,
          backgroundColor: Constants.bgColor,
          elevation: 1.0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: AppTheme.normalText,
          unselectedLabelStyle: AppTheme.normalText,
          selectedItemColor: Constants.activeColor,
          //
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            if (index == 2) {
              // Get.to(
              //   () => AddExpenseView(),
              //   transition: Transition.downToUp,
              //   duration: const Duration(milliseconds: 300),
              // );
            } else {
              controller.changeTab(index);
            }
          },

          items: [
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
                color: Colors.grey[600],
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
                color: Colors.grey[600],
              ),
              activeIcon: SvgPicture.asset(
                Constants.userLogo,
                width: 26,
                height: 26,
                color: Constants.activeColor,
              ),
              label: 'Profile',
            ),
          ],
        ));
  }
}
