import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/utils/assets_manager.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';

/// Shared scaffold for auth flows: gradient hero header + floating form card.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 70.h),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36.r),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(8.h),
                    SizedBox(
                      height: 44.h,
                      child: showBack
                          ? Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: GlassCard(
                                radius: 14,
                                padding: EdgeInsets.zero,
                                child: IconButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Gap(10.h),
                    FadeSlideIn(
                      child: Row(
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Container(
                              width: 54.w,
                              height: 54.w,
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11.r),
                                child: Image.asset(
                                  ImageAssets.logoImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Gap(12.w),
                          Text(
                            'Impact Loop',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(22.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Gap(6.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14.sp,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -46.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  offset: 40,
                  child: AppCard(
                    padding: EdgeInsets.all(20.w),
                    radius: 26,
                    child: child,
                  ),
                ),
              ),
            ),
            if (footer != null)
              Transform.translate(offset: Offset(0, -30.h), child: footer!),
          ],
        ),
      ),
    );
  }
}

/// Labelled text field used across forms.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          textInputAction: textInputAction ?? TextInputAction.next,
          style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20.sp),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'field_required'.tr() : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'invalid_email'.tr();
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'field_required'.tr();
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v.trim())
        ? null
        : 'invalid_phone'.tr();
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'field_required'.tr();
    return v.length < 8 ? 'password_short'.tr() : null;
  }
}

/// Email / Phone segmented switch.
class IdentifierSwitch extends StatelessWidget {
  const IdentifierSwitch({
    super.key,
    required this.usePhone,
    required this.onChanged,
  });

  final bool usePhone;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, IconData icon, bool selected, bool value) {
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: selected ? AppColors.softShadow : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17.sp,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                Gap(6.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          tab('email'.tr(), Icons.alternate_email_rounded, !usePhone, false),
          tab('phone'.tr(), Icons.phone_iphone_rounded, usePhone, true),
        ],
      ),
    );
  }
}
