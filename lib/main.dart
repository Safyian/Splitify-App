import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:splitify/Widgets/bottom_navBar.dart';

Future<void> main() async {
  await _setup();

  runApp(
    ScreenUtilInit(
      builder: (_, child) => const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: BottomNaviBar(),
      ),
      designSize: const Size(414, 896),
    ),
  );
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
