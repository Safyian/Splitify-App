import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/widgets/alert_widgets.dart';
import '../../shared/widgets/app_dialogs.dart';
import 'contact_picker_view.dart';
import 'friends_controller.dart';

class AddFriendView extends StatefulWidget {
  const AddFriendView({super.key});

  @override
  State<AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  final _emailCtrl = TextEditingController();
  final friendsCtrl = Get.find<FriendsController>(tag: 'friends');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addByEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AlertWidgets.showSnackBar(message: 'Enter a valid email address');
      return;
    }

    final ctx = context; // capture before any async gap
    AppDialogs.loading(
      message: 'Finding friend...',
      subtitle: 'Looking up on Splittify...',
      icon: Icons.person_search_outlined,
    );

    try {
      await friendsCtrl.addFriend(email: email);
      _emailCtrl.clear();
      if (!mounted) return;
      await AppDialogs.closeLoading();
      AppDialogs.success(
        title: 'Friend Added!',
        message: '$email is now in your friends list.',
        closePop: 2,
      );
    } catch (e) {
      if (mounted) {
        await AppDialogs.closeLoading();
        final msg = e.toString().replaceAll('Exception: ', '');
        if (msg.toLowerCase().contains('no splitify account') ||
            msg.toLowerCase().contains('no splittify account') ||
            msg.toLowerCase().contains('not found') ||
            msg.toLowerCase().contains('no account')) {
          final email = _emailCtrl.text.trim();
          AppDialogs.invite(
            name: email,
            inviteMessage:
                'Hey! I\'m using Splittify to split bills with friends. '
                'Join me here: splittify.app/download',
            // ignore: use_build_context_synchronously
            context: ctx,
            closePop: 1,
            onInviteConfirmed: () async {
              await friendsCtrl.inviteFriend(
                name: email,
                email: email,
              );
            },
          );
        } else {
          AlertWidgets.showSnackBar(message: msg);
        }
      }
    }
  }

  Future<void> _findFromContacts() async {
    final permStatus =
        await FlutterContacts.permissions.request(PermissionType.readWrite);
    if (!mounted) return;

    if (permStatus == PermissionStatus.permanentlyDenied ||
        permStatus == PermissionStatus.restricted) {
      final openSettings = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Constants.bgColorLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Contacts Access Required',
                  style: AppTheme.subHeadingText),
              content: Text(
                'Please enable contacts access in Settings to find friends on Splittify.',
                style:
                    AppTheme.normalText.copyWith(color: Colors.grey.shade600),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel',
                      style: AppTheme.normalText.copyWith(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('Open Settings',
                      style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ) ??
          false;
      if (openSettings) await FlutterContacts.permissions.openSettings();
      return;
    } else if (permStatus != PermissionStatus.granted &&
        permStatus != PermissionStatus.limited) {
      AlertWidgets.showSnackBar(message: 'Contacts permission is required');
      return;
    }

    // Step 3: Navigate to contact picker
    Get.to(
      () => const ContactPickerView(),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

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
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black87),
        ),
        title: Text('Add Friend', style: AppTheme.headingText),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Subtitle ─────────────────────────────────────
              Text(
                'Find friends by email or from your contacts',
                style:
                    AppTheme.normalText.copyWith(color: Colors.grey.shade500),
              ),
              SizedBox(height: 24.h),

              // ── From Contacts button ──────────────────────────
              GestureDetector(
                onTap: _findFromContacts,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Constants.activeColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12.r),
                    border:
                        Border.all(color: Constants.activeColor.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts_outlined,
                          color: Constants.activeColor, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Find from Contacts',
                        style: AppTheme.normalText.copyWith(
                          color: Constants.activeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Divider ───────────────────────────────────────
              SizedBox(height: 16.h),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or add by email',
                      style: AppTheme.normalText
                          .copyWith(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 16.h),

              // ── Email field ───────────────────────────────────
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onEditingComplete: () => FocusScope.of(context).unfocus(),
                style: AppTheme.normalText,
                decoration: InputDecoration(
                  hintText: 'email@example.com',
                  hintStyle:
                      AppTheme.normalText.copyWith(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      size: 18, color: Colors.grey),
                  filled: true,
                  fillColor: Constants.bgColorLight,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Constants.activeColor, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ── Add by email button ───────────────────────────
              GestureDetector(
                onTap: _addByEmail,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Constants.activeColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Add Friend',
                    style: AppTheme.normalText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
