import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../widgets/touri_app_bar.dart';

/// 감사 일기 풀스크린. 3개 슬롯. 닫기 = 자동 저장.
class GratitudeScreen extends StatefulWidget {
  final List<String> initial;
  const GratitudeScreen({super.key, required this.initial});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final padded = [...widget.initial];
    while (padded.length < 3) {
      padded.add('');
    }
    _controllers = padded.take(3).map((s) => TextEditingController(text: s)).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(_controllers.map((c) => c.text).toList());
  }

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
          title: '오늘의 감사',
          subtitle: '세 가지만 떠올려봐',
        ),
        body: SafeArea(
          child: Column(
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
                      '♡ GRATITUDE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: TouriColors.touriPink,
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘 감사한 일 3가지',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: TouriColors.cocoaDark,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '아주 작은 것도 괜찮아. 따뜻한 커피, 햇살 한 줌도 ♡',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TouriColors.cocoa,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _GratitudeSlot(
                    index: i + 1,
                    controller: _controllers[i],
                    autofocus: i == 0 && widget.initial.every((s) => s.trim().isEmpty),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GratitudeSlot extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool autofocus;

  const _GratitudeSlot({
    required this.index,
    required this.controller,
    required this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TouriColors.cloudPink, width: 1),
        boxShadow: [
          BoxShadow(
            color: TouriColors.touriPink.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: TouriColors.touriPink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              maxLines: null,
              cursorColor: TouriColors.touriPink,
              style: TouriTheme.handwriting(fontSize: 17),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
                hintText: '예) 오전 햇살이 따뜻했어',
                hintStyle: TouriTheme.handwriting(
                  fontSize: 16,
                  color: TouriColors.dim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
