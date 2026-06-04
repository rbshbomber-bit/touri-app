import 'package:flutter/material.dart';
import '../../theme/touri_colors.dart';
import '../../theme/touri_theme.dart';
import '../../services/affirmation_cache_service.dart';

/// 오늘의 Affirmation 카드 — 핑크 그라데이션 + 손글씨 + ↻ 새로고침.
/// 초기 자동 로드(차감 X), ↻ 탭은 일일 한도 차감.
class AffirmationCard extends StatefulWidget {
  const AffirmationCard({super.key});

  @override
  State<AffirmationCard> createState() => _AffirmationCardState();
}

class _AffirmationCardState extends State<AffirmationCard>
    with SingleTickerProviderStateMixin {
  final AffirmationCacheService _service = AffirmationCacheService();
  late final AnimationController _spin;

  String? _text;
  bool _loading = false;
  int _remaining = AffirmationCacheService.dailyLimit;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initial();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _initial() async {
    setState(() => _loading = true);
    final t = await _service.initialOrFetch();
    final r = await _service.getRemaining();
    if (!mounted) return;
    setState(() {
      _text = t;
      _loading = false;
      _remaining = r;
    });
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _spin.repeat();
    setState(() => _loading = true);
    final t = await _service.refresh();
    final r = await _service.getRemaining();
    _spin.stop();
    if (!mounted) return;
    if (t == null) {
      setState(() {
        _loading = false;
        _remaining = r;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘 새로고침은 다 썼어. 내일 또 만나 ♡'),
          backgroundColor: TouriColors.cocoaDark,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _text = t;
      _loading = false;
      _remaining = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE9EE), Color(0xFFFFD1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: TouriColors.touriPink.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '✦ TODAY\'S AFFIRMATION',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TouriColors.touriPink,
                      fontSize: 10,
                      letterSpacing: 1.4,
                    ),
              ),
              const Spacer(),
              Text(
                '$_remaining/${AffirmationCacheService.dailyLimit}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TouriColors.cocoa,
                ),
              ),
              const SizedBox(width: 8),
              _RefreshButton(
                onTap: _refresh,
                spinning: _spin,
                disabled: _loading,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _text ?? '오늘의 문장을 가져오는 중...',
                key: ValueKey(_text ?? '_loading'),
                style: TouriTheme.handwriting(
                  fontSize: 22,
                  color: TouriColors.cocoaDark,
                ).copyWith(height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController spinning;
  final bool disabled;
  const _RefreshButton({
    required this.onTap,
    required this.spinning,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: disabled ? null : onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: RotationTransition(
              turns: spinning,
              child: const Icon(
                Icons.refresh_rounded,
                color: TouriColors.touriPink,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
