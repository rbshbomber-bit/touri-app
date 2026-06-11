import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../rpg/touri_rpg_game.dart';
import '../rpg/widgets/touri_dialog.dart';
import '../rpg/widgets/touri_dpad.dart';
import '../services/pet_service.dart';
import '../models/pet_stat.dart';
import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';

/// 토우리 마을 RPG — Flame 게임 + D-pad + 모던 다이얼로그.
/// v2: 4배 넓어진 마을, 자유 이동, 동물 주민, 낮밤 분위기.
class TouriRpgScreen extends StatefulWidget {
  const TouriRpgScreen({super.key});

  @override
  State<TouriRpgScreen> createState() => _TouriRpgScreenState();
}

class _TouriRpgScreenState extends State<TouriRpgScreen> {
  late final TouriRpgGame _game;
  String? _dialogText;

  @override
  void initState() {
    super.initState();
    _game = TouriRpgGame(onInteract: _showDialog);
  }

  void _showDialog(String text) {
    // 같은 다이얼로그 연타 방지
    if (_dialogText != null) return;
    // 입력 상태 초기화 (D-pad가 사라지며 up 이벤트가 유실될 수 있음)
    _game.clearInput();
    // 상호작용 시 능력치 살짝
    if (text.contains('+1')) {
      if (text.contains('사랑')) {
        PetService.instance.reward(PetStat.love, amount: 1, source: '마을 산책');
      } else if (text.contains('행복')) {
        PetService.instance.reward(PetStat.sparkle, amount: 1, source: '마을 산책');
      } else if (text.contains('에너지')) {
        PetService.instance.reward(PetStat.focus, amount: 1, source: '우물물');
      }
    }
    setState(() => _dialogText = text);
  }

  void _dismissDialog() {
    if (mounted) {
      // 집 옆 다이얼로그 닫으면 → 방(PetCareScreen)으로 복귀
      final wasGoingHome = _dialogText?.contains('방으로 돌아가기') ?? false;
      setState(() => _dialogText = null);
      if (wasGoingHome && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFADDE2), // 핑크풍 마을
      appBar: const TouriAppBar(
        title: '토우리 마을 🏠',
        subtitle: '같이 산책하자',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 게임 캔버스
            Positioned.fill(
              child: GameWidget(game: _game),
            ),
            // 우상단 안내 chip
            const Positioned(
              top: 10,
              right: 12,
              child: _HintChip(
                text: '🌸 꾹 눌러 산책 · 친구 옆에서 A',
              ),
            ),
            // 하단 D-pad (다이얼로그 떠 있으면 숨김)
            if (_dialogText == null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: TouriDpad(
                  onDirStart: (d) => _game.pressDir(d),
                  onDirEnd: (d) => _game.releaseDir(d),
                  onA: () => _game.interact(),
                ),
              ),
            // 다이얼로그
            if (_dialogText != null)
              TouriDialog(
                text: _dialogText!,
                onDismiss: _dismissDialog,
              ),
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String text;
  const _HintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TouriColors.touriPink.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: TouriColors.cocoaDark,
        ),
      ),
    );
  }
}
