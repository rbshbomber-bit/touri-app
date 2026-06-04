import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../data/sticker_catalog.dart';

/// 다이어리에 붙일 스티커를 고르는 하단 모달 시트.
class StickerPickerSheet extends StatelessWidget {
  final ValueChanged<StickerAsset> onPicked;
  const StickerPickerSheet({super.key, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TouriColors.warmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: TouriColors.softPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '✦ 스티커 고르기',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: TouriColors.cocoaDark,
                            fontSize: 20,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${stickerCatalog.length}종',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: TouriColors.dim,
                          ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Text(
                  '꾹 눌러서 다이어리에 붙일 토우리를 골라봐!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TouriColors.cocoa,
                      ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: stickerCatalog.length,
                  itemBuilder: (context, i) => _StickerTile(
                    asset: stickerCatalog[i],
                    onTap: () {
                      onPicked(stickerCatalog[i]);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StickerTile extends StatelessWidget {
  final StickerAsset asset;
  final VoidCallback onTap;
  const _StickerTile({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TouriColors.cloudPink, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  asset.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: TouriColors.mistPink,
                alignment: Alignment.center,
                child: Text(
                  asset.label,
                  style: const TextStyle(
                    fontSize: 11,
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
