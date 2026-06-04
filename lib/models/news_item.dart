/// 뉴스/콘텐츠 코너에 표시할 기사 한 건.
class NewsItem {
  final String title;
  final String link;
  final String source;
  final DateTime? publishedAt;
  final String summary;
  final bool isFallback;

  const NewsItem({
    required this.title,
    required this.link,
    required this.source,
    this.publishedAt,
    this.summary = '',
    this.isFallback = false,
  });
}

/// 토우리 뉴스 코너 카테고리.
class NewsCategory {
  final String id;
  final String label;
  final String description;
  final String query;

  const NewsCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.query,
  });

  static const all = [
    NewsCategory(
      id: 'spirituality',
      label: '영성',
      description: '명상, 마음챙김, 내면 돌봄',
      query: '영성 OR 명상 OR 마음챙김',
    ),
    NewsCategory(
      id: 'manifestation',
      label: 'Manifest',
      description: '확언, 자기계발, 끌어당김',
      query: '확언 OR 자기계발 OR 끌어당김 법칙',
    ),
    NewsCategory(
      id: 'love',
      label: '연애',
      description: '관계, 심리, 데이트 트렌드',
      query: '연애 OR 관계 심리 OR 데이트',
    ),
    NewsCategory(
      id: 'economy',
      label: '경제',
      description: '금리, 증시, 부동산, 생활경제',
      query: '경제 OR 금리 OR 증시 OR 부동산',
    ),
    NewsCategory(
      id: 'business',
      label: '비즈니스',
      description: '창업, 스타트업, 커리어',
      query: '비즈니스 OR 스타트업 OR 창업',
    ),
    NewsCategory(
      id: 'csat',
      label: '수능',
      description: '입시, 교육, 수능 이슈',
      query: '수능 OR 입시 OR 교육',
    ),
  ];
}
