import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splitify/core/constants/constants.dart';

import '../../core/theme/app_themes.dart';
import '../profile/profile_controller.dart';
import 'groups_controller.dart';

// ── Emoji presets ─────────────────────────────────────────────────────────────
const _emojis = [
  "🏠",
  "🍕",
  "✈️",
  "🎉",
  "🏖️",
  "🎮",
  "🏋️",
  "🛒",
  "🍔",
  "🎵",
  "📚",
  "💼",
  "🚗",
  "⚽",
  "🎂",
  "💊",
  "🐶",
  "🌿",
  "☕",
  "🎬",
  "🏕️",
  "🧳",
  "🍣",
  "💡",
];

class GroupSettingsView extends StatelessWidget {
  GroupSettingsView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        final summary = groupCtrl.summaries[index];
        final myId = profileCtrl.user.value.user?.id ?? '';
        final isCreator = myId == summary.createdBy;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Group Identity ───────────────────────────
            _SectionHeader(title: "Group Identity"),
            const SizedBox(height: 10),
            _EmojiAndNameCard(index: index, groupCtrl: groupCtrl),
            const SizedBox(height: 24),

            // ── Expense Defaults ─────────────────────────
            _SectionHeader(title: "Expense Defaults"),
            const SizedBox(height: 10),
            _SplitTypeCard(index: index, groupCtrl: groupCtrl),
            const SizedBox(height: 24),

            // ── Members ──────────────────────────────────
            _SectionHeader(title: "Members"),
            const SizedBox(height: 10),
            _MembersCard(index: index, groupCtrl: groupCtrl, myId: myId),
            const SizedBox(height: 24),

