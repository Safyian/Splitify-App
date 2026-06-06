import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splittify/core/constants/constants.dart';
import 'package:splittify/features/groups/Controllers/groups_controller.dart';
import 'package:splittify/features/groups/Models/group_members_model.dart';

import '../../core/theme/app_themes.dart';
import '../../shared/widgets/alert_widgets.dart';
import '../../shared/widgets/shimmer.dart';
import 'add_expense_controller.dart';
import 'expense_payload_model.dart';

// ── Shared input decoration factory ──────────────────────────────────────────
InputDecoration _fieldDecor({
  required String label,
  IconData? icon,
  String? suffix,
  String? prefix,
}) {
  const radius = 14.0;
  final base = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide.none,
  );
  final focused = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: const BorderSide(color: Constants.activeColor, width: 1.5),
  );
  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null
        ? Icon(icon, size: 20, color: Constants.activeColor)
        : null,
    suffixText: suffix,
    prefixText: prefix,
    filled: true,
    fillColor: Constants.bgColorLight,
    border: base,
    enabledBorder: base,
    focusedBorder: focused,
    labelStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 14,
        fontFamily: GoogleFonts.inter().fontFamily),
    floatingLabelStyle: TextStyle(
        color: Constants.activeColor,
        fontSize: 12,
        fontFamily: GoogleFonts.inter().fontFamily),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final expenseCtrl = Get.find<AddExpenseController>();
  final groupCtrl = Get.find<GroupsController>();

  late final String groupId;

  // Separate flag purely for submit — member-fetch uses expenseCtrl.isLoading
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    groupId = expenseCtrl.groupId;
  }

  Future<void> _submit() async {
    if (_isSubmitting.value) return;

    // Validate before showing any loading UI
    final error = expenseCtrl.validate();
    if (error != null) {
      AlertWidgets.showSnackBar(message: error);
      return;
    }

    _isSubmitting.value = true;
    Get.dialog(const _ExpenseLoadingDialog(), barrierDismissible: false);
    bool isEditMode = expenseCtrl.isEditMode.value;
    final success = await expenseCtrl.submitExpense(groupId: groupId);

    if (Get.isDialogOpen ?? false) Get.back();
    _isSubmitting.value = false;

    if (success) {
      Get.close(isEditMode ? 2 : 1);
      AlertWidgets.showSnackBar(
        message: isEditMode
            ? 'Expense updated successfully'
            : 'Expense added successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Amount hero ───────────────────────────
              _AmountCard(ctrl: expenseCtrl),
              const SizedBox(height: 20),

              // ── Description ──────────────────────────
              TextField(
                controller: expenseCtrl.descriptionCtrl,
                style: AppTheme.subHeadingText,
                decoration: _fieldDecor(
                  label: 'What was it for?',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(height: 14),

              // ── Paid By ──────────────────────────────
              Obx(() {
                final members = expenseCtrl.groupMembersData.members;
                final loading = expenseCtrl.isLoading.value &&
                    (members == null || members.isEmpty);
                if (loading) return _fieldSkeleton(56);
                final selected = expenseCtrl.selectedMember.value;
                return GestureDetector(
                  onTap: () => _showPaidBySheet(members ?? []),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 20, color: Constants.activeColor),
                        const SizedBox(width: 12),
                        if (selected != null) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Constants.activeColor,
                            child: Text(
                              selected.name![0].toUpperCase(),
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(selected.name!, style: AppTheme.subHeadingText),
                        ] else
                          Text('Who paid?',
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade500, fontSize: 14)),
                        const Spacer(),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade400, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── Split by ─────────────────────────────
              const _SectionLabel(label: 'Split by'),
              const SizedBox(height: 10),
              Obx(() => _SplitTypeChips(
                    selected: expenseCtrl.selectedSplitType.value,
                    onSelect: (t) => expenseCtrl.selectedSplitType.value = t,
                  )),
              const SizedBox(height: 22),

              // ── Members ──────────────────────────────
              Obx(() {
                final members = expenseCtrl.groupMembersData.members ?? [];
                final splitType = expenseCtrl.selectedSplitType.value;

                if (expenseCtrl.isLoading.value && members.isEmpty) {
                  return _membersSkeleton();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: _splitSectionTitle(splitType)),
                    const SizedBox(height: 10),
                    ...members.map((m) => _buildMemberRow(m, splitType)),
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

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
        backgroundColor: Constants.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Colors.black87),
            ),
          ),
        ),
        title: Obx(() => Text(
              expenseCtrl.isEditMode.value ? 'Edit Expense' : 'Add Expense',
              style: AppTheme.headingText,
            )),
      );

  // ── Submit bar (pinned to bottom) ─────────────────────────────────────────
  Widget _buildSubmitBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Constants.bgColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Obx(() {
        final membersReady =
            expenseCtrl.groupMembersData.members?.isNotEmpty ?? false;
        final enabled = membersReady && !_isSubmitting.value;
        return GestureDetector(
          onTap: enabled ? _submit : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: enabled ? Constants.activeColor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              expenseCtrl.isEditMode.value ? 'Update Expense' : 'Add Expense',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.grey.shade400,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Paid By bottom sheet ──────────────────────────────────────────────────
  void _showPaidBySheet(List<Member> members) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        decoration: const BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Who paid?', style: AppTheme.headingText),
            ),
            ...members.map((m) => Obx(() {
                  final isSelected =
                      expenseCtrl.selectedMember.value?.id == m.id;
                  return GestureDetector(
                    onTap: () {
                      expenseCtrl.selectedMember.value = m;
                      Get.back();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Constants.activeColor.withValues(alpha: 0.07)
                            : Constants.bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Constants.activeColor.withValues(alpha: 0.35)
                              : Colors.grey.shade100,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected
                                ? Constants.activeColor
                                : Colors.grey.shade200,
                            child: Text(
                              m.name![0].toUpperCase(),
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(m.name!,
                                style: AppTheme.subHeadingText.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                )),
                          ),
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Constants.activeColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  );
                })),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // ── Member row ────────────────────────────────────────────────────────────
  Widget _buildMemberRow(Member member, SplitType splitType) {
    return Obx(() {
      final isSelected = expenseCtrl.selectedMembers.contains(member.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => expenseCtrl.toggleMember(member.id!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Constants.activeColor.withValues(alpha: 0.06)
                  : Constants.bgColorLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Constants.activeColor.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Constants.activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Constants.activeColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Avatar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Constants.activeColor
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    member.name![0].toUpperCase(),
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name
                Expanded(
                  child: Text(
                    member.name!,
                    style: AppTheme.subHeadingText.copyWith(
                      color: isSelected
                          ? Constants.textDark
                          : Colors.grey.shade500,
                    ),
                  ),
                ),

                // Split input (exact / percentage)
                if (splitType != SplitType.equal && isSelected)
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: expenseCtrl.splitInputControllers[member.id],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                      textAlign: TextAlign.center,
                      style: AppTheme.subHeadingText,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        filled: true,
                        fillColor: Constants.bgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Constants.activeColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixText:
                            splitType == SplitType.percentage ? '%' : null,
                        prefixText: splitType == SplitType.exact ? '\$' : null,
                        suffixStyle: AppTheme.normalText
                            .copyWith(color: Colors.grey.shade500),
                        prefixStyle: AppTheme.normalText
                            .copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  ),

                // Equal badge
                if (splitType == SplitType.equal && isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Constants.activeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Equal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Constants.activeColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Skeletons ─────────────────────────────────────────────────────────────
  Widget _fieldSkeleton(double height) => Shimmer(
        child: ShimmerBox(height: height, borderRadius: 14),
      );

  Widget _membersSkeleton() {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 120, height: 13, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(width: 22, height: 22, borderRadius: 6),
                    const SizedBox(width: 12),
                    const ShimmerBox(
                        width: 36, height: 36, shape: BoxShape.circle),
                    const SizedBox(width: 12),
                    ShimmerBox(
                        width: 80.0 + i * 24, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _splitSectionTitle(SplitType type) {
    switch (type) {
      case SplitType.equal:
        return 'Split equally among';
      case SplitType.exact:
        return 'Enter amount per person';
      case SplitType.percentage:
        return 'Enter percentage per person';
    }
  }
}

// ── Amount hero card ──────────────────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.ctrl});
  final AddExpenseController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Constants.activeColor,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: ctrl.amountCtrl,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Constants.textDark,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0.00',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade200,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1.5,
            width: 80,
            decoration: BoxDecoration(
              color: Constants.activeColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ── Split type chips ──────────────────────────────────────────────────────────
class _SplitTypeChips extends StatelessWidget {
  const _SplitTypeChips({required this.selected, required this.onSelect});
  final SplitType selected;
  final ValueChanged<SplitType> onSelect;

  static const _labels = {
    SplitType.equal: 'Equally',
    SplitType.exact: 'By Amount',
    SplitType.percentage: 'By %',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: SplitType.values.map((type) {
          final isSelected = selected == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 38,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Constants.activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[type]!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Expense loading dialog ────────────────────────────────────────────────────
class _ExpenseLoadingDialog extends StatelessWidget {
  const _ExpenseLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Constants.activeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Constants.activeColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Saving expense',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Constants.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Just a moment…',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live total hint ───────────────────────────────────────────────────────────
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
    _recalculate();
    for (final m in widget.members) {
      widget.controllers[m.id]?.addListener(_recalculate);
    }
    widget.amountCtrl.addListener(_recalculate);
  }

  void _recalculate() {
    double sum = 0;
    for (final m in widget.members) {
      if (!widget.selectedMembers.contains(m.id)) continue;
      sum += double.tryParse(widget.controllers[m.id]?.text.trim() ?? '') ?? 0;
    }
    setState(() => _currentTotal = sum);
  }

  @override
  void dispose() {
    for (final m in widget.members) {
      widget.controllers[m.id]?.removeListener(_recalculate);
    }
    widget.amountCtrl.removeListener(_recalculate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPct = widget.splitType == SplitType.percentage;
    final target =
        isPct ? 100.0 : (double.tryParse(widget.amountCtrl.text.trim()) ?? 0);
    final remaining = target - _currentTotal;
    final isValid = remaining.abs() < 0.01;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isValid
            ? const Color(0xFF0DAD85).withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isValid
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                size: 15,
                color: isValid ? Constants.activeColor : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                isPct
                    ? '${_currentTotal.toStringAsFixed(1)}% of 100%'
                    : '\$${_currentTotal.toStringAsFixed(2)} of \$${target.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isValid ? Constants.activeColor : Colors.orange,
                ),
              ),
            ],
          ),
          if (!isValid)
            Text(
              isPct
                  ? '${remaining > 0 ? '+' : ''}${remaining.toStringAsFixed(1)}% left'
                  : '${remaining > 0 ? '+' : ''}\$${remaining.toStringAsFixed(2)} left',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500),
            ),
          if (isValid)
            Text(
              'Balanced ✓',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
