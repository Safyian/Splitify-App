import 'package:get/get.dart';

import 'group_expenses_model.dart';
import 'group_service.dart';
import 'group_summary_model.dart';

class GroupsController extends GetxController {
  RxList<GroupSummary> summaries = <GroupSummary>[].obs;
  var groupExpenses = GroupExpenses().obs;
  RxBool isLoading = false.obs;
  final GroupService _service = GroupService();

  void fetchSummary() async {
    try {
      isLoading.value = true;
      summaries.value = await _service.getSummary();
    } catch (e) {
      Get.snackbar("Error", "Failed to load groups");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchGroupExpenses({required String groupId}) async {
    try {
      isLoading.value = true;
      groupExpenses.value = await _service.getExpenses(groupId: groupId);
    } catch (e) {
      Get.snackbar("Error", "Failed to load groups");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }
}
