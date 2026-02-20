import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/groups/settle_up_view.dart';

import '../../core/theme/app_themes.dart';
import '../expenses/add_expense_view.dart';
import '../profile/profile_controller.dart';
import 'group_summary_model.dart';
import 'groups_controller.dart';

class GroupExpensesView extends StatelessWidget {
  GroupExpensesView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  // ── Navigation to Add Expense ──────────────────────────────
  Future<void> _goToAddExpense() async {
    final result = await Get.to(
      () => AddExpenseView(index: index),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    if (result == true) {
      await Future.wait([
        groupCtrl.fetchGroupExpenses(groupId: groupCtrl.summaries[index].id),
        groupCtrl.fetchSummary(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: Obx(() {
        if (groupCtrl.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _GroupHeader(index: index, groupCtrl: groupCtrl),
              const SizedBox(height: 12),
              _ActionChips(index: index, groupCtrl: groupCtrl),
              const SizedBox(height: 16),
              Expanded(child: _ExpenseList(index: index)),
            ],
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text("Back", style: AppTheme.normalText),
        titleSpacing: 0.0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            child:
                SvgPicture.asset(Constants.backLogo, width: 24.w, height: 24.w),
          ),
        ),
        actions: [
          SvgPicture.asset(Constants.settingsLogo, width: 24.w, height: 24.w),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
      );

  Widget _buildFAB() => FloatingActionButton.extended(
        onPressed: _goToAddExpense,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 4,
        backgroundColor: Constants.activeColor,
        foregroundColor: Constants.activeColor,
        extendedIconLabelSpacing: 4.w,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(
          "Add Expense",
          style: AppTheme.subHeadingText.copyWith(color: Constants.textLight),
        ),
        icon: Icon(Icons.add, size: 18.w, color: Constants.bgColorLight),
      );
}

// ── Group Header ───────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 42.w,
          backgroundImage: const NetworkImage(
            "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final summary = groupCtrl.summaries[index];
            final isSettled = summary.balance.status == BalanceStatus.settled;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.name, style: AppTheme.headingText),
                if (isSettled)
                  Text(
                    "You're all settled",
                    style: AppTheme.subHeadingText.copyWith(
                      color: Constants.activeColor,
                    ),
                  )
                else
                  ...summary.preview.map(
                    (entity) => RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: entity.direction == PreviewDirection.youPay
                                ? "You owe ${entity.name} "
                                : "${entity.name} owes you ",
                            style: AppTheme.subHeadingText,
                          ),
                          TextSpan(
                            text: "\$${entity.amount}",
                            style: AppTheme.subHeadingText.copyWith(
                              color: entity.direction == PreviewDirection.youPay
                                  ? Constants.redColor
                                  : Constants.activeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ── Action Chips Row ────────────────────────────────────────────────────────────
class _ActionChips extends StatelessWidget {
  const _ActionChips({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSettled =
          groupCtrl.summaries[index].balance.status == BalanceStatus.settled;

      return Row(
        children: [
          _Chip(
            label: isSettled ? "Settled" : "Settle Up",
            color: Constants.activeColor,
            onTap: isSettled
                ? null
                : () => Get.to(() => SettleUpView(index: index)),
            trailing: isSettled
                ? Image.asset(Constants.settledLogo, width: 26.w, height: 26.w)
                : null,
          ),
          const SizedBox(width: 8),
          _Chip(label: "Charts", color: Constants.chipColor, onTap: () {}),
          const SizedBox(width: 8),
          _Chip(label: "Balances", color: Constants.chipColor, onTap: () {}),
          const SizedBox(width: 8),
          _Chip(label: "Totals", color: Constants.chipColor, onTap: () {}),
        ],
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.onTap,
    this.trailing,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style:
                  AppTheme.subHeadingText.copyWith(color: Constants.textLight),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Expense List ───────────────────────────────────────────────────────────────
class _ExpenseList extends StatelessWidget {
  _ExpenseList({required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final expenses = groupCtrl.groupExpenses.value.expenses ?? [];

    if (expenses.isEmpty) {
      return Center(
        child: Text("No expenses yet", style: AppTheme.subHeadingText),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final myId = profileCtrl.user.value.user?.id;
        final isSettlement = expense.description == "Settlement";

        // Calculate user's share amount
        double amount = 0.0;
        expense.splits?.forEach((split) {
          final iPaid = expense.paidBy?.id == myId;
          final isMe = split.user?.id == myId;

          if (iPaid && !isMe) {
            amount = (amount + split.amount!).toPrecision(2);
          } else if (!iPaid && isMe) {
            amount = split.amount!.toPrecision(2);
          }
        });

        return _ExpenseCard(
          expense: expense,
          amount: amount,
          myId: myId,
          isSettlement: isSettlement,
        );
      },
    );
  }
}

// ── Expense Card ───────────────────────────────────────────────────────────────
class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.amount,
    required this.myId,
    required this.isSettlement,
  });

  final dynamic expense;
  final double amount;
  final String? myId;
  final bool isSettlement;

  String get _icon {
    if (isSettlement) return Constants.walletLogo;
    if (expense.description!.contains("meat")) return Constants.meatLogo;
    return Constants.groceryLogo;
  }

  @override
  Widget build(BuildContext context) {
    final iPaid = expense.paidBy?.id == myId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ── Icon ──
          SizedBox(
            width: 38.w,
            height: 38.w,
            child: CircleAvatar(
              backgroundColor: Constants.activeColor.withAlpha(25),
              child: SvgPicture.asset(_icon, color: Constants.activeColor),
            ),
          ),
          const SizedBox(width: 12),

          // ── Description + Paid by ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSettlement)
                  Text(
                    expense.description!,
                    style: AppTheme.normalText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text:
                          iPaid ? 'You paid ' : '${expense.paidBy?.name} paid ',
                      style: AppTheme.normalText,
                    ),
                    TextSpan(
                      text: "\$${expense.amount}",
                      style: AppTheme.normalText.copyWith(
                        color: Constants.activeColor,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // ── Lent / Borrowed / Settlement ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSettlement)
                Text(
                  "Settlement",
                  style: AppTheme.normalText
                      .copyWith(color: Constants.activeColor),
                )
              else
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: iPaid ? 'You lent ' : 'You borrowed ',
                      style: AppTheme.normalText,
                    ),
                    TextSpan(
                      text: "\$$amount",
                      style: AppTheme.normalText.copyWith(
                        color: Constants.redColor,
                      ),
                    ),
                  ]),
                ),
              Text("19 Oct", style: AppTheme.normalText),
            ],
          ),
        ],
      ),
    );
  }
}
