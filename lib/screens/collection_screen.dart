import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/touri_colors.dart';
import '../theme/touri_theme.dart';
import '../models/generated_item.dart';
import '../models/touri_mood.dart';
import '../services/collection_service.dart';
import '../widgets/touri_app_bar.dart';

/// 토우리 수집함. 3열 정사각 그리드 + 풀스크린 액션 모달.
class CollectionScreen extends StatelessWidget {
  /// 다이어리에 붙이기 콜백. DiaryScreen이 DiarySticker로 변환해 오늘 entry에 추가.
  final void Function(GeneratedItem item) onAttachToToday;

  /// 다시 그리기 콜백. DiaryScreen이 orchestrator.generate(scene: item.prompt) 호출.
  final void Function(GeneratedItem item) onRegenerate;

  const CollectionScreen({
    super.key,
    required this.onAttachToToday,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '수집함 ✦', subtitle: '내 토우리들'),
      body: ListenableBuilder(
        listenable: CollectionService.instance,
        builder: (context, _) => FutureBuilder<List<GeneratedItem>>(
          future: CollectionService.instance.all(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data!;
            if (items.isEmpty) return const _EmptyState();
            return _Grid(
              items: items,
              onTap: (i) => _openFullscreen(context, i),
            );
          },
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, GeneratedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ItemFullscreen(
          item: item,
          onAttachToToday: () {
            onAttachToToday(item);
          },
          onRegenerate: () {
            onRegenerate(item);
          },
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<GeneratedItem> items;
  final void Function(GeneratedItem) onTap;
  const _Grid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.86,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _Tile(
        item: items[i],
        onTap: () => onTap(items[i]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final GeneratedItem item;
  final VoidCallback onTap;
  const _Tile({required this.item, required this.onTap});

  ImageProvider get _provider {
    if (item.localPath.startsWith('http')) return NetworkImage(item.localPath);
    if (kIsWeb) return NetworkImage(item.localPath);
    return FileImage(File(item.localPath));
  }

  @override
  Widget build(BuildContext context) {
    final mood = TouriMood.fromId(item.moodId);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TouriColors.cloudPink, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Image(
                  image: _provider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: TouriColors.mistPink,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: TouriColors.dim, size: 20),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: TouriColors.mistPink,
                alignment: Alignment.center,
                child: Text(
                  mood.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TouriColors.cocoaDark,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              '아직 토우리가 없어',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: TouriColors.cocoaDark,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '일기 쓰고 ✦ 그려줘를 눌러봐 ♡',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TouriColors.cocoa,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemFullscreen extends StatelessWidget {
  final GeneratedItem item;
  final VoidCallback onAttachToToday;
  final VoidCallback onRegenerate;
  const _ItemFullscreen({
    required this.item,
    required this.onAttachToToday,
    required this.onRegenerate,
  });

  ImageProvider get _provider {
    if (item.localPath.startsWith('http')) return NetworkImage(item.localPath);
    if (kIsWeb) return NetworkImage(item.localPath);
    return FileImage(File(item.localPath));
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      if (item.localPath.startsWith('http') || kIsWeb) {
        await Share.share('토우리가 그려줬어요 ♡ ${item.localPath}');
      } else {
        await Share.shareXFiles([XFile(item.localPath)], text: '토우리가 그려줬어요 ♡');
      }
    } catch (e) {
      if (context.mounted) _toast(context, '공유에 실패했어 — $e');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TouriColors.warmWhite,
        title: const Text('이 토우리 삭제할까?',
            style: TextStyle(color: TouriColors.cocoaDark)),
        content: const Text('한 번 지우면 못 돌려.',
            style: TextStyle(color: TouriColors.cocoa)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: TouriColors.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: TouriColors.touriPink)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await CollectionService.instance.delete(item.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: TouriColors.cocoaDark,
        elevation: 0,
        title: Text(
          TouriMood.fromId(item.moodId).label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: TouriColors.cocoaDark,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image(image: _provider, fit: BoxFit.contain),
              ),
            ),
          ),
          if (item.prompt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 4),
              child: Text(
                '"${item.prompt}"',
                textAlign: TextAlign.center,
                style: TouriTheme.handwriting(fontSize: 14, color: TouriColors.dim),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.push_pin_rounded,
                    label: '다이어리',
                    onTap: () {
                      Navigator.of(context).pop();
                      onAttachToToday();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.refresh_rounded,
                    label: '다시 그리기',
                    onTap: () {
                      Navigator.of(context).pop();
                      onRegenerate();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_rounded,
                    label: '공유',
                    onTap: () => _share(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TouriColors.cloudPink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: TouriColors.touriPink, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TouriColors.cocoaDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
