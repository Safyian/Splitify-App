import 'dart:convert';

enum BalanceStatus { youOwe, youAreOwed, settled }

enum PreviewDirection { youPay, youReceive }

BalanceStatus balanceStatusFromString(String value) {
  switch (value) {
    case "you_owe":
      return BalanceStatus.youOwe;
    case "you_are_owed":
      return BalanceStatus.youAreOwed;
    default:
      return BalanceStatus.settled;
  }
}

String balanceStatusToString(BalanceStatus status) {
  switch (status) {
    case BalanceStatus.youOwe:
      return "you_owe";
    case BalanceStatus.youAreOwed:
      return "you_are_owed";
    case BalanceStatus.settled:
      return "settled";
  }
}

PreviewDirection previewDirectionFromString(String value) {
  switch (value) {
    case "you_pay":
      return PreviewDirection.youPay;
    default:
      return PreviewDirection.youReceive;
  }
}

String previewDirectionToString(PreviewDirection dir) {
  switch (dir) {
    case PreviewDirection.youPay:
      return "you_pay";
    case PreviewDirection.youReceive:
      return "you_receive";
  }
}

// To parse this JSON data, do
//
//     final GroupSummary = groupSummaryFromJson(jsonString);

List<GroupSummary> groupSummaryFromJson(String str) => List<GroupSummary>.from(
    json.decode(str).map((x) => GroupSummary.fromJson(x)));

String groupSummaryToJson(List<GroupSummary> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupSummary {
  String id;
  String name;
  Balance balance;
  List<Preview> preview;
  int othersCount;

  GroupSummary({
    required this.id,
    required this.name,
    required this.balance,
    required this.preview,
    required this.othersCount,
  });

  factory GroupSummary.fromJson(Map<String, dynamic> json) => GroupSummary(
        id: json["_id"],
        name: json["name"],
        balance: Balance.fromJson(json["balance"]),
        preview:
            List<Preview>.from(json["preview"].map((x) => Preview.fromJson(x))),
        othersCount: json["othersCount"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "balance": balance.toJson(),
        "preview": List<dynamic>.from(preview.map((x) => x.toJson())),
        "othersCount": othersCount,
      };
}

class Balance {
  double net;
  BalanceStatus status;

  Balance({
    required this.net,
    required this.status,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
        net: (json["net"] as num).toDouble(),
        status: balanceStatusFromString(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "net": net,
        "status": balanceStatusToString(status),
      };
}

class Preview {
  String userId;
  String name;
  double amount;
  PreviewDirection direction;

  Preview({
    required this.userId,
    required this.name,
    required this.amount,
    required this.direction,
  });

  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
        userId: json["userId"],
        name: json["name"],
        amount: (json["amount"] as num).toDouble(),
        direction: previewDirectionFromString(json["direction"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "amount": amount,
        "direction": previewDirectionToString(direction),
      };
}
