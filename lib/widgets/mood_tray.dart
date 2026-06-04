import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../models/touri_mood.dart';

/// 화면 하단의 무드 선택 트레이. 4개 무드를 한 줄로 보여주고
/// 탭하면 onChanged로 알려줌. 와이드 화면에선 480px로 max.
class MoodTray extends StatelessWidget {
  final TouriMood selected;
  final ValueChanged<TouriMood> onChanged;

  const MoodTray({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 토우리 무드',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TouriColors.dim,
                ),
              ),
              Text(
                '${selected.label} 모드',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TouriColors.touriPink,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Row(
              children: TouriMood.values.map((mood) {
                final isSelected = mood == selected;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _MoodButton(
                      mood: mood,
                      selected: isSelected,
                      onTap: () => onChanged(mood),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  final TouriMood mood;
  final bool selected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TouriColors.cloudPink,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? TouriColors.touriPink : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: TouriColors.touriPink.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  mood.avatarPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: TouriColors.warmWhite.withOpacity(0.92),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    alignment: Alignment.center,
                    child: Text(
                      mood.label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TouriColors.cocoaDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
