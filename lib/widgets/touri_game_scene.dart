import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import 'touri_motion.dart';

/// 다마고치 스타일 게임 화면.
/// 토우리가 좌우로 걸어다니고, 가끔 점프하고, 탭하면 반응한다.
///
/// 구성:
///  • 픽셀 풀바닥 (마룻바닥 패턴)
///  • 토우리 sprite (PixelSpriteAvatar로 4프레임 sprite 애니메이션)
///  • 좌우 위치 자동 변경 (3-5초마다 새 목표 위치)
///  • 5-8초마다 점프
///  • 탭하면 위로 폴짝 + ♡ 버스트
///  • 우상단 픽셀 HUD (hunger/mood/energy 미니 게이지)
class TouriGameScene extends StatefulWidget {
  final List<String> framePaths;
  final String fallbackPath;
  final int hunger;
  final int mood;
  final int energy;
  final int streak;
  final String stageLabel;
  final double height;

  const TouriGameScene({
    super.key,
    required this.framePaths,
    required this.fallbackPath,
    required this.hunger,
    required this.mood,
    required this.energy,
    required this.streak,
    required this.stageLabel,
    this.height = 280,
  });

  @override
  State<TouriGameScene> createState() => _TouriGameSceneState();
}

class _TouriGameSceneState extends State<TouriGameScene>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late AnimationController _jumpController;
  late Animation<double> _walkAnim;
  late Animation<double> _jumpAnim;

  final math.Random _rng = math.Random();
  Timer? _walkTimer;
  Timer? _jumpTimer;

  double _walkFrom = 0.5; // 0~1 가로 위치 비율
  double _walkTo = 0.5;
  bool _facingRight = true;
  int _reactionTrigger = 0;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _walkAnim = CurvedAnimation(parent: _walkController, curve: Curves.easeInOut);
    _jumpAnim = CurvedAnimation(parent: _jumpController, curve: Curves.easeOut);

    _scheduleNextWalk();
    _scheduleNextJump();
  }

  void _scheduleNextWalk() {
    // 새 목표 위치 (0.15 ~ 0.85 범위, 양 끝 여백)
    _walkFrom = _walkTo;
    _walkTo = 0.15 + _rng.nextDouble() * 0.70;
    _facingRight = _walkTo >= _walkFrom;
    _walkController.duration = Duration(
      milliseconds: 2500 + _rng.nextInt(2500),
    );
    _walkController.forward(from: 0).then((_) {
      if (!mounted) return;
      // 잠시 멈췄다가 다시 걷기
      _walkTimer = Timer(
        Duration(milliseconds: 800 + _rng.nextInt(1500)),
        _scheduleNextWalk,
      );
    });
  }

  void _scheduleNextJump() {
    _jumpTimer = Timer(
      Duration(seconds: 4 + _rng.nextInt(5)),
      () {
        if (!mounted) return;
        _jumpController.forward(from: 0).then((_) {
          if (mounted) _scheduleNextJump();
        });
      },
    );
  }

  void _onTap() {
    // 탭 즉시 점프 + 하트 버스트
    _jumpController.forward(from: 0);
    setState(() => _reactionTrigger++);
  }

  @override
  void dispose() {
    _walkController.dispose();
    _jumpController.dispose();
    _walkTimer?.cancel();
    _jumpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          // 8-bit 게임 화면 — 부드러운 라일락 → 핑크 그라데이션
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE9F2), // 연분홍 하늘
              Color(0xFFFBD0E0), // 핑크 황혼
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TouriColors.touriPink.withOpacity(0.6),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final touriSize = math.min(w * 0.42, 140.0);
            final floorY = h - 60; // 풀바닥 위치
            return Stack(
              children: [
                // ── 배경: 픽셀 별 점들 ──
                _PixelStars(rng: _rng),
                // ── 풀바닥 (픽셀 잔디 패턴) ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 60,
                  child: CustomPaint(
                    painter: _GrassPainter(),
                  ),
                ),
                // ── 토우리 ──
                AnimatedBuilder(
                  animation: Listenable.merge([_walkAnim, _jumpAnim]),
                  builder: (context, _) {
                    final x = _walkFrom + (_walkTo - _walkFrom) * _walkAnim.value;
                    // 점프: 0 → 1 → 0 (parabolic-ish)
                    final j = _jumpAnim.value;
                    final jumpHeight = -22.0 * math.sin(j * math.pi);
                    return Positioned(
                      left: x * w - touriSize / 2,
                      bottom: 40 + (-jumpHeight),
                      width: touriSize,
                      height: touriSize,
                      child: Transform(
                        alignment: Alignment.center,
                        // 좌우 반전 (이동 방향)
                        transform: Matrix4.identity()
                          ..scale(_facingRight ? 1.0 : -1.0, 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PixelSpriteAvatar(
                              framePaths: widget.framePaths,
                              fallbackPath: widget.fallbackPath,
                              size: touriSize,
                              fit: BoxFit.contain,
                            ),
                            // 탭 반응 — 하트 버스트
                            Positioned.fill(
                              child: ReactionBurst(
                                trigger: _reactionTrigger,
                                symbol: '♡',
                                color: TouriColors.touriPink,
                                origin: const Alignment(0, -0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // ── 좌상단 단계 라벨 (게임 HUD 스타일) ──
                Positioned(
                  left: 12,
                  top: 12,
                  child: _HudChip(
                    text: '${widget.stageLabel}  Lv',
                    fg: const Color(0xFF7B5FB8),
                    bg: Colors.white,
                  ),
                ),
                // ── 우상단 streak ──
                Positioned(
                  right: 12,
                  top: 12,
                  child: _HudChip(
                    text: '🔥 ${widget.streak}d',
                    fg: TouriColors.cocoaDark,
                    bg: Colors.white,
                  ),
                ),
                // ── 우하단 미니 HUD (hunger/mood/energy 게이지) ──
                Positioned(
                  right: 12,
                  bottom: 70,
                  child: _MiniGauges(
                    hunger: widget.hunger,
                    mood: widget.mood,
                    energy: widget.energy,
                  ),
                ),
                // ── "탭해봐 ✦" 힌트 (살짝 깜빡임) ──
                if (_reactionTrigger == 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Center(
                      child: _BlinkText(text: 'tap 토우리 ✦'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _HudChip({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MiniGauges extends StatelessWidget {
  final int hunger;
  final int mood;
  final int energy;
  const _MiniGauges({
    required this.hunger,
    required this.mood,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TouriColors.touriPink.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar('🍓', hunger, TouriColors.touriPink),
          const SizedBox(height: 3),
          _bar('☀️', mood, TouriColors.lavender),
          const SizedBox(height: 3),
          _bar('💤', energy, TouriColors.mint),
        ],
      ),
    );
  }

  Widget _bar(String emoji, int v, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFFBEAF0),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withOpacity(0.4), width: 0.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (v / 10).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlinkText extends StatefulWidget {
  final String text;
  const _BlinkText({required this.text});

  @override
  State<_BlinkText> createState() => _BlinkTextState();
}

class _BlinkTextState extends State<_BlinkText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: 0.35 + 0.45 * _c.value,
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7B5FB8),
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}

/// 배경 픽셀 별 — 8x8 픽셀 도트 18개 랜덤 배치 (static)
class _PixelStars extends StatelessWidget {
  final math.Random rng;
  const _PixelStars({required this.rng});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final dots = List.generate(18, (i) {
        final x = rng.nextDouble() * c.maxWidth;
        final y = rng.nextDouble() * (c.maxHeight * 0.55);
        final s = 2.0 + rng.nextInt(3); // 2-4px
        final colors = [
          Colors.white.withOpacity(0.8),
          TouriColors.lavender.withOpacity(0.7),
          TouriColors.touriPink.withOpacity(0.55),
        ];
        return Positioned(
          left: x,
          top: y,
          width: s,
          height: s,
          child: Container(color: colors[i % 3]),
        );
      });
      return Stack(children: dots);
    });
  }
}

/// 픽셀 잔디 페인터 — 작은 사각형 패턴 (다마고치 마룻바닥 느낌)
class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 베이스 잔디 색
    final base = Paint()..color = const Color(0xFFE7F4D4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), base);

    // 풀잎 픽셀 도트
    final darkGrass = Paint()..color = const Color(0xFFB5D89A);
    final lightGrass = Paint()..color = const Color(0xFFD0EBA8);
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final cellSize = 6.0;
    final rng = math.Random(42); // seeded → 매번 같은 패턴
    for (double y = 4; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final r = rng.nextDouble();
        if (r < 0.18) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), darkGrass);
        } else if (r < 0.28) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), lightGrass);
        } else if (r < 0.30) {
          // 가끔 분홍 꽃
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), pink);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
