import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/models/submission_models.dart';
import 'package:impact_loop/core/models/wallet_models.dart';
import 'package:impact_loop/features/auth/data/missions_repository.dart';
import 'package:impact_loop/features/auth/data/submissions_repository.dart';
import 'package:impact_loop/features/auth/data/wallet_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._missionsRepo,
    this._submissionsRepo,
    this._walletRepo,
  ) : super(const HomeInitial());

  final MissionsRepository _missionsRepo;
  final SubmissionsRepository _submissionsRepo;
  final WalletRepository _walletRepo;

  Future<void> load() async {
    emit(const HomeLoading());

    final missionsResult = await _missionsRepo.listMissions();
    final submissionsResult = await _submissionsRepo.listMySubmissions();
    final impactResult = await _walletRepo.getImpact();

    final failure = _firstFailure([
      missionsResult,
      submissionsResult,
      impactResult,
    ]);
    if (failure != null) {
      emit(HomeFailure(failure.message));
      return;
    }

    final missions = missionsResult.getOrElse(() => throw StateError(''));
    final submissions = submissionsResult.getOrElse(() => throw StateError(''));
    final impact = impactResult.getOrElse(() => throw StateError(''));

    emit(HomeLoaded(
      recommended: missions.take(3).toList(),
      activeMissions: missions,
      pendingSubmissions: submissions
          .where((s) =>
              s.status == SubmissionStatus.pendingReview ||
              s.status == SubmissionStatus.needsInfo ||
              s.status == SubmissionStatus.pending)
          .toList(),
      impact: impact,
    ));
  }

  Failure? _firstFailure(List<Either<Failure, dynamic>> results) {
    for (final result in results) {
      Failure? failure;
      result.fold((l) => failure = l, (_) {});
      if (failure != null) return failure;
    }
    return null;
  }
}
