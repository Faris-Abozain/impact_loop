import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';
import 'package:impact_loop/features/auth/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _usePhone = false;
  bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  double get _strength {
    final p = _password.text;
    var s = 0.0;
    if (p.length >= 8) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s += 0.25;
    return s;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      showAppSnack(context, 'accept_terms_error'.tr(), error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(
          name: _name.text.trim(),
          password: _password.text,
          email: _usePhone ? null : _identifier.text.trim(),
          phone: _usePhone ? _identifier.text.trim() : null,
        );
  }

  Color _strengthColor(double s) => s < 0.5
      ? AppColors.error
      : s < 1
          ? AppColors.warning
          : AppColors.success;

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
        return AuthScaffold(
          showBack: true,
          title: 'create_account'.tr(),
          subtitle: 'register_subtitle'.tr(),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'have_account'.tr(),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5.sp),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('login'.tr()),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledField(
                  label: 'full_name'.tr(),
                  controller: _name,
                  hint: 'full_name_hint'.tr(),
                  icon: Icons.person_outline_rounded,
                  validator: Validators.required,
                ),
                Gap(14.h),
                IdentifierSwitch(
                  usePhone: _usePhone,
                  onChanged: (v) => setState(() {
                    _usePhone = v;
                    _identifier.clear();
                  }),
                ),
                Gap(14.h),
                LabeledField(
                  key: ValueKey(_usePhone),
                  label: _usePhone ? 'phone'.tr() : 'email'.tr(),
                  controller: _identifier,
                  hint: _usePhone ? '+966 5X XXX XXXX' : 'you@example.com',
                  icon: _usePhone
                      ? Icons.phone_iphone_rounded
                      : Icons.alternate_email_rounded,
                  keyboardType:
                      _usePhone ? TextInputType.phone : TextInputType.emailAddress,
                  validator: _usePhone ? Validators.phone : Validators.email,
                ),
                Gap(14.h),
                StatefulBuilder(
                  builder: (context, _) => LabeledField(
                    label: 'password'.tr(),
                    controller: _password,
                    hint: 'password_hint'.tr(),
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    validator: Validators.password,
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                Gap(8.h),
                ValueListenableBuilder(
                  valueListenable: _password,
                  builder: (context, _, __) {
                    final s = _strength;
                    final strengthColor = _strengthColor(s);
                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: s),
                              duration: const Duration(milliseconds: 300),
                              builder: (_, v, __) => LinearProgressIndicator(
                                value: v,
                                minHeight: 6.h,
                                color: strengthColor,
                                backgroundColor: AppColors.border,
                              ),
                            ),
                          ),
                        ),
                        Gap(10.w),
                        Text(
                          s < 0.5
                              ? 'weak'.tr()
                              : s < 1
                                  ? 'medium'.tr()
                                  : 'strong'.tr(),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: strengthColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Gap(14.h),
                LabeledField(
                  label: 'confirm_password'.tr(),
                  controller: _confirm,
                  hint: '••••••••',
                  icon: Icons.lock_reset_rounded,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v != _password.text ? 'passwords_mismatch'.tr() : null,
                ),
                Gap(12.h),
                InkWell(
                  borderRadius: BorderRadius.circular(10.r),
                  onTap: () => setState(() => _agree = !_agree),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agree,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        onChanged: (v) => setState(() => _agree = v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'accept_terms'.tr(),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(12.h),
                GradientButton(
                  label: 'create_account'.tr(),
                  icon: Icons.person_add_alt_1_rounded,
                  loading: state is AuthLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
