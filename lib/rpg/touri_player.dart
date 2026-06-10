import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'town_tilemap.dart';

enum TouriDirection { down, up, left, right }

/// 토우리 플레이어 — 4방향 sprite + 타일 단위 부드러운 이동.
/// 타일 사이를 0.25초에 걸쳐 보간. 이동 중에는 새 입력 무시.
class TouriPlayer extends PositionComponent with HasGameReference {
  static const double moveDuration = 0.22; // 한 타일 이동 시간 (초)

  // 현재 타일 좌표
  int col;
  int row;

  TouriDirection direction = TouriDirection.down;

  // 이동 보간
  Vector2? _moveFrom;
  Vector2? _moveTo;
  double _moveT = 0;
  bool get isMoving => _moveTo != null;

  // 애니메이션
  late SpriteAnimationComponent _sprite;
  final Map<TouriDirection, SpriteAnimation> _anims = {};
  int _stepCounter = 0; // 걸음 카운터 — 0/2 → idle frame, 1 → left, 3 → right

  TouriPlayer({required this.col, required this.row}) {
    size = Vector2.all(TownMap.tileSize);
    anchor = Anchor.topLeft;
    position = Vector2(col * TownMap.tileSize, row * TownMap.tileSize);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await _loadAnimations();
    _sprite = SpriteAnimationComponent(
      animation: _anims[direction],
      size: Vector2.all(TownMap.tileSize),
    );
    add(_sprite);
  }

  Future<void> _loadAnimations() async {
    Future<SpriteAnimation> loadDir(String dirName, {bool flip = false}) async {
      final frames = <Sprite>[];
      for (int i = 1; i <= 4; i++) {
        final img = await game.images.load(
          'assets/character/rpg_sprites/touri_${dirName}_$i.png',
        );
        frames.add(Sprite(img));
      }
      final anim = SpriteAnimation.spriteList(
        frames,
        stepTime: 0.18,
        loop: true,
      );
      return anim;
    }

    _anims[TouriDirection.down] = await loadDir('down');
    _anims[TouriDirection.up] = await loadDir('up');
    _anims[TouriDirection.right] = await loadDir('right');
    // left = right flipped
    final right = await loadDir('right');
    _anims[TouriDirection.left] = right;
  }

  /// 타일 단위 이동 시도. 이동 가능하면 true.
  bool tryMove(TouriDirection dir) {
    if (isMoving) return false;
    direction = dir;
    final (dc, dr) = switch (dir) {
      TouriDirection.up => (0, -1),
      TouriDirection.down => (0, 1),
      TouriDirection.left => (-1, 0),
      TouriDirection.right => (1, 0),
    };
    final newCol = col + dc;
    final newRow = row + dr;
    // 애니메이션 + 방향 sprite 교체 (이동 못해도 방향은 바뀜)
    _sprite.animation = _anims[dir];
    _sprite.scale = (dir == TouriDirection.left) ? Vector2(-1, 1) : Vector2(1, 1);
    _sprite.anchor = (dir == TouriDirection.left) ? Anchor.topRight : Anchor.topLeft;
    _sprite.position = (dir == TouriDirection.left)
        ? Vector2(TownMap.tileSize, 0)
        : Vector2.zero();
    if (!TownMap.canWalk(newCol, newRow)) {
      return false; // 충돌 — 방향만 바뀌고 이동은 안 함
    }
    col = newCol;
    row = newRow;
    _moveFrom = position.clone();
    _moveTo = Vector2(newCol * TownMap.tileSize, newRow * TownMap.tileSize);
    _moveT = 0;
    _stepCounter = (_stepCounter + 1) % 4;
    return true;
  }

  /// 토우리 정면 한 타일 (상호작용 대상)
  (int, int) get facingTile {
    final (dc, dr) = switch (direction) {
      TouriDirection.up => (0, -1),
      TouriDirection.down => (0, 1),
      TouriDirection.left => (-1, 0),
      TouriDirection.right => (1, 0),
    };
    return (col + dc, row + dr);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_moveTo != null && _moveFrom != null) {
      _moveT += dt / moveDuration;
      if (_moveT >= 1.0) {
        position = _moveTo!;
        _moveTo = null;
        _moveFrom = null;
        _moveT = 0;
      } else {
        position = _moveFrom! + (_moveTo! - _moveFrom!) * _moveT;
      }
    }
  }
}
