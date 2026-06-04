import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/news_item.dart';

/// Google News RSS 기반 국내 뉴스 피드.
class NewsService {
  NewsService._();

  static final _client = http.Client();
  static const _anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  static const _anthropicModel = 'claude-haiku-4-5-20251001';
  static const _anthropicVersion = '2023-06-01';

  static Future<List<NewsItem>> fetch(NewsCategory category) async {
    final url = Uri.https('news.google.com', '/rss/search', {
      'q': '${category.query} when:14d',
      'hl': 'ko',
      'gl': 'KR',
      'ceid': 'KR:ko',
    });

    final fetchUrl = kIsWeb
        ? Uri.https('api.allorigins.win', '/raw', {'url': url.toString()})
        : url;
    final res = await _client.get(fetchUrl).timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) {
      throw NewsException('뉴스를 불러오지 못했어 (${res.statusCode})');
    }

    final decoded = utf8.decode(res.bodyBytes);
    final doc = XmlDocument.parse(decoded);
    return doc.findAllElements('item').take(20).map((node) {
      final rawTitle = _text(node, 'title');
      final source = _text(node, 'source');
      return NewsItem(
        title: _cleanTitle(rawTitle, source),
        link: _text(node, 'link'),
        source: source.isEmpty ? 'Google News' : source,
        publishedAt: DateTime.tryParse(_text(node, 'pubDate')),
        summary: _stripHtml(_text(node, 'description')),
      );
    }).where((item) => item.title.isNotEmpty && item.link.isNotEmpty).toList();
  }

  static List<NewsItem> localFallback(NewsCategory category) {
    final now = DateTime.now();
    final rows = switch (category.id) {
      'spirituality' => [
          ('명상 앱과 마음챙김 루틴, MZ 여성 중심 확산', '아침 5분 호흡과 저녁 기록 루틴이 국내 웰니스 서비스의 핵심 흐름으로 떠오르고 있어.'),
          ('수면·불안 관리 시장에서 영성 콘텐츠 주목', '병원 밖 일상 관리 영역에서 명상, 호흡, 감정 기록형 콘텐츠 수요가 늘고 있어.'),
          ('보름달·계절 루틴을 활용한 셀프케어 인기', '계절감 있는 의식과 기록이 다이어리 앱 경험과 결합되는 흐름이 보여.'),
        ],
      'manifestation' => [
          ('확언과 시각화 루틴, 다이어리 서비스와 결합', '목표를 쓰고 이미지로 확인하는 습관형 자기계발 UX가 주목받고 있어.'),
          ('Manifestation 키워드, 20-30대 여성 커뮤니티서 확산', '끌어당김, 감사일기, 비전보드가 가벼운 일상 루틴으로 소비되고 있어.'),
          ('AI 이미지 기록, 목표 몰입을 돕는 도구로 부상', '텍스트 목표를 시각 자료로 바꾸는 기능이 동기부여 경험을 강화해.'),
        ],
      'love' => [
          ('연애 심리 콘텐츠, 관계 회복 루틴으로 인기', '대화법, 애착 유형, 데이트 회고 같은 콘텐츠가 꾸준히 소비되고 있어.'),
          ('소개팅보다 자기이해 먼저, 연애 트렌드 변화', '관계 전 자기 감정과 패턴을 기록하려는 니즈가 커지고 있어.'),
          ('커플 다이어리와 감정 기록 서비스 재주목', '기념일 중심에서 매일의 마음을 공유하는 방식으로 흐름이 바뀌고 있어.'),
        ],
      'economy' => [
          ('생활경제 뉴스, 금리와 소비 흐름에 관심 집중', '물가, 대출, 저축 관련 실용 정보가 개인 루틴 관리와 연결되고 있어.'),
          ('2030 재테크, 소액 저축과 자동화 관리 선호', '복잡한 투자보다 지출 기록, 목표 저축, 심리적 안정이 중요해지는 흐름이야.'),
          ('부동산·금리 이슈, 일상 소비 판단에 영향', '큰 경제 뉴스가 월별 예산과 소비 습관으로 바로 이어지고 있어.'),
        ],
      'business' => [
          ('AI 생산성 도구, 1인 창업자 필수 인프라로 확산', '기획, 디자인, 문서화까지 혼자 처리하는 작은 팀의 속도가 빨라지고 있어.'),
          ('캐릭터 IP와 앱 서비스 결합 사례 증가', '귀여운 캐릭터가 기능보다 오래 머무는 이유를 만드는 브랜드 자산이 되고 있어.'),
          ('구독형 앱, 감정 케어와 루틴 관리로 차별화', '단순 기능보다 매일 쓰는 이유를 만드는 경험 설계가 중요해지고 있어.'),
        ],
      'csat' => [
          ('수능 학습 루틴, 짧은 기록과 회고 중심으로 변화', '공부 시간보다 컨디션과 집중 패턴을 같이 관리하는 수요가 늘고 있어.'),
          ('입시생 멘탈케어 콘텐츠, 학습 앱 부가 기능으로 확대', '불안 관리, 짧은 명상, 응원 메시지가 학습 지속성에 도움을 주고 있어.'),
          ('교육 뉴스 소비, 모바일 요약형 콘텐츠 선호', '긴 기사보다 핵심 3줄 요약과 원문 링크를 함께 보는 방식이 편해지고 있어.'),
        ],
      _ => [
          ('국내 라이프 트렌드, 루틴 관리가 핵심 키워드', '일상 기록과 자기 돌봄을 연결하는 서비스가 꾸준히 주목받고 있어.'),
          ('AI와 캐릭터 UX 결합 서비스 증가', '친근한 캐릭터가 복잡한 기능을 부드럽게 안내하는 방식이 늘고 있어.'),
          ('모바일 콘텐츠, 요약과 실행 버튼 중심으로 변화', '읽기만 하는 화면보다 바로 기록하고 저장하는 흐름이 중요해지고 있어.'),
        ],
    };
    return rows
        .map(
          (row) => NewsItem(
            title: row.$1,
            link: Uri.https('news.google.com', '/search', {
              'q': '${category.query} ${row.$1}',
              'hl': 'ko',
              'gl': 'KR',
              'ceid': 'KR:ko',
            }).toString(),
            source: 'Touri News',
            publishedAt: now,
            summary: row.$2,
            isFallback: true,
          ),
        )
        .toList();
  }

  static Future<List<String>> summarize(NewsItem item, NewsCategory category) async {
    final key = _anthropicKey;
    if (key == null) return _localSummary(item, category);

    try {
      final body = jsonEncode({
        'model': _anthropicModel,
        'max_tokens': 220,
        'system': '너는 한국어 뉴스 큐레이터야. 기사 제목과 RSS 설명을 바탕으로 앱 안에서 읽을 3줄 요약만 작성해. 각 줄은 35자 이내, 과장 없이 담백하게.',
        'messages': [
          {
            'role': 'user',
            'content': '카테고리: ${category.label}\n제목: ${item.title}\n출처: ${item.source}\n설명: ${item.summary}',
          },
        ],
      });
      final res = await _client
          .post(
            Uri.parse(_anthropicEndpoint),
            headers: {
              'x-api-key': key,
              'anthropic-version': _anthropicVersion,
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 16));
      if (res.statusCode != 200) return _localSummary(item, category);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (json['content'] as List?)?.firstOrNull as Map?;
      final text = (content?['text'] as String?)?.trim();
      if (text == null || text.isEmpty) return _localSummary(item, category);
      final lines = text
          .split(RegExp(r'\n+'))
          .map((line) => line.replaceFirst(RegExp(r'^[-•\d. ]+'), '').trim())
          .where((line) => line.isNotEmpty)
          .take(3)
          .toList();
      return lines.length >= 3 ? lines : _localSummary(item, category);
    } catch (_) {
      // Web은 Anthropic CORS에 막힐 수 있음. 모바일/데스크톱에서는 실제 Haiku 요약 사용.
      return _localSummary(item, category);
    }
  }

  static String? get _anthropicKey {
    try {
      final key = dotenv.env['ANTHROPIC_API_KEY'];
      if (key == null || key.isEmpty || key.startsWith('sk-ant-xxxxx')) return null;
      return key;
    } catch (_) {
      return null;
    }
  }

  static List<String> _localSummary(NewsItem item, NewsCategory category) {
    final desc = item.summary.isEmpty ? item.title : item.summary;
    final compact = desc.replaceAll(RegExp(r'\s+'), ' ').trim();
    final first = compact.length > 46 ? '${compact.substring(0, 46)}...' : compact;
    return [
      '${category.label} 흐름에서 주목받는 기사야.',
      first.isEmpty ? item.title : first,
      '원문 보기로 자세한 맥락을 확인할 수 있어.',
    ];
  }

  static String _text(XmlElement node, String tag) {
    final found = node.findElements(tag);
    if (found.isEmpty) return '';
    return found.first.innerText.trim();
  }

  static String _cleanTitle(String title, String source) {
    var cleaned = _decodeEntities(title).trim();
    if (source.isNotEmpty && cleaned.endsWith(' - $source')) {
      cleaned = cleaned.substring(0, cleaned.length - source.length - 3).trim();
    }
    return cleaned;
  }

  static String _stripHtml(String value) {
    final noTags = value.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return _decodeEntities(noTags).replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _decodeEntities(String value) {
    return value
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class NewsException implements Exception {
  final String message;
  const NewsException(this.message);

  @override
  String toString() => message;
}
