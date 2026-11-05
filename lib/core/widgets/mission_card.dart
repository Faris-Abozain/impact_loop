import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
    this.compact = false,
  });

  final MissionSummary mission;
  final VoidCallback? onTap;

  /// Compact variant used in horizontal carousels.
  final bool compact;

  String get _type =>
      mission.taskTypes.isNotEmpty ? mission.taskTypes.first : 'DUMPING_REPORT';

  @override
  Widget build(BuildContext context) {
    final color = TaskTypeStyle.color(_type);
    final rewardText = mission.maxRewardPoints != null &&
            mission.minRewardPoints != null &&
            mission.minRewardPoints != mission.maxRewardPoints
        ? '${mission.minRewardPoints}–${mission.maxRewardPoints}'
        : '${mission.maxRewardPoints ?? mission.minRewardPoints ?? 0}';
    final daysLeft = mission.endAt.difference(DateTime.now()).inDays;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual header
          Container(
            height: compact ? 92.h : 104.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.9),
                  color.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  end: -14.w,
                  bottom: -18.h,
                  child: Icon(
                    TaskTypeStyle.icon(_type),
                    size: 110.sp,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlassCard(
                            radius: 30,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            opacity: 0.22,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  TaskTypeStyle.icon(_type),
                                  size: 13.sp,
                                  color: Colors.white,
                                ),
                                Gap(4.w),
                                Text(
                                  TaskTypeStyle.label(_type),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (mission.distanceMeters != null)
                            Pill(
                              label:
                                  '${(mission.distanceMeters! / 1000).toStringAsFixed(1)} ${'km'.tr()}',
                              icon: Icons.near_me_rounded,
                              color: Colors.white,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.stars_rounded,
                              color: AppColors.gold, size: 18.sp),
                          Gap(4.w),
                          Text(
                            '$rewardText ${'pts'.tr()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.localizedTitle(context.locale.languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!compact && mission.description != null) ...[
                  Gap(4.h),
                  Text(
                    mission.localizedDescription(context.locale.languageCode)!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                Gap(10.h),
                Row(
                  children: [
                    Icon(Icons.task_alt_rounded,
                        size: 14.sp, color: AppColors.primary),
                    Gap(4.w),
                    Flexible(
                      child: Text(
                        'tasks_available'.tr(namedArgs: {
                          'count': '${mission.availableTasks}',
                        }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.schedule_rounded,
                        size: 14.sp, color: AppColors.textMuted),
                    Gap(3.w),
                    Text(
                      'days_left'.tr(namedArgs: {'days': '$daysLeft'}),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
