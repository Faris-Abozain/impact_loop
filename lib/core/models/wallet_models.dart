import 'impact_enums.dart';

class WalletTransaction {
  final String id;
  final WalletTransactionType type;
  final int amountPoints;
  final String? reason;
  final String? submissionId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amountPoints,
    this.reason,
    this.submissionId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    WalletTransactionType parseType(String raw) {
      switch (raw) {
        case 'REWARD':
          return WalletTransactionType.reward;
        case 'ADJUSTMENT':
          return WalletTransactionType.adjustment;
        case 'PENALTY':
          return WalletTransactionType.penalty;
        case 'WITHDRAWAL':
          return WalletTransactionType.withdrawal;
        default:
          return WalletTransactionType.adjustment;
      }
    }

    return WalletTransaction(
      id: json['id'] as String,
      type: parseType(json['type'] as String),
      amountPoints: json['amountPoints'] as int,
      reason: json['reason'] as String?,
      submissionId: json['submissionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class WalletSummary {
  final int balancePoints;
  final List<WalletTransaction> transactions;

  WalletSummary({
    required this.balancePoints,
    required this.transactions,
  });

  int get pendingPoints => transactions
      .where((t) => t.type == WalletTransactionType.reward && t.amountPoints > 0)
      .fold(0, (sum, t) => sum + t.amountPoints);

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
        balancePoints: json['balancePoints'] as int,
        transactions: (json['transactions'] as List<dynamic>? ?? [])
            .map((e) =>
                WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ImpactSummary {
  final int totalSubmissions;
  final int approvedSubmissions;
  final int rejectedSubmissions;
  final int pointsEarned;

  ImpactSummary({
    required this.totalSubmissions,
    required this.approvedSubmissions,
    required this.rejectedSubmissions,
    required this.pointsEarned,
  });

  factory ImpactSummary.fromJson(Map<String, dynamic> json) => ImpactSummary(
        totalSubmissions: json['totalSubmissions'] as int,
        approvedSubmissions: json['approvedSubmissions'] as int,
        rejectedSubmissions: json['rejectedSubmissions'] as int,
        pointsEarned: json['pointsEarned'] as int,
      );
}
