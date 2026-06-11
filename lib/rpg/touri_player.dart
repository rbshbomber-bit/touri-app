import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'town_effects.dart';
import 'town_tilemap.dart';

enum TouriDirection { down, up, left, right }

/// 토우리 플레이어 v2 — 자유 이동 물리.
/// 픽셀 단위 velocity + 가속/감속 + 축 분리 충돌(벽 슬라이딩).
/// D-pad 홀드 입력(8방향), 탭 목적지 이동, 타일 단위 호환 API(tryMove).
/// 기본은 마을(TownMap)이고, canWalkTile/worldSize 주입으로 방에서도 사용.
class TouriPlayer extends PositionComponent with HasGameReference {
  static const double maxSpeed = 92; // px/s
  static const double accel = 640;
  static const double decel = 780;
  static const double ts = TownMap.tileSize;

  TouriPlayer({
    required int col,
    required int row,
    bool Function(int col, int row)? canWalkTile,
    Vector2? worldSize,
  })  : canWalkTile = canWalkTile ?? TownMap.canWalk,
        _worldW = worldSize?.x ?? TownMap.pixelWidth,
        _worldH = worldSize?.y ?? TownMap.pixelHeight {
    size = Vector2.all(ts);
    anchor = Anchor.topLeft;
    position = Vector2(col * ts, row * ts);
  }

  /// 걷기 가능 여부 (타일 좌표) — 마을/방 맵 주입
  final bool Function(int col, int row) canWalkTile;
  final double _worldW;
  final double _worldH;

  /// D-pad/키보드가 매 프레임 넣어주는 입력 벡터 (정규화 전)
  final Vector2 input = Vector2.zero();

  /// 목적지 (발 중심 기준 월드 좌표) — 탭 이동/tryMove가 설정
  Vector2? moveTarget;

  final Vector2 velocity = Vector2.zero();
  TouriDirection direction = TouriDirection.down;

  double _dustTimer = 0;
  double _blockedT = 0;
  bool _walking = false;
  TouriDirection? _animDir;

  late SpriteAnimationComponent _sprite;
  final Map<TouriDirection, SpriteAnimation> _anims = {};

  /// 발 중심 (충돌·상호작용 기준점)
  Vector2 get feetCenter => Vector2(position.x + 16, position.y + 24);

  /// 발밑 히트박스 — 머리는 타일에 살짝 겹쳐도 OK (탑다운 자연스러움)
  Rect get _feetRect =>
      Rect.fromLTWH(position.x + 7, position.y + 18, 18, 12);

  (int, int) get feetTile =>
      ((feetCenter.x / ts).floor(), (feetCenter.y / ts).floor());

  /// 현재 타일 좌표 (구버전 호환)
  int get col => feetTile.$1;
  int get row => feetTile.$2;

  /// 이동 중 여부 (구버전 호환)
  bool get isMoving => moveTarget != null || velocity.length2 > 25;

  /// 타일 한 칸 이동 시도 (구버전 호환 — 방 게임의 자동 산책 등).
  /// 막히면 방향만 바꾸고 false.
  bool tryMove(TouriDirection dir) {
    if (isMoving) return false;
    direction = dir;
    _applyDirection(dir);
    final (c, r) = feetTile;
    final (dc, dr) = _delta(dir);
    final nc = c + dc;
    final nr = r + dr;
    if (!canWalkTile(nc, nr)) return false;
    moveTarget = Vector2(nc * ts + 16, nr * ts + 24);
    return true;
  }

  static (int, int) _delta(TouriDirection dir) => switch (dir) {
        TouriDirection.up => (0, -1),
        TouriDirection.down => (0, 1),
        TouriDirection.left => (-1, 0),
        TouriDirection.right => (1, 0),
      };

  /// 토우리 정면 한 타일 (상호작용 대상)
  (int, int) get facingTile {
    final (c, r) = feetTile;
    final (dc, dr) = _delta(direction);
    return (c + dc, r + dr);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations();
    _sprite = SpriteAnimationComponent(
      animation: _anims[direction],
      size: Vector2.all(ts),
    );
    add(_sprite);
    _sprite.playing = false;
  }

