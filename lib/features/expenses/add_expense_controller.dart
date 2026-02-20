import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../groups/group_members_model.dart';
import '../groups/group_service.dart';
import 'expense_payload_model.dart';
import 'expense_service.dart';

class AddExpenseController extends GetxController {
  final descriptionCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  var groupMembers = GroupMembersModel().obs;
  RxBool isLoading = false.obs;

  final GroupService _service = GroupService();
  final ExpenseService _expenseService = ExpenseService();

  var selectedMember = Rxn<Member>(); // Paid by
  var selectedSplitType = SplitType.equal.obs;

  /// userId → TextEditingController (for exact & percentage inputs)
  final Map<String, TextEditingController> splitInputControllers = {};

  // ─────────────────────────────────────────
  // Fetch Members
  // ─────────────────────────────────────────

  Future<void> fetchGroupMembers({required String groupId}) async {
    try {
      isLoading.value = true;
      groupMembers.value = await _service.getGroupMembers(groupId: groupId);
      _initSplitControllers();
    } catch (e) {
      Get.snackbar("Error", "Failed to load group members");
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates one TextEditingController per member
  /// Call this after members are loaded
  void _initSplitControllers() {
    _disposeSplitControllers();
    for (final member in groupMembers.value.members ?? []) {
      splitInputControllers[member.id!] = TextEditingController();
    }
  }

  // ─────────────────────────────────────────
  // Submit Expense
  // ─────────────────────────────────────────

  Future<void> submitExpense({required String groupId}) async {
    final desc = descriptionCtrl.text.trim();
    final amt = amountCtrl.text.trim();

    // Basic validation
    if (desc.isEmpty || amt.isEmpty) {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    final amount = double.tryParse(amt);
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Invalid amount");
      return;
    }

    if (selectedMember.value == null) {
      Get.snackbar("Error", "Select who paid");
      return;
    }

    // Build splits
    List<SplitInput> splits;
    try {
      splits = _buildSplits(amount);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return;
    }

    // Call API
    try {
      isLoading.value = true;

      final request = AddExpenseRequest(
        description: desc,
        amount: amount,
        paidBy: selectedMember.value!.id!,
        splitType: selectedSplitType.value,
        splits: splits,
      );

      await _expenseService.addExpense(
        groupId: groupId,
        request: request,
      );

      // ── Refresh both screens ──────────────────
      // final groupCtrl = Get.find<GroupsController>();
      // await Future.wait([
      //   groupCtrl.fetchSummary(), // refreshes GroupsView
      //   groupCtrl.fetchGroupExpenses(
      //       groupId: groupId), // refreshes GroupExpenseView
      // ]);
      // ─────────────────────────────────────────

      Get.back(result: true);
      Get.snackbar("Success", "Expense added successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────
  // Build Splits based on selected type
  // ─────────────────────────────────────────

  List<SplitInput> _buildSplits(double totalAmount) {
    final members = groupMembers.value.members ?? [];

    if (members.isEmpty) throw Exception("No members found");

    switch (selectedSplitType.value) {
      case SplitType.equal:
        // Just pass user ids — backend handles the math
        return members.map((m) => SplitInput(user: m.id!)).toList();

      case SplitType.exact:
        double sum = 0;
        final splits = members.map((m) {
          final val = double.tryParse(
            splitInputControllers[m.id]?.text.trim() ?? '',
          );
          if (val == null || val <= 0) {
            throw Exception("Enter valid amount for ${m.name}");
          }
          sum += val;
          return SplitInput(user: m.id!, amount: val);
        }).toList();

        if ((sum - totalAmount).abs() > 0.01) {
          throw Exception(
            "Amounts (${sum.toStringAsFixed(2)}) must equal total (${totalAmount.toStringAsFixed(2)})",
          );
        }
        return splits;

      case SplitType.percentage:
        double totalPct = 0;
        final splits = members.map((m) {
          final val = double.tryParse(
            splitInputControllers[m.id]?.text.trim() ?? '',
          );
          if (val == null || val <= 0) {
            throw Exception("Enter valid percentage for ${m.name}");
          }
          totalPct += val;
          return SplitInput(user: m.id!, percentage: val);
        }).toList();

        if ((totalPct - 100).abs() > 0.001) {
          throw Exception(
            "Percentages must total 100% (currently ${totalPct.toStringAsFixed(1)}%)",
          );
        }
        return splits;
    }
  }

  // ─────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────

  void _disposeSplitControllers() {
    for (final ctrl in splitInputControllers.values) {
      ctrl.dispose();
    }
    splitInputControllers.clear();
  }

  @override
  void onClose() {
    descriptionCtrl.dispose();
    amountCtrl.dispose();
    _disposeSplitControllers();
    super.onClose();
  }
}
