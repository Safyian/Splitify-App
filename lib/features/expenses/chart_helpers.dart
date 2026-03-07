// lib/features/expenses/chart_helpers.dart

import '../groups/group_expenses_model.dart'; // your existing model

class MemberSpending {
  final String name;
  final double amount;
  final int colorIndex;

  MemberSpending({
    required this.name,
    required this.amount,
    required this.colorIndex,
  });
}

class MonthlySpending {
  final String month; // "Jan", "Feb" etc
  final double amount;

  MonthlySpending({required this.month, required this.amount});
}

class WeeklySpending {
  final String label; // "W1", "W2" etc
  final double amount;

  WeeklySpending({required this.label, required this.amount});
}

class MyShareData {
  final double iPaid; // total I paid for others
  final double othersOweMe; // total others owe me
  final double iOwe; // total I owe others

  MyShareData({
    required this.iPaid,
    required this.othersOweMe,
    required this.iOwe,
  });
}

class ChartHelpers {
  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // ── Donut: spending per member ──────────────────────────────
  static List<MemberSpending> spendingByMember(List<Expense> expenses) {
    final Map<String, double> totals = {};
    final Map<String, String> names = {};

    for (final e in expenses) {
      if (e.description == "Settlement") continue; // exclude settlements
      final id = e.paidBy?.id ?? '';
      final name = e.paidBy?.name ?? 'Unknown';
      totals[id] = (totals[id] ?? 0) + (e.amount ?? 0);
      names[id] = name;
    }

    int i = 0;
    return totals.entries.map((entry) {
      return MemberSpending(
        name: names[entry.key] ?? 'Unknown',
        amount: entry.value,
        colorIndex: i++,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // ── Bar: monthly spending ───────────────────────────────────
  static List<MonthlySpending> spendingByMonth(List<Expense> expenses) {
    final Map<int, double> totals = {};

    for (final e in expenses) {
      if (e.description == "Settlement") continue;
      final date = e.createdAt; // DateTime from your model
      if (date == null) continue;
      totals[date.month] = (totals[date.month] ?? 0) + (e.amount ?? 0);
    }

    // Only return months that have data
    return totals.entries.map((entry) {
      return MonthlySpending(
        month: _monthLabels[entry.key - 1],
        amount: entry.value,
      );
    }).toList()
      ..sort((a, b) => _monthLabels
          .indexOf(a.month)
          .compareTo(_monthLabels.indexOf(b.month)));
  }

// Add this inside ChartHelpers class
  static List<WeeklySpending> spendingByWeek(List<Expense> expenses) {
    final Map<int, double> totals = {};

    for (final e in expenses) {
      if (e.description == "Settlement") continue;
      final date = e.createdAt;
      if (date == null) continue;

      // Week number within the year
      final weekNum = _weekOfYear(date);
      totals[weekNum] = (totals[weekNum] ?? 0) + (e.amount ?? 0);
    }

    return totals.entries.map((entry) {
      return WeeklySpending(
        label: "W${entry.key}",
        amount: entry.value,
      );
    }).toList()
      ..sort((a, b) {
        final aNum = int.parse(a.label.substring(1));
        final bNum = int.parse(b.label.substring(1));
        return aNum.compareTo(bNum);
      });
  }

  static int _weekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final diff = date.difference(startOfYear).inDays;
    return (diff / 7).floor() + 1;
  }

  // Add inside ChartHelpers
  static MyShareData myShareData(List<Expense> expenses, String myId) {
    double iPaid = 0;
    double iOwe = 0;

    for (final e in expenses) {
      if (e.description == "Settlement") continue;

      final paid = e.paidBy?.id == myId;

      e.splits?.forEach((split) {
        if (paid && split.user?.id != myId) {
// I paid for someone else
          iPaid += split.amount ?? 0;
        } else if (!paid && split.user?.id == myId) {
// Someone else paid, I owe my share
          iOwe += split.amount ?? 0;
        }
      });
    }

    return MyShareData(
      iPaid: double.parse(iPaid.toStringAsFixed(2)),
      othersOweMe: double.parse(iPaid.toStringAsFixed(2)),
      iOwe: double.parse(iOwe.toStringAsFixed(2)),
    );
  }

  // Add inside ChartHelpers
  static List<MemberTotals> memberTotals(List<Expense> expenses) {
    final Map<String, double> paid = {};
    final Map<String, double> share = {};
    final Map<String, String> names = {};

    for (final e in expenses) {
      if (e.description == "Settlement") continue;

      final payerId = e.paidBy?.id ?? '';
      final payerName = e.paidBy?.name ?? 'Unknown';

      paid[payerId] = (paid[payerId] ?? 0) + (e.amount ?? 0);
      names[payerId] = payerName;

      e.splits?.forEach((split) {
        final uid = split.user?.id ?? '';
        final uname = split.user?.name ?? 'Unknown';
        share[uid] = (share[uid] ?? 0) + (split.amount ?? 0);
        names[uid] = uname;
      });
    }

// Merge all userIds
    final allIds = {...paid.keys, ...share.keys};

    return allIds.map((id) {
      final p = double.parse((paid[id] ?? 0).toStringAsFixed(2));
      final s = double.parse((share[id] ?? 0).toStringAsFixed(2));
      return MemberTotals(
        userId: id,
        name: names[id] ?? 'Unknown',
        totalPaid: p,
        totalShare: s,
        net: double.parse((p - s).toStringAsFixed(2)),
      );
    }).toList()
      ..sort((a, b) => b.totalPaid.compareTo(a.totalPaid));
  }
}

class MemberTotals {
  final String userId;
  final String name;
  final double totalPaid; // how much they paid out
  final double totalShare; // how much they owe in splits
  final double net; // totalPaid - totalShare

  MemberTotals({
    required this.userId,
    required this.name,
    required this.totalPaid,
    required this.totalShare,
    required this.net,
  });
}
