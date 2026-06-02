import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../models/touri_mood.dart';
import '../models/touri_entry.dart';
import '../services/touri_storage.dart';
import '../widgets/ai_companion_card.dart';
import '../widgets/mood_tray.dart';
import '../widgets/diary_paper.dart';
import '../widgets/manifest_card.dart';
import '../widgets/gratitude_card.dart';
import 'manifest_screen.dart';
import 'gratitude_screen.dart';

/// 메인 다이어리 화면. 무드 + AI + 자유 본문 + 매니페스테이션·감사 카드.
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TouriStorage _storage = TouriStorage();
  late final String _dateKey;
  TouriEntry _entry = const TouriEntry(dateKey: '', mood: TouriMood.secretary);
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _dateKey = TouriStorage.dateKeyFor(DateTime.now());
    _entry = TouriEntry(dateKey: _dateKey, mood: TouriMood.secretary);
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.load(_dateKey);
    if (!mounted) return;
    setState(() => _entry = loaded);
  }

  void _debouncedSave(TouriEntry next) {
    setState(() => _entry = next);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      _storage.save(next);
    });
  }

  Future<void> _saveNow(TouriEntry next) async {
    setState(() => _entry = next);
    _saveDebounce?.cancel();
    await _storage.save(next);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    // 디바운스 중인 변경 사항 즉시 저장.
    _storage.save(_entry);
    super.dispose();
  }

  void _changeMood(TouriMood next) {
    _saveNow(_entry.copyWith(mood: next));
  }

  void _changeBody(String text) {
    _debouncedSave(_entry.copyWith(body: text));
  }

  Future<void> _openManifest() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ManifestScreen(initialText: _entry.manifestation),
      ),
    );
    if (result != null) {
      await _saveNow(_entry.copyWith(manifestation: result));
    }
  }

  Future<void> _openGratitude() async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => GratitudeScreen(initial: _entry.gratitude),
      ),
    );
    if (result != null) {
      await _saveNow(_entry.copyWith(gratitude: result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AiCompanionCard(mood: _entry.mood),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: DiaryPaper(
                        mood: _entry.mood,
                        initialText: _entry.body,
                        onChanged: _changeBody,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 78,
                      child: Row(
                        children: [
                          Expanded(
                            child: ManifestCard(
                              text: _entry.manifestation,
                              onTap: _openManifest,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GratitudeCard(
                              gratitude: _entry.gratitude,
                              onTap: _openGratitude,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MoodTray(selected: _entry.mood, onChanged: _changeMood),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2026 . 06 . 02 · TUE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: TouriColors.dim,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '토우리 일기',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
          Row(
            children: [
              _Avatar(letter: '나', color: TouriColors.touriPink),
              const SizedBox(width: 4),
              _Avatar(letter: '시', color: const Color(0xFFB89CDF)),
              const SizedBox(width: 4),
              _Avatar(letter: '지', color: const Color(0xFF6FCBA1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  final Color color;
  const _Avatar({required this.letter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
