import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import '../services/touri_storage.dart';
import '../widgets/touri_motion.dart';
import 'diary_screen.dart';
import 'collection_screen.dart';
import 'sticker_store_screen.dart';
import 'sticker_make_screen.dart';
import 'coaching_screen.dart';
import 'spirituality_screen.dart';
import 'news_screen.dart';
import 'auth_sheet.dart';
import 'pet_care_screen.dart';
import 'touri_rpg_screen.dart';
import 'admin_screen.dart';

/// 메뉴 — 3열 그리드 9개 진입점. 각 카드 토우리 이미지 + 라벨.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TouriStorage _storage = TouriStorage();
  late final String _dateKey;

  // 숨은 관리자 진입 — 헤더 "메뉴"를 3초 안에 7번 탭
  int _adminTapCount = 0;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _dateKey = TouriStorage.dateKeyFor(DateTime.now());
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDiary({bool hintGenerate = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DiaryScreen()),
    );
    if (hintGenerate) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _toast('✦ 그려줘 버튼을 눌러봐 ♡');
      });
    }
  }

  void _openCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(
          onAttachToToday: (_) => _toast('다이어리 탭에서 붙일 수 있어 ♡'),
          onRegenerate: (_) => _toast('다이어리 탭에서 다시 그릴 수 있어 ♡'),
        ),
      ),
    );
  }

  void _openStore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StickerStoreScreen()),
    );
  }

  void _openStickerMake() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StickerMakeScreen()),
    );
  }

  Future<void> _openCoaching() async {
    final entry = await _storage.load(_dateKey);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachingScreen(
          diary: entry.body,
          manifestation: entry.manifestation,
          mood: entry.mood,
        ),
      ),
    );
  }

  void _openSpirituality() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpiritualityScreen()),
    );
  }

  void _openPetCare() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PetCareScreen()),
    );
  }

  void _onHeaderTap() {
    final now = DateTime.now();
    if (_lastTap == null ||
        now.difference(_lastTap!) > const Duration(seconds: 3)) {
      _adminTapCount = 1; // 3초 넘으면 카운터 리셋
    } else {
      _adminTapCount++;
    }
    _lastTap = now;
    if (_adminTapCount >= 7) {
      _adminTapCount = 0;
      _lastTap = null;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    }
  }

  void _openRpg() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TouriRpgScreen()),
    );
  }

  void _openNews() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewsScreen()),
    );
  }

  void _openAuth() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuthSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        image: 'assets/character/menu_icons/diary.png',
        label: '다이어리',
        accent: TouriColors.cloudPink,
        onTap: () => _openDiary(),
      ),
      // 🐰 토우리 키우기 — 새 핵심 기능 (v2: 한 귀 처짐 시그니처)
      _MenuItem(
        image: 'assets/character/menu_icons/pet_growth_v2.png',
        label: '토우리 키우기',
        accent: TouriColors.touriPink,
        onTap: _openPetCare,
      ),
      // 🏠 토우리 마을 — RPG (포켓몬 도트 + 모던 UI)
      _MenuItem(
        image: 'assets/character/menu_icons/village.png',
        imageUrl: 'assets/assets/character/menu_icons/village.png?v=two-ear-20260611',
        label: '토우리 마을 🏠',
        accent: TouriColors.lilac,
        onTap: _openRpg,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/generate.png',
        label: '그려줘',
        accent: TouriColors.lilac,
        onTap: () => _openDiary(hintGenerate: true),
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/sticker_make.png',
        label: '스티커 제작',
        accent: TouriColors.mint,
        onTap: _openStickerMake,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/collection.png',
        label: '수집함',
        accent: TouriColors.cream,
        onTap: _openCollection,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/season_pack.png',
        label: '시즌팩',
        accent: TouriColors.bubble,
        onTap: _openStore,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/coaching.png',
        label: 'AI 코칭',
        accent: TouriColors.lavender,
        onTap: _openCoaching,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/spirituality.png',
        label: '영성',
        accent: TouriColors.lilac,
        onTap: _openSpirituality,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/news.png',
        label: '뉴스',
        accent: TouriColors.sky,
        onTap: _openNews,
      ),
      _MenuItem(
        image: 'assets/character/menu_icons/settings.png',
        label: '설정·로그인',
        accent: TouriColors.mistPink,
        onTap: _openAuth,
      ),
    ];

    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onHeaderTap,
                child: Text(
                  '메뉴',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '전부 한자리에 ✦',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TouriColors.cocoa,
                    ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _MenuTile(
                    item: items[i],
                    index: i,
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

class _MenuItem {
  final String image;
  final String? imageUrl;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  const _MenuItem({
    required this.image,
    this.imageUrl,
    required this.label,
    required this.accent,
    required this.onTap,
  });
}

class _MenuTile extends StatefulWidget {
  final _MenuItem item;
  final int index;
  const _MenuTile({required this.item, required this.index});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: 34 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TapBounce(
          onTap: widget.item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TouriColors.cloudPink, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: widget.item.accent,
                    alignment: Alignment.center,
                    child: _MenuImage(item: widget.item),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: TouriColors.cocoaDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  final _MenuItem item;
  const _MenuImage({required this.item});

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    if (url != null) {
      return Image.network(
        Uri.base.resolve(url).toString(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Image.asset(
          item.image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Image.asset(
      item.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
