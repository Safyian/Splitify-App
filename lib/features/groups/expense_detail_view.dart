import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splittify/core/constants/constants.dart';
import 'package:splittify/core/theme/app_themes.dart';
import 'package:splittify/core/utils/date_helper.dart';
import 'package:splittify/core/utils/expense_icon_helper.dart';
import 'package:splittify/features/expenses/add_expense_controller.dart';
import 'package:splittify/features/expenses/add_expense_view.dart';
import 'package:splittify/features/groups/groups_controller.dart';
import 'package:splittify/shared/widgets/app_dialogs.dart';

class ExpenseDetailView extends StatelessWidget {
  const ExpenseDetailView({
    super.key,
    required this.expense,
    required this.myId,
    required this.groupIndex,
  });

  final dynamic expense;
  final String? myId;
  final int groupIndex;

  bool get _isSettlement => expense.description == "Settlement";
  bool get _iPaid => expense.paidBy?.id == myId;

  double get _myAmount {
    final splits = expense.splits ?? [];
    double amount = 0.0;
    for (final split in splits) {
      final isMe = split.user?.id == myId;
      if (_iPaid && !isMe) {
        amount =
            double.parse((amount + (split.amount ?? 0)).toStringAsFixed(2));
      } else if (!_iPaid && isMe) {
        amount = double.parse((split.amount ?? 0).toStringAsFixed(2));
      }
    }
    return amount;
  }

