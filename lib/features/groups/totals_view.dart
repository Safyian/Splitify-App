import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/core/theme/app_themes.dart';
import 'package:splitify/features/expenses/chart_helpers.dart';
import 'package:splitify/features/profile/profile_controller.dart';

import 'groups_controller.dart';

class TotalsView extends StatelessWidget {
  TotalsView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final expenses = groupCtrl.groupExpenses.value.expenses ?? [];
    final totals = ChartHelpers.memberTotals(expenses);
    final myId = profileCtrl.user.value.user?.id ?? '';

    // Group overall total
    final groupTotal = totals.fold(0.0, (sum, m) => sum + m.totalPaid);

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: Text("Totals", style: AppTheme.headingText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Group total card ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("Group Total Spent", style: AppTheme.normalText),
                  const SizedBox(height: 4),
                  Text(
                    "\$${groupTotal.toStringAsFixed(2)}",
                    style: AppTheme.headingText.copyWith(
                      color: Constants.activeColor,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${expenses.where((e) => e.description != 'Settlement').length} expenses",
                    style: AppTheme.normalText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Per member breakdown ───────────────────────
            Text("Per Member Breakdown", style: AppTheme.subHeadingText),
            const SizedBox(height: 8),

            ...totals.map((member) {
              final isMe = member.userId == myId;
              final name = isMe ? "You" : member.name;
              final isPositive = member.net >= 0;
              final paidPct =
                  groupTotal > 0 ? member.totalPaid / groupTotal : 0.0;

              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Constants.bgColorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isMe
                      ? Border.all(color: Constants.activeColor, width: 1.5)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + net ──────────────────────────
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Constants.activeColor.withAlpha(25),
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              color: Constants.activeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(name, style: AppTheme.subHeadingText),
                        ),
                        // Net badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.net == 0
                                ? Colors.grey.withOpacity(0.15)
                                : isPositive
                                    ? Constants.activeColor.withAlpha(25)
                                    : Constants.redColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            member.net == 0
                                ? "Settled"
                                : "${isPositive ? '+' : ''}\$${member.net.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: member.net == 0
                                  ? Colors.grey
                                  : isPositive
                                      ? Constants.activeColor
                                      : Constants.redColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Paid vs Share row ───────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatColumn(
                            label: "Paid",
                            value: "\$${member.totalPaid.toStringAsFixed(2)}",
                            color: Constants.activeColor,
                          ),
                        ),
                        Expanded(
                          child: _StatColumn(
                            label: "Share",
                            value: "\$${member.totalShare.toStringAsFixed(2)}",
                            color: Constants.redColor,
                          ),
                        ),
                        Expanded(
                          child: _StatColumn(
                            label: "% of Group",
                            value: "${(paidPct * 100).toStringAsFixed(1)}%",
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Progress bar showing % of group spending ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: paidPct,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Constants.activeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.subHeadingText.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.normalText),
      ],
    );
  }
}
