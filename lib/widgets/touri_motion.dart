import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../theme/touri_colors.dart';

class AnimatedTouriAvatar extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  final bool float;

  const AnimatedTouriAvatar({
    super.key,
    required this.child,
    this.amplitude = 0.025,
    this.duration = const Duration(milliseconds: 2600),
    this.float = false,
  });

  @override
  State<AnimatedTouriAvatar> createState() => _AnimatedTouriAvatarState();
}

class _AnimatedTouriAvatarState extends State<AnimatedTouriAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale = 1 + widget.amplitude * t;
        final dy = widget.float ? -3 * t : 0.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }
}

class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const TapBounce({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 0.96 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap == null ? null : (_) => _setDown(true),
          onTapCancel: widget.onTap == null ? null : () => _setDown(false),
          onTapUp: widget.onTap == null ? null : (_) => _setDown(false),
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 다마고치 스타일 픽셀 sprite 애니메이션.
/// 4프레임을 step transition (보간 X)으로 순환.
/// frame 파일이 다 있으면 sprite 모드, 없으면 fallback static 이미지.
///
/// 사용:
///   PixelSpriteAvatar(
///     framePaths: stage.spriteFramePaths,    // 4장 경로
///     fallbackPath: stage.imagePath,         // 정적 1장
///     size: 200,
///   )
class PixelSpriteAvatar extends StatefulWidget {
  final List<String> framePaths;
  final String fallbackPath;
  final Duration frameDuration;
  final double size;
  final BoxFit fit;

  const PixelSpriteAvatar({
    super.key,
    required this.framePaths,
    required this.fallbackPath,
    this.frameDuration = const Duration(milliseconds: 400),
    this.size = 140,
    this.fit = BoxFit.contain,
  });

  @override
  State<PixelSpriteAvatar> createState() => _PixelSpriteAvatarState();
}

class _PixelSpriteAvatarState extends State<PixelSpriteAvatar> {
  Timer? _timer;
  int _index = 0;
  bool _spriteMode = false;

  @override
  void initState() {
    super.initState();
    _checkAssets();
  }

  @override
  void didUpdateWidget(covariant PixelSpriteAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 프레임 경로 바뀌면 (단계 진화 등) 다시 자산 확인
    final changed = oldWidget.framePaths.length != widget.framePaths.length ||
        !List.generate(widget.framePaths.length,
                (i) => widget.framePaths[i] == oldWidget.framePaths[i])
            .every((e) => e);
    if (changed) {
      _timer?.cancel();
      _index = 0;
      _spriteMode = false;
      _checkAssets();
    }
  }

  Future<void> _checkAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final keys = manifest.listAssets().toSet();
      final hasAll = widget.framePaths.every(keys.contains);
      if (!mounted) return;
      if (hasAll) {
        setState(() => _spriteMode = true);
        _timer = Timer.periodic(widget.frameDuration, (_) {
          if (!mounted) return;
          setState(() => _index = (_index + 1) % widget.framePaths.length);
        });
      }
    } catch (_) {
      // 매니페스트 로드 실패 → fallback static
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _spriteMode ? widget.framePaths[_index] : widget.fallbackPath;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.asset(
        path,
        fit: widget.fit,
        // 핵심 — Flutter 보간 끄고 픽셀 그대로 표시
        filterQuality: FilterQuality.none,
        gaplessPlayback: true, // 프레임 전환 시 깜빡임 방지
        errorBuilder: (_, __, ___) => Image.asset(
          widget.fallbackPath,
          fit: widget.fit,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}

class ReactionBurst extends StatefulWidget {
  final int trigger;
  final String symbol;
  final Color color;
  final Alignment origin;

  const ReactionBurst({
    super.key,
    required this.trigger,
    this.symbol = '♡',
    this.color = TouriColors.touriPink,
    this.origin = Alignment.center,
  });

  @override
  State<ReactionBurst> createState() => _ReactionBurstState();
}

class _ReactionBurstState extends State<ReactionBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant ReactionBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = Curves.easeOutCubic.transform(_controller.value);
          final opacity = (1 - value).clamp(0.0, 1.0);
          if (opacity <= 0) return const SizedBox.shrink();
          return Stack(
            children: List.generate(7, (i) {
              final angle = -math.pi / 2 + (i - 3) * 0.34;
              final distance = 18 + 42 * value + (i.isEven ? 5 : 0);
              final dx = math.cos(angle) * distance;
              final dy = math.sin(angle) * distance;
              return Align(
                alignment: widget.origin,
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.6 + value * 0.75,
                      child: Text(
                        i.isEven ? widget.symbol : '✦',
                        style: TextStyle(
                          color: i.isEven ? widget.color : const Color(0xFFFFC36B),
                          fontSize: i.isEven ? 18 : 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
