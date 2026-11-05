import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:impact_loop/core/api/status_code.dart';
import 'package:impact_loop/core/error/exceptions.dart';
import 'package:impact_loop/core/preferences/preferences.dart';
import 'package:impact_loop/core/api/app_interceptors.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/injector.dart' as injector;

class DioConsumer implements BaseApiConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    _configureClient();
    _addInterceptors();
  }

  void _configureClient() {
    if (!kIsWeb) {
      (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    client.options
      ..baseUrl = EndPoints.baseUrl
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..receiveTimeout = const Duration(seconds: 15)
      ..connectTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..validateStatus = (status) {
        return status != null && status < StatusCode.internalServerError;
      };
  }


  void _addInterceptors() {
    client.interceptors.add(injector.serviceLocator<AppInterceptors>());
    if (kDebugMode) {
      client.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolvedOptions = await _resolveOptions(options);
    return _makeRequest(
      () async => client.get(
        path,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolvedOptions = await _resolveOptions(options);
    return _makeRequest(
      () async => client.post(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolvedOptions = await _resolveOptions(options);
    return _makeRequest(
      () async => client.put(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolvedOptions = await _resolveOptions(options);
    return _makeRequest(
      () async => client.patch(
        path,
        data: body,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    bool formDataIsEnabled = false,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final resolvedOptions = await _resolveOptions(options);
    return _makeRequest(
      () async => client.delete(
        path,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  Future<Options> _resolveOptions(Options? customOptions) async {
    final defaultOptions = await _getOptions();
    if (customOptions == null) {
      return defaultOptions;
    }
    return customOptions.copyWith(
      headers: {
        ...?defaultOptions.headers,
        ...?customOptions.headers,
      },
    );
  }

  Future<Options> _getOptions() async {
    final token = await _getToken();
    final lang = await Preferences.instance.getSavedLang();
    log('myToken=>$token');
    return Options(headers: {
      if (token != null) 'Authorization': token,
      'Connection': 'keep-alive',
      'Accept': '*/*',
      'Accept-Language': lang,
    });
  }

  Future<String?> _getToken() async {
    final session = await Preferences.instance.getSession();
    if (session == null) return null;
    final token = session.accessToken;
    if (token.startsWith('Bearer ')) return token;
    return 'Bearer $token';
  }

  Future<dynamic> _makeRequest(Future<Response> Function() request) async {
    try {
      client.options.baseUrl = EndPoints.baseUrl;
      final response = await request();
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioException(error);
    }
  }

  dynamic _handleResponseAsJson(Response<dynamic> response) {
    if (response.data != null) {
      return jsonDecode(response.data);
    } else {
      throw const FetchDataException();
    }
  }

  void _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const FetchDataException();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            throw const BadRequestException();
          case StatusCode.unautherized:
            throw const UnauthorizedException();
          case StatusCode.forbidden:
          case StatusCode.notFound:
            throw const NotFoundException();
          case StatusCode.conflict:
            throw const ConflictException();
          case StatusCode.internalServerError:
            throw const InternalServerErrorException();
          default:
            throw const FetchDataException();
        }
      case DioExceptionType.cancel:
        throw const FetchDataException();
      case DioExceptionType.unknown:
      default:
        throw const NoInternetConnectionException();
    }
  }
}
