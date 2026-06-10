import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../models/touri_mood.dart';
import '../models/diary_sticker.dart';
import 'sticker_view.dart';
import 'touri_motion.dart';

/// 다이어리 종이. 워시테이프 + 줄간격 + 자유 본문 + 우상단 토우리 + 스티커 레이어.
class DiaryPaper extends StatefulWidget {
  final TouriMood mood;
  final String initialText;
  final ValueChanged<String> onChanged;
  final List<DiarySticker> stickers;
  final bool stickerMode;
  final ValueChanged<DiarySticker>? onStickerChanged;
  final ValueChanged<String>? onStickerDelete;
  final VoidCallback? onToggleMode;
  final VoidCallback? onPickSticker;
  final VoidCallback? onRequestGeneration;
  final int generationRemaining;
  final bool generationBusy;

  const DiaryPaper({
    super.key,
    required this.mood,
    required this.initialText,
    required this.onChanged,
    this.stickers = const [],
    this.stickerMode = false,
    this.onStickerChanged,
    this.onStickerDelete,
    this.onToggleMode,
    this.onPickSticker,
    this.onRequestGeneration,
    this.generationRemaining = 3,
    this.generationBusy = false,
  });

  @override
  State<DiaryPaper> createState() => _DiaryPaperState();
}

class _DiaryPaperState extends State<DiaryPaper> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant DiaryPaper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != _controller.text && widget.initialText != oldWidget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TouriColors.paperBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.stickerMode ? TouriColors.touriPink : TouriColors.paperLine,
          width: widget.stickerMode ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _LinePainter())),

            const _WashiTape(left: 24, color: TouriColors.touriPink, rot: -3),
            const _WashiTape(right: 30, color: TouriColors.lavender, rot: 4),

            Positioned(
              top: 18,
              right: 16,
              child: Transform.rotate(
                angle: 0.08,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: TouriColors.touriPink.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedTouriAvatar(
                    amplitude: 0.02,
                    child: Image.asset(
                      widget.mood.imagePath,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.2),
                    ),
                  ),
                ),
              ),
            ),

            // 본문 텍스트 — 스티커 모드일 땐 입력 차단
            IgnorePointer(
              ignoring: widget.stickerMode,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 116, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘 일기 ✦',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: TouriColors.touriPink,
                            fontSize: 17,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: widget.onChanged,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        cursorColor: TouriColors.touriPink,
                        style: TouriTheme.handwriting(fontSize: 17),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: '오늘 마음을 적어볼까?\n토우리가 옆에서 같이 있어줄게.',
                          hintStyle: TouriTheme.handwriting(
                            fontSize: 17,
                            color: TouriColors.dim,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 스티커 레이어 — 텍스트 모드일 땐 인터랙션 무시(보이기만)
            ...widget.stickers.map((s) => StickerView(
                  key: ValueKey(s.id),
                  sticker: s,
                  interactive: widget.stickerMode,
                  onChanged: widget.onStickerChanged,
                  onDelete: widget.onStickerDelete,
                )),

            // 우하단 모드 토글 버튼
            Positioned(
              right: 12,
              bottom: 12,
              child: _RoundButton(
                icon: widget.stickerMode ? Icons.check_rounded : Icons.auto_awesome_rounded,
                label: widget.stickerMode ? '끝내기' : null,
                onTap: widget.onToggleMode,
              ),
            ),

            // 좌하단 — 스티커 모드면 picker, 평소엔 그려줘 버튼
            if (widget.stickerMode)
              Positioned(
                left: 12,
                bottom: 12,
                child: _RoundButton(
                  icon: Icons.add_rounded,
                  onTap: widget.onPickSticker,
                ),
              )
            else
              Positioned(
                left: 12,
                bottom: 12,
                child: _GenerateButton(
                  onTap: widget.onRequestGeneration,
                  remaining: widget.generationRemaining,
                  busy: widget.generationBusy,
                ),
              ),

            if (widget.generationBusy)
              Positioned(
                left: 12,
                bottom: 54,
                child: _DrawingHint(imagePath: widget.mood.avatarPath),
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawingHint extends StatefulWidget {
  final String imagePath;
  const _DrawingHint({required this.imagePath});

  @override
  State<_DrawingHint> createState() => _DrawingHintState();
}

class _DrawingHintState extends State<_DrawingHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -2 * t),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TouriColors.cloudPink, width: 1),
              boxShadow: [
                BoxShadow(
                  color: TouriColors.touriPink.withOpacity(0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 6),
                Transform.rotate(
                  angle: -0.18 + 0.36 * t,
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: TouriColors.touriPink,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  '토우리가 그리는 중',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: TouriColors.cocoaDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final VoidCallback? onTap;
  final int remaining;
  final bool busy;
  const _GenerateButton({this.onTap, required this.remaining, required this.busy});

  @override
  Widget build(BuildContext context) {
    final disabled = busy || remaining <= 0;
    const purple = Color(0xFF7B5FB8);
    return Material(
      color: disabled ? TouriColors.dim : purple,
      shape: const StadiumBorder(),
      elevation: disabled ? 0 : 3,
      shadowColor: purple.withOpacity(0.4),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                busy ? '그리는 중' : '그려줘',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$remaining/3',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  const _RoundButton({required this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null;
    return Material(
      color: TouriColors.touriPink,
      shape: hasLabel
          ? const StadiumBorder()
          : const CircleBorder(),
      elevation: 3,
      shadowColor: TouriColors.touriPink.withOpacity(0.4),
      child: InkWell(
        customBorder: hasLabel ? const StadiumBorder() : const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: hasLabel
              ? const EdgeInsets.fromLTRB(12, 8, 16, 8)
              : const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              if (hasLabel) ...[
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WashiTape extends StatelessWidget {
  final double? left;
  final double? right;
  final Color color;
  final double rot;
  const _WashiTape({this.left, this.right, required this.color, required this.rot});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -8,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rot * 3.14159 / 180,
        child: Container(
          width: 70,
          height: 24,
          color: color.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TouriColors.paperLine
      ..strokeWidth = 1;
    for (double y = 28; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
