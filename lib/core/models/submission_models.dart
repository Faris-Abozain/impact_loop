import 'impact_enums.dart';
import 'mission_models.dart';

class SubmissionEvidence {
  final String id;
  final String mimeType;
  final String? publicUrl;
  final DateTime createdAt;

  SubmissionEvidence({
    required this.id,
    required this.mimeType,
    this.publicUrl,
    required this.createdAt,
  });

  factory SubmissionEvidence.fromJson(Map<String, dynamic> json) =>
      SubmissionEvidence(
        id: json['id'] as String,
        mimeType: json['mimeType'] as String,
        publicUrl: json['publicUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class MySubmissionItem {
  final String id;
  final String taskId;
  final String campaignId;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  MySubmissionItem({
    required this.id,
    required this.taskId,
    required this.campaignId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MySubmissionItem.fromJson(Map<String, dynamic> json) =>
      MySubmissionItem(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        campaignId: json['campaignId'] as String,
        status: SubmissionStatusX.fromApi(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class SubmissionDetail {
  final String id;
  final String taskId;
  final String campaignId;
  final SubmissionStatus status;
  final String? note;
  final LatLng? location;
  final List<String> reasonCodes;
  final List<SubmissionEvidence> evidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubmissionDetail({
    required this.id,
    required this.taskId,
    required this.campaignId,
    required this.status,
    this.note,
    this.location,
    required this.reasonCodes,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubmissionDetail.fromJson(Map<String, dynamic> json) =>
      SubmissionDetail(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        campaignId: json['campaignId'] as String,
        status: SubmissionStatusX.fromApi(json['status'] as String),
        note: json['note'] as String?,
        location: json['location'] != null
            ? LatLng.fromJson(json['location'] as Map<String, dynamic>)
            : null,
        reasonCodes: (json['reasonCodes'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        evidence: (json['evidence'] as List<dynamic>? ?? [])
            .map((e) =>
                SubmissionEvidence.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
