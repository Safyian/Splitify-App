import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../features/groups/Controllers/groups_controller.dart';
import '../../features/groups/Models/group_summary_model.dart';
import '../../features/groups/Views/group_expenses_view.dart';

class GroupCard extends StatelessWidget {
  GroupCard({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = groupCtrl.summaries[index];
      final isSettled = summary.balance.status == BalanceStatus.settled;
      final youOwe = summary.balance.status == BalanceStatus.youOwe;
      final balanceColor = isSettled
          ? Colors.grey
          : youOwe
              ? Constants.redColor
              : Constants.activeColor;

      return GestureDetector(
        onTap: () {
          groupCtrl.fetchGroupMembers(groupId: summary.id, forceRefresh: true);
          groupCtrl.fetchGroupExpenses(groupId: summary.id, forceRefresh: true);
          Get.to(() => GroupExpensesView(index: index));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Constants.bgColorLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // ── Group emoji avatar ───────────────────────────
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Constants.activeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  summary.emoji,
                  style: TextStyle(fontSize: 26.w),
                ),
              ),
              const SizedBox(width: 14),

              // ── Group info ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name,
                      style: AppTheme.subHeadingText.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isSettled)
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 13, color: Constants.activeColor),
                          const SizedBox(width: 4),
                          Text(
                            "All settled up",
                            style: AppTheme.normalText.copyWith(
                              color: Constants.activeColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      // Preview entries
                      ...summary.preview.take(2).map(
                        (entity) {
                          final youPay =
                              entity.direction == PreviewDirection.youPay;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: youPay ? "You owe " : "${entity.name} ",
                                  style: AppTheme.normalText.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      youPay ? "${entity.name} " : "owes you ",
                                  style: AppTheme.normalText.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: "\$${entity.amount.toStringAsFixed(2)}",
                                  style: AppTheme.normalText.copyWith(
                                    color: youPay
                                        ? Constants.redColor
                                        : Constants.activeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // ── Balance badge ────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: balanceColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSettled
                          ? "Settled"
                          : "\$${summary.balance.net.abs().toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        color: balanceColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
