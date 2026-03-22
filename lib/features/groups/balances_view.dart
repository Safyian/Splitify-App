import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/widgets/shimmer.dart';
import '../profile/profile_controller.dart';
import 'groups_controller.dart';
import 'settlement_breakdown_sheet.dart';

class BalancesView extends StatelessWidget {
  BalancesView({super.key, required this.index});
  final int index;

  final groupCtrl = Get.find<GroupsController>();
  final profileCtrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Balances", style: AppTheme.headingText),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (groupCtrl.isLoadingBalances.isTrue) {
          return const _BalancesSkeleton();
        }

        final groupId = groupCtrl.summaries[index].id;
        final myId = profileCtrl.user.value.user?.id ?? '';
        final members = groupCtrl.membersFor(groupId).members ?? [];
        final nameMap = {for (final m in members) m.id!: m.name!};

        final balances = groupCtrl.balancesFor(groupId).balances;
        final settlements = groupCtrl.balancesFor(groupId).settlements;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Net Balances ───────────────────────────────
              const _SectionHeader(label: 'Net Balances'),
              const SizedBox(height: 10),
              ...balances.map((b) {
                final isMe = b.userId == myId;
                final name = isMe ? 'You' : (nameMap[b.userId] ?? b.name);
                final isPositive = b.net > 0;
                final isZero = b.net == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Constants.bgColorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isZero
                              ? Colors.grey.shade100
                              : isPositive
                                  ? Constants.activeColor
                                      .withValues(alpha: 0.12)
                                  : Constants.redColor
                                      .withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isZero
                                ? Colors.grey
                                : isPositive
                                    ? Constants.activeColor
                                    : Constants.redColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: AppTheme.subHeadingText
                                    .copyWith(fontWeight: FontWeight.w600)),
                            if (!isZero)
                              Text(
                                isPositive ? 'gets back' : 'owes',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.grey.shade500),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isZero
                              ? Colors.grey.shade100
                              : isPositive
                                  ? Constants.activeColor
                                      .withValues(alpha: 0.10)
                                  : Constants.redColor
                                      .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isZero
                              ? 'Settled'
                              : '${isPositive ? '+' : ''}\$${b.net.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isZero
                                ? Colors.grey
                                : isPositive
                                    ? Constants.activeColor
                                    : Constants.redColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ── Suggested Settlements ──────────────────────
              Row(
                children: [
                  const _SectionHeader(label: 'Suggested Settlements'),
                  const Spacer(),
                  if (settlements.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        final gId = groupCtrl.summaries[index].id;
                        final myId =
                            profileCtrl.user.value.user?.id ?? '';
                        final breakdownData =
                            SettlementBreakdownData.fromBalancesModel(
                          groupCtrl.balancesFor(gId),
                          myId,
                        );
                        showSettlementBreakdown(context, breakdownData);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Constants.activeColor
                              .withValues(alpha: 0.10),
                          border: Border.all(
                              color: Constants.activeColor
                                  .withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate_outlined,
                                size: 13,
                                color: Constants.activeColor),
                            const SizedBox(width: 4),
                            Text(
                              'How is this calculated?',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Constants.activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              settlements.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Constants.bgColorLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Constants.activeColor
                                  .withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('🎉',
                                style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(height: 10),
                          Text('Everyone is settled up!',
                              style: AppTheme.subHeadingText.copyWith(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'No outstanding balances in this group.',
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey.shade400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: settlements.map((s) {
                        final members =
                            groupCtrl.membersFor(groupId).members ?? [];
                        final nameMap = {
                          for (final m in members) m.id!: m.name!
                        };
                        final fromName = s.from == myId
                            ? 'You'
                            : (nameMap[s.from] ?? s.fromName);
                        final toName = s.to == myId
                            ? 'you'
                            : (nameMap[s.to] ?? s.toName);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Constants.bgColorLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Constants.redColor
                                    .withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Constants.redColor
                                      .withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: Constants.redColor, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: '$fromName ',
                                        style: AppTheme.subHeadingText
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                    TextSpan(
                                        text: 'owes ',
                                        style: AppTheme.normalText.copyWith(
                                            color: Colors.grey.shade500)),
                                    TextSpan(
                                        text: toName,
                                        style: AppTheme.subHeadingText
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                  ]),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${s.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Constants.redColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ── Skeleton loading state ────────────────────────────────────────────────────
class _BalancesSkeleton extends StatelessWidget {
  const _BalancesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Constants.activeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color:
                            Constants.activeColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calculating balances…',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Constants.activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Net Balances label
            const ShimmerBox(width: 90, height: 12, borderRadius: 4),
            const SizedBox(height: 12),
            _balanceRowSkeleton(100),
            _balanceRowSkeleton(140),
            _balanceRowSkeleton(80),

            const SizedBox(height: 28),

            // Settlements label
            const ShimmerBox(width: 140, height: 12, borderRadius: 4),
            const SizedBox(height: 12),
            _settlementRowSkeleton(120),
            _settlementRowSkeleton(90),
          ],
        ),
      ),
    );
  }

  Widget _balanceRowSkeleton(double nameWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 38, height: 38, shape: BoxShape.circle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: nameWidth, height: 12, borderRadius: 4),
                const SizedBox(height: 5),
                const ShimmerBox(width: 50, height: 10, borderRadius: 4),
              ],
            ),
          ),
          const ShimmerBox(width: 64, height: 28, borderRadius: 20),
        ],
      ),
    );
  }

  Widget _settlementRowSkeleton(double nameWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 34, height: 34, shape: BoxShape.circle),
          const SizedBox(width: 12),
          Expanded(
            child:
                ShimmerBox(width: nameWidth, height: 12, borderRadius: 4),
          ),
          const SizedBox(width: 12),
          const ShimmerBox(width: 50, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
