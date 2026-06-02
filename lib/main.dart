import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/touri_theme.dart';
import 'screens/diary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: TouriTheme.light,
      home: const DiaryScreen(),
    );
  }
}
