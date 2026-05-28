import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/app_themes.dart';
import 'auth_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final c = Get.find<AuthController>();
  final _obscure = true.obs;
  final _usePhone = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // ── Branding ──────────────────────────────────────
                      SvgPicture.asset(
                        Constants.splitifyLogo,
                        height: 40.w,
                      ),

                      SizedBox(height: 0.065.sh),

                      // ── Title ─────────────────────────────────────────
                      Text(
                        'Create your account ✨',
                        style: AppTheme.headingText.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Split expenses fairly with everyone',
                        style: AppTheme.normalText.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Full name label ───────────────────────────────
                      Text(
                        'Full name',
                        style: AppTheme.normalText.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // ── Name field ────────────────────────────────────
                      Obx(() {
                        final err = c.fieldErrors['name'] ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Constants.bgColorLight,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: err.isNotEmpty
                                      ? Constants.redColor
                                      : Colors.grey.withAlpha(30),
                                ),
                              ),
                              child: TextFormField(
                                controller: c.nameCtrl,
                                keyboardType: TextInputType.name,
                                style: AppTheme.normalText
                                    .copyWith(fontSize: 13.sp),
                                decoration: InputDecoration(
                                  hintText: 'John Doe',
                                  hintStyle: AppTheme.normalText.copyWith(
                                    color: Colors.grey.shade400,
                                    fontSize: 13.sp,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 14.h),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (err.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                err,
                                style: AppTheme.normalText.copyWith(
                                  fontSize: 11.sp,
                                  color: Constants.redColor,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      SizedBox(height: 20.h),

                      // ── Email / Phone toggle ──────────────────────────
                      Obx(() => _AuthToggle(
                            usePhone: _usePhone.value,
                            onEmailTap: () => _usePhone.value = false,
                            onPhoneTap: () => _usePhone.value = true,
                          )),
                      SizedBox(height: 20.h),

                      // ── Dynamic field label ───────────────────────────
                      Obx(() => Text(
                            _usePhone.value ? 'Phone number' : 'Email address',
                            style: AppTheme.normalText.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          )),
                      SizedBox(height: 6.h),

                      // ── Email or Phone field ──────────────────────────
                      Obx(() {
                        if (_usePhone.value) {
                          return IntlPhoneField(
                            initialCountryCode: 'AU',
                            style:
                                AppTheme.normalText.copyWith(fontSize: 13.sp),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: AppTheme.normalText.copyWith(
                                color: Colors.grey.shade400,
                                fontSize: 13.sp,
                              ),
                              filled: true,
                              fillColor: Constants.bgColorLight,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.withAlpha(30)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.withAlpha(30)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                    color: Constants.activeColor, width: 1.5),
                              ),
                            ),
                            onChanged: (phone) {
                              c.completePhone.value = phone.completeNumber;
                            },
                          );
                        }
                        final err = c.fieldErrors['email'] ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Constants.bgColorLight,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: err.isNotEmpty
                                      ? Constants.redColor
                                      : Colors.grey.withAlpha(30),
                                ),
                              ),
                              child: TextFormField(
                                controller: c.emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTheme.normalText
                                    .copyWith(fontSize: 13.sp),
                                decoration: InputDecoration(
                                  hintText: 'you@example.com',
                                  hintStyle: AppTheme.normalText.copyWith(
                                    color: Colors.grey.shade400,
                                    fontSize: 13.sp,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 14.h),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (err.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                err,
                                style: AppTheme.normalText.copyWith(
                                  fontSize: 11.sp,
                                  color: Constants.redColor,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      SizedBox(height: 14.h),

                      // ── Password label ────────────────────────────────
                      Text(
                        'Password',
                        style: AppTheme.normalText.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // ── Password field ────────────────────────────────
                      Obx(() {
                        final err = c.fieldErrors['password'] ?? '';
                        final isObscure = _obscure.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Constants.bgColorLight,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: err.isNotEmpty
                                      ? Constants.redColor
                                      : Colors.grey.withAlpha(30),
                                ),
                              ),
                              child: TextFormField(
                                controller: c.passCtrl,
                                obscureText: isObscure,
                                style: AppTheme.normalText
                                    .copyWith(fontSize: 13.sp),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: AppTheme.normalText.copyWith(
                                    color: Colors.grey.shade400,
                                    fontSize: 13.sp,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 14.h),
                                  border: InputBorder.none,
                                  suffixIcon: GestureDetector(
                                    onTap: () =>
                                        _obscure.value = !_obscure.value,
                                    child: Icon(
                                      isObscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (err.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                err,
                                style: AppTheme.normalText.copyWith(
                                  fontSize: 11.sp,
                                  color: Constants.redColor,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      SizedBox(height: 36.h),

                      // ── Create account button ─────────────────────────
                      GestureDetector(
                        onTap: () {
                          if (c.isLoading.value) return;
                          _usePhone.value
                              ? c.registerWithPhone()
                              : c.register();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          decoration: BoxDecoration(
                            color: Constants.activeColor,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          alignment: Alignment.center,
                          child: Obx(() => c.isLoading.value
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create account',
                                  style: AppTheme.normalText.copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                )),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Login link ────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: AppTheme.normalText.copyWith(
                                  color: Colors.grey.shade500,
                                  fontSize: 13.sp,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign in',
                                style: AppTheme.normalText.copyWith(
                                  color: Constants.activeColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthToggle extends StatelessWidget {
  const _AuthToggle({
    required this.usePhone,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  final bool usePhone;
  final VoidCallback onEmailTap;
  final VoidCallback onPhoneTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        children: [
          _tab('Email', !usePhone, onEmailTap),
          _tab('Phone', usePhone, onPhoneTap),
        ],
      ),
    );
  }

  Widget _tab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive
                ? Constants.activeColor.withAlpha(50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: isActive
                ? Border.all(color: Constants.activeColor.withAlpha(60))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.normalText.copyWith(
              color: isActive ? Constants.activeColor : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
