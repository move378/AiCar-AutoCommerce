import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  // Auth
  static const String login = '/api/v1/auth/login';
  static const String logout = '/api/v1/auth/logout';
  static const String refresh = '/api/v1/auth/refresh';
  static const String appleLogin = '/api/v1/auth/apple';
  static const String kakaoLogin = '/api/v1/auth/kakao';

  // Survey
  static const String survey = '/api/v1/surveys';

  // Vehicle
  static const String vehicles = '/api/v1/vehicles';
  static const String vehicleSearch = '/api/v1/vehicles/search';

  // AI Chat
  static const String chat = '/api/v1/chat';
  static const String chatStream = '/api/v1/chat/stream';

  // AI Card
  static const String cards = '/api/v1/cards';

  // Garage
  static const String garage = '/api/v1/garage';

  // Estimate
  static const String estimates = '/api/v1/estimates';

  // Promotion
  static const String promotions = '/api/v1/promotions';
}
