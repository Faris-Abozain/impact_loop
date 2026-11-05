import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/missions_repository.dart';
import 'package:impact_loop/injector.dart';

class MissionDetailScreen extends StatefulWidget {
  const MissionDetailScreen({super.key, required this.missionId});

  final String missionId;

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  bool _loading = true;
  String? _error;
  MissionSummary? _mission;
  List<MissionTaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final missionsRepo = serviceLocator<MissionsRepository>();
    final missionRes = await missionsRepo.getMission(widget.missionId);
    final tasksRes = await missionsRepo.listMissionTasks(widget.missionId);

    missionRes.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (m) {
        tasksRes.fold(
          (l) => setState(() {
            _loading = false;
            _error = l.message;
          }),
          (tasks) => setState(() {
            _loading = false;
            _mission = m;
            _tasks = tasks;
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mission_details'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              showAppSnack(context, 'link_copied'.tr());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _mission == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: EdgeInsets.all(16.w),
                        children: [
                          // Header Card
                          AppCard(
                            padding: EdgeInsets.all(18.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Pill(
                                      label: TaskTypeStyle.label(
                                        _mission!.taskTypes.isNotEmpty
                                            ? _mission!.taskTypes.first
                                            : 'DUMPING_REPORT',
                                      ),
                                      icon: TaskTypeStyle.icon(
                                        _mission!.taskTypes.isNotEmpty
                                            ? _mission!.taskTypes.first
                                            : 'DUMPING_REPORT',
                                      ),
                                      color: TaskTypeStyle.color(
                                        _mission!.taskTypes.isNotEmpty
                                            ? _mission!.taskTypes.first
                                            : 'DUMPING_REPORT',
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.stars_rounded,
                                        color: AppColors.warning, size: 20.sp),
                                    Gap(4.w),
                                    Text(
                                      '${_mission!.maxRewardPoints ?? _mission!.minRewardPoints ?? 0} ${'points'.tr()}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(12.h),
                                Text(
                                  _mission!.localizedTitle(context.locale.languageCode),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_mission!.description != null) ...[
                                  Gap(8.h),
                                  Text(
                                    _mission!.localizedDescription(context.locale.languageCode)!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                Gap(14.h),
                                Row(
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 16.sp,
                                        color: AppColors.textSecondary),
                                    Gap(6.w),
                                    Text(
                                      '${DateFormat.yMMMd().format(_mission!.startAt)} - ${DateFormat.yMMMd().format(_mission!.endAt)}',
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Gap(20.h),

                          // Tasks Section
                          SectionHeader(
                            title: 'tasks_available'.tr(namedArgs: {
                              'count': '${_tasks.length}',
                            }),
                          ),
                          ..._tasks.map((task) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: AppCard(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  Routes.taskDetailRoute,
                                  arguments: task.id,
                                ),
                                padding: EdgeInsets.all(14.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconBadge(
                                          icon: TaskTypeStyle.icon(task.type),
                                          color: TaskTypeStyle.color(task.type),
                                          size: 38,
                                        ),
                                        Gap(12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.localizedTitle(context.locale.languageCode),
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Gap(2.h),
                                              Text(
                                                '${task.rewardPoints} ${'points'.tr()}',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right,
                                            color: AppColors.textSecondary),
                                      ],
                                    ),
                                    Gap(8.h),
                                    Text(
                                      task.localizedInstructions(context.locale.languageCode),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Gap(8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 14.sp,
                                            color: AppColors.textMuted),
                                        Gap(4.w),
                                        Text(
                                          '${'radius_label'.tr()}: ${task.radiusMeters} ${'meter'.tr()}',
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        const Spacer(),
                                        Pill(
                                          label: task.status == 'OPEN'
                                              ? 'status_open'.tr()
                                              : (task.status == 'RESERVED'
                                                  ? 'status_reserved'.tr()
                                                  : task.status),
                                          color: task.status == 'OPEN'
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }
}
