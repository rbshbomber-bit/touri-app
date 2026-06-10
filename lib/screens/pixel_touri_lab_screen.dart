import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import '../models/generation_status.dart';
import '../services/generation_orchestrator.dart';
import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';
import '../widgets/touri_motion.dart';

/// 도트 토우리 LoRA 테스트 화면.
/// scene 텍스트 입력 → fal.ai에 touri-pixel LoRA로 도트 토우리 생성.
/// 학습 끝난 LoRA URL이 touri_pixel_lora_url.txt에 저장되어 있어야 함.
class PixelTouriLabScreen extends StatefulWidget {
  const PixelTouriLabScreen({super.key});

  @override
  State<PixelTouriLabScreen> createState() => _PixelTouriLabScreenState();
}

class _PixelTouriLabScreenState extends State<PixelTouriLabScreen> {
  final _ctrl = TextEditingController(
    text: 'exercising at gym, side view',
  );
  GenerationStatus _status = GenerationStatus.idle;
  String? _resultPath;
  String? _error;

  static const _suggestions = [
    'sleeping on a cloud',
    'eating strawberry shortcake',
    'reading a book in the rain',
    'jogging in pink shorts',
    'playing piano',
    'holding a coffee cup',
    'meditating with crystals',
    'shopping with a tiny pink bag',
    'celebrating birthday with cake',
    'splashing in a puddle',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final scene = _ctrl.text.trim();
    if (scene.isEmpty) return;
    setState(() {
      _status = GenerationStatus.queued;
      _error = null;
      _resultPath = null;
    });

    final dateKey = 'pixel_${DateTime.now().millisecondsSinceEpoch}';
    await GenerationOrchestrator.instance.pixelGenerate(
      scene: scene,
      dateKey: dateKey,
      onProgress: (s, {requestId}) {
        if (!mounted) return;
        setState(() => _status = s);
      },
      onReady: (path) {
        if (!mounted) return;
        setState(() {
          _resultPath = path;
          _status = GenerationStatus.ready;
        });
      },
      onFailed: (e) {
        if (!mounted) return;
        setState(() {
          _error = e;
          _status = GenerationStatus.failed;
        });
      },
    );
  }

  String get _statusLabel {
    switch (_status) {
      case GenerationStatus.idle:
        return '🐰 한 줄로 토우리가 뭐 하는지 적어줘';
      case GenerationStatus.extracting:
        return '✨ 장면 추출 중...';
      case GenerationStatus.queued:
        return '📤 fal.ai 큐 대기 중...';
      case GenerationStatus.generating:
        return '🎨 도트 토우리 그리는 중... (15-30초)';
      case GenerationStatus.downloading:
        return '💾 다운로드 중...';
      case GenerationStatus.ready:
        return '✅ 완성!';
      case GenerationStatus.failed:
        return '❌ 실패';
    }
  }

  Widget _buildResultImage() {
    if (_resultPath == null) return const SizedBox.shrink();
    if (kIsWeb || _resultPath!.startsWith('http')) {
      return Image.network(
        _resultPath!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    }
    return Image.file(
      File(_resultPath!),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _status.isBusy;
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(
        title: '도트 토우리 랩 🎨',
        subtitle: 'touri-pixel LoRA · 무한 생성',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // 상태/안내
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TouriColors.touriPink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _statusLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: TouriColors.cocoaDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 입력
            TextField(
              controller: _ctrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '예: exercising at gym, side view',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: TouriColors.touriPink.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 빠른 추천
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions
                  .map(
                    (s) => TapBounce(
                      borderRadius: BorderRadius.circular(20),
                      onTap: busy
                          ? null
                          : () => setState(() => _ctrl.text = s),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TouriColors.touriPink.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TouriColors.cocoaDark,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // 생성 버튼
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: busy ? null : _generate,
                icon: const Text('🎨', style: TextStyle(fontSize: 20)),
                label: Text(
                  busy ? '생성 중...' : '도트 토우리 생성',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TouriColors.touriPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 결과 이미지
            if (_resultPath != null)
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFFFF6E8),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildResultImage(),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
