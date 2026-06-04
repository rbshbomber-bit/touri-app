import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/touri_mood.dart';

/// Claude Haiku로 토우리 코칭 받기.
/// 시스템 톤: 다정한 반말, 공감 → 작은 다짐 → 격려 순으로 3-4문장.
class CoachingService {
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

  static const _system = '''너는 토우리 토끼. 사용자의 가장 다정한 친구.
규칙:
- 다정한 반말로만 답해. 명령조·존댓말 절대 X.
- 의성어·이모지 가끔 자연스럽게 (예: "히힝", "✦", "♡").
- 항상 이 순서: [공감 1문장] → [작은 다짐 1개 제안] → [격려 1문장].
- 총 3-4문장. 짧고 따뜻하게.
- 금지: "~하셔야 합니다", "목표 미달", "분발하세요", "실패", "지각".
- 사용자가 잘 하고 있다고 먼저 인정해줘. 작은 변화도 칭찬.''';

  Future<String> coach({
    required String diary,
    required String manifestation,
    required TouriMood mood,
  }) async {
    final key = _apiKey;
    if (key == null) return _fallback(mood);

    final userMessage = '''오늘 무드: ${mood.label}
오늘 일기: ${diary.trim().isEmpty ? '(아직 안 적었어)' : diary.trim()}
부르고 있는 미래: ${manifestation.trim().isEmpty ? '(아직 안 적었어)' : manifestation.trim()}''';

    try {
      final body = jsonEncode({
        'model': _model,
        'max_tokens': 400,
        'system': _system,
        'messages': [
          {'role': 'user', 'content': userMessage},
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
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return _fallback(mood);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (json['content'] as List?)?.firstOrNull as Map?;
      final text = content?['text'] as String?;
      if (text == null || text.trim().isEmpty) return _fallback(mood);
      return text.trim();
    } catch (_) {
      return _fallback(mood);
    }
  }

  String _fallback(TouriMood mood) {
    switch (mood) {
      case TouriMood.secretary:
        return '오늘 하루 정리하느라 진짜 수고했어. 내일 가장 중요한 1가지만 메모해둘까? 그것만 해도 충분해 ♡';
      case TouriMood.exercise:
        return '몸 챙기는 마음이 예뻐. 오늘은 5분 스트레칭만 해보자. 토우리도 같이 할게 ✦';
      case TouriMood.diet:
        return '천천히 가고 있는 거 다 느껴져. 오늘은 물 한 컵 더 마셔보자. 작은 변화가 진짜야 ♡';
      case TouriMood.manifest:
        return '꿈 하나 적어준 것만으로도 이미 시작이야. 오늘은 그 꿈에 1mm만 가까워질 한 가지를 골라봐. 같이 부를게 ✦';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
