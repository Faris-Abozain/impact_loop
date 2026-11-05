import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/mission_card.dart';
import 'package:impact_loop/core/widgets/submission_status_chip.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/home/cubit/home_cubit.dart';
import 'package:impact_loop/injector.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<HomeCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, color: AppColors.primary, size: 20.sp),
              ),
              Gap(8.w),
              Text(
                'home_title'.tr(),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.notificationsRoute),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: ErrorState(
                    message: state.message,
                    onRetry: () => context.read<HomeCubit>().load(),
                  ),
                ),
              );
            }
            if (state is! HomeLoaded) return const SizedBox.shrink();

            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().load(),
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Hero Stats Card
                  AppCard(
                    padding: EdgeInsets.all(20.w),
                    gradient: AppColors.heroGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'continue_impact'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.bolt,
                                      color: AppColors.gold, size: 14.sp),
                                  Gap(4.w),
                                  Text(
                                    'active_hero'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Gap(12.h),
                        Text(
                          '${state.impact.pointsEarned} ${'pts'.tr()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'points_earned'.tr(namedArgs: {
                            'points': '${state.impact.pointsEarned}',
                          }),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13.sp,
                          ),
                        ),
                        Gap(16.h),
                        Row(
                          children: [
                            _miniStat(
                              icon: Icons.check_circle_outline,
                              value: '${state.impact.approvedSubmissions}',
                              label: 'status_approved'.tr(),
                            ),
                            Gap(16.w),
                            _miniStat(
                              icon: Icons.assignment_outlined,
                              value: '${state.impact.totalSubmissions}',
                              label: 'total_label'.tr(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Gap(20.h),

                  // Quick Action Shortcuts
                  Row(
                    children: [
                      Expanded(
                        child: _quickAction(
                          context: context,
                          icon: Icons.explore_rounded,
                          label: 'tab_explore'.tr(),
                          color: AppColors.primary,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.exploreRoute),
                        ),
                      ),
                      Gap(10.w),
                      Expanded(
                        child: _quickAction(
                          context: context,
                          icon: Icons.camera_alt_rounded,
                          label: 'tab_submit'.tr(),
                          color: AppColors.accent,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.submitRoute),
                        ),
                      ),
                      Gap(10.w),
                      Expanded(
                        child: _quickAction(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'tab_wallet'.tr(),
                          color: AppColors.violet,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.walletRoute),
                        ),
                      ),
                    ],
                  ),
                  Gap(24.h),

                  // Recommended Missions
                  SectionHeader(
                    title: 'recommended_missions'.tr(),
                    actionLabel: 'all'.tr(),
                    onAction: () =>
                        Navigator.pushNamed(context, Routes.exploreRoute),
                  ),
                  ...state.recommended.map(
                    (m) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: MissionCard(
                        mission: m,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.missionDetailRoute,
                          arguments: m.id,
                        ),
                      ),
                    ),
                  ),
                  Gap(12.h),

                  // Pending Submissions
                  SectionHeader(title: 'pending_submissions'.tr()),
                  if (state.pendingSubmissions.isEmpty)
                    AppCard(
                      padding: EdgeInsets.all(16.w),
                      child: Center(
                        child: Text(
                          'no_pending_submissions'.tr(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.pendingSubmissions.map(
                      (s) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: AppCard(
                          onTap: () => Navigator.pushNamed(
                            context,
                            Routes.submissionDetailRoute,
                            arguments: s.id,
                          ),
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              IconBadge(
                                icon: Icons.pending_actions_rounded,
                                color: AppColors.warning,
                                size: 38,
                              ),
                              Gap(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'task_label'.tr()}: ${s.taskId}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(s.createdAt),
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SubmissionStatusChip(status: s.status),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Gap(12.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16.sp),
        Gap(6.w),
        Text(
          '$value $label',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      child: Column(
        children: [
          IconBadge(icon: icon, color: color, size: 38),
          Gap(8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
