import '../config/app_config.dart';
import 'impact_enums.dart';

class MeProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final AppRole role;
  final List<AppRole> roles;
  final VerifiedStatus verifiedStatus;
  final String? avatarUrl;

  MeProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.roles,
    required this.verifiedStatus,
    this.avatarUrl,
  });

  bool get canAccessOps =>
      roles.any((r) => r.canAccessOps) && AppConfig.enableOpsPanel;

  factory MeProfile.fromJson(Map<String, dynamic> json) {
    VerifiedStatus parseVerified(String raw) {
      switch (raw) {
        case 'PENDING':
          return VerifiedStatus.pending;
        case 'VERIFIED':
          return VerifiedStatus.verified;
        case 'REJECTED':
          return VerifiedStatus.rejected;
        default:
          return VerifiedStatus.notRequired;
      }
    }

    return MeProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: AppRoleX.fromApi(json['role'] as String),
      roles: (json['roles'] as List<dynamic>)
          .map((e) => AppRoleX.fromApi(e as String))
          .toList(),
      verifiedStatus: parseVerified(json['verifiedStatus'] as String),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final MeProfile user;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userJson = data['user'] as Map<String, dynamic>;
    // Auth register/login returns User schema; map to MeProfile shape.
    final meJson = {
      ...userJson,
      'roles': userJson['roles'] ?? [userJson['role']],
      'verifiedStatus': userJson['verifiedStatus'] ?? 'NOT_REQUIRED',
    };
    return AuthSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: MeProfile.fromJson(meJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role.name.toUpperCase(),
          'roles': user.roles.map((r) => r.name.toUpperCase()).toList(),
          'verifiedStatus': _verifiedApi(user.verifiedStatus),
          'avatarUrl': user.avatarUrl,
        },
      };

  static String _verifiedApi(VerifiedStatus s) {
    switch (s) {
      case VerifiedStatus.pending:
        return 'PENDING';
      case VerifiedStatus.verified:
        return 'VERIFIED';
      case VerifiedStatus.rejected:
        return 'REJECTED';
      case VerifiedStatus.notRequired:
        return 'NOT_REQUIRED';
    }
  }
}
