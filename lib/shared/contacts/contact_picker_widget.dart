import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import '../../core/utils/hash_helper.dart';
import '../../features/friends/friends_services.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/app_dialogs.dart';
import 'person_row.dart';

/// Context-agnostic contact picker.
///
/// Owns all of:
///   - contacts permission request (granted / limited / denied / permanentlyDenied)
///   - limited-access banner + "Update" link
///   - permission-denied state with "Open Settings" button
///   - device contact loading + search
///   - phone normalisation + SHA-256 hashing
///   - backend registration check (single-contact lookup)
///
/// Callers supply two async callbacks:
///   [onRegisteredContactTap]   – contact found on Splittify → do whatever
///                                (add as friend, add as member, …)
///   [onUnregisteredContactTap] – contact not on Splittify → invite flow
///
/// Each callback is awaited while the row shows a "..." spinner; the caller is
/// responsible for showing its own loading dialog + success/invite dialogs.
///
/// Pass [addedIdentifiers] (a set of emails / normalised phones) so that rows
/// whose contact is already added show an "Added" chip instead of the Add button.
class ContactPickerWidget extends StatefulWidget {
  const ContactPickerWidget({
    super.key,
    required this.onRegisteredContactTap,
    required this.onUnregisteredContactTap,
    this.addedIdentifiers,
  });

  /// Called after the hash-check confirms the contact is a registered user.
  /// Args: userId, displayName, normalised email (nullable), normalised phone (nullable).
  final Future<void> Function(
    String userId,
    String name,
    String? email,
    String? phone,
  ) onRegisteredContactTap;

  /// Called after the hash-check confirms the contact has no Splittify account.
  /// Args: displayName, normalised email (nullable), normalised phone (nullable).
  final Future<void> Function(
    String name,
    String? email,
    String? phone,
  ) onUnregisteredContactTap;

  /// Emails and normalised phone numbers already present in the target list
  /// (e.g. current group members). Rows matching any identifier show "Added".
  final Set<String>? addedIdentifiers;

  @override
  State<ContactPickerWidget> createState() => _ContactPickerWidgetState();
}

class _ContactPickerWidgetState extends State<ContactPickerWidget> {
  final _searchCtrl = TextEditingController();
  final _service = FriendService();

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isLimitedAccess = false;

  // The contact currently being hash-checked — disables that row's button.
  String? _processingContactId;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Permission + contact load ────────────────────────────────────────────

