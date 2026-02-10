import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_expense_controller.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AddExpenseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: c.descriptionCtrl,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: c.amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: c.selectedPayer.value.isEmpty
                      ? null
                      : c.selectedPayer.value,
                  hint: const Text("Paid By"),
                  items: ["You", "Friend A", "Friend B"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedPayer.value = v ?? "",
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: c.submitExpense,
                child: const Text("Add Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
