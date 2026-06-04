import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../models/touri_mood.dart';

/// 상단의 AI 토우리 카드. 무드 캐릭터 + 회전 멘트 + 새로고침.
class AiCompanionCard extends StatefulWidget {
  final TouriMood mood;
  const AiCompanionCard({super.key, required this.mood});

  @override
  State<AiCompanionCard> createState() => _AiCompanionCardState();
}

class _AiCompanionCardState extends State<AiCompanionCard> {
  int _msgIdx = 0;

  void _next() {
    setState(() => _msgIdx = (_msgIdx + 1) % widget.mood.aiOptions.length);
  }

  @override
  void didUpdateWidget(covariant AiCompanionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      setState(() => _msgIdx = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TouriColors.cloudPink,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.softPink, width: 1, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          // 캐릭터 아바타
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              mood.avatarPath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(width: 12),

          // 멘트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOURI ✦',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TouriColors.touriPink,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    mood.aiOptions[_msgIdx],
                    key: ValueKey('${mood.id}_$_msgIdx'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TouriColors.cocoaDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 새로고침
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _next,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.refresh_rounded,
                    color: TouriColors.touriPink, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
