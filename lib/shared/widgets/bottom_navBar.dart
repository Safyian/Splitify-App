import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/groups/group_summary_model.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../features/expenses/add_expense_controller.dart';
import '../../features/expenses/add_expense_view.dart';
import '../../features/groups/groups_controller.dart';
import '../../features/navigation/nav_controller.dart';
import 'alert_widgets.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final NavigationController controller = Get.find<NavigationController>();

  Future<void> _onAddTapped(BuildContext context) async {
    final groupCtrl = Get.find<GroupsController>();
    final groups = groupCtrl.summaries;

    if (groups.isEmpty) {
      AlertWidgets.showSnackBar(message: 'Create or join a group first.');
      return;
    }

    String? groupId;

    if (groups.length == 1) {
      groupId = groups.first.id;
    } else {
      // Show group picker bottom sheet
      groupId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _GroupPickerSheet(groups: groups),
      );
    }

    if (groupId == null) return;

    await Get.delete<AddExpenseController>(force: true);
    final expenseCtrl = Get.put(AddExpenseController());
    expenseCtrl.groupId = groupId;
    await expenseCtrl.fetchGroupMembers(groupId: groupId);

    Get.to(
      () => const AddExpenseView(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );
  }

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
              _onAddTapped(context);
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

class _GroupPickerSheet extends StatelessWidget {
  final List<GroupSummary> groups;
  const _GroupPickerSheet({required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Constants.bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add expense to...',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a group for this expense',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ...groups.map((g) => GestureDetector(
                onTap: () => Navigator.of(context).pop(g.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(g.emoji,
                          style: GoogleFonts.inter(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          g.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
