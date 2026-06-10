import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../models/growth_stage.dart';

/// Day 1 — 토우리 Flame 게임 화면 (기본).
/// 토우리가 자체 의지로 좌우 걷고 가끔 점프 + 탭하면 폴짝.
/// 다음 단계: 미니게임 (딸기 던지기, 별가루 모으기).
class TouriFlameGame extends FlameGame with TapCallbacks {
  final GrowthStage stage;
  final void Function()? onTouriTap;

  late _SkyBackground _sky;
  late _GrassFloor _floor;
  late _TouriCharacter _touri;
  late _Rainbow _rainbow;
  late _Tree _tree;
  final List<_TwinkleStar> _stars = [];
  final List<_Cloud> _clouds = [];

  TouriFlameGame({
    required this.stage,
    this.onTouriTap,
  });

  @override
  Color backgroundColor() => const Color(0xFFFFE9F2);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Flame이 sprite를 'assets/images/' 기본 prefix로 찾는데
    // 우리는 'assets/character/pet/'이라 prefix를 비워서 전체 경로 직접 사용
    images.prefix = '';

    // 배경 — 하늘
    _sky = _SkyBackground();
    add(_sky);

    // 무지개 (먼 배경)
    _rainbow = _Rainbow();
    add(_rainbow);

    // 구름 2개
    _clouds.add(_Cloud(initialX: 60, initialY: 35, cloudScale: 1.0)..priority = 1);
    _clouds.add(_Cloud(initialX: 200, initialY: 78, cloudScale: 0.7)..priority = 1);
    addAll(_clouds);

    // 반짝이 별 30개 (랜덤 위치, 시간차 깜빡임)
    final rng = math.Random(7);
    for (int i = 0; i < 30; i++) {
      _stars.add(_TwinkleStar(
        startX: rng.nextDouble() * size.x,
        startY: rng.nextDouble() * size.y * 0.6,
        phase: rng.nextDouble() * 2 * math.pi,
      )..priority = 1);
    }
    addAll(_stars);

    // 나무 (좌측)
    _tree = _Tree()..priority = 2;
    add(_tree);

    // 풀바닥
    _floor = _GrassFloor()..priority = 3;
    add(_floor);

    // 토우리 캐릭터 (가장 위)
    _touri = _TouriCharacter(stage: stage)..priority = 10;
    add(_touri);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 자식 컴포넌트들에 새 사이즈 알림은 각 컴포넌트가 onParentResize로 처리
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // 토우리 위치 근처면 직접 폴짝, 아니면 그쪽으로 걸어가기
    final tapPos = event.localPosition;
    final touriPos = _touri.position;
    final dist = (tapPos - touriPos).length;
    if (dist < 80) {
      _touri.tapped();
      onTouriTap?.call();
    } else {
      _touri.walkTo(tapPos.x);
    }
  }
}

// ─── 토우리 캐릭터 ───────────────────────────────
class _TouriCharacter extends PositionComponent with HasGameReference<TouriFlameGame> {
  final GrowthStage stage;
  SpriteAnimation? _animation;
  SpriteAnimationComponent? _sprite;

  double _targetX = 0;
  double _vx = 0;
  bool _facingRight = true;
  double _jumpOffset = 0;
  double _jumpTime = 0;
  bool _isJumping = false;
  final math.Random _rng = math.Random();
  double _nextActionAt = 0;

  _TouriCharacter({required this.stage}) {
    size = Vector2.all(180);
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 4프레임 sprite 애니메이션 — game.images로 로드 (prefix='' 설정됨)
    final frames = await Future.wait(
      stage.spriteFramePaths.map((p) async {
        try {
          final img = await game.images.load(p);
          return Sprite(img);
        } catch (_) {
          final img = await game.images.load(stage.imagePath);
          return Sprite(img);
        }
      }),
    );
    _animation = SpriteAnimation.spriteList(frames, stepTime: 0.4, loop: true);
    _sprite = SpriteAnimationComponent(
      animation: _animation,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_sprite!);

    // 초기 위치 — 화면 중앙 풀바닥 위
    position = Vector2(game.size.x / 2, game.size.y - 50);
    _targetX = position.x;
    _scheduleNextAction();
  }

  void _scheduleNextAction() {
    _nextActionAt = _rng.nextDouble() * 3 + 2; // 2-5초 후 다음 행동
  }

  void walkTo(double x) {
    final w = game.size.x;
    _targetX = x.clamp(50.0, w - 50.0);
    _facingRight = _targetX > position.x;
  }

