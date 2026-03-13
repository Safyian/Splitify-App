import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/groups/settle_up_view.dart';
import 'package:splitify/features/groups/totals_view.dart';

import '../../core/theme/app_themes.dart';
import '../../core/utils/date_helper.dart';
import '../expenses/add_expense_controller.dart';
import '../expenses/add_expense_view.dart';
import '../expenses/charts_view.dart';
import '../profile/profile_controller.dart';
import 'balances_view.dart';
import 'group_settings_view.dart';
import 'group_summary_model.dart';
import 'groups_controller.dart';
import 'settlement_breakdown_sheet.dart'; // ← NEW

class GroupExpensesView extends StatelessWidget {
  GroupExpensesView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  Future<void> _goToAddExpense() async {
    await Get.delete<AddExpenseController>(force: true);
    final expenseCtrl = Get.put(AddExpenseController());
    expenseCtrl.groupId = groupCtrl.summaries[index].id;
    await expenseCtrl.fetchGroupMembers(groupId: expenseCtrl.groupId);
    final result = await Get.to(
      () => const AddExpenseView(),
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
        if (index >= groupCtrl.summaries.length) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _GroupHeader(index: index, groupCtrl: groupCtrl),
              const SizedBox(height: 16),
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
            child: SvgPicture.asset(
              Constants.backLogo,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.to(
              () => GroupSettingsView(index: index),
              transition: Transition.rightToLeft,
            ),
            child: SvgPicture.asset(
              Constants.settingsLogo,
              width: 24.w,
              height: 24.w,
            ),
          ),
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
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        label: Text(
          "Add Expense",
          style: AppTheme.subHeadingText.copyWith(color: Constants.textLight),
        ),
        icon: Icon(Icons.add, size: 20.w, color: Constants.bgColorLight),
      );
}

// ── Group Header ───────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  // ── Trigger the breakdown sheet ──────────────────────────
  void _showBreakdown(BuildContext context) {
    final myId = Get.find<ProfileController>().user.value.user?.id ?? '';
    final balances = groupCtrl.groupBalances.value;

    // Guard: balances not yet loaded for this screen
    if (balances.balances.isEmpty) {
      // Fetch first, then show
      groupCtrl
          .fetchGroupBalances(groupId: groupCtrl.summaries[index].id)
          .then((_) {
        if (!context.mounted) return;
        final data = SettlementBreakdownData.fromBalancesModel(
          groupCtrl.groupBalances.value,
          myId,
        );
        showSettlementBreakdown(context, data);
      });
      return;
    }

    final data = SettlementBreakdownData.fromBalancesModel(balances, myId);
    showSettlementBreakdown(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (index >= groupCtrl.summaries.length) return const SizedBox.shrink();
      final summary = groupCtrl.summaries[index];
      final isSettled = summary.balance.status == BalanceStatus.settled;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Group Avatar ──────────────────────────────────
          CircleAvatar(
            radius: 30.w,
            backgroundImage: const NetworkImage(
              "https://jarvis.cx/tools/_next/image?url=https%3A%2F%2Ffiles.oaiusercontent.com%2Ffile-ctTMt4msuva5EDGFhkxV4zR7%3Fse%3D2123-11-06T01%253A08%253A20Z%26sp%3Dr%26sv%3D2021-08-06%26sr%3Db%26rscc%3Dmax-age%253D31536000%252C%2520immutable%26rscd%3Dattachment%253B%2520filename%253Ddanny-2.webp%26sig%3DHFENdbWjKuaTqdZOdWHzlZ%252BsF1CRtZW1pBI3q94pJ0s%253D&w=1080&q=75",
            ),
          ),
          const SizedBox(width: 14),

          // ── Group Info ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.name, style: AppTheme.headingText),
                const SizedBox(height: 2),
                if (isSettled)
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: Constants.activeColor),
                      const SizedBox(width: 4),
                      Text(
                        "All settled up",
                        style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                        ),
                      ),
                    ],
                  )
                else
                  // ── Balance preview rows ───────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...summary.preview.asMap().entries.map((entry) {
                        final isLast = entry.key == summary.preview.length - 1;
                        final entity = entry.value;
                        final youPay =
                            entity.direction == PreviewDirection.youPay;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: youPay
                                      ? "You owe ${entity.name} "
                                      : "${entity.name} owes you ",
                                  style: AppTheme.normalText,
                                ),
                                TextSpan(
                                  text: "\$${entity.amount}",
                                  style: AppTheme.normalText.copyWith(
                                    color: youPay
                                        ? Constants.redColor
                                        : Constants.activeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ── +N more › inline on last row ──
                                if (isLast && summary.othersCount > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      onTap: () => _showBreakdown(context),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          "+${summary.othersCount} more ›",
                                          style: AppTheme.normalText.copyWith(
                                            color: Constants.activeColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // ── See breakdown (only when nothing hidden) ──
                      if (summary.othersCount == 0) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showBreakdown(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.north_east_rounded,
                                size: 12,
                                color: Constants.activeColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "See breakdown",
                                style: AppTheme.normalText.copyWith(
                                  color: Constants.activeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Constants.activeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    });
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
      if (index >= groupCtrl.summaries.length) return const SizedBox.shrink();
      final isSettled =
          groupCtrl.summaries[index].balance.status == BalanceStatus.settled;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: isSettled ? "Settled" : "Settle Up",
              color: Constants.activeColor,
              onTap: isSettled
                  ? null
                  : () => Get.to(() => SettleUpView(index: index)),
              trailing: isSettled
                  ? Icon(Icons.check_circle,
                      size: 16, color: Constants.textLight)
                  : Icon(Icons.arrow_forward_ios,
                      size: 12, color: Constants.textLight),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: "Charts",
              icon: Icons.bar_chart_rounded,
              color: Constants.chipColor,
              onTap: () => Get.to(
                () => ChartsView(index: index),
                transition: Transition.rightToLeft,
              ),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: "Balances",
              icon: Icons.account_balance_wallet_outlined,
              color: Constants.chipColor,
              onTap: () {
                groupCtrl.fetchGroupBalances(
                  groupId: groupCtrl.summaries[index].id,
                );
                Get.to(
                  () => BalancesView(index: index),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            const SizedBox(width: 8),
            _Chip(
              label: "Totals",
              icon: Icons.receipt_long_outlined,
              color: Constants.chipColor,
              onTap: () => Get.to(
                () => TotalsView(index: index),
                transition: Transition.rightToLeft,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.trailing,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Constants.textLight),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTheme.normalText.copyWith(
                  color: Constants.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                trailing!,
              ],
            ],
          ),
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
    return Obx(() {
      if (index >= groupCtrl.summaries.length) return const SizedBox.shrink();
      final expenses = groupCtrl.groupExpenses.value.expenses;
      final groupId = groupCtrl.summaries[index].id;

      if (expenses == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (expenses.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text("No expenses yet", style: AppTheme.subHeadingText),
              const SizedBox(height: 4),
              Text(
                "Tap + Add Expense to get started",
                style: AppTheme.normalText.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      final grouped = SplitifyDateUtils.groupByMonth(
        expenses,
        (e) => e.createdAt,
      );

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: grouped.length,
        itemBuilder: (context, sectionIndex) {
          final section = grouped[sectionIndex];
          final monthLabel = section.key;
          final monthExpenses = section.value;

          final sectionTotal = monthExpenses
              .where((e) => e.description != 'Settlement')
              .fold(0.0, (sum, e) => sum + (e.amount ?? 0));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonthHeader(label: monthLabel, total: sectionTotal),
              const SizedBox(height: 8),
              ...monthExpenses.map((expense) {
                final myId = profileCtrl.user.value.user?.id;
                final isSettlement = expense.description == "Settlement";

                double amount = 0.0;
                expense.splits?.forEach((split) {
                  final iPaid = expense.paidBy?.id == myId;
                  final isMe = split.user?.id == myId;

                  if (iPaid && !isMe) {
                    amount = (amount + (split.amount ?? 0)).toPrecision(2);
                  } else if (!iPaid && isMe) {
                    amount = (split.amount ?? 0).toPrecision(2);
                  }
                });

                final card = _ExpenseCard(
                  expense: expense,
                  amount: amount,
                  myId: myId,
                  isSettlement: isSettlement,
                );

                return Dismissible(
                  key: Key(expense.id ?? UniqueKey().toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await Get.dialog<bool>(
                          AlertDialog(
                            backgroundColor: Constants.bgColorLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              isSettlement
                                  ? "Delete Settlement"
                                  : "Delete Expense",
                              style: AppTheme.subHeadingText,
                            ),
                            content: Text(
                              isSettlement
                                  ? "Are you sure you want to delete this settlement? This cannot be undone."
                                  : "Are you sure you want to delete \"${expense.description}\"? This cannot be undone.",
                              style: AppTheme.normalText,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text("Cancel",
                                    style: AppTheme.normalText
                                        .copyWith(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: Text(
                                  "Delete",
                                  style: AppTheme.normalText.copyWith(
                                    color: Constants.redColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    groupCtrl.deleteExpense(
                      groupId: groupId,
                      expenseId: expense.id ?? '',
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Constants.redColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.white, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          "Delete",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: card,
                );
              }),
              const SizedBox(height: 4),
            ],
          );
        },
      );
    });
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

  void _showExpenseDetail(BuildContext context, dynamic expense, String? myId) {
    Get.bottomSheet(
      _ExpenseDetailSheet(expense: expense, myId: myId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String get _icon {
    if (isSettlement) return Constants.walletLogo;
    final desc = (expense.description as String? ?? '').toLowerCase();
    if (desc.contains("meat")) return Constants.meatLogo;
    return Constants.groceryLogo;
  }

  @override
  Widget build(BuildContext context) {
    final iPaid = expense.paidBy?.id == myId;
    final isZero = amount == 0.0;

    return GestureDetector(
      onTap: () => _showExpenseDetail(context, expense, myId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Constants.activeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                _icon,
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                    Constants.activeColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSettlement)
                    Text(
                      expense.description ?? '',
                      style: AppTheme.normalText
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: iPaid
                            ? 'You paid '
                            : '${expense.paidBy?.name} paid ',
                        style: AppTheme.normalText.copyWith(color: Colors.grey),
                      ),
                      TextSpan(
                        text: "\$${expense.amount}",
                        style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSettlement)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Constants.activeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Settlement",
                      style: AppTheme.normalText.copyWith(
                        color: Constants.activeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isZero)
                  Text(
                    "not involved",
                    style: AppTheme.normalText
                        .copyWith(color: Colors.grey, fontSize: 11),
                  )
                else
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: iPaid ? 'lent ' : 'borrowed ',
                        style: AppTheme.normalText.copyWith(color: Colors.grey),
                      ),
                      TextSpan(
                        text: "\$$amount",
                        style: AppTheme.normalText.copyWith(
                          color: iPaid
                              ? Constants.activeColor
                              : Constants.redColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 4),
                Text(
                  SplitifyDateUtils.formatExpenseDate(expense.createdAt),
                  style: AppTheme.normalText
                      .copyWith(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month Header ───────────────────────────────────────────────────────────────
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.label, required this.total});
  final String label;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Constants.activeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: AppTheme.normalText.copyWith(
                color: Constants.activeColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 1,
              color: Colors.grey.withOpacity(0.15),
            ),
          ),
          Text(
            "\$${total.toStringAsFixed(2)}",
            style: AppTheme.normalText.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expense Detail Sheet ───────────────────────────────────────────────────────
class _ExpenseDetailSheet extends StatelessWidget {
  const _ExpenseDetailSheet({
    required this.expense,
    required this.myId,
  });

  final dynamic expense;
  final String? myId;

  void _goToEditExpense() {
    final isSettlement = expense.description == "Settlement";
    if (isSettlement) {
      _showEditSettlementDialog();
    } else {
      Get.back();
      final groupCtrl = Get.find<GroupsController>();
      // Delete stale instance first so Get.put always creates fresh
      Get.delete<AddExpenseController>(force: true);

      final expenseCtrl = AddExpenseController(editExpense: expense);
      expenseCtrl.groupId = groupCtrl.groupMembers.value.members != null
          ? expense.group ?? ''
          : '';
      Get.put(expenseCtrl);

      Get.to(
        () => const AddExpenseView(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _showEditSettlementDialog() {
    final groupCtrl = Get.find<GroupsController>();
    final amountCtrl = TextEditingController(
      text: expense.amount?.toStringAsFixed(2) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text("Edit Settlement Amount", style: AppTheme.subHeadingText),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update the settlement amount",
                style: AppTheme.normalText.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTheme.headingText.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  prefixText: "\$ ",
                  prefixStyle: AppTheme.subHeadingText,
                  border: const OutlineInputBorder(),
                  hintText: "0.00",
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter an amount';
                  final v = double.tryParse(val);
                  if (v == null || v <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                "Original: \$${expense.amount?.toStringAsFixed(2)}",
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Get.back();
                Get.back();
                await groupCtrl.updateSettlement(
                  groupId: expense.group,
                  expenseId: expense.id ?? '',
                  amount: double.parse(amountCtrl.text.trim()),
                );
              }
            },
            child: Text(
              "Update",
              style: AppTheme.normalText.copyWith(
                color: Constants.activeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iPaid = expense.paidBy?.id == myId;
    final isSettlement = expense.description == "Settlement";
    final splits = expense.splits ?? [];

    double myAmount = 0.0;
    for (final split in splits) {
      final isMe = split.user?.id == myId;
      if (iPaid && !isMe) {
        myAmount =
            double.parse((myAmount + (split.amount ?? 0)).toStringAsFixed(2));
      } else if (!iPaid && isMe) {
        myAmount = double.parse((split.amount ?? 0).toStringAsFixed(2));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Constants.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Constants.activeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSettlement
                      ? Icons.account_balance_wallet_outlined
                      : Icons.receipt_long_outlined,
                  color: Constants.activeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSettlement ? "Settlement" : (expense.description ?? ''),
                      style: AppTheme.headingText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      SplitifyDateUtils.formatExpenseDate(expense.createdAt),
                      style: AppTheme.normalText
                          .copyWith(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _goToEditExpense(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constants.activeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Constants.activeColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Constants.bgColorLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  "\$${expense.amount?.toStringAsFixed(2) ?? '0.00'}",
                  style: AppTheme.headingText.copyWith(
                    fontSize: 32,
                    color: Constants.activeColor,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Paid by ",
                      style: AppTheme.normalText.copyWith(color: Colors.grey),
                    ),
                    TextSpan(
                      text: iPaid ? "You" : expense.paidBy?.name ?? '',
                      style: AppTheme.normalText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Constants.activeColor,
                      ),
                    ),
                  ]),
                ),
                if (!isSettlement && myAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: iPaid
                          ? Constants.activeColor.withAlpha(25)
                          : Constants.redColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: iPaid ? "You lent " : "You borrowed ",
                          style: AppTheme.normalText.copyWith(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "\$$myAmount",
                          style: AppTheme.normalText.copyWith(
                            color: iPaid
                                ? Constants.activeColor
                                : Constants.redColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!isSettlement) ...[
            Text("Split between", style: AppTheme.subHeadingText),
            const SizedBox(height: 10),
            ...splits.map<Widget>((split) {
              final isMe = split.user?.id == myId;
              final name = isMe ? "You" : (split.user?.name ?? 'Unknown');
              final amount = split.amount ?? 0.0;
              final total = expense.amount ?? 1.0;
              final pct = (amount / total * 100).toStringAsFixed(1);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Constants.bgColorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isMe
                      ? Border.all(color: Constants.activeColor.withAlpha(60))
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Constants.activeColor.withAlpha(25),
                      child: Text(
                        name[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(name, style: AppTheme.normalText),
                    ),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: amount / total,
                          minHeight: 5,
                          backgroundColor: Colors.grey.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMe
                                ? (iPaid
                                    ? Constants.activeColor
                                    : Constants.redColor)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${amount.toStringAsFixed(2)}",
                          style: AppTheme.normalText.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "$pct%",
                          style: AppTheme.normalText.copyWith(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (isSettlement) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Constants.activeColor.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Constants.activeColor.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Constants.activeColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: iPaid
                              ? "You paid "
                              : "${expense.paidBy?.name} paid ",
                          style: AppTheme.normalText,
                        ),
                        TextSpan(
                          text: "\$${expense.amount?.toStringAsFixed(2)} ",
                          style: AppTheme.normalText.copyWith(
                            color: Constants.activeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: "to settle their balance",
                          style: AppTheme.normalText,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
