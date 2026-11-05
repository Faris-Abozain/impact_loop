import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/preferences/preferences.dart';
import 'package:impact_loop/core/utils/assets_manager.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';
import 'package:impact_loop/injector.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final Animation<double> _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
    CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ),
  );

  late final Animation<double> _contentSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
    CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
    ),
  );

  late final Animation<double> _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
    ),
  );

  late final Animation<double> _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ),
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AppConfig.autoDetectHost();
    _timer = Timer(const Duration(milliseconds: 2600), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final onboardingDone = prefs.getBool(Preferences.onboardingKey) ?? false;
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, Routes.onboardingRoute);
      return;
    }
    final auth = serviceLocator<AuthCubit>();
    await auth.restoreSession();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      auth.state is AuthAuthenticated ? Routes.mainRoute : Routes.loginRoute,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041812),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Aurora Gradients
          Positioned(
            top: -60.h,
            right: -40.w,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 280.w,
                height: 280.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.28 + _pulseController.value * 0.1),
                      const Color(0xFF059669).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -60.w,
            top: 220.h,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.22 + (1 - _pulseController.value) * 0.08),
                      const Color(0xFF6D28D9).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: 40.w,
            right: 40.w,
            child: Container(
              height: 240.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF065F46).withValues(alpha: 0.35),
                    const Color(0xFF041812).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Subtle background grid/glow mesh
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating illuminated Logo Card
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulse = _pulseController.value;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25 + pulse * 0.18),
                            blurRadius: 50 + pulse * 20,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.20 + (1 - pulse) * 0.15),
                            blurRadius: 60,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          width: 110.w,
                          height: 110.w,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 35,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22.r),
                            child: Image.asset(
                              ImageAssets.logoImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(28.h),

                // Brand Title & Tagline
                AnimatedBuilder(
                  animation: _entryController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _contentSlide.value),
                      child: Opacity(
                        opacity: _contentFade.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFF34D399).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Gap(8.w),
                            Text(
                              context.locale.languageCode == 'ar'
                                  ? 'منصة الأثر البيئي المستدام'
                                  : 'Eco-Action Platform',
                              style: TextStyle(
                                color: const Color(0xFF6EE7B7),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(12.h),

                      // App Name
                      Text(
                        'Impact Loop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      Gap(8.h),

                      // Tagline
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36.w),
                        child: Text(
                          'splash_tagline'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom sleek progress indicator and footer
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _footerFade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Elegant glowing mini progress pill
                  Container(
                    width: 52.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.4 + _pulseController.value * 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF34D399), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF34D399).withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Gap(14.h),
                  Text(
                    context.locale.languageCode == 'ar'
                        ? 'مستقبل أخضر ومستدام • الإصدار 1.0'
                        : 'Sustainable Future • Version 1.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
