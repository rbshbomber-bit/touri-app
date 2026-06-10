import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../models/growth_stage.dart';

/// Day 2 — 토우리 Flame 게임 + 딸기 던지기 미니게임.
/// 빈 풀바닥 탭 → 딸기 떨어짐 (gravity), 토우리가 가장 가까운 딸기 추적해서 받아먹음.
/// 5개 먹으면 보너스 ✨ (onStrawberryEaten 콜백 호출 — PetService 연동).
class TouriFlameGame extends FlameGame with TapCallbacks {
  final GrowthStage stage;
  final void Function()? onTouriTap;
  final void Function(int totalEaten)? onStrawberryEaten;

  late _SkyBackground _sky;
  late _GrassFloor _floor;
  late _TouriCharacter _touri;
  late _Rainbow _rainbow;
  late _Tree _tree;
  final List<_TwinkleStar> _stars = [];
  final List<_Cloud> _clouds = [];
  final List<_Strawberry> _strawberries = [];

  int strawberriesEaten = 0;

  TouriFlameGame({
    required this.stage,
    this.onTouriTap,
    this.onStrawberryEaten,
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
    final tapPos = event.localPosition;
    final touriPos = _touri.position;
    final dist = (tapPos - touriPos).length;
    final isOnFloor = tapPos.y > size.y * 0.6; // 화면 아래쪽 60% 영역

    if (dist < 60) {
      // 토우리 바로 탭 → 폴짝
      _touri.tapped();
      onTouriTap?.call();
    } else if (isOnFloor && _strawberries.length < 8) {
      // 빈 풀바닥 탭 → 딸기 떨어뜨림 (최대 8개 동시)
      final s = _Strawberry(spawnX: tapPos.x, spawnY: math.max(0, tapPos.y - 80))..priority = 9;
      _strawberries.add(s);
      add(s);
    } else {
      // 머리 위 탭 → 토우리가 그쪽으로
      _touri.walkTo(tapPos.x);
    }
  }

  /// 토우리가 딸기 먹었을 때 호출됨 (충돌 처리)
  void _onStrawberryEaten(_Strawberry s) {
    s.removeFromParent();
    _strawberries.remove(s);
    strawberriesEaten++;
    onStrawberryEaten?.call(strawberriesEaten);
  }

  /// 토우리에 가장 가까운 딸기 위치 (없으면 null)
  Vector2? get nearestStrawberryPos {
    if (_strawberries.isEmpty) return null;
    _Strawberry? nearest;
    double minDist = double.infinity;
    for (final s in _strawberries) {
      if (!s.isReady) continue; // 땅에 닿은 거만 추적
      final d = (s.position - _touri.position).length;
      if (d < minDist) {
        minDist = d;
        nearest = s;
      }
    }
    return nearest?.position;
  }

  /// 충돌 체크 — 토우리 위치 vs 딸기들
  void _checkCollisions() {
    final touriPos = _touri.position;
    for (final s in List.of(_strawberries)) {
      if (!s.isReady) continue;
      final d = (s.position - touriPos).length;
      if (d < 36) {
        _onStrawberryEaten(s);
        _touri.celebrate();
      }
    }
  }
}

// 친구 단계 전용 액션 10종 — assets/character/actions/friend/{action}_{1-4}.png
enum TouriAction { idle, walk, eat, jump, happy, sleep, surprise, sad, wave, dance }

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

  // 친구 단계 액션 시스템 (다른 단계는 기존 spriteFramePaths 사용)
  bool _useActions = false;
  final Map<TouriAction, SpriteAnimation> _actionAnims = {};
  TouriAction _currentAction = TouriAction.idle;
  double _actionHold = 0; // 현재 액션 고정 시간 (eat→happy 시퀀스용)
  TouriAction? _afterHold; // 고정 끝나면 전환할 액션

  _TouriCharacter({required this.stage}) {
    size = Vector2.all(180);
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _useActions = stage == GrowthStage.friend;

    if (_useActions) {
      // 친구 단계 — 액션 10종 × 4프레임 (stepTime 0.18) 로드
      for (final action in TouriAction.values) {
        final frames = <Sprite>[];
        for (int i = 1; i <= 4; i++) {
          try {
            final img = await game.images
                .load('assets/character/actions/friend/${action.name}_$i.png');
            frames.add(Sprite(img));
          } catch (_) {
            // 프레임 누락 시 친구 기본 이미지로 폴백
            frames.add(Sprite(await game.images.load(stage.imagePath)));
          }
        }
        _actionAnims[action] =
            SpriteAnimation.spriteList(frames, stepTime: 0.18, loop: true);
      }
      _animation = _actionAnims[TouriAction.idle];
    } else {
      // 그 외 단계 — 기존 4프레임 spriteFramePaths (prefix='' 설정됨)
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
    }

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
    _currentAction = TouriAction.idle;
    _scheduleNextAction();
  }

  void _scheduleNextAction() {
    // 친구(액션 시스템)는 5-8초, 그 외는 2-5초
    _nextActionAt =
        _useActions ? _rng.nextDouble() * 3 + 5 : _rng.nextDouble() * 3 + 2;
  }

  /// 액션 sprite 교체 (친구 단계만). hold>0이면 그 시간 동안 고정 후 then 액션으로.
  void setAction(TouriAction action, {double hold = 0, TouriAction? then}) {
    if (!_useActions) return;
    _currentAction = action;
    final anim = _actionAnims[action];
    if (anim != null && _sprite != null) {
      _sprite!.animation = anim;
    }
    _actionHold = hold;
    _afterHold = then;
  }

