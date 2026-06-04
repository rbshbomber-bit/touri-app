import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';

/// 다이어리에 자동 부착된 생성 일러스트.
/// 탭하면 풀스크린 확대 + 액션 3개 (현재는 토스트).
class GeneratedImageView extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onRegenerate;
  const GeneratedImageView({
    super.key,
    required this.imagePath,
    this.onRegenerate,
  });

  ImageProvider get _provider {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    if (kIsWeb) {
      return NetworkImage(imagePath);
    }
    return FileImage(File(imagePath));
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreen(
          provider: _provider,
          onRegenerate: onRegenerate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TouriColors.softPink, width: 1),
            boxShadow: [
              BoxShadow(
                color: TouriColors.touriPink.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      '오늘의 토우리',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: TouriColors.touriPink,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '탭해서 크게',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: TouriColors.dim,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 1.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openFullscreen(context),
                    child: Image(
                      image: _provider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: TouriColors.mistPink,
                        alignment: Alignment.center,
                        child: const Text(
                          '이미지 불러오기 실패',
                          style: TextStyle(color: TouriColors.cocoa),
                        ),
                      ),
                    ),
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

class _FullScreen extends StatelessWidget {
  final ImageProvider provider;
  final VoidCallback? onRegenerate;
  const _FullScreen({required this.provider, this.onRegenerate});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
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
          '오늘의 토우리',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: TouriColors.cocoaDark,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image(image: provider, fit: BoxFit.contain),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.refresh_rounded,
                    label: '다시 그리기',
                    onTap: () {
                      Navigator.of(context).pop();
                      onRegenerate?.call();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.download_rounded,
                    label: '갤러리',
                    onTap: () => _toast(context, '곧 출시 ♡'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_rounded,
                    label: '공유',
                    onTap: () => _toast(context, '곧 출시 ♡'),
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
