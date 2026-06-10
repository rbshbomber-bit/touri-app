import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

/// 토우리 마을 타일맵.
/// 32x32 픽셀 타일 × 16x12 그리드 = 512x384 마을 크기.
/// 0=풀밭 1=길 2=나무 3=집 4=꽃 5=표지판 6=우물 7=벤치

enum TileType {
  grass(walkable: true),
  path(walkable: true),
  tree(walkable: false, interactKey: 'tree'),
  house(walkable: false, interactKey: 'house'),
  flower(walkable: true, interactKey: 'flower'),
  sign(walkable: false, interactKey: 'sign'),
  well(walkable: false, interactKey: 'well'),
  bench(walkable: false, interactKey: 'bench');

  final bool walkable;
  final String? interactKey;
  const TileType({required this.walkable, this.interactKey});
}

class TownMap {
  static const int width = 16;
  static const int height = 12;
  static const double tileSize = 32.0;

  /// 16x12 타일 그리드
  /// 2=나무 0=풀밭 3=집 1=길 4=꽃 5=표지판 6=우물 7=벤치
  static const List<List<int>> grid = [
    [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
    [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2],
    [2, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 2],
    [2, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 2],
    [2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 2],
    [2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2],
    [2, 0, 0, 1, 0, 0, 0, 6, 0, 0, 0, 0, 1, 0, 0, 2],
    [2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2],
    [2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 2],
    [2, 0, 0, 0, 0, 4, 4, 0, 5, 0, 7, 0, 0, 0, 0, 2],
    [2, 0, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 4, 4, 0, 2],
    [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
  ];

  /// 토우리 시작 타일 (중앙 약간)
  static const startTile = (8, 6);

  static TileType tileAt(int col, int row) {
    if (col < 0 || col >= width || row < 0 || row >= height) {
      return TileType.tree; // 경계 = 충돌
    }
    final v = grid[row][col];
    return TileType.values[v];
  }

  static bool canWalk(int col, int row) => tileAt(col, row).walkable;

  /// 타일 종류별 한 줄 대화 (모던 다이얼로그에 표시)
  static String interactionText(TileType t) {
    switch (t) {
      case TileType.tree:
        return '🌳 시원한 그늘이 있어. 잠깐 쉬어갈까?';
      case TileType.house:
        return '🏠 집에 들어갈래?\n사랑 +1';
      case TileType.flower:
        return '🌸 분홍 꽃을 한 송이 땄어. 행복 +1';
      case TileType.sign:
        return '🪧 「토우리 마을에 어서와 ♡」';
      case TileType.well:
        return '💧 우물물이 맑아. 에너지 +1';
      case TileType.bench:
        return '🪑 벤치에 같이 앉았어. 사랑 +1';
      default:
        return '';
    }
  }
}

/// 타일맵을 한 번에 그리는 컴포넌트.
/// 각 타일 = 단순 컬러 + 작은 도트 디테일 (Flame Canvas로 직접).
class TownTilemapComponent extends Component with HasGameReference {
  TownTilemapComponent() {
    priority = 0;
  }

  static const _grass = Color(0xFFA8D5A2);
  static const _grassDark = Color(0xFF8FBE89);
  static const _grassDot = Color(0xFF7AA875);
  static const _path = Color(0xFFE6CFA5);
  static const _pathDark = Color(0xFFD0B886);
  static const _treeTrunk = Color(0xFF7E5A3C);
  static const _treeLeaf = Color(0xFF4F8A4A);
  static const _treeLeafLight = Color(0xFF74A86E);
  static const _houseWall = Color(0xFFFFE9EF);
  static const _houseRoof = Color(0xFFE8A0B5);
  static const _houseDoor = Color(0xFF8B5A6E);
  static const _flowerPink = Color(0xFFFBA5C0);
  static const _flowerCenter = Color(0xFFFCE783);
  static const _signWood = Color(0xFF9C7654);
  static const _wellStone = Color(0xFF9C9CA8);
  static const _wellWater = Color(0xFF6FA9C8);
  static const _benchWood = Color(0xFFB58860);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const ts = TownMap.tileSize;
    for (int r = 0; r < TownMap.height; r++) {
      for (int c = 0; c < TownMap.width; c++) {
        final v = TownMap.grid[r][c];
        final t = TileType.values[v];
        final x = c * ts;
        final y = r * ts;
        // 모든 타일 아래 풀밭 깔기
        _drawGrass(canvas, x, y, c, r);
        // 타일 종류별 위에 그리기
        switch (t) {
          case TileType.path:
            _drawPath(canvas, x, y);
            break;
          case TileType.tree:
            _drawTree(canvas, x, y);
            break;
          case TileType.house:
            _drawHouse(canvas, x, y, c, r);
            break;
          case TileType.flower:
            _drawFlower(canvas, x, y);
            break;
          case TileType.sign:
            _drawSign(canvas, x, y);
            break;
          case TileType.well:
            _drawWell(canvas, x, y);
            break;
          case TileType.bench:
            _drawBench(canvas, x, y);
            break;
          case TileType.grass:
            break;
        }
      }
    }
  }

  void _drawGrass(Canvas canvas, double x, double y, int c, int r) {
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), Paint()..color = _grass);
    // 풀잎 도트 (시드 = c,r → 확정적)
    final rng = math.Random((c * 31 + r * 17) & 0xFFFF);
    final n = 3 + rng.nextInt(3);
    for (int i = 0; i < n; i++) {
      final dx = rng.nextDouble() * 30 + 1;
      final dy = rng.nextDouble() * 30 + 1;
      canvas.drawRect(
        Rect.fromLTWH(x + dx, y + dy, 2, 2),
        Paint()..color = rng.nextBool() ? _grassDark : _grassDot,
      );
    }
  }

  void _drawPath(Canvas canvas, double x, double y) {
    canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, 30, 30), Paint()..color = _path);
    // 가장자리 살짝 진하게
    final dark = Paint()..color = _pathDark;
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x, y + 31, 32, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x, y, 1, 32), dark);
    canvas.drawRect(Rect.fromLTWH(x + 31, y, 1, 32), dark);
    // 작은 자갈 (확정적)
    final rng = math.Random(((x.toInt() * 13) ^ y.toInt()) & 0xFFFF);
    for (int i = 0; i < 4; i++) {
      final dx = rng.nextDouble() * 28 + 2;
      final dy = rng.nextDouble() * 28 + 2;
      canvas.drawRect(Rect.fromLTWH(x + dx, y + dy, 2, 2), dark);
    }
  }

  void _drawTree(Canvas canvas, double x, double y) {
    // 트렁크
    canvas.drawRect(
      Rect.fromLTWH(x + 13, y + 20, 6, 10),
      Paint()..color = _treeTrunk,
    );
    // 잎 (원형 도트)
    final leaf = Paint()..color = _treeLeaf;
    final leafLight = Paint()..color = _treeLeafLight;
    canvas.drawOval(Rect.fromLTWH(x + 4, y + 4, 24, 20), leaf);
    canvas.drawOval(Rect.fromLTWH(x + 6, y + 5, 8, 6), leafLight);
    canvas.drawOval(Rect.fromLTWH(x + 18, y + 6, 6, 5), leafLight);
    // 잎 사이 작은 그림자 점
    canvas.drawRect(
      Rect.fromLTWH(x + 14, y + 14, 2, 2),
      Paint()..color = const Color(0xFF3C6B3A),
    );
  }

  /// 집은 2x2 타일에 걸쳐 그리되, 좌상단 타일에서만 한 번 그림.
  void _drawHouse(Canvas canvas, double x, double y, int c, int r) {
    // 좌상단 한 번만 (오른쪽 / 아래 / 대각선 타일은 스킵)
    if (c > 0 && TownMap.grid[r][c - 1] == 3) return;
    if (r > 0 && TownMap.grid[r - 1][c] == 3) return;

    final w = 64.0; // 2 tile wide
    final h = 64.0; // 2 tile tall
    // 지붕 (사다리꼴 흉내 — 삼각형 도트)
    final roof = Paint()..color = _houseRoof;
    final roofDark = Paint()..color = const Color(0xFFCC7A92);
    // 삼각 지붕 그리기 (정수 좌표)
    for (int i = 0; i < 16; i++) {
      canvas.drawRect(
        Rect.fromLTWH(x + i * 2.0, y + i * 1.0, w - i * 4.0, 1),
        roof,
      );
    }
    // 지붕 그림자 라인
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 16, w - 4, 2), roofDark);
    // 벽
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 18, w - 8, h - 22), Paint()..color = _houseWall);
    // 벽 outline
    final outline = Paint()
      ..color = const Color(0xFF8B5A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 18, w - 8, h - 22), outline);
    // 문
    canvas.drawRect(
      Rect.fromLTWH(x + 28, y + 42, 8, 18),
      Paint()..color = _houseDoor,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + 33, y + 50, 1, 2),
      Paint()..color = Colors.amber,
    );
    // 창문
    final window = Paint()..color = const Color(0xFFB0DDF0);
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 26, 8, 8), window);
    canvas.drawRect(Rect.fromLTWH(x + 46, y + 26, 8, 8), window);
    // 창문 틀
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 26, 8, 8), outline);
    canvas.drawRect(Rect.fromLTWH(x + 46, y + 26, 8, 8), outline);
    canvas.drawLine(Offset(x + 14, y + 26), Offset(x + 14, y + 34), outline);
    canvas.drawLine(Offset(x + 10, y + 30), Offset(x + 18, y + 30), outline);
  }

  void _drawFlower(Canvas canvas, double x, double y) {
    final petal = Paint()..color = _flowerPink;
    final center = Paint()..color = _flowerCenter;
    // 5개 꽃잎
    canvas.drawCircle(Offset(x + 16, y + 8), 3, petal);
    canvas.drawCircle(Offset(x + 10, y + 14), 3, petal);
    canvas.drawCircle(Offset(x + 22, y + 14), 3, petal);
    canvas.drawCircle(Offset(x + 12, y + 22), 3, petal);
    canvas.drawCircle(Offset(x + 20, y + 22), 3, petal);
    // 중심
    canvas.drawCircle(Offset(x + 16, y + 16), 3, center);
    // 잎
    canvas.drawOval(Rect.fromLTWH(x + 13, y + 24, 6, 4), Paint()..color = _treeLeafLight);
  }

  void _drawSign(Canvas canvas, double x, double y) {
    final wood = Paint()..color = _signWood;
    final dark = Paint()..color = const Color(0xFF6F4F32);
    // 기둥
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 18, 4, 12), dark);
    // 판
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 8, 24, 14), wood);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 8, 24, 14),
        Paint()
          ..color = const Color(0xFF4F3A24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    // 글씨 라인
    canvas.drawRect(Rect.fromLTWH(x + 7, y + 12, 18, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x + 7, y + 16, 14, 1), dark);
  }

  void _drawWell(Canvas canvas, double x, double y) {
    final stone = Paint()..color = _wellStone;
    final water = Paint()..color = _wellWater;
    final dark = Paint()..color = const Color(0xFF7878A0);
    // 우물 본체
    canvas.drawOval(Rect.fromLTWH(x + 4, y + 14, 24, 14), stone);
    // 물
    canvas.drawOval(Rect.fromLTWH(x + 8, y + 16, 16, 10), water);
    // 우물 위 지붕 기둥
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 4, 2, 14), dark);
    canvas.drawRect(Rect.fromLTWH(x + 25, y + 4, 2, 14), dark);
    // 지붕
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 28, 4), Paint()..color = const Color(0xFFB57272));
    // 물 반사
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 18, 4, 1), Paint()..color = Colors.white);
  }

  void _drawBench(Canvas canvas, double x, double y) {
    final wood = Paint()..color = _benchWood;
    final dark = Paint()..color = const Color(0xFF8B6440);
    // 등받이
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 4), wood);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 1), dark);
    // 좌석
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 20, 24, 4), wood);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 23, 24, 1), dark);
    // 다리
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 24, 2, 6), dark);
    canvas.drawRect(Rect.fromLTWH(x + 24, y + 24, 2, 6), dark);
  }
}
