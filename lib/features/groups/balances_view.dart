import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../profile/profile_controller.dart';
import 'groups_controller.dart';
import 'settlement_breakdown_sheet.dart';

class BalancesView extends StatelessWidget {
  BalancesView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final myId = profileCtrl.user.value.user?.id ?? '';
    final members = groupCtrl.groupMembers.value.members ?? [];

    final nameMap = {for (final m in members) m.id!: m.name!};

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: Text("Balances", style: AppTheme.headingText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (groupCtrl.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        final balances = groupCtrl.groupBalances.value.balances;
        final settlements = groupCtrl.groupBalances.value.settlements;
        final pairwise = groupCtrl.groupBalances.value.pairwise;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Net Balances ───────────────────────────────
              Text("Net Balances", style: AppTheme.subHeadingText),
              const SizedBox(height: 8),
              ...balances.map((b) {
                final isMe = b.userId == myId;
                final name = isMe ? "You" : (nameMap[b.userId] ?? b.name);
                final isPositive = b.net >= 0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Constants.activeColor.withAlpha(25),
                        child: Text(
                          name[0].toUpperCase(),
                          style: TextStyle(color: Constants.activeColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(name, style: AppTheme.subHeadingText),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            b.net == 0
                                ? "Settled"
                                : "${isPositive ? '+' : ''}\$${b.net.toStringAsFixed(2)}",
                            style: AppTheme.subHeadingText.copyWith(
                              color: b.net == 0
                                  ? Colors.grey
                                  : isPositive
                                      ? Constants.activeColor
                                      : Constants.redColor,
                            ),
                          ),
                          Text(
                            b.net == 0
                                ? ""
                                : isPositive
                                    ? "gets back"
                                    : "owes",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── Suggested Settlements header ───────────────
              Row(
                children: [
                  Text("Suggested Settlements", style: AppTheme.subHeadingText),
                  const Spacer(),

                  // ✅ Trigger button — only show when there are settlements
                  if (settlements.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        final breakdownData =
                            SettlementBreakdownData.fromBalancesModel(
                          groupCtrl.groupBalances.value,
                          myId,
                        );
                        showSettlementBreakdown(context, breakdownData);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Constants.activeColor.withOpacity(0.1),
                          border: Border.all(
                              color: Constants.activeColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate_outlined,
                                size: 13, color: Constants.activeColor),
                            const SizedBox(width: 4),
                            Text(
                              "How is this calculated?",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Constants.activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Settlements list ───────────────────────────
              settlements.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Constants.bgColorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Everyone is settled up! 🎉",
                        style: AppTheme.normalText,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: settlements.map((s) {
                        final fromName = s.from == myId
                            ? "You"
                            : (nameMap[s.from] ?? s.fromName);
                        final toName =
                            s.to == myId ? "you" : (nameMap[s.to] ?? s.toName);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Constants.bgColorLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward,
                                  color: Constants.redColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: "$fromName ",
                                        style: AppTheme.subHeadingText),
                                    TextSpan(
                                        text: "owes ",
                                        style: AppTheme.normalText),
                                    TextSpan(
                                        text: "$toName ",
                                        style: AppTheme.subHeadingText),
                                  ]),
                                ),
                              ),
                              Text(
                                "\$${s.amount.toStringAsFixed(2)}",
                                style: AppTheme.subHeadingText
                                    .copyWith(color: Constants.redColor),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      }),
    );
  }
}
