import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'touri_colors.dart';

/// 토우리 앱 전역 테마. Material 3 기반.
/// 폰트: Gaegu (로고·헤더), Nanum Pen Script (손글씨), Noto Sans KR (본문).
class TouriTheme {
  TouriTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: TouriColors.touriPink,
        brightness: Brightness.light,
        primary: TouriColors.touriPink,
        onPrimary: Colors.white,
        secondary: TouriColors.lavender,
        surface: TouriColors.warmWhite,
        onSurface: TouriColors.cocoa,
        surfaceContainerHighest: TouriColors.cloudPink,
      ),
      scaffoldBackgroundColor: TouriColors.warmWhite,
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: TouriColors.warmWhite,
        foregroundColor: TouriColors.cocoaDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: TouriColors.cloudPink, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: TouriColors.cocoa),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // 큰 헤더 (로고, 타이틀 카드)
      displayLarge: GoogleFonts.gaegu(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: TouriColors.cocoaDark,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.gaegu(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: TouriColors.cocoaDark,
        height: 1.2,
      ),

      // 화면 타이틀
      headlineMedium: GoogleFonts.gaegu(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: TouriColors.cocoaDark,
      ),

      // 카드/섹션 타이틀
      titleLarge: GoogleFonts.notoSansKr(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: TouriColors.cocoaDark,
      ),
      titleMedium: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: TouriColors.cocoaDark,
      ),

      // 본문
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: TouriColors.cocoa,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: TouriColors.cocoa,
        height: 1.55,
      ),

      // 라벨 (작은 메타 텍스트)
      labelLarge: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: TouriColors.touriPink,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.notoSansKr(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TouriColors.dim,
        letterSpacing: 0.8,
      ),
    );
  }

  /// 손글씨 일기체 (다이어리 본문에만 사용).
  static TextStyle handwriting({
    double fontSize = 17,
    Color color = TouriColors.cocoaDark,
  }) {
    return GoogleFonts.nanumPenScript(
      fontSize: fontSize,
      color: color,
      height: 1.7,
    );
  }
}
