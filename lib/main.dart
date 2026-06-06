import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:splittify/features/auth/Views/splash_view.dart';

Future<void> main() async {
  await _setup();

  runApp(
    ScreenUtilInit(
      builder: (_, child) => const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashView(),
      ),
      designSize: const Size(414, 896),
    ),
  );
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
