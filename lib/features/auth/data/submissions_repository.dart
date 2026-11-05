import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/data/mock_impact_data.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/models/submission_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';
import 'package:impact_loop/core/utils/uuid_utils.dart';

class SubmissionsRepository {
  SubmissionsRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, List<MySubmissionItem>>> listMySubmissions({
    SubmissionStatus? status,
  }) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      var list = MockImpactData.mySubmissions;
      if (status != null) {
        list = list.where((s) => s.status == status).toList();
      }
      return Right(list);
    }

    try {
      final raw = await _api.get(
        EndPoints.submissions,
        queryParameters: {
          if (status != null) 'status': status.apiValue,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final items = (envelope.data!['submissions'] as List<dynamic>)
          .map((e) => MySubmissionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Creates a proof submission for [taskId] and returns the new item.
  Future<Either<Failure, MySubmissionItem>> createSubmission({
    required String taskId,
    required String campaignId,
    required List<String> mediaPaths,
    String? note,
    double? lat,
    double? lng,
    String? idempotencyKey,
  }) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final item = MySubmissionItem(
        id: 's${DateTime.now().millisecondsSinceEpoch}',
        taskId: taskId,
        campaignId: campaignId,
        status: SubmissionStatus.pendingReview,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      MockImpactData.mySubmissions = [item, ...MockImpactData.mySubmissions];
      return Right(item);
    }

    try {
      final form = <String, dynamic>{
        if (note != null && note.isNotEmpty) 'note': note,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'files': [
          for (final p in mediaPaths) await MultipartFile.fromFile(p),
        ],
      };
      final key = idempotencyKey ?? UuidUtils.generateV4();
      final raw = await _api.post(
        EndPoints.taskSubmit(taskId),
        body: form,
        formDataIsEnabled: true,
        options: Options(
          headers: {
            'Idempotency-Key': key,
          },
        ),
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final data = envelope.data!;
      final id = (data['submissionId'] ?? data['id'] ?? 's-${DateTime.now().millisecondsSinceEpoch}') as String;
      final statusStr = (data['status'] ?? 'PENDING_REVIEW') as String;
      return Right(MySubmissionItem(
        id: id,
        taskId: taskId,
        campaignId: campaignId,
        status: SubmissionStatusX.fromApi(statusStr),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> createDraft({
    required String taskId,
    required double lat,
    required double lng,
    String? note,
    String? idempotencyKey,
  }) async {
    if (AppConfig.useMockApi) {
      return Right('draft-${DateTime.now().millisecondsSinceEpoch}');
    }
    try {
      final key = idempotencyKey ?? UuidUtils.generateV4();
      final raw = await _api.post(
        EndPoints.submissions,
        body: {
          'taskId': taskId,
          'lat': lat,
          'lng': lng,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: {
            'Idempotency-Key': key,
          },
        ),
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(envelope.data!['submissionId'] as String);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, SubmissionDetail>> updateDraft({
    required String submissionId,
    double? lat,
    double? lng,
    String? note,
  }) async {
    try {
      final raw = await _api.patch(
        EndPoints.submission(submissionId),
        body: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (note != null) 'note': note,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(SubmissionDetail.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> submitDraft({
    required String submissionId,
    required List<String> mediaPaths,
    String? note,
    double? lat,
    double? lng,
    String? idempotencyKey,
  }) async {
    try {
      final form = <String, dynamic>{
        if (note != null) 'note': note,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'files': [
          for (final p in mediaPaths) await MultipartFile.fromFile(p),
        ],
      };
      final key = idempotencyKey ?? UuidUtils.generateV4();
      final raw = await _api.post(
        EndPoints.submissionSubmit(submissionId),
        body: form,
        formDataIsEnabled: true,
        options: Options(
          headers: {
            'Idempotency-Key': key,
          },
        ),
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(envelope.data!['submissionId'] as String);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, SubmissionDetail>> getSubmission(String id) async {
    if (AppConfig.useMockApi) {
      return Right(MockImpactData.submissionDetail(id));
    }

    try {
      final raw = await _api.get(EndPoints.submission(id));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(SubmissionDetail.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

