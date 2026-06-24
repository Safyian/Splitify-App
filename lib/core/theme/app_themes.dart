import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/constants.dart';

class AppTheme {
  static TextStyle headingText = TextStyle(
      fontFamily: 'Inter',
      fontSize: 16.sp,
      color: Constants.textDark,
      fontWeight: FontWeight.w600);
  static TextStyle subHeadingText = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14.sp,
      color: Constants.textDark,
      fontWeight: FontWeight.w500);
  static TextStyle normalText = TextStyle(
      fontFamily: 'Inter',
      fontSize: 13.sp,
      color: Constants.textDark,
      fontWeight: FontWeight.w500);
}
