import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/touri_colors.dart';

/// 모던 RPG 다이얼로그 — 화면 하단, 둥근 24px, blur 백그라운드.
/// 화살표 탭 / OK 탭으로 닫힘.
class TouriDialog extends StatefulWidget {
  final String text;
  final VoidCallback onDismiss;

  const TouriDialog({
    super.key,
    required this.text,
    required this.onDismiss,
  });

  @override
  State<TouriDialog> createState() => _TouriDialogState();
}

class _TouriDialogState extends State<TouriDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: TouriColors.touriPink.withOpacity(0.45),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: TouriColors.touriPink.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('🐰', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '토우리',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: TouriColors.cocoaDark,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: TouriColors.touriPink.withOpacity(0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            color: TouriColors.cocoaDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '탭해서 닫기',
                            style: TextStyle(
                              fontSize: 11,
                              color: TouriColors.cocoaDark.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
