import 'package:dartz/dartz.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/data/mock_impact_data.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/models/user_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';
import 'package:impact_loop/core/preferences/preferences.dart';

class AuthRepository {
  AuthRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, AuthSession>> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    if (AppConfig.useMockApi) {
      final session = AuthSession(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        user: email?.contains('admin') == true
            ? MockImpactData.adminUser
            : MockImpactData.demoUser,
      );
      await Preferences.instance.setSession(session);
      return Right(session);
    }

    try {
      final body = <String, dynamic>{'password': password};
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;

      final raw = await _api.post(EndPoints.authLogin, body: body);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Login failed'));
      }
      final session = AuthSession.fromJson({'data': envelope.data});
      await Preferences.instance.setSession(session);
      return Right(session);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String password,
    String? email,
    String? phone,
  }) async {
    if (AppConfig.useMockApi) {
      final session = AuthSession(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        user: MeProfile(
          id: MockImpactData.demoUser.id,
          name: name,
          email: email,
          phone: phone,
          role: AppRole.user,
          roles: [AppRole.user],
          verifiedStatus: VerifiedStatus.notRequired,
        ),
      );
      await Preferences.instance.setSession(session);
      return Right(session);
    }

    try {
      final body = <String, dynamic>{'name': name, 'password': password};
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;

      final raw = await _api.post(EndPoints.authRegister, body: body);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(
          ServerFailure(message: envelope.error?.message ?? 'Register failed'),
        );
      }
      final session = AuthSession.fromJson({'data': envelope.data});
      await Preferences.instance.setSession(session);
      return Right(session);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<AuthSession?> restoreSession() => Preferences.instance.getSession();

  Future<Either<Failure, MeProfile>> fetchMe() async {
    if (AppConfig.useMockApi) {
      final session = await Preferences.instance.getSession();
      if (session == null) {
        return Left(ServerFailure(message: 'Not authenticated'));
      }
      return Right(session.user);
    }

    try {
      final raw = await _api.get(EndPoints.me);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed'));
      }
      return Right(MeProfile.fromJson(envelope.data!));
    } catch (e) {
      final session = await Preferences.instance.getSession();
      if (session != null) return Right(session.user);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthSession>> refreshTokens() async {
    final session = await Preferences.instance.getSession();
    if (session == null) {
      return Left(ServerFailure(message: 'No active session'));
    }
    if (AppConfig.useMockApi) {
      return Right(session);
    }
    try {
      final raw = await _api.post(
        EndPoints.authRefresh,
        body: {'refreshToken': session.refreshToken},
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Refresh failed'));
      }
      final newSession = AuthSession.fromJson({'data': envelope.data});
      await Preferences.instance.setSession(newSession);
      return Right(newSession);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<bool> checkHealth() async {
    try {
      final raw = await _api.get(EndPoints.health);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      return envelope.success;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final session = await Preferences.instance.getSession();
    if (session != null && !AppConfig.useMockApi) {
      try {
        await _api.post(
          EndPoints.authLogout,
          body: {'refreshToken': session.refreshToken},
        );
      } catch (_) {}
    }
    await Preferences.instance.clearUser();
  }
}

