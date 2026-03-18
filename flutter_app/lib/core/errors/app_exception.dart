sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 네트워크/서버 오류
final class ServerException extends AppException {
  const ServerException({required this.statusCode, required String message})
      : super(message);
  final int statusCode;
}

/// 인증 오류 (401)
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = '인증이 필요합니다.']);
}

/// 인증되지 않은 상태
final class NotAuthenticatedException extends AppException {
  const NotAuthenticatedException([super.message = '로그인이 필요합니다.']);
}

/// 네트워크 연결 오류
final class NetworkException extends AppException {
  const NetworkException([super.message = '네트워크 연결을 확인해주세요.']);
}

/// 캐시/로컬 저장소 오류
final class CacheException extends AppException {
  const CacheException([super.message = '데이터를 불러오는데 실패했습니다.']);
}

/// 예상치 못한 오류
final class UnexpectedException extends AppException {
  const UnexpectedException([super.message = '알 수 없는 오류가 발생했습니다.']);
}
