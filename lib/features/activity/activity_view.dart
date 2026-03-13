// lib/features/activity/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'activity_controller.dart';
import 'activity_model.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    final ctrl = Get.find<ActivityController>();

    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity',
                      style: AppTheme.headingText.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      )),
                  Text('Everything happening in your groups',
                      style: AppTheme.normalText.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Constants.activeColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Loading activity...',
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }
                if (ctrl.error.value.isNotEmpty) {
                  return _ErrorState(ctrl: ctrl);
                }
                if (ctrl.activities.isEmpty) {
                  return const _EmptyState();
                }
                final groups = ctrl.grouped;
                return RefreshIndicator(
                  color: Constants.activeColor,
                  backgroundColor: Constants.bgColorLight,
                  onRefresh: () => ctrl.fetchActivity(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 40),
                    itemCount: groups.length + (ctrl.hasMore.value ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == groups.length)
                        return _LoadMoreButton(ctrl: ctrl);
                      return _ActivitySection(section: groups[i]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────
class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.section});
  final ActivitySection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Text(
                section.label.toUpperCase(),
                style: AppTheme.normalText.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child:
                    Container(height: 1, color: Colors.grey.withOpacity(0.1)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(section.items.length, (i) {
              return _TimelineItem(
                activity: section.items[i],
                isLast: i == section.items.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Timeline Item ─────────────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.activity, required this.isLast});
  final ActivityModel activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spine
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.grey.withOpacity(0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Constants.bgColorLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: color.withAlpha(60), width: 3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge + time row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconData, size: 11, color: color),
                              const SizedBox(width: 4),
                              Text(
                                _typeLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(activity.createdAt),
                          style: AppTheme.normalText.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Rich description ──────────────────────
                    _RichDescription(activity: activity, accentColor: color),

                    const SizedBox(height: 8),

                    // Group name
                    Row(
                      children: [
                        Icon(Icons.group_outlined,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          activity.groupName,
                          style: AppTheme.normalText.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _initials {
    final name = activity.actorName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Color get _accentColor {
    switch (activity.type) {
      case 'member_removed':
      case 'group_left':
      case 'group_deleted':
        return Constants.redColor;
      case 'group_renamed':
        return const Color(0xFFF59E0B);
      case 'settlement_made':
        return const Color(0xFF6366F1);
      default:
        return Constants.activeColor;
    }
  }

  IconData get _iconData {
    switch (activity.type) {
      case 'expense_added':
        return Icons.receipt_long_rounded;
      case 'expense_updated':
        return Icons.edit_rounded;
      case 'settlement_made':
        return Icons.check_circle_outline_rounded;
      case 'member_added':
        return Icons.person_add_rounded;
      case 'member_removed':
        return Icons.person_remove_rounded;
      case 'group_created':
        return Icons.add_circle_outline_rounded;
      case 'group_renamed':
        return Icons.drive_file_rename_outline_rounded;
      case 'group_left':
        return Icons.logout_rounded;
      case 'group_deleted':
        return Icons.delete_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String get _typeLabel {
    switch (activity.type) {
      case 'expense_added':
        return 'EXPENSE';
      case 'expense_updated':
        return 'UPDATED';
      case 'settlement_made':
        return 'SETTLED';
      case 'member_added':
        return 'JOINED';
      case 'member_removed':
        return 'REMOVED';
      case 'group_created':
        return 'NEW GROUP';
      case 'group_renamed':
        return 'RENAMED';
      case 'group_left':
        return 'LEFT';
      case 'group_deleted':
        return 'DELETED';
      default:
        return 'ACTIVITY';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}

// ── Rich Description ──────────────────────────────────────────────────────────
class _RichDescription extends StatelessWidget {
  const _RichDescription({
    required this.activity,
    required this.accentColor,
  });
  final ActivityModel activity;
  final Color accentColor;

  // Text styles
  static final _actorStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1C1C1E),
    height: 1.45,
  );
  static final _verbStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade500,
    height: 1.45,
  );
  static final _labelStyle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF3A3A3C),
    height: 1.45,
    fontStyle: FontStyle.italic,
  );

  TextStyle get _amountStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: accentColor,
        height: 1.45,
      );

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _spans));
  }

  List<InlineSpan> get _spans {
    final meta = activity.metadata;
    final actor = activity.actorName;

    switch (activity.type) {
      case 'expense_added':
        final desc = meta['description']?.toString() ?? 'an expense';
        final rawAmt = meta['amount'];
        final amt =
            rawAmt != null ? '\$${(rawAmt as num).toStringAsFixed(2)}' : null;
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' added ', style: _verbStyle),
          TextSpan(text: desc, style: _labelStyle),
          if (amt != null) ...[
            TextSpan(text: '  ', style: _verbStyle),
            TextSpan(text: amt, style: _amountStyle),
          ],
        ];

      case 'expense_updated':
        final desc = meta['description']?.toString() ?? 'an expense';
        final rawAmt = meta['amount'];
        final amt =
            rawAmt != null ? '\$${(rawAmt as num).toStringAsFixed(2)}' : null;
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' updated ', style: _verbStyle),
          TextSpan(text: desc, style: _labelStyle),
          if (amt != null) ...[
            TextSpan(text: '  ', style: _verbStyle),
            TextSpan(text: amt, style: _amountStyle),
          ],
        ];

      case 'settlement_made':
        final rawAmt = meta['amount'];
        final amt =
            rawAmt != null ? '\$${(rawAmt as num).toStringAsFixed(2)}' : null;
        final to = meta['toName']?.toString() ?? 'someone';
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' settled up with ', style: _verbStyle),
          TextSpan(text: to, style: _actorStyle),
          if (amt != null) ...[
            TextSpan(text: ' · ', style: _verbStyle),
            TextSpan(text: amt, style: _amountStyle),
          ],
        ];

      case 'member_added':
        final target = meta['targetName']?.toString() ?? 'someone';
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' added ', style: _verbStyle),
          TextSpan(text: target, style: _actorStyle),
          TextSpan(text: ' to the group', style: _verbStyle),
        ];

      case 'member_removed':
        final target = meta['targetName']?.toString() ?? 'someone';
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' removed ', style: _verbStyle),
          TextSpan(text: target, style: _actorStyle),
          TextSpan(text: ' from the group', style: _verbStyle),
        ];

      case 'group_created':
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' created this group', style: _verbStyle),
        ];

      case 'group_renamed':
        final oldName = meta['oldName']?.toString() ?? '';
        final newName = meta['newName']?.toString() ?? '';
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' renamed the group', style: _verbStyle),
          if (oldName.isNotEmpty && newName.isNotEmpty) ...[
            TextSpan(text: ' from ', style: _verbStyle),
            TextSpan(text: oldName, style: _labelStyle),
            TextSpan(text: ' to ', style: _verbStyle),
            TextSpan(text: newName, style: _labelStyle),
          ],
        ];

      case 'group_left':
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' left the group', style: _verbStyle),
        ];

      case 'group_deleted':
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' deleted this group', style: _verbStyle),
        ];

      default:
        return [
          TextSpan(text: actor, style: _actorStyle),
          TextSpan(text: ' performed an action', style: _verbStyle),
        ];
    }
  }
}

// ── Load More ─────────────────────────────────────────────────────────────────
class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.ctrl});
  final ActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: ctrl.isLoadingMore.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Constants.activeColor,
                    ),
                  )
                : GestureDetector(
                    onTap: ctrl.loadMore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Constants.bgColorLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        'Load more',
                        style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
          ),
        ));
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.ctrl});
  final ActivityController ctrl;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.wifi_off_rounded,
                  size: 28, color: Constants.redColor),
            ),
            const SizedBox(height: 16),
            Text('Couldn\'t load activity',
                style: AppTheme.subHeadingText
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(ctrl.error.value,
                style: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade400, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => ctrl.fetchActivity(refresh: true),
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

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Constants.activeColor.withAlpha(12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.history_rounded,
                size: 36, color: Constants.activeColor.withAlpha(180)),
          ),
          const SizedBox(height: 20),
          Text('All quiet for now',
              style: AppTheme.subHeadingText.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              )),
          const SizedBox(height: 6),
          Text(
            'When expenses, settlements or\nmembers change, you\'ll see it here.',
            style: AppTheme.normalText.copyWith(
              color: Colors.grey.shade400,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
