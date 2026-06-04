import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../services/touri_storage.dart';
import '../widgets/spirituality/affirmation_card.dart';
import '../widgets/spirituality/manifest_checklist_card.dart';
import '../widgets/touri_app_bar.dart';
import 'gratitude_screen.dart';
import 'manifest_screen.dart';
import 'collection_screen.dart';

/// 영성/manifestation 루틴 허브.
/// Card 1: AffirmationCard
/// Card 2: ManifestChecklistCard
/// Card 3-5: 임시 placeholder
class SpiritualityScreen extends StatefulWidget {
  const SpiritualityScreen({super.key});

  @override
  State<SpiritualityScreen> createState() => _SpiritualityScreenState();
}

class _SpiritualityScreenState extends State<SpiritualityScreen> {
  final TouriStorage _storage = TouriStorage();
  late final String _dateKey;

  @override
  void initState() {
    super.initState();
    _dateKey = TouriStorage.dateKeyFor(DateTime.now());
  }

  void _soon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 루틴은 곧 열릴게 ♡'),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openGratitude() async {
    final entry = await _storage.load(_dateKey);
    if (!mounted) return;
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => GratitudeScreen(initial: entry.gratitude),
      ),
    );
    if (result == null) return;
    await _storage.save(entry.copyWith(gratitude: result));
  }

  Future<void> _openManifest() async {
    final entry = await _storage.load(_dateKey);
    if (!mounted) return;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ManifestScreen(initialText: entry.manifestation),
      ),
    );
    if (result == null) return;
    await _storage.save(entry.copyWith(manifestation: result));
  }

  void _openCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          onAttachToToday: (_) => _toast('다이어리 탭에서 붙일 수 있어 ♡'),
          onRegenerate: (_) => _toast('다이어리 탭에서 다시 그릴 수 있어 ♡'),
        ),
      ),
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
    final placeholders = [
      _RoutineCardData(
        icon: Icons.self_improvement_rounded,
        title: '5분 호흡 명상',
        body: '곧 출시 — 들숨·날숨 따라 같이 쉬어보자.',
        color: TouriColors.mint,
      ),
      _RoutineCardData(
        icon: Icons.nightlight_round,
        title: '오늘의 달 ✦',
        body: '곧 출시 — 음력 달의 위상과 메시지.',
        color: TouriColors.lavender,
      ),
      _RoutineCardData(
        icon: Icons.favorite_rounded,
        title: '이번 주 너가 부른 미래',
        body: '곧 출시 — 최근 7일 manifestation 모음.',
        color: TouriColors.bubble,
      ),
    ];

    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '영성 ✦', subtitle: '오늘의 마음 돌봄'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              '영성 루틴',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '귀엽지만 차분하게, 매일 마음을 조율하는 메뉴야.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TouriColors.cocoa,
                  ),
            ),
            const SizedBox(height: 18),
            const AffirmationCard(),
            const SizedBox(height: 16),
            ManifestChecklistCard(
              onOpenGratitude: _openGratitude,
              onOpenManifest: _openManifest,
              onOpenCollection: _openCollection,
              onBreathTap: () => _soon('5분 호흡 명상'),
            ),
            const SizedBox(height: 16),
            ...placeholders.map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RoutineCard(
                  data: card,
                  onTap: () => _soon(card.title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCardData {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _RoutineCardData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _RoutineCard extends StatelessWidget {
  final _RoutineCardData data;
  final VoidCallback onTap;
  const _RoutineCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TouriColors.cloudPink),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: TouriColors.cocoaDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TouriColors.cocoaDark,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TouriColors.cocoa,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: TouriColors.dim),
            ],
          ),
        ),
      ),
    );
  }
}
