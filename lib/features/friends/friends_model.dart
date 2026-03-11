// To parse this JSON data, do
//     final friend = friendFromJson(jsonString);

import 'dart:convert';

List<Friend> friendListFromJson(String str) =>
    List<Friend>.from(json.decode(str).map((x) => Friend.fromJson(x)));

class Friend {
  final String id;
  final String name;
  final String email;
  final bool isExplicitFriend;
  final bool isGroupContact;
  final FriendBalance balance;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.isExplicitFriend,
    required this.isGroupContact,
    required this.balance,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        isExplicitFriend: json["isExplicitFriend"] ?? false,
        isGroupContact: json["isGroupContact"] ?? false,
        balance: FriendBalance.fromJson(json["balance"]),
      );
}

enum FriendBalanceStatus { youOwe, youAreOwed, settled }

FriendBalanceStatus friendBalanceStatusFromString(String value) {
  switch (value) {
    case "you_owe":
      return FriendBalanceStatus.youOwe;
    case "you_are_owed":
      return FriendBalanceStatus.youAreOwed;
    default:
      return FriendBalanceStatus.settled;
  }
}

class FriendBalance {
  final double net;
  final FriendBalanceStatus status;

  FriendBalance({required this.net, required this.status});

  factory FriendBalance.fromJson(Map<String, dynamic> json) => FriendBalance(
        net: (json["net"] as num).toDouble(),
        status: friendBalanceStatusFromString(json["status"]),
      );
}
