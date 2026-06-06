import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/constants.dart';
import '../../../core/theme/app_themes.dart';
import '../../../shared/widgets/alert_widgets.dart';
import '../../navigation/navigation_view.dart';
import '../auth_services.dart';

class VerifyPhoneView extends StatefulWidget {
  final String phone;
  final bool otpAlreadySent;
  const VerifyPhoneView({
    super.key,
    required this.phone,
    this.otpAlreadySent = true,
  });

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  final _pinCtrl = TextEditingController();
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  bool _isVerifying = false;
  bool _isResending = false;
  bool _otpSent = false;
  int _resendCountdown = 120;
  int _resendAttempts = 0;
  static const int _maxResends = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _otpSent = widget.otpAlreadySent;
    if (_otpSent) _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6) return;
    setState(() => _isVerifying = true);
    try {
      final res = await _authService.verifyPhoneOtp(
        phone: widget.phone,
        otp: otp,
      );
      await _storage.write(key: 'token', value: res['token']);
      Get.offAll(() => NavigationView());
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
      _pinCtrl.clear();
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0 || _resendAttempts >= _maxResends) return;
    setState(() => _isResending = true);
    try {
      await _authService.sendPhoneOtp(phone: widget.phone);
      setState(() => _resendAttempts++);
      _startCountdown();
      AlertWidgets.showSnackBar(message: 'OTP sent successfully');
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _isResending = true);
    try {
      await _authService.sendPhoneOtp(phone: widget.phone);
      setState(() {
        _otpSent = true;
        _resendAttempts++;
      });
      _startCountdown();
    } catch (e) {
      AlertWidgets.showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: AppTheme.headingText.copyWith(fontSize: 20.sp),
      decoration: BoxDecoration(
        color: Constants.bgColorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withAlpha(40)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Constants.activeColor, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              if (!_otpSent) ...[
                // ── STATE 1: send OTP ────────────────────────────
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Constants.activeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.sms_outlined,
                      color: Constants.activeColor, size: 28.sp),
                ),
                SizedBox(height: 20.h),
                Text('Verify your number',
                    style: AppTheme.headingText.copyWith(fontSize: 22.sp)),
                SizedBox(height: 8.h),
                Text(
                  'Tap below to send a verification code to ${widget.phone}',
                  style: AppTheme.normalText
                      .copyWith(color: Colors.grey, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 36.h),
                GestureDetector(
                  onTap: _isResending ? null : _sendOtp,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Constants.activeColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: _isResending
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Send verification code',
                            style: AppTheme.normalText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            )),
                  ),
                ),
              ] else ...[
                // ── STATE 2: enter OTP ────────────────────────────
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Constants.activeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.sms_outlined,
                      color: Constants.activeColor, size: 28.sp),
                ),
                SizedBox(height: 20.h),
                Text('Verify your number',
                    style: AppTheme.headingText.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Constants.textDark,
                    )),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Enter the 6-digit code sent to ',
                      style:
                          AppTheme.subHeadingText.copyWith(color: Colors.grey),
                    ),
                    TextSpan(
                      text: widget.phone,
                      style: AppTheme.subHeadingText.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: 36.h),

                Center(
                  child: Pinput(
                    controller: _pinCtrl,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: _verify,
                    autofocus: true,
                  ),
                ),
                SizedBox(height: 24.h),

                if (_isVerifying)
                  const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Constants.activeColor,
                    ),
                  ),

                SizedBox(height: 24.h),

                Center(
                  child: _resendAttempts >= _maxResends
                      ? Text(
                          'Maximum attempts reached. Please try again later.',
                          textAlign: TextAlign.center,
                          style: AppTheme.normalText.copyWith(
                            color: Constants.redColor,
                            fontSize: 13.sp,
                          ),
                        )
                      : _resendCountdown > 0
                          ? RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Resend code in ',
                                  style: AppTheme.normalText.copyWith(
                                    color: Colors.grey.shade400,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: '${_resendCountdown}s',
                                  style: AppTheme.normalText.copyWith(
                                    color: Constants.activeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ]),
                            )
                          : GestureDetector(
                              onTap: _isResending ? null : _resend,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Constants.activeColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                      color:
                                          Constants.activeColor.withAlpha(60)),
                                ),
                                child: _isResending
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Constants.activeColor,
                                        ),
                                      )
                                    : Text(
                                        'Resend code',
                                        style: AppTheme.normalText.copyWith(
                                          color: Constants.activeColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                              ),
                            ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
