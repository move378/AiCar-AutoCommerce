import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  // Auth
  static const String onboard = '/api/v1/auth/onboard';
  static const String onboardRefresh = '/api/v1/auth/onboard/refresh';
  static const String kakaoLogin = '/api/v1/auth/kakao-login';
  static const String googleLogin = '/api/v1/auth/google-login';
  static const String appleLogin = '/api/v1/auth/apple-login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String marketingConsent = '/api/v1/auth/agreed';

  // User
  static const String logout = '/api/v1/user/logout';
  static const String profile = '/api/v1/user/me';

  // Cars (카탈로그)
  static const String cars = '/api/v1/cars';
  static String carDetail(String id) => '/api/v1/cars/$id';
  static String carImages(String id) => '/api/v1/cars/$id/images';

  // Brands
  static const String brands = '/api/v1/brands';

  // MyCar
  static const String registerCar = '/api/v1/cars/register';
  static String myCars(String userId) => '/api/v1/cars/register/$userId';

  // Chat
  static const String chatSessions = '/api/v1/chat/sessions';
  static String chatSession(String id) => '/api/v1/chat/sessions/$id';
  static String chatMessages(String sessionId) =>
      '/api/v1/chat/sessions/$sessionId/messages';
  static String chatFeedback(String messageId) =>
      '/api/v1/chat/messages/$messageId/feedback';
}
