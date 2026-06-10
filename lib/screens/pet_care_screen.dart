import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../services/pet_service.dart';
import '../models/pet_stat.dart';
import 'package:flame/game.dart';
import '../widgets/touri_app_bar.dart';
import '../widgets/touri_motion.dart';
import '../widgets/touri_game_scene.dart';
import '../games/touri_flame_game.dart';

/// 토우리 돌보기. 큰 토우리 + 능력치 + 일일 액션 3개 + 진화 컷씬.
class PetCareScreen extends StatefulWidget {
  const PetCareScreen({super.key});

  @override
  State<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends State<PetCareScreen> {
  int _reactionTrigger = 0;
  String _reactionSymbol = '♡';
  Color _reactionColor = TouriColors.touriPink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(
        title: '토우리 돌보기 ✦',
        subtitle: '오늘도 같이 자라자',
      ),
      body: ListenableBuilder(
        listenable: PetService.instance,
        builder: (context, _) {
          final pet = PetService.instance.pet;
          final stage = pet.stage;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // ── 🔥 Flame 게임 엔진 화면 (Day 1) ──
                // 본격 2D 게임 — Flame이 토우리 행동 자동 관리
                // 토우리가 자체적으로 걸어다님 + 가끔 점프 + 탭하면 그쪽으로 이동 or 폴짝
                Container(
                  height: 300,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TouriColors.touriPink.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      GameWidget.controlled(
                        gameFactory: () => TouriFlameGame(stage: stage),
                      ),
                      // 좌상단 단계 라벨 (HUD)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _HudChip(
                          text: '${stage.emoji} ${stage.label}',
                          fg: const Color(0xFF7B5FB8),
                        ),
                      ),
                      // 우상단 streak
                      Positioned(
                        right: 12,
                        top: 12,
                        child: _HudChip(
                          text: '🔥 ${pet.streak}d',
                          fg: TouriColors.cocoaDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // ── 단계 라벨 ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${stage.emoji} ${pet.customTitle ?? stage.label}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: TouriColors.cocoaDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (stage.xpToNext(pet.xp) != null)
                        Text(
                          '다음 단계까지 ${stage.xpToNext(pet.xp)} XP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: TouriColors.cocoa,
                          ),
                        )
                      else
                        Column(
                          children: [
                            const Text(
                              '✨ 마스터 단계 — 너의 칭호를 부여해줘',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7B5FB8),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '🌌 곧 별자리를 그릴 차례 — 별의 화신으로 승격 예정 (Phase 2)',
                              style: TextStyle(
                                fontSize: 10,
                                color: TouriColors.dim,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ── 진행률 막대 ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pet.progressToNext,
                    minHeight: 8,
                    backgroundColor: TouriColors.cloudPink,
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF7B5FB8)),
                  ),
                ),
                const SizedBox(height: 20),
                // ── 일일 돌보기 액션 ──
                Text(
                  '오늘의 돌보기 ${pet.canCareToday ? "✦" : "(완료 ♡)"}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: TouriColors.cocoaDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _CareButton(
                        emoji: '🍓',
                        label: '밥주기',
                        sub: '+사랑',
                        enabled: pet.canCareToday,
                        color: TouriColors.touriPink,
                        onTap: () => _doCare(
                          context,
                          PetService.instance.feed,
                          '🍓 토우리가 행복하게 먹었어',
                          '♡',
                          TouriColors.touriPink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CareButton(
                        emoji: '🫂',
                        label: '안아주기',
                        sub: '+마음',
                        enabled: pet.canCareToday,
                        color: TouriColors.lavender,
                        onTap: () => _doCare(
                          context,
                          PetService.instance.play,
                          '🫂 토우리가 폭 안겼어',
                          '✦',
                          const Color(0xFF7B5FB8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CareButton(
                        emoji: '💤',
                        label: '재우기',
                        sub: '+용기',
                        enabled: pet.canCareToday,
                        color: TouriColors.mint,
                        onTap: () => _doCare(
                          context,
                          PetService.instance.rest,
                          '💤 토우리가 쌔근쌔근',
                          '☾',
                          TouriColors.mint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ── 능력치 ──
                const Text(
                  '능력치 ✦',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: TouriColors.cocoaDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...PetStat.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _StatRow(stat: s, value: pet.stats[s] ?? 0),
                  ),
                ),
                const SizedBox(height: 16),
                // ── 돌보기 안내 ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TouriColors.cloudPink, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✦ 토우리가 자라는 법',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B5FB8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 다이어리 쓰면 💗 마음 +1\n'
                        '• Manifestation 쓰면 ⭐ 반짝임 +1\n'
                        '• 감사 3줄 쓰면 💞 사랑 +1\n'
                        '• 뉴스 읽으면 🎯 집중 +1\n'
                        '• 영성 체크 완료하면 🔥 용기 +1\n'
                        '• ✦ 그려줘 사용하면 ⭐ 반짝임 +2',
                        style: TouriTheme.handwriting(
                          fontSize: 13,
                          color: TouriColors.cocoa,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TouriColors.lilac.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: TouriColors.lavender,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '🌌 마스터 도달 이후 — 토우리는 별의 화신이 되고, '
                          '너의 행동마다 ⭐ 별이 모여 별자리를 그려. '
                          '7개씩 모이면 사용자가 이름을 부여하는 무한 컬렉션.',
                          style: TouriTheme.handwriting(
                            fontSize: 12,
                            color: const Color(0xFF7B5FB8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _doCare(
    BuildContext context,
    bool Function() action,
    String msg,
    String symbol,
    Color color,
  ) {
    final ok = action();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘 돌보기는 이미 끝났어 — 내일 또 보자 ♡'),
          backgroundColor: TouriColors.cocoaDark,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _reactionTrigger++;
      _reactionSymbol = symbol;
      _reactionColor = color;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF7B5FB8),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _CareButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;
  const _CareButton({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      elevation: enabled ? 3 : 0,
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  final String text;
  final Color fg;
  const _HudChip({required this.text, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final PetStat stat;
  final int value;
  const _StatRow({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = (value / 99).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '${stat.emoji} ${stat.label}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: TouriColors.cocoaDark,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: TouriColors.cloudPink,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7B5FB8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7B5FB8),
            ),
          ),
        ),
      ],
    );
  }
}
