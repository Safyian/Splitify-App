import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/alert_widgets.dart';
import '../groups/group_members_model.dart';
import '../groups/group_service.dart';
import '../groups/groups_controller.dart';
import 'expense_payload_model.dart';
import 'expense_service.dart';

class AddExpenseController extends GetxController {
  // ✅ Accept optional expense for edit mode
  final dynamic editExpense;
  AddExpenseController({this.editExpense});

  final descriptionCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  // var groupMembers = GroupMembersModel().obs;
  RxBool isLoading = false.obs;

  final GroupService _service = GroupService();
  final ExpenseService _expenseService = ExpenseService();

  var selectedMember = Rxn<Member>(); // Paid by
  var selectedSplitType = SplitType.equal.obs;
  var selectedMembers = <String>{}.obs; // stores selected member IDs

  /// userId → TextEditingController (for exact & percentage inputs)
  final Map<String, TextEditingController> splitInputControllers = {};

  // ── Edit mode ──────────────────────────────────────
  RxBool isEditMode = false.obs;
  String? editingExpenseId;

  // ─────────────────────────────────────────
  // Fetch Members
  // ─────────────────────────────────────────
  Future<void> fetchGroupMembers({required String groupId}) async {
    try {
      isLoading.value = true;
      await Get.find<GroupsController>().fetchGroupMembers(groupId: groupId);
      _initSplitControllers(); // ✅ isEditMode is already true here if editing

      // ✅ Load edit data AFTER controllers are initialized
      if (editExpense != null) {
        loadExpenseForEdit(editExpense);
      }
    } catch (e) {
      AlertWidgets.showSnackBar(message: "Failed to load group members");
    } finally {
      isLoading.value = false;
    }
  }

// Getter for convenience
  GroupMembersModel get groupMembersData =>
      Get.find<GroupsController>().groupMembers.value;

  /// Creates one TextEditingController per member
  /// Call this after members are loaded
  // void _initSplitControllers() {
  //   _disposeSplitControllers();
  //   for (final member in groupMembersData.members ?? []) {
  //     splitInputControllers[member.id!] = TextEditingController();
  //     selectedMembers.add(member.id!); // select all by default
  //   }
  // }
  void _initSplitControllers() {
    _disposeSplitControllers();
    // ✅ Add this
    print(
        "=== _initSplitControllers called, isEditMode: ${isEditMode.value} ===");
    for (final member in groupMembersData.members ?? []) {
      splitInputControllers[member.id!] = TextEditingController();
      if (!isEditMode.value) {
        selectedMembers.add(member.id!);
      }
    }
    // ✅ Add this
    print("selectedMembers after _initSplitControllers: $selectedMembers");
  }

  // ─────────────────────────────────────────
  // Submit Expense
  // ─────────────────────────────────────────

