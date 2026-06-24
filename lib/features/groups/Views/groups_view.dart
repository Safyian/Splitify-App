import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_themes.dart';
import '../../../shared/widgets/group_card.dart';
import '../Controllers/groups_controller.dart';
import '../Models/group_summary_model.dart';
import 'create_group_view.dart';

class GroupsScreen extends StatelessWidget {
  GroupsScreen({super.key});

  final groupCtrl = Get.find<GroupsController>();
  final RxString _groupSort = 'outstanding'.obs;

  /// Returns group indices reordered according to the active sort.
  List<int> _sortedOrder(List<GroupSummary> summaries) {
    final order = List<int>.generate(summaries.length, (i) => i);
    switch (_groupSort.value) {
      case 'name':
        order.sort((a, b) => summaries[a]
            .name
            .toLowerCase()
            .compareTo(summaries[b].name.toLowerCase()));
        break;
      case 'amount':
        order.sort((a, b) => summaries[b]
            .balance
            .net
            .abs()
            .compareTo(summaries[a].balance.net.abs()));
        break;
      case 'outstanding':
      default:
        order.sort((a, b) {
          final aS =
              summaries[a].balance.status == BalanceStatus.settled ? 1 : 0;
          final bS =
              summaries[b].balance.status == BalanceStatus.settled ? 1 : 0;
          if (aS != bS) return aS.compareTo(bS);
          return summaries[b]
              .balance
              .net
              .abs()
              .compareTo(summaries[a].balance.net.abs());
        });
    }
    return order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Groups', style: AppTheme.headingText),
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
        elevation: 0,
      ),
      body: Obx(() {
        final summaries = groupCtrl.summaries;
        final order = _sortedOrder(summaries);

        return RefreshIndicator(
          color: Constants.activeColor,
          onRefresh: () => groupCtrl.fetchSummary(forceRefresh: true),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _OverallBalanceBanner(summaries: summaries)),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  count: summaries.length,
                  activeSort: _groupSort.value,
                  onSortSelected: (v) => _groupSort.value = v,
                ),
              ),
              _GroupsBody(
                summaries: summaries,
                order: order,
                isLoading: groupCtrl.isLoading.value,
                error: groupCtrl.error.value,
              ),
              const SliverToBoxAdapter(child: _NewGroupButton()),
            ],
          ),
        );
      }),
    );
  }
}

// ── Overall balance banner ──────────────────────────────────────────────────
class _OverallBalanceBanner extends StatelessWidget {
  const _OverallBalanceBanner({required this.summaries});
  final List<GroupSummary> summaries;

  @override
  Widget build(BuildContext context) {
    double totalOwed = 0;
    double totalOwe = 0;
    for (final s in summaries) {
      final net = s.balance.net;
      if (net > 0) totalOwed += net;
      if (net < 0) totalOwe += net.abs();
    }
    final netOverall = totalOwed - totalOwe;
    final isPositive = netOverall >= 0;
    final accent = isPositive ? Constants.activeColor : Constants.redColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withOpacity(0.15), accent.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: accent.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: accent,
                size: 18.w,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Overall balance",
                      style: AppTheme.normalText.copyWith(color: Colors.grey)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: isPositive ? "You are owed " : "You owe ",
                        style: AppTheme.normalText,
                      ),
                      TextSpan(
                        text: "\$${netOverall.abs().toStringAsFixed(2)}",
                        style: AppTheme.normalText.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MiniStat(
                  label: "owed",
                  value: "\$${totalOwed.toStringAsFixed(2)}",
                  color: Constants.activeColor,
                ),
                const SizedBox(height: 4),
                _MiniStat(
                  label: "owe",
                  value: "\$${totalOwe.toStringAsFixed(2)}",
                  color: Constants.redColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header (count + sort menu) ───────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.count,
    required this.activeSort,
    required this.onSortSelected,
  });
  final int count;
  final String activeSort;
  final ValueChanged<String> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text("$count Groups", style: AppTheme.subHeadingText),
          const Spacer(),
          _GroupSortMenu(active: activeSort, onSelected: onSortSelected),
        ],
      ),
    );
  }
}

