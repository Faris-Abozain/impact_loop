import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';
import 'package:impact_loop/features/auth/widgets/auth_widgets.dart';

import '../../../config/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _usePhone = false;
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
          password: _password.text,
          email: _usePhone ? null : _identifier.text.trim(),
          phone: _usePhone ? _identifier.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.mainRoute,
            (_) => false,
          );
        } else if (state is AuthFailure) {
          showAppSnack(context, state.message, error: true);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return AuthScaffold(
          title: 'welcome_back'.tr(),
          subtitle: 'login_subtitle'.tr(),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'no_account'.tr(),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5.sp),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.registerRoute),
                child: Text('create_account'.tr()),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IdentifierSwitch(
                  usePhone: _usePhone,
                  onChanged: (v) => setState(() {
                    _usePhone = v;
                    _identifier.clear();
                  }),
                ),
                Gap(18.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: LabeledField(
                    key: ValueKey(_usePhone),
                    label: _usePhone ? 'phone'.tr() : 'email'.tr(),
                    controller: _identifier,
                    hint: _usePhone ? '+10 XX XXX XXX' : 'you@example.com',
                    icon: _usePhone
                        ? Icons.phone_iphone_rounded
                        : Icons.alternate_email_rounded,
                    keyboardType: _usePhone
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    validator: _usePhone ? Validators.phone : Validators.email,
                  ),
                ),
                Gap(14.h),
                LabeledField(
                  label: 'password'.tr(),
                  controller: _password,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  validator: Validators.required,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.forgotPasswordRoute),
                    child: Text('forgot_password'.tr()),
                  ),
                ),
                Gap(4.h),
                GradientButton(
                  label: 'login'.tr(),
                  icon: Icons.login_rounded,
                  loading: loading,
                  onPressed: _submit,
                ),
                Gap(18.h),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'secure_login'.tr(),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                Gap(10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 15.sp, color: AppColors.primary),
                    Gap(6.w),
                    Flexible(
                      child: Text(
                        'secure_login_hint'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
