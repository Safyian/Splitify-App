import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // color palette
  static const Color bgColor = Color(0XFFF2F1F8);
  static const Color bgColorLight = Colors.white;
  static const Color activeColor = Color(0XFF0DAD85);
  static const Color redColor = Color(0XFFE56D39);
  static const Color chipColor = Color(0XFF373B3F);
  static const Color textDark = Colors.black;
  static Color textLight = Colors.white;
  static Color textGrey = Colors.grey.shade600;

  // images
  static const String friendsLogo = "assets/images/Friends.svg";
  static const String groupsLogo = "assets/images/Groups.svg";
  static const String addLogo = "assets/images/Add.svg";
  static const String activityLogo = "assets/images/Activity.svg";
  static const String userLogo = "assets/images/User.svg";
  static const String profileLogo = "assets/images/Profile.svg";
  static const String searchLogo = "assets/images/search.svg";
  static const String teamsLogo = "assets/images/Teams.svg";
  static const String filterLogo = "assets/images/filter.svg";
  static const String filterLineLogo = "assets/images/filter-02.svg";
  static const String notificationLogo = "assets/images/notification.svg";
  static const String walletLogo = "assets/images/wallet.svg";
  static const String rightLogo = "assets/images/Right-arrow.svg";
  static const String premiumLogo = "assets/images/premium.svg";
  static const String backLogo = "assets/images/Left-arrow.svg";
  static const String settingsLogo = "assets/images/settings.svg";
  static const String paidLogo = "assets/images/wallet.svg";
  static const String meatLogo = "assets/images/Meat.svg";
  static const String groceryLogo = "assets/images/Store.svg";
  static const String settleLogo = "assets/images/settle.json";
  static const String arrowLogo = "assets/images/arrow.json";
  static const String cashLogo = "assets/images/cash.svg";
  static const String settledLogo = "assets/images/like.png";
  static const String splitifyLogo = "assets/images/splitify-logo.svg";
}

// ********* TextField Input Decoration Constant **********
InputDecoration inputDecoration = InputDecoration(
  isDense: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    // borderSide: const BorderSide(color: Colors.grey, width: 1.0),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    // borderSide: const BorderSide(color: Colors.grey, width: 1.0),
    // borderSide: BorderSide.none,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.red, width: 1.0),
    // borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    // borderSide: BorderSide(color: Colors.grey, width: 1.0),
    // borderSide: BorderSide.none,
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.red, width: 1.0),
    // borderSide: BorderSide.none,
  ),
  errorStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.red),
  // hintText: 'xyz@abc.com',
  hintStyle: GoogleFonts.inter(
      color: Colors.black54, fontSize: 15.sp, fontWeight: FontWeight.w600),
  // labelText: 'Email',
  labelStyle: GoogleFonts.inter(
      color: Colors.black54, fontSize: 15.sp, fontWeight: FontWeight.w600),
  filled: true,
);
