/// 다이어리에 붙일 수 있는 스티커 자산 카탈로그.
/// 캐릭터 단독 컷 12장 + LoRA 생성 8장 = 총 20장.
class StickerAsset {
  final String path;
  final String label;
  const StickerAsset(this.path, this.label);
}

const _scene = 'assets/character/scenes';
const _gen = 'assets/character/generated';

const stickerCatalog = <StickerAsset>[
  // ─── 캐릭터 단독 컷 (12) ───
  StickerAsset('$_scene/scene_secretary.png', '비서'),
  StickerAsset('$_scene/scene_exercise.png', '운동'),
  StickerAsset('$_scene/scene_diet.png', '식단'),
  StickerAsset('$_scene/scene_study.png', '공부'),
  StickerAsset('$_scene/scene_dessert.png', '디저트'),
  StickerAsset('$_scene/scene_princess.png', '공주'),
  StickerAsset('$_scene/scene_travel.png', '여행'),
  StickerAsset('$_scene/scene_rain.png', '비'),
  StickerAsset('$_scene/scene_sleep.png', '잠'),
  StickerAsset('$_scene/scene_picnic.png', '피크닉'),
  StickerAsset('$_scene/scene_christmas.png', '크리스마스'),
  StickerAsset('$_scene/scene_space.png', '우주'),

  // ─── LoRA 생성 컷 (8) — 매니페스테이션 ───
  StickerAsset('$_gen/touri_biz_ceo_20260603_173344.png', 'CEO'),
  StickerAsset('$_gen/touri_wealth_money_20260603_173400.png', '부자'),
  StickerAsset('$_gen/touri_love_20260603_173407.png', '사랑'),
  StickerAsset('$_gen/touri_morning_20260603_173414.png', '모닝'),
  StickerAsset('$_gen/touri_meditation_20260603_173427.png', '명상'),
  StickerAsset('$_gen/touri_celebration_20260603_173434.png', '축하'),
  StickerAsset('$_gen/touri_self_love_20260603_173440.png', '자존감'),
  StickerAsset('$_gen/touri_focus_work_20260603_173448.png', '집중'),
];
