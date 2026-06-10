import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../models/diary_sticker.dart';

/// 다이어리 페이퍼 위에 떠 있는 스티커 한 장.
/// interactive=true (스티커 모드)면 드래그·핀치·회전·길게눌러 삭제.
/// interactive=false면 보이기만.
class StickerView extends StatefulWidget {
  final DiarySticker sticker;
  final bool interactive;
  final ValueChanged<DiarySticker>? onChanged;
  final ValueChanged<String>? onDelete;

  const StickerView({
    super.key,
    required this.sticker,
    this.interactive = false,
    this.onChanged,
    this.onDelete,
  });

  @override
  State<StickerView> createState() => _StickerViewState();
}

class _StickerViewState extends State<StickerView>
    with SingleTickerProviderStateMixin {
  static const _baseSize = 96.0;

  bool _selected = false;
  late final AnimationController _popController;
  late double _dx;
  late double _dy;
  late double _scale;
  late double _rotation;

  // 제스처 시작 시점 스냅샷 (delta 누적용)
  double _startDx = 0;
  double _startDy = 0;
  double _startScale = 1;
  double _startRotation = 0;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..forward();
    _sync(widget.sticker);
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sticker != oldWidget.sticker) {
      _sync(widget.sticker);
    }
  }

  void _sync(DiarySticker s) {
    _dx = s.dx;
    _dy = s.dy;
    _scale = s.scale;
    _rotation = s.rotation;
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startDx = _dx;
    _startDy = _dy;
    _startScale = _scale;
    _startRotation = _rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _dx = _startDx + d.focalPointDelta.dx;
      _dy = _startDy + d.focalPointDelta.dy;
      _scale = (_startScale * d.scale).clamp(0.4, 3.0);
      _rotation = _startRotation + d.rotation;
    });
  }

  void _onScaleEnd(ScaleEndDetails _) {
    widget.onChanged?.call(widget.sticker.copyWith(
      dx: _dx,
      dy: _dy,
      scale: _scale,
      rotation: _rotation,
    ));
  }

  void _toggleSelect() {
    if (!widget.interactive) return;
    setState(() => _selected = !_selected);
  }

  @override
  Widget build(BuildContext context) {
    final size = _baseSize * _scale;
    final core = AnimatedBuilder(
      animation: _popController,
      builder: (context, _) {
        final pop = Curves.elasticOut.transform(_popController.value);
        return Transform.scale(
          scale: 0.72 + 0.28 * pop,
          child: Transform.rotate(
            angle: _rotation,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selected && widget.interactive ? TouriColors.touriPink : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TouriColors.touriPink.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(widget.sticker.sourcePath, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );

    return Positioned(
      left: _dx - size / 2,
      top: _dy - size / 2,
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.interactive)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: _toggleSelect,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: core,
            )
          else
            core,

          // 삭제 버튼 — 선택 상태에서만
          if (_selected && widget.interactive)
            Positioned(
              top: -10,
              right: -10,
              child: Material(
                color: TouriColors.touriPink,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => widget.onDelete?.call(widget.sticker.id),
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
