import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splittify/core/constants/constants.dart';
import 'package:splittify/features/groups/settle_up_view.dart';
import 'package:splittify/features/groups/totals_view.dart';

import '../../core/theme/app_themes.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/expense_icon_helper.dart';
import '../../shared/widgets/shimmer.dart';
import '../expenses/add_expense_controller.dart';
import '../expenses/add_expense_view.dart';
import '../expenses/charts_view.dart';
import '../profile/profile_controller.dart';
import 'balances_view.dart';
import 'expense_detail_view.dart';
import 'group_expenses_model.dart';
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
    // Set groupId before Get.put so onInit auto-fetches members in the background
    final expenseCtrl = AddExpenseController();
    expenseCtrl.groupId = groupCtrl.summaries[index].id;
    Get.put(expenseCtrl);
    // Navigate immediately — AddExpenseView shows its own loading state for members
    // submitExpense already fetches expenses + summary before returning true,
    // so there is nothing to do on return — data is already fresh.
    await Get.to(
      () => const AddExpenseView(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: Obx(() {
        // Guard: group was deleted/left
        if (index >= groupCtrl.summaries.length) {
          return const SizedBox.shrink();
        }
        // Full skeleton only on first open before any data has loaded
        final groupId = groupCtrl.summaries[index].id;
        if (groupCtrl.isLoading.isTrue &&
            groupCtrl.expensesFor(groupId).expenses == null) {
          return const _GroupExpensesSkeleton();
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
class _GroupHeader extends StatefulWidget {
  const _GroupHeader({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  @override
  State<_GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<_GroupHeader> {
  OverlayEntry? _overlayEntry;

  // ── Trigger the breakdown sheet ──────────────────────────
  void _showBreakdown(BuildContext context) {
    final groupId = widget.groupCtrl.summaries[widget.index].id;
    final myId = Get.find<ProfileController>().user.value.user?.id ?? '';
    final balances = widget.groupCtrl.balancesFor(groupId);

    // Guard: balances not yet loaded for this screen
    if (balances.balances.isEmpty) {
      // Fetch first, then show
      widget.groupCtrl.fetchGroupBalances(groupId: groupId).then((_) {
        if (!context.mounted) return;
        final data = SettlementBreakdownData.fromBalancesModel(
          widget.groupCtrl.balancesFor(groupId),
          myId,
        );
        showSettlementBreakdown(context, data);
      });
      return;
    }

    final data = SettlementBreakdownData.fromBalancesModel(balances, myId);
    showSettlementBreakdown(context, data);
  }

  void _openPopup(GroupSummary summary) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePopup,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withAlpha(30)),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 120,
            left: 16,
            right: 16,
            child: _AllBalancesPopup(
              summary: summary,
              onClose: _closePopup,
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.index >= widget.groupCtrl.summaries.length) {
        return const SizedBox.shrink();
      }
      final summary = widget.groupCtrl.summaries[widget.index];
      final isSettled = summary.balance.status == BalanceStatus.settled;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Group emoji avatar ────────────────────────────
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Constants.activeColor.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              summary.emoji,
              style: TextStyle(fontSize: 28.w),
            ),
          ),
          const SizedBox(width: 14),

          // ── Group Info ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.name,
                  style: AppTheme.headingText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                      ...summary.preview
                          .take(2)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final isLast = entry.key ==
                            summary.preview.take(2).toList().length - 1;
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
                                // ── +N more chip inline on last row ──
                                if (isLast && summary.othersCount > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      onTap: () => _openPopup(summary),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Constants.bgColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '+${summary.othersCount} more',
                                                style: AppTheme.normalText
                                                    .copyWith(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                            ],
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
                              const Icon(
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

// ── All Balances Popup ─────────────────────────────────────────────────────────
class _AllBalancesPopup extends StatelessWidget {
  const _AllBalancesPopup({
    required this.summary,
    required this.onClose,
  });
  final GroupSummary summary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final items = summary.preview;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All balances',
                  style: AppTheme.headingText.copyWith(fontSize: 14),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Constants.bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Balance rows ─────────────────────────────────
            if (items.isNotEmpty)
              ...items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                final item = entry.value;

                final youPay = item.direction == PreviewDirection.youPay;
                final name = item.name;
                final amount = item.amount;
                final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
                final avatarBg = youPay
                    ? Constants.redColor.withAlpha(20)
                    : Constants.activeColor.withAlpha(20);
                final avatarTextColor =
                    youPay ? Constants.redColor : Constants.activeColor;
                final amountColor =
                    youPay ? Constants.redColor : Constants.activeColor;
                final label = youPay
                    ? 'you owe \$${amount.toStringAsFixed(2)}'
                    : 'owes you \$${amount.toStringAsFixed(2)}';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: avatarBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: AppTheme.normalText.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: avatarTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: AppTheme.normalText.copyWith(fontSize: 13),
                            ),
                          ),
                          Text(
                            label,
                            style: AppTheme.normalText.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: Colors.grey.withAlpha(25),
                      ),
                  ],
                );
              })

            // ── Empty state ──────────────────────────────────
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'All settled up',
                  style: AppTheme.normalText.copyWith(
                    color: Constants.activeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // ── Net balance footer ───────────────────────────
            if (items.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withAlpha(40)),
                  ),
                ),
                child: Builder(builder: (_) {
                  final net = summary.balance.net;
                  final isPositive = net >= 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net balance',
                        style: AppTheme.normalText.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        isPositive
                            ? '+\$${net.toStringAsFixed(2)}'
                            : '-\$${net.abs().toStringAsFixed(2)}',
                        style: AppTheme.headingText.copyWith(
                          fontSize: 14,
                          color: isPositive
                              ? Constants.activeColor
                              : Constants.redColor,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ],
        ),
      ),
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
      final groupId = groupCtrl.summaries[index].id;
      final expenses = groupCtrl.expensesFor(groupId).expenses;

      if (expenses == null) {
        return const _ExpenseListSkeleton();
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

      return Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.metrics.pixels >=
                    scroll.metrics.maxScrollExtent - 200) {
                  final gId = groupCtrl.summaries[index].id;
                  final hasMore =
                      groupCtrl.expensesFor(gId).hasMore ?? false;
                  final isLoadingMore =
                      groupCtrl.isLoadingMoreExpenses.value;
                  if (hasMore && !isLoadingMore) {
                    groupCtrl.fetchGroupExpenses(
                      groupId: gId,
                      loadMore: true,
                    );
                  }
                }
                return false;
              },
              child: ListView.builder(
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
                  index: index,
                );

                return Dismissible(
                  key: ValueKey(expense.id),
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
                  onDismissed: (direction) async {
                    final expenseId = expense.id ?? '';

                    // Immediately remove from local cache so Dismissible is satisfied
                    final currentExpenses =
                        groupCtrl.expensesFor(groupId).expenses ?? [];
                    final updatedExpenses = List.of(currentExpenses)
                      ..removeWhere((e) => e.id == expenseId);
                    groupCtrl.allGroupExpenses[groupId] = GroupExpenses(
                      count: updatedExpenses.length,
                      expenses: updatedExpenses,
                    );

                    // Then call the API in background
                    await groupCtrl.deleteExpense(
                      groupId: groupId,
                      expenseId: expenseId,
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
              ),
            ),
          ),
          Obx(() {
            if (groupCtrl.isLoadingMoreExpenses.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Constants.activeColor,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
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
    required this.index,
  });

  final dynamic expense;
  final double amount;
  final String? myId;
  final bool isSettlement;
  final int index;

  void _showExpenseDetail(BuildContext context, dynamic expense, String? myId) {
    Get.to(
      () => ExpenseDetailView(
        expense: expense,
        myId: myId,
        groupIndex: index,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
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
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Constants.activeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                ExpenseIconHelper.resolve(
                  expense.description as String?,
                  isSettlement: expense.description == 'Settlement',
                ),
                size: 21.w,
                color: Constants.activeColor,
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
                  if (isSettlement &&
                      expense.splits != null &&
                      expense.splits!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          expense.splits![0].user?.id == myId
                              ? 'You'
                              : expense.splits![0].user?.name ?? '',
                          style: AppTheme.normalText.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
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

// ── Full-page skeleton (first load) ──────────────────────────────────────────
class _GroupExpensesSkeleton extends StatelessWidget {
  const _GroupExpensesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Group Header ──
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShimmerBox(width: 60, height: 60, shape: BoxShape.circle),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130, height: 16, borderRadius: 6),
                      SizedBox(height: 8),
                      ShimmerBox(height: 12, borderRadius: 4),
                      SizedBox(height: 5),
                      ShimmerBox(width: 160, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Action Chips ──
            const Row(
              children: [
                ShimmerBox(width: 100, height: 38, borderRadius: 10),
                SizedBox(width: 8),
                ShimmerBox(width: 76, height: 38, borderRadius: 10),
                SizedBox(width: 8),
                ShimmerBox(width: 92, height: 38, borderRadius: 10),
                SizedBox(width: 8),
                ShimmerBox(width: 76, height: 38, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 20),

            // ── Month header ──
            Row(
              children: [
                const ShimmerBox(width: 72, height: 24, borderRadius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.12),
                  ),
                ),
                const SizedBox(width: 10),
                const ShimmerBox(width: 48, height: 12, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 12),

            // ── Expense rows ──
            _expenseRowSkeleton(120),
            _expenseRowSkeleton(160),
            _expenseRowSkeleton(100),
            _expenseRowSkeleton(140),
          ],
        ),
      ),
    );
  }

  Widget _expenseRowSkeleton(double descWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: descWidth, height: 13, borderRadius: 4),
                const SizedBox(height: 6),
                const ShimmerBox(width: 90, height: 11, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 55, height: 13, borderRadius: 4),
              SizedBox(height: 5),
              ShimmerBox(width: 42, height: 18, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Expense-list-only skeleton (fallback when header already rendered) ────────
class _ExpenseListSkeleton extends StatelessWidget {
  const _ExpenseListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Row(
              children: [
                const ShimmerBox(width: 72, height: 24, borderRadius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.12),
                  ),
                ),
                const SizedBox(width: 10),
                const ShimmerBox(width: 48, height: 12, borderRadius: 4),
              ],
            ),
          ),
          _row(120),
          _row(160),
          _row(100),
          _row(140),
        ],
      ),
    );
  }

  Widget _row(double descWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: descWidth, height: 13, borderRadius: 4),
                const SizedBox(height: 6),
                const ShimmerBox(width: 90, height: 11, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 55, height: 13, borderRadius: 4),
              SizedBox(height: 5),
              ShimmerBox(width: 42, height: 18, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
