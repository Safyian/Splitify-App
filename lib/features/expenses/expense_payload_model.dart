// split_type.dart
enum SplitType { equal, exact, percentage }

extension SplitTypeExtension on SplitType {
  String get value {
    switch (this) {
      case SplitType.equal:
        return 'equal';
      case SplitType.exact:
        return 'exact';
      case SplitType.percentage:
        return 'percentage';
    }
  }
}

// split_input.dart
class SplitInput {
  final String user;
  final double? amount; // for exact
  final double? percentage; // for percentage
  // equal needs only user

  const SplitInput({
    required this.user,
    this.amount,
    this.percentage,
  });

  Map<String, dynamic> toJson(SplitType splitType) {
    switch (splitType) {
      case SplitType.exact:
        return {'user': user, 'amount': amount};
      case SplitType.percentage:
        return {'user': user, 'percentage': percentage};
      case SplitType.equal:
        return {'user': user};
    }
  }
}

// add_expense_request.dart
class AddExpenseRequest {
  final String description;
  final double amount;
  final String paidBy;
  final SplitType splitType;
  final List<SplitInput> splits;

  const AddExpenseRequest({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'splitType': splitType.value,
        'splits': splits.map((s) => s.toJson(splitType)).toList(),
      };
}
