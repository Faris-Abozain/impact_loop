import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/submission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/submission_status_chip.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/submissions_repository.dart';
import 'package:impact_loop/injector.dart';

class SubmissionsListScreen extends StatefulWidget {
  const SubmissionsListScreen({super.key});

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  bool _loading = true;
  String? _error;
  List<MySubmissionItem> _submissions = [];

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
    final result =
        await serviceLocator<SubmissionsRepository>().listMySubmissions();
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (items) => setState(() {
        _loading = false;
        _submissions = items;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pending_submissions'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _submissions.isEmpty
                  ? EmptyState(
                      icon: Icons.task_rounded,
                      title: 'no_pending_submissions'.tr(),
                      actionLabel: 'start_mission'.tr(),
                      onAction: () =>
                          Navigator.pushNamed(context, Routes.exploreRoute),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _submissions.length,
                        separatorBuilder: (_, __) => Gap(12.h),
                        itemBuilder: (context, index) {
                          final item = _submissions[index];
                          return AppCard(
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.submissionDetailRoute,
                              arguments: item.id,
                            ),
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              children: [
                                IconBadge(
                                  icon: Icons.fact_check_outlined,
                                  color: AppColors.primary,
                                  size: 42,
                                ),
                                Gap(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${'task_label'.tr()}: ${item.taskId}',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Gap(4.h),
                                      Text(
                                        DateFormat.yMMMd()
                                            .add_jm()
                                            .format(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SubmissionStatusChip(status: item.status),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
