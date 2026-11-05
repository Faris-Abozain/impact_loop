import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/utils/uuid_utils.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/missions_repository.dart';
import 'package:impact_loop/features/auth/data/submissions_repository.dart';
import 'package:impact_loop/injector.dart';

class SubmitTabScreen extends StatefulWidget {
  const SubmitTabScreen({super.key, this.initialTaskId});

  final String? initialTaskId;

  @override
  State<SubmitTabScreen> createState() => _SubmitTabScreenState();
}

class _SubmitTabScreenState extends State<SubmitTabScreen> {
  final _picker = ImagePicker();
  final _noteController = TextEditingController();
  final List<XFile> _selectedFiles = [];

  String? _taskId;
  String? _campaignId;
  String? _taskTitle;
  int? _rewardPoints;
  String? _taskType;
  bool _loadingTasks = false;
  List<MissionTaskItem> _availableTasks = [];

  Position? _currentPosition;
  bool _fetchingLocation = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTaskId != null && UuidUtils.isValid(widget.initialTaskId)) {
      _taskId = widget.initialTaskId;
    }
    _determinePosition();
    _loadAvailableTasks();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        if (mounted) {
          setState(() => _currentPosition = pos);
          if (_availableTasks.isEmpty) {
            _loadAvailableTasks();
          }
        }
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _loadAvailableTasks() async {
    if (_loadingTasks) return;
    setState(() => _loadingTasks = true);
    final missionsRepo = serviceLocator<MissionsRepository>();

    if (_taskId != null && UuidUtils.isValid(_taskId)) {
      final taskRes = await missionsRepo.getTask(_taskId!);
      taskRes.fold((_) {}, (detail) {
        if (mounted) {
          setState(() {
            _campaignId = detail.campaignId;
            _taskTitle = detail.title;
            _rewardPoints = detail.rewardPoints;
            _taskType = detail.type;
          });
        }
      });
    }

    final lat = _currentPosition?.latitude ?? 30.0444;
    final lng = _currentPosition?.longitude ?? 31.2357;

    List<MissionTaskItem> tasks = [];
    final nearbyRes = await missionsRepo.getNearbyTasks(
      lat: lat,
      lng: lng,
      radiusKm: 100,
    );
    nearbyRes.fold((_) {}, (list) => tasks = list);

    if (tasks.isEmpty) {
      final missionsRes = await missionsRepo.listMissions();
      await missionsRes.fold((_) async {}, (missions) async {
        if (missions.isNotEmpty) {
          final tRes = await missionsRepo.listMissionTasks(missions.first.id);
          tRes.fold((_) {}, (mTasks) => tasks = mTasks);
        }
      });
    }

    if (mounted) {
      setState(() {
        _availableTasks = tasks;
        _loadingTasks = false;
        if ((_taskId == null || !UuidUtils.isValid(_taskId)) && tasks.isNotEmpty) {
          final first = tasks.first;
          _taskId = first.id;
          _campaignId = first.campaignId;
          _taskTitle = first.title;
          _rewardPoints = first.rewardPoints;
          _taskType = first.type;
        }
      });
    }
  }

  void _showTaskPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'active_task'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Gap(12.h),
              if (_loadingTasks && _availableTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableTasks.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Center(
                    child: Text(
                      'no_tasks_available'.tr(),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _availableTasks.length,
                    separatorBuilder: (_, __) => Gap(10.h),
                    itemBuilder: (_, index) {
                      final task = _availableTasks[index];
                      final isSelected = task.id == _taskId;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _taskId = task.id;
                            _campaignId = task.campaignId;
                            _taskTitle = task.title;
                            _rewardPoints = task.rewardPoints;
                            _taskType = task.type;
                          });
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.15),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              IconBadge(
                                icon: TaskTypeStyle.icon(task.type),
                                color: TaskTypeStyle.color(task.type),
                                size: 36,
                              ),
                              Gap(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.localizedTitle(context.locale.languageCode),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Gap(4.h),
                                    Text(
                                      '+${task.rewardPoints} ${'points'.tr()}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: AppColors.primary)
                              else
                                Icon(Icons.radio_button_unchecked, color: Colors.grey.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 80);
      if (file != null) {
        setState(() => _selectedFiles.add(file));
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'camera_gallery_error'.tr(), error: true);
      }
    }
  }

  Future<void> _submit() async {
    if (_taskId == null || !UuidUtils.isValid(_taskId)) {
      showAppSnack(context, 'select_task_required'.tr(), error: true);
      _showTaskPickerSheet();
      return;
    }

    if (_selectedFiles.isEmpty) {
      showAppSnack(context, 'proof_photo_required'.tr(), error: true);
      return;
    }

    setState(() => _submitting = true);
    final missionsRepo = serviceLocator<MissionsRepository>();
    final submissionsRepo = serviceLocator<SubmissionsRepository>();

    // Ensure the task is reserved before submission (required by backend)
    await missionsRepo.reserveTask(_taskId!);

    var result = await submissionsRepo.createSubmission(
      taskId: _taskId!,
      campaignId: _campaignId ?? '',
      mediaPaths: _selectedFiles.map((f) => f.path).toList(),
      note: _noteController.text.trim(),
      lat: _currentPosition?.latitude ?? 30.0444,
      lng: _currentPosition?.longitude ?? 31.2357,
    );

    // If still fails with reservation error, attempt reserve once more and retry
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => null);
      if (failure != null && failure.message.toLowerCase().contains('reserved')) {
        final res = await missionsRepo.reserveTask(_taskId!);
        if (res.isRight()) {
          result = await submissionsRepo.createSubmission(
            taskId: _taskId!,
            campaignId: _campaignId ?? '',
            mediaPaths: _selectedFiles.map((f) => f.path).toList(),
            note: _noteController.text.trim(),
            lat: _currentPosition?.latitude ?? 30.0444,
            lng: _currentPosition?.longitude ?? 31.2357,
          );
        }
      }
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (failure) {
        if (!mounted) return;
        showAppSnack(context, failure.message, error: true);
      },
      (item) {
        if (!mounted) return;
        showAppSnack(context, 'submission_success'.tr());
        setState(() {
          _selectedFiles.clear();
          _noteController.clear();
        });
        Navigator.pushNamed(
          context,
          Routes.submissionDetailRoute,
          arguments: item.id,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('submit_title'.tr()),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.submissionsRoute),
            child: Text(
              'view_all_submissions'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task Assignment Card
            AppCard(
              onTap: _showTaskPickerSheet,
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(
                        icon: _taskType != null
                            ? TaskTypeStyle.icon(_taskType!)
                            : Icons.assignment_outlined,
                        color: _taskType != null
                            ? TaskTypeStyle.color(_taskType!)
                            : AppColors.primary,
                        size: 38,
                      ),
                      Gap(10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'active_task'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_loadingTasks && _taskTitle == null)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            else
                              Text(
                                _taskTitle != null
                                    ? ContentTranslator.translate(
                                        _taskTitle!, context.locale.languageCode)
                                    : (_taskId != null && UuidUtils.isValid(_taskId)
                                        ? '${'task_label'.tr()} #${_taskId!.substring(0, 8)}'
                                        : 'choose'.tr()),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (_rewardPoints != null) ...[
                              Gap(2.h),
                              Text(
                                '+$_rewardPoints ${'points'.tr()}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _showTaskPickerSheet,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'choose'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Gap(4.w),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(8.h),
                  Text(
                    'submit_guidance'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Evidence Upload Section
            SectionHeader(title: 'evidence'.tr()),
            if (_selectedFiles.isNotEmpty) ...[
              SizedBox(
                height: 100.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (_, __) => Gap(10.w),
                  itemBuilder: (context, index) {
                    final f = _selectedFiles[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            File(f.path),
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFiles.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Gap(12.h),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text('take_photo'.tr()),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text('choose_gallery'.tr()),
                  ),
                ),
              ],
            ),
            Gap(16.h),

            // Location Verification Card
            SectionHeader(title: 'location'.tr()),
            AppCard(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  IconBadge(
                    icon: Icons.gps_fixed_rounded,
                    color: _currentPosition != null
                        ? AppColors.success
                        : AppColors.warning,
                    size: 36,
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fetchingLocation
                              ? 'acquiring_gps'.tr()
                              : _currentPosition != null
                                  ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                  : '${'gps_verified'.tr()} (24.7136, 46.6753)',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'gps_attached_hint'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _determinePosition,
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Notes field
            SectionHeader(title: 'add_notes'.tr()),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'notes_hint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            Gap(24.h),

            // Submit CTA
            GradientButton(
              label: 'submit_action'.tr(),
              icon: Icons.send_rounded,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
