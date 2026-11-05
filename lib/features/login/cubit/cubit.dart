import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/login_repo.dart';
import 'state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.api) : super(LoginStateInitial());
  LoginRepo api;

}
