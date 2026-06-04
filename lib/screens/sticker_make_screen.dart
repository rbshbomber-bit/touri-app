import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/collection_service.dart';
import '../theme/touri_colors.dart';
import '../widgets/touri_app_bar.dart';

class StickerMakeScreen extends StatefulWidget {
  const StickerMakeScreen({super.key});

  @override
  State<StickerMakeScreen> createState() => _StickerMakeScreenState();
}

class _StickerMakeScreenState extends State<StickerMakeScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _pickedBytes;
  String? _resultUrl;
  bool _busy = false;
  String? _error;

  Future<void> _pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1400,
      imageQuality: 92,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _resultUrl = null;
      _error = null;
    });
  }

  Future<void> _convert() async {
    final bytes = _pickedBytes;
    if (bytes == null) {
      _toast('먼저 사진을 골라줘 ♡');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final url = await _StickerFalClient().convert(bytes);
      await CollectionService.instance.add(
        sourcePath: url,
        prompt: 'custom photo to touri-bunny style sticker',
        sourceDateKey: 'sticker_make',
        moodId: 'custom',
      );
      if (!mounted) return;
      setState(() => _resultUrl = url);
      _toast('커스텀 토우리가 수집함에 저장됐어 ✦');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      _toast('변환에 실패했어. 키와 네트워크를 확인해줘.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: TouriColors.cocoaDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TouriColors.warmWhite,
      appBar: const TouriAppBar(title: '스티커 제작', subtitle: '내 사진을 토우리 스타일로'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _PreviewBox(
              title: '원본 사진',
              child: _pickedBytes == null
                  ? const _EmptyPick()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_pickedBytes!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _pick,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('사진 선택'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TouriColors.cocoaDark,
                      side: const BorderSide(color: TouriColors.cloudPink),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _convert,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(_busy ? '변환 중' : '토우리로 변환'),
                    style: FilledButton.styleFrom(
                      backgroundColor: TouriColors.touriPink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _PreviewBox(
              title: '결과 스티커',
              child: _resultUrl == null
                  ? const _ResultEmpty()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(_resultUrl!, fit: BoxFit.cover),
                    ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: TouriColors.dim, fontSize: 12),
              ),
            ],
            const SizedBox(height: 18),
            const _PremiumNote(),
          ],
        ),
      ),
    );
  }
}

class _StickerFalClient {
  static const _model = 'fal-ai/flux-lora/image-to-image';

  String? get _apiKey {
    try {
      final key = dotenv.env['FAL_KEY'];
      if (key == null || key.isEmpty) return null;
      return key;
    } catch (_) {
      return null;
    }
  }

  Future<String> convert(Uint8List bytes) async {
    final key = _apiKey;
    if (key == null) throw Exception('FAL_KEY가 없어.');
    final loraUrl = (await rootBundle.loadString('touri_lora_url.txt')).trim();
    final imageData = 'data:image/png;base64,${base64Encode(bytes)}';
    final requestId = await _submit(key, loraUrl, imageData);
    for (var i = 0; i < 24; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final status = await _status(key, requestId);
      if (status == 'COMPLETED') return _result(key, requestId);
      if (status == 'FAILED') throw Exception('fal.ai 변환 실패');
    }
    throw Exception('fal.ai 변환 시간이 초과됐어.');
  }

  Future<String> _submit(String key, String loraUrl, String imageData) async {
    final res = await http
        .post(
          Uri.parse('https://queue.fal.run/$_model'),
          headers: {
            'Authorization': 'Key $key',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'image_url': imageData,
            'prompt': 'touri-bunny style, kawaii watercolor sticker, soft pastel pink, clean cute character, no text',
            'loras': [
              {'path': loraUrl, 'scale': 0.85},
            ],
            'strength': 0.6,
            'num_inference_steps': 30,
            'guidance_scale': 4.0,
            'num_images': 1,
            'image_size': 'square_hd',
            'enable_safety_checker': true,
          }),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('fal.ai submit 실패 (${res.statusCode})');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final id = json['request_id'] as String?;
    if (id == null) throw Exception('request_id가 없어.');
    return id;
  }

  Future<String> _status(String key, String id) async {
    final res = await http
        .get(
          Uri.parse('https://queue.fal.run/$_model/requests/$id/status'),
          headers: {'Authorization': 'Key $key'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('fal.ai status 실패 (${res.statusCode})');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return (json['status'] as String?) ?? 'FAILED';
  }

  Future<String> _result(String key, String id) async {
    final res = await http
        .get(
          Uri.parse('https://queue.fal.run/$_model/requests/$id'),
          headers: {'Authorization': 'Key $key'},
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('fal.ai result 실패 (${res.statusCode})');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final images = json['images'] as List?;
    final first = images?.firstOrNull as Map?;
    final url = first?['url'] as String?;
    if (url == null) throw Exception('결과 이미지 URL이 없어.');
    return url;
  }
}

class _PreviewBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreviewBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TouriColors.cloudPink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: TouriColors.cocoaDark,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: TouriColors.mistPink,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPick extends StatelessWidget {
  const _EmptyPick();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add_photo_alternate_rounded, color: TouriColors.touriPink, size: 42),
        SizedBox(height: 8),
        Text('사진을 골라줘', style: TextStyle(color: TouriColors.cocoa, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ResultEmpty extends StatelessWidget {
  const _ResultEmpty();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/character/sticker_base/sparkle.png',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}

class _PremiumNote extends StatelessWidget {
  const _PremiumNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TouriColors.cloudPink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '커스텀 토우리는 프리미엄 기능으로 열어둘 예정이야. 지금은 데모 변환으로 수집함 저장까지 확인할 수 있어.',
        style: TextStyle(
          color: TouriColors.cocoaDark,
          height: 1.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
