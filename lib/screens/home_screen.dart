import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';

/// Day 1 확인용 홈 화면.
/// 색·폰트·이미지가 제대로 로드되는지만 보여줌.
/// Day 2에 진짜 DiaryScreen으로 교체 예정.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 로고 ─────────────────────────────────
              Text('토우리', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(
                'TOURI · v0.1',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 24),

              // ─── 캐릭터 메인 일러스트 ────────────────
              _CharacterCard(),
              const SizedBox(height: 24),

              // ─── 손글씨 폰트 샘플 ─────────────────────
              _SectionTitle(title: '손글씨 폰트 (다이어리 본문용)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TouriColors.paperBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TouriColors.paperLine),
                ),
                child: Text(
                  '오늘은 마음이 가벼웠다.\n토우리랑 같이 적는 일기는\n진짜 친구가 옆에 있는 것 같아.',
                  style: TouriTheme.handwriting(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // ─── 컬러 팔레트 ─────────────────────────
              _SectionTitle(title: '공식 컬러 팔레트'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Swatch(name: 'touriPink', color: TouriColors.touriPink),
                  _Swatch(name: 'softPink', color: TouriColors.softPink),
                  _Swatch(name: 'cloudPink', color: TouriColors.cloudPink),
                  _Swatch(name: 'warmWhite', color: TouriColors.warmWhite),
                  _Swatch(name: 'lavender', color: TouriColors.lavender),
                  _Swatch(name: 'mint', color: TouriColors.mint),
                  _Swatch(name: 'cream', color: TouriColors.cream),
                  _Swatch(name: 'sky', color: TouriColors.sky),
                  _Swatch(name: 'lilac', color: TouriColors.lilac),
                  _Swatch(name: 'bubble', color: TouriColors.bubble),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Day 1 완료 메시지 ───────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TouriColors.cloudPink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day 1 완료 ✦',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: TouriColors.touriPink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flutter 셋업 + 테마 시스템 + 캐릭터 자산 로드 확인됨.\n'
                      'Day 2: 메인 다이어리 화면으로 교체할 거예요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/character/scenes/character_sheet.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: TouriColors.cloudPink,
                child: const Center(
                  child: Text('이미지 로드 실패 (assets 경로 확인)'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"언제나 네 편이에요"',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '네 하루를 더 예쁘고 의미있게 만들어주는 따뜻한 다이어리 친구',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              color: TouriColors.cocoa,
            ),
          ),
        ],
      ),
    );
  }
}
