import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:splittify/features/auth/Views/splash_view.dart';

import 'core/bindings/initial_binding.dart';
import 'core/constants/constants.dart';

Future<void> main() async {
  await _setup();

  runApp(
    ScreenUtilInit(
      builder: (_, child) => GetMaterialApp(
        defaultTransition: Transition.topLevel,
        debugShowCheckedModeBanner: false,
        enableLog: false,
        initialBinding: InitialBinding(), // ← controllers created once, here
        theme: ThemeData(
          fontFamily: 'Inter',
          scaffoldBackgroundColor: Constants.bgColor,
        ),

        home: const SplashView(),
      ),
      designSize: const Size(414, 896),
    ),
  );
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await ScreenUtil.ensureScreenSize();
}
