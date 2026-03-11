import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/widgets/group_card.dart';
import 'groups_controller.dart';

class GroupsScreen extends StatelessWidget {
  GroupsScreen({super.key});

  final groupCtrl = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Groups', style: AppTheme.headingText),
        actions: [
          SvgPicture.asset(Constants.searchLogo, width: 22, height: 22),
          const SizedBox(width: 16),
          SvgPicture.asset(Constants.teamsLogo, width: 22, height: 22),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
        elevation: 0,
      ),
      body: Obx(() {
        final summaries = groupCtrl.summaries;

        // ── Overall balance calculation ──────────────────────
        double totalOwed = 0;
        double totalOwe = 0;
        for (final s in summaries) {
          final net = s.balance.net;
          if (net > 0) totalOwed += net;
          if (net < 0) totalOwe += net.abs();
        }
        final netOverall = totalOwed - totalOwe;
        final isPositive = netOverall >= 0;

        return CustomScrollView(
          slivers: [
            // ── Overall Balance Banner ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPositive
                          ? [
                              Constants.activeColor.withOpacity(0.15),
                              Constants.activeColor.withOpacity(0.05),
                            ]
                          : [
                              Constants.redColor.withOpacity(0.15),
                              Constants.redColor.withOpacity(0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPositive
                          ? Constants.activeColor.withAlpha(50)
                          : Constants.redColor.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? Constants.activeColor.withAlpha(40)
                              : Constants.redColor.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: isPositive
                              ? Constants.activeColor
                              : Constants.redColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overall balance",
                              style: AppTheme.normalText
                                  .copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      isPositive ? "You are owed " : "You owe ",
                                  style: AppTheme.subHeadingText,
                                ),
                                TextSpan(
                                  text:
                                      "\$${netOverall.abs().toStringAsFixed(2)}",
                                  style: AppTheme.subHeadingText.copyWith(
                                    color: isPositive
                                        ? Constants.activeColor
                                        : Constants.redColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),

                      // ── Owed / Owe summary ───────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _MiniStat(
                            label: "owed",
                            value: "\$${totalOwed.toStringAsFixed(2)}",
                            color: Constants.activeColor,
                          ),
                          const SizedBox(height: 4),
                          _MiniStat(
                            label: "owe",
                            value: "\$${totalOwe.toStringAsFixed(2)}",
                            color: Constants.redColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section header ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Text(
                      "${summaries.length} Groups",
                      style: AppTheme.subHeadingText,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        Constants.filterLineLogo,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Group Cards ────────────────────────────────────
            summaries.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_outlined,
                              size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text("No groups yet", style: AppTheme.subHeadingText),
                          const SizedBox(height: 4),
                          Text(
                            "Create a group to start splitting",
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GroupCard(index: index),
                        ),
                        childCount: summaries.length,
                      ),
                    ),
                  ),

            // ── Create group button ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: GestureDetector(
                  onTap: () {}, // hook up create group
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Constants.activeColor.withAlpha(120),
                      ),
                      color: Constants.activeColor.withAlpha(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Constants.activeColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Start a new group',
                          style: AppTheme.subHeadingText.copyWith(
                            color: Constants.activeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.normalText.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.normalText.copyWith(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
