import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';
import 'package:splitify/features/groups/group_members_model.dart';
import 'package:splitify/features/groups/groups_controller.dart';

import '../../core/theme/app_themes.dart';
import 'add_expense_controller.dart';
import 'expense_payload_model.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key, required this.index});
  final int index;

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final expenseCtrl = Get.find<AddExpenseController>();
  final groupCtrl = Get.find<GroupsController>();

  late final String groupId;

  @override
  void initState() {
    super.initState();
    groupId = expenseCtrl.groupId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        title: Obx(() => Text(
              expenseCtrl.isEditMode.value ? "Edit Expense" : "Add Expense",
              style: AppTheme.headingText,
            )),
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
            // ── Description ──────────────────────────
            TextField(
              controller: expenseCtrl.descriptionCtrl,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Amount ───────────────────────────────
            TextField(
              controller: expenseCtrl.amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
                prefixText: "\$ ",
              ),
            ),
            const SizedBox(height: 16),

            // ── Paid By ──────────────────────────────
            Obx(() => DropdownButtonFormField<Member>(
                  value: expenseCtrl.selectedMember.value,
                  hint: const Text("Paid By"),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  // Paid By dropdown
                  items: expenseCtrl.groupMembersData.members
                      ?.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name!),
                          ))
                      .toList(),
                  onChanged: (v) => expenseCtrl.selectedMember.value = v,
                )),
            const SizedBox(height: 20),

            // ── Split By ─────────────────────────────
            Text("Split by", style: AppTheme.subHeadingText),
            const SizedBox(height: 8),

            Obx(() => Row(
                  children: SplitType.values.map((type) {
                    final isSelected =
                        expenseCtrl.selectedSplitType.value == type;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              expenseCtrl.selectedSplitType.value = type,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Constants.activeColor
                                  : Constants.bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Constants.activeColor
                                    : Colors.grey.shade400,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _splitTypeLabel(type),
                              style: AppTheme.subHeadingText.copyWith(
                                color: isSelected
                                    ? Constants.textLight
                                    : Colors.grey.shade600,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 24),

            // ── Members Split Inputs ──────────────────
            Obx(() {
              final members = expenseCtrl.groupMembersData.members ?? [];
              final splitType = expenseCtrl.selectedSplitType.value;

              if (members.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _splitSectionTitle(splitType),
                    style: AppTheme.subHeadingText,
                  ),
                  const SizedBox(height: 8),
                  ...members
                      .map((member) => _buildMemberSplitRow(member, splitType)),

                  // Live total hint for exact & percentage
                  if (splitType != SplitType.equal) ...[
                    const SizedBox(height: 8),
                    _TotalHintRow(
                      splitType: splitType,
                      controllers: expenseCtrl.splitInputControllers,
                      members: members,
                      amountCtrl: expenseCtrl.amountCtrl,
                      selectedMembers: expenseCtrl.selectedMembers,
                    ),
                  ],
                ],
              );
            }),

            const SizedBox(height: 32),

            // ── Submit ───────────────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: expenseCtrl.isLoading.value
                        ? null
                        : () async {
                            final success = await expenseCtrl.submitExpense(
                                groupId: groupId);
                            if (success) {
                              Get.back(result: true);
                              Get.snackbar(
                                "Success",
                                expenseCtrl.isEditMode.value
                                    ? "Expense updated successfully"
                                    : "Expense added successfully",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    child: expenseCtrl.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            expenseCtrl.isEditMode.value
                                ? "Update Expense"
                                : "Add Expense",
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Member row: shows input only for exact & percentage ──
  Widget _buildMemberSplitRow(Member member, SplitType splitType) {
    return Obx(() {
      final isSelected = expenseCtrl.selectedMembers.contains(member.id);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => expenseCtrl.toggleMember(member.id!),
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Constants.activeColor.withAlpha(60)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  // ✅ Checkbox
                  GestureDetector(
                    onTap: () => expenseCtrl.toggleMember(member.id!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Constants.activeColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? Constants.activeColor
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? Constants.activeColor
                        : Colors.grey.shade400,
                    child: Text(
                      member.name![0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name
                  Expanded(
                    child: Text(member.name!, style: AppTheme.subHeadingText),
                  ),

                  // Input field — only for exact & percentage & only if selected
                  if (splitType != SplitType.equal && isSelected)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller:
                            expenseCtrl.splitInputControllers[member.id],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: const OutlineInputBorder(),
                          suffixText:
                              splitType == SplitType.percentage ? "%" : null,
                          prefixText:
                              splitType == SplitType.exact ? "\$" : null,
                        ),
                      ),
                    ),

                  // Equal share badge — only if selected
                  if (splitType == SplitType.equal && isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Constants.activeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Equal share",
                        style: AppTheme.normalText.copyWith(
                          fontSize: 11,
                          color: Constants.activeColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _splitTypeLabel(SplitType type) {
    switch (type) {
      case SplitType.equal:
        return "Equally";
      case SplitType.exact:
        return "Amount";
      case SplitType.percentage:
        return "Percentage";
    }
  }

  String _splitSectionTitle(SplitType type) {
    switch (type) {
      case SplitType.equal:
        return "Split equally among:";
      case SplitType.exact:
        return "Enter amount for each person:";
      case SplitType.percentage:
        return "Enter percentage for each person:";
    }
  }
}

// ── Live total hint widget ────────────────────────────────────────────────────
class _TotalHintRow extends StatefulWidget {
  final SplitType splitType;
  final Map<String, TextEditingController> controllers;
  final List<Member> members;
  final TextEditingController amountCtrl;
  final RxSet<String> selectedMembers;

  const _TotalHintRow({
    required this.splitType,
    required this.controllers,
    required this.members,
    required this.amountCtrl,
    required this.selectedMembers,
  });

  @override
  State<_TotalHintRow> createState() => _TotalHintRowState();
}

class _TotalHintRowState extends State<_TotalHintRow> {
  double _currentTotal = 0;

  @override
  void initState() {
    super.initState();
    // Listen to all split input controllers for live updates
    _recalculate();
    for (final member in widget.members) {
      widget.controllers[member.id]?.addListener(_recalculate);
    }

    widget.amountCtrl.addListener(_recalculate);
  }

  void _recalculate() {
    double sum = 0;
    for (final member in widget.members) {
      // ✅ Only sum selected members
      if (!widget.selectedMembers.contains(member.id)) continue;
      final val = double.tryParse(
            widget.controllers[member.id]?.text.trim() ?? '',
          ) ??
          0;
      sum += val;
    }
    setState(() => _currentTotal = sum);
  }

  @override
  void dispose() {
    for (final member in widget.members) {
      widget.controllers[member.id]?.removeListener(_recalculate);
    }
    widget.amountCtrl.removeListener(_recalculate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPercentage = widget.splitType == SplitType.percentage;
    final target = isPercentage
        ? 100.0
        : (double.tryParse(widget.amountCtrl.text.trim()) ?? 0);
    final remaining = target - _currentTotal;
    final isValid = remaining.abs() < 0.01;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          isPercentage
              ? "Total: ${_currentTotal.toStringAsFixed(1)}% / 100%  "
              : "Total: \$${_currentTotal.toStringAsFixed(2)} / \$${target.toStringAsFixed(2)}  ",
          style: TextStyle(
            fontSize: 13,
            color: isValid ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!isValid)
          Text(
            isPercentage
                ? "(${remaining > 0 ? '+' : ''}${remaining.toStringAsFixed(1)}% remaining)"
                : "(${remaining > 0 ? '+' : ''}\$${remaining.toStringAsFixed(2)} remaining)",
            style: const TextStyle(fontSize: 12, color: Colors.orange),
          ),
        if (isValid)
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
      ],
    );
  }
}
