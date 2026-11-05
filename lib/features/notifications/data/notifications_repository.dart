import 'package:dartz/dartz.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/notification_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final BaseApiConsumer _api;

  static final List<AppNotification> _mock = [
    AppNotification(
      id: 'n1',
      title: 'تم إيداع المكافأة في محفظتك 🎉',
      body: 'تمت إضافة +80 نقطة إلى محفظتك مقابل اعتماد مهمة "تنظيف مسار الشارع البيئي".',
      type: NotificationType.reward,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      targetId: 's3',
    ),
    AppNotification(
      id: 'n2',
      title: 'مطلوب توضيح إضافي للإثبات',
      body: 'صورة إثبات إعادة التدوير غير واضحة تماماً. يرجى إعادة رفع صورة واضحة للحاوية المخصصة.',
      type: NotificationType.submission,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      targetId: 's2',
    ),
    AppNotification(
      id: 'n3',
      title: 'مهمة بيئية جديدة بالقرب منك',
      body: 'تحدي التنقل الأخضر المستدام متاح الآن في منطقتك — اكسب حتى 100 نقطة.',
      type: NotificationType.mission,
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      targetId: 'm3',
      read: true,
    ),
    AppNotification(
      id: 'n4',
      title: 'طلب التحقق قيد المراجعة',
      body: 'تم استلام وثائق الهوية الخاصة بك، وتستغرق مراجعة الحساب عادة بين 24 إلى 48 ساعة.',
      type: NotificationType.verification,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      read: true,
    ),
    AppNotification(
      id: 'n5',
      title: 'أهلاً بك في تطبيق إمباكت لوب 🌱',
      body: 'أنجز أول مهمة بيئية لك اليوم وابدأ في جمع النقاط والمكافآت الحقيقية.',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      read: true,
    ),
  ];

  Future<Either<Failure, List<AppNotification>>> list() async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return Right(List.of(_mock));
    }
    try {
      final raw = await _api.get(EndPoints.notifications);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final items = (envelope.data!['notifications'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  int get mockUnreadCount => _mock.where((n) => !n.read).length;

  Future<void> markRead(String id) async {
    if (AppConfig.useMockApi) {
      final i = _mock.indexWhere((n) => n.id == id);
      if (i != -1) _mock[i] = _mock[i].copyWith(read: true);
      return;
    }
    try {
      await _api.post(EndPoints.notificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    if (AppConfig.useMockApi) {
      for (var i = 0; i < _mock.length; i++) {
        _mock[i] = _mock[i].copyWith(read: true);
      }
      return;
    }
    for (final n in _mock.where((n) => !n.read)) {
      await markRead(n.id);
    }
  }

  Future<Either<Failure, Unit>> registerDevice({
    required String platform,
    required String token,
    String? deviceId,
  }) async {
    if (AppConfig.useMockApi) return const Right(unit);
    try {
      final raw = await _api.post(
        EndPoints.devicesRegister,
        body: {
          'platform': platform,
          'token': token,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to register device'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

