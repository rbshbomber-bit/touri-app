import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/touri_theme.dart';
import 'screens/main_shell_screen.dart';
import 'services/pet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env는 빌드에 자산으로 포함됨. 없거나 키가 비어도 앱은 동작 (서비스 쪽에서 fallback).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env 없어도 OK — 키 필요한 기능만 비활성.
  }
  // 토우리 키우기 상태 로드 + 출석 체크.
  await PetService.instance.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const TouriApp());
}

class TouriApp extends StatelessWidget {
  const TouriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '토우리',
      debugShowCheckedModeBanner: false,
      theme: TouriTheme.light.copyWith(
        // 모든 플랫폼에 iOS 스타일 뒤로가기 전환 + 좌측 엣지 스와이프 적용
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainShellScreen(),
    );
  }
}
