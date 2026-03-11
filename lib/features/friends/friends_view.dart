import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitify/shared/widgets/friend_card.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../groups/create_group_view.dart';
import '../groups/group_summary_model.dart';
import '../groups/groups_controller.dart'; // already imported
import '../groups/settle_up_view.dart'; // SettleAmountView lives here
import 'friends_controller.dart';
import 'friends_model.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({super.key});

  final FriendsController friendsCtrl =
      Get.put(FriendsController(), tag: 'friends');

  void _registerSettledCallback() {
    try {
      Get.find<GroupsController>().onBalanceChanged = () async {
        await friendsCtrl.fetchFriends();
      };
    } catch (_) {}
  }

  final RxString _searchQuery = ''.obs;
  final RxString _activeFilter = 'all'.obs;

  // ── Add friend dialog ──────────────────────────────────────────────────────
  void _showAddFriendDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        backgroundColor: Constants.bgColorLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Add Friend", style: AppTheme.subHeadingText),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the email of a registered Splitify user",
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
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
                await friendsCtrl.addFriend(email: emailCtrl.text.trim());
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

  // ── Filtered list ──────────────────────────────────────────────────────────
  List<Friend> _filtered(List<Friend> all) {
    final query = _searchQuery.value.toLowerCase();
    final filter = _activeFilter.value;

    return all.where((f) {
      final matchesSearch = query.isEmpty ||
          f.name.toLowerCase().contains(query) ||
          f.email.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        "friends" => f.isExplicitFriend,
        "contacts" => !f.isExplicitFriend,
        "you_owe" => f.balance.status == FriendBalanceStatus.youOwe,
        "you_are_owed" => f.balance.status == FriendBalanceStatus.youAreOwed,
        "settled" => f.balance.status == FriendBalanceStatus.settled,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ── Group picker — shown when friend card is tapped ───────────────────────
  void _showGroupPicker(BuildContext context, Friend friend) {
    final sharedGroups = friendsCtrl.sharedGroupsWithFriend(friend.id);

    if (sharedGroups.isEmpty) {
      // No shared groups with unsettled balance — nothing to settle
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: BoxDecoration(
            color: Constants.bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(Icons.check_circle_outline_rounded,
                  size: 48, color: Constants.activeColor),
              const SizedBox(height: 12),
              Text("All settled up with ${friend.name}",
                  style: AppTheme.subHeadingText, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text("You have no shared groups with outstanding balances.",
                  style: AppTheme.normalText.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );
      return;
    }

    // Go direct if only one shared group
    if (sharedGroups.length == 1) {
      final g = sharedGroups[0];
      Get.to(
        () => SettleAmountView(
          entity: g['preview'],
          groupId: g['groupId'] as String,
          popCount: 1,
        ),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 300),
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
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
            Text("Settle up with ${friend.name}",
                style: AppTheme.subHeadingText),
            const SizedBox(height: 4),
            Text("Choose which group to settle in",
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),
            ...sharedGroups.map((g) {
              final status = g['status'] as BalanceStatus;
              final isSettled = status == BalanceStatus.settled;
              return GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(
                    () => SettleAmountView(
                      entity: g['preview'],
                      groupId: g['groupId'] as String,
                      popCount: 1,
                    ),
                    transition: Transition.downToUp,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(g['emoji'] as String,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(g['name'] as String,
                            style: AppTheme.normalText
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (isSettled)
                        const Icon(Icons.check_circle,
                            size: 16, color: Constants.activeColor)
                      else
                        const Icon(Icons.chevron_right_rounded,
                            size: 18, color: Constants.activeColor),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    _registerSettledCallback();
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Friends', style: AppTheme.headingText),
        actions: [
          GestureDetector(
            onTap: () => _showAddFriendDialog(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Constants.activeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_add_outlined,
                  size: 18, color: Constants.activeColor),
            ),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (friendsCtrl.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = friendsCtrl.friends;
        final filtered = _filtered(all);
        final overallNet = friendsCtrl.overallNet;
        final overallSettled = overallNet == 0;
        final overallOwed = overallNet > 0;

        return RefreshIndicator(
          color: Constants.activeColor,
          onRefresh: () => friendsCtrl.fetchFriends(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Overall balance card ──────────────
                      _OverallBalanceCard(
                        net: overallNet,
                        isSettled: overallSettled,
                        owed: overallOwed,
                      ),
                      const SizedBox(height: 16),

                      // ── Search bar ────────────────────────
                      _SearchBar(searchQuery: _searchQuery),
                      const SizedBox(height: 12),

                      // ── Filter chips ──────────────────────
                      _FilterChips(activeFilter: _activeFilter),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── List ──────────────────────────────────────
              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                    isFiltered: _searchQuery.value.isNotEmpty ||
                        _activeFilter.value != 'all',
                    onAdd: () => _showAddFriendDialog(context),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Constants.bgColorLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: filtered.map((friend) {
                        final isLast = friend == filtered.last;
                        return FriendCard(
                          friend: friend,
                          onTap: () => _showGroupPicker(context, friend),
                          onRemove: friend.isExplicitFriend
                              ? () =>
                                  friendsCtrl.removeFriend(friendId: friend.id)
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    children: [
                      // ── Create Group button ─────────────────────
                      GestureDetector(
                        onTap: () => Get.to(
                          () => const CreateGroupScreen(),
                          transition: Transition.rightToLeft,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Constants.activeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.group_add_outlined,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Create New Group",
                                style: AppTheme.subHeadingText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Add Friend button ───────────────────────
                      GestureDetector(
                        onTap: () => _showAddFriendDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Constants.activeColor.withAlpha(150)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_outlined,
                                  size: 18, color: Constants.activeColor),
                              const SizedBox(width: 8),
                              Text(
                                "Add a Friend",
                                style: AppTheme.subHeadingText.copyWith(
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
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }
}

// ── Overall Balance Card ───────────────────────────────────────────────────────
class _OverallBalanceCard extends StatelessWidget {
  const _OverallBalanceCard({
    required this.net,
    required this.isSettled,
    required this.owed,
  });
  final double net;
  final bool isSettled;
  final bool owed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSettled
                  ? Constants.activeColor.withAlpha(20)
                  : owed
                      ? Constants.activeColor.withAlpha(20)
                      : Constants.redColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              isSettled
                  ? Icons.check_circle_outline_rounded
                  : owed
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
              size: 20,
              color: isSettled
                  ? Constants.activeColor
                  : owed
                      ? Constants.activeColor
                      : Constants.redColor,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Overall balance",
                style: AppTheme.normalText.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              if (isSettled)
                Text(
                  "All settled up",
                  style: AppTheme.subHeadingText.copyWith(
                    color: Constants.activeColor,
                  ),
                )
              else
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: owed ? "You are owed " : "You owe ",
                        style: AppTheme.subHeadingText,
                      ),
                      TextSpan(
                        text: "\$${net.abs().toStringAsFixed(2)}",
                        style: AppTheme.subHeadingText.copyWith(
                          color:
                              owed ? Constants.activeColor : Constants.redColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.searchQuery});
  final RxString searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (v) => searchQuery.value = v,
        style: AppTheme.normalText,
        decoration: InputDecoration(
          hintText: "Search by name or email...",
          hintStyle: AppTheme.normalText.copyWith(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}

// ── Filter Chips ───────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.activeFilter});
  final RxString activeFilter;

  static const _filters = [
    {"label": "All", "value": "all"},
    {"label": "Friends", "value": "friends"},
    {"label": "Contacts", "value": "contacts"},
    {"label": "You owe", "value": "you_owe"},
    {"label": "Owed to you", "value": "you_are_owed"},
    {"label": "Settled", "value": "settled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((f) {
              final isActive = activeFilter.value == f["value"];
              return GestureDetector(
                onTap: () => activeFilter.value = f["value"]!,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Constants.activeColor
                        : Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f["label"]!,
                    style: AppTheme.normalText.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isFiltered, required this.onAdd});
  final bool isFiltered;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            isFiltered ? "No results" : "No friends yet",
            style: AppTheme.subHeadingText,
          ),
          const SizedBox(height: 4),
          Text(
            isFiltered
                ? "Try a different search or filter"
                : "Add a friend to get started",
            style: AppTheme.normalText.copyWith(color: Colors.grey.shade400),
          ),
          if (!isFiltered) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  color: Constants.activeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Add a friend",
                  style: AppTheme.normalText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
