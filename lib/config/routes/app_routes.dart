import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../core/utils/app_strings.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/explore/screens/explore_tab_screen.dart';
import '../../features/explore/screens/mission_detail_screen.dart';
import '../../features/explore/screens/task_detail_screen.dart';
import '../../features/home/screens/home_tab_screen.dart';
import '../../features/login/screens/login_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/screens/profile_tab_screen.dart';
import '../../features/shell/impact_shell_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/submit/screens/submission_detail_screen.dart';
import '../../features/submit/screens/submissions_list_screen.dart';
import '../../features/submit/screens/submit_tab_screen.dart';
import '../../features/verification/screens/verification_screen.dart';
import '../../features/wallet/screens/wallet_tab_screen.dart';
import '../../features/wallet/screens/withdraw_screen.dart';

class Routes {
  static const String initialRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgotPassword';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';
  static const String exploreRoute = '/explore';
  static const String submitRoute = '/submit';
  static const String walletRoute = '/wallet';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';
  static const String missionDetailRoute = '/missionDetail';
  static const String taskDetailRoute = '/taskDetail';
  static const String submissionsRoute = '/submissions';
  static const String submissionDetailRoute = '/submissionDetail';
  static const String verificationRoute = '/verification';
  static const String withdrawRoute = '/withdraw';
}

class AppRoutes {
  static String route = '';

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );

      case Routes.onboardingRoute:
        return PageTransition(
          child: const OnboardingScreen(),
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 400),
        );

      case Routes.loginRoute:
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 500),
        );

      case Routes.registerRoute:
        return PageTransition(
          child: const RegisterScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 400),
        );

      case Routes.forgotPasswordRoute:
        return PageTransition(
          child: const ForgotPasswordScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 400),
        );

      case Routes.mainRoute:
        return PageTransition(
          child: const ImpactShellScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 500),
        );

      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeTabScreen());

      case Routes.exploreRoute:
        return MaterialPageRoute(builder: (_) => const ExploreTabScreen());

      case Routes.submitRoute:
        return MaterialPageRoute(
          builder: (_) => SubmitTabScreen(
            initialTaskId: settings.arguments as String?,
          ),
        );

      case Routes.walletRoute:
        return MaterialPageRoute(builder: (_) => const WalletTabScreen());

      case Routes.profileRoute:
        return MaterialPageRoute(
          builder: (ctx) => ProfileTabScreen(
            onLocaleChanged: () {},
          ),
        );

      case Routes.notificationsRoute:
        return PageTransition(
          child: const NotificationsScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.missionDetailRoute:
        return PageTransition(
          child: MissionDetailScreen(
            missionId: (settings.arguments as String?) ?? 'm1',
          ),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.taskDetailRoute:
        return PageTransition(
          child: TaskDetailScreen(
            taskId: (settings.arguments as String?) ?? 't-m1-0',
          ),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.submissionsRoute:
        return PageTransition(
          child: const SubmissionsListScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.submissionDetailRoute:
        return PageTransition(
          child: SubmissionDetailScreen(
            submissionId: (settings.arguments as String?) ?? 's1',
          ),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.verificationRoute:
        return PageTransition(
          child: const VerificationScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

      case Routes.withdrawRoute:
        return PageTransition(
          child: WithdrawScreen(
            availableBalance: (settings.arguments as int?) ?? 0,
          ),
          type: PageTransitionType.bottomToTop,
          duration: const Duration(milliseconds: 350),
        );

      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text(AppStrings.noRouteFound),
        ),
      ),
    );
  }
}
