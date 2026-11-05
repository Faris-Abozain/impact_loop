import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/wallet_repository.dart';
import 'package:impact_loop/injector.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key, required this.availableBalance});

  final int availableBalance;

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();

  String _method = 'STC_PAY';
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final points = int.tryParse(_amountController.text.trim()) ?? 0;
    if (points <= 0) {
      showAppSnack(context, 'enter_valid_amount'.tr(), error: true);
      return;
    }
    if (points > widget.availableBalance) {
      showAppSnack(context, 'amount_exceeds_balance'.tr(), error: true);
      return;
    }

    setState(() => _loading = true);
    final result = await serviceLocator<WalletRepository>().requestWithdrawal(
      points: points,
      method: _method,
      destination: _accountController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (failure) => showAppSnack(context, failure.message, error: true),
      (_) {
        showAppSnack(context, 'withdrawal_success'.tr());
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('withdraw'.tr()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Balance Card
            AppCard(
              padding: EdgeInsets.all(18.w),
              gradient: AppColors.walletGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'available_balance'.tr(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Gap(6.h),
                  Text(
                    '${widget.availableBalance} ${'points'.tr()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Gap(20.h),

            // Method Selection
        DropdownButtonFormField<String>(
          value: _method,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'withdraw_method'.tr(),
            prefixIcon: const Icon(Icons.payment_outlined),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'STC_PAY',
              child: Text(
                'stc_pay'.tr(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            DropdownMenuItem(
              value: 'BANK_TRANSFER',
              child: Text(
                'bank_wire'.tr(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const DropdownMenuItem(
              value: 'PAYPAL',
              child: Text(
                'PayPal',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            DropdownMenuItem(
              value: 'GREEN_VOUCHER',
              child: Text(
                'eco_voucher'.tr(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _method = val);
            }
          },
        ),
            Gap(14.h),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'withdraw_amount'.tr(),
                hintText: 'e.g. 100',
                prefixIcon: const Icon(Icons.stars_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'field_required'.tr();
                final val = int.tryParse(v.trim());
                if (val == null || val <= 0) return 'enter_valid_number'.tr();
                if (val > widget.availableBalance) return 'exceeds_balance'.tr();
                return null;
              },
            ),
            Gap(14.h),

            // Account / Destination
            TextFormField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: 'withdraw_account'.tr(),
                hintText: _method == 'STC_PAY'
                    ? '05XXXXXXXX'
                    : _method == 'BANK_TRANSFER'
                        ? 'SA00 0000 0000 0000'
                        : 'email@example.com',
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'field_required'.tr() : null,
            ),
            Gap(28.h),

            GradientButton(
              label: 'request_withdrawal'.tr(),
              icon: Icons.account_balance_wallet_rounded,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
