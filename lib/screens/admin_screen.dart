import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';
import '../widgets/touri_motion.dart';
import 'pixel_touri_lab_screen.dart';

/// 관리자 페이지 — 변승환 본인만 사용.
/// 일반 사용자 메뉴에는 안 보임. 메뉴 헤더 "메뉴" 7번 빠르게 탭하면 진입.
///
/// 포함:
/// - 도트 토우리 랩 (touri-pixel LoRA 생성)
/// - 자산 통계
/// - LoRA URL 확인
/// - 향후: 사용량 / 매출 통계 / 학습 트리거
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? _pixelLoraUrl;
  String? _waterLoraUrl;
  bool _loadingLora = true;

  @override
  void initState() {
    super.initState();
    _loadLoraUrls();
  }

  Future<void> _loadLoraUrls() async {
    try {
      final p = await rootBundle.loadString('touri_pixel_lora_url.txt');
      final w = await rootBundle.loadString('touri_lora_url.txt');
      if (!mounted) return;
      setState(() {
        _pixelLoraUrl = p.trim().isEmpty ? null : p.trim();
        _waterLoraUrl = w.trim().isEmpty ? null : w.trim();
        _loadingLora = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLora = false);
    }
  }

  void _openPixelLab() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PixelTouriLabScreen()),
    );
  }

  String _shortenUrl(String? url) {
    if (url == null) return '없음';
    if (url.length < 30) return url;
    return '${url.substring(0, 25)}...${url.substring(url.length - 15)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(
        title: '관리자 🔧',
        subtitle: '변승환 전용 — 도구 / 통계',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // ── 도구 섹션 ──
            const _SectionTitle('🛠️ 도구'),
            _AdminCard(
              emoji: '🎨',
              title: '도트 토우리 랩',
              subtitle: 'touri-pixel LoRA · 무한 도트 생성',
              accent: TouriColors.bubble,
              onTap: _openPixelLab,
            ),
            _AdminCard(
              emoji: '🌊',
              title: '워터컬러 토우리 랩',
              subtitle: 'touri-bunny LoRA · 다이어리 일러스트',
              accent: TouriColors.lilac,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('다이어리 → 그려줘 버튼으로 동일 기능 사용 가능'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // ── LoRA URL 상태 ──
            const _SectionTitle('🧬 LoRA 상태'),
            _StatusRow(
              label: 'touri-pixel (도트)',
              value: _loadingLora ? '로딩 중...' : _shortenUrl(_pixelLoraUrl),
              ok: _pixelLoraUrl != null,
            ),
            _StatusRow(
              label: 'touri-bunny (워터컬러)',
              value: _loadingLora ? '로딩 중...' : _shortenUrl(_waterLoraUrl),
              ok: _waterLoraUrl != null,
            ),

            const SizedBox(height: 18),

            // ── 향후 슬롯 ──
            const _SectionTitle('📊 향후 추가'),
            const _PlaceholderCard(
              emoji: '💰',
              title: '매출 / 사용량 통계',
              note: 'Supabase 마이그 후',
            ),
            const _PlaceholderCard(
              emoji: '🔄',
              title: 'LoRA 재학습 트리거',
              note: '새 학습 데이터 자동 업로드',
            ),
            const _PlaceholderCard(
              emoji: '🗂️',
              title: '이미지 자산 매니저',
              note: '메뉴/뉴스/시즌팩 자산 일괄 교체',
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                '🔒 일반 사용자에게 노출 X\n메뉴 헤더 7번 탭 → 진입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: TouriColors.cocoaDark.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: TouriColors.cocoaDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  const _AdminCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TapBounce(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: TouriColors.cocoaDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: TouriColors.cocoaDark.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: TouriColors.cocoaDark.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;
  const _StatusRow({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              ok ? '✅' : '⚠️',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: TouriColors.cocoaDark,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: TouriColors.cocoaDark.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String note;
  const _PlaceholderCard({
    required this.emoji,
    required this.title,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TouriColors.cocoaDark.withOpacity(0.15),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: 0.5,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TouriColors.cocoaDark.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 10,
                      color: TouriColors.cocoaDark.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TouriColors.cocoaDark.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '예정',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TouriColors.cocoaDark.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
