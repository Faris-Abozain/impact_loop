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

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _loading = true;
  String? _error;
  TaskDetail? _task;
  bool _reserved = false;

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
    final result = await serviceLocator<MissionsRepository>().getTask(widget.taskId);
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (task) => setState(() {
        _loading = false;
        _task = task;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('active_task'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _task == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card
                          AppCard(
                            padding: EdgeInsets.all(18.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconBadge(
                                      icon: TaskTypeStyle.icon(_task!.type),
                                      color: TaskTypeStyle.color(_task!.type),
                                      size: 46,
                                    ),
                                    Gap(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _task!.localizedTitle(context.locale.languageCode),
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(4.h),
                                          Pill(
                                            label: TaskTypeStyle.label(_task!.type),
                                            color: TaskTypeStyle.color(_task!.type),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Icon(Icons.stars_rounded,
                                            color: AppColors.warning,
                                            size: 24.sp),
                                        Text(
                                          '${_task!.rewardPoints} ${'pts'.tr()}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Gap(16.h),

                          // Instructions
                          SectionHeader(title: 'instructions'.tr()),
                          AppCard(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              _task!.localizedInstructions(context.locale.languageCode),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ),
                          Gap(16.h),

                          // Location Info
                          SectionHeader(title: 'location'.tr()),
                          AppCard(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pin_drop,
                                        color: Colors.redAccent),
                                    Gap(8.w),
                                    Expanded(
                                      child: Text(
                                        '${'lat'.tr()}: ${_task!.location.lat.toStringAsFixed(4)}, ${'lng'.tr()}: ${_task!.location.lng.toStringAsFixed(4)}',
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(10.h),
                                Row(
                                  children: [
                                    const Icon(Icons.radar,
                                        color: Colors.blueAccent),
                                    Gap(8.w),
                                    Text(
                                      '${'radius_label'.tr()}: ${_task!.radiusMeters} ${'meter'.tr()}',
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Gap(28.h),

                          // Action Buttons
                          if (!_reserved) ...[
                            GradientButton(
                              label: 'reserve_task'.tr(),
                              icon: Icons.bookmark_add_rounded,
                              onPressed: () async {
                                final repo = serviceLocator<MissionsRepository>();
                                final res = await repo.reserveTask(_task!.id);
                                if (!mounted) return;
                                res.fold(
                                  (failure) => showAppSnack(context, failure.message, error: true),
                                  (_) {
                                    setState(() => _reserved = true);
                                    showAppSnack(context, 'task_reserved'.tr());
                                  },
                                );
                              },
                            ),
                            Gap(12.h),
                          ],

                          FilledButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.submitRoute,
                                arguments: _task!.id,
                              );
                            },
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: Text('submit_title'.tr()),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
