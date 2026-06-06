import 'package:get/get.dart';
import 'package:splittify/core/utils/cache_manager.dart';
import 'package:splittify/features/expenses/expense_service.dart';

import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/widgets/alert_widgets.dart';
import '../../friends/friends_controller.dart';
import '../Models/group_balances_model.dart';
import '../Models/group_expenses_model.dart';
import '../Models/group_members_model.dart';
import '../Models/group_summary_model.dart';
import '../group_service.dart';

class GroupsController extends GetxController {
  /// Register this from FriendsScreen to refresh friends after settlement
  Future<void> Function()? onBalanceChanged;

  RxList<GroupSummary> summaries = <GroupSummary>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSettling = false.obs;
  RxBool isLoadingBalances = false.obs;
  RxBool isLoadingMoreExpenses = false.obs;
  final GroupService _service = GroupService();
  final ExpenseService _expenseService = ExpenseService();
  final _cache = CacheManager();

  // ── Per-group caches ──────────────────────────────────────────────────────
  final RxMap<String, GroupExpenses> allGroupExpenses =
      <String, GroupExpenses>{}.obs;
  final RxMap<String, GroupMembersModel> allGroupMembers =
      <String, GroupMembersModel>{}.obs;
  final RxMap<String, GroupBalancesModel> allGroupBalances =
      <String, GroupBalancesModel>{}.obs;

  // ── Helper getters ────────────────────────────────────────────────────────
  GroupExpenses expensesFor(String groupId) =>
      allGroupExpenses[groupId] ?? GroupExpenses();
  GroupMembersModel membersFor(String groupId) =>
      allGroupMembers[groupId] ?? GroupMembersModel();
  GroupBalancesModel balancesFor(String groupId) =>
      allGroupBalances[groupId] ??
      GroupBalancesModel(
          balances: [], settlements: [], pairwise: [], balanceMode: null);

