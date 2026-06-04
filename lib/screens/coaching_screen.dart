import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../models/touri_mood.dart';
import '../services/coaching_service.dart';
import '../services/quota_service.dart';
import '../widgets/touri_app_bar.dart';
import 'premium_sheet.dart';

/// AI 매니페스테이션 코칭 화면.
/// 일기·매니페·무드 받아서 Claude로 코칭 메시지 받고 typewriter로 출력.
/// QuotaService는 그려줘와 공유 (주 3회 합산).
class CoachingScreen extends StatefulWidget {
  final String diary;
  final String manifestation;
  final TouriMood mood;

  const CoachingScreen({
    super.key,
    required this.diary,
    required this.manifestation,
    required this.mood,
  });

  @override
  State<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends State<CoachingScreen> {
  final CoachingService _service = CoachingService();
  final QuotaService _quota = QuotaService();

  String _displayed = '';
  String _full = '';
  bool _loading = false;
  bool _done = false;
  int _remaining = QuotaService.weeklyLimit;
  Timer? _typewriter;

  @override
  void initState() {
    super.initState();
    _loadQuota();
  }

  Future<void> _loadQuota() async {
    final r = await _quota.getRemaining();
    if (!mounted) return;
    setState(() => _remaining = r);
  }

  @override
  void dispose() {
    _typewriter?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_loading) return;
    if (!await _quota.canGenerate()) {
      if (!mounted) return;
      _openPremium();
      return;
    }
    setState(() {
      _loading = true;
      _done = false;
      _displayed = '';
      _full = '';
    });

    final text = await _service.coach(
      diary: widget.diary,
      manifestation: widget.manifestation,
      mood: widget.mood,
    );
    await _quota.increment();
    final newR = await _quota.getRemaining();

    if (!mounted) return;
    setState(() {
      _full = text;
      _loading = false;
      _remaining = newR;
    });
    _animate(text);
  }

  void _animate(String full) {
    _typewriter?.cancel();
    int i = 0;
    setState(() => _displayed = '');
    _typewriter = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (i >= full.length) {
        t.cancel();
        setState(() => _done = true);
        return;
      }
      i++;
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _displayed = full.substring(0, i));
    });
  }

  void _openPremium() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !_loading && _remaining > 0;
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: 'AI 코칭 ✦', subtitle: '토우리의 응원'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvatarHeader(mood: widget.mood),
            const SizedBox(height: 18),
            _InputPreview(diary: widget.diary, manifestation: widget.manifestation),
            const SizedBox(height: 18),
            _ResultPanel(text: _displayed, loading: _loading, hasResult: _full.isNotEmpty),
            const SizedBox(height: 18),
            _ActionButton(
              loading: _loading,
              done: _done,
              remaining: _remaining,
              enabled: canTap,
              onTap: _start,
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '그려줘 + 코칭 합쳐 주 3회 ♡',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TouriColors.dim,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  final TouriMood mood;
  const _AvatarHeader({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: TouriColors.touriPink.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(mood.avatarPath, fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Text(
          '토우리가 너에게 ✦',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: TouriColors.cocoaDark,
                fontSize: 18,
              ),
        ),
      ],
    );
  }
}

class _InputPreview extends StatelessWidget {
  final String diary;
  final String manifestation;
  const _InputPreview({required this.diary, required this.manifestation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: TouriColors.paperBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TouriColors.paperLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(label: '오늘 일기', body: diary.trim().isEmpty ? '(아직 안 적었어)' : diary),
          const SizedBox(height: 10),
          _Section(
            label: '✦ 내가 부르는 미래',
            body: manifestation.trim().isEmpty ? '(아직 안 적었어)' : manifestation,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String body;
  const _Section({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: TouriColors.touriPink,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TouriTheme.handwriting(fontSize: 15),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String text;
  final bool loading;
  final bool hasResult;
  const _ResultPanel({required this.text, required this.loading, required this.hasResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F6), Color(0xFFEADCF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.lavender, width: 1),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !hasResult && !loading
            ? const _ResultPlaceholder()
            : Column(
                key: const ValueKey('result'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOURI ✦',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: const Color(0xFF7B5FB8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TouriTheme.handwriting(
                      fontSize: 17,
                      color: TouriColors.cocoaDark,
                    ),
                  ),
                  if (loading) ...[
                    const SizedBox(height: 8),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF7B5FB8)),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ResultPlaceholder extends StatelessWidget {
  const _ResultPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '버튼을 누르면 토우리가 너에게 한 마디 적어줄게 ♡',
        style: TouriTheme.handwriting(fontSize: 15, color: TouriColors.dim),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool loading;
  final bool done;
  final int remaining;
  final bool enabled;
  final VoidCallback onTap;
  const _ActionButton({
    required this.loading,
    required this.done,
    required this.remaining,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B5FB8);
    final label = loading
        ? '쓰는 중...'
        : (done ? '다시 받기 ✦' : '✦ 토우리 코칭 받기');
    return Material(
      color: enabled ? purple : TouriColors.dim,
      shape: const StadiumBorder(),
      elevation: enabled ? 3 : 0,
      shadowColor: purple.withOpacity(0.4),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$remaining/3',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
