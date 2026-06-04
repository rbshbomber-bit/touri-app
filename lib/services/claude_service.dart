import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/touri_mood.dart';

/// Claude Haiku로 일기+무드를 영문 scene 키워드로 추출.
/// 키 없거나 실패 시 무드별 기본 fallback 반환.
class ClaudeService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';
  static const _version = '2023-06-01';

  String? get _apiKey {
    try {
      final k = dotenv.env['ANTHROPIC_API_KEY'];
      if (k == null || k.isEmpty || k.startsWith('sk-ant-xxxxx')) return null;
      return k;
    } catch (_) {
      return null;
    }
  }

  bool get hasKey => _apiKey != null;

  static const _system =
      'You are a visual scene extractor for an AI image prompt. '
      'The user gives a short Korean diary entry and their mood. '
      'Output ONLY 3-5 short English scene keywords (comma-separated, lowercase), '
      'capturing what the person experienced visually. '
      'No explanation, no quotes, no period. '
      'Example: "cafe afternoon light, strawberry cake on plate, cozy comfort moment".';

  Future<String> extractScene(String diary, TouriMood mood) async {
    final key = _apiKey;
    if (key == null) return _fallback(mood);

    try {
      final body = jsonEncode({
        'model': _model,
        'max_tokens': 120,
        'system': _system,
        'messages': [
          {
            'role': 'user',
            'content':
                '무드: ${mood.label}\n일기: ${diary.trim().isEmpty ? "(빈 일기)" : diary}',
          },
        ],
      });

      final res = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'x-api-key': key,
              'anthropic-version': _version,
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        return _fallback(mood);
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (json['content'] as List?)?.firstOrNull as Map?;
      final text = content?['text'] as String?;
      if (text == null || text.trim().isEmpty) return _fallback(mood);
      return text.trim().toLowerCase();
    } catch (_) {
      return _fallback(mood);
    }
  }

  static const _affirmationSystem =
      '한국어로 따뜻한 affirmation 한 문장만 생성. '
      '명령조 X, 다정한 반말. 15자 이내. '
      '예: "나는 이미 충분히 사랑받고 있어 ♡" '
      '한 문장만 출력, 다른 설명·따옴표 없이.';

  static const _affirmationFallback = <String>[
    '나는 이미 충분히 사랑받고 있어 ♡',
    '오늘의 나도 잘하고 있어 ✦',
    '천천히 가도 괜찮아',
    '내가 부르는 미래가 오고 있어',
    '작은 변화도 진짜 변화야',
    '나는 나에게 다정한 사람이야',
    '오늘도 한 걸음 더 가까워졌어',
    '나는 이미 좋은 흐름 안에 있어',
  ];

  Future<String> generateAffirmation() async {
    final key = _apiKey;
    if (key == null) return _randomAffirmation();
    try {
      final body = jsonEncode({
        'model': _model,
        'max_tokens': 80,
        'system': _affirmationSystem,
        'messages': [
          {'role': 'user', 'content': '오늘 나에게 줄 한 문장 ♡'},
        ],
      });
      final res = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'x-api-key': key,
              'anthropic-version': _version,
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return _randomAffirmation();
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (json['content'] as List?)?.firstOrNull as Map?;
      final text = (content?['text'] as String?)?.trim();
      if (text == null || text.isEmpty) return _randomAffirmation();
      // 따옴표 들어왔으면 제거.
      return text.replaceAll(RegExp(r'^["“]|["”]$'), '').trim();
    } catch (_) {
      return _randomAffirmation();
    }
  }

  String _randomAffirmation() {
    final i = math.Random().nextInt(_affirmationFallback.length);
    return _affirmationFallback[i];
  }

  String _fallback(TouriMood mood) {
    switch (mood) {
      case TouriMood.secretary:
        return 'organized desk with planner, soft afternoon light, focused calm mood';
      case TouriMood.exercise:
        return 'morning stretch by window, water bottle, fresh energetic mood';
      case TouriMood.diet:
        return 'fresh salad bowl on wooden table, healthy meal vibe';
      case TouriMood.manifest:
        return 'cozy evening with journal and warm lamp, dreaming a wish';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
