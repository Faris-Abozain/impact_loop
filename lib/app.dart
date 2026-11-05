import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impact_loop/core/notification_services/notification_service.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';
import 'package:impact_loop/features/login/cubit/cubit.dart';
import 'package:impact_loop/features/splash/cubit/cubit.dart';
import 'package:impact_loop/injector.dart' as injector;

import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => injector.serviceLocator<AuthCubit>()..restoreSession(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<SplashCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<LoginCubit>(),
        ),
        // BlocProvider(
        //   create: (_) => injector.serviceLocator<MainCubit>(),
        // ),
      ],
      child: MaterialApp(
        initialRoute: Routes.initialRoute,
        supportedLocales: context.supportedLocales,
        navigatorKey: navigatorKey,
        locale: context.locale,
        theme: appTheme(context.locale.languageCode),
        themeMode: ThemeMode.light,
        darkTheme: ThemeData.light(),
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName.tr(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
