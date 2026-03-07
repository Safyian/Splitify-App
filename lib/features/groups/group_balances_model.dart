class GroupBalancesModel {
  final List<MemberBalance> balances;
  final List<SettlementDebt> settlements;
  final List<PairwiseDebt> pairwise;

  GroupBalancesModel({
    required this.balances,
    required this.settlements,
    required this.pairwise,
  });

  factory GroupBalancesModel.fromJson(Map<String, dynamic> json) {
    return GroupBalancesModel(
      balances: (json['balances'] as List)
          .map((e) => MemberBalance.fromJson(e))
          .toList(),
      settlements: (json['settlements'] as List)
          .map((e) => SettlementDebt.fromJson(e))
          .toList(),
      pairwise: (json['pairwise'] as List)
          .map((e) => PairwiseDebt.fromJson(e))
          .toList(),
    );
  }
}

class MemberBalance {
  final String userId;
  final String name;
  final double net;

  MemberBalance({required this.userId, required this.name, required this.net});

  factory MemberBalance.fromJson(Map<String, dynamic> json) => MemberBalance(
        userId: json['userId'],
        name: json['name'] ?? 'Unknown',
        net: (json['net'] as num).toDouble(),
      );
}

class SettlementDebt {
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final double amount;

  SettlementDebt({
    required this.from,
    required this.fromName,
    required this.to,
    required this.toName,
    required this.amount,
  });

  factory SettlementDebt.fromJson(Map<String, dynamic> json) => SettlementDebt(
        from: json['from'],
        fromName: json['fromName'] ?? 'Unknown',
        to: json['to'],
        toName: json['toName'] ?? 'Unknown',
        amount: (json['amount'] as num).toDouble(),
      );
}

class PairwiseDebt {
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final double amount;

  PairwiseDebt({
    required this.from,
    required this.fromName,
    required this.to,
    required this.toName,
    required this.amount,
  });

  factory PairwiseDebt.fromJson(Map<String, dynamic> json) => PairwiseDebt(
        from: json['from'],
        fromName: json['fromName'] ?? 'Unknown',
        to: json['to'],
        toName: json['toName'] ?? 'Unknown',
        amount: (json['amount'] as num).toDouble(),
      );
}
