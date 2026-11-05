import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';

void main() async {
  await initializationClass();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/lang',
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      saveLocale: true,
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: HotRestartController(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (ctx, child) {
            return const MyApp();
          },
        ),
      ),
    ),
  );
}
