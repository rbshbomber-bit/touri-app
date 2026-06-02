import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';

/// 감사 일기 작은 카드. 채워진 개수 + 첫 줄 미리보기 + 탭 → 풀스크린.
class GratitudeCard extends StatelessWidget {
  final List<String> gratitude;
  final VoidCallback onTap;

  const GratitudeCard({super.key, required this.gratitude, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final filled = gratitude.where((g) => g.trim().isNotEmpty).toList();
    final firstLine = filled.isEmpty ? '' : filled.first.trim();

    return Material(
      color: TouriColors.cloudPink,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TouriColors.softPink, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('♡',
                      style: TextStyle(fontSize: 14, color: TouriColors.touriPink)),
                  const SizedBox(width: 4),
                  Text(
                    '감사한 일',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: TouriColors.touriPink,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${filled.length}/3',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: TouriColors.touriPink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                firstLine.isEmpty ? '오늘 작은 거 3가지!' : firstLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TouriTheme.handwriting(
                  fontSize: 15,
                  color: firstLine.isEmpty ? TouriColors.dim : TouriColors.cocoaDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
