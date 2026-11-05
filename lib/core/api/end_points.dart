import '../config/app_config.dart';

class EndPoints {
  static String get baseUrl =>
      AppConfig.apiBaseUrl.endsWith('/')
          ? AppConfig.apiBaseUrl
          : '${AppConfig.apiBaseUrl}/';

  static const String health = 'health';
  static const String ready = 'ready';
  static const String authRegister = 'auth/register';
  static const String authLogin = 'auth/login';
  static const String loginUrl = 'auth/login';
  static const String homeUrl = 'home';
  static const String authRefresh = 'auth/refresh';
  static const String authLogout = 'auth/logout';

  static const String me = 'me';
  static const String usersMe = 'users/me';
  static const String usersMeWallet = 'users/me/wallet';
  static const String usersMeImpact = 'users/me/impact';
  static const String wallet = 'wallet';
  static const String walletLedger = 'wallet/ledger';
  static const String walletWithdraw = 'wallet/withdraw';

  static const String missions = 'missions';
  static String mission(String id) => 'missions/$id';
  static String missionTasks(String missionId) => 'missions/$missionId/tasks';

  static const String tasksNearby = 'tasks/nearby';
  static String task(String taskId) => 'tasks/$taskId';
  static String taskReserve(String taskId) => 'tasks/$taskId/reserve';
  static String taskSubmit(String taskId) => 'tasks/$taskId/submit';

  static const String submissions = 'submissions';
  static String submission(String id) => 'submissions/$id';
  static String submissionSubmit(String id) => 'submissions/$id/submit';

  static const String campaigns = 'campaigns';
  static String campaign(String id) => 'campaigns/$id';
  static String campaignStatus(String id) => 'campaigns/$id/status';
  static String campaignSubmissions(String id) => 'campaigns/$id/submissions';
  static String campaignSubmissionsExport(String id) => 'campaigns/$id/submissions/export';

  static const String adminSubmissions = 'admin/submissions';
  static String adminApprove(String id) => 'admin/submissions/$id/approve';
  static String adminReject(String id) => 'admin/submissions/$id/reject';
  static String adminWalletAdjust(String userId) => 'admin/wallet/$userId/adjust';

  static const String notifications = 'notifications';
  static String notificationRead(String id) => 'notifications/$id/read';
  static const String devicesRegister = 'devices/register';

  static const String verificationStatus = 'verification/status';
  static const String verificationSubmit = 'verification/submit';
  static const String verificationDetails = 'verification/details';

  static const String opsSubmissions = 'ops/submissions';
  static String opsApprove(String id) => 'ops/submissions/$id/approve';
  static String opsReject(String id) => 'ops/submissions/$id/reject';
  static String opsRequestInfo(String id) => 'ops/submissions/$id/request-info';
}

