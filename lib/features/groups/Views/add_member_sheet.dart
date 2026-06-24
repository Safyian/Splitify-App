import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/utils/hash_helper.dart';
import '../../../shared/contacts/add_by_email_field.dart';
import '../../../shared/contacts/contact_picker_widget.dart';
import '../../../shared/contacts/person_row.dart';
import '../../../shared/widgets/alert_widgets.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../friends/friends_controller.dart';
import '../Controllers/groups_controller.dart';

void showAddMemberSheet(
  BuildContext context, {
  required String groupId,
  required int groupIndex,
}) {
  Get.to(
    () => AddMemberView(groupId: groupId, groupIndex: groupIndex),
  );
}

class AddMemberView extends StatefulWidget {
  const AddMemberView(
      {super.key, required this.groupId, required this.groupIndex});
  final String groupId;
  final int groupIndex;

  @override
  State<AddMemberView> createState() => _AddMemberViewState();
}

class _AddMemberViewState extends State<AddMemberView> {
  int _tab = 0;

  final GroupsController _groupCtrl = Get.find<GroupsController>();
  final FriendsController _friendsCtrl =
      Get.find<FriendsController>(tag: 'friends');

  // ── Helpers ───────────────────────────────────────────────────────────────

  Set<String> get _memberIds {
    return (_groupCtrl.membersFor(widget.groupId).members ?? [])
        .map((m) => m.id ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Emails + normalised phones of current members — used by ContactPickerWidget
  /// to show "Added" on rows that are already in the group.
  Set<String> get _memberIdentifiers {
    final members = _groupCtrl.membersFor(widget.groupId).members ?? [];
    final ids = <String>{};
    for (final m in members) {
      if (m.email?.isNotEmpty == true) ids.add(m.email!.toLowerCase().trim());
      if (m.phone?.isNotEmpty == true) ids.add(m.phone!);
    }
    return ids;
  }

  // ── Friend-tab actions ────────────────────────────────────────────────────

  Future<void> _addFriendToGroup(String friendId, String friendName,
      bool isPending, String? email, String? phone) async {
    AppDialogs.loading(
      message: 'Adding $friendName...',
      icon: Icons.person_add_outlined,
    );
    try {
      final member = isPending
          ? await _groupCtrl.addMemberByContact(
              groupId: widget.groupId,
              name: friendName,
              email: email,
              phone: phone,
              index: widget.groupIndex,
            )
          : await _groupCtrl.addMemberById(
              groupId: widget.groupId,
              userId: friendId,
              index: widget.groupIndex,
            );
      await AppDialogs.closeLoading();
      if (!mounted) return;
      if (member != null && member.isPlaceholder) {
        // ignore: use_build_context_synchronously
        AppDialogs.invite(
          name: friendName,
          inviteMessage:
              'Hey $friendName! I\'m using Splittify to split bills with friends. '
              'Join me: splittify.app/download',
          description:
              'Add them to this group and send an invitation to join Splittify.',
          loadingMessage: null,
          context: context,
          closePop: 2,
        );
      } else if (member != null) {
        Get.back();
        AlertWidgets.showSnackBar(message: '$friendName added to group');
      }
    } catch (e) {
      await AppDialogs.closeLoading();
      if (mounted) {
        AlertWidgets.showSnackBar(
            message: e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  // ── Contacts-tab actions (used by ContactPickerWidget callbacks) ──────────

  Future<void> _onRegisteredContact(
      String userId, String name, String? email, String? phone) async {
    AppDialogs.loading(
      message: 'Adding $name...',
      icon: Icons.person_add_outlined,
    );
    try {
      final member = await _groupCtrl.addMemberById(
        groupId: widget.groupId,
        userId: userId,
        index: widget.groupIndex,
      );
      await AppDialogs.closeLoading();
      if (mounted && member != null) {
        Get.back();
        AlertWidgets.showSnackBar(message: '$name added to group');
      }
    } catch (e) {
      await AppDialogs.closeLoading();
      if (mounted) {
        AlertWidgets.showSnackBar(
            message: e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onUnregisteredContact(
      String name, String? email, String? phone) async {
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    AppDialogs.invite(
      name: name,
      inviteMessage:
          'Hey $name! I\'m using Splittify to split bills with friends. '
          'Join me: splittify.app/download',
      description:
          'Add them to this group and send an invitation to join Splittify.',
      loadingMessage: 'Adding member...',
      context: context,
      closePop: 2,
      onInviteConfirmed: () async {
        await _groupCtrl.addMemberByContact(
          groupId: widget.groupId,
          name: name,
          phone: phone,
          email: email,
          index: widget.groupIndex,
        );
      },
    );
  }

  // ── Email-tab action ──────────────────────────────────────────────────────

  Future<void> _addByEmail(String email) async {
    // Step 1: check registration without mutating anything.
    AppDialogs.loading(
      message: 'Checking…',
      icon: Icons.search_rounded,
    );
    Map<String, dynamic> result;
    try {
      result = await _friendsCtrl.checkSingleContact(
        emailHash: HashHelper.hashContact(email),
      );
    } catch (e) {
      await AppDialogs.closeLoading();
      if (mounted) {
        AlertWidgets.showSnackBar(
            message: e.toString().replaceAll('Exception: ', ''));
      }
      rethrow;
    }
    await AppDialogs.closeLoading();
    if (!mounted) return;

    final isRegistered = result['isRegistered'] == true;
    final userId = result['user']?['id'] as String?;

    if (isRegistered) {
      // Step 2a: registered — add directly, no invite dialog.
      if (userId == null || userId.isEmpty) {
        AlertWidgets.showSnackBar(message: 'Could not find user. Try again.');
        return;
      }
      AppDialogs.loading(
        message: 'Adding member...',
        icon: Icons.person_add_outlined,
      );
      try {
        final member = await _groupCtrl.addMemberById(
          groupId: widget.groupId,
          userId: userId,
          index: widget.groupIndex,
        );
        await AppDialogs.closeLoading();
        if (!mounted) return;
        if (member != null) {
          Get.back();
          AlertWidgets.showSnackBar(message: 'Member added successfully');
        }
      } catch (e) {
        await AppDialogs.closeLoading();
        if (mounted) {
          AlertWidgets.showSnackBar(
              message: e.toString().replaceAll('Exception: ', ''));
          rethrow;
        }
      }
    } else {
      // Step 2b: not registered — show invite dialog FIRST; create nothing yet.
      // ignore: use_build_context_synchronously
      AppDialogs.invite(
        name: email,
        inviteMessage: 'Hey! I\'m using Splittify to split bills with friends. '
            'Join me: splittify.app/download',
        description:
            'Add them to this group and send an invitation to join Splittify.',
        loadingMessage: 'Adding member...',
        context: context,
        closePop: 2,
        onInviteConfirmed: () async {
          await _groupCtrl.addMemberByContact(
            groupId: widget.groupId,
            name: email,
            email: email,
            index: widget.groupIndex,
          );
        },
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child:
              const Icon(Icons.close_rounded, size: 22, color: Colors.black87),
        ),
        title: Text('Add Member', style: AppTheme.headingText),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _TabChip(
                  label: 'Friends',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Contacts',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'By Email',
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildFriendsTab(),
                // ContactPickerWidget is kept alive across tab switches so
                // contacts don't reload every time the user switches tabs.
                ContactPickerWidget(
                  onRegisteredContactTap: _onRegisteredContact,
                  onUnregisteredContactTap: _onUnregisteredContact,
                  addedIdentifiers: _memberIdentifiers,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AddByEmailField(
                    buttonLabel: 'Add Member',
                    description: 'Enter the email address of a Splittify user',
                    onSubmit: _addByEmail,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Friends tab ───────────────────────────────────────────────────────────

  Widget _buildFriendsTab() {
    return Obx(() {
      final memberIds = _memberIds;
      final friends =
          _friendsCtrl.friends.where((f) => f.isExplicitFriend).toList();

      if (_friendsCtrl.isLoading.value && friends.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
              color: Constants.activeColor, strokeWidth: 2),
        );
      }

      if (friends.isEmpty) {
        return Center(
          child: Text(
            'No friends yet',
            style: AppTheme.normalText.copyWith(color: Colors.grey),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Constants.bgColorLight,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(friends.length, (i) {
              final friend = friends[i];
              final isAdded = memberIds.contains(friend.id);

              return Column(
                children: [
                  PersonRow(
                    name: friend.name,
                    subtitle: friend.email ?? friend.phone,
                    isAdded: isAdded,
                    onTap: isAdded
                        ? null
                        : () => _addFriendToGroup(
                              friend.id,
                              friend.name,
                              friend.isPending,
                              friend.email,
                              friend.phone,
                            ),
                  ),
                  if (i != friends.length - 1)
                    Divider(height: 1, color: Colors.grey.withAlpha(20)),
                ],
              );
            }),
          ),
        ),
      );
    });
  }
}

// ── Tab chip ───────────────────────────────────────────────────────────────────
class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // color: selected ? Constants.activeColor : Constants.chipColor,
          color: selected ? Constants.activeColor : Constants.bgColorLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTheme.normalText.copyWith(
            // color: selected ? Colors.white : Constants.textLight,
            color: selected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
