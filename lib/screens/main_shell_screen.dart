import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';
import 'home_feed_screen.dart';
import 'menu_screen.dart';

/// 앱 메뉴 셸. 홈 피드 + 메뉴 그리드 2탭.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  static const _screens = [
    HomeFeedScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 68,
        backgroundColor: TouriColors.warmWhite,
        indicatorColor: TouriColors.cloudPink,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: TouriColors.cocoaDark,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded, color: TouriColors.dim),
            selectedIcon:
                Icon(Icons.home_rounded, color: TouriColors.touriPink),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded, color: TouriColors.dim),
            selectedIcon:
                Icon(Icons.grid_view_rounded, color: TouriColors.touriPink),
            label: '메뉴',
          ),
        ],
      ),
    );
  }
}
