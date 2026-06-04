import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// FAL queue REST 클라이언트.
/// - submit() → request_id
/// - pollStatus() → in_queue / in_progress / completed / failed
/// - fetchResult() → image url
/// - download() → 로컬 PNG 경로
class FalGenerationService {
  static const _model = 'fal-ai/flux-lora';
  static const _trigger = 'touri-bunny';
  static const _styleSuffix =
      'kawaii watercolor illustration, soft pastel pink color palette, cute cozy style';

  String? _cachedLoraUrl;

  String? get _apiKey {
    try {
      final k = dotenv.env['FAL_KEY'];
      if (k == null || k.isEmpty) return null;
      return k;
    } catch (_) {
      return null;
    }
  }

  bool get hasKey => _apiKey != null;

  Future<String?> _getLoraUrl() async {
    if (_cachedLoraUrl != null) return _cachedLoraUrl;
    try {
      final raw = await rootBundle.loadString('touri_lora_url.txt');
      final url = raw.trim();
      if (url.isEmpty) return null;
      _cachedLoraUrl = url;
      return url;
    } catch (_) {
      return null;
    }
  }

  String buildPrompt(String scene) {
    return '$_trigger, ${scene.trim()}, $_styleSuffix';
  }

  /// FAL 큐에 제출. 성공 시 request_id 반환.
  Future<String> submit(String scene) async {
    final key = _apiKey;
    if (key == null) {
      throw FalException('FAL_KEY가 없어. .env에 FAL_KEY 추가해줘.');
    }
    final loraUrl = await _getLoraUrl();
    if (loraUrl == null) {
      throw FalException('LoRA URL이 없어. scripts/train_touri_lora.py 먼저 돌려야 해.');
    }

    final res = await http.post(
      Uri.parse('https://queue.fal.run/$_model'),
      headers: {
        'Authorization': 'Key $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': buildPrompt(scene),
        'loras': [
          {'path': loraUrl, 'scale': 1.0},
        ],
        'num_inference_steps': 28,
        'guidance_scale': 3.5,
        'num_images': 1,
        'image_size': 'square_hd',
        'enable_safety_checker': true,
      }),
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw FalException('FAL submit 실패 (${res.statusCode}): ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final id = json['request_id'] as String?;
    if (id == null) {
      throw FalException('FAL 응답에 request_id 없음: ${res.body}');
    }
    return id;
  }

  /// 상태 폴링. "IN_QUEUE" / "IN_PROGRESS" / "COMPLETED" / "FAILED"
  Future<String> pollStatus(String requestId) async {
    final key = _apiKey;
    if (key == null) {
      throw FalException('FAL_KEY가 없어. .env를 확인해줘.');
    }
    final res = await http.get(
      Uri.parse('https://queue.fal.run/$_model/requests/$requestId/status'),
      headers: {'Authorization': 'Key $key'},
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw FalException('FAL status 실패 (${res.statusCode}): ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return (json['status'] as String?) ?? 'FAILED';
  }

  /// 완료된 요청의 결과 이미지 URL.
  Future<String> fetchResultUrl(String requestId) async {
    final key = _apiKey!;
    final res = await http.get(
      Uri.parse('https://queue.fal.run/$_model/requests/$requestId'),
      headers: {'Authorization': 'Key $key'},
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw FalException('FAL result 실패 (${res.statusCode}): ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final images = json['images'] as List?;
    final first = images?.firstOrNull as Map?;
    final url = first?['url'] as String?;
    if (url == null) throw FalException('이미지 URL이 없어.');
    return url;
  }

  /// 결과 PNG 다운로드 → 로컬 파일 경로 반환.
  /// Web에서는 path_provider 안 됨 → URL 그대로 반환.
  Future<String> download(String url, String dateKey) async {
    if (kIsWebSafe) {
      // Web 환경에선 URL 그대로 보여줌 (Image.network).
      return url;
    }
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));
    if (res.statusCode != 200) {
      throw FalException('다운로드 실패 (${res.statusCode})');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/touri_generated_$dateKey.png');
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }
}

class FalException implements Exception {
  final String message;
  FalException(this.message);
  @override
  String toString() => message;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// kIsWeb은 flutter:foundation이지만 import 줄이려고 직접 체크.
const bool kIsWebSafe = bool.fromEnvironment('dart.library.js_util');
