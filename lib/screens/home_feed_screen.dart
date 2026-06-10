import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../models/touri_entry.dart';
import '../models/touri_mood.dart';
import '../services/touri_storage.dart';
import '../services/checklist_service.dart';
import '../widgets/spirituality/affirmation_card.dart';
import '../widgets/pet_status_card.dart';
import '../widgets/touri_motion.dart';
import 'manifest_screen.dart';
import 'spirituality_screen.dart';
import 'pet_care_screen.dart';

/// 새 홈 — 카드 피드.
/// 헤더(인사+아바타) → 오늘의 뉴스(메인) → Affirmation → 영성 진행률
/// → 카테고리 칩 → 오늘 부르는 미래(맨 아래).
/// 들어오자마자 뉴스가 첫인상.
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TouriStorage _storage = TouriStorage();
  late final String _dateKey;
  TouriEntry _entry =
      const TouriEntry(dateKey: '', mood: TouriMood.secretary);

  @override
  void initState() {
    super.initState();
    _dateKey = TouriStorage.dateKeyFor(DateTime.now());
    _load();
    ChecklistService.instance.load();
  }

  Future<void> _load() async {
    final e = await _storage.load(_dateKey);
    if (!mounted) return;
    setState(() => _entry = e);
  }

  Future<void> _openManifest() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ManifestScreen(initialText: _entry.manifestation),
      ),
    );
    if (result == null) return;
    final next = _entry.copyWith(manifestation: result);
    await _storage.save(next);
    if (!mounted) return;
    setState(() => _entry = next);
  }

  void _openSpirituality() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpiritualityScreen()),
    );
  }

  void _openPetCare() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PetCareScreen()),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      body: SafeArea(
        child: RefreshIndicator(
          color: TouriColors.touriPink,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _GreetingHeader(mood: _entry.mood),
              const SizedBox(height: 12),
              // ── 토우리 키우기 상태창 ──
              PetStatusCard(onTap: _openPetCare),
              const SizedBox(height: 14),
              // ── 오늘의 뉴스 (메인) ──
              _NewsSection(onTapMock: (label) => _toast('$label — 곧 인앱 뉴스로 ♡')),
              const SizedBox(height: 14),
              _CategoryChips(onTap: (label) => _toast('$label 카테고리 — 곧 출시 ♡')),
              const SizedBox(height: 18),
              // ── 마음 살피기 ──
              const AffirmationCard(),
              const SizedBox(height: 14),
              _ChecklistProgress(onTap: _openSpirituality),
              const SizedBox(height: 14),
              // ── 오늘 부르는 미래 (맨 아래) ──
              _ManifestPreview(
                text: _entry.manifestation,
                onTap: _openManifest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 헤더 ─────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final TouriMood mood;
  const _GreetingHeader({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedTouriAvatar(
          float: true,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: TouriColors.touriPink.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(mood.avatarPath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕 ✦',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TouriColors.touriPink,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '오늘도 함께해',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: TouriColors.cocoaDark,
                      fontSize: 22,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 오늘의 manifestation ─────────────────────────
class _ManifestPreview extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ManifestPreview({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final firstLine = text.trim().split('\n').firstOrNull?.trim() ?? '';
    final has = firstLine.isNotEmpty;
    return Material(
      color: TouriColors.lilac.withOpacity(0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TouriColors.lavender, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✦', style: TextStyle(fontSize: 16, color: Color(0xFF7B5FB8))),
                  const SizedBox(width: 6),
                  Text(
                    '오늘 부르는 미래',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF7B5FB8),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    has ? Icons.edit_rounded : Icons.add_rounded,
                    color: const Color(0xFF7B5FB8),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                has ? firstLine : '한 줄 적어볼까? 토우리가 같이 부를게',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TouriTheme.handwriting(
                  fontSize: 17,
                  color: has ? TouriColors.cocoaDark : TouriColors.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 뉴스 섹션 (placeholder) ──────────────────────
class _NewsSection extends StatelessWidget {
  final void Function(String) onTapMock;
  const _NewsSection({required this.onTapMock});

  static const _mock = <_MockNews>[
    _MockNews(
      title: '캐릭터 굿즈 시장, MZ 여성 중심 확산',
      summary: '아기자기한 캐릭터 IP 굿즈가 다이어리·문구를 넘어 라이프 영역으로 확장 중.',
      category: '라이프',
      dot: TouriColors.touriPink,
      thumb: 'assets/character/news_categories/life.png',
    ),
    _MockNews(
      title: '명상·manifestation 앱 유저 급증',
      summary: '심리 안정과 자기 돌봄 루틴에 대한 수요가 20-30대 사이에서 두드러져.',
      category: 'Manifest',
      dot: TouriColors.lavender,
      thumb: 'assets/character/news_categories/manifest.png',
    ),
    _MockNews(
      title: 'AI 일러스트, 일기·다이어리 트렌드 진입',
      summary: '글을 그림으로 자동 변환해주는 서비스가 개인 기록 영역에서 인기.',
      category: 'IT',
      dot: TouriColors.mint,
      thumb: 'assets/character/news_categories/it.png',
    ),
    _MockNews(
      title: '오늘의 영성 — 보름달이 다가오는 주간',
      summary: '6월 보름달 에너지를 받아 내 안의 의도를 정리하기 좋은 시기.',
      category: '영성',
      dot: TouriColors.lilac,
      thumb: 'assets/character/news_categories/spirituality.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '✦ 오늘의 뉴스',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TouriColors.touriPink,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 8),
        ..._mock.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NewsCard(item: n, onTap: () => onTapMock(n.title)),
            )),
      ],
    );
  }
}

class _MockNews {
  final String title;
  final String summary;
  final String category;
  final Color dot;
  final String thumb;
  const _MockNews({
    required this.title,
    required this.summary,
    required this.category,
    required this.dot,
    required this.thumb,
  });
}

class _NewsCard extends StatelessWidget {
  final _MockNews item;
  final VoidCallback onTap;
  const _NewsCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TouriColors.cloudPink, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 좌측 토우리 카테고리 썸네일
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: item.dot.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: item.dot.withOpacity(0.4), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  item.thumb,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // 우측 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: item.dot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: TouriColors.cocoa,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TouriColors.cocoaDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: TouriColors.cocoa,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 영성 진행률 짧은 위젯 ────────────────────────
class _ChecklistProgress extends StatelessWidget {
  final VoidCallback onTap;
  const _ChecklistProgress({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChecklistService.instance,
      builder: (context, _) {
        final done = ChecklistService.instance.doneCount;
        final total = ChecklistService.itemIds.length;
        final pct = total == 0 ? 0.0 : done / total;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TouriColors.cloudPink, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task_alt_rounded,
                          color: Color(0xFF7B5FB8), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '오늘의 manifestation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: TouriColors.cocoaDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '$done/$total',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B5FB8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: TouriColors.dim, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: TouriColors.cloudPink,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF7B5FB8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── 카테고리 칩 ──────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final void Function(String) onTap;
  const _CategoryChips({required this.onTap});

  static const _categories = ['정치', '경제', '사회', '문화', '스포츠', 'IT'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '더 보기',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TouriColors.touriPink,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories
              .map((c) => Material(
                    color: TouriColors.cloudPink,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => onTap(c),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Text(
                          c,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: TouriColors.cocoaDark,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