  Future<void> _loadAnimations() async {
    Future<SpriteAnimation> loadDir(String dirName) async {
      final frames = <Sprite>[];
      for (int i = 1; i <= 4; i++) {
        final img = await game.images.load(
          'assets/character/rpg_sprites/touri_${dirName}_$i.png',
        );
        frames.add(Sprite(img));
      }
      return SpriteAnimation.spriteList(frames, stepTime: 0.15, loop: true);
    }

    _anims[TouriDirection.down] = await loadDir('down');
    _anims[TouriDirection.up] = await loadDir('up');
    _anims[TouriDirection.right] = await loadDir('right');
    _anims[TouriDirection.left] = await loadDir('right'); // 좌우 반전
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1) 원하는 방향 — D-pad 입력 우선, 없으면 목적지
    Vector2 desired = Vector2.zero();
    if (input.length2 > 0) {
      desired = input.normalized();
    } else if (moveTarget != null) {
      final d = moveTarget! - feetCenter;
      if (d.length < 5) {
        moveTarget = null;
      } else {
        desired = d.normalized();
      }
    }

    // 2) 가속/감속
    final targetV = desired * maxSpeed;
    final dv = targetV - velocity;
    final rate = desired.length2 > 0 ? accel : decel;
    final step = rate * dt;
    if (dv.length <= step) {
      velocity.setFrom(targetV);
    } else {
      velocity.add(dv.normalized() * step);
    }

    // 3) 축 분리 이동 → 벽에 비스듬히 닿으면 미끄러짐
    bool blocked = false;
    if (velocity.length2 > 0.5) {
      final dx = velocity.x * dt;
      final dy = velocity.y * dt;
      if (dx != 0) {
        if (_rectWalkable(_feetRect.translate(dx, 0))) {
          position.x += dx;
        } else {
          velocity.x = 0;
          blocked = true;
        }
      }
      if (dy != 0) {
        if (_rectWalkable(_feetRect.translate(0, dy))) {
          position.y += dy;
        } else {
          velocity.y = 0;
          blocked = true;
        }
      }
      position.x = position.x.clamp(0.0, _worldW - size.x).toDouble();
      position.y = position.y.clamp(0.0, _worldH - size.y).toDouble();
    }

    // 4) 목적지로 가다가 막히면 잠시 후 포기
    if (moveTarget != null && blocked && velocity.length < 18) {
      _blockedT += dt;
      if (_blockedT > 0.45) {
        moveTarget = null;
        _blockedT = 0;
      }
    } else {
      _blockedT = 0;
    }

    // 5) 방향·애니메이션·발먼지
    final speed = velocity.length;
    if (speed > 10) {
      direction = velocity.x.abs() > velocity.y.abs()
          ? (velocity.x > 0 ? TouriDirection.right : TouriDirection.left)
          : (velocity.y > 0 ? TouriDirection.down : TouriDirection.up);
      _applyDirection(direction);
      _setWalking(true);
      _dustTimer -= dt;
      if (_dustTimer <= 0) {
        _dustTimer = 0.22;
        parent?.add(DustPuff(feetCenter + Vector2(0, 5)));
      }
    } else {
      _setWalking(false);
      _dustTimer = 0;
    }
  }

  bool _rectWalkable(Rect rect) {
    final c0 = (rect.left / ts).floor();
    final c1 = ((rect.right - 0.001) / ts).floor();
    final r0 = (rect.top / ts).floor();
    final r1 = ((rect.bottom - 0.001) / ts).floor();
    for (int r = r0; r <= r1; r++) {
      for (int c = c0; c <= c1; c++) {
        if (!canWalkTile(c, r)) return false;
      }
    }
    return true;
  }

  void _applyDirection(TouriDirection dir) {
    if (_animDir == dir || _anims.isEmpty) return;
    _animDir = dir;
    _sprite.animation = _anims[dir];
    final left = dir == TouriDirection.left;
    _sprite.scale = left ? Vector2(-1, 1) : Vector2(1, 1);
    _sprite.anchor = left ? Anchor.topRight : Anchor.topLeft;
    _sprite.position = left ? Vector2(ts, 0) : Vector2.zero();
  }

  void _setWalking(bool w) {
    if (_walking == w || _anims.isEmpty) return;
    _walking = w;
    _sprite.playing = w;
    if (!w) _sprite.animationTicker?.reset();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 발밑 그림자
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(16, 28), width: 18, height: 7),
      Paint()..color = const Color(0x2E805060),
    );
  }
}
