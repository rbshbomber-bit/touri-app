import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'town_effects.dart';

/// 토우리 마을 타일맵 v2.
/// 32x24 타일 (32px) = 1024x768 월드 — 기존의 4배.
/// 광장·분수·연못·다리·카페·꽃밭 정원 + 살아있는 연출
/// (물결, 분수 물줄기, 나무 흔들림, 밤 가로등·창문 불빛)
enum TileType {
  grass(walkable: true),
  path(walkable: true),
  tree(walkable: false, interactKey: 'tree'),
  house(walkable: false, interactKey: 'house'),
  flower(walkable: true, interactKey: 'flower'),
  sign(walkable: false, interactKey: 'sign'),
  well(walkable: false, interactKey: 'well'),
  bench(walkable: false, interactKey: 'bench'),
  water(walkable: false, interactKey: 'water'),
  bridge(walkable: true),
  fountain(walkable: false, interactKey: 'fountain'),
  cafe(walkable: false, interactKey: 'cafe'),
  lamp(walkable: false, interactKey: 'lamp');

  final bool walkable;
  final String? interactKey;
  const TileType({required this.walkable, this.interactKey});
}

class TownMap {
  static const int width = 32;
  static const int height = 24;
  static const double tileSize = 32.0;

  static double get pixelWidth => width * tileSize;
  static double get pixelHeight => height * tileSize;

  /// 토우리 시작 타일 (광장 안, 분수 아래)
  static const startTile = (14, 13);

  static final List<List<int>> grid = _build();

  static List<List<int>> _build() {
    final g = List.generate(height, (_) => List<int>.filled(width, 0));
    void put(int c, int r, int v) {
      if (c >= 0 && c < width && r >= 0 && r < height) g[r][c] = v;
    }

    void fill(int c0, int r0, int w, int h, int v) {
      for (int r = r0; r < r0 + h; r++) {
        for (int c = c0; c < c0 + w; c++) {
          put(c, r, v);
        }
      }
    }

    // 1) 테두리 숲
    fill(0, 0, width, 1, 2);
    fill(0, height - 1, width, 1, 2);
    fill(0, 0, 1, height, 2);
    fill(width - 1, 0, 1, height, 2);

    // 2) 안쪽 랜덤 나무·들꽃 (확정적 시드)
    final rng = math.Random(7);
    for (int r = 1; r < height - 1; r++) {
      for (int c = 1; c < width - 1; c++) {
        final v = rng.nextDouble();
        final nearEdge = r <= 2 || r >= height - 3 || c <= 1 || c >= width - 2;
        if (nearEdge && v < 0.30) {
          put(c, r, 2);
        } else if (v < 0.045) {
          put(c, r, 2);
        } else if (v < 0.10) {
          put(c, r, 4);
        }
      }
    }

    // 3) 연못 (타원, 오른쪽 중하단)
    for (int r = 13; r <= 20; r++) {
      for (int c = 21; c <= 29; c++) {
        final dx = (c - 25) / 3.6;
        final dy = (r - 16.5) / 2.9;
        if (dx * dx + dy * dy <= 1.0) put(c, r, 8);
      }
    }

    // 4) 길
    fill(2, 11, 28, 2, 1); // 중앙 가로 대로
    fill(15, 2, 2, 20, 1); // 중앙 세로 길
    fill(4, 6, 22, 1, 1); // 윗길 (집·카페 앞)
    fill(5, 7, 1, 4, 1); // 집앞 연결
    fill(24, 7, 1, 4, 1); // 카페앞 연결
    fill(6, 13, 1, 2, 1); // 정원 연결
    // 연못길 + 다리
    for (int c = 16; c <= 29; c++) {
      put(c, 16, g[16][c] == 8 ? 9 : 1);
    }

    // 5) 중앙 광장 + 분수 (2x2)
    fill(12, 9, 8, 6, 1);
    fill(15, 11, 2, 2, 10);

    // 6) 집 2채 + 카페 (각 2x2)
    fill(4, 3, 2, 2, 3);
    fill(9, 3, 2, 2, 3);
    fill(23, 3, 2, 2, 11);
    // 현관 앞은 비워두기
    put(4, 5, 0);
    put(5, 5, 0);
    put(9, 5, 0);
    put(10, 5, 0);
    put(23, 5, 0);
    put(24, 5, 0);

    // 7) 꽃밭 정원 (왼쪽 중하단)
    for (int r = 15; r <= 19; r++) {
      for (int c = 3; c <= 9; c++) {
        put(c, r, ((c + r) % 2 == 0) ? 4 : 0);
      }
    }

    // 8) 소품
    put(20, 8, 6); // 우물
    put(14, 15, 5); // 표지판 (광장 남쪽)
    put(11, 9, 7); // 벤치 — 광장 서쪽
    put(21, 14, 7); // 벤치 — 연못가
    put(4, 14, 7); // 벤치 — 정원 입구
    // 가로등 8개
    put(8, 10, 12);
    put(23, 10, 12);
    put(12, 8, 12);
    put(19, 8, 12);
    put(12, 15, 12);
    put(19, 15, 12);
    put(8, 13, 12);
    put(23, 13, 12);

    // 9) NPC 스폰 자리 확보
    put(26, 13, 0);
    put(13, 8, 0);
    put(6, 17, 0);

    return g;
  }

