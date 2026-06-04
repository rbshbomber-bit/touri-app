import 'package:flutter/material.dart';
import '../../theme/touri_colors.dart';
import '../../services/checklist_service.dart';

/// 오늘의 manifestation 체크리스트 5항목 카드.
/// 다 체크되면 카드 테두리·glow 펄스 + 칭찬 메시지.
class ManifestChecklistCard extends StatefulWidget {
  final VoidCallback onOpenGratitude;
  final VoidCallback onOpenManifest;
  final VoidCallback onOpenCollection;
  final VoidCallback onBreathTap;

  const ManifestChecklistCard({
    super.key,
    required this.onOpenGratitude,
    required this.onOpenManifest,
    required this.onOpenCollection,
    required this.onBreathTap,
  });

  @override
  State<ManifestChecklistCard> createState() => _ManifestChecklistCardState();
}

class _ManifestChecklistCardState extends State<ManifestChecklistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    ChecklistService.instance.load();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  static const _items = <_ChecklistItem>[
    _ChecklistItem(
      id: 'breath',
      label: '마음챙김 5분 호흡',
      praise: '🌿 깊은 숨, 잘했어',
      hasArrow: true,
    ),
    _ChecklistItem(
      id: 'gratitude',
      label: '감사한 일 3가지',
      praise: '♡ 작은 거 알아채줘서 고마워',
      hasArrow: true,
    ),
    _ChecklistItem(
      id: 'manifest',
      label: '매니페스테이션 한 줄',
      praise: '✦ 부를수록 가까워져',
      hasArrow: true,
    ),
    _ChecklistItem(
      id: 'vision',
      label: 'Vision board 보기',
      praise: '✨ 너가 모은 토우리들이야',
      hasArrow: true,
    ),
    _ChecklistItem(
      id: 'selfmessage',
      label: '오늘 나에게 한 마디',
      praise: '🤍 잘 적었어, 다정한 사람',
      hasArrow: false,
    ),
  ];

  void _onAction(String id) {
    switch (id) {
      case 'breath':
        widget.onBreathTap();
        break;
      case 'gratitude':
        widget.onOpenGratitude();
        break;
      case 'manifest':
        widget.onOpenManifest();
        break;
      case 'vision':
        widget.onOpenCollection();
        break;
      case 'selfmessage':
        _openSelfMessage();
        break;
    }
  }

  Future<void> _openSelfMessage() async {
    final controller =
        TextEditingController(text: ChecklistService.instance.selfMessage);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TouriColors.warmWhite,
        title: const Text('오늘 나에게 한 마디 ♡',
            style: TextStyle(color: TouriColors.cocoaDark)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '예: 오늘도 충분히 잘했어',
            hintStyle: TextStyle(color: TouriColors.dim),
          ),
          style: const TextStyle(color: TouriColors.cocoaDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: TouriColors.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('저장',
                style: TextStyle(color: TouriColors.touriPink, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ChecklistService.instance.setSelfMessage(result);
    if (result.isNotEmpty) {
      await ChecklistService.instance.setDone('selfmessage', true);
      if (!mounted) return;
      _praise(_items.firstWhere((i) => i.id == 'selfmessage').praise);
    }
  }

  void _praise(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF7B5FB8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggle(String id) async {
    final cur = ChecklistService.instance.items[id] ?? false;
    await ChecklistService.instance.setDone(id, !cur);
    if (!cur) {
      final item = _items.firstWhere((i) => i.id == id);
      _praise(item.praise);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChecklistService.instance,
      builder: (context, _) {
        final items = ChecklistService.instance.items;
        final allDone = ChecklistService.instance.allDone;
        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = allDone ? _pulse.value : 0.0;
            return Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: allDone
                      ? Color.lerp(
                          TouriColors.lavender, TouriColors.touriPink, t)!
                      : TouriColors.lavender,
                  width: allDone ? 2 : 1,
                ),
                boxShadow: allDone
                    ? [
                        BoxShadow(
                          color: TouriColors.touriPink.withOpacity(0.18 + 0.18 * t),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.task_alt_rounded,
                      color: Color(0xFF7B5FB8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 manifestation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: TouriColors.cocoaDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${ChecklistService.instance.doneCount}/${ChecklistService.itemIds.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: TouriColors.touriPink,
                    ),
                  ),
                ],
              ),
              if (allDone) ...[
                const SizedBox(height: 6),
                Text(
                  '✨ 오늘의 manifestation 완료! 잘했어',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7B5FB8),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
              const SizedBox(height: 6),
              ..._items.map((item) {
                final done = items[item.id] ?? false;
                return _Row(
                  item: item,
                  done: done,
                  onCheck: () => _toggle(item.id),
                  onAction: () => _onAction(item.id),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistItem {
  final String id;
  final String label;
  final String praise;
  final bool hasArrow;
  const _ChecklistItem({
    required this.id,
    required this.label,
    required this.praise,
    required this.hasArrow,
  });
}

class _Row extends StatelessWidget {
  final _ChecklistItem item;
  final bool done;
  final VoidCallback onCheck;
  final VoidCallback onAction;
  const _Row({
    required this.item,
    required this.done,
    required this.onCheck,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAction,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            GestureDetector(
              onTap: onCheck,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? TouriColors.touriPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: done ? TouriColors.touriPink : TouriColors.dim,
                    width: 1.6,
                  ),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: done ? TouriColors.dim : TouriColors.cocoaDark,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: TouriColors.dim,
                ),
              ),
            ),
            if (item.hasArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: TouriColors.dim, size: 18),
          ],
        ),
      ),
    );
  }
}