// ── Styled sort menu ─────────────────────────────────────────────────────────
class _GroupSortMenu extends StatelessWidget {
  const _GroupSortMenu({required this.active, required this.onSelected});
  final String active;
  final ValueChanged<String> onSelected;

  static const _options = [
    (
      value: 'outstanding',
      label: 'Outstanding first',
      icon: Icons.outbond_outlined,
    ),
    (value: 'name', label: 'Name (A–Z)', icon: Icons.sort_by_alpha_rounded),
    (
      value: 'amount',
      label: 'Amount (high to low)',
      icon: Icons.attach_money_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      tooltip: 'Sort groups',
      offset: const Offset(0, 40),
      color: Constants.bgColorLight,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      shadowColor: Colors.black.withOpacity(0.15),
      icon: SvgPicture.asset(Constants.filterLineLogo, width: 20, height: 20),
      itemBuilder: (_) => _options.map((opt) {
        final isActive = opt.value == active;
        return PopupMenuItem<String>(
          value: opt.value,
          height: 46,
          child: Row(
            children: [
              Icon(
                opt.icon,
                size: 18,
                color: isActive ? Constants.activeColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opt.label,
                  style: AppTheme.normalText.copyWith(
                    color: isActive ? Constants.activeColor : null,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isActive)
                const Icon(Icons.check_rounded,
                    size: 18, color: Constants.activeColor),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Group cards / loading / empty state ──────────────────────────────────────
class _GroupsBody extends StatelessWidget {
  const _GroupsBody({
    required this.summaries,
    required this.order,
    required this.isLoading,
    required this.error,
  });
  final List<GroupSummary> summaries;
  final List<int> order;
  final bool isLoading;
  final String error;

  @override
  Widget build(BuildContext context) {
    if (isLoading && summaries.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: Constants.activeColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (error.isNotEmpty && summaries.isEmpty) {
      return const SliverFillRemaining(child: _GroupsErrorState());
    }
    if (summaries.isEmpty) {
      return const SliverFillRemaining(child: _GroupsEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GroupCard(index: order[i]),
          ),
          childCount: order.length,
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class _GroupsEmptyState extends StatelessWidget {
  const _GroupsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 52.w, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text("No groups yet", style: AppTheme.subHeadingText),
          const SizedBox(height: 4),
          Text(
            "Create a group to start splitting",
            style: AppTheme.normalText.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.to(() => const CreateGroupScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Constants.activeColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start a new group',
                    style: AppTheme.subHeadingText.copyWith(
                      color: Colors.white,
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
  }
}

// ── Error state ─────────────────────────────────────────────────────────────
class _GroupsErrorState extends StatelessWidget {
  const _GroupsErrorState();

  @override
  Widget build(BuildContext context) {
    final groupCtrl = Get.find<GroupsController>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Constants.redColor.withAlpha(15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.wifi_off_rounded,
                  size: 28, color: Constants.redColor),
            ),
            const SizedBox(height: 16),
            Text("Couldn't load groups",
                style: AppTheme.subHeadingText
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Obx(() => Text(groupCtrl.error.value,
                style:
                    AppTheme.normalText.copyWith(color: Colors.grey.shade400),
                textAlign: TextAlign.center)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => groupCtrl.fetchSummary(forceRefresh: true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color: Constants.activeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Try again',
                    style: AppTheme.normalText.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom "new group" button ────────────────────────────────────────────────
class _NewGroupButton extends StatelessWidget {
  const _NewGroupButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: GestureDetector(
        onTap: () => Get.to(() => const CreateGroupScreen()),
        child: Container(
          width: double.infinity,
          height: 48.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Constants.activeColor.withAlpha(120)),
            color: Constants.activeColor.withAlpha(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded,
                  color: Constants.activeColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Start a new group',
                style: AppTheme.subHeadingText.copyWith(
                  color: Constants.activeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini stat (owed / owe) ───────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.normalText.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.normalText.copyWith(color: Colors.grey)),
      ],
    );
  }
}