  static TileType tileAt(int col, int row) {
    if (col < 0 || col >= width || row < 0 || row >= height) {
      return TileType.tree; // 경계 = 충돌
    }
    return TileType.values[grid[row][col]];
  }

  static bool canWalk(int col, int row) => tileAt(col, row).walkable;

  /// 타일 종류별 한 줄 대화
  static String interactionText(TileType t) {
    switch (t) {
      case TileType.tree:
        return '🌳 벚꽃잎이 사르르 떨어져. 예쁘다~';
      case TileType.house:
        return '🏠 우리 집에 들어갈까?\n방으로 돌아가기 ♡';
      case TileType.flower:
        return '🌸 분홍 꽃을 한 송이 땄어. 행복 +1';
      case TileType.sign:
        return '🪧 「토우리 마을에 어서와 ♡」\n← 꽃밭 정원 · 연못 →';
      case TileType.well:
        return '💧 우물물이 맑아. 에너지 +1';
      case TileType.bench:
        return '🪑 벤치에 같이 앉았어. 사랑 +1';
      case TileType.water:
        return '💙 연못 물이 반짝반짝해.\n오리 친구가 어디 있을 텐데?';
      case TileType.fountain:
        return '⛲ 분수에 소원을 빌었어. 행복 +1';
      case TileType.cafe:
        return '☕ 토우리 카페야.\n딸기라떼 냄새가 솔솔~';
      case TileType.lamp:
        return '🏮 가로등이 포근하게 빛나고 있어';
      default:
        return '';
    }
  }
}

/// 타일맵 렌더 컴포넌트.
/// 정적 타일은 Picture로 1회 캐싱, 움직이는 것(물·분수·나무·불빛)만 매 프레임.
class TownTilemapComponent extends PositionComponent {
  TownTilemapComponent() {
    priority = 0;
    size = Vector2(TownMap.pixelWidth, TownMap.pixelHeight);
  }

  double _time = 0;
  Picture? _static;

  // 동적 렌더 대상 (onLoad에서 스캔)
  final List<(int, int)> _trees = [];
  final List<(int, int, int)> _waters = []; // (c, r, edgeMask: 상1 하2 좌4 우8)
  final List<(int, int)> _lamps = [];
  final List<(int, int)> _buildings = []; // 집+카페 좌상단 (창문 불빛용)
  (int, int)? _fountain;

