import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';

/// 매니페스테이션 보드의 작은 카드. 첫 줄 미리보기 + 탭 → 풀스크린.
class ManifestCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ManifestCard({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final firstLine = text.trim().split('\n').firstOrNull?.trim() ?? '';
    final hasContent = firstLine.isNotEmpty;

    return Material(
      color: TouriColors.lilac.withOpacity(0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TouriColors.lavender, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✦', style: TextStyle(fontSize: 14, color: Color(0xFF7B5FB8))),
                  const SizedBox(width: 4),
                  Text(
                    '내가 부르는 미래',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF7B5FB8),
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hasContent ? firstLine : '꿈 한 줄, 적어둘까?',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TouriTheme.handwriting(
                  fontSize: 15,
                  color: hasContent ? TouriColors.cocoaDark : TouriColors.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
