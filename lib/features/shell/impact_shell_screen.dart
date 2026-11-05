import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/features/explore/screens/explore_tab_screen.dart';
import 'package:impact_loop/features/home/screens/home_tab_screen.dart';
import 'package:impact_loop/features/profile/screens/profile_tab_screen.dart';
import 'package:impact_loop/features/wallet/screens/wallet_tab_screen.dart';

class ImpactShellScreen extends StatefulWidget {
  const ImpactShellScreen({super.key});

  @override
  State<ImpactShellScreen> createState() => _ImpactShellScreenState();
}

class _ImpactShellScreenState extends State<ImpactShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final tabs = [
      HomeTabScreen(key: ValueKey('home_$lang')),
      ExploreTabScreen(key: ValueKey('explore_$lang')),
      WalletTabScreen(key: ValueKey('wallet_$lang')),
      ProfileTabScreen(
        key: ValueKey('profile_$lang'),
        onLocaleChanged: () => setState(() {}),
      ),
    ];

    final isSubmitActive = _index == 2;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: tabs,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.submitRoute);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: isSubmitActive ? 62.w : 58.w,
          height: isSubmitActive ? 62.w : 58.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isSubmitActive
                  ? [const Color(0xFF15803D), const Color(0xFF16A34A), const Color(0xFF22C55E)]
                  : [const Color(0xFF22C55E), const Color(0xFF16A34A), const Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white,
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isSubmitActive ? 0.55 : 0.35),
                blurRadius: isSubmitActive ? 20 : 14,
                spreadRadius: isSubmitActive ? 3 : 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: isSubmitActive ? 34.sp : 30.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7.0,
        color: Colors.white,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        padding: EdgeInsets.zero,
        height: 64.h,
        child: Row(
          children: [
            // Home Tab
            Expanded(
              child: _ShellTabItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'tab_home'.tr(),
                isSelected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
            ),
            // Explore Tab
            Expanded(
              child: _ShellTabItem(
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore_rounded,
                label: 'tab_explore'.tr(),
                isSelected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
            ),
            // Spacer for Center Docked FAB
            SizedBox(width: 60.w),
            // Wallet Tab
            Expanded(
              child: _ShellTabItem(
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet_rounded,
                label: 'tab_wallet'.tr(),
                isSelected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
            ),
            // Profile Tab
            Expanded(
              child: _ShellTabItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'tab_profile'.tr(),
                isSelected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTabItem extends StatelessWidget {
  const _ShellTabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.08 : 1.0,
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: 23.sp,
              color: color,
            ),
          ),
          Gap(4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

