import 'package:dio/dio.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/features/auth/cubit/auth_cubit.dart';
import 'package:impact_loop/features/auth/data/auth_repository.dart';
import 'package:impact_loop/features/auth/data/missions_repository.dart';
import 'package:impact_loop/features/auth/data/submissions_repository.dart';
import 'package:impact_loop/features/auth/data/wallet_repository.dart';
import 'package:impact_loop/features/home/cubit/home_cubit.dart';
import 'package:impact_loop/features/login/cubit/cubit.dart';
import 'package:impact_loop/features/login/data/login_repo.dart';
import 'package:impact_loop/features/notifications/data/notifications_repository.dart';
import 'package:impact_loop/features/splash/cubit/cubit.dart';
import 'package:impact_loop/features/verification/data/verification_repository.dart';
import 'package:impact_loop/features/explore/data/campaigns_repository.dart';
import 'package:impact_loop/features/profile/data/admin_ops_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/base_api_consumer.dart';
import 'core/api/dio_consumer.dart';

final serviceLocator = GetIt.instance;
Future<void> setupCubit() async {
  serviceLocator.registerFactory(() => SplashCubit());

  serviceLocator.registerFactory(
    () => LoginCubit(
      serviceLocator(),
    ),
  );
  // serviceLocator.registerFactory(
  //   () => MainCubit(
  //     serviceLocator(),
  //   ),
  // );

  // Impact Loop
  serviceLocator.registerLazySingleton(() => AuthCubit(serviceLocator()));
  serviceLocator.registerFactory(
    () => HomeCubit(serviceLocator(), serviceLocator(), serviceLocator()),
  );
}

Future<void> setupRepo() async {
  serviceLocator.registerLazySingleton(() => LoginRepo(serviceLocator()));

  // Impact Loop
  serviceLocator.registerLazySingleton(() => AuthRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => MissionsRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => SubmissionsRepository(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WalletRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => NotificationsRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => VerificationRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => CampaignsRepository(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => AdminOpsRepository(serviceLocator()));
}


Future<void> setupDependencyInjection() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  ///! (dio)
  serviceLocator.registerLazySingleton<BaseApiConsumer>(
      () => DioConsumer(client: serviceLocator()));
  serviceLocator.registerLazySingleton(() => AppInterceptors());

  // Dio
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    ),
  );
}
