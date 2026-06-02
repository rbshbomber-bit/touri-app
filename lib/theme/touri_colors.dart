import 'package:flutter/material.dart';

/// 토우리 공식 컬러 팔레트 (캐릭터 시트 + 9컷 모음에서 추출).
/// BRAND.md 기준. 수정 금지 — 캐릭터 일러스트와 톤이 맞아야 함.
class TouriColors {
  TouriColors._();

  // ─── Primary ───────────────────────────────
  static const Color touriPink   = Color(0xFFFFB6C1);
  static const Color softPink    = Color(0xFFFFD1DC);
  static const Color cloudPink   = Color(0xFFFFE9EE);
  static const Color warmWhite   = Color(0xFFFFF8F5);
  static const Color mistPink    = Color(0xFFFFF1F6);
  static const Color cocoa       = Color(0xFF8E7A7A);
  static const Color cocoaDark   = Color(0xFF6B5A55);

  // ─── Secondary (장면별 강조) ────────────────
  static const Color bubble      = Color(0xFFFFD6E7);
  static const Color lavender    = Color(0xFFE8D6FF);
  static const Color lilac       = Color(0xFFEADCF9);
  static const Color mint        = Color(0xFFD6F5E3);
  static const Color cream       = Color(0xFFFFF6D6);
  static const Color sky         = Color(0xFFDCEBFF);

  // ─── Functional (UI 상태) ──────────────────
  static const Color paperLine   = Color(0xFFF4E0D2);
  static const Color paperBg     = Color(0xFFFFFCF6);
  static const Color shadowSoft  = Color(0x1AFFB6C1);
  static const Color dim         = Color(0xFFC2A8A0);
}
