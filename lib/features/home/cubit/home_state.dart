part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.recommended,
    required this.activeMissions,
    required this.pendingSubmissions,
    required this.impact,
  });

  final List<MissionSummary> recommended;
  final List<MissionSummary> activeMissions;
  final List<MySubmissionItem> pendingSubmissions;
  final ImpactSummary impact;

  @override
  List<Object?> get props =>
      [recommended.length, activeMissions.length, pendingSubmissions.length];
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
