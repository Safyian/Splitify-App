import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/core/theme/app_themes.dart';
import 'package:splitify/features/groups/expenses_tab_view.dart';

class TabsView extends StatefulWidget {
  const TabsView({super.key});

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: Container(
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            // ******** TabBar without using appBar and Scaffold ********
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(0);
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? Constants.activeColor
                            : Constants.chipColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("Settle Up",
                        style: AppTheme.subHeadingText.copyWith(
                          color: Constants.textLight,
                        )),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(1);
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Constants.activeColor
                            : Constants.chipColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("Charts",
                        style: AppTheme.subHeadingText.copyWith(
                          color: Constants.textLight,
                        )),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(2);
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: _selectedIndex == 2
                            ? Constants.activeColor
                            : Constants.chipColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("Balances",
                        style: AppTheme.subHeadingText.copyWith(
                          color: Constants.textLight,
                        )),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(3);
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: _selectedIndex == 3
                            ? Constants.activeColor
                            : Constants.chipColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("Totals",
                        style: AppTheme.subHeadingText.copyWith(
                          color: Constants.textLight,
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
            Expanded(
              child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    ExpensesTabView(),
                    ExpensesTabView(),
                    ExpensesTabView(),
                    ExpensesTabView(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