  Future<void> _loadContacts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _permissionDenied = false;
        _isLimitedAccess = false;
      });
    }
    try {
      final status =
          await FlutterContacts.permissions.request(PermissionType.read);

      if (status == PermissionStatus.permanentlyDenied ||
          status == PermissionStatus.restricted) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _permissionDenied = true;
          });
        }
        return;
      }
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        // denied (not permanently) — still treat as denied
        if (mounted) {
          setState(() {
            _isLoading = false;
            _permissionDenied = true;
          });
        }
        return;
      }
      if (status == PermissionStatus.limited && mounted) {
        setState(() => _isLimitedAccess = true);
      }

      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.email, ContactProperty.phone},
      );
      final filtered = contacts
          .where((c) => c.phones.isNotEmpty || c.emails.isNotEmpty)
          .toList()
        ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

      if (mounted) {
        setState(() {
          _allContacts = filtered;
          _filteredContacts = filtered;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts
          .where((c) => (c.displayName ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  // ── Already-added check ──────────────────────────────────────────────────

  bool _isContactAdded(Contact contact) {
    final ids = widget.addedIdentifiers;
    if (ids == null || ids.isEmpty) return false;
    for (final e in contact.emails) {
      if (ids.contains(e.address.toLowerCase().trim())) return true;
    }
    for (final p in contact.phones) {
      final normalised = HashHelper.normalisePhone(p.number);
      if (normalised != null && ids.contains(normalised)) return true;
    }
    return false;
  }

  // ── Contact tap → hash check → callback ─────────────────────────────────

  Future<void> _onContactTap(Contact contact) async {
    if (_processingContactId != null) return; // block while one is in flight

    final phone = contact.phones.isNotEmpty
        ? HashHelper.normalisePhone(contact.phones.first.number)
        : null;
    final email = contact.emails.isNotEmpty
        ? contact.emails.first.address.toLowerCase().trim()
        : null;

    if (phone == null && email == null) {
      AlertWidgets.showSnackBar(
          message: '${contact.displayName ?? 'Contact'} has no phone or email');
      return;
    }

    final name = contact.displayName ?? '';
    final contactId = contact.id ?? '';

    if (mounted) setState(() => _processingContactId = contactId);

    AppDialogs.loading(
      message: 'Checking $name',
      subtitle: 'Looking up on Splittify...',
      icon: Icons.person_search_outlined,
    );

    try {
      final phoneHash = phone != null ? HashHelper.hashPhone(phone) : null;
      final emailHash = email != null ? HashHelper.hashContact(email) : null;

      final result = await _service.checkSingleContact(
        phoneHash: phoneHash,
        emailHash: emailHash,
      );

      if (!mounted) return;
      await AppDialogs.closeLoading();

      if (result['isRegistered'] == true) {
        final user = result['user'] as Map<String, dynamic>;
        final userId = user['id'] as String;
        await widget.onRegisteredContactTap(userId, name, email, phone);
      } else {
        await widget.onUnregisteredContactTap(name, email, phone);
      }
    } catch (e) {
      if (mounted) {
        await AppDialogs.closeLoading();
        AlertWidgets.showSnackBar(
            message: e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _processingContactId = null);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _PermissionDeniedState(
        onOpenSettings: () async {
          await FlutterContacts.permissions.openSettings();
          if (mounted) _loadContacts();
        },
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Constants.bgColorLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withAlpha(30)),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: _searchCtrl,
              style: AppTheme.normalText.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: AppTheme.normalText
                    .copyWith(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 20),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),

        // Limited-access banner
        if (_isLimitedAccess)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withAlpha(60)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing limited contacts. Tap to select more.',
                      style: AppTheme.normalText.copyWith(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async =>
                        FlutterContacts.permissions.openSettings(),
                    child: Text(
                      'Update',
                      style: AppTheme.normalText.copyWith(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Contact list
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Constants.activeColor, strokeWidth: 2))
              : _filteredContacts.isEmpty
                  ? Center(
                      child: Text('No contacts found',
                          style:
                              AppTheme.normalText.copyWith(color: Colors.grey)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: _filteredContacts.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.withAlpha(20)),
                      itemBuilder: (_, i) {
                        final contact = _filteredContacts[i];
                        final contactId = contact.id ?? '';
                        final isProcessing = _processingContactId == contactId;
                        final displayName = contact.displayName ?? '';

                        // Prefer email as subtitle; fall back to phone number.
                        final subtitle = contact.emails.isNotEmpty
                            ? contact.emails.first.address
                            : contact.phones.isNotEmpty
                                ? contact.phones.first.number
                                : null;

                        // Check if this contact is already added.
                        final added = widget.addedIdentifiers != null &&
                            _isContactAdded(contact);

                        return PersonRow(
                          name: displayName,
                          subtitle: subtitle,
                          isAdded: added,
                          isProcessing: isProcessing,
                          onTap: added ? null : () => _onContactTap(contact),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ── Permission denied state ────────────────────────────────────────────────────
class _PermissionDeniedState extends StatelessWidget {
  const _PermissionDeniedState({required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.contacts_outlined,
                  size: 32, color: Colors.orange.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'Contacts Access Required',
              style: AppTheme.subHeadingText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable contacts access in Settings to continue.',
              style: AppTheme.normalText
                  .copyWith(color: Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onOpenSettings,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  color: Constants.activeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Open Settings',
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
    );
  }
}
