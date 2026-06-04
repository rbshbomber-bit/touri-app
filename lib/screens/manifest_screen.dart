import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../widgets/touri_app_bar.dart';

/// 매니페스테이션 보드 풀스크린. 여러 줄 자유 입력.
/// 닫기 = 자동 저장 (Navigator.pop에 텍스트 반환).
class ManifestScreen extends StatefulWidget {
  final String initialText;
  const ManifestScreen({super.key, required this.initialText});

  @override
  State<ManifestScreen> createState() => _ManifestScreenState();
}

class _ManifestScreenState extends State<ManifestScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: TouriColors.warmWhite,
        appBar: const TouriAppBar(
          title: '오늘 부르는 미래',
          subtitle: '한 줄 적어볼까',
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 배경: 우주 토우리 살짝
              Positioned(
                right: -40,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/character/scenes/scene_grid_9panels.png',
                    width: 280,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, 0.4),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: TouriColors.cocoa),
                          onPressed: _close,
                        ),
                        const Spacer(),
                        Text(
                          '닫으면 자동 저장 ♡',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: TouriColors.dim,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✦ MANIFESTATION',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF7B5FB8),
                                fontSize: 11,
                                letterSpacing: 1.4,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '내가 부르는 미래',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: TouriColors.cocoaDark,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '꿈은 작아도 진짜야. 토우리가 매일 같이 부를게.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: TouriColors.cocoa,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: TouriColors.lavender, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: TouriColors.touriPink.withOpacity(0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          autofocus: widget.initialText.isEmpty,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          cursorColor: const Color(0xFF7B5FB8),
                          style: TouriTheme.handwriting(fontSize: 18),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: '예) 나는 매일 조금씩 성장하고 있다.\n     내 일은 사람들에게 닿고 있다.',
                            hintStyle: TouriTheme.handwriting(
                              fontSize: 17,
                              color: TouriColors.dim,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
