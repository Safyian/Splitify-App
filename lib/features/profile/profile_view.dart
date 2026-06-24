// lib/features/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splittify/core/constants/constants.dart';
import 'package:splittify/features/auth/Controllers/auth_controller.dart';
import 'package:splittify/features/groups/Controllers/groups_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_themes.dart';
import '../../shared/widgets/app_dialogs.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final authCtrl = Get.find<AuthController>();
  final profileCtrl = Get.find<ProfileController>();
  final groupsCtrl = Get.find<GroupsController>();

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not open link');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profileCtrl.user.value.user == null) {
      profileCtrl.getUserDetails();
    }

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Profile', style: AppTheme.headingText),
        // actions: [
        //   SvgPicture.asset(Constants.premiumLogo, width: 20, height: 20),
        //   const SizedBox(width: 16),
        // ],
        backgroundColor: Constants.bgColor,
        foregroundColor: Constants.bgColor,
        elevation: 0,
      ),
      body: Obx(() {
        final user = profileCtrl.user.value.user;
        final summaries = groupsCtrl.summaries;

        double totalOwed = 0;
        double totalOwe = 0;
        for (final s in summaries) {
          final net = s.balance.net;
          if (net > 0) totalOwed += net;
          if (net < 0) totalOwe += net.abs();
        }
        final netBalance = totalOwed - totalOwe;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar card ─────────────────────────────────
              _AvatarCard(
                user: user,
                onEditTap: () => _showEditNameSheet(profileCtrl),
              ),

              const SizedBox(height: 12),

              // ── Balance summary ──────────────────────────────
              _BalanceSummaryCard(
                totalOwed: totalOwed,
                totalOwe: totalOwe,
                netBalance: netBalance,
                activeGroups: summaries.length,
              ),

              const SizedBox(height: 12),

              // ── Account ──────────────────────────────────────
              const _SectionLabel(label: 'Account'),
              const SizedBox(height: 4),
              _SettingsCard(items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Display name',
                  value: user?.name ?? '—',
                  onTap: () => _showEditNameSheet(profileCtrl),
                ),
                _SettingsItem(
                  icon: (user?.email?.isNotEmpty ?? false)
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  label: (user?.email?.isNotEmpty ?? false) ? 'Email' : 'Phone',
                  value: (user?.email?.isNotEmpty ?? false)
                      ? user!.email!
                      : (user?.phone ?? '—'),
                  onTap: null,
                ),
              ]),

              const SizedBox(height: 12),

              // ── Splittify ────────────────────────────────────
              const _SectionLabel(label: 'Splittify'),
              const SizedBox(height: 4),
              _SettingsCard(items: [
                _SettingsItem(
                  icon: Icons.person_add_outlined,
                  label: 'Invite a friend',
                  value: '',
                  onTap: () => _inviteFriend(),
                ),
              ]),

              const SizedBox(height: 12),

              // ── Support ──────────────────────────────────────
              const _SectionLabel(label: 'Support'),
              const SizedBox(height: 4),
              _SettingsCard(items: [
                _SettingsItem(
                  icon: Icons.shield_outlined,
                  label: 'Privacy Policy',
                  value: '',
                  onTap: () => openUrl('https://legal.splittify.app/#privacy'),
                ),
                _SettingsItem(
                  icon: Icons.description_outlined,
                  label: 'Terms of Use',
                  value: '',
                  onTap: () => openUrl('https://legal.splittify.app/#terms'),
                ),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  value: 'v1.0.0',
                  onTap: () => openUrl('https://legal.splittify.app/#about'),
                ),
                _SettingsItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Rate the app',
                  value: '',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 12),

              // ── Danger zone ───────────────────────────────────
              const _SectionLabel(label: 'Danger zone'),
              const SizedBox(height: 4),
              _SettingsCard(items: [
                _SettingsItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete account',
                  value: '',
                  danger: true,
                  onTap: () async {
                    final confirmed = await AppDialogs.confirm(
                      title: 'Delete Account',
                      message: 'Are you sure? This cannot be undone.',
                      confirmLabel: 'Delete',
                      confirmColor: Constants.redColor,
                    );
                    if (confirmed) await profileCtrl.deleteAccount();
                  },
                ),
              ]),

              const SizedBox(height: 26),

              // ── Logout ────────────────────────────────────────
              GestureDetector(
                onTap: () async => await authCtrl.logout(),
                child: Container(
                  width: double.infinity,
                  height: 54.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Constants.redColor.withAlpha(12),
                    border: Border.all(color: Constants.redColor.withAlpha(40)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 18, color: Constants.redColor),
                      const SizedBox(width: 8),
                      Text(
                        'Log out',
                        style: AppTheme.headingText.copyWith(
                          color: Constants.redColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Edit name bottom sheet ───────────────────────────────────────────────
  void _showEditNameSheet(ProfileController ctrl) {
    final nameCtrl =
        TextEditingController(text: ctrl.user.value.user?.name ?? '');
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Constants.bgColorLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            Text('Edit display name', style: AppTheme.headingText),
            const SizedBox(height: 4),
            Text('This is how you appear to other members',
                style: AppTheme.subHeadingText
                    .copyWith(color: Colors.grey.shade400)),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: TextFormField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: AppTheme.normalText,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle:
                      AppTheme.normalText.copyWith(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Constants.bgColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => GestureDetector(
                  onTap: ctrl.isUpdatingName.value
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await ctrl.updateName(nameCtrl.text);
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              'Updated',
                              'Display name saved',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Constants.activeColor,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Could not update name. Try again.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: ctrl.isUpdatingName.value
                          ? Constants.activeColor.withAlpha(120)
                          : Constants.activeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: ctrl.isUpdatingName.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save',
                            style: AppTheme.headingText
                                .copyWith(color: Colors.white)),
                  ),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Invite friend ────────────────────────────────────────────────────────
  // ── Invite friend ──────────────────────────────────────────────
  void _inviteFriend() {
    SharePlus.instance.share(
      ShareParams(
        text:
            "Join me on Splittify — the easiest way to split bills with friends!\n"
            "https://splittify.app",
      ),
    );
  }
}

// ── Avatar card ───────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.user, required this.onEditTap});
  final dynamic user;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '';
    final contact =
        (user?.email?.isNotEmpty ?? false) ? user!.email! : (user?.phone ?? '');
    final initials = _initials(name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Constants.activeColor, Color(0xFF0B9472)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTheme.normalText.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Your Name',
                  style: AppTheme.headingText.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                // const SizedBox(height: 3),
                Text(
                  contact.isNotEmpty ? contact : '—',
                  style: AppTheme.normalText.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Edit name shortcut
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_outlined,
                  size: 12, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ── Balance summary card ──────────────────────────────────────────────────────
class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({
    required this.totalOwed,
    required this.totalOwe,
    required this.netBalance,
    required this.activeGroups,
  });
  final double totalOwed;
  final double totalOwe;
  final double netBalance;
  final int activeGroups;

  @override
  Widget build(BuildContext context) {
    final isPositive = netBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Constants.activeColor, Color(0xFF0B9472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Constants.activeColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall balance',
            style: AppTheme.subHeadingText.copyWith(
              color: Colors.white.withAlpha(200),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            netBalance == 0
                ? 'All settled up 🎉'
                : '${isPositive ? '+' : '-'}\$${netBalance.abs().toStringAsFixed(2)}',
            style: AppTheme.headingText.copyWith(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatPill(
                  label: 'You\'re owed',
                  value: '\$${totalOwed.toStringAsFixed(2)}'),
              const SizedBox(width: 10),
              _StatPill(
                  label: 'You owe', value: '\$${totalOwe.toStringAsFixed(2)}'),
              const SizedBox(width: 10),
              _StatPill(label: 'Groups', value: '$activeGroups'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTheme.normalText.copyWith(
                    fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTheme.normalText.copyWith(
                  fontSize: 11.sp,
                  color: Colors.white.withAlpha(170),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.normalText.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            children: [
              _SettingsRow(item: items[i]),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      Divider(height: 1, color: Colors.grey.withOpacity(0.08)),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool danger;
  final bool accent;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.danger = false,
    this.accent = false,
  });
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});
  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final iconColor = item.danger
        ? Constants.redColor
        : item.accent
            ? Constants.activeColor
            : Constants.activeColor;
    final labelColor =
        item.danger ? Constants.redColor : const Color(0xFF1C1C1E);

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(15),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: AppTheme.normalText.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: labelColor,
                ),
              ),
            ),
            if (item.value.isNotEmpty)
              Text(
                item.value,
                style: AppTheme.normalText.copyWith(
                  // fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            if (item.onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey.shade300),
            ],
          ],
        ),
      ),
    );
  }
}
