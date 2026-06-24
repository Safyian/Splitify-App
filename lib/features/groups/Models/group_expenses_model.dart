// To parse this JSON data, do
//
//     final groupExpenses = groupExpensesFromJson(jsonString);

import 'dart:convert';

GroupExpenses groupExpensesFromJson(String str) =>
    GroupExpenses.fromJson(json.decode(str));

String groupExpensesToJson(GroupExpenses data) => json.encode(data.toJson());

class GroupExpenses {
  int? count;
  int? total;
  int? page;
  bool? hasMore;
  List<Expense>? expenses;

  GroupExpenses({
    this.count,
    this.total,
    this.page,
    this.hasMore,
    this.expenses,
  });

  factory GroupExpenses.fromJson(Map<String, dynamic> json) => GroupExpenses(
        count: json["count"],
        total: json['total'] as int?,
        page: json['page'] as int?,
        hasMore: json['hasMore'] as bool?,
        expenses: json["expenses"] == null
            ? []
            : List<Expense>.from(
                json["expenses"]!.map((x) => Expense.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "total": total,
        "page": page,
        "hasMore": hasMore,
        "expenses": expenses == null
            ? []
            : List<dynamic>.from(expenses!.map((x) => x.toJson())),
      };
}

class Expense {
  String? id;
  String? group;
  String? description;
  double? amount;
  PaidBy? paidBy;
  final String? splitType;
  List<Split>? splits;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  final String? settledCycleId;

  Expense({
    this.id,
    this.group,
    this.description,
    this.amount,
    this.paidBy,
    this.splitType,
    this.splits,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.settledCycleId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["_id"],
        group: json["group"],
        description: json["description"],
        amount: json["amount"]?.toDouble(),
        paidBy: json["paidBy"] == null ? null : PaidBy.fromJson(json["paidBy"]),
        splitType: json['splitType'],
        splits: json["splits"] == null
            ? []
            : List<Split>.from(json["splits"]!.map((x) => Split.fromJson(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        settledCycleId: json["settledCycleId"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "group": group,
        "description": description,
        "amount": amount,
        "paidBy": paidBy?.toJson(),
        "splits": splits == null
            ? []
            : List<dynamic>.from(splits!.map((x) => x.toJson())),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "settledCycleId": settledCycleId,
      };
}

class PaidBy {
  String? id;
  String? name;
  String? email;

  PaidBy({
    this.id,
    this.name,
    this.email,
  });

  factory PaidBy.fromJson(Map<String, dynamic> json) => PaidBy(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}

class Split {
  PaidBy? user;
  double? amount;
  String? id;
  final double? percentage;

  Split({
    this.user,
    this.amount,
    this.id,
    this.percentage,
  });

  factory Split.fromJson(Map<String, dynamic> json) => Split(
        user: json["user"] == null ? null : PaidBy.fromJson(json["user"]),
        amount: json["amount"]?.toDouble(),
        percentage: (json['percentage'] as num?)?.toDouble(),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "amount": amount,
        "percentage": percentage,
        "_id": id,
      };
}
