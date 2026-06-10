import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../services/pet_service.dart';
import 'touri_motion.dart';

/// 홈 피드 상단에 박는 토우리 상태창.
/// 좌측 토우리 아바타 + 단계 라벨 + 우측 능력치 막대 3개.
/// 탭하면 PetCareScreen 이동 (외부에서 onTap 주입).
class PetStatusCard extends StatelessWidget {
  final VoidCallback? onTap;
  const PetStatusCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PetService.instance,
      builder: (context, _) {
        final pet = PetService.instance.pet;
        final stage = pet.stage;
        return Material(
          color: TouriColors.cloudPink.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TouriColors.touriPink.withOpacity(0.5), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 토우리 아바타 — 픽셀 sprite 4프레임 자동 순환 (없으면 static)
                  AnimatedTouriAvatar(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: TouriColors.touriPink.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PixelSpriteAvatar(
                        framePaths: stage.spriteFramePaths,
                        fallbackPath: stage.imagePath,
                        size: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${stage.emoji} ${pet.customTitle ?? stage.label}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: TouriColors.cocoaDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: TouriColors.touriPink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '연속 ${pet.streak}일',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 진행률 + XP
                        _ProgressLine(
                          label: '다음 단계까지',
                          value: pet.progressToNext,
                          color: const Color(0xFF7B5FB8),
                          trailing: stage.xpToNext(pet.xp) == null
                              ? '최고 단계'
                              : '${stage.xpToNext(pet.xp)} XP',
                        ),
                        const SizedBox(height: 5),
                        // 케어 상태 3개 한 줄
                        Row(
                          children: [
                            _MiniBar(
                              emoji: '🍓',
                              value: pet.hunger,
                              color: TouriColors.touriPink,
                            ),
                            const SizedBox(width: 8),
                            _MiniBar(
                              emoji: '☀️',
                              value: pet.mood,
                              color: TouriColors.lavender,
                            ),
                            const SizedBox(width: 8),
                            _MiniBar(
                              emoji: '💤',
                              value: pet.energy,
                              color: TouriColors.mint,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 돌보기 가능 표시
                  if (pet.canCareToday)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TouriColors.touriPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TouriColors.touriPink.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String trailing;
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7B5FB8),
          ),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String emoji;
  final int value; // 0~10
  final Color color;
  const _MiniBar({required this.emoji, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = (value / 10).clamp(0.0, 1.0);
    return Expanded(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
