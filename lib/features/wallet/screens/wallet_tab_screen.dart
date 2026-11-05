import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/wallet_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/wallet_repository.dart';
import 'package:impact_loop/injector.dart';

class WalletTabScreen extends StatefulWidget {
  const WalletTabScreen({super.key});

  @override
  State<WalletTabScreen> createState() => _WalletTabScreenState();
}

class _WalletTabScreenState extends State<WalletTabScreen> {
  bool _loading = true;
  WalletSummary? _wallet;
  String? _error;

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
    final result = await serviceLocator<WalletRepository>().getWallet();
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (r) => setState(() {
        _loading = false;
        _wallet = r;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('wallet_title'.tr()),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.notificationsRoute),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      // Balance Card
                      AppCard(
                        padding: EdgeInsets.all(20.w),
                        gradient: AppColors.walletGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'available_balance'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                GlassCard(
                                  radius: 12,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  opacity: 0.2,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.eco,
                                          color: Colors.white, size: 14),
                                      Gap(4.w),
                                      Text(
                                        'eco_rewards'.tr(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Gap(10.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${_wallet?.balancePoints ?? 0}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Gap(6.w),
                                Text(
                                  'points'.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                            Gap(18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final res = await Navigator.pushNamed(
                                        context,
                                        Routes.withdrawRoute,
                                        arguments: _wallet?.balancePoints ?? 0,
                                      );
                                      if (res == true) _load();
                                    },
                                    icon: const Icon(Icons.arrow_upward_rounded),
                                    label: Text('withdraw'.tr()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryDark,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                ),
                                Gap(10.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                        context, Routes.exploreRoute),
                                    icon: const Icon(Icons.add_rounded,
                                        color: Colors.white),
                                    label: Text(
                                      'start_mission'.tr(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white70),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gap(20.h),

                      // Ledger Title
                      SectionHeader(title: 'ledger'.tr()),
                      if (_wallet?.transactions.isEmpty ?? true)
                        EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'no_data'.tr(),
                        )
                      else
                        ...(_wallet!.transactions.map(
                          (t) {
                            final isPositive = t.amountPoints > 0;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: AppCard(
                                padding: EdgeInsets.all(12.w),
                                child: Row(
                                  children: [
                                    IconBadge(
                                      icon: isPositive
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: isPositive
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 40,
                                    ),
                                    Gap(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.reason ?? t.type.name.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          Gap(3.h),
                                          Text(
                                            DateFormat.yMMMd()
                                                .add_jm()
                                                .format(t.createdAt),
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isPositive ? '+' : ''}${t.amountPoints} ${'pts'.tr()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.sp,
                                        color: isPositive
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                    ],
                  ),
                ),
    );
  }
}
