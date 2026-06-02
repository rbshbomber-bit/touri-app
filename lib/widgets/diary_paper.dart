import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../models/touri_mood.dart';

/// 다이어리 종이. 워시테이프 + 줄간격 + 자유 본문 입력 + 우상단 토우리 스티커.
class DiaryPaper extends StatefulWidget {
  final TouriMood mood;
  final String initialText;
  final ValueChanged<String> onChanged;

  const DiaryPaper({
    super.key,
    required this.mood,
    required this.initialText,
    required this.onChanged,
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
    // 외부에서 다른 날짜 엔트리가 로드된 경우만 컨트롤러 동기화.
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
        border: Border.all(color: TouriColors.paperLine),
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
                  child: Image.asset(widget.mood.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),

            Padding(
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
          ],
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
