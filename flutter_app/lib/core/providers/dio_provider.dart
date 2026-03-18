import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/core/errors/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(ref),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._ref);

  // ignore: unused_field
  final Ref _ref;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: tokenStorageProvider 연결 후 access token 주입
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      // TODO: refresh token 로직 추가
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
      return;
    }

    handler.next(err);
  }
}
