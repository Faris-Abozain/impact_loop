import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:impact_loop/core/models/notification_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/verification/data/verification_repository.dart';
import 'package:impact_loop/injector.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _picker = ImagePicker();

  String _docType = 'NATIONAL_ID';
  XFile? _frontFile;
  XFile? _backFile;
  XFile? _selfieFile;

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  VerificationInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await serviceLocator<VerificationRepository>().status();
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (info) => setState(() {
        _loading = false;
        _info = info;
      }),
    );
  }

  Future<void> _pickFile(int slot) async {
    final file = await _picker.pickImage(
      source: slot == 3 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        if (slot == 1) _frontFile = file;
        if (slot == 2) _backFile = file;
        if (slot == 3) _selfieFile = file;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frontFile == null || _selfieFile == null) {
      showAppSnack(context, 'upload_required_files'.tr(), error: true);
      return;
    }

    setState(() => _submitting = true);
    final result = await serviceLocator<VerificationRepository>().submit(
      fullName: _nameController.text.trim(),
      documentType: _docType,
      documentNumber: _docNumberController.text.trim(),
      frontPath: _frontFile!.path,
      backPath: _backFile?.path,
      selfiePath: _selfieFile!.path,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (l) => showAppSnack(context, l.message, error: true),
      (info) {
        showAppSnack(context, 'verification_submitted_success'.tr());
        setState(() => _info = info);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('verification_title'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _info?.status == 'VERIFIED'
                  ? _buildVerifiedState()
                  : _info?.status == 'PENDING'
                      ? _buildPendingState()
                      : _buildForm(),
    );
  }

  Widget _buildVerifiedState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.secondPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified_user_rounded,
                  color: AppColors.primary, size: 60.sp),
            ),
            Gap(20.h),
            Text(
              'verification_verified'.tr(),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            Text(
              'kyc_verified_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded,
                  color: AppColors.warning, size: 60.sp),
            ),
            Gap(20.h),
            Text(
              'verification_pending'.tr(),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            Gap(8.h),
            Text(
              'kyc_pending_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'verify_id'.tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Gap(4.h),
          Text(
            'kyc_desc'.tr(),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          Gap(16.h),

          // Full Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'full_name'.tr(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'field_required'.tr() : null,
          ),
          Gap(14.h),

          // Document Type Dropdown
          DropdownButtonFormField<String>(
            value: _docType,
            decoration: InputDecoration(
              labelText: 'id_document_type'.tr(),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: 'NATIONAL_ID',
                child: Text('national_id'.tr()),
              ),
              DropdownMenuItem(
                value: 'PASSPORT',
                child: Text('passport'.tr()),
              ),
              DropdownMenuItem(
                value: 'DRIVER_LICENSE',
                child: Text('driver_license'.tr()),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _docType = val);
            },
          ),
          Gap(14.h),

          // Document Number
          TextFormField(
            controller: _docNumberController,
            decoration: InputDecoration(
              labelText: 'id_number'.tr(),
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'field_required'.tr() : null,
          ),
          Gap(20.h),

          // Document Photos
          SectionHeader(title: 'upload_documents'.tr()),
          _uploadBox(
            title: 'upload_front'.tr(),
            file: _frontFile,
            onTap: () => _pickFile(1),
          ),
          Gap(12.h),
          _uploadBox(
            title: 'upload_back'.tr(),
            file: _backFile,
            onTap: () => _pickFile(2),
          ),
          Gap(12.h),
          _uploadBox(
            title: 'take_selfie'.tr(),
            file: _selfieFile,
            onTap: () => _pickFile(3),
            isCamera: true,
          ),
          Gap(24.h),

          GradientButton(
            label: 'submit_verification'.tr(),
            icon: Icons.shield_rounded,
            loading: _submitting,
            onPressed: _submit,
          ),
          Gap(20.h),
        ],
      ),
    );
  }

  Widget _uploadBox({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
    bool isCamera = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 80.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: file != null ? AppColors.primary : AppColors.border,
            width: file != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (file != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(file.path),
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                ),
              )
            else
              IconBadge(
                icon: isCamera ? Icons.camera_alt : Icons.upload_file,
                color: AppColors.primary,
                size: 40,
              ),
            Gap(12.w),
            Expanded(
              child: Text(
                file != null ? 'file_selected'.tr() : title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: file != null ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: file != null ? AppColors.success : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
