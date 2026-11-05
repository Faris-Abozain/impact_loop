import '../../../core/exports.dart';

class LoginRepo {
  BaseApiConsumer dio;
  LoginRepo(this.dio);
  Future<Either<Failure, LoginModel>> login(
      String phone, String phoneCode, String name) async {
    try {
      var response = await dio.post(
        EndPoints.loginUrl,
        body: {'phone': phone, 'phone_code': phoneCode, 'name': name},
      );
      return Right(LoginModel.fromJson(response));
    } catch(e) {
      return Left(ServerFailure(message:e.toString() ));
    }
  }
}
