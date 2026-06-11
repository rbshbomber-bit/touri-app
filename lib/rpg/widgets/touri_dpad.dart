import 'package:flutter/material.dart';
import '../../theme/touri_colors.dart';
import '../touri_player.dart';

/// 가상 D-pad v2 — 꾹 누르고 있는 동안 계속 이동 (홀드 입력).
class TouriDpad extends StatelessWidget {
  final void Function(TouriDirection) onDirStart;
  final void Function(TouriDirection) onDirEnd;
  final VoidCallback onA;
  final VoidCallback? onB;

  const TouriDpad({
    super.key,
    required this.onDirStart,
    required this.onDirEnd,
    required this.onA,
    this.onB,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, TouriDirection d) => _DpadBtn(
          icon: icon,
          onDown: () => onDirStart(d),
          onUp: () => onDirEnd(d),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 왼쪽 — 십자키
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 44,
                child: btn(Icons.keyboard_arrow_up, TouriDirection.up),
              ),
              Positioned(
                bottom: 0,
                left: 44,
                child: btn(Icons.keyboard_arrow_down, TouriDirection.down),
              ),
              Positioned(
                top: 44,
                left: 0,
                child: btn(Icons.keyboard_arrow_left, TouriDirection.left),
              ),
              Positioned(
                top: 44,
                right: 0,
                child: btn(Icons.keyboard_arrow_right, TouriDirection.right),
              ),
              Positioned(
                top: 56,
                left: 56,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: TouriColors.touriPink.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 오른쪽 — A/B 버튼
        SizedBox(
          width: 120,
          height: 132,
          child: Stack(
            children: [
              if (onB != null)
                Positioned(
                  top: 24,
                  left: 0,
                  child: _ActionBtn(
                    label: 'B',
                    color: TouriColors.lilac,
                    onTap: onB!,
                  ),
                ),
              Positioned(
                top: 48,
                right: 0,
                child: _ActionBtn(
                  label: 'A',
                  color: TouriColors.touriPink,
                  onTap: onA,
                  big: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DpadBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  const _DpadBtn({
    required this.icon,
    required this.onDown,
    required this.onUp,
  });
  @override
  State<_DpadBtn> createState() => _DpadBtnState();
}

class _DpadBtnState extends State<_DpadBtn> {
  bool _down = false;

  void _press() {
    if (_down) return;
    setState(() => _down = true);
    widget.onDown();
  }

  void _release() {
    if (!_down) return;
    setState(() => _down = false);
    widget.onUp();
  }

  @override
  void dispose() {
    // 위젯이 사라질 때 (다이얼로그 등) 눌림 상태 누수 방지
    if (_down) widget.onUp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedScale(
        scale: _down ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _down
                ? TouriColors.touriPink.withOpacity(0.9)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 26,
            color: _down ? Colors.white : TouriColors.cocoaDark,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool big;
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.big = false,
  });
  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.big ? 60.0 : 44.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.big ? 22 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