  Future<bool> submitExpense({required String groupId}) async {
    final desc = descriptionCtrl.text.trim();
    final amt = amountCtrl.text.trim();

    // Basic validation
    if (desc.isEmpty || amt.isEmpty) {
      AlertWidgets.showSnackBar(message: "Fill all fields");
      return false;
    }

    final amount = double.tryParse(amt);
    if (amount == null || amount <= 0) {
      AlertWidgets.showSnackBar(message: "Invalid amount");
      return false;
    }

    if (selectedMember.value == null) {
      // print("Select who paid");
      AlertWidgets.showSnackBar(message: "Select who paid");
      return false;
    }

    // Build splits
    List<SplitInput> splits;
    try {
      splits = _buildSplits(amount);
    } catch (e) {
      AlertWidgets.showSnackBar(message: e.toString());
      return false;
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

      if (isEditMode.value && editingExpenseId != null) {
        // ── Update existing expense ──
        await _expenseService.updateExpense(
          groupId: groupId,
          expenseId: editingExpenseId!,
          request: request,
        );
      }
      //
      else {
        // ── Create new expense ──
        await _expenseService.addExpense(
          groupId: groupId,
          request: request,
        );
      }
      await Future.wait([
        Get.find<GroupsController>().fetchGroupExpenses(groupId: groupId),
        Get.find<GroupsController>().fetchSummary()
      ]);
      print("=== AFTER REFRESH ===");
      print(
          "summaries: ${Get.find<GroupsController>().summaries.map((s) => s.balance.net).toList()}");

      _resetForm();
      return true;
    } catch (e) {
      AlertWidgets.showSnackBar(message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
      resetEditMode();
    }
  }

  void _resetForm() {
    descriptionCtrl.clear();
    amountCtrl.clear();
    selectedMember.value = null;
    selectedSplitType.value = SplitType.equal;
    selectedMembers.clear();
    for (final ctrl in splitInputControllers.values) {
      ctrl.clear();
    }
  }

  // ─────────────────────────────────────────
  // Build Splits based on selected type
  // ─────────────────────────────────────────
  List<SplitInput> _buildSplits(double totalAmount) {
    final members = groupMembersData.members ?? [];

    if (members.isEmpty) throw Exception("No members found");

    // ✅ Only include selected members
    final involvedMembers =
        members.where((m) => selectedMembers.contains(m.id)).toList();

    print("=== _buildSplits ===");
    print("selectedMembers: $selectedMembers");
    print(
        "involvedMembers: ${involvedMembers.map((m) => '${m.name}:${m.id}').toList()}");
    print("splitType: ${selectedSplitType.value}");
    print("===================");

    if (involvedMembers.isEmpty) {
      throw Exception("Select at least one member to split with");
    }

    switch (selectedSplitType.value) {
      case SplitType.equal:
        // Just pass user ids — backend handles the math
        return involvedMembers.map((m) => SplitInput(user: m.id!)).toList();

      case SplitType.exact:
        double sum = 0;
        final splits = involvedMembers.map((m) {
          final val = double.tryParse(
            splitInputControllers[m.id!]?.text.trim() ?? '',
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
        final splits = involvedMembers.map((m) {
          final val = double.tryParse(
            splitInputControllers[m.id!]?.text.trim() ?? '',
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

  String groupId = '';

  //
  // Pre-fill form for editing
  void loadExpenseForEdit(dynamic expense) {
    isEditMode.value = true;
    editingExpenseId = expense.id;

    // ✅ Add this
    print("=== LOAD EXPENSE FOR EDIT ===");
    print("expense.splits: ${expense.splits?.map((s) => s.user?.id).toList()}");

    descriptionCtrl.text = expense.description ?? '';
    amountCtrl.text = expense.amount?.toString() ?? '';

    // Pre-fill payer
    final members = groupMembersData.members ?? [];
    selectedMember.value = members.firstWhereOrNull(
      (m) => m.id! == expense.paidBy?.id,
    );

    // ✅ Pre-fill selected members from existing splits
    selectedMembers.clear();
    for (final split in (expense.splits ?? [])) {
      if (split.user?.id != null) {
        selectedMembers.add(split.user!.id!);
      }
    }

    print("selectedMembers after clear+fill: $selectedMembers");
    print("==============================");

    // Pre-fill split type
    switch (expense.splitType) {
      case 'equal':
        selectedSplitType.value = SplitType.equal;
        break;
      case 'exact':
        selectedSplitType.value = SplitType.exact;
        break;
      case 'percentage':
        selectedSplitType.value = SplitType.percentage;
        break;
      default:
        selectedSplitType.value = SplitType.equal;
    }

    // Pre-fill split input controllers
    for (final split in (expense.splits ?? [])) {
      final userId = split.user?.id;
      if (userId == null) continue;
      if (!splitInputControllers.containsKey(userId)) continue;

      switch (expense.splitType) {
        case 'exact':
          splitInputControllers[userId]?.text =
              split.amount?.toStringAsFixed(2) ?? '';
          break;
        case 'percentage':
          splitInputControllers[userId]?.text =
              split.percentage?.toStringAsFixed(1) ?? '';
          break;
        case 'equal':
        default:
          splitInputControllers[userId]?.text = '';
          break;
      }
    }
  }

  void resetEditMode() {
    isEditMode.value = false;
    editingExpenseId = null;
  }

  void toggleMember(String memberId) {
    if (selectedMembers.contains(memberId)) {
      selectedMembers.remove(memberId);
    } else {
      selectedMembers.add(memberId);
    }
  }

  @override
  void onClose() {
    descriptionCtrl.dispose();
    amountCtrl.dispose();
    _disposeSplitControllers();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // ✅ Set edit mode BEFORE fetchGroupMembers triggers _initSplitControllers
    if (editExpense != null) {
      isEditMode.value = true;
      editingExpenseId = editExpense.id;
    }

    if (groupId.isNotEmpty) {
      fetchGroupMembers(groupId: groupId);
    }
  }
}
