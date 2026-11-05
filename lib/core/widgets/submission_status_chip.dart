import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/utils/app_colors.dart';

class SubmissionStatusChip extends StatelessWidget {
  const SubmissionStatusChip({super.key, required this.status});

  final SubmissionStatus status;

  Color get _color {
    switch (status) {
      case SubmissionStatus.approved:
        return AppColors.success;
      case SubmissionStatus.rejected:
        return AppColors.error;
      case SubmissionStatus.needsInfo:
        return AppColors.warning;
      case SubmissionStatus.draft:
        return AppColors.gray;
      default:
        return AppColors.primary;
    }
  }

  String get _label {
    switch (status) {
      case SubmissionStatus.draft:
        return 'status_draft'.tr();
      case SubmissionStatus.pending:
      case SubmissionStatus.pendingReview:
        return 'status_pending'.tr();
      case SubmissionStatus.needsInfo:
        return 'status_needs_info'.tr();
      case SubmissionStatus.approved:
        return 'status_approved'.tr();
      case SubmissionStatus.rejected:
        return 'status_rejected'.tr();
      case SubmissionStatus.flagged:
        return 'status_flagged'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
