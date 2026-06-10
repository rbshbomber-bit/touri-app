import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart' show Rectangle;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Color;

import '../models/growth_stage.dart';
import '../rpg/room_tilemap.dart';
import '../rpg/touri_player.dart';

/// 🏠 토우리 방 게임 — 토우리 키우기 화면용.
/// 8x6 작은 방, 가구 6종, 토우리 자동 걸음 + 가구 상호작용.
/// 마을(TouriRpgGame)과 동일한 비주얼 톤 + 같은 도트 토우리.
/// 문(door) 타일 위에서 A → onDoorEnter 콜백 → 마을로 점프.
class TouriRoomGame extends FlameGame with TapCallbacks {
  final GrowthStage stage;
  final void Function(String text)? onInteract;
  final void Function()? onDoorEnter;

  late TouriPlayer _player;
  late RoomTilemapComponent _tilemap;
  final math.Random _rng = math.Random();
  double _nextActionAt = 0;

  TouriRoomGame({
    required this.stage,
    this.onInteract,
    this.onDoorEnter,
  });

  TouriPlayer get player => _player;

  @override
  Color backgroundColor() => const Color(0xFFFFF0E8); // 크림핑크 (방 바닥과 동일)

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = '';

    // 타일맵
    _tilemap = RoomTilemapComponent();
    world.add(_tilemap);

    // 토우리 플레이어 (마을과 동일 sprite)
    final (sc, sr) = RoomMap.startTile;
    _player = TouriPlayer(col: sc, row: sr)..priority = 10;
    world.add(_player);

    // 카메라 — 줌인 + 방 전체 보기
    camera.viewfinder.zoom = 2.6;
    final mapW = RoomMap.width * RoomMap.tileSize;
    final mapH = RoomMap.height * RoomMap.tileSize;
    camera.setBounds(Rectangle.fromLTWH(0, 0, mapW, mapH));
    camera.viewfinder.position = Vector2(mapW / 2, mapH / 2);

    _scheduleNextAction();
  }

  void _scheduleNextAction() {
    _nextActionAt = _rng.nextDouble() * 3 + 4; // 4-7초
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 토우리 자동 행동 — 가끔 새 방향으로 이동
    if (_player.isMoving) return;
    _nextActionAt -= dt;
    if (_nextActionAt <= 0) {
      _autoRoam();
      _scheduleNextAction();
    }
  }

  /// 방 안에서 토우리가 알아서 돌아다님 (랜덤 방향 + 가능하면 이동)
  void _autoRoam() {
    final dirs = [
      TouriDirection.up,
      TouriDirection.down,
      TouriDirection.left,
      TouriDirection.right,
    ];
    dirs.shuffle(_rng);
    for (final d in dirs) {
      if (_player.tryMove(d)) return;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final worldPos = camera.globalToLocal(event.canvasPosition);
    final tc = (worldPos.x / RoomMap.tileSize).floor();
    final tr = (worldPos.y / RoomMap.tileSize).floor();
    final dc = tc - _player.col;
    final dr = tr - _player.row;

    // 인접 타일 탭 → 상호작용 or 이동
    if (dc.abs() + dr.abs() <= 1) {
      final t = RoomMap.tileAt(tc, tr);
      if (!t.walkable && t.interactKey != null) {
        // 가구 = 상호작용
        final dir = (dc > 0)
            ? TouriDirection.right
            : (dc < 0)
                ? TouriDirection.left
                : (dr > 0)
                    ? TouriDirection.down
                    : TouriDirection.up;
        _player.tryMove(dir);
        final text = RoomMap.interactionText(t);
        if (text.isNotEmpty) onInteract?.call(text);
        return;
      }
      if (t == RoomTileType.door) {
        // 문 = 마을 점프
        onDoorEnter?.call();
        return;
      }
    }

    // 방향 이동 (탭한 방향으로 한 타일)
    TouriDirection? dir;
    if (dc.abs() > dr.abs()) {
      dir = dc > 0 ? TouriDirection.right : TouriDirection.left;
    } else if (dr != 0) {
      dir = dr > 0 ? TouriDirection.down : TouriDirection.up;
    }
    if (dir != null) _player.tryMove(dir);
  }
}
