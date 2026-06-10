import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

/// 🏠 토우리 방 타일맵 (집 안 — 토우리 키우기 화면용).
/// 8x6 그리드 = 256x192 작은 방. 카메라 줌으로 모바일 화면에 적절히.
/// 마을과 동일한 핑크 톤. 가구 6종 + 문 1개 (마을 점프).
///
/// 타일 코드:
/// 0=바닥(walkable) 1=벽 2=침대 3=식탁 4=거울 5=책장 6=장난감 7=문(walkable)

enum RoomTileType {
  floor(walkable: true),
  wall(walkable: false),
  bed(walkable: false, interactKey: 'bed'),
  table(walkable: false, interactKey: 'table'),
  mirror(walkable: false, interactKey: 'mirror'),
  bookshelf(walkable: false, interactKey: 'bookshelf'),
  toybox(walkable: false, interactKey: 'toybox'),
  door(walkable: true, interactKey: 'door'); // door = 마을 점프

  final bool walkable;
  final String? interactKey;
  const RoomTileType({required this.walkable, this.interactKey});
}

class RoomMap {
  static const int width = 8;
  static const int height = 6;
  static const double tileSize = 32.0;

  /// 8x6 방 그리드
  /// 0=floor 1=wall 2=bed 3=table 4=mirror 5=bookshelf 6=toybox 7=door
  static const List<List<int>> grid = [
    [1, 1, 1, 1, 1, 1, 1, 1], // 벽 윗줄
    [1, 2, 2, 0, 0, 0, 4, 1], // 침대(2,2) + 거울(4)
    [1, 0, 0, 0, 0, 0, 0, 1],
    [1, 5, 0, 0, 0, 0, 6, 1], // 책장(5) + 장난감(6)
    [1, 0, 0, 3, 3, 0, 0, 1], // 식탁(3,3)
    [1, 1, 1, 7, 1, 1, 1, 1], // 문(7) — 마을 점프
  ];

  /// 토우리 시작 타일 (방 중앙)
  static const startTile = (4, 2);

  static RoomTileType tileAt(int col, int row) {
    if (col < 0 || col >= width || row < 0 || row >= height) {
      return RoomTileType.wall;
    }
    return RoomTileType.values[grid[row][col]];
  }

  static bool canWalk(int col, int row) => tileAt(col, row).walkable;

  /// 상호작용 텍스트 (모던 다이얼로그)
  static String interactionText(RoomTileType t) {
    switch (t) {
      case RoomTileType.bed:
        return '🛏️ 잠깐 누워서 쉴까?\n에너지 +2';
      case RoomTileType.table:
        return '🍽️ 맛있는 거 차려줬어!\n사랑 +2';
      case RoomTileType.mirror:
        return '🪞 거울 속 토우리 너무 예쁘다 ♡\n반짝임 +2';
      case RoomTileType.bookshelf:
        return '📚 책 한 권 읽었어\n집중 +2';
      case RoomTileType.toybox:
        return '🧸 장난감이랑 같이 놀았어!\n사랑 +1, 반짝임 +1';
      case RoomTileType.door:
        return '🚪 마을로 나가볼까?';
      default:
        return '';
    }
  }
}

/// 방 타일맵 컴포넌트 — Canvas로 직접 그리기. 핑크풍 통일.
class RoomTilemapComponent extends Component with HasGameReference {
  RoomTilemapComponent() {
    priority = 0;
  }