  void tapped() {
    if (!_isJumping) {
      _isJumping = true;
      _jumpTime = 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 자동 행동 — 가끔 새 위치로 걷거나 점프
    _nextActionAt -= dt;
    if (_nextActionAt <= 0) {
      if (_rng.nextDouble() < 0.7) {
        // 70% 걷기
        final w = game.size.x;
        walkTo(50 + _rng.nextDouble() * (w - 100));
      } else {
        // 30% 점프
        tapped();
      }
      _scheduleNextAction();
    }

    // 목표 위치로 부드럽게 이동
    final dx = _targetX - position.x;
    if (dx.abs() > 1) {
      _vx = dx * 1.8; // 비례 제어
      _vx = _vx.clamp(-120, 120);
      position.x += _vx * dt;
      _facingRight = _vx >= 0;
    } else {
      _vx = 0;
    }

    // 점프 처리 (parabolic)
    if (_isJumping) {
      _jumpTime += dt;
      const jumpDuration = 0.5;
      if (_jumpTime >= jumpDuration) {
        _isJumping = false;
        _jumpOffset = 0;
      } else {
        final t = _jumpTime / jumpDuration;
        _jumpOffset = -50 * math.sin(t * math.pi);
      }
    }

    // sprite 좌우 반전
    if (_sprite != null) {
      _sprite!.scale = Vector2(_facingRight ? 1.0 : -1.0, 1.0);
      _sprite!.position = Vector2(size.x / 2, size.y / 2 + _jumpOffset);
    }
  }
}

// ─── 배경 하늘 (그라데이션 박스) ──────────────────
class _SkyBackground extends Component with HasGameReference<TouriFlameGame> {
  @override
  int get priority => 0;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFE9F2),
          Color(0xFFFBD0E0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, gradient);
  }
}

// ─── 무지개 (반원 6색) ──────────────────────────
class _Rainbow extends Component with HasGameReference<TouriFlameGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final cx = size.x - 70;
    final cy = 50.0;
    const colors = [
      Color(0xFFFF8B94),
      Color(0xFFFFBE76),
      Color(0xFFFFE066),
      Color(0xFFB5D89A),
      Color(0xFF8FCFD8),
      Color(0xFFB8A1E0),
    ];
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      final r = 50.0 - i * 4;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }
}

// ─── 구름 ──────────────────────────────────────
class _Cloud extends PositionComponent {
  final double initialX;
  final double initialY;
  final double cloudScale;
  double _t = 0;

  _Cloud({required this.initialX, required this.initialY, required this.cloudScale}) {
    position = Vector2(initialX, initialY);
    size = Vector2(70 * cloudScale, 28 * cloudScale);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    // 천천히 좌우로 흔들림
    position.x = initialX + math.sin(_t * 0.3) * 6;
  }

  @override
  void render(Canvas canvas) {
    final cell = size.y / 4;
    final paint = Paint()..color = Colors.white.withOpacity(0.9);
    final pattern = [
      [0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    ];
    for (int r = 0; r < pattern.length; r++) {
      for (int c = 0; c < pattern[r].length; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }
}

// ─── 반짝이는 별 ───────────────────────────────
class _TwinkleStar extends PositionComponent {
  final double startX;
  final double startY;
  double phase;
  double _t = 0;

  _TwinkleStar({
    required this.startX,
    required this.startY,
    required this.phase,
  }) {
    position = Vector2(startX, startY);
    size = Vector2.all(3);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    // 깜빡임 (sin)
    final brightness = (0.4 + 0.6 * (0.5 + 0.5 * math.sin(_t * 2 + phase))).clamp(0.0, 1.0);
    final colors = [
      Colors.white,
      const Color(0xFFFFE066),
      const Color(0xFFB8A1E0),
      const Color(0xFFFFB6C1),
    ];
    final c = colors[(phase * 4).toInt() % 4];
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = c.withOpacity(brightness),
    );
  }
}

// ─── 좌측 나무 (분홍 잎) ────────────────────────
class _Tree extends Component with HasGameReference<TouriFlameGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final left = 12.0;
    final bottom = size.y - 60;
    const cellSize = 5.0;
    final trunk = Paint()..color = const Color(0xFF8B6F47);
    final leafDark = Paint()..color = const Color(0xFFED93B1);
    final leafLight = Paint()..color = const Color(0xFFF4C0D1);

    // 줄기 (세로 2칸 굵기)
    for (double y = bottom - 30; y < bottom; y += cellSize) {
      canvas.drawRect(
        Rect.fromLTWH(left + cellSize * 3, y, cellSize * 2, cellSize),
        trunk,
      );
    }

    // 잎 (구름 모양)
    final leafTop = bottom - 65;
    final pattern = [
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 1, 2, 2, 2, 2, 1, 0],
      [1, 2, 2, 2, 2, 2, 2, 1],
      [1, 2, 2, 1, 2, 2, 2, 1],
      [0, 1, 2, 2, 2, 1, 0, 0],
    ];
    for (int r = 0; r < pattern.length; r++) {
      for (int c = 0; c < pattern[r].length; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(left + c * cellSize, leafTop + r * cellSize, cellSize, cellSize),
            leafDark,
          );
        } else if (pattern[r][c] == 2) {
          canvas.drawRect(
            Rect.fromLTWH(left + c * cellSize, leafTop + r * cellSize, cellSize, cellSize),
            leafLight,
          );
        }
      }
    }
  }
}

// ─── 풀바닥 ─────────────────────────────────────
class _GrassFloor extends Component with HasGameReference<TouriFlameGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final h = 60.0;
    final top = size.y - h;
    // 베이스
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.x, h),
      Paint()..color = const Color(0xFFE7F4D4),
    );
    // 픽셀 패턴
    final dark = Paint()..color = const Color(0xFFB5D89A);
    final light = Paint()..color = const Color(0xFFD0EBA8);
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final rng = math.Random(42);
    const cell = 6.0;
    for (double y = top + 4; y < size.y; y += cell) {
      for (double x = 0; x < size.x; x += cell) {
        final r = rng.nextDouble();
        if (r < 0.18) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), dark);
        } else if (r < 0.28) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), light);
        } else if (r < 0.30) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), pink);
        }
      }
    }
  }
}
