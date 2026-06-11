import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'town_tilemap.dart';

enum NpcKind { duck, cat, bird }

/// 마을 동물 주민 — 어슬렁어슬렁 돌아다니고 말을 걸 수 있다.
/// 걷기는 타일 L자 경로(가로→세로)로 부드럽게 이동.
class TouriNpc extends PositionComponent {
  static const double ts = TownMap.tileSize;
  static const double speed = 30;

  TouriNpc({
    required this.kind,
    required int col,
    required int row,
    required this.lines,
    int seed = 0,
  }) : _rng = math.Random(seed * 977 + 13) {
    size = Vector2.all(ts);
    anchor = Anchor.topLeft;
    position = Vector2(col * ts, row * ts);
    priority = 9;
    _pause = 1.0 + _rng.nextDouble() * 2;
  }

  final NpcKind kind;
  final List<String> lines;
  final math.Random _rng;

  int _li = 0;
  double _time = 0;
  double _pause = 1.5;
  bool _faceLeft = false;
  final List<Vector2> _waypoints = [];

  bool get _walkingNow => _waypoints.isNotEmpty;

  Vector2 get centerPoint => Vector2(position.x + 16, position.y + 18);

  String nextLine() => lines[_li++ % lines.length];

  (int, int) get _tile =>
      ((position.x / ts).round(), (position.y / ts).round());

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_waypoints.isEmpty) {
      _pause -= dt;
      if (_pause <= 0) {
        _pickTarget();
        _pause = 1.2 + _rng.nextDouble() * 2.8;
      }
      return;
    }
    final wp = _waypoints.first;
    final d = wp - position;
    final step = speed * dt;
    if (d.length <= step) {
      position.setFrom(wp);
      _waypoints.removeAt(0);
    } else {
      final dir = d.normalized();
      position.add(dir * step);
      if (dir.x < -0.1) _faceLeft = true;
      if (dir.x > 0.1) _faceLeft = false;
    }
  }

  void _pickTarget() {
    final (c, r) = _tile;
    for (int attempt = 0; attempt < 6; attempt++) {
      final nc = c + _rng.nextInt(7) - 3;
      final nr = r + _rng.nextInt(7) - 3;
      if ((nc == c && nr == r) || !TownMap.canWalk(nc, nr)) continue;
      // L자 경로 체크 (가로 먼저)
      bool ok = true;
      for (int cc = math.min(c, nc); cc <= math.max(c, nc) && ok; cc++) {
        if (!TownMap.canWalk(cc, r)) ok = false;
      }
      for (int rr = math.min(r, nr); rr <= math.max(r, nr) && ok; rr++) {
        if (!TownMap.canWalk(nc, rr)) ok = false;
      }
      if (!ok) continue;
      _waypoints
        ..clear()
        ..add(Vector2(nc * ts, r * ts))
        ..add(Vector2(nc * ts, nr * ts));
      return;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final bob = _walkingNow
        ? math.sin(_time * 11) * 1.6
        : math.sin(_time * 2.2) * 0.5;
    // 그림자
    canvas.drawOval(
      const Rect.fromLTWH(8, 24, 16, 6),
      Paint()..color = const Color(0x26805060),
    );
    canvas.save();
    if (_faceLeft) {
      canvas.translate(32, 0);
      canvas.scale(-1, 1);
    }
    switch (kind) {
      case NpcKind.duck:
        _drawDuck(canvas, bob);
        break;
      case NpcKind.cat:
        _drawCat(canvas, bob);
        break;
      case NpcKind.bird:
        _drawBird(canvas, bob);
        break;
    }
    canvas.restore();
  }

  void _drawDuck(Canvas canvas, double bob) {
    final body = Paint()..color = const Color(0xFFFFD96B);
    final wing = Paint()..color = const Color(0xFFF2C04A);
    final beak = Paint()..color = const Color(0xFFFF9C50);
    canvas.drawOval(Rect.fromLTWH(7, 13 + bob, 16, 12), body);
    canvas.drawCircle(Offset(21, 11 + bob), 5.5, body);
    canvas.drawOval(Rect.fromLTWH(25, 10 + bob, 6, 3.5), beak);
    canvas.drawCircle(Offset(22, 9.5 + bob), 1.1,
        Paint()..color = const Color(0xFF4A3838));
    canvas.drawOval(Rect.fromLTWH(9, 15 + bob, 9, 7), wing);
    // 발
    canvas.drawRect(const Rect.fromLTWH(11, 24, 3, 3), beak);
    canvas.drawRect(const Rect.fromLTWH(17, 24, 3, 3), beak);
  }

  void _drawCat(Canvas canvas, double bob) {
    final fur = Paint()..color = const Color(0xFFFFFCF8);
    final pink = Paint()..color = const Color(0xFFF8A8C0);
    final dark = Paint()..color = const Color(0xFF4A3838);
    // 꼬리 (살랑살랑)
    final tail = math.sin(_time * 3) * 2;
    canvas.drawOval(Rect.fromLTWH(3, 13 + bob + tail, 7, 3), fur);
    // 몸 + 머리
    canvas.drawOval(Rect.fromLTWH(7, 14 + bob, 15, 10), fur);
    canvas.drawCircle(Offset(21, 12 + bob), 6, fur);
    // 귀
    final earL = Path()
      ..moveTo(17, 9 + bob)
      ..lineTo(18.5, 4 + bob)
      ..lineTo(21, 8 + bob)
      ..close();
    final earR = Path()
      ..moveTo(22, 8 + bob)
      ..lineTo(24.5, 3.5 + bob)
      ..lineTo(26, 8.5 + bob)
      ..close();
    canvas.drawPath(earL, fur);
    canvas.drawPath(earR, fur);
    canvas.drawCircle(Offset(19, 7.5 + bob), 0.9, pink);
    // 눈·코
    canvas.drawCircle(Offset(20, 11.5 + bob), 1.0, dark);
    canvas.drawCircle(Offset(24, 11.5 + bob), 1.0, dark);
    canvas.drawCircle(Offset(22.2, 13.8 + bob), 1.0, pink);
    // 발
    canvas.drawOval(const Rect.fromLTWH(10, 23, 4, 3), fur);
    canvas.drawOval(const Rect.fromLTWH(17, 23, 4, 3), fur);
  }

  void _drawBird(Canvas canvas, double bob) {
    final body = Paint()..color = const Color(0xFF7EB6E8);
    final belly = Paint()..color = const Color(0xFFD8ECFA);
    final beak = Paint()..color = const Color(0xFFFFB35C);
    final hop = _walkingNow ? bob * 1.4 : bob;
    canvas.drawCircle(Offset(16, 17 + hop), 6.5, body);
    canvas.drawOval(Rect.fromLTWH(12, 17 + hop, 8, 5.5), belly);
    canvas.drawCircle(Offset(20.5, 13 + hop), 4.2, body);
    // 부리
    final bk = Path()
      ..moveTo(24, 12.5 + hop)
      ..lineTo(28, 13.5 + hop)
      ..lineTo(24, 14.5 + hop)
      ..close();
    canvas.drawPath(bk, beak);
    canvas.drawCircle(Offset(21.5, 12 + hop), 1.0,
        Paint()..color = const Color(0xFF333344));
    // 날개 (파닥)
    final flap = math.sin(_time * 9) * (_walkingNow ? 2.2 : 0.7);
    canvas.drawOval(
        Rect.fromLTWH(10, 14 + hop - flap, 8, 5),
        Paint()..color = const Color(0xFF5C9AD0));
    // 꽁지
    canvas.drawOval(Rect.fromLTWH(7, 15 + hop, 5, 3),
        Paint()..color = const Color(0xFF5C9AD0));
    // 발
    canvas.drawRect(Rect.fromLTWH(14, 23 + hop * 0.3, 1.5, 3), beak);
    canvas.drawRect(Rect.fromLTWH(18, 23 + hop * 0.3, 1.5, 3), beak);
  }
}
