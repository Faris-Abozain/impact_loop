class MissionSummary {
  final String id;
  final String title;
  final String? description;
  final List<String> taskTypes;
  final int availableTasks;
  final int? minRewardPoints;
  final int? maxRewardPoints;
  final double? distanceMeters;
  final DateTime startAt;
  final DateTime endAt;

  MissionSummary({
    required this.id,
    required this.title,
    this.description,
    required this.taskTypes,
    required this.availableTasks,
    this.minRewardPoints,
    this.maxRewardPoints,
    this.distanceMeters,
    required this.startAt,
    required this.endAt,
  });

  String localizedTitle(String langCode) =>
      ContentTranslator.translate(title, langCode);

  String? localizedDescription(String langCode) => description == null
      ? null
      : ContentTranslator.translate(description!, langCode);

  factory MissionSummary.fromJson(Map<String, dynamic> json) => MissionSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        taskTypes: (json['taskTypes'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        availableTasks: json['availableTasks'] as int,
        minRewardPoints: json['minRewardPoints'] as int?,
        maxRewardPoints: json['maxRewardPoints'] as int?,
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: DateTime.parse(json['endAt'] as String),
      );
}

class LatLng {
  final double lat;
  final double lng;

  const LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class MissionTaskItem {
  final String id;
  final String campaignId;
  final String type;
  final String title;
  final String instructions;
  final LatLng location;
  final int radiusMeters;
  final int rewardPoints;
  final String status;
  final DateTime? expiresAt;
  final double? distanceMeters;

  MissionTaskItem({
    required this.id,
    required this.campaignId,
    required this.type,
    required this.title,
    required this.instructions,
    required this.location,
    required this.radiusMeters,
    required this.rewardPoints,
    required this.status,
    this.expiresAt,
    this.distanceMeters,
  });

  String localizedTitle(String langCode) =>
      ContentTranslator.translate(title, langCode);

  String localizedInstructions(String langCode) =>
      ContentTranslator.translate(instructions, langCode);

  factory MissionTaskItem.fromJson(Map<String, dynamic> json) =>
      MissionTaskItem(
        id: json['id'] as String,
        campaignId: (json['campaignId'] as String?) ?? '',
        type: (json['type'] as String?) ?? 'DUMPING_REPORT',
        title: (json['title'] as String?) ?? '',
        instructions: (json['instructions'] as String?) ?? '',
        location: json['location'] != null
            ? LatLng.fromJson(json['location'] as Map<String, dynamic>)
            : const LatLng(lat: 30.0444, lng: 31.2357),
        radiusMeters: (json['radiusMeters'] as int?) ?? 500,
        rewardPoints: (json['rewardPoints'] as int?) ?? 50,
        status: (json['status'] as String?) ?? 'OPEN',
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      );
}

class TaskDetail {
  final String id;
  final String campaignId;
  final String type;
  final String title;
  final String instructions;
  final LatLng location;
  final int radiusMeters;
  final int rewardPoints;
  final String status;
  final DateTime? expiresAt;

  TaskDetail({
    required this.id,
    required this.campaignId,
    required this.type,
    required this.title,
    required this.instructions,
    required this.location,
    required this.radiusMeters,
    required this.rewardPoints,
    required this.status,
    this.expiresAt,
  });

  String localizedTitle(String langCode) =>
      ContentTranslator.translate(title, langCode);

  String localizedInstructions(String langCode) =>
      ContentTranslator.translate(instructions, langCode);

  factory TaskDetail.fromJson(Map<String, dynamic> json) => TaskDetail(
        id: json['id'] as String,
        campaignId: (json['campaignId'] as String?) ?? '',
        type: (json['type'] as String?) ?? 'DUMPING_REPORT',
        title: (json['title'] as String?) ?? '',
        instructions: (json['instructions'] as String?) ?? '',
        location: json['location'] != null
            ? LatLng.fromJson(json['location'] as Map<String, dynamic>)
            : const LatLng(lat: 30.0444, lng: 31.2357),
        radiusMeters: (json['radiusMeters'] as int?) ?? 500,
        rewardPoints: (json['rewardPoints'] as int?) ?? 50,
        status: (json['status'] as String?) ?? 'OPEN',
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}

class ContentTranslator {
  static final Map<String, String> _arTranslations = {
    // Mission Titles
    'Clean Nile River Bank': 'تنظيف ضفاف نهر النيل',
    'Downtown Plastic Sorting Drop-off': 'نقطة فرز وتجميع البلاستيك بوسط البلد',
    'Cairo Metro Transit Loop': 'مسار مترو القاهرة الأخضر',
    'Community Tree Planting': 'تشجير وزراعة الأشجار المجتمعية',
    'Solar Panel Inspection': 'فحص ومتابعة ألواح الطاقة الشمسية',

    // Task Titles
    'Report illegal dumping': 'الإبلاغ عن مكب نفايات عشوائي',
    'Drop off plastic bottles': 'تسليم زجاجات بلاستيكية قابلة للتدوير',
    'Ride green transit': 'استخدام المواصلات العامة المستدامة',
    'Verify bin cleanliness': 'التحقق من نظافة الحاويات وسعتها',
    'Document recycling dropoff': 'توثيق تسليم المواد المفروزة',
    'Inspect recycling dropoff point': 'فحص نقطة تجميع وإعادة التدوير',

    // Mission Descriptions
    'Participate in cleaning trash along the Nile River to protect marine life and urban hygiene.':
        'شارك في إزالة وتنظيف النفايات على ضفاف نهر النيل لحماية الحياة البحرية ونظافة المدينة.',
    'Drop off sorted plastic and paper materials at the downtown green collection hub.':
        'قم بتسليم البلاستيك والورق المفروز إلى مركز التجميع الأخضر بوسط البلد لكسب النقاط.',
    'Earn rewards by using Cairo public metro system and reducing vehicular emissions.':
        'احصل على مكافآت عبر استخدام شبكة مترو القاهرة العامة والحد من الانبعاثات الكربونية.',

    // Task Instructions
    'Take a clear geo-tagged photo of the illegal waste site and submit notes.':
        'التقط صورة واضحة محددة جغرافياً لموقع النفايات غير القانوني وأرسل الملاحظات.',
    'Deliver at least 5kg of sorted plastic bottles to the hub coordinator.':
        'سلّم ما لا يقل عن 5 كجم من الزجاجات البلاستيكية النظيفة لمشرف نقطة التجميع.',
    'Check in at any metro station during peak hours and verify your ticket.':
        'سجّل الوصول في أي محطة مترو خلال ساعات الذروة مع إرفاق التذكرة أو الرمز.',
    'Verify that the collection bins are not overflowing and in good condition.':
        'تأكد من أن حاويات التجميع ليست ممتلئة بشكل مفرط وأنها بحالة جيدة ونظيفة.',
  };

  static String translate(String text, String langCode) {
    if (langCode != 'ar') return text;
    final trimmed = text.trim();
    if (_arTranslations.containsKey(trimmed)) {
      return _arTranslations[trimmed]!;
    }
    for (final entry in _arTranslations.entries) {
      if (trimmed.toLowerCase() == entry.key.toLowerCase()) {
        return entry.value;
      }
    }
    return text;
  }
}

