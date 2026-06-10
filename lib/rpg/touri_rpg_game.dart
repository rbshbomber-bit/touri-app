import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart' show Rectangle;
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color, Colors;

import 'town_tilemap.dart';
import 'touri_player.dart';

/// 토우리 마을 RPG 게임.
/// - 16x12 타일맵 (512x384 월드)
/// - 토우리 플레이어 (타일 단위 이동)
/// - 카메라 follow + 줌인
/// - D-pad / 탭 이동 (Flutter 위 D-pad가 입력 호출)
/// - 충돌 + 상호작용 → onInteract 콜백 → 다이얼로그
class TouriRpgGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks {
  /// 상호작용 시 Flutter 다이얼로그에 표시할 텍스트 콜백
  final void Function(String text)? onInteract;

  late TouriPlayer _player;
  late TownTilemapComponent _tilemap;

  TouriRpgGame({this.onInteract});

  TouriPlayer get player => _player;

  @override
  Color backgroundColor() => const Color(0xFFA8D5A2);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = '';

    // 타일맵
    _tilemap = TownTilemapComponent();
    world.add(_tilemap);

    // 플레이어
    final (sc, sr) = TownMap.startTile;
    _player = TouriPlayer(col: sc, row: sr)..priority = 10;
    world.add(_player);

    // 카메라 — 토우리 따라가기 + 줌인
    camera.viewfinder.zoom = 2.4;
    camera.follow(_player, maxSpeed: 240);

    // 카메라 경계 — 마을 밖으로 안 나가게
    final mapW = TownMap.width * TownMap.tileSize;
    final mapH = TownMap.height * TownMap.tileSize;
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, mapW, mapH),
    );
  }

  /// D-pad에서 호출 — 토우리 이동 시도
  void moveDir(TouriDirection dir) {
    _player.tryMove(dir);
  }

  /// A 버튼 누름 — 토우리 정면 타일 상호작용
  void interact() {
    final (fc, fr) = _player.facingTile;
    final t = TownMap.tileAt(fc, fr);
    final text = TownMap.interactionText(t);
    if (text.isNotEmpty) {
      onInteract?.call(text);
    }
  }

  /// 탭 이동: 탭한 화면 위치 → 월드 좌표 → 그 타일 방향으로 한 칸
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final worldPos = camera.globalToLocal(event.canvasPosition);
    final tc = (worldPos.x / TownMap.tileSize).floor();
    final tr = (worldPos.y / TownMap.tileSize).floor();
    final dc = tc - _player.col;
    final dr = tr - _player.row;
    // 상호작용 가능 타일을 탭했고 인접하면 → 상호작용
    if (dc.abs() + dr.abs() <= 1) {
      final t = TownMap.tileAt(tc, tr);
      if (!t.walkable && t.interactKey != null) {
        // 인접 타일 = 상호작용
        final dir = (dc > 0)
            ? TouriDirection.right
            : (dc < 0)
                ? TouriDirection.left
                : (dr > 0)
                    ? TouriDirection.down
                    : TouriDirection.up;
        _player.tryMove(dir); // 방향만 돌고 이동 X (충돌)
        final text = TownMap.interactionText(t);
        if (text.isNotEmpty) onInteract?.call(text);
        return;
      }
    }
    // 그 외 — 그 방향으로 한 타일 이동
    final TouriDirection? dir;
    if (dc.abs() > dr.abs()) {
      dir = dc > 0 ? TouriDirection.right : TouriDirection.left;
    } else if (dr != 0) {
      dir = dr > 0 ? TouriDirection.down : TouriDirection.up;
    } else {
      dir = null;
    }
    if (dir != null) _player.tryMove(dir);
  }
}
