// To parse this JSON data, do
//
//     final groupMembersModel = groupMembersModelFromJson(jsonString);

import 'dart:convert';

GroupMembersModel groupMembersModelFromJson(String str) =>
    GroupMembersModel.fromJson(json.decode(str));

String groupMembersModelToJson(GroupMembersModel data) =>
    json.encode(data.toJson());

class GroupMembersModel {
  final List<Member>? members;

  GroupMembersModel({
    this.members,
  });

  factory GroupMembersModel.fromJson(Map<String, dynamic> json) =>
      GroupMembersModel(
        members: json["members"] == null
            ? []
            : List<Member>.from(
                json["members"]!.map((x) => Member.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "members": members == null
            ? []
            : List<dynamic>.from(members!.map((x) => x.toJson())),
      };
}

class Member {
  final String? id;
  final String? name;
  final String? email;

  Member({
    this.id,
    this.name,
    this.email,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Member && other.id == id;

  @override
  int get hashCode => id.hashCode;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
