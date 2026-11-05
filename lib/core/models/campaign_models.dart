import 'impact_enums.dart';

class CampaignAreaGeoJson {
  final String type;
  final List<dynamic> coordinates;

  CampaignAreaGeoJson({required this.type, required this.coordinates});

  factory CampaignAreaGeoJson.fromJson(Map<String, dynamic> json) =>
      CampaignAreaGeoJson(
        type: json['type'] as String? ?? 'Polygon',
        coordinates: json['coordinates'] as List<dynamic>? ?? [],
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class Campaign {
  final String id;
  final String clientId;
  final String title;
  final String? description;
  final double budgetTotal;
  final double budgetRemaining;
  final CampaignAreaGeoJson areaGeoJson;
  final List<String> taskTypes;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.clientId,
    required this.title,
    this.description,
    required this.budgetTotal,
    required this.budgetRemaining,
    required this.areaGeoJson,
    required this.taskTypes,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        budgetTotal: (json['budgetTotal'] as num).toDouble(),
        budgetRemaining: (json['budgetRemaining'] as num).toDouble(),
        areaGeoJson: CampaignAreaGeoJson.fromJson(
            json['areaGeoJson'] as Map<String, dynamic>),
        taskTypes: (json['taskTypes'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        status: json['status'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: DateTime.parse(json['endAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'title': title,
        'description': description,
        'budgetTotal': budgetTotal,
        'budgetRemaining': budgetRemaining,
        'areaGeoJson': areaGeoJson.toJson(),
        'taskTypes': taskTypes,
        'status': status,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CampaignMetrics {
  final int totalSubmissions;
  final int approvedSubmissions;
  final int rejectedSubmissions;
  final int flaggedSubmissions;
  final int pointsPaid;

  CampaignMetrics({
    required this.totalSubmissions,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
    required this.flaggedSubmissions,
    required this.pointsPaid,
  });

  factory CampaignMetrics.fromJson(Map<String, dynamic> json) => CampaignMetrics(
        totalSubmissions: json['totalSubmissions'] as int? ?? 0,
        approvedSubmissions: json['approvedSubmissions'] as int? ?? 0,
        rejectedSubmissions: json['rejectedSubmissions'] as int? ?? 0,
        flaggedSubmissions: json['flaggedSubmissions'] as int? ?? 0,
        pointsPaid: json['pointsPaid'] as int? ?? 0,
      );
}

class CampaignSubmissionItem {
  final String id;
  final String taskId;
  final String userId;
  final SubmissionStatus status;
  final int? verificationScore;
  final List<String> reasonCodes;
  final DateTime createdAt;

  CampaignSubmissionItem({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.status,
    this.verificationScore,
    required this.reasonCodes,
    required this.createdAt,
  });

  factory CampaignSubmissionItem.fromJson(Map<String, dynamic> json) =>
      CampaignSubmissionItem(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        userId: json['userId'] as String,
        status: SubmissionStatusX.fromApi(json['status'] as String),
        verificationScore: json['verificationScore'] as int?,
        reasonCodes: (json['reasonCodes'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
