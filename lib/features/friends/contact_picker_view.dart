import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../core/utils/hash_helper.dart';
import '../../shared/widgets/alert_widgets.dart';
import '../../shared/widgets/app_dialogs.dart';
import 'friends_controller.dart';
import 'friends_services.dart';

class ContactPickerView extends StatefulWidget {
  const ContactPickerView({super.key});

  @override
  State<ContactPickerView> createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  final _searchCtrl = TextEditingController();
  final _friendsCtrl = Get.find<FriendsController>(tag: 'friends');
  final _friendsService = FriendService();

  List<Contact> _allContacts = [];
  List<Contact> _filtered = [];
  bool _isLoading = true;
  bool _isLimitedAccess = false;
  final Map<String, bool> _addingContact = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _checkLimitedAccess();
    _searchCtrl.addListener(_filter);
  }

  Future<void> _checkLimitedAccess() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.readWrite);
    if (mounted && status == PermissionStatus.limited) {
      setState(() => _isLimitedAccess = true);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.email, ContactProperty.phone},
      );
      final filtered = contacts
          .where((c) => c.phones.isNotEmpty || c.emails.isNotEmpty)
          .toList()
        ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

      setState(() {
        _allContacts = filtered;
        _filtered = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      AlertWidgets.showSnackBar(message: 'Failed to load contacts');
    }
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allContacts
          .where((c) => (c.displayName ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addContact(Contact contact) async {
    final contactId = contact.id ?? '';
    final ctx = context; // capture before any async gap
    setState(() => _addingContact[contactId] = true);
    AppDialogs.loading(
      message: 'Checking ${contact.displayName ?? ''}',
      subtitle: 'Looking up on Splittify...',
      icon: Icons.person_search_outlined,
    );

    try {
      final phone = contact.phones.isNotEmpty
          ? HashHelper.normalisePhone(contact.phones.first.number)
          : null;
      final email = contact.emails.isNotEmpty
          ? contact.emails.first.address.toLowerCase().trim()
          : null;

      if (phone == null && email == null) {
        AlertWidgets.showSnackBar(
            message:
                '${contact.displayName ?? 'Contact'} has no phone or email');
        return;
      }

      final phoneHash = phone != null ? HashHelper.hashPhone(phone) : null;
      final emailHash = email != null ? HashHelper.hashContact(email) : null;

      final result = await _friendsService.checkSingleContact(
        phoneHash: phoneHash,
        emailHash: emailHash,
      );

      if (!mounted) return;

      final name = contact.displayName ?? '';
      if (result['isRegistered'] == true) {
        final user = result['user'] as Map<String, dynamic>;
        final userId = user['id'] as String;
        await _friendsCtrl.addFriendById(userId);
        if (!mounted) return;
        await AppDialogs.closeLoading();
        AppDialogs.success(
          title: '$name Added!',
          message: '$name is now in your friends list.',
          closePop: 3,
        );
      } else {
        if (!mounted) return;
        await AppDialogs.closeLoading();
        // ignore: use_build_context_synchronously
        AppDialogs.invite(
          name: name,
          inviteMessage:
              'Hey $name! I\'m using Splittify to split bills with friends. Join me here: splittify.app/download',
          context: ctx,
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
    } catch (e) {
      if (mounted) {
        await AppDialogs.closeLoading();
        AlertWidgets.showSnackBar(
            message: e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _addingContact.remove(contactId));
      }
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
        title: Text('Select Contact', style: AppTheme.headingText),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: Constants.bgColorLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withAlpha(30)),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTheme.normalText.copyWith(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: AppTheme.normalText
                      .copyWith(color: Colors.grey.shade400, fontSize: 13.sp),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey.shade400, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
              ),
            ),
          ),

          // Limited access banner
          if (_isLimitedAccess)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.orange.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16.sp, color: Colors.orange.shade700),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Showing limited contacts. Tap to select more.',
                        style: AppTheme.normalText.copyWith(
                          fontSize: 12.sp,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () async {
                        await FlutterContacts.permissions.openSettings();
                      },
                      child: Text(
                        'Update',
                        style: AppTheme.normalText.copyWith(
                          fontSize: 12.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Contact count
          if (!_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} contacts',
                  style: AppTheme.normalText
                      .copyWith(color: Colors.grey.shade400, fontSize: 12.sp),
                ),
              ),
            ),

          // Contact list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Constants.activeColor, strokeWidth: 2))
                : _filtered.isEmpty
                    ? Center(
                        child: Text('No contacts found',
                            style: AppTheme.normalText
                                .copyWith(color: Colors.grey)))
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.grey.withAlpha(20),
                        ),
                        itemBuilder: (context, i) {
                          final contact = _filtered[i];
                          final isAdding = _addingContact[contact.id] == true;
                          final displayName = contact.displayName ?? '';
                          final initial = displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?';
                          final subtitle = contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : contact.emails.isNotEmpty
                                  ? contact.emails.first.address
                                  : '';

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor:
                                      Constants.activeColor.withAlpha(20),
                                  child: Text(initial,
                                      style: AppTheme.normalText.copyWith(
                                        color: Constants.activeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      )),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(displayName,
                                          style: AppTheme.normalText.copyWith(
                                              fontWeight: FontWeight.w500)),
                                      if (subtitle.isNotEmpty)
                                        Text(subtitle,
                                            style: AppTheme.normalText.copyWith(
                                              color: Colors.grey.shade400,
                                              fontSize: 11.sp,
                                            )),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isAdding
                                      ? null
                                      : () => _addContact(contact),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 4.w),
                                    decoration: BoxDecoration(
                                      color: isAdding
                                          ? Constants.bgColorLight
                                          : Constants.activeColor.withAlpha(15),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color:
                                            Constants.activeColor.withAlpha(60),
                                      ),
                                    ),
                                    child: Text(
                                      'Add',
                                      style: AppTheme.normalText.copyWith(
                                        color: Constants.activeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
