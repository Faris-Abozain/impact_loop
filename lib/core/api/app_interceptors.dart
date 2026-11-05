
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/routes/app_routes.dart';
import '../../core/notification_services/notification_service.dart';
import '../preferences/preferences.dart';
import '../utils/app_strings.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is! FormData) {
      options.headers[AppStrings.contentType] = AppStrings.applicationJson;
    }
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);

    final path = response.requestOptions.path;
    final isAuthEndpoint =
        path.contains('auth/login') || path.contains('auth/register');

    if (response.statusCode == 401 && !isAuthEndpoint) {
      Preferences.instance.clearUser().then((value) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.initialRoute,
          (route) => false,
        );
      });
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path.contains('auth/login') || path.contains('auth/register');

    if ((statusCode == 401 || statusCode == 407) && !isAuthEndpoint) {
      Preferences.instance.clearUser().then((value) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.initialRoute,
          (route) => false,
        );
      });
    }

    super.onError(err, handler);
  }
}

