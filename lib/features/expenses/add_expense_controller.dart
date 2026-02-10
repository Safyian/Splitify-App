import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseController extends GetxController {
  final descriptionCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  var selectedPayer = "".obs;

  void submitExpense() {
    final desc = descriptionCtrl.text.trim();
    final amt = amountCtrl.text.trim();

    if (desc.isEmpty || amt.isEmpty) {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    final amount = double.tryParse(amt);
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Invalid amount");
      return;
    }

    Get.snackbar("Success", "Expense ready to submit");

    /// Later:
    /// call API here
  }

  @override
  void onClose() {
    descriptionCtrl.dispose();
    amountCtrl.dispose();
    super.onClose();
  }
}