  // 핑크풍 톤 — 마을과 통일
  static const _floor = Color(0xFFFFF0E8);        // 크림핑크 바닥 (마을 길과 같음)
  static const _floorDark = Color(0xFFE8C8C8);    // 가장자리
  static const _wall = Color(0xFFE8A0B5);          // 핑크 벽 (마을 지붕과 같음)
  static const _wallDark = Color(0xFFCC7A92);      // 벽 그림자
  // 침대 컬러
  static const _bedFrame = Color(0xFF8B5A6E);      // 다크 핑크 프레임
  static const _bedSheet = Color(0xFFFADDE2);      // 연분홍 시트
  static const _bedPillow = Color(0xFFFFF8FB);     // 흰핑크 베개
  static const _bedHeart = Color(0xFFFB7CA0);      // 베개 위 하트
  // 식탁
  static const _tableTop = Color(0xFFC8A0A0);      // 핑크 갈색 상판
  static const _tableLeg = Color(0xFF8B5A6E);      // 다리
  static const _tableDish = Color(0xFFFFF8FB);     // 흰 접시
  static const _tableFood = Color(0xFFFB7CA0);     // 음식 (분홍)
  // 거울
  static const _mirrorFrame = Color(0xFFE8A0B5);   // 핑크 프레임
  static const _mirrorGlass = Color(0xFFD8E8F0);   // 연한 파랑 (반사)
  // 책장
  static const _shelf = Color(0xFFB58880);         // 핑크 갈색 책장
  static const _bookA = Color(0xFFFB7CA0);         // 분홍 책
  static const _bookB = Color(0xFFA8C8E0);         // 파랑 책
  static const _bookC = Color(0xFFFCE783);         // 노랑 책
  // 장난감 박스
  static const _toyBox = Color(0xFFE8A0B5);        // 핑크 박스
  static const _toyBall = Color(0xFFFCE783);       // 노랑 공
  static const _toyHeart = Color(0xFFFB7CA0);      // 하트
  // 문
  static const _doorFrame = Color(0xFF8B5A6E);     // 다크 핑크 프레임
  static const _doorWood = Color(0xFFC8A0A0);      // 핑크 갈색 문

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const ts = RoomMap.tileSize;
    for (int r = 0; r < RoomMap.height; r++) {
      for (int c = 0; c < RoomMap.width; c++) {
        final v = RoomMap.grid[r][c];
        final t = RoomTileType.values[v];
        final x = c * ts;
        final y = r * ts;
        // 모든 타일 아래 바닥 깔기
        _drawFloor(canvas, x, y, c, r);
        // 타일별 위에 그리기
        switch (t) {
          case RoomTileType.wall:
            _drawWall(canvas, x, y);
            break;
          case RoomTileType.bed:
            _drawBed(canvas, x, y, c, r);
            break;
          case RoomTileType.table:
            _drawTable(canvas, x, y, c, r);
            break;
          case RoomTileType.mirror:
            _drawMirror(canvas, x, y);
            break;
          case RoomTileType.bookshelf:
            _drawBookshelf(canvas, x, y);
            break;
          case RoomTileType.toybox:
            _drawToybox(canvas, x, y);
            break;
          case RoomTileType.door:
            _drawDoor(canvas, x, y);
            break;
          case RoomTileType.floor:
            break;
        }
      }
    }
  }

  void _drawFloor(Canvas canvas, double x, double y, int c, int r) {
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), Paint()..color = _floor);
    // 살짝 그라데이션 도트 (확정적 시드)
    final rng = math.Random((c * 31 + r * 17) & 0xFFFF);
    for (int i = 0; i < 3; i++) {
      final dx = rng.nextDouble() * 28 + 2;
      final dy = rng.nextDouble() * 28 + 2;
      canvas.drawRect(
        Rect.fromLTWH(x + dx, y + dy, 2, 2),
        Paint()..color = _floorDark,
      );
    }
  }

  void _drawWall(Canvas canvas, double x, double y) {
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), Paint()..color = _wall);
    // 벽돌 패턴 (가로 줄)
    final dark = Paint()..color = _wallDark;
    canvas.drawRect(Rect.fromLTWH(x, y + 11, 32, 1), dark);
    canvas.drawRect(Rect.fromLTWH(x, y + 22, 32, 1), dark);
    // 세로 줄 (벽돌 끝)
    canvas.drawRect(Rect.fromLTWH(x + 15, y, 1, 11), dark);
    canvas.drawRect(Rect.fromLTWH(x + 7, y + 11, 1, 11), dark);
    canvas.drawRect(Rect.fromLTWH(x + 23, y + 11, 1, 11), dark);
    canvas.drawRect(Rect.fromLTWH(x + 15, y + 22, 1, 10), dark);
  }

  // 침대는 2x1 타일에 걸쳐 — 좌측 타일에서만 그림
  void _drawBed(Canvas canvas, double x, double y, int c, int r) {
    if (c > 0 && RoomMap.grid[r][c - 1] == 2) return; // 우측 타일은 스킵

    final w = 64.0;
    // 프레임
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 6, w - 4, 24), Paint()..color = _bedFrame);
    // 시트 (위에 덮음)
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 8, w - 8, 18), Paint()..color = _bedSheet);
    // 베개 (왼쪽)
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 10, 14, 8), Paint()..color = _bedPillow);
    // 베개 위 하트
    final heart = Paint()..color = _bedHeart;
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 12, 2, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 13, y + 12, 2, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 13, 5, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 15, 3, 1), heart);
    // 다리
    final leg = Paint()..color = _bedFrame;
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 28, 4, 4), leg);
    canvas.drawRect(Rect.fromLTWH(x + w - 6, y + 28, 4, 4), leg);
  }

  // 식탁은 2x1 타일에 걸쳐
  void _drawTable(Canvas canvas, double x, double y, int c, int r) {
    if (c > 0 && RoomMap.grid[r][c - 1] == 3) return;

    final w = 64.0;
    // 상판
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, w - 8, 6), Paint()..color = _tableTop);
    // 다리 (4개)
    final leg = Paint()..color = _tableLeg;
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 20, 3, 10), leg);
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 20, 3, 10), leg);
    canvas.drawRect(Rect.fromLTWH(x + w - 9, y + 20, 3, 10), leg);
    canvas.drawRect(Rect.fromLTWH(x + w - 17, y + 20, 3, 10), leg);
    // 접시 + 음식
    canvas.drawOval(Rect.fromLTWH(x + 12, y + 11, 12, 5), Paint()..color = _tableDish);
    canvas.drawOval(Rect.fromLTWH(x + 14, y + 9, 8, 5), Paint()..color = _tableFood);
    // 두 번째 접시 (오른쪽)
    canvas.drawOval(Rect.fromLTWH(x + 38, y + 11, 12, 5), Paint()..color = _tableDish);
    canvas.drawOval(Rect.fromLTWH(x + 40, y + 9, 8, 5), Paint()..color = _bedHeart);
  }

  void _drawMirror(Canvas canvas, double x, double y) {
    // 프레임 (둥근 모서리)
    final frame = Paint()..color = _mirrorFrame;
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 4, 16, 20), frame);
    // 유리
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 6, 12, 16), Paint()..color = _mirrorGlass);
    // 빛 반사 (대각선)
    final hi = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 7, 2, 1), hi);
    canvas.drawRect(Rect.fromLTWH(x + 12, y + 8, 2, 1), hi);
    canvas.drawRect(Rect.fromLTWH(x + 13, y + 9, 2, 1), hi);
    // 받침대
    final base = Paint()..color = _wallDark;
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 24, 12, 3), base);
    canvas.drawRect(Rect.fromLTWH(x + 13, y + 27, 6, 3), base);
  }

  void _drawBookshelf(Canvas canvas, double x, double y) {
    // 책장 본체
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, 24, 26), Paint()..color = _shelf);
    // 선반 라인 (3단)
    final line = Paint()..color = _wallDark;
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 13, 24, 1), line);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 22, 24, 1), line);
    // 책 (각 단)
    // 1단
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 6, 4, 7), Paint()..color = _bookA);
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 6, 4, 7), Paint()..color = _bookB);
    canvas.drawRect(Rect.fromLTWH(x + 16, y + 7, 4, 6), Paint()..color = _bookC);
    canvas.drawRect(Rect.fromLTWH(x + 21, y + 6, 4, 7), Paint()..color = _bookA);
    // 2단
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 15, 4, 7), Paint()..color = _bookB);
    canvas.drawRect(Rect.fromLTWH(x + 11, y + 16, 4, 6), Paint()..color = _bookA);
    canvas.drawRect(Rect.fromLTWH(x + 17, y + 15, 4, 7), Paint()..color = _bookC);
    canvas.drawRect(Rect.fromLTWH(x + 22, y + 15, 3, 7), Paint()..color = _bookB);
    // 3단 — 소품
    canvas.drawCircle(Offset(x + 9, y + 27), 2, Paint()..color = _toyHeart); // 화분?
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 24, 6, 5), Paint()..color = _bookA);
    canvas.drawRect(Rect.fromLTWH(x + 22, y + 25, 4, 4), Paint()..color = _tableDish);
  }

  void _drawToybox(Canvas canvas, double x, double y) {
    // 박스
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 16), Paint()..color = _toyBox);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 14, 24, 1),
        Paint()..color = _wallDark);
    // 뚜껑 살짝 열림 — 위에 작게
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 10, 28, 6), Paint()..color = _bedFrame);
    // 박스 안에서 튀어나온 장난감
    // 공
    canvas.drawCircle(Offset(x + 10, y + 10), 4, Paint()..color = _toyBall);
    canvas.drawRect(Rect.fromLTWH(x + 9, y + 9, 1, 1), Paint()..color = Colors.white);
    // 하트 인형
    final heart = Paint()..color = _toyHeart;
    canvas.drawRect(Rect.fromLTWH(x + 18, y + 8, 2, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 21, y + 8, 2, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 17, y + 9, 6, 2), heart);
    canvas.drawRect(Rect.fromLTWH(x + 18, y + 11, 4, 1), heart);
    // 박스 라벨
    canvas.drawRect(Rect.fromLTWH(x + 12, y + 22, 8, 4), Paint()..color = _bedSheet);
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 23, 4, 1), Paint()..color = _wallDark);
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 25, 4, 1), Paint()..color = _wallDark);
  }

  void _drawDoor(Canvas canvas, double x, double y) {
    // 문 프레임 (벽 일부 위에 덮기)
    canvas.drawRect(Rect.fromLTWH(x, y, 32, 32), Paint()..color = _wall);
    // 프레임 (어두운 핑크)
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 2, 24, 30), Paint()..color = _doorFrame);
    // 문 (나무)
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 4, 20, 26), Paint()..color = _doorWood);
    // 문 패널 (세로 라인)
    final line = Paint()..color = _doorFrame;
    canvas.drawRect(Rect.fromLTWH(x + 15, y + 6, 1, 22), line);
    // 손잡이
    canvas.drawCircle(Offset(x + 21, y + 18), 1.5, Paint()..color = Color(0xFFFCE783));
    // 위쪽 '나가기' 화살표
    final arrow = Paint()..color = _bedHeart;
    canvas.drawRect(Rect.fromLTWH(x + 14, y + 1, 4, 1), arrow);
    canvas.drawRect(Rect.fromLTWH(x + 13, y + 2, 6, 1), arrow);
  }
}
