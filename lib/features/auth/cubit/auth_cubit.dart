import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impact_loop/core/models/user_models.dart';
import 'package:impact_loop/features/auth/data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepository _repo;

  Future<void> restoreSession() async {
    emit(const AuthLoading());
    final session = await _repo.restoreSession();
    if (session == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(session.user));
  }

  Future<void> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    emit(const AuthLoading());
    final result = await _repo.login(
      password: password,
      email: email,
      phone: phone,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthAuthenticated(session.user)),
    );
  }

  Future<void> register({
    required String name,
    required String password,
    String? email,
    String? phone,
  }) async {
    emit(const AuthLoading());
    final result = await _repo.register(
      name: name,
      password: password,
      email: email,
      phone: phone,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (session) => emit(AuthAuthenticated(session.user)),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthUnauthenticated());
  }
}
