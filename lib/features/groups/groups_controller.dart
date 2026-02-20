import 'package:get/get.dart';

import '../../shared/widgets/alert_widgets.dart';
import 'group_expenses_model.dart';
import 'group_service.dart';
import 'group_summary_model.dart';

class GroupsController extends GetxController {
  RxList<GroupSummary> summaries = <GroupSummary>[].obs;
  var groupExpenses = GroupExpenses().obs;
  RxBool isLoading = false.obs;
  RxBool isSettling = false.obs;
  final GroupService _service = GroupService();

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
      await fetchSummary(); // refresh summary
      AlertWidgets.hideLoadingDialog();
      Get.back();
      Get.back();
      AlertWidgets.showSnackBar(message: 'Amount Settled Successfully!');
    } catch (e) {
      AlertWidgets.hideLoadingDialog();
      AlertWidgets.showSnackBar(message: 'Error: ${e.toString()},');
    } finally {
      isSettling.value = false;
    }
  }

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }
}
