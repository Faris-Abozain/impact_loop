import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/preferences/preferences.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';

import 'package:impact_loop/core/models/wallet_models.dart';
import 'package:impact_loop/features/auth/data/wallet_repository.dart';
import 'package:impact_loop/core/utils/restart_app_class.dart';
import 'package:impact_loop/injector.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key, required this.onLocaleChanged});

  final VoidCallback onLocaleChanged;

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  ImpactSummary? _impact;

  @override
  void initState() {
    super.initState();
    _loadImpact();
  }

  void _loadImpact() async {
    final res = await serviceLocator<WalletRepository>().getImpact();
    res.fold((_) {}, (impact) {
      if (mounted) setState(() => _impact = impact);
    });
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final name = user?.name ?? 'Eco Hero';
        final email = user?.email ?? user?.phone ?? 'hero@impactloop.app';
        final isVerified = user?.verifiedStatus == VerifiedStatus.verified;
        final isPending = user?.verifiedStatus == VerifiedStatus.pending;

        return Scaffold(
          appBar: AppBar(
            title: Text('profile_title'.tr()),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.notificationsRoute),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // User Card
              AppCard(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: AppColors.secondPrimary,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Gap(14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Gap(6.w),
                              if (isVerified)
                                Icon(Icons.verified,
                                    color: AppColors.primary, size: 18.sp)
                              else if (isPending)
                                Icon(Icons.hourglass_top_rounded,
                                    color: AppColors.warning, size: 18.sp),
                            ],
                          ),
                          Gap(4.h),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Gap(6.h),
                          Pill(
                            label: isVerified
                                ? 'verification_verified'.tr()
                                : isPending
                                    ? 'verification_pending'.tr()
                                    : 'verify_id'.tr(),
                            color: isVerified
                                ? AppColors.success
                                : isPending
                                    ? AppColors.warning
                                    : AppColors.primary,
                            icon: isVerified
                                ? Icons.verified_user
                                : Icons.security,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16.h),

              // KYC Banner if not verified
              if (!isVerified) ...[
                Pressable(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.verificationRoute),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isPending
                            ? AppColors.warning.withValues(alpha: 0.5)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconBadge(
                          icon: isPending
                              ? Icons.hourglass_empty_rounded
                              : Icons.fingerprint_rounded,
                          color: isPending ? AppColors.warning : AppColors.primary,
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPending
                                    ? 'verification_pending'.tr()
                                    : 'verify_id'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Gap(2.h),
                              Text(
                                isPending
                                    ? 'kyc_review_hint'.tr()
                                    : 'kyc_verify_hint'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                Gap(16.h),
              ],

              // Badges & Rank
              SectionHeader(title: 'total_impact'.tr()),
              Builder(
                builder: (context) {
                  final completedCount = _impact?.approvedSubmissions ?? 0;
                  final points = _impact?.pointsEarned ?? 0;
                  final level = points >= 1000
                      ? 5
                      : points >= 600
                          ? 4
                          : points >= 300
                              ? 3
                              : points >= 100
                                  ? 2
                                  : 1;
                  final levelText = context.locale.languageCode == 'ar'
                      ? 'المستوى $level'
                      : 'Level $level';

                  return Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          icon: Icons.emoji_events_rounded,
                          value: levelText,
                          label: 'rank'.tr(),
                          color: AppColors.warning,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: StatTile(
                          icon: Icons.task_alt_rounded,
                          value: '$completedCount',
                          label: 'completed_tasks'.tr(),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),

              Gap(20.h),

              // Settings Section
              SectionHeader(title: 'settings'.tr()),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.language_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                      title: Text('language'.tr()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.locale.languageCode == 'ar'
                                ? 'العربية'
                                : 'English',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                          Gap(6.w),
                          const AppAdaptiveArrow(),
                        ],
                      ),
                      onTap: () => _showLanguageSheet(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.verified_user_outlined,
                        color: AppColors.accent,
                        size: 36,
                      ),
                      title: Text('verification_title'.tr()),
                      trailing: const AppAdaptiveArrow(),
                      onTap: () => Navigator.pushNamed(
                          context, Routes.verificationRoute),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.notifications_none_rounded,
                        color: AppColors.info,
                        size: 36,
                      ),
                      title: Text('notifications_title'.tr()),
                      trailing: const AppAdaptiveArrow(),
                      onTap: () => Navigator.pushNamed(
                          context, Routes.notificationsRoute),
                    ),
                  ],
                ),
              ),
              Gap(16.h),

              // Support & Policies
              SectionHeader(title: 'help_support'.tr()),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.help_outline_rounded,
                        color: AppColors.violet,
                        size: 36,
                      ),
                      title: Text('faq'.tr()),
                      trailing: const AppAdaptiveArrow(),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.privacy_tip_outlined,
                        color: AppColors.textSecondary,
                        size: 36,
                      ),
                      title: Text('privacy_policy'.tr()),
                      trailing: const AppAdaptiveArrow(),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: IconBadge(
                        icon: Icons.description_outlined,
                        color: AppColors.textSecondary,
                        size: 36,
                      ),
                      title: Text('terms_service'.tr()),
                      trailing: const AppAdaptiveArrow(),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Gap(24.h),

              // Logout Button
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  'logout'.tr(),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: () async {
                  await context.read<AuthCubit>().logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.loginRoute,
                    (_) => false,
                  );
                },
              ),
              Gap(20.h),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final current = context.locale.languageCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                Gap(18.h),
                Text(
                  'choose'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Gap(16.h),
                _LanguageOptionTile(
                  title: 'العربية (Arabic)',
                  isSelected: current == 'ar',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await context.setLocale(const Locale('ar'));
                    await Preferences.instance.savedLang('ar');
                    widget.onLocaleChanged();
                    if (context.mounted) {
                      HotRestartController.performHotRestart(context);
                    }
                  },
                ),
                Gap(10.h),
                _LanguageOptionTile(
                  title: 'English (الإنجليزية)',
                  isSelected: current == 'en',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await context.setLocale(const Locale('en'));
                    await Preferences.instance.savedLang('en');
                    widget.onLocaleChanged();
                    if (context.mounted) {
                      HotRestartController.performHotRestart(context);
                    }
                  },
                ),

                Gap(12.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondPrimary.withValues(alpha: 0.35)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language_rounded,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20.sp,
            ),
            Gap(12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class AppAdaptiveArrow extends StatelessWidget {
  const AppAdaptiveArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    return Icon(
      isRtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
      size: 14.sp,
      color: AppColors.textSecondary,
    );
  }
}


