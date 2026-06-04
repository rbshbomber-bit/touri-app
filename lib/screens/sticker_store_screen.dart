import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../data/sticker_packs.dart';
import '../widgets/touri_app_bar.dart';

/// 시즌 한정 스티커 상점. 4시즌 2×2 + 상세 페이지.
class StickerStoreScreen extends StatelessWidget {
  const StickerStoreScreen({super.key});

  void _openDetail(BuildContext context, SeasonalPack pack) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _PackDetailScreen(pack: pack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '시즌팩 ✦', subtitle: '계절 한정 토우리'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _IntroCard(),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
            children: seasonalPacks
                .map((p) => _PackCard(pack: p, onTap: () => _openDetail(context, p)))
                .toList(),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              '미리보기 5장은 무료 ♡',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: TouriColors.dim,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD1DC), Color(0xFFEADCF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦ SEASONAL COLLECTION',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7B5FB8),
                  fontSize: 11,
                  letterSpacing: 1.4,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '계절마다 새로운\n토우리가 도착해 ♡',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: TouriColors.cocoaDark,
                  fontSize: 22,
                  height: 1.25,
                ),
          ),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final SeasonalPack pack;
  final VoidCallback onTap;
  const _PackCard({required this.pack, required this.onTap});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(pack.coverPath, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B5FB8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pack.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: TouriColors.cocoaDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '12장 · ₩${_format(pack.priceWon)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: TouriColors.cocoa,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PackDetailScreen extends StatelessWidget {
  final SeasonalPack pack;
  const _PackDetailScreen({required this.pack});

  static const _freePreviewCount = 5;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF7B5FB8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: AppBar(
        backgroundColor: TouriColors.warmWhite,
        foregroundColor: TouriColors.cocoaDark,
        elevation: 0,
        title: Text(
          pack.label,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: TouriColors.cocoaDark,
                fontSize: 20,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    pack.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TouriColors.cocoa,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: pack.items.length,
                  itemBuilder: (context, i) => _ItemTile(
                    path: pack.items[i],
                    locked: i >= _freePreviewCount,
                  ),
                ),
                const SizedBox(height: 12),
                _UnlockNote(),
              ],
            ),
          ),
          _PurchaseBar(
            pack: pack,
            onPurchase: () =>
                _toast(context, '곧 출시 — 텀블벅에서 만나요 ♡'),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String path;
  final bool locked;
  const _ItemTile({required this.path, required this.locked});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(path, fit: BoxFit.cover),
          if (locked)
            Container(
              decoration: BoxDecoration(
                color: TouriColors.warmWhite.withOpacity(0.78),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.lock_rounded,
                  color: Color(0xFF7B5FB8), size: 22),
            ),
        ],
      ),
    );
  }
}

class _UnlockNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: TouriColors.cloudPink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, color: Color(0xFF7B5FB8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '5장은 미리 볼 수 있어. 나머지 7장은 잠겨있어.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TouriColors.cocoaDark,
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseBar extends StatelessWidget {
  final SeasonalPack pack;
  final VoidCallback onPurchase;
  const _PurchaseBar({required this.pack, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: TouriColors.touriPink.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₩${_format(pack.priceWon)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7B5FB8),
                    ),
                  ),
                  const Text(
                    '일회성 · 12장 한 번에',
                    style: TextStyle(
                      fontSize: 11,
                      color: TouriColors.dim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Material(
              color: const Color(0xFF7B5FB8),
              shape: const StadiumBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onPurchase,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Text(
                    '구매하기 ✦',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
