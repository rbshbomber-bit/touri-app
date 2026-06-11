import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart' show Rectangle;
import 'package:flame/game.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'touri_npc.dart';
import 'touri_player.dart';
import 'town_effects.dart';
import 'town_tilemap.dart';

/// 토우리 마을 RPG v2.
/// - 32x24 타일맵 (1024x768 월드) — 광장·분수·연못·다리·카페·정원
/// - 자유 이동 물리 (가속·감속·벽 슬라이딩), D-pad 홀드 / 탭 / 키보드(WASD·화살표)
/// - 동물 주민 3마리 (말 걸기 가능)
/// - 벚꽃잎·물결·발먼지·낮밤 분위기
class TouriRpgGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks {
  TouriRpgGame({this.onInteract});

  /// 상호작용 시 Flutter 다이얼로그에 표시할 텍스트 콜백
  final void Function(String text)? onInteract;

  late TouriPlayer _player;
  final List<TouriNpc> _npcs = [];
  final Set<TouriDirection> _held = {};

  TouriPlayer get player => _player;

  @override
  Color backgroundColor() => const Color(0xFFFADDE2);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = '';

    world.add(TownTilemapComponent());

    // 플레이어
    final (sc, sr) = TownMap.startTile;
    _player = TouriPlayer(col: sc, row: sr)..priority = 10;
    world.add(_player);

    // 동물 주민
    _npcs.addAll([
      TouriNpc(
        kind: NpcKind.duck,
        col: 26,
        row: 13,
        seed: 1,
        lines: const [
          '🦆 꽥! 연못 물이 딱 좋아~',
          '🦆 다리 밑은 내 비밀 낮잠 장소야',
          '🦆 토우리랑 산책하니까 좋다. 사랑 +1',
        ],
      ),
      TouriNpc(
        kind: NpcKind.cat,
        col: 6,
        row: 17,
        seed: 2,
        lines: const [
          '🐱 야옹. 꽃밭에서 낮잠 자는 중이야',
          '🐱 토우리 털은 어쩜 그렇게 분홍분홍해?',
          '🐱 골골골… 쓰다듬어줘서 고마워. 사랑 +1',
        ],
      ),
      TouriNpc(
        kind: NpcKind.bird,
        col: 13,
        row: 8,
        seed: 3,
        lines: const [
          '🐦 짹짹! 분수 물방울이 시원해',
          '🐦 마을에서 제일 빠른 건 나야!',
          '🐦 노래 불러줄게~ 행복 +1',
        ],
      ),
    ]);
    world.addAll(_npcs);

    // 벚꽃잎
    world.add(PetalLayer(mapW: TownMap.pixelWidth, mapH: TownMap.pixelHeight));

