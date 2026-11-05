import 'package:dartz/dartz.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/campaign_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';

class CampaignsRepository {
  CampaignsRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, List<Campaign>>> listCampaigns({String? status}) async {
    try {
      final raw = await _api.get(
        EndPoints.campaigns,
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to list campaigns'));
      }
      final items = (envelope.data!['campaigns'] as List<dynamic>)
          .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Campaign>> getCampaign(String id) async {
    try {
      final raw = await _api.get(EndPoints.campaign(id));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Campaign not found'));
      }
      return Right(Campaign.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Campaign>> createCampaign(Map<String, dynamic> body) async {
    try {
      final raw = await _api.post(EndPoints.campaigns, body: body);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to create campaign'));
      }
      return Right(Campaign.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Campaign>> updateCampaignStatus(String id, String status) async {
    try {
      final raw = await _api.patch(
        EndPoints.campaignStatus(id),
        body: {'status': status},
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to update campaign status'));
      }
      return Right(Campaign.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCampaignSubmissions(String id, {String? status}) async {
    try {
      final raw = await _api.get(
        EndPoints.campaignSubmissions(id),
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Failed to get submissions'));
      }
      final subs = (envelope.data!['submissions'] as List<dynamic>)
          .map((e) => CampaignSubmissionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final metrics = envelope.data!['metrics'] != null
          ? CampaignMetrics.fromJson(envelope.data!['metrics'] as Map<String, dynamic>)
          : null;
      return Right({'submissions': subs, 'metrics': metrics});
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> exportSubmissionsCsv(String id) async {
    try {
      final raw = await _api.get(EndPoints.campaignSubmissionsExport(id));
      return Right(raw.toString());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
