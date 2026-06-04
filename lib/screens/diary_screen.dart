import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../models/touri_mood.dart';
import '../models/touri_entry.dart';
import '../models/diary_sticker.dart';
import '../models/generation_status.dart';
import '../models/generated_item.dart';
import '../services/touri_storage.dart';
import '../services/generation_orchestrator.dart';
import '../services/quota_service.dart';
import '../services/collection_service.dart';
import '../services/pet_service.dart';
import '../models/pet_stat.dart';
import '../data/sticker_catalog.dart';
import '../widgets/ai_companion_card.dart';
import '../widgets/mood_tray.dart';
import '../widgets/diary_paper.dart';
import '../widgets/manifest_card.dart';
import '../widgets/gratitude_card.dart';
import '../widgets/sticker_picker_sheet.dart';
import '../widgets/generation_status_badge.dart';
import '../widgets/generated_image_view.dart';
import '../widgets/touri_app_bar.dart';
import 'manifest_screen.dart';
import 'gratitude_screen.dart';
import 'premium_sheet.dart';
import 'collection_screen.dart';
import 'auth_sheet.dart';
import 'sticker_store_screen.dart';
import 'coaching_screen.dart';

/// 메인 다이어리 화면. 무드 + AI + 자유 본문 + 매니페스테이션·감사 카드.
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TouriStorage _storage = TouriStorage();
  final QuotaService _quota = QuotaService();
  late final String _dateKey;
  TouriEntry _entry = const TouriEntry(dateKey: '', mood: TouriMood.secretary);
  Timer? _saveDebounce;
  bool _stickerMode = false;
  int _remaining = QuotaService.weeklyLimit;

  @override
  void initState() {
    super.initState();
    _dateKey = TouriStorage.dateKeyFor(DateTime.now());
    _entry = TouriEntry(dateKey: _dateKey, mood: TouriMood.secretary);
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.load(_dateKey);
    final remaining = await _quota.getRemaining();
    if (!mounted) return;
    setState(() {
      _entry = loaded;
      _remaining = remaining;
    });
    // 앱 재시작 후에도 미완료 생성 이어받기
    if (loaded.generationStatus.isBusy && loaded.generationRequestId != null) {
      GenerationOrchestrator.instance.resume(
        requestId: loaded.generationRequestId!,
        dateKey: _dateKey,
        lastStatus: loaded.generationStatus,
        onProgress: _handleGenerationProgress,
        onReady: _handleGenerationReady,
        onFailed: _handleGenerationFailed,
      );
    }
  }

  void _debouncedSave(TouriEntry next) {
    setState(() => _entry = next);
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      _storage.save(next);
      _maybeRewardDiary(next);
    });
  }

  Future<void> _saveNow(TouriEntry next) async {
    setState(() => _entry = next);
    _saveDebounce?.cancel();
    await _storage.save(next);
    _maybeRewardDiary(next);
  }

  /// 다이어리 본문이 10자 이상이면 하루 한 번 마음 +1.
  void _maybeRewardDiary(TouriEntry next) {
    if (next.body.trim().length < 10) return;
    final awarded = PetService.instance.rewardOncePerDay(
      PetStat.heart,
      'diary',
    );
    if (awarded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💗 마음 +1 — 토우리가 한 뼘 자랐어'),
          backgroundColor: Color(0xFF7B5FB8),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      if (result.trim().isNotEmpty) {
        final awarded = PetService.instance.rewardOncePerDay(
          PetStat.sparkle,
          'manifest',
        );
        if (awarded && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⭐ 반짝임 +1 — 오늘 부르는 미래를 토우리가 들었어'),
              backgroundColor: Color(0xFF7B5FB8),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
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
      if (result.where((g) => g.trim().isNotEmpty).length >= 3) {
        final awarded = PetService.instance.rewardOncePerDay(
          PetStat.love,
          'gratitude',
        );
        if (awarded && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💞 사랑 +1 — 감사가 토우리를 따뜻하게 했어'),
              backgroundColor: Color(0xFF7B5FB8),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _toggleStickerMode() {
    setState(() => _stickerMode = !_stickerMode);
    if (_stickerMode && _entry.stickers.isEmpty) {
      _openStickerPicker();
    }
  }

  Future<void> _openStickerPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StickerPickerSheet(onPicked: _addSticker),
    );
  }

  void _addSticker(StickerAsset asset) {
    final newSticker = DiarySticker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourcePath: asset.path,
      dx: 150,
      dy: 180,
      scale: 1.0,
      rotation: 0,
    );
    _saveNow(_entry.copyWith(stickers: [..._entry.stickers, newSticker]));
  }

  void _updateSticker(DiarySticker updated) {
    final next = _entry.stickers
        .map((s) => s.id == updated.id ? updated : s)
        .toList();
    _debouncedSave(_entry.copyWith(stickers: next));
  }

  void _deleteSticker(String id) {
    final next = _entry.stickers.where((s) => s.id != id).toList();
    _saveNow(_entry.copyWith(stickers: next));
  }

  // ─── 생성 흐름 ─────────────────────────────────────
  void _handleGenerationProgress(GenerationStatus s, {String? requestId}) {
    _saveNow(_entry.copyWith(
      generationStatus: s,
      generationRequestId: requestId,
    ));
  }

  void _handleGenerationReady(String localPath) async {
    await _saveNow(_entry.copyWith(
      generationStatus: GenerationStatus.ready,
      generatedImagePath: localPath,
      clearGenerationRequestId: true,
    ));
    // 수집함에도 누적.
    final scene = GenerationOrchestrator.instance.lastScene ?? '';
    await CollectionService.instance.add(
      sourcePath: localPath,
      prompt: scene,
      sourceDateKey: _dateKey,
      moodId: _entry.mood.id,
    );
    final newRemaining = QuotaService.weeklyLimit - await _quota.increment();
    // 그려줘 = 반짝임 +2 (귀한 보상, 매 호출마다)
    PetService.instance.reward(PetStat.sparkle, amount: 2, source: 'generate');
    if (!mounted) return;
    setState(() => _remaining = newRemaining < 0 ? 0 : newRemaining);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ 새 토우리 도착! 반짝임 +2'),
        backgroundColor: Color(0xFF7B5FB8),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleGenerationFailed(String error) {
    _saveNow(_entry.copyWith(
      generationStatus: GenerationStatus.failed,
      clearGenerationRequestId: true,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('어머, 토우리가 살짝 길을 잃었어 — $error'),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onRequestGeneration() async {
    if (GenerationOrchestrator.instance.isBusy) return;
    final canGen = await _quota.canGenerate();
    if (!canGen) {
      if (!mounted) return;
      _openPremium();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎨 토우리가 그리는 중... 다른 일 해도 돼'),
        backgroundColor: Color(0xFF7B5FB8),
        duration: Duration(seconds: 3),
      ),
    );
    await GenerationOrchestrator.instance.generate(
      diary: _entry.body,
      mood: _entry.mood,
      dateKey: _dateKey,
      onProgress: _handleGenerationProgress,
      onReady: _handleGenerationReady,
      onFailed: _handleGenerationFailed,
    );
  }

  void _openPremium() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumSheet(),
    );
  }

  void _openCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          onAttachToToday: _attachItemToDiary,
          onRegenerate: _regenerateFromItem,
        ),
      ),
    );
  }

  void _openStore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StickerStoreScreen()),
    );
  }

  void _openCoaching() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachingScreen(
          diary: _entry.body,
          manifestation: _entry.manifestation,
          mood: _entry.mood,
        ),
      ),
    ).then((_) => _refreshQuota());
  }

  Future<void> _refreshQuota() async {
    final r = await _quota.getRemaining();
    if (!mounted) return;
    setState(() => _remaining = r);
  }

  void _openAuth() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuthSheet(),
    );
  }

  void _attachItemToDiary(GeneratedItem item) {
    final sticker = DiarySticker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourcePath: item.localPath,
      dx: 150,
      dy: 180,
      scale: 1.0,
      rotation: 0,
    );
    _saveNow(_entry.copyWith(stickers: [..._entry.stickers, sticker]));
    if (!mounted) return;
    setState(() => _stickerMode = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✦ 다이어리에 붙였어. 위치 조정해봐'),
        backgroundColor: Color(0xFF7B5FB8),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _regenerateFromItem(GeneratedItem item) async {
    if (GenerationOrchestrator.instance.isBusy) return;
    final canGen = await _quota.canGenerate();
    if (!canGen) {
      if (!mounted) return;
      _openPremium();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎨 같은 마음으로 다시 그리는 중...'),
        backgroundColor: Color(0xFF7B5FB8),
        duration: Duration(seconds: 3),
      ),
    );
    await GenerationOrchestrator.instance.generate(
      diary: _entry.body,
      mood: _entry.mood,
      dateKey: _dateKey,
      scene: item.prompt,
      onProgress: _handleGenerationProgress,
      onReady: _handleGenerationReady,
      onFailed: _handleGenerationFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '다이어리', subtitle: '오늘의 마음 기록'),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onOpenCollection: _openCollection,
              onOpenAuth: _openAuth,
              onOpenStore: _openStore,
            ),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hasGeneratedImage = _entry.generatedImagePath != null;
                          final paperHeight = hasGeneratedImage
                              ? 340.0
                              : math.max(260.0, constraints.maxHeight - 110);
                          final imageWidth = math.min(380.0, constraints.maxWidth);

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: paperHeight,
                                  child: ListenableBuilder(
                                    listenable: GenerationOrchestrator.instance,
                                    builder: (context, _) => DiaryPaper(
                                      mood: _entry.mood,
                                      initialText: _entry.body,
                                      onChanged: _changeBody,
                                      stickers: _entry.stickers,
                                      stickerMode: _stickerMode,
                                      onStickerChanged: _updateSticker,
                                      onStickerDelete: _deleteSticker,
                                      onToggleMode: _toggleStickerMode,
                                      onPickSticker: _openStickerPicker,
                                      onRequestGeneration: _onRequestGeneration,
                                      generationRemaining: _remaining,
                                      generationBusy: GenerationOrchestrator.instance.isBusy,
                                    ),
                                  ),
                                ),
                                if (hasGeneratedImage) ...[
                                  const SizedBox(height: 10),
                                  Center(
                                    child: SizedBox(
                                      width: imageWidth,
                                      child: GeneratedImageView(
                                        imagePath: _entry.generatedImagePath!,
                                        onRegenerate: _onRequestGeneration,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 82,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ManifestCard(
                                          text: _entry.manifestation,
                                          onTap: _openManifest,
                                          onCoachTap: _openCoaching,
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListenableBuilder(
                listenable: GenerationOrchestrator.instance,
                builder: (context, _) => _GenerateActionBar(
                  remaining: _remaining,
                  busy: GenerationOrchestrator.instance.isBusy,
                  onTap: _onRequestGeneration,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
  final VoidCallback? onOpenCollection;
  final VoidCallback? onOpenAuth;
  final VoidCallback? onOpenStore;
  const _Header({this.onOpenCollection, this.onOpenAuth, this.onOpenStore});

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
          const GenerationStatusBadge(),
          const SizedBox(width: 8),
          _StoreButton(onTap: onOpenStore),
          const SizedBox(width: 6),
          _CollectionButton(onTap: onOpenCollection),
          const SizedBox(width: 8),
          _LoginButton(onTap: onOpenAuth),
          const SizedBox(width: 8),
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

class _GenerateActionBar extends StatelessWidget {
  final int remaining;
  final bool busy;
  final VoidCallback? onTap;

  const _GenerateActionBar({
    required this.remaining,
    required this.busy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = busy || remaining <= 0;
    const purple = Color(0xFF7B5FB8);
    return Material(
      color: disabled ? TouriColors.dim : purple,
      borderRadius: BorderRadius.circular(16),
      elevation: disabled ? 0 : 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disabled ? onTap : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                busy ? '토우리가 그리는 중...' : '✦ 그려줘',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$remaining/3',
                style: const TextStyle(
                  color: Color(0xDDFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _LoginButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TouriColors.cloudPink,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(9, 5, 10, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded, color: TouriColors.touriPink, size: 14),
              SizedBox(width: 4),
              Text(
                '로그인',
                style: TextStyle(
                  color: TouriColors.cocoaDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _StoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TouriColors.touriPink,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _CollectionButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _CollectionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CollectionService.instance,
      builder: (context, _) => FutureBuilder<List<GeneratedItem>>(
        future: CollectionService.instance.all(),
        builder: (context, snap) {
          final count = snap.data?.length ?? 0;
          return Material(
            color: const Color(0xFF7B5FB8),
            shape: const StadiumBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
