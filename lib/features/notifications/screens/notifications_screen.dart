import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/notification_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/notifications/data/notifications_repository.dart';
import 'package:impact_loop/injector.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<AppNotification> _notifications = [];

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
    final result = await serviceLocator<NotificationsRepository>().list();
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (r) => setState(() {
        _loading = false;
        _notifications = r;
      }),
    );
  }

  Future<void> _markAllRead() async {
    await serviceLocator<NotificationsRepository>().markAllRead();
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(read: true)).toList();
    });
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.reward:
        return Icons.stars_rounded;
      case NotificationType.submission:
        return Icons.assignment_turned_in_rounded;
      case NotificationType.mission:
        return Icons.explore_rounded;
      case NotificationType.verification:
        return Icons.verified_user_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.reward:
        return AppColors.warning;
      case NotificationType.submission:
        return AppColors.primary;
      case NotificationType.mission:
        return AppColors.accent;
      case NotificationType.verification:
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  void _onNotificationTap(AppNotification item) {
    serviceLocator<NotificationsRepository>().markRead(item.id);
    setState(() {
      final i = _notifications.indexWhere((n) => n.id == item.id);
      if (i != -1) {
        _notifications[i] = item.copyWith(read: true);
      }
    });

    if (item.targetId != null) {
      if (item.type == NotificationType.submission ||
          item.type == NotificationType.reward) {
        Navigator.pushNamed(
          context,
          Routes.submissionDetailRoute,
          arguments: item.targetId,
        );
      } else if (item.type == NotificationType.mission) {
        Navigator.pushNamed(
          context,
          Routes.missionDetailRoute,
          arguments: item.targetId,
        );
      } else if (item.type == NotificationType.verification) {
        Navigator.pushNamed(context, Routes.verificationRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications_title'.tr()),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'mark_all_read'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _notifications.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'no_notifications'.tr(),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => Gap(10.h),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final color = _colorForType(item.type);
                          return AppCard(
                            onTap: () => _onNotificationTap(item),
                            color: item.read
                                ? AppColors.card
                                : AppColors.mint.withValues(alpha: 0.6),
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconBadge(
                                  icon: _iconForType(item.type),
                                  color: color,
                                  size: 42,
                                ),
                                Gap(12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 14.5.sp,
                                                fontWeight: item.read
                                                    ? FontWeight.w600
                                                    : FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (!item.read)
                                            Container(
                                              width: 8.w,
                                              height: 8.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Gap(4.h),
                                      Text(
                                        item.body,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                      Gap(6.h),
                                      Text(
                                        DateFormat.yMMMd()
                                            .add_jm()
                                            .format(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
