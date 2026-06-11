import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// 시간대별 마을 분위기 (실제 시계 기준).
/// 아침 6-9 / 낮 9-17 / 노을 17-20 / 밤 20-6
class TownAmbient {
  static int get _hour => DateTime.now().hour;

  static bool get isNight => _hour >= 20 || _hour < 6;
  static bool get isSunset => _hour >= 17 && _hour < 20;
  static bool get isMorning => _hour >= 6 && _hour < 9;

  /// 가로등·창문 불 켜짐 (노을부터)
  static bool get lampsOn => isNight || isSunset;

  static bool get hasTint => isNight || isSunset || isMorning;

  static Color get tint {
    if (isNight) return const Color(0x55283A66); // 남보라 밤
    if (isSunset) return const Color(0x2EFF9E80); // 주황 노을
    if (isMorning) return const Color(0x14FFD180); // 황금 아침
    return const Color(0x00000000);
  }
}

/// 화면 전체 색조 오버레이 — 카메라 viewport에 추가.
class DayNightOverlay extends Component with HasGameReference {
  DayNightOverlay() {
    priority = 100;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!TownAmbient.hasTint) return;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()..color = TownAmbient.tint,
    );
  }
}

/// 벚꽃잎 흩날림 — 마을 전체에 잎 30장이 떨어지며 순환.
class PetalLayer extends Component {
  PetalLayer({required this.mapW, required this.mapH, this.count = 30}) {
    priority = 30;
  }

  final double mapW;
  final double mapH;
  final int count;
  final List<_Petal> _petals = [];
  final math.Random _rng = math.Random(3);
  double _time = 0;

  static const _colors = [
    Color(0xFFF8A8C0),
    Color(0xFFFCBED1),
    Color(0xFFFFD7E4),
  ];

  @override
  Future<void> onLoad() async {
    super.onLoad();
    for (int i = 0; i < count; i++) {
      _petals.add(_spawn(anywhere: true));
    }
  }

  _Petal _spawn({bool anywhere = false}) {
    return _Petal(
      x: _rng.nextDouble() * mapW,
      y: anywhere ? _rng.nextDouble() * mapH : -8,
      vy: 13 + _rng.nextDouble() * 14,
      phase: _rng.nextDouble() * math.pi * 2,
      rot: _rng.nextDouble() * math.pi * 2,
      vr: (_rng.nextDouble() - 0.5) * 3.0,
      sz: 2.0 + _rng.nextDouble() * 1.4,
      color: _colors[_rng.nextInt(_colors.length)],
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    for (int i = 0; i < _petals.length; i++) {
      final p = _petals[i];
      p.y += p.vy * dt;
      p.x += math.sin(_time * 1.4 + p.phase) * 11 * dt;
      p.rot += p.vr * dt;
      if (p.y > mapH + 8) {
        _petals[i] = _spawn();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final p in _petals) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.sz * 1.6, height: p.sz),
          const Radius.circular(1),
        ),
        Paint()..color = p.color,
      );
      canvas.restore();
    }
  }
}

class _Petal {
  _Petal({
    required this.x,
    required this.y,
    required this.vy,
    required this.phase,
    required this.rot,
    required this.vr,
    required this.sz,
    required this.color,
  });

  double x, y, vy, phase, rot, vr, sz;
  final Color color;
}

/// 발걸음 먼지 퍼프 — 짧게 커지며 사라짐.
class DustPuff extends PositionComponent {
  DustPuff(Vector2 pos) {
    position = pos;
    anchor = Anchor.center;
    priority = 5;
  }

  static const double life = 0.38;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    if (_t >= life) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final p = (_t / life).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset.zero,
      2 + 4 * p,
      Paint()..color = Color.fromRGBO(255, 255, 255, (1 - p) * 0.45),
    );
  }
}
