import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/models/submission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/submission_status_chip.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/submissions_repository.dart';
import 'package:impact_loop/injector.dart';

class SubmissionDetailScreen extends StatefulWidget {
  const SubmissionDetailScreen({super.key, required this.submissionId});

  final String submissionId;

  @override
  State<SubmissionDetailScreen> createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  bool _loading = true;
  String? _error;
  SubmissionDetail? _submission;

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
    final result = await serviceLocator<SubmissionsRepository>()
        .getSubmission(widget.submissionId);
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (s) => setState(() {
        _loading = false;
        _submission = s;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('submission_details'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _submission == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status Overview Card
                          AppCard(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${'task_label'.tr()}: ${_submission!.taskId}',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SubmissionStatusChip(
                                        status: _submission!.status),
                                  ],
                                ),
                                Gap(10.h),
                                Text(
                                  '${'submitted_at'.tr()}: ${DateFormat.yMMMd().add_jm().format(_submission!.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(16.h),

                          // Reviewer feedback if needsInfo or rejected
                          if (_submission!.status == SubmissionStatus.needsInfo ||
                              _submission!.status == SubmissionStatus.rejected ||
                              _submission!.reasonCodes.isNotEmpty) ...[
                            SectionHeader(title: 'reviewer_notes'.tr()),
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.warning.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.feedback_outlined,
                                      color: AppColors.warning, size: 22.sp),
                                  Gap(10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'action_required'.tr(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        Gap(4.h),
                                        Text(
                                          _submission!.reasonCodes.isNotEmpty
                                              ? '${'reason'.tr()}: ${_submission!.reasonCodes.join(', ')}'
                                              : 'default_reviewer_hint'.tr(),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(16.h),
                          ],

                          // Notes
                          if (_submission!.note != null &&
                              _submission!.note!.isNotEmpty) ...[
                            SectionHeader(title: 'add_notes'.tr()),
                            AppCard(
                              padding: EdgeInsets.all(14.w),
                              child: Text(
                                _submission!.note!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Gap(16.h),
                          ],

                          // Location coordinates
                          if (_submission!.location != null) ...[
                            SectionHeader(title: 'location'.tr()),
                            AppCard(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                children: [
                                  const Icon(Icons.pin_drop,
                                      color: Colors.redAccent),
                                  Gap(8.w),
                                  Text(
                                    '${'lat'.tr()}: ${_submission!.location!.lat.toStringAsFixed(4)}, ${'lng'.tr()}: ${_submission!.location!.lng.toStringAsFixed(4)}',
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ],
                              ),
                            ),
                            Gap(16.h),
                          ],

                          // Evidence list
                          SectionHeader(title: 'evidence'.tr()),
                          if (_submission!.evidence.isEmpty)
                            Text('no_data'.tr())
                          else
                            ..._submission!.evidence.map((ev) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: AppCard(
                                  padding: EdgeInsets.all(12.w),
                                  child: Row(
                                    children: [
                                      IconBadge(
                                        icon: Icons.image_outlined,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                                      Gap(12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${'file_id'.tr()}: ${ev.id}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.5.sp,
                                              ),
                                            ),
                                            Text(
                                              ev.mimeType,
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
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
