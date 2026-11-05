enum AppRole { user, client, admin }

enum SubmissionStatus {
  draft,
  pending,
  pendingReview,
  needsInfo,
  approved,
  rejected,
  flagged,
}

enum TaskType { dumpingReport, recyclingDropoff, publicTransport }

enum TaskStatus { open, reserved, completed, expired, disabled }

enum VerifiedStatus { notRequired, pending, verified, rejected }

enum WalletTransactionType { reward, adjustment, penalty, withdrawal }

extension SubmissionStatusX on SubmissionStatus {
  String get apiValue {
    switch (this) {
      case SubmissionStatus.draft:
        return 'DRAFT';
      case SubmissionStatus.pending:
        return 'PENDING';
      case SubmissionStatus.pendingReview:
        return 'PENDING_REVIEW';
      case SubmissionStatus.needsInfo:
        return 'NEEDS_INFO';
      case SubmissionStatus.approved:
        return 'APPROVED';
      case SubmissionStatus.rejected:
        return 'REJECTED';
      case SubmissionStatus.flagged:
        return 'FLAGGED';
    }
  }

  static SubmissionStatus fromApi(String value) {
    switch (value) {
      case 'DRAFT':
        return SubmissionStatus.draft;
      case 'PENDING':
        return SubmissionStatus.pending;
      case 'PENDING_REVIEW':
        return SubmissionStatus.pendingReview;
      case 'NEEDS_INFO':
        return SubmissionStatus.needsInfo;
      case 'APPROVED':
        return SubmissionStatus.approved;
      case 'REJECTED':
        return SubmissionStatus.rejected;
      case 'FLAGGED':
        return SubmissionStatus.flagged;
      default:
        return SubmissionStatus.pending;
    }
  }
}

extension AppRoleX on AppRole {
  static AppRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return AppRole.admin;
      case 'CLIENT':
        return AppRole.client;
      default:
        return AppRole.user;
    }
  }

  bool get canAccessOps => this == AppRole.admin;
}
