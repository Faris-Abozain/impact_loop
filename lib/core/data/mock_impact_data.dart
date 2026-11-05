import '../models/impact_enums.dart';
import '../models/mission_models.dart';
import '../models/submission_models.dart';
import '../models/user_models.dart';
import '../models/wallet_models.dart';

class MockImpactData {
  static final MeProfile demoUser = MeProfile(
    id: '11111111-1111-1111-1111-111111111111',
    name: 'بطل الأثر البيئي',
    email: 'demo@impactloop.app',
    phone: '+966500000000',
    role: AppRole.user,
    roles: [AppRole.user],
    verifiedStatus: VerifiedStatus.pending,
  );

  static final MeProfile adminUser = MeProfile(
    id: '22222222-2222-2222-2222-222222222222',
    name: 'مراجع العمليات',
    email: 'ops@impactloop.app',
    role: AppRole.admin,
    roles: [AppRole.admin, AppRole.user],
    verifiedStatus: VerifiedStatus.verified,
  );

  static List<MissionSummary> missions = [
    MissionSummary(
      id: 'm1',
      title: 'تنظيف مسار الشارع البيئي',
      description: 'توثيق إزالة النفايات والمخلفات على طول المسار المخصص وتجميل الحي.',
      taskTypes: ['DUMPING_REPORT'],
      availableTasks: 12,
      minRewardPoints: 50,
      maxRewardPoints: 120,
      distanceMeters: 850,
      startAt: DateTime.now().subtract(const Duration(days: 2)),
      endAt: DateTime.now().add(const Duration(days: 30)),
    ),
    MissionSummary(
      id: 'm2',
      title: 'تسليم المواد القابلة لإعادة التدوير',
      description: 'فرز وتسليم البلاستيك والورق والمعادن في مراكز التجميع المعتمدة.',
      taskTypes: ['RECYCLING_DROPOFF'],
      availableTasks: 8,
      minRewardPoints: 30,
      maxRewardPoints: 80,
      distanceMeters: 2100,
      startAt: DateTime.now().subtract(const Duration(days: 5)),
      endAt: DateTime.now().add(const Duration(days: 45)),
    ),
    MissionSummary(
      id: 'm3',
      title: 'تحدي التنقل الأخضر المستدام',
      description: 'استخدام وسائل النقل العام أو الدراجة الهوائية وتوثيق المسار لخفض الانبعاثات.',
      taskTypes: ['PUBLIC_TRANSPORT'],
      availableTasks: 5,
      minRewardPoints: 40,
      maxRewardPoints: 100,
      distanceMeters: 4200,
      startAt: DateTime.now(),
      endAt: DateTime.now().add(const Duration(days: 14)),
    ),
  ];

  static MissionTaskItem taskForMission(String missionId, int index) {
    final titles = [
      'التقاط صور النفايات قبل وبعد الجمع',
      'توثيق التخلص في الحاوية المخصصة',
      'تسجيل إحداثيات الموقع النظيف',
    ];
    final title = index < titles.length ? titles[index] : 'المهمة الفرعية ${index + 1}';
    return MissionTaskItem(
      id: 't-$missionId-$index',
      campaignId: missionId,
      type: missionId == 'm2'
          ? 'RECYCLING_DROPOFF'
          : missionId == 'm3'
              ? 'PUBLIC_TRANSPORT'
              : 'DUMPING_REPORT',
      title: title,
      instructions:
          'التقط صوراً وفيديوهات واضحة تثبت إنجاز العمل مع تفعيل الـ GPS والتأكد من مطابقة الموقع ضمن نطاق المهمة المحدد.',
      location: LatLng(lat: 24.7136 + index * 0.01, lng: 46.6753),
      radiusMeters: 500,
      rewardPoints: 50 + index * 10,
      status: 'OPEN',
      distanceMeters: 300 + index * 150.0,
    );
  }

  static List<MySubmissionItem> mySubmissions = [
    MySubmissionItem(
      id: 's1',
      taskId: 't-m1-0',
      campaignId: 'm1',
      status: SubmissionStatus.pendingReview,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    MySubmissionItem(
      id: 's2',
      taskId: 't-m2-0',
      campaignId: 'm2',
      status: SubmissionStatus.needsInfo,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    MySubmissionItem(
      id: 's3',
      taskId: 't-m1-1',
      campaignId: 'm1',
      status: SubmissionStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static SubmissionDetail submissionDetail(String id) {
    final item = mySubmissions.firstWhere((s) => s.id == id);
    return SubmissionDetail(
      id: item.id,
      taskId: item.taskId,
      campaignId: item.campaignId,
      status: item.status,
      note: 'تم إنجاز التنظيف وإزالة النفايات البلاستيكية بنجاح بجوار الشارع العام.',
      location: LatLng(lat: 24.7136, lng: 46.6753),
      reasonCodes: item.status == SubmissionStatus.needsInfo
          ? ['الصورة غير واضحة، يرجى إعادة التقاط صورة مقربة للحاوية']
          : [],
      evidence: [
        SubmissionEvidence(
          id: 'e1',
          mimeType: 'image/jpeg',
          publicUrl: null,
          createdAt: item.createdAt,
        ),
      ],
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  static WalletSummary wallet = WalletSummary(
    balancePoints: 240,
    transactions: [
      WalletTransaction(
        id: 'w1',
        type: WalletTransactionType.reward,
        amountPoints: 80,
        reason: 'مكافأة اعتماد إثبات تنظيف الشارع',
        submissionId: 's3',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WalletTransaction(
        id: 'w2',
        type: WalletTransactionType.reward,
        amountPoints: 50,
        reason: 'مكافأة تسليم مواد إعادة التدوير',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ],
  );

  static ImpactSummary impact = ImpactSummary(
    totalSubmissions: 8,
    approvedSubmissions: 5,
    rejectedSubmissions: 1,
    pointsEarned: 240,
  );
}