            // ── Danger Zone ──────────────────────────────
            _SectionHeader(title: "Danger Zone", isRed: true),
            const SizedBox(height: 10),
            _DangerCard(
                index: index,
                groupCtrl: groupCtrl,
                myId: myId,
                isCreator: isCreator),
            const SizedBox(height: 40),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: Text("Group Settings", style: AppTheme.subHeadingText),
        titleSpacing: 0.0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              Constants.backLogo,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
        elevation: 0,
      );
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.isRed = false});
  final String title;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTheme.normalText.copyWith(
        color: isRed ? Constants.redColor : Colors.grey.shade500,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Settings Tile ──────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.valueColor,
    this.isFirst = false,
    this.isLast = false,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(14) : Radius.zero,
            bottom: isLast ? const Radius.circular(14) : Radius.zero,
          ),
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.grey.shade500),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(label, style: AppTheme.normalText),
            ),
            Text(
              value,
              style: AppTheme.normalText.copyWith(
                color: valueColor ?? Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Emoji + Name Card ──────────────────────────────────────────────────────────
class _EmojiAndNameCard extends StatelessWidget {
  const _EmojiAndNameCard({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: groupCtrl.summaries[index].name);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Rename Group", style: AppTheme.subHeadingText),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            style: AppTheme.normalText,
            decoration: InputDecoration(
              hintText: "Group name",
              hintStyle: AppTheme.normalText.copyWith(color: Colors.grey),
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name cannot be empty';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Get.back();
                await groupCtrl.renameGroup(
                  groupId: groupCtrl.summaries[index].id,
                  name: ctrl.text.trim(),
                  index: index,
                );
              }
            },
            child: Text("Save",
                style: AppTheme.normalText.copyWith(
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Constants.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Choose an Emoji", style: AppTheme.subHeadingText),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, i) {
                final emoji = _emojis[i];
                final isSelected = groupCtrl.summaries[index].emoji == emoji;
                return GestureDetector(
                  onTap: () async {
                    Get.back();
                    await groupCtrl.updateEmoji(
                      groupId: groupCtrl.summaries[index].id,
                      emoji: emoji,
                      index: index,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Constants.activeColor.withAlpha(25)
                          : Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: Constants.activeColor.withAlpha(80))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = groupCtrl.summaries[index];
      return Column(
        children: [
          _SettingsTile(
            label: "Group Name",
            value: summary.name,
            icon: Icons.drive_file_rename_outline_rounded,
            onTap: () => _showRenameDialog(context),
            isFirst: true,
          ),
          _SettingsTile(
            label: "Group Emoji",
            value: summary.emoji,
            icon: Icons.emoji_emotions_outlined,
            onTap: () => _showEmojiPicker(context),
            isLast: true,
          ),
        ],
      );
    });
  }
}

// ── Split Type Card ────────────────────────────────────────────────────────────
class _SplitTypeCard extends StatelessWidget {
  const _SplitTypeCard({required this.index, required this.groupCtrl});
  final int index;
  final GroupsController groupCtrl;

  static const _options = [
    {"value": "equal", "label": "Equal", "desc": "Split evenly between all"},
    {
      "value": "exact",
      "label": "Exact amounts",
      "desc": "Enter specific amounts"
    },
    {
      "value": "percentage",
      "label": "Percentage",
      "desc": "Split by percentages"
    },
  ];

  void _showPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Constants.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Default Split Type", style: AppTheme.subHeadingText),
            Text(
              "Applied automatically when adding new expenses",
              style: AppTheme.normalText
                  .copyWith(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ..._options.map((opt) {
              return Obx(() {
                final isSelected =
                    groupCtrl.summaries[index].defaultSplitType == opt["value"];
                return GestureDetector(
                  onTap: () async {
                    Get.back();
                    await groupCtrl.updateDefaultSplitType(
                      groupId: groupCtrl.summaries[index].id,
                      splitType: opt["value"]!,
                      index: index,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Constants.activeColor.withAlpha(20)
                          : Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Constants.activeColor.withAlpha(80))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt["label"]!,
                                  style: AppTheme.normalText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Constants.activeColor
                                        : null,
                                  )),
                              Text(opt["desc"]!,
                                  style: AppTheme.normalText.copyWith(
                                      color: Colors.grey.shade500,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: Constants.activeColor, size: 20),
                      ],
                    ),
                  ),
                );
              });
            }),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _label(String val) {
    switch (val) {
      case "exact":
        return "Exact amounts";
      case "percentage":
        return "Percentage";
      default:
        return "Equal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _SettingsTile(
          label: "Default Split",
          value: _label(groupCtrl.summaries[index].defaultSplitType),
          icon: Icons.call_split_rounded,
          onTap: () => _showPicker(context),
          isFirst: true,
          isLast: true,
        ));
  }
}

// ── Members Card ───────────────────────────────────────────────────────────────
class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.index,
    required this.groupCtrl,
    required this.myId,
  });
  final int index;
  final GroupsController groupCtrl;
  final String myId;

  void _showAddMemberDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Add Member", style: AppTheme.subHeadingText),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the email of a registered Splitify user",
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.normalText,
                decoration: InputDecoration(
                  hintText: "email@example.com",
                  hintStyle: AppTheme.normalText.copyWith(color: Colors.grey),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Get.back();
                await groupCtrl.addMember(
                  groupId: groupCtrl.summaries[index].id,
                  email: ctrl.text.trim(),
                  index: index,
                );
              }
            },
            child: Text("Add",
                style: AppTheme.normalText.copyWith(
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(
      BuildContext context, String memberId, String memberName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Remove Member", style: AppTheme.subHeadingText),
        content: Text(
          "Remove $memberName from the group? They must have no unsettled balances.",
          style: AppTheme.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await groupCtrl.removeMember(
                groupId: groupCtrl.summaries[index].id,
                memberId: memberId,
                index: index,
              );
            },
            child: Text("Remove",
                style: AppTheme.normalText.copyWith(
                  color: Constants.redColor,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = groupCtrl.groupMembers.value.members ?? [];
    final groupId = groupCtrl.summaries[index].id;

    // Fetch members if not loaded
    if (members.isEmpty) {
      groupCtrl.fetchGroupMembers(groupId: groupId);
    }

    return Obx(() {
      final memberList = groupCtrl.groupMembers.value.members ?? [];

      return Container(
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Member rows
            ...memberList.asMap().entries.map((entry) {
              final i = entry.key;
              final member = entry.value;
              final isMe = member.id == myId;
              final isLast = i == memberList.length - 1;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Constants.activeColor.withAlpha(25),
                      child: Text(
                        (member.name ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMe ? "${member.name} (You)" : member.name ?? '',
                            style: AppTheme.normalText
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            member.email ?? '',
                            style: AppTheme.normalText.copyWith(
                                color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Remove button — only shown to non-self members
                    if (!isMe)
                      GestureDetector(
                        onTap: () => _confirmRemoveMember(
                          context,
                          member.id ?? '',
                          member.name ?? '',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Constants.redColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person_remove_outlined,
                            size: 16,
                            color: Constants.redColor,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            // Add Member button at the bottom
            GestureDetector(
              onTap: () => _showAddMemberDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Constants.activeColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.person_add_outlined,
                          size: 18, color: Constants.activeColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Add Member",
                      style: AppTheme.normalText.copyWith(
                        color: Constants.activeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Danger Card ────────────────────────────────────────────────────────────────
class _DangerCard extends StatelessWidget {
  const _DangerCard({
    required this.index,
    required this.groupCtrl,
    required this.myId,
    required this.isCreator,
  });
  final int index;
  final GroupsController groupCtrl;
  final String myId;
  final bool isCreator;

  void _confirmLeave(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Leave Group", style: AppTheme.subHeadingText),
        content: Text(
          "You'll be removed from this group. You must have no unsettled balances.",
          style: AppTheme.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await groupCtrl.leaveGroup(
                groupId: groupCtrl.summaries[index].id,
                index: index,
              );
            },
            child: Text("Leave",
                style: AppTheme.normalText.copyWith(
                  color: Constants.redColor,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Group", style: AppTheme.subHeadingText),
        content: Text(
          "This will permanently delete the group and all its expenses. All balances must be settled first. This cannot be undone.",
          style: AppTheme.normalText,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel",
                style: AppTheme.normalText.copyWith(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await groupCtrl.deleteGroup(
                groupId: groupCtrl.summaries[index].id,
                index: index,
              );
            },
            child: Text("Delete",
                style: AppTheme.normalText.copyWith(
                  color: Constants.redColor,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Leave group — available to all members
        _DangerTile(
          label: "Leave Group",
          icon: Icons.exit_to_app_rounded,
          onTap: () => _confirmLeave(context),
          isFirst: true,
          isLast: true,
        ),
        const SizedBox(height: 8),

        // Delete group — only visible to the group creator
        if (isCreator)
          _DangerTile(
            label: "Delete Group",
            icon: Icons.delete_forever_rounded,
            onTap: () => _confirmDelete(context),
            isFirst: true,
            isLast: true,
          ),
      ],
    );
  }
}

class _DangerTile extends StatelessWidget {
  const _DangerTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Constants.redColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.normalText.copyWith(
                  color: Constants.redColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
