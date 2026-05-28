import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';

class AuthLabel extends StatelessWidget {
  const AuthLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.normalText.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.errorText,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (errorText != null && errorText!.isNotEmpty)
                  ? const Color(0xFFE56D39)
                  : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: AppTheme.normalText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTheme.normalText.copyWith(color: Colors.grey.shade400),
              prefixIcon:
                  Icon(prefixIcon, size: 20, color: Colors.grey.shade400),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE56D39),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton(
      {super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Constants.activeColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSegmentedToggle extends StatelessWidget {
  const AuthSegmentedToggle({
    super.key,
    required this.value,
    required this.onEmail,
    required this.onPhone,
  });

  final RxBool value;
  final VoidCallback onEmail;
  final VoidCallback onPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Constants.bgColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEmail,
              child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: !value.value
                      ? Constants.bgColorLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: !value.value
                      ? Border.all(color: Constants.activeColor.withAlpha(80))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Email',
                  style: AppTheme.normalText.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: !value.value
                        ? Constants.activeColor
                        : Colors.grey.shade500,
                  ),
                ),
              )),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: GestureDetector(
              onTap: onPhone,
              child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: value.value
                      ? Constants.bgColorLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: value.value
                      ? Border.all(color: Constants.activeColor.withAlpha(80))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Phone',
                  style: AppTheme.normalText.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: value.value
                        ? Constants.activeColor
                        : Colors.grey.shade500,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
