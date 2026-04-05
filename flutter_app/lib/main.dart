import 'package:aicar/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );

  // DEBUG: 카카오 키 해시 확인 (콘솔에 등록된 값과 비교)
  final keyHash = await KakaoSdk.origin;
  debugPrint('[Kakao] keyHash: $keyHash');

  runApp(
    const ProviderScope(
      child: AiCarApp(),
    ),
  );
}