    // 카메라
    camera.viewfinder.zoom = 2.2;
    camera.follow(_player, maxSpeed: 480);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, TownMap.pixelWidth, TownMap.pixelHeight),
      considerViewport: true,
    );
    camera.viewport.add(DayNightOverlay());

    // 키보드 (웹) — 화살표 + WASD
    bool down(TouriDirection d) {
      pressDir(d);
      return true;
    }

    bool up(TouriDirection d) {
      releaseDir(d);
      return true;
    }

    add(KeyboardListenerComponent(
      keyDown: {
        LogicalKeyboardKey.arrowUp: (_) => down(TouriDirection.up),
        LogicalKeyboardKey.arrowDown: (_) => down(TouriDirection.down),
        LogicalKeyboardKey.arrowLeft: (_) => down(TouriDirection.left),
        LogicalKeyboardKey.arrowRight: (_) => down(TouriDirection.right),
        LogicalKeyboardKey.keyW: (_) => down(TouriDirection.up),
        LogicalKeyboardKey.keyS: (_) => down(TouriDirection.down),
        LogicalKeyboardKey.keyA: (_) => down(TouriDirection.left),
        LogicalKeyboardKey.keyD: (_) => down(TouriDirection.right),
        LogicalKeyboardKey.space: (_) {
          interact();
          return true;
        },
      },
      keyUp: {
        LogicalKeyboardKey.arrowUp: (_) => up(TouriDirection.up),
        LogicalKeyboardKey.arrowDown: (_) => up(TouriDirection.down),
        LogicalKeyboardKey.arrowLeft: (_) => up(TouriDirection.left),
        LogicalKeyboardKey.arrowRight: (_) => up(TouriDirection.right),
        LogicalKeyboardKey.keyW: (_) => up(TouriDirection.up),
        LogicalKeyboardKey.keyS: (_) => up(TouriDirection.down),
        LogicalKeyboardKey.keyA: (_) => up(TouriDirection.left),
        LogicalKeyboardKey.keyD: (_) => up(TouriDirection.right),
      },
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 홀드 중인 방향 → 입력 벡터 (대각선 허용)
    final v = _player.input..setZero();
    if (_held.contains(TouriDirection.up)) v.y -= 1;
    if (_held.contains(TouriDirection.down)) v.y += 1;
    if (_held.contains(TouriDirection.left)) v.x -= 1;
    if (_held.contains(TouriDirection.right)) v.x += 1;
  }

  // ── 입력 API (D-pad / 키보드) ──

  void pressDir(TouriDirection d) {
    _held.add(d);
    _player.moveTarget = null;
  }

  void releaseDir(TouriDirection d) {
    _held.remove(d);
  }

  /// 다이얼로그가 뜰 때 입력 상태 초기화 (버튼 up 이벤트 유실 대비)
  void clearInput() {
    _held.clear();
    _player.input.setZero();
    _player.moveTarget = null;
  }

  /// A 버튼 — 가까운 동물 친구 우선, 없으면 정면 타일 상호작용
  void interact() {
    final npc = _nearestNpc(54);
    if (npc != null) {
      onInteract?.call(npc.nextLine());
      return;
    }
    final (fc, fr) = _player.facingTile;
    final t = TownMap.tileAt(fc, fr);
    final text = TownMap.interactionText(t);
    if (text.isNotEmpty) {
      onInteract?.call(text);
    }
  }

  TouriNpc? _nearestNpc(double maxDist) {
    TouriNpc? best;
    var bestD = maxDist;
    for (final n in _npcs) {
      final d = (n.centerPoint - _player.feetCenter).length;
      if (d < bestD) {
        bestD = d;
        best = n;
      }
    }
    return best;
  }

  /// 발먼지 스폰 (플레이어가 호출)
  void spawnDust(Vector2 pos) {
    world.add(DustPuff(pos));
  }

  /// 탭: 가까운 동물/타일이면 상호작용, 아니면 그 지점으로 걸어가기
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final worldPos = camera.globalToLocal(event.canvasPosition);

    // 동물 친구 탭
    for (final n in _npcs) {
      if (n.toRect().contains(worldPos.toOffset())) {
        if ((n.centerPoint - _player.feetCenter).length < 80) {
          onInteract?.call(n.nextLine());
          return;
        }
        break; // 멀면 그쪽으로 걸어감
      }
    }

    // 인접한 상호작용 타일 탭
    final tc = (worldPos.x / TownMap.tileSize).floor();
    final tr = (worldPos.y / TownMap.tileSize).floor();
    final t = TownMap.tileAt(tc, tr);
    final (pc, pr) = _player.feetTile;
    if (!t.walkable &&
        t.interactKey != null &&
        (tc - pc).abs() + (tr - pr).abs() <= 2) {
      final text = TownMap.interactionText(t);
      if (text.isNotEmpty) onInteract?.call(text);
      return;
    }

    // 자유 이동 목적지
    _player.moveTarget = Vector2(
      worldPos.x.clamp(8.0, TownMap.pixelWidth - 8.0).toDouble(),
      worldPos.y.clamp(8.0, TownMap.pixelHeight - 8.0).toDouble(),
    );
  }
}
