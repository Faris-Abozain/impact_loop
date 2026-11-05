import 'package:dartz/dartz.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/submission_models.dart';
import 'package:impact_loop/core/models/wallet_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';

class AdminOpsRepository {
  AdminOpsRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, List<SubmissionDetail>>> listSubmissions({
    String? status,
    bool isOps = true,
  }) async {
    try {
      final endpoint = isOps ? EndPoints.opsSubmissions : EndPoints.adminSubmissions;
      final raw = await _api.get(
        endpoint,
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to list submissions'));
      }
      final items = (envelope.data!['submissions'] as List<dynamic>)
          .map((e) => SubmissionDetail.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> approveSubmission(
    String submissionId, {
    String? reasonCode,
    String? notes,
    bool isOps = true,
  }) async {
    try {
      final endpoint = isOps
          ? EndPoints.opsApprove(submissionId)
          : EndPoints.adminApprove(submissionId);
      final raw = await _api.post(
        endpoint,
        body: {
          if (reasonCode != null) 'reasonCode': reasonCode,
          if (notes != null) 'notes': notes,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Approval failed'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> rejectSubmission(
    String submissionId, {
    required String reasonCode,
    String? notes,
    bool isOps = true,
  }) async {
    try {
      final endpoint = isOps
          ? EndPoints.opsReject(submissionId)
          : EndPoints.adminReject(submissionId);
      final raw = await _api.post(
        endpoint,
        body: {
          'reasonCode': reasonCode,
          if (notes != null) 'notes': notes,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Rejection failed'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> requestInfo(
    String submissionId, {
    required String reasonCode,
    String? notes,
  }) async {
    try {
      final raw = await _api.post(
        EndPoints.opsRequestInfo(submissionId),
        body: {
          'reasonCode': reasonCode,
          if (notes != null) 'notes': notes,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Request info failed'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, WalletTransaction>> adjustWallet({
    required String userId,
    required String type, // ADJUSTMENT | PENALTY
    required int amountPoints,
    required String reason,
  }) async {
    try {
      final raw = await _api.post(
        EndPoints.adminWalletAdjust(userId),
        body: {
          'type': type,
          'amountPoints': amountPoints,
          'reason': reason,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Wallet adjustment failed'));
      }
      return Right(WalletTransaction.fromJson(
        envelope.data!['transaction'] as Map<String, dynamic>,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