  /// 가중 랜덤 액션: idle/walk 70% · jump/dance/wave 20% · sleep/sad/surprise 10%
  TouriAction _randomAction() {
    final r = _rng.nextDouble();
    if (r < 0.70) {
      return _rng.nextBool() ? TouriAction.idle : TouriAction.walk;
    } else if (r < 0.90) {
      const g = [TouriAction.jump, TouriAction.dance, TouriAction.wave];
      return g[_rng.nextInt(g.length)];
    } else {
      const g = [TouriAction.sleep, TouriAction.sad, TouriAction.surprise];
      return g[_rng.nextInt(g.length)];
    }
  }

  /// 친구 단계 자동 액션 사이클
  void _updateActionCycle(double dt) {
    if (_actionHold > 0) {
      _actionHold -= dt;
      if (_actionHold <= 0) {
        setAction(_afterHold ?? TouriAction.idle);
        _afterHold = null;
        _scheduleNextAction();
      }
      return;
    }
    _nextActionAt -= dt;
    if (_nextActionAt <= 0) {
      final action = _randomAction();
      if (action == TouriAction.walk) {
        final w = game.size.x;
        walkTo(50 + _rng.nextDouble() * (w - 100));
      } else {
        _targetX = position.x; // 제자리 액션
        if (action == TouriAction.jump) tapped();
      }
      setAction(action);
      _scheduleNextAction();
    }
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

  void celebrate() {
    if (_useActions) {
      // 딸기 먹기 → eat(0.72s) 후 happy 로 전환
      _targetX = position.x; // 먹는 동안 제자리
      setAction(TouriAction.eat, hold: 0.72, then: TouriAction.happy);
    } else {
      // 딸기 먹고 기뻐서 폴짝
      tapped();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 충돌 체크 (매 프레임 — 가벼움)
    game._checkCollisions();

    // 딸기가 있으면 가장 가까운 거 추적 (우선순위 ↑)
    final strawberry = game.nearestStrawberryPos;
    if (strawberry != null) {
      walkTo(strawberry.x);
      // 친구는 추적 중 walk 액션 (단, eat/happy 시퀀스 중엔 유지)
      if (_useActions &&
          _actionHold <= 0 &&
          _currentAction != TouriAction.walk) {
        setAction(TouriAction.walk);
      }
      _nextActionAt = 1.0; // 자동 행동 잠시 중단
    } else if (_useActions) {
      // 친구 단계 — 액션 sprite 자동 사이클
      _updateActionCycle(dt);
    } else {
      // 그 외 단계 — 가끔 새 위치로 걷거나 점프
      _nextActionAt -= dt;
      if (_nextActionAt <= 0) {
        if (_rng.nextDouble() < 0.7) {
          final w = game.size.x;
          walkTo(50 + _rng.nextDouble() * (w - 100));
        } else {
          tapped();
        }
        _scheduleNextAction();
      }
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

// ─── 딸기 (미니게임 Day 2) ──────────────────────
class _Strawberry extends PositionComponent {
  final double spawnX;
  final double spawnY;
  double _vy = 0;
  bool _onFloor = false;
  bool get isReady => _onFloor;
  double _bounceTimer = 0;

  _Strawberry({required this.spawnX, required this.spawnY}) {
    position = Vector2(spawnX, spawnY);
    size = Vector2(28, 32);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final game = parent as TouriFlameGame;
    final floorY = game.size.y - 50;

    if (!_onFloor) {
      // 자유 낙하
      _vy += 480 * dt; // gravity
      position.y += _vy * dt;
      if (position.y >= floorY) {
        position.y = floorY;
        _vy = -_vy * 0.4; // 통통 튐
        if (_vy.abs() < 30) {
          _vy = 0;
          _onFloor = true;
        }
      }
    } else {
      // 살짝 꿀렁
      _bounceTimer += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    // 잎 (위) — 초록
    final leaf = Paint()..color = const Color(0xFF8FAE5E);
    canvas.drawOval(Rect.fromLTWH(w*0.15, 0, w*0.7, h*0.25), leaf);
    canvas.drawOval(Rect.fromLTWH(w*0.05, h*0.05, w*0.4, h*0.18), leaf);
    canvas.drawOval(Rect.fromLTWH(w*0.55, h*0.05, w*0.4, h*0.18), leaf);
    // 줄기
    final stem = Paint()..color = const Color(0xFF6E8C4E);
    canvas.drawRect(Rect.fromLTWH(w*0.45, 0, w*0.1, h*0.15), stem);
    // 딸기 몸체 — 빨강 (살짝 꿀렁)
    final body = Paint()..color = const Color(0xFFE54D6F);
    final wobble = math.sin(_bounceTimer * 6) * 0.5;
    canvas.drawOval(
      Rect.fromLTWH(w*0.1, h*0.22 + wobble, w*0.8, h*0.72),
      body,
    );
    // 씨앗 (작은 노란 점)
    final seed = Paint()..color = const Color(0xFFFFE066);
    for (int i = 0; i < 6; i++) {
      final dx = (i % 3 - 1) * w * 0.25 + w * 0.5;
      final dy = (i ~/ 3) * h * 0.18 + h * 0.4;
      canvas.drawCircle(Offset(dx, dy), 1.5, seed);
    }
    // highlight (왼쪽 위)
    final hi = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawOval(Rect.fromLTWH(w*0.2, h*0.3, w*0.15, h*0.2), hi);
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
