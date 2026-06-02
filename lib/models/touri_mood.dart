/// 토우리 무드 — 사용자가 선택하는 오늘의 상태.
/// 무드를 바꾸면 AI 멘트·다이어리 표지·자동 채워지는 다짐 종류가 바뀜.
enum TouriMood {
  manifest(
    id: 'manifest',
    label: '꿈 ✦',
    aiOptions: [
      '오늘 어떤 manifestation을 부르고 싶어?',
      '이번 주에 진짜 이루고 싶은 거 딱 하나만 적어보자',
      '걱정 하나를 다짐 하나로 바꿔볼까?',
      '꿈은 작아도 진짜야. 적어두자.',
    ],
    suggestedTodos: [
      '이번 주 manifestation 한 줄',
      '오늘 감사한 일 3가지',
      '미래 나에게 한 마디',
    ],
    imagePath: 'assets/character/scenes/scene_grid_9panels.png',
  ),
  secretary(
    id: 'secretary',
    label: '비서',
    aiOptions: [
      '오늘 일정 정리 도와줄까? 같이 해보자.',
      '회의 전 5분, 깊게 숨 한번 쉬자',
      'To-do 3개만 골라보자. 다 안 해도 돼.',
    ],
    suggestedTodos: [
      '오늘 가장 중요한 일 1가지',
      '회의/일정 정리',
      '내일 준비 5분',
    ],
    imagePath: 'assets/character/scenes/scene_secretary.png',
  ),
  exercise(
    id: 'exercise',
    label: '운동',
    aiOptions: [
      '5분만 스트레칭 해볼까? 작은 거부터!',
      '숨이 차도 괜찮아, 천천히',
      '어제보다 0.1mm 더 움직였어',
    ],
    suggestedTodos: [
      '스트레칭 5분',
      '계단 한 층 더 걷기',
      '물 2L 마시기',
    ],
    imagePath: 'assets/character/scenes/scene_exercise.png',
  ),
  diet(
    id: 'diet',
    label: '식단',
    aiOptions: [
      '천천히, 나답게, 건강하게!',
      '작은 변화가 큰 변화를 만들어요',
      '물 한 컵 마실 시간이야',
    ],
    suggestedTodos: [
      '오늘의 식사 기록',
      '물 2L 체크',
      '간식 한 번 줄이기',
    ],
    imagePath: 'assets/character/scenes/scene_diet.png',
  );

  const TouriMood({
    required this.id,
    required this.label,
    required this.aiOptions,
    required this.suggestedTodos,
    required this.imagePath,
  });

  final String id;
  final String label;
  final List<String> aiOptions;
  final List<String> suggestedTodos;
  final String imagePath;

  static TouriMood fromId(String id) =>
      TouriMood.values.firstWhere((m) => m.id == id, orElse: () => TouriMood.manifest);
}
