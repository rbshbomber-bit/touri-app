import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import 'sticker_store_screen.dart';

/// Touri+ 구독 안내 모달. 풀스크린.
/// 5개 기능 + 가격 3종 + 평생회원.
class PremiumSheet extends StatelessWidget {
  const PremiumSheet({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TouriColors.warmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: TouriColors.softPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _Header(),
                    const SizedBox(height: 24),
                    _SectionLabel('이런 게 들어있어 ♡'),
                    const SizedBox(height: 10),
                    const _FeatureCard(
                      live: true,
                      title: '오늘의 토우리 일러스트',
                      subtitle: '월 50장 (현재 무료 3장/주)',
                      icon: Icons.auto_awesome,
                    ),
                    _FeatureCard(
                      live: true,
                      title: 'AI 매니페스테이션 코칭',
                      subtitle: '다정한 토우리가 1:1로 코칭 — 받아보기',
                      icon: Icons.psychology_alt_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        _toast(context, '매니페스테이션 카드의 ✦코칭 버튼을 눌러봐 ♡');
                      },
                    ),
                    _FeatureCard(
                      live: true,
                      title: '시즌 한정 스티커팩',
                      subtitle: '분기별 새 토우리 컬렉션 — 둘러보기',
                      icon: Icons.collections_bookmark_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StickerStoreScreen(),
                          ),
                        );
                      },
                    ),
                    const _FeatureCard(
                      live: false,
                      title: '커스텀 친구 토우리',
                      subtitle: '친구·반려동물도 토우리로 만들 수 있어',
                      icon: Icons.favorite_rounded,
                    ),
                    const _FeatureCard(
                      live: false,
                      title: '월간 PDF 책자',
                      subtitle: '한 달치 다이어리 인쇄 가능',
                      icon: Icons.menu_book_rounded,
                    ),

                    const SizedBox(height: 28),
                    _SectionLabel('내가 고를 수 있는 길'),
                    const SizedBox(height: 10),
                    const _PlanCard(
                      name: '무료',
                      price: '₩0',
                      period: '지금',
                      highlight: false,
                      lines: ['주 3장 일러스트', '모든 다이어리 기능', '로컬 저장'],
                    ),
                    const _PlanCard(
                      name: 'Touri Plus',
                      price: '₩4,900',
                      period: '/월',
                      highlight: true,
                      lines: ['월 50장 일러스트', 'AI 매니페스테이션 코칭 (출시 시)', '시즌 스티커팩'],
                    ),
                    const _PlanCard(
                      name: 'Touri Premium',
                      price: '₩9,900',
                      period: '/월',
                      highlight: false,
                      lines: ['무제한 일러스트', '커스텀 친구 토우리', '월간 PDF 책자'],
                    ),

                    const SizedBox(height: 16),
                    _LifetimeCard(onTap: () => _toast(context, '곧 출시 — 텀블벅 발사 알림 받기 ♡')),

                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Material(
                        color: const Color(0xFF7B5FB8),
                        shape: const StadiumBorder(),
                        elevation: 4,
                        shadowColor: const Color(0xFF7B5FB8).withOpacity(0.45),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => _toast(context, '곧 출시 — 텀블벅 발사 알림 받기 ♡'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                '구독하기 ✦',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        '괜찮아, 천천히 봐도 돼 ♡',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: TouriColors.dim,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD1DC), Color(0xFFEADCF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦ TOURI+',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7B5FB8),
                  fontSize: 12,
                  letterSpacing: 1.6,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '더 깊이 함께\n해줄래?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: TouriColors.cocoaDark,
                  fontSize: 28,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '주 3장으로는 부족할 때,\n토우리가 매일 너랑 함께 그릴게.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TouriColors.cocoaDark,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: TouriColors.cocoaDark,
            fontSize: 16,
          ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final bool live;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  const _FeatureCard({
    required this.live,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: live ? TouriColors.touriPink : TouriColors.cloudPink,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: live ? TouriColors.cloudPink : TouriColors.mistPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: live ? TouriColors.touriPink : TouriColors.dim,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TouriColors.cocoaDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: live
                            ? TouriColors.touriPink
                            : TouriColors.dim.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        live ? '작동 중' : '곧 출시',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: live ? Colors.white : TouriColors.dim,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TouriColors.cocoa,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: inner,
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final bool highlight;
  final List<String> lines;
  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.highlight,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: highlight ? TouriColors.cloudPink : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? TouriColors.touriPink : TouriColors.cloudPink,
          width: highlight ? 2 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: TouriColors.touriPink.withOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: highlight ? TouriColors.touriPink : TouriColors.cocoaDark,
                ),
              ),
              const Spacer(),
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: highlight ? TouriColors.touriPink : TouriColors.cocoaDark,
                ),
              ),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 12,
                  color: TouriColors.cocoa,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...lines.map((l) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    const Text('♡', style: TextStyle(color: TouriColors.touriPink, fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TouriColors.cocoa,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _LifetimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LifetimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF7B5FB8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            children: [
              const Text('✦', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '평생 회원',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '텀블벅 한정 · ₩299,000',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
