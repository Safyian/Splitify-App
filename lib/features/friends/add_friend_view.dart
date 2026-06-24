import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/contacts/add_by_email_field.dart';
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
  final _friendsCtrl = Get.find<FriendsController>(tag: 'friends');

  Future<void> _addByEmail(String email) async {
    AppDialogs.loading(
      message: 'Finding friend...',
      subtitle: 'Looking up on Splittify...',
      icon: Icons.person_search_outlined,
    );
    try {
      await _friendsCtrl.addFriend(email: email);
      await AppDialogs.closeLoading();
      AppDialogs.success(
        title: 'Friend Added!',
        message: '$email is now in your friends list.',
        closePop: 2,
      );
    } catch (e) {
      await AppDialogs.closeLoading();
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('no splitify account') ||
          msg.toLowerCase().contains('no splittify account') ||
          msg.toLowerCase().contains('not found') ||
          msg.toLowerCase().contains('no account')) {
        // ignore: use_build_context_synchronously
        AppDialogs.invite(
          name: email,
          inviteMessage:
              'Hey! I\'m using Splittify to split bills with friends. '
              'Join me here: splittify.app/download',
          context: context,
          closePop: 1,
          onInviteConfirmed: () async {
            await _friendsCtrl.inviteFriend(name: email, email: email);
          },
        );
      } else {
        AlertWidgets.showSnackBar(message: msg);
      }
      // Rethrow so AddByEmailField keeps the field populated.
      rethrow;
    }
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
              // ── Subtitle ─────────────────────────────────────────
              Text(
                'Find friends by email or from your contacts',
                style:
                    AppTheme.normalText.copyWith(color: Colors.grey.shade500),
              ),
              SizedBox(height: 24.h),

              // ── From Contacts button ──────────────────────────────
              // ContactPickerView handles all permission logic internally.
              GestureDetector(
                onTap: () => Get.to(
                  () => const ContactPickerView(),
                ),
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

              // ── Divider ───────────────────────────────────────────
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

              // ── Add by email ──────────────────────────────────────
              AddByEmailField(
                buttonLabel: 'Add Friend',
                onSubmit: _addByEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
