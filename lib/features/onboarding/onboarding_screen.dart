import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/preferences/preferences.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  late final _pages = [
    _OnbData(
      icon: Icons.travel_explore_rounded,
      secondary: Icons.place_rounded,
      title: 'onb1_title',
      body: 'onb1_body',
      color: AppColors.primary,
    ),
    _OnbData(
      icon: Icons.photo_camera_rounded,
      secondary: Icons.verified_rounded,
      title: 'onb2_title',
      body: 'onb2_body',
      color: AppColors.info,
    ),
    _OnbData(
      icon: Icons.account_balance_wallet_rounded,
      secondary: Icons.stars_rounded,
      title: 'onb3_title',
      body: 'onb3_body',
      color: AppColors.violet,
    ),
  ];

  Future<void> _finish() async {
    await Preferences.instance.setOnboardingDone();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.loginRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    _LangToggle(onChanged: () => setState(() {})),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: isLast ? null : _finish,
                        child: Text('skip'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _OnbPage(data: _pages[i]),
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.border,
                  dotHeight: 8.h,
                  dotWidth: 8.h,
                  expansionFactor: 4,
                ),
              ),
              Gap(28.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GradientButton(
                  label: isLast ? 'get_started'.tr() : 'next'.tr(),
                  icon: isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
              ),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnbData {
  final IconData icon;
  final IconData secondary;
  final String title;
  final String body;
  final Color color;

  _OnbData({
    required this.icon,
    required this.secondary,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _OnbPage extends StatelessWidget {
  const _OnbPage({required this.data});

  final _OnbData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            child: SizedBox(
              width: 250.w,
              height: 250.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250.w,
                    height: 250.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.color.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 180.w,
                    height: 180.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.color.withValues(alpha: 0.14),
                    ),
                  ),
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [data.color.withValues(alpha: 0.8), data.color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 56.sp),
                  ),
                  PositionedDirectional(
                    top: 28.h,
                    end: 30.w,
                    child: _FloatingChip(icon: data.secondary, color: data.color),
                  ),
                  PositionedDirectional(
                    bottom: 34.h,
                    start: 22.w,
                    child: _FloatingChip(icon: Icons.eco_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          Gap(36.h),
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: Text(
              data.title.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
          Gap(12.h),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: Text(
              data.body.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5.sp,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatefulWidget {
  const _FloatingChip({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_FloatingChip> createState() => _FloatingChipState();
}

class _FloatingChipState extends State<_FloatingChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -6 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: AppColors.softShadow,
        ),
        child: Icon(widget.icon, color: widget.color, size: 22.sp),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    return Pressable(
      onTap: () async {
        final newLang = isAr ? 'en' : 'ar';
        await context.setLocale(Locale(newLang));
        await Preferences.instance.savedLang(newLang);
        onChanged();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 16.sp, color: AppColors.primary),
            Gap(6.w),
            Text(
              isAr ? 'English' : 'العربية',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
