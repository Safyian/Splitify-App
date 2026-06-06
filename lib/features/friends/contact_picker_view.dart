import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../shared/contacts/contact_picker_widget.dart';
import '../../shared/widgets/alert_widgets.dart';
import '../../shared/widgets/app_dialogs.dart';
import 'friends_controller.dart';

class ContactPickerView extends StatefulWidget {
  const ContactPickerView({super.key});

  @override
  State<ContactPickerView> createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  final _friendsCtrl = Get.find<FriendsController>(tag: 'friends');

  Future<void> _onRegistered(
      String userId, String name, String? email, String? phone) async {
    AppDialogs.loading(
      message: 'Adding $name...',
      icon: Icons.person_add_outlined,
    );
    try {
      await _friendsCtrl.addFriendById(userId);
      await AppDialogs.closeLoading();
      AppDialogs.success(
        title: '$name Added!',
        message: '$name is now in your friends list.',
        closePop: 3,
      );
    } catch (e) {
      await AppDialogs.closeLoading();
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onUnregistered(
      String name, String? email, String? phone) async {
    // ignore: use_build_context_synchronously
    AppDialogs.invite(
      name: name,
      inviteMessage:
          'Hey $name! I\'m using Splittify to split bills with friends. '
          'Join me here: splittify.app/download',
      context: context,
      closePop: 3,
      onInviteConfirmed: () async {
        await _friendsCtrl.inviteFriend(
          name: name,
          phone: phone,
          email: email,
        );
      },
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
        title: Text('Select Contact', style: AppTheme.headingText),
      ),
      body: ContactPickerWidget(
        onRegisteredContactTap: _onRegistered,
        onUnregisteredContactTap: _onUnregistered,
      ),
    );
  }
}
