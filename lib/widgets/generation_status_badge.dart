import 'package:flutter/material.dart';
import '../services/generation_orchestrator.dart';
import '../models/generation_status.dart';

/// 헤더 우측에 작게 떠있는 진행 뱃지.
/// orchestrator 구독, busy일 때만 표시. 펄스 애니메이션.
class GenerationStatusBadge extends StatefulWidget {
  const GenerationStatusBadge({super.key});

  @override
  State<GenerationStatusBadge> createState() => _GenerationStatusBadgeState();
}

class _GenerationStatusBadgeState extends State<GenerationStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GenerationOrchestrator.instance,
      builder: (context, _) {
        final s = GenerationOrchestrator.instance.status;
        if (!s.isBusy) return const SizedBox.shrink();

        final label = switch (s) {
          GenerationStatus.extracting => '✦ 마음 읽는 중',
          GenerationStatus.queued => '🎨 자리 잡는 중',
          GenerationStatus.generating => '🎨 그리는 중',
          GenerationStatus.downloading => '📥 가져오는 중',
          _ => '✦',
        };

        return FadeTransition(
          opacity: Tween(begin: 0.65, end: 1.0).animate(_pulse),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF7B5FB8).withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B5FB8).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
