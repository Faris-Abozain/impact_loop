import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/notification_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';
import 'package:impact_loop/core/utils/uuid_utils.dart';

class VerificationRepository {
  VerificationRepository(this._api);

  final BaseApiConsumer _api;

  static VerificationInfo _mock = VerificationInfo(status: 'NOT_STARTED');

  Future<Either<Failure, VerificationInfo>> status() async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return Right(_mock);
    }
    try {
      final raw = await _api.get(EndPoints.verificationStatus);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(VerificationInfo.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, VerificationInfo>> submit({
    required String fullName,
    required String documentType,
    required String documentNumber,
    required String frontPath,
    String? backPath,
    required String selfiePath,
    String? idempotencyKey,
  }) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      _mock = VerificationInfo(status: 'PENDING', submittedAt: DateTime.now());
      return Right(_mock);
    }
    try {
      final raw = await _api.post(
        EndPoints.verificationSubmit,
        formDataIsEnabled: true,
        body: {
          'fullName': fullName,
          'documentType': documentType,
          'documentNumber': documentNumber,
          'front': await MultipartFile.fromFile(frontPath),
          if (backPath != null) 'back': await MultipartFile.fromFile(backPath),
          'selfie': await MultipartFile.fromFile(selfiePath),
        },
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey ?? UuidUtils.generateV4(),
          },
        ),
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(VerificationInfo.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getDetails() async {
    if (AppConfig.useMockApi) {
      return Right({
        'status': _mock.status,
        'submittedAt': _mock.submittedAt?.toIso8601String(),
        'reviewerNotes': _mock.rejectionReason,
      });
    }
    try {
      final raw = await _api.get(EndPoints.verificationDetails);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to get details'));
      }
      return Right(envelope.data!);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

