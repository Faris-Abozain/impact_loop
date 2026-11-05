import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'reset_password'.tr(),
      subtitle: 'reset_password_subtitle'.tr(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _sent
            ? Column(
                key: const ValueKey('sent'),
                children: [
                  Gap(8.h),
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.primary,
                      size: 40.sp,
                    ),
                  ),
                  Gap(14.h),
                  Text(
                    'reset_link_sent'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
                  ),
                  Gap(6.h),
                  Text(
                    'reset_link_sent_body'.tr(namedArgs: {'email': _email.text}),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  Gap(20.h),
                  GradientButton(
                    label: 'back_to_login'.tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  key: const ValueKey('form'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledField(
                      label: 'email'.tr(),
                      controller: _email,
                      hint: 'you@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      textInputAction: TextInputAction.done,
                    ),
                    Gap(20.h),
                    GradientButton(
                      label: 'send_reset_link'.tr(),
                      icon: Icons.send_rounded,
                      loading: _loading,
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