  /// Removes map entries whose cache TTL has expired.
  void pruneExpensesCache() {
    for (final id in allGroupExpenses.keys.toList()) {
      if (!_cache.isFresh(CacheKeys.groupExpenses(id))) {
        allGroupExpenses.remove(id);
      }
    }
    for (final id in allGroupMembers.keys.toList()) {
      if (!_cache.isFresh(CacheKeys.groupMembers(id))) {
        allGroupMembers.remove(id);
      }
    }
    for (final id in allGroupBalances.keys.toList()) {
      if (!_cache.isFresh(CacheKeys.groupBalances(id))) {
        allGroupBalances.remove(id);
      }
    }
  }

// ── Balances ──────────────────────────────────────────────────────────────
  Future<void> fetchGroupBalances({
    required String groupId,
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.groupBalances(groupId);
    if (!forceRefresh && _cache.isFresh(key, ttl: const Duration(seconds: 120)))
      return;
    try {
      isLoadingBalances.value = true;
      print("id = $groupId");
      allGroupBalances[groupId] =
          await _service.getGroupBalances(groupId: groupId);
      _cache.markFetched(key);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load balances');
    } finally {
      isLoadingBalances.value = false;
    }
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Future<void> fetchSummary({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache.isFresh(CacheKeys.summaries) &&
        summaries.isNotEmpty) return;
    try {
      isLoading.value = true;
      summaries.value = await _service.getSummary();
      _cache.markFetched(CacheKeys.summaries);
      if (onBalanceChanged != null) onBalanceChanged!();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load groups');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Expenses ──────────────────────────────────────────────────────────────

  Future<void> fetchGroupExpenses({
    required String groupId,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    final key = CacheKeys.groupExpenses(groupId);
    if (!loadMore &&
        !forceRefresh &&
        _cache.isFresh(key, ttl: const Duration(seconds: 120)) &&
        allGroupExpenses[groupId]?.expenses != null) return;

    try {
      if (loadMore) {
        isLoadingMoreExpenses.value = true;
      } else {
        isLoading.value = true;
      }

      final current = allGroupExpenses[groupId];
      final nextPage = loadMore ? ((current?.page ?? 0) + 1) : 1;

      final result = await _service.getExpenses(
        groupId: groupId,
        page: nextPage,
      );

      if (loadMore && current?.expenses != null) {
        final merged = GroupExpenses(
          count: result.count,
          total: result.total,
          page: result.page,
          hasMore: result.hasMore,
          expenses: [...current!.expenses!, ...result.expenses ?? []],
        );
        allGroupExpenses[groupId] = merged;
      } else {
        allGroupExpenses[groupId] = result;
        _cache.markFetched(key);
        if (!forceRefresh) {
          _cache.invalidate(CacheKeys.summaries);
          fetchSummary();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expenses');
    } finally {
      isLoading.value = false;
      isLoadingMoreExpenses.value = false;
    }
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Future<void> fetchGroupMembers({
    required String groupId,
    bool forceRefresh = false,
  }) async {
    final key = CacheKeys.groupMembers(groupId);
    if (!forceRefresh &&
        _cache.isFresh(key, ttl: const Duration(seconds: 120)) &&
        allGroupMembers[groupId]?.members != null) return;
    try {
      allGroupMembers[groupId] =
          await _service.getGroupMembers(groupId: groupId);
      _cache.markFetched(key);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load members');
    }
  }

  Future<void> settleExpense({
    required String groupId,
    required String toUserId,
    required double amount,
    int popCount = 2,
  }) async {
    try {
      isSettling.value = true;
      await _service.settleGroup(
        groupId: groupId,
        toUserId: toUserId,
        amount: amount,
      );
      _cache.invalidateAll([
        CacheKeys.summaries,
        CacheKeys.friends,
        CacheKeys.activity,
        CacheKeys.groupExpenses(groupId),
        CacheKeys.groupBalances(groupId),
      ]);
      await Future.wait([
        fetchGroupExpenses(groupId: groupId, forceRefresh: true),
        fetchSummary(forceRefresh: true),
      ]);
      // Refresh friends list if registered (callback set by FriendsScreen)

      AlertWidgets.hideLoadingDialog();
      for (int i = 0; i < popCount; i++) {
        Get.back();
      }
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
      _cache.invalidateAll([
        CacheKeys.summaries,
        CacheKeys.friends,
        CacheKeys.activity,
        CacheKeys.groupExpenses(groupId),
      ]);
      await Future.wait([
        fetchGroupExpenses(groupId: groupId, forceRefresh: true),
        fetchSummary(forceRefresh: true),
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
      _cache.invalidateAll([
        CacheKeys.summaries,
        CacheKeys.friends,
        CacheKeys.activity,
        CacheKeys.groupExpenses(groupId),
        CacheKeys.groupBalances(groupId),
      ]);
      await Future.wait([
        fetchGroupExpenses(groupId: groupId, forceRefresh: true),
        fetchSummary(forceRefresh: true),
      ]);
      SnackBarHelper.success("Settlement updated");
    } catch (e) {
      SnackBarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── NEW: Settings methods ────────────────────────────────────────────────────

  Future<Member?> addMember({
    required String groupId,
    required String email,
    required int index,
  }) async {
    final member = await _service.addMember(groupId: groupId, email: email);
    _cache.invalidateAll([
      CacheKeys.summaries,
      CacheKeys.groupMembers(groupId),
      CacheKeys.friends,
    ]);
    await Future.wait([
      fetchGroupMembers(groupId: groupId, forceRefresh: true),
      fetchSummary(forceRefresh: true),
    ]);
    return member;
  }

  Future<Member?> addMemberById({
    required String groupId,
    required String userId,
    required int index,
  }) async {
    final member =
        await _service.addMemberById(groupId: groupId, userId: userId);
    _cache.invalidateAll([
      CacheKeys.summaries,
      CacheKeys.groupMembers(groupId),
      CacheKeys.friends,
    ]);
    await Future.wait([
      fetchGroupMembers(groupId: groupId, forceRefresh: true),
      fetchSummary(forceRefresh: true),
    ]);
    return member;
  }

  Future<Member?> addMemberByContact({
    required String groupId,
    required String name,
    String? email,
    String? phone,
    required int index,
  }) async {
    final member = await _service.addMemberByContact(
      groupId: groupId,
      name: name,
      email: email,
      phone: phone,
    );
    _cache.invalidateAll([
      CacheKeys.summaries,
      CacheKeys.groupMembers(groupId),
      CacheKeys.friends,
    ]);
    await Future.wait([
      fetchGroupMembers(groupId: groupId, forceRefresh: true),
      fetchSummary(forceRefresh: true),
    ]);
    return member;
  }

  // ── Remove member ─────────────────────────────────────────────────────────

  Future<bool> removeMember({
    required String groupId,
    required String memberId,
    required int index,
  }) async {
    try {
      await _service.removeMember(groupId: groupId, memberId: memberId);
      _cache.invalidateAll([
        CacheKeys.summaries,
        CacheKeys.groupMembers(groupId),
        CacheKeys.friends,
      ]);
      await Future.wait([
        fetchGroupMembers(groupId: groupId, forceRefresh: true),
        fetchSummary(forceRefresh: true),
      ]);
      AlertWidgets.showSnackBar(message: 'Member removed');
      return true;
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

// ── Rename group ──────────────────────────────────────────────────────────

  Future<bool> renameGroup({
    required String groupId,
    required String name,
    required int index,
  }) async {
    try {
      await _service.renameGroup(groupId: groupId, name: name);
      // Update locally — no need to invalidate summaries for a rename
      summaries[index] = GroupSummary(
        id: summaries[index].id,
        name: name,
        emoji: summaries[index].emoji,
        defaultSplitType: summaries[index].defaultSplitType,
        createdBy: summaries[index].createdBy,
        adminId: summaries[index].adminId,
        balanceMode: summaries[index].balanceMode,
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

  // ── Update emoji ──────────────────────────────────────────────────────────

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
        adminId: summaries[index].adminId,
        balanceMode: summaries[index].balanceMode,
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

  // ── Update default split type ─────────────────────────────────────────────

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
        adminId: summaries[index].adminId,
        balanceMode: summaries[index].balanceMode,
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

  // ── Update balance mode ───────────────────────────────────────────────────

  Future<void> updateBalanceMode({
    required String groupId,
    required String balanceMode,
    required int index,
  }) async {
    try {
      await _service.updateBalanceMode(
        groupId: groupId,
        balanceMode: balanceMode,
      );
      final current = summaries[index];
      summaries[index] = GroupSummary(
        id: current.id,
        name: current.name,
        emoji: current.emoji,
        defaultSplitType: current.defaultSplitType,
        createdBy: current.createdBy,
        adminId: current.adminId,
        balanceMode: balanceMode,
        balance: current.balance,
        preview: current.preview,
        othersCount: current.othersCount,
      );
      summaries.refresh();
      _cache.invalidateAll([
        CacheKeys.groupBalances(groupId),
        CacheKeys.summaries,
        CacheKeys.friends,
      ]);
      await Future.wait([
        fetchSummary(forceRefresh: true),
        fetchGroupBalances(groupId: groupId, forceRefresh: true),
        Get.find<FriendsController>(tag: 'friends')
            .fetchFriends(forceRefresh: true),
      ]);
      AlertWidgets.showSnackBar(message: 'Balance mode updated');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Leave group ───────────────────────────────────────────────────────────

  Future<void> leaveGroup({
    required String groupId,
    required int index,
  }) async {
    try {
      await _service.leaveGroup(groupId: groupId);
      _cache.invalidate(CacheKeys.summaries);
      summaries.removeAt(index);
      summaries.refresh();
      Get.until((route) => route.isFirst);
      AlertWidgets.showSnackBar(message: 'You have left the group');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Delete group ──────────────────────────────────────────────────────────

  Future<void> deleteGroup({
    required String groupId,
    required int index,
  }) async {
    try {
      await _service.deleteGroup(groupId: groupId);
      _cache.invalidate(CacheKeys.summaries);
      summaries.removeAt(index);
      summaries.refresh();
      Get.until((route) => route.isFirst);
      AlertWidgets.showSnackBar(message: 'Group deleted');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ── Create group ──────────────────────────────────────────────────────────

  Future<void> createGroupWithFriends({
    required String name,
    required String emoji,
    required List<dynamic> friends,
  }) async {
    try {
      isLoading.value = true;
      final res = await _service.createGroup(name: name);
      final groupId = res['id'] as String;
      if (emoji != '🏠') {
        await _service.updateEmoji(groupId: groupId, emoji: emoji);
      }
      for (final friend in friends) {
        try {
          await _service.addMember(
              groupId: groupId, email: friend.email as String);
        } catch (_) {}
      }
      _cache.invalidateAll([
        CacheKeys.summaries,
        CacheKeys.friends,
      ]);
      await fetchSummary(forceRefresh: true);
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Clear cache on logout ─────────────────────────────────────────────────

  void clearCache() {
    _cache.clear();
    allGroupExpenses.clear();
    allGroupMembers.clear();
    allGroupBalances.clear();
  }

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }
}
