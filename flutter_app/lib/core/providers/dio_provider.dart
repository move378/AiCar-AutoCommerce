import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/core/errors/app_exception.dart';
import 'package:aicar/data/dto/auth_dto.dart';
import 'package:aicar/data/services/secure_storage_service_impl.dart';
import 'package:aicar/domain/services/i_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TokenStorage provider — 기존 SecureStorageServiceImpl 재사용
final tokenStorageProvider = Provider<ITokenStorage>((ref) {
  return SecureStorageServiceImpl();
});

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final tokenStorage = ref.read(tokenStorageProvider);

  dio.interceptors.addAll([
    _AuthInterceptor(tokenStorage, dio),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenStorage, this._dio);

  final ITokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearAll();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(),
          ),
        );
        return;
      }

      // 토큰 갱신 — interceptor 우회를 위해 새 Dio 사용
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );

      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final tokens = TokenResponseDto.fromJson(data);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // 원래 요청 재시도
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _tokenStorage.clearAll();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
    } finally {
      _isRefreshing = false;
    }
  }
}
