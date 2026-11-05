enum NotificationType { submission, reward, mission, verification, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;

  /// Optional deep-link target (submission id, mission id, ...).
  final String? targetId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.targetId,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        read: read ?? this.read,
        targetId: targetId,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType parse(String? raw) {
      switch (raw?.toUpperCase()) {
        case 'SUBMISSION':
        case 'SUBMISSION_REJECTED':
          return NotificationType.submission;
        case 'REWARD':
          return NotificationType.reward;
        case 'MISSION':
          return NotificationType.mission;
        case 'VERIFICATION':
        case 'NEEDS_INFO':
          return NotificationType.verification;
        default:
          return NotificationType.system;
      }
    }

    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: (json['message'] as String?) ?? (json['body'] as String?) ?? '',
      type: parse(json['type'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      read: (json['isRead'] as bool?) ?? (json['read'] as bool?) ?? (json['readAt'] != null),
      targetId: (json['entityId'] as String?) ?? (json['targetId'] as String?),
    );
  }
}


class VerificationInfo {
  final String status; // NOT_STARTED | PENDING | VERIFIED | REJECTED
  final String? rejectionReason;
  final DateTime? submittedAt;

  VerificationInfo({
    required this.status,
    this.rejectionReason,
    this.submittedAt,
  });

  factory VerificationInfo.fromJson(Map<String, dynamic> json) =>
      VerificationInfo(
        status: json['status'] as String? ?? 'NOT_STARTED',
        rejectionReason: json['rejectionReason'] as String?,
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'] as String)
            : null,
      );
}