  // 🌸 핑크풍 팔레트
  static const _grass = Color(0xFFFADDE2);
  static const _grassDark = Color(0xFFF0BACD);
  static const _grassDot = Color(0xFFE89BAA);
  static const _path = Color(0xFFFFF0E8);
  static const _pathDark = Color(0xFFE8C8C8);
  static const _treeTrunk = Color(0xFF8B6B6B);
  static const _treeLeaf = Color(0xFFE89BAA);
  static const _treeLeafLight = Color(0xFFF8CCDC);
  static const _houseWall = Color(0xFFFFF8FB);
  static const _houseRoof = Color(0xFFE8A0B5);
  static const _houseDoor = Color(0xFF8B5A6E);
  static const _flowerPink = Color(0xFFFB7CA0);
  static const _flowerCenter = Color(0xFFFFE066);
  static const _signWood = Color(0xFFB58880);
  static const _wellStone = Color(0xFFD0A8B8);
  static const _wellWater = Color(0xFFA8C8E0);
  static const _benchWood = Color(0xFFC8A0A0);
  static const _waterBlue = Color(0xFFA8D4F0);
  static const _waterDeep = Color(0xFF8FC2E8);
  static const _sand = Color(0xFFF2DCC8);
  static const _bridgeWood = Color(0xFFC89078);
  static const _bridgeDark = Color(0xFF9A6B55);
  static const _lampGlow = Color(0xFFFFD27D);
  static const _windowLit = Color(0xFFFFDF9E);
  static const _outline = Color(0xFF8B5A6E);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // 동적 대상 스캔
    for (int r = 0; r < TownMap.height; r++) {
      for (int c = 0; c < TownMap.width; c++) {
        final v = TownMap.grid[r][c];
        switch (v) {
          case 2:
            _trees.add((c, r));
            break;
          case 8:
            int mask = 0;
            if (TownMap.grid[math.max(0, r - 1)][c] != 8 || r == 0) mask |= 1;
            if (TownMap.grid[math.min(TownMap.height - 1, r + 1)][c] != 8) {
              mask |= 2;
            }
            if (TownMap.grid[r][math.max(0, c - 1)] != 8 || c == 0) mask |= 4;
            if (TownMap.grid[r][math.min(TownMap.width - 1, c + 1)] != 8) {
              mask |= 8;
            }
            _waters.add((c, r, mask));
            break;
          case 12:
            _lamps.add((c, r));
            break;
          case 3:
          case 11:
            final leftSame = c > 0 && TownMap.grid[r][c - 1] == v;
            final upSame = r > 0 && TownMap.grid[r - 1][c] == v;
            if (!leftSame && !upSame) _buildings.add((c, r));
            break;
          case 10:
            final leftSame = c > 0 && TownMap.grid[r][c - 1] == 10;
            final upSame = r > 0 && TownMap.grid[r - 1][c] == 10;
            if (!leftSame && !upSame) _fountain = (c, r);
            break;
        }
      }
    }
    // 정적 레이어 캐싱
    final rec = PictureRecorder();
    _renderStatic(Canvas(rec));
    _static = rec.endRecording();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_static != null) canvas.drawPicture(_static!);
    final lit = TownAmbient.lampsOn;
    for (final (c, r, mask) in _waters) {
      _drawWater(canvas, c * 32.0, r * 32.0, c, r, mask);
    }
    if (_fountain != null) {
      _drawFountain(canvas, _fountain!.$1 * 32.0, _fountain!.$2 * 32.0);
    }
    for (final (c, r) in _trees) {
      _drawTree(canvas, c * 32.0, r * 32.0, c, r);
    }
    for (final (c, r) in _lamps) {
      _drawLamp(canvas, c * 32.0, r * 32.0, lit);
    }
    if (lit) {
      for (final (c, r) in _buildings) {
        _drawLitWindows(canvas, c * 32.0, r * 32.0);
      }
    }
  }

  // ───────────────────────── 정적 레이어 ─────────────────────────

  void _renderStatic(Canvas canvas) {
    const ts = TownMap.tileSize;
    for (int r = 0; r < TownMap.height; r++) {
      for (int c = 0; c < TownMap.width; c++) {
        final t = TileType.values[TownMap.grid[r][c]];
        final x = c * ts;
        final y = r * ts;
        _drawGrass(canvas, x, y, c, r);
        switch (t) {
          case TileType.path:
            _drawPath(canvas, x, y);
            break;
          case TileType.house:
            _drawHouse(canvas, x, y, c, r);
            break;
          case TileType.cafe:
            _drawCafe(canvas, x, y, c, r);
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
          case TileType.water:
            // 모래 바닥 (가장자리 림으로 살짝 보임)
            canvas.drawRect(
              Rect.fromLTWH(x, y, 32, 32),
              Paint()..color = _sand,
            );
            break;
          case TileType.bridge:
            _drawBridge(canvas, x, y);
            break;
          default:
            break;
        }
      }
    }
  }

  void _drawGrass(Canvas canvas, double x, double y, int c, int r) {
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), Paint()..color = _grass);
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
    canvas.drawRect(
        Rect.fromLTWH(x + 1, y + 1, 30, 30), Paint()..color = _path);
    final dark = Paint()..color = _pathDark;
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x, y + 31, 32, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x, y, 1, 32), dark);
    canvas.drawRect(Rect.fromLTWH(x + 31, y, 1, 32), dark);
    final rng = math.Random(((x.toInt() * 13) ^ y.toInt()) & 0xFFFF);
    for (int i = 0; i < 4; i++) {
      final dx = rng.nextDouble() * 28 + 2;
      final dy = rng.nextDouble() * 28 + 2;
      canvas.drawRect(Rect.fromLTWH(x + dx, y + dy, 2, 2), dark);
    }
  }

  void _drawHouse(Canvas canvas, double x, double y, int c, int r) {
    if (c > 0 && TownMap.grid[r][c - 1] == 3) return;
    if (r > 0 && TownMap.grid[r - 1][c] == 3) return;
    const w = 64.0;
    const h = 64.0;
    final roof = Paint()..color = _houseRoof;
    final roofDark = Paint()..color = const Color(0xFFCC7A92);
    for (int i = 0; i < 16; i++) {
      canvas.drawRect(
        Rect.fromLTWH(x + i * 2.0, y + i * 1.0, w - i * 4.0, 1),
        roof,
      );
    }
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 16, w - 4, 2), roofDark);
    canvas.drawRect(
        Rect.fromLTWH(x + 4, y + 18, w - 8, h - 22), Paint()..color = _houseWall);
    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 18, w - 8, h - 22), outline);
    canvas.drawRect(
        Rect.fromLTWH(x + 28, y + 42, 8, 18), Paint()..color = _houseDoor);
    canvas.drawRect(Rect.fromLTWH(x + 33, y + 50, 1, 2),
        Paint()..color = const Color(0xFFFFC107));
    final window = Paint()..color = const Color(0xFFB0DDF0);
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 26, 8, 8), window);
    canvas.drawRect(Rect.fromLTWH(x + 46, y + 26, 8, 8), window);
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 26, 8, 8), outline);
    canvas.drawRect(Rect.fromLTWH(x + 46, y + 26, 8, 8), outline);
    canvas.drawLine(Offset(x + 14, y + 26), Offset(x + 14, y + 34), outline);
    canvas.drawLine(Offset(x + 10, y + 30), Offset(x + 18, y + 30), outline);
  }

  void _drawCafe(Canvas canvas, double x, double y, int c, int r) {
    if (c > 0 && TownMap.grid[r][c - 1] == 11) return;
    if (r > 0 && TownMap.grid[r - 1][c] == 11) return;
    const w = 64.0;
    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // 벽
    canvas.drawRect(
        Rect.fromLTWH(x + 4, y + 14, w - 8, 46), Paint()..color = const Color(0xFFFFF6EC));
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, w - 8, 46), outline);
    // 줄무늬 어닝 (차양)
    final a1 = Paint()..color = const Color(0xFFF2A9BE);
    final a2 = Paint()..color = const Color(0xFFFFF4F7);
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(x + i * 8.0, y + 6, 8, 12),
        i.isEven ? a1 : a2,
      );
      // 스캘럽 (반원 끝단)
      canvas.drawCircle(
        Offset(x + i * 8.0 + 4, y + 18),
        4,
        i.isEven ? a1 : a2,
      );
    }
    // 큰 창 2개
    final glass = Paint()..color = const Color(0xFFBFE3F2);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 28, 14, 12), glass);
    canvas.drawRect(Rect.fromLTWH(x + 42, y + 28, 14, 12), glass);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 28, 14, 12), outline);
    canvas.drawRect(Rect.fromLTWH(x + 42, y + 28, 14, 12), outline);
    // 문
    canvas.drawRect(
        Rect.fromLTWH(x + 27, y + 40, 10, 20), Paint()..color = const Color(0xFF9C6B5E));
    // 커피잔 간판
    canvas.drawRect(
        Rect.fromLTWH(x + 24, y + 22, 16, 7), Paint()..color = const Color(0xFFFFFBF5));
    canvas.drawRect(Rect.fromLTWH(x + 24, y + 22, 16, 7), outline);
    canvas.drawRect(
        Rect.fromLTWH(x + 28, y + 24, 5, 4), Paint()..color = const Color(0xFF8B5A3C));
    canvas.drawArc(Rect.fromLTWH(x + 33, y + 24, 3, 3), -1.5, 3.0, false,
        Paint()
          ..color = const Color(0xFF8B5A3C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _drawFlower(Canvas canvas, double x, double y) {
    final petal = Paint()..color = _flowerPink;
    final center = Paint()..color = _flowerCenter;
    canvas.drawCircle(Offset(x + 16, y + 8), 3, petal);
    canvas.drawCircle(Offset(x + 10, y + 14), 3, petal);
    canvas.drawCircle(Offset(x + 22, y + 14), 3, petal);
    canvas.drawCircle(Offset(x + 12, y + 22), 3, petal);
    canvas.drawCircle(Offset(x + 20, y + 22), 3, petal);
    canvas.drawCircle(Offset(x + 16, y + 16), 3, center);
    canvas.drawOval(
        Rect.fromLTWH(x + 13, y + 24, 6, 4), Paint()..color = _treeLeafLight);
  }

  void _drawSign(Canvas canvas, double x, double y) {
    final wood = Paint()..color = _signWood;
    final dark = Paint()..color = const Color(0xFF6F4F32);
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 18, 4, 12), dark);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 8, 24, 14), wood);
    canvas.drawRect(
        Rect.fromLTWH(x + 4, y + 8, 24, 14),
        Paint()
          ..color = const Color(0xFF4F3A24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.drawRect(Rect.fromLTWH(x + 7, y + 12, 18, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x + 7, y + 16, 14, 1), dark);
  }

  void _drawWell(Canvas canvas, double x, double y) {
    final stone = Paint()..color = _wellStone;
    final water = Paint()..color = _wellWater;
    final dark = Paint()..color = const Color(0xFF7878A0);
    canvas.drawOval(Rect.fromLTWH(x + 4, y + 14, 24, 14), stone);
    canvas.drawOval(Rect.fromLTWH(x + 8, y + 16, 16, 10), water);
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 4, 2, 14), dark);
    canvas.drawRect(Rect.fromLTWH(x + 25, y + 4, 2, 14), dark);
    canvas.drawRect(
        Rect.fromLTWH(x + 2, y + 2, 28, 4), Paint()..color = const Color(0xFFB57272));
    canvas.drawRect(
        Rect.fromLTWH(x + 11, y + 18, 4, 1), Paint()..color = const Color(0xFFFFFFFF));
  }

  void _drawBench(Canvas canvas, double x, double y) {
    final wood = Paint()..color = _benchWood;
    final dark = Paint()..color = const Color(0xFF8B6440);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 4), wood);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 20, 24, 4), wood);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 23, 24, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 24, 2, 6), dark);
    canvas.drawRect(Rect.fromLTWH(x + 24, y + 24, 2, 6), dark);
  }

  void _drawBridge(Canvas canvas, double x, double y) {
    // 널빤지
    canvas.drawRect(Rect.fromLTWH(x, y + 4, 32, 24), Paint()..color = _bridgeWood);
    final dark = Paint()..color = _bridgeDark;
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(x + i * 8.0, y + 4, 1, 24), dark);
    }
    // 난간 (위아래)
    canvas.drawRect(Rect.fromLTWH(x, y + 1, 32, 3), dark);
    canvas.drawRect(Rect.fromLTWH(x, y + 28, 32, 3), dark);
    // 기둥
    canvas.drawRect(Rect.fromLTWH(x + 2, y, 3, 6), dark);
    canvas.drawRect(Rect.fromLTWH(x + 27, y, 3, 6), dark);
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 26, 3, 6), dark);
    canvas.drawRect(Rect.fromLTWH(x + 27, y + 26, 3, 6), dark);
  }

  // ───────────────────────── 동적 레이어 ─────────────────────────

  void _drawWater(Canvas canvas, double x, double y, int c, int r, int mask) {
    // 가장자리는 모래 림이 1.5px 보이게 안쪽으로
    final inset = Rect.fromLTWH(
      x + ((mask & 4) != 0 ? 2.0 : 0.0),
      y + ((mask & 1) != 0 ? 2.0 : 0.0),
      32 - ((mask & 4) != 0 ? 2.0 : 0.0) - ((mask & 8) != 0 ? 2.0 : 0.0),
      32 - ((mask & 1) != 0 ? 2.0 : 0.0) - ((mask & 2) != 0 ? 2.0 : 0.0),
    );
    canvas.drawRect(inset, Paint()..color = _waterBlue);
    // 깊은 물 그라데이션 느낌
    canvas.drawRect(
      Rect.fromLTWH(inset.left + 4, inset.top + 8, inset.width - 8,
          math.max(0.0, inset.height - 12)),
      Paint()..color = _waterDeep,
    );
    // 물결 — 시간 따라 흐르는 하이라이트 줄
    final phase = _time * 1.6 + c * 0.9 + r * 1.4;
    final wave = Paint()..color = const Color(0x66FFFFFF);
    final wy = y + 8 + math.sin(phase) * 4 + 8;
    canvas.drawRect(Rect.fromLTWH(x + 6, wy, 9, 1.5), wave);
    canvas.drawRect(
        Rect.fromLTWH(x + 18, wy + 6 * math.sin(phase * 0.7), 7, 1.5), wave);
    // 반짝임
    if (math.sin(phase * 2.3) > 0.93) {
      canvas.drawCircle(
          Offset(x + 16 + math.sin(phase) * 8, y + 16), 1.5,
          Paint()..color = const Color(0xCCFFFFFF));
    }
  }

  void _drawFountain(Canvas canvas, double x, double y) {
    // 64x64 (2x2 타일)
    final cx = x + 32;
    final cy = y + 32;
    // 받침 돌
    canvas.drawCircle(
        Offset(cx, cy), 30, Paint()..color = const Color(0xFFE0C4D0));
    canvas.drawCircle(
        Offset(cx, cy), 30,
        Paint()
          ..color = const Color(0xFFB890A8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    // 물
    canvas.drawCircle(Offset(cx, cy), 24, Paint()..color = _waterBlue);
    // 퍼지는 물결 링 2개
    for (int i = 0; i < 2; i++) {
      final p = (_time * 0.55 + i * 0.5) % 1.0;
      canvas.drawCircle(
        Offset(cx, cy),
        6 + p * 17,
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, (1 - p) * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    // 중앙 기둥
    canvas.drawCircle(
        Offset(cx, cy), 6, Paint()..color = const Color(0xFFD0A8B8));
    canvas.drawCircle(
        Offset(cx, cy - 3), 3.5, Paint()..color = const Color(0xFFE0C4D0));
    // 물줄기 — 8방향 포물선 물방울
    for (int i = 0; i < 8; i++) {
      final ang = i * math.pi / 4;
      final p = (_time * 0.9 + i * 0.125) % 1.0;
      final rr = 4 + p * 16;
      final lift = -10 * (1 - (2 * p - 1) * (2 * p - 1)); // 포물선
      final px = cx + math.cos(ang) * rr;
      final py = cy - 4 + math.sin(ang) * rr * 0.5 + lift;
      canvas.drawCircle(
        Offset(px, py),
        1.6,
        Paint()..color = Color.fromRGBO(255, 255, 255, 0.85 - p * 0.5),
      );
    }
  }

  void _drawTree(Canvas canvas, double x, double y, int c, int r) {
    final sway = math.sin(_time * 1.3 + c * 0.7 + r * 0.4) * 1.3;
    // 트렁크
    canvas.drawRect(
        Rect.fromLTWH(x + 13, y + 20, 6, 10), Paint()..color = _treeTrunk);
    // 잎 (흔들림)
    canvas.drawOval(Rect.fromLTWH(x + 4 + sway, y + 3, 24, 21),
        Paint()..color = _treeLeaf);
    canvas.drawOval(Rect.fromLTWH(x + 7 + sway, y + 5, 9, 7),
        Paint()..color = _treeLeafLight);
    canvas.drawCircle(Offset(x + 16 + sway, y + 14), 1.2,
        Paint()..color = _flowerPink);
  }

  void _drawLamp(Canvas canvas, double x, double y, bool lit) {
    final dark = Paint()..color = const Color(0xFF7A5A66);
    // 밤이면 은은한 글로우 먼저
    if (lit) {
      canvas.drawCircle(Offset(x + 16, y + 8), 15,
          Paint()..color = _lampGlow.withAlpha(0x16));
      canvas.drawCircle(Offset(x + 16, y + 8), 9,
          Paint()..color = _lampGlow.withAlpha(0x2E));
    }
    // 기둥 + 받침
    canvas.drawRect(Rect.fromLTWH(x + 14.5, y + 10, 3, 18), dark);
    canvas.drawRect(Rect.fromLTWH(x + 12, y + 27, 8, 3), dark);
    // 머리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 11, y + 3, 10, 9), const Radius.circular(3)),
      Paint()..color = lit ? const Color(0xFFFFE9A8) : const Color(0xFFF4E8EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 11, y + 3, 10, 9), const Radius.circular(3)),
      Paint()
        ..color = dark.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRect(Rect.fromLTWH(x + 13, y + 1, 6, 2), dark);
  }

  void _drawLitWindows(Canvas canvas, double x, double y) {
    // 집/카페 공통 — 창문 위치에 따뜻한 불빛
    final lit = Paint()..color = _windowLit;
    final glow = Paint()..color = _windowLit.withAlpha(0x28);
    final isCafe = TownMap.grid[(y / 32).round()][(x / 32).round()] == 11;
    final rects = isCafe
        ? [Rect.fromLTWH(x + 8, y + 28, 14, 12), Rect.fromLTWH(x + 42, y + 28, 14, 12)]
        : [Rect.fromLTWH(x + 10, y + 26, 8, 8), Rect.fromLTWH(x + 46, y + 26, 8, 8)];
    for (final w in rects) {
      canvas.drawRect(w.inflate(4), glow);
      canvas.drawRect(w, lit);
    }
  }
}
