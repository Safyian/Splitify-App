import 'package:get/get.dart';
import 'package:splitify/features/expenses/expense_service.dart';

import '../../core/utils/snackbar_helper.dart';
import '../../shared/widgets/alert_widgets.dart';
import 'group_balances_model.dart';
import 'group_expenses_model.dart';
import 'group_members_model.dart';
import 'group_service.dart';
import 'group_summary_model.dart';

class GroupsController extends GetxController {
  RxList<GroupSummary> summaries = <GroupSummary>[].obs;
  var groupExpenses = GroupExpenses().obs;
  RxBool isLoading = false.obs;
  RxBool isSettling = false.obs;
  final GroupService _service = GroupService();
  final ExpenseService _expenseService = ExpenseService();
  var groupBalances =
      GroupBalancesModel(balances: [], settlements: [], pairwise: []).obs;
  var groupMembers = GroupMembersModel().obs;

  // ── Existing methods ─────────────────────────────────────────────────────────

  Future<void> fetchGroupBalances({required String groupId}) async {
    try {
      groupBalances.value = await _service.getGroupBalances(groupId: groupId);
    } catch (e) {
      Get.snackbar("Error", "Failed to load balances");
    }
  }

  Future<void> fetchSummary() async {
    try {
      isLoading.value = true;
      summaries.value = await _service.getSummary();
    } catch (e) {
      Get.snackbar("Error", "Failed to load groups");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupExpenses({required String groupId}) async {
    try {
      isLoading.value = true;
      groupExpenses.value = await _service.getExpenses(groupId: groupId);
    } catch (e) {
      Get.snackbar("Error", "Failed to load groups");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGroupMembers({required String groupId}) async {
    try {
      isLoading.value = true;
      groupMembers.value = await _service.getGroupMembers(groupId: groupId);
    } catch (e) {
      Get.snackbar("Error", "Failed to load members");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> settleExpense({
    required String groupId,
    required String toUserId,
    required double amount,
  }) async {
    try {
      isSettling.value = true;
      await _service.settleGroup(
        groupId: groupId,
        toUserId: toUserId,
        amount: amount,
      );
      await fetchGroupExpenses(groupId: groupId);
      await fetchSummary();
      AlertWidgets.hideLoadingDialog();
      Get.back();
      Get.back();
      AlertWidgets.showSnackBar(message: 'Amount Settled Successfully!');
    } catch (e) {
      AlertWidgets.hideLoadingDialog();
      AlertWidgets.showSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      isSettling.value = false;
    }
  }

  Future<void> deleteExpense({
    required String groupId,
    required String expenseId,
  }) async {
    try {
      isLoading.value = true;
      await _expenseService.deleteExpense(
        groupId: groupId,
        expenseId: expenseId,
      );
      await Future.wait([
        fetchGroupExpenses(groupId: groupId),
        fetchSummary(),
      ]);
    } catch (e) {
      // SnackBarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettlement({
    required String groupId,
    required String expenseId,
    required double amount,
  }) async {
    try {
      isLoading.value = true;
      await _expenseService.updateSettlement(
        groupId: groupId,
        expenseId: expenseId,
        amount: amount,
      );
      await Future.wait([
        fetchGroupExpenses(groupId: groupId),
        fetchSummary(),
      ]);
      SnackBarHelper.success("Settlement updated");
    } catch (e) {
      SnackBarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── NEW: Settings methods ────────────────────────────────────────────────────

  Future<void> addMember({
    required String groupId,
    required String email,
    required int index,
  }) async {
    try {
      await _service.addMember(groupId: groupId, email: email);
      await Future.wait([
        fetchGroupMembers(groupId: groupId),
        fetchSummary(),
      ]);
      AlertWidgets.showSnackBar(message: 'Member added successfully');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> removeMember({
    required String groupId,
    required String memberId,
    required int index,
  }) async {
    try {
      await _service.removeMember(groupId: groupId, memberId: memberId);
      await Future.wait([
        fetchGroupMembers(groupId: groupId),
        fetchSummary(),
      ]);
      AlertWidgets.showSnackBar(message: 'Member removed');
      return true;
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> renameGroup({
    required String groupId,
    required String name,
    required int index,
  }) async {
    try {
      await _service.renameGroup(groupId: groupId, name: name);
      // Update locally so UI reflects immediately without full refetch
      summaries[index] = GroupSummary(
        id: summaries[index].id,
        name: name,
        emoji: summaries[index].emoji,
        defaultSplitType: summaries[index].defaultSplitType,
        createdBy: summaries[index].createdBy,
        balance: summaries[index].balance,
        preview: summaries[index].preview,
        othersCount: summaries[index].othersCount,
      );
      summaries.refresh();
      AlertWidgets.showSnackBar(message: 'Group renamed');
      return true;
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> updateEmoji({
    required String groupId,
    required String emoji,
    required int index,
  }) async {
    try {
      await _service.updateEmoji(groupId: groupId, emoji: emoji);
      summaries[index] = GroupSummary(
        id: summaries[index].id,
        name: summaries[index].name,
        emoji: emoji,
        defaultSplitType: summaries[index].defaultSplitType,
        createdBy: summaries[index].createdBy,
        balance: summaries[index].balance,
        preview: summaries[index].preview,
        othersCount: summaries[index].othersCount,
      );
      summaries.refresh();
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateDefaultSplitType({
    required String groupId,
    required String splitType,
    required int index,
  }) async {
    try {
      await _service.updateDefaultSplitType(
          groupId: groupId, splitType: splitType);
      summaries[index] = GroupSummary(
        id: summaries[index].id,
        name: summaries[index].name,
        emoji: summaries[index].emoji,
        defaultSplitType: splitType,
        createdBy: summaries[index].createdBy,
        balance: summaries[index].balance,
        preview: summaries[index].preview,
        othersCount: summaries[index].othersCount,
      );
      summaries.refresh();
      AlertWidgets.showSnackBar(message: 'Default split type updated');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> leaveGroup({
    required String groupId,
    required int index,
  }) async {
    try {
      await _service.leaveGroup(groupId: groupId);
      summaries.removeAt(index);
      summaries.refresh();
      Get.until((route) => route.isFirst);
      AlertWidgets.showSnackBar(message: 'You have left the group');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteGroup({
    required String groupId,
    required int index,
  }) async {
    try {
      await _service.deleteGroup(groupId: groupId);
      summaries.removeAt(index);
      summaries.refresh();
      Get.until((route) => route.isFirst);
      AlertWidgets.showSnackBar(message: 'Group deleted');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }
}
