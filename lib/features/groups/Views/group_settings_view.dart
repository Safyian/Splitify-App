import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splittify/core/constants/constants.dart';
import 'package:splittify/features/groups/Views/settle_up_view.dart';

import '../../../core/theme/app_themes.dart';
import '../../../shared/widgets/alert_widgets.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../profile/profile_controller.dart';
import '../Controllers/groups_controller.dart';
import '../Models/group_summary_model.dart';
import 'add_member_sheet.dart';

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
        if (index >= groupCtrl.summaries.length) return const SizedBox.shrink();
        final summary = groupCtrl.summaries[index];
        final myId = profileCtrl.user.value.user?.id ?? '';
        final adminId = summary.adminId ?? '';
        final isAdmin = adminId == myId;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Group Identity ───────────────────────────
            const _SectionHeader(title: "Group Identity"),
            const SizedBox(height: 10),
            _EmojiAndNameCard(index: index, groupCtrl: groupCtrl),
            const SizedBox(height: 24),

            // ── Expense Defaults ─────────────────────────
            const _SectionHeader(title: "Expense Defaults"),
            const SizedBox(height: 10),
            _SplitTypeCard(index: index, groupCtrl: groupCtrl),
            const SizedBox(height: 24),

            // ── Members ──────────────────────────────────
            const _SectionHeader(title: "Members"),
            const SizedBox(height: 10),
            _MembersCard(index: index, groupCtrl: groupCtrl, myId: myId),
            const SizedBox(height: 24),

            // ── Danger Zone ──────────────────────────────
            const _SectionHeader(title: "Danger Zone", isRed: true),
            const SizedBox(height: 10),
            _DangerCard(
                index: index,
                groupCtrl: groupCtrl,
                myId: myId,
                isAdmin: isAdmin),
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
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.w),
              child: Text(
                value,
                style: AppTheme.normalText.copyWith(
                  color: valueColor ?? Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
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
        decoration: const BoxDecoration(
          color: Constants.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    child: Text(emoji,
                        style: AppTheme.normalText.copyWith(fontSize: 22.sp)),
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
        decoration: const BoxDecoration(
          color: Constants.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

  void _showBalanceModeSheet(
    BuildContext context,
    GroupsController groupCtrl,
    int index,
  ) {
    final groupId = groupCtrl.summaries[index].id;
    final current = groupCtrl.summaries[index].balanceMode;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        decoration: const BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Balance Mode',
                style: AppTheme.headingText.copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              'Choose how balances are calculated and displayed',
              style: AppTheme.normalText
                  .copyWith(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _BalanceModeOption(
              title: 'Pairwise',
              subtitle:
                  'Shows direct debts between each pair of members based on actual expenses',
              icon: Icons.people_outline_rounded,
              isSelected: current == 'pairwise',
              onTap: () async {
                Get.back();
                AppDialogs.loading(
                  message: 'Performing action ...',
                  subtitle: 'Converting to Pairwise mode...',
                  icon: Icons.person_search_outlined,
                );
                await groupCtrl.updateBalanceMode(
                  groupId: groupId,
                  balanceMode: 'pairwise',
                  index: index,
                );
                await AppDialogs.closeLoading();
              },
            ),
            const SizedBox(height: 10),
            _BalanceModeOption(
              title: 'Simplified',
              subtitle:
                  'Reduces transactions to the minimum needed to settle all debts',
              icon: Icons.account_tree_outlined,
              isSelected: current == 'simplified',
              onTap: () async {
                Get.back();
                AppDialogs.loading(
                  message: 'Performing action ...',
                  subtitle: 'Converting to Simplified mode...',
                  icon: Icons.person_search_outlined,
                );
                await groupCtrl.updateBalanceMode(
                  groupId: groupId,
                  balanceMode: 'simplified',
                  index: index,
                );
                await AppDialogs.closeLoading();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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
    return Obx(() {
      final myId = Get.find<ProfileController>().user.value.user?.id ?? '';
      final isAdmin = (groupCtrl.summaries[index].adminId ?? '') == myId;
      final balanceMode = groupCtrl.summaries[index].balanceMode;

      return Column(
        children: [
          _SettingsTile(
            label: "Default Split",
            value: _label(groupCtrl.summaries[index].defaultSplitType),
            icon: Icons.call_split_rounded,
            onTap: () => _showPicker(context),
            isFirst: true,
            isLast: false,
          ),
          _SettingsTile(
            label: "Split Mode",
            // label: "Balance Mode",
            value: balanceMode == 'pairwise' ? 'Pairwise' : 'Simplified',
            icon: Icons.account_tree_outlined,
            onTap: () {
              if (isAdmin) {
                _showBalanceModeSheet(context, groupCtrl, index);
              } else {
                AlertWidgets.showSnackBar(
                    message: 'Only Admin can change Split mode');
              }
            },
            isFirst: false,
            isLast: true,
          ),
        ],
      );
    });
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
    showAddMemberSheet(
      context,
      groupId: groupCtrl.summaries[index].id,
      groupIndex: index,
    );
  }

  Future<void> _confirmRemoveMember(
      BuildContext context, String memberId, String memberName) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Remove Member',
      message:
          'Remove $memberName from the group? They must have no unsettled balances.',
      confirmLabel: 'Remove',
      confirmColor: Constants.redColor,
    );
    if (confirmed) {
      AppDialogs.loading(
        message: 'Removing $memberName...',
        icon: Icons.person_remove_outlined,
      );
      await groupCtrl.removeMember(
        groupId: groupCtrl.summaries[index].id,
        memberId: memberId,
        index: index,
      );
      await AppDialogs.closeLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = groupCtrl.summaries[index].id;
    final members = groupCtrl.membersFor(groupId).members ?? [];

    // Fetch members if not loaded
    if (members.isEmpty) {
      groupCtrl.fetchGroupMembers(groupId: groupId);
    }

    return Obx(() {
      final memberList = groupCtrl.membersFor(groupId).members ?? [];
      final adminId = groupCtrl.summaries[index].adminId ?? '';
      final isAdmin = adminId == myId;

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
              final canRemove = isAdmin || member.id == myId;

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
                      backgroundColor: member.isPlaceholder
                          ? Colors.grey.withAlpha(30)
                          : Constants.activeColor.withAlpha(25),
                      child: Text(
                        (member.name ?? '?')[0].toUpperCase(),
                        style: AppTheme.normalText.copyWith(
                          color: member.isPlaceholder
                              ? Colors.grey.shade400
                              : Constants.activeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isMe
                                      ? "${member.name} (You)"
                                      : member.name ?? '',
                                  style: AppTheme.normalText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: member.isPlaceholder
                                        ? Colors.grey.shade500
                                        : null,
                                  ),
                                ),
                              ),
                              if (member.isPlaceholder) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.orange.withAlpha(60)),
                                  ),
                                  child: Text(
                                    'Invited',
                                    style: AppTheme.normalText.copyWith(
                                      color: Colors.orange.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if ((member.email ?? member.phone ?? '').isNotEmpty)
                            Text(
                              member.email ?? member.phone ?? '',
                              style: AppTheme.normalText.copyWith(
                                  color: Colors.grey.shade500, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    if (canRemove)
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
                          child: const Icon(
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
    required this.isAdmin,
  });
  final int index;
  final GroupsController groupCtrl;
  final String myId;
  final bool isAdmin;

  // Future<void> _confirmLeave(BuildContext context) async {
  //   final confirmed = await AppDialogs.confirm(
  //     title: 'Leave Group',
  //     message:
  //         "You'll be removed from this group. You must have no unsettled balances.",
  //     confirmLabel: 'Leave',
  //     confirmColor: Constants.redColor,
  //   );
  //   if (confirmed) {
  //     await groupCtrl.leaveGroup(
  //       groupId: groupCtrl.summaries[index].id,
  //       index: index,
  //     );
  //   }
  // }

  Future<void> _confirmLeave(BuildContext context) async {
    // Guard: block leaving with unsettled balances before the confirm dialog,
    // and offer a shortcut to Settle Up instead of a wasted API rejection.
    final status = groupCtrl.summaries[index].balance.status;
    if (status != BalanceStatus.settled) {
      final goSettle = await AppDialogs.confirm(
        title: 'Settle Up First',
        message:
            "You have unsettled balances in this group. Settle up before leaving.",
        confirmLabel: 'Settle Up',
        confirmColor: Constants.activeColor,
      );
      if (goSettle) {
        Get.to(() => SettleUpView(
              // groupId: groupCtrl.summaries[index].id,
              index: index,
              // match the params SettleUpView actually requires
            ));
      }
      return; // do NOT show the leave dialog
    }

    final confirmed = await AppDialogs.confirm(
      title: 'Leave Group',
      message:
          "You'll be removed from this group. You must have no unsettled balances.",
      confirmLabel: 'Leave',
      confirmColor: Constants.redColor,
    );
    if (confirmed) {
      await groupCtrl.leaveGroup(
        groupId: groupCtrl.summaries[index].id,
        index: index,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Delete Group',
      message:
          'This will permanently delete the group and all its expenses. All balances must be settled first. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Constants.redColor,
    );
    if (confirmed) {
      await groupCtrl.deleteGroup(
        groupId: groupCtrl.summaries[index].id,
        index: index,
      );
    }
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

        // Delete group — only visible to the group admin
        if (isAdmin)
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

// ── Balance Mode Option ────────────────────────────────────────────────────────
class _BalanceModeOption extends StatelessWidget {
  const _BalanceModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Constants.activeColor.withAlpha(12)
              : Constants.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Constants.activeColor.withAlpha(80)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? Constants.activeColor.withAlpha(20)
                    : Colors.grey.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 18,
                  color: isSelected
                      ? Constants.activeColor
                      : Colors.grey.shade400),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.normalText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? Constants.activeColor
                          : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.normalText.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: Constants.activeColor),
          ],
        ),
      ),
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
