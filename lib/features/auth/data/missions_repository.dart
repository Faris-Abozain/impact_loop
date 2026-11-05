import 'package:dartz/dartz.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/data/mock_impact_data.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';

class MissionsRepository {
  MissionsRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, List<MissionSummary>>> listMissions({
    String? query,
    double? lat,
    double? lng,
  }) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      var list = MockImpactData.missions;
      if (query != null && query.isNotEmpty) {
        list = list
            .where((m) =>
                m.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return Right(list);
    }

    try {
      final raw = await _api.get(
        EndPoints.missions,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final missions = (envelope.data!['missions'] as List<dynamic>)
          .map((e) => MissionSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(missions);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, MissionSummary>> getMission(String id) async {
    if (AppConfig.useMockApi) {
      return Right(
        MockImpactData.missions.firstWhere((m) => m.id == id),
      );
    }

    try {
      final raw = await _api.get(EndPoints.mission(id));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(MissionSummary.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<MissionTaskItem>>> listMissionTasks(
    String missionId,
  ) async {
    if (AppConfig.useMockApi) {
      return Right(List.generate(3, (i) => MockImpactData.taskForMission(missionId, i)));
    }

    try {
      final raw = await _api.get(EndPoints.missionTasks(missionId));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final tasks = (envelope.data!['tasks'] as List<dynamic>)
          .map((e) => MissionTaskItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, TaskDetail>> getTask(String taskId) async {
    if (AppConfig.useMockApi) {
      final parts = taskId.split('-');
      final missionId = parts.length >= 2 ? parts[1] : 'm1';
      final index = parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0;
      final item = MockImpactData.taskForMission(missionId, index);
      return Right(
        TaskDetail(
          id: item.id,
          campaignId: item.campaignId,
          type: item.type,
          title: item.title,
          instructions: item.instructions,
          location: item.location,
          radiusMeters: item.radiusMeters,
          rewardPoints: item.rewardPoints,
          status: item.status,
          expiresAt: item.expiresAt,
        ),
      );
    }

    try {
      final raw = await _api.get(EndPoints.task(taskId));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(TaskDetail.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<MissionTaskItem>>> getNearbyTasks({
    double lat = 24.7136,
    double lng = 46.6753,
    double radiusKm = 5.0,
    String? type,
  }) async {
    if (AppConfig.useMockApi) {
      return Right(List.generate(4, (i) => MockImpactData.taskForMission('m1', i)));
    }
    try {
      final raw = await _api.get(
        EndPoints.tasksNearby,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radiusKm': radiusKm,
          if (type != null) 'type': type,
        },
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final tasks = (envelope.data!['tasks'] as List<dynamic>)
          .map((e) => MissionTaskItem(
                id: e['id'] as String,
                campaignId: (e['campaignId'] as String?) ?? 'm1',
                type: (e['type'] as String?) ?? 'DUMPING_REPORT',
                title: e['title'] as String,
                instructions: (e['instructions'] as String?) ?? '',
                location: LatLng(lat: lat, lng: lng),
                radiusMeters: (e['radiusMeters'] as int?) ?? 500,
                rewardPoints: (e['rewardPoints'] as int?) ?? 50,
                status: (e['status'] as String?) ?? 'OPEN',
                distanceMeters: (e['distanceMeters'] as num?)?.toDouble(),
              ))
          .toList();
      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> reserveTask(String taskId) async {
    if (AppConfig.useMockApi) {
      return Right(DateTime.now().add(const Duration(hours: 2)).toIso8601String());
    }
    try {
      final raw = await _api.post(EndPoints.taskReserve(taskId));
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Reservation failed'));
      }
      return Right(envelope.data!['reservedUntil'] as String);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

