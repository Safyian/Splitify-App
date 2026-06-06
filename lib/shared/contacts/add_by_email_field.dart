import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';

/// Email input + submit button.
///
/// [onSubmit] receives a validated, trimmed email. It may throw — the widget
/// won't clear the field on error so the caller can show a snackbar/dialog
/// while the email stays editable. The caller must handle all error UI; this
/// widget only resets the loading spinner after [onSubmit] completes or throws.
class AddByEmailField extends StatefulWidget {
  const AddByEmailField({
    super.key,
    required this.onSubmit,
    this.buttonLabel = 'Add',
    this.hint = 'email@example.com',
    this.description,
  });

  final Future<void> Function(String email) onSubmit;
  final String buttonLabel;
  final String hint;
  final String? description;

  @override
  State<AddByEmailField> createState() => _AddByEmailFieldState();
}

class _AddByEmailFieldState extends State<AddByEmailField> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _ctrl.text.trim();
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(email);
      if (mounted) _ctrl.clear();
    } catch (_) {
      // Caller already showed error UI; just reset spinner.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.description != null) ...[
            Text(
              widget.description!,
              style: AppTheme.normalText
                  .copyWith(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
            const SizedBox(height: 4),
          ],
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTheme.normalText,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTheme.normalText.copyWith(color: Colors.grey),
                filled: true,
                fillColor: Constants.bgColorLight,
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
                  borderSide: const BorderSide(color: Constants.activeColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isLoading ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isLoading
                    ? Constants.activeColor.withAlpha(120)
                    : Constants.activeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _isLoading ? 'Adding...' : widget.buttonLabel,
                style: AppTheme.normalText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