  void _goToEditExpense() {
    if (_isSettlement) {
      _showEditSettlementDialog();
    } else {
      Get.back();
      final groupCtrl = Get.find<GroupsController>();
      Get.delete<AddExpenseController>(force: true);

      final expenseCtrl = AddExpenseController(editExpense: expense);
      expenseCtrl.groupId =
          groupCtrl.membersFor(expense.group ?? '').members != null
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
                Get.back(); // close dialog
                Get.back(); // close ExpenseDetailView
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

  Future<void> _confirmDelete(BuildContext context) async {
    final groupCtrl = Get.find<GroupsController>();
    final confirmed = await AppDialogs.confirm(
      title: _isSettlement ? 'Delete Settlement' : 'Delete Expense',
      message: _isSettlement
          ? 'Are you sure you want to delete this settlement? This cannot be undone.'
          : 'Are you sure you want to delete "${expense.description}"? This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Constants.redColor,
    );

    if (confirmed) {
      await groupCtrl.deleteExpense(
        groupId: expense.group,
        expenseId: expense.id ?? '',
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSettlement = _isSettlement;
    final iPaid = _iPaid;
    final myAmount = _myAmount;
    final splits = expense.splits ?? [];

    final sortedSplits = [...splits]..sort((a, b) {
        if (a.user?.id == myId) return -1;
        if (b.user?.id == myId) return 1;
        return 0;
      });

    final rawSplitType = expense.splitType ?? 'equal';
    final splitTypeLabel = (rawSplitType as String).isNotEmpty
        ? rawSplitType[0].toUpperCase() + rawSplitType.substring(1)
        : rawSplitType;

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
        title: Text(
          isSettlement ? 'Settlement' : 'Expense Detail',
          style: AppTheme.headingText,
        ),
        actions: [
          GestureDetector(
            onTap: () => _goToEditExpense(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.activeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8.r),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// ─────────────────────────────────────────────────────────────
// SECTION 1: HEADER
// ─────────────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: Constants.activeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      ExpenseIconHelper.resolve(
                        expense.description as String?,
                        isSettlement: _isSettlement,
                      ),
                      color: Constants.activeColor,
                      size: 21.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSettlement
                              ? 'Settlement'
                              : (expense.description ?? ''),
                          textAlign: TextAlign.justify,
                          style: AppTheme.normalText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              SplitifyDateUtils.formatExpenseDate(
                                expense.createdAt,
                              ),
                              style: AppTheme.normalText.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 11.sp,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
// ─────────────────────────────────────────────────────────────
// SECTION 2: AMOUNT CARD
// ─────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: AppTheme.normalText.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 12.sp,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${(expense.amount ?? 0.0).toStringAsFixed(2)}',
                              style: AppTheme.headingText.copyWith(
                                fontSize: 26.sp,
                                color: Constants.activeColor,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Constants.activeColor.withAlpha(14),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 9.r,
                                    backgroundColor:
                                        Constants.activeColor.withAlpha(24),
                                    child: Text(
                                      (iPaid
                                              ? 'Y'
                                              : (expense.paidBy?.name ??
                                                  'U')[0])
                                          .toUpperCase(),
                                      style: AppTheme.normalText.copyWith(
                                        color: Constants.activeColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Paid by ',
                                          style: AppTheme.normalText.copyWith(
                                            color: Colors.grey.shade700,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                        TextSpan(
                                          text: iPaid
                                              ? 'You'
                                              : (expense.paidBy?.name ?? ''),
                                          style: AppTheme.normalText.copyWith(
                                            color: Constants.activeColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSettlement) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Constants.bgColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 14.r,
                                      backgroundColor:
                                          Constants.activeColor.withAlpha(25),
                                      child: Text(
                                        (iPaid
                                                ? 'You'
                                                : (expense.paidBy?.name ??
                                                    'U'))[0]
                                            .toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Constants.activeColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      iPaid
                                          ? 'You'
                                          : (expense.paidBy?.name ?? ''),
                                      style: AppTheme.normalText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16.sp,
                                      color: Constants.activeColor,
                                    ),
                                    SizedBox(width: 10.w),
                                    Builder(builder: (context) {
                                      final splits = expense.splits ?? [];
                                      final recipientSplit =
                                          splits.isNotEmpty ? splits[0] : null;
                                      final recipientId =
                                          recipientSplit?.user?.id ?? '';
                                      final recipientName = recipientId == myId
                                          ? 'You'
                                          : (recipientSplit?.user?.name ??
                                              'Unknown');
                                      final initial =
                                          recipientName[0].toUpperCase();
                                      final recipientColor =
                                          recipientId == myId
                                              ? Constants.redColor
                                              : Constants.activeColor;

                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14.r,
                                            backgroundColor:
                                                recipientColor.withAlpha(25),
                                            child: Text(
                                              initial,
                                              style: GoogleFonts.inter(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                                color: recipientColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            recipientName,
                                            style:
                                                AppTheme.normalText.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
                                              color: recipientColor,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    const Spacer(),
                                    Text(
                                      '\$${(expense.amount ?? 0.0).toStringAsFixed(2)}',
                                      style: AppTheme.headingText.copyWith(
                                        fontSize: 14.sp,
                                        color: Constants.activeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Constants.activeColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Constants.activeColor,
                          size: 21.w,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: Colors.grey.withAlpha(35),
                    height: 0,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Constants.bgColor,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: Constants.activeColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  isSettlement
                                      ? Icons.swap_horiz_rounded
                                      : Icons.group_outlined,
                                  color: Constants.activeColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSettlement
                                        ? 'Transferred'
                                        : 'Split $splitTypeLabel',
                                    style: AppTheme.normalText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSettlement
                                        ? ''
                                        : '${splits.length} people',
                                    style: AppTheme.normalText.copyWith(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: iPaid
                                ? Constants.activeColor.withAlpha(10)
                                : Constants.redColor.withAlpha(10),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: iPaid
                                      ? Constants.activeColor.withAlpha(25)
                                      : Constants.redColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  iPaid
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: iPaid
                                      ? Constants.activeColor
                                      : Constants.redColor,
                                  size: 18,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    iPaid ? 'You lent' : 'You borrowed',
                                    style: AppTheme.normalText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${myAmount.toStringAsFixed(2)}',
                                    style: AppTheme.normalText.copyWith(
                                      color: iPaid
                                          ? Constants.activeColor
                                          : Constants.redColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
// ─────────────────────────────────────────────────────────────
// Section 3: Split between
// ─────────────────────────────────────────────────────────────
            if (!isSettlement) ...[
              Row(
                children: [
                  Text('Split between', style: AppTheme.subHeadingText),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Constants.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$splitTypeLabel · ${splits.length} people',
                      style: AppTheme.normalText.copyWith(
                        color: Colors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ...sortedSplits.map<Widget>((split) {
                final isMe = split.user?.id == myId;
                final name = isMe ? 'You' : (split.user?.name ?? 'Unknown');
                final splitAmount = (split.amount ?? 0.0) as double;
                final total = (expense.amount ?? 1.0) as double;
                final pct = (splitAmount / (total == 0 ? 1.0 : total) * 100)
                    .toStringAsFixed(1);
                final initial = name[0].toUpperCase();

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(10.r),
                    border: isMe
                        ? Border.all(
                            color: Constants.activeColor.withAlpha(80),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Constants.activeColor.withAlpha(25),
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: Constants.activeColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(name,
                                      style: AppTheme.normalText,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '\$${splitAmount.toStringAsFixed(2)}',
                                      style: AppTheme.normalText.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (rawSplitType != 'exact') ...[
                                      SizedBox(width: 4.w),
                                      Text(
                                        '$pct%',
                                        style: AppTheme.normalText.copyWith(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: splitAmount / (total == 0 ? 1.0 : total),
                                minHeight: 3.h,
                                backgroundColor: Colors.grey.withAlpha(30),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isMe
                                      ? (iPaid
                                          ? Constants.activeColor
                                          : Constants.redColor)
                                      : Constants.activeColor.withAlpha(150),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // ── Section 4: Delete button ───────────────────────
            SizedBox(height: 6.h),
            Divider(height: 1, color: Colors.grey.withAlpha(30)),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Constants.redColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Constants.redColor.withAlpha(40)),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: Constants.redColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete expense',
                      style: AppTheme.headingText.copyWith(
                        fontSize: 14.sp,
                        color: Constants.redColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
