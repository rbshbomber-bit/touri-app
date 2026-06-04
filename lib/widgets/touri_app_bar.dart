import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';

/// 토우리 앱 공통 헤더.
/// 좌측: ← 뒤로가기 (Navigator.pop)
/// 중앙: 화면 제목 (옵션 부제목)
/// 우측: 🏠 홈으로 점프 (스택 다 비우고 메인 셸로)
///
/// 사용:
///   appBar: TouriAppBar(title: '다이어리'),
///   appBar: TouriAppBar(title: '뉴스', actions: [...]),
class TouriAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showHomeJump;
  final Color? backgroundColor;

  const TouriAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showHomeJump = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 64);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: backgroundColor ?? TouriColors.warmWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          // ── 좌측 뒤로가기 ──
          if (canPop)
            _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).maybePop(),
              tooltip: '뒤로',
            )
          else
            const SizedBox(width: 8),
          const SizedBox(width: 6),
          // ── 중앙 제목 ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: TouriColors.cocoaDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: TouriColors.cocoa.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // ── 우측 actions ──
          ...actions,
          // ── 우측 🏠 홈으로 점프 ──
          if (showHomeJump && canPop) ...[
            const SizedBox(width: 4),
            _CircleIconButton(
              icon: Icons.home_rounded,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              tooltip: '홈으로',
            ),
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: TouriColors.cloudPink.withOpacity(0.55),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              icon,
              color: TouriColors.cocoaDark,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
