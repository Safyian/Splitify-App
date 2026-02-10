import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

class AppTheme {
  static TextStyle headingText = GoogleFonts.inter(
      fontSize: 16.sp, color: Constants.textDark, fontWeight: FontWeight.w600);
  static TextStyle subHeadingText = GoogleFonts.inter(
      fontSize: 14.sp, color: Constants.textDark, fontWeight: FontWeight.w500);
  static TextStyle normalText = GoogleFonts.inter(
      fontSize: 13.sp, color: Constants.textDark, fontWeight: FontWeight.w500);
}
