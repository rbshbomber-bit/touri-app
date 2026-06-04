# 🐰 토우리 앱 — 이미지 프롬프트 목록

> Codex/fal.ai에서 생성할 모든 앱 자산 이미지 프롬프트.
> **참고 이미지**: 토우리 캐릭터 시트 + 기존 깨끗한 이미지(`touri_morning`, `touri_self_love`, `touri_meditation`, `touri_celebration`) 업로드해서 일관성 유지.

---

## ⚙️ 공통 규칙 (모든 프롬프트에 자동 적용)

**Trigger word (필수, 매 프롬프트 맨 앞)**
```
touri-bunny
```

**Positive style suffix (매 프롬프트 끝에 붙임)**
```
kawaii watercolor illustration, soft pink and lilac pastel palette,
puffy fluffy bunny, dashed outline body, big shiny black eyes, blush cheeks,
heart accents, sparkles, clean cream background (#FFF8F5),
centered composition, gentle lighting, picture book style
```

**Negative prompt (필수, 텍스트 박힘 방지)**
```
text, letters, words, korean characters, hangul, english characters,
logos, signs, captions, watermark, signature, labels, typography,
ui elements, buttons, app icons, dark colors, photorealistic, 3d render,
multiple characters, group, blurry, low quality
```

**기술 파라미터**
- model: `fal-ai/flux-lora`
- LoRA: `touri_lora_url.txt` 내용 (scale 1.0)
- size: `square_hd` (1024×1024)
- inference_steps: 28
- guidance_scale: 3.5
- num_images: 1 (마음에 안 들면 재생성)

---

## 📁 폴더 구조

```
assets/character/
├── menu_icons/        ← 카테고리 1 (메뉴 9칸)
├── news_categories/   ← 카테고리 2 (뉴스 카테고리 12)
├── empty_states/      ← 카테고리 3 (빈 상태 6)
└── spirituality/      ← 카테고리 4 (영성 카드 4)
```

---

# 🍓 카테고리 1 — 메뉴 9칸 아이콘

> 사용처: `lib/screens/menu_screen.dart`
> 톤: **단순 배경 + 캐릭터 중앙 명확** (카드 UI 안에 들어감)

### 1-1. 다이어리 (`menu_icons/diary.png`)
```
touri-bunny sitting at a tiny pink desk writing in a blank open notebook
with a strawberry pen, blank pages (no text), small heart sticker on cover,
warm afternoon light
```

### 1-2. 그려줘 (`menu_icons/generate.png`)
```
touri-bunny holding a magic paintbrush, soft purple sparkles swirling out of the tip,
small blank canvas floating nearby, dreamy lavender glow, magical moment
```

### 1-3. 스티커 제작 (`menu_icons/sticker_make.png`)
```
touri-bunny surrounded by floating cute blank pastel stickers in various shapes
(hearts, stars, clouds, flowers), tiny pink scissors and washi tape roll beside,
playful crafty vibe
```

### 1-4. 수집함 (`menu_icons/collection.png`)
```
touri-bunny peeking joyfully into an open pastel pink treasure box,
small sparkles and tiny hearts floating out, soft magical glow,
treasure box has heart latch (no text)
```

### 1-5. 시즌팩 (`menu_icons/season_pack.png`)
```
touri-bunny standing in the center surrounded by four floating seasonal elements:
cherry blossom branch (spring), sunflower (summer), maple leaf (autumn),
red rose (valentine), each in its own soft glow bubble
```

### 1-6. AI 코칭 (`menu_icons/coaching.png`)
```
touri-bunny wearing a tiny pink coach cap, raising one paw cheerfully,
a small heart-shaped whistle on a ribbon around the neck,
encouraging pose, motivational energy, sparkle aura
```

### 1-7. 영성 (`menu_icons/spirituality.png`)
```
touri-bunny sitting cross-legged meditating with closed peaceful eyes,
small crescent moon and three soft stars floating above the head,
purple and lilac aura, serene calm vibe
```

### 1-8. 뉴스 (`menu_icons/news.png`)
```
touri-bunny holding a folded pastel pink newspaper with blank pages
(absolutely no text or letters), morning sun rays softly behind,
small coffee cup nearby, cozy reading mood
```

### 1-9. 설정·로그인 (`menu_icons/settings.png`)
```
touri-bunny wearing round pastel glasses, holding a small pink key,
a soft floating gear icon (simple flat shape, no detail) beside,
cozy organized vibe
```

---

# 📰 카테고리 2 — 뉴스 카테고리별 (12장)

> 사용처: `lib/screens/home_feed_screen.dart` 뉴스 카드 카테고리 점/아이콘 + `news_screen.dart` 카테고리 헤더
> 톤: **카테고리 정체성 명확 + 텍스트 절대 없음**

### 2-1. 라이프 (`news_categories/life.png`)
```
touri-bunny sipping from a heart-shaped mug, surrounded by tiny daily items
(blank planner, lipstick, candle, flower), cozy morning routine vibe
```

### 2-2. 문화 (`news_categories/culture.png`)
```
touri-bunny holding a blank closed book to chest, dreamy eyes,
small theater curtain and tiny ticket floating beside (no text on ticket),
artistic mood
```

### 2-3. IT (`news_categories/it.png`)
```
touri-bunny tapping a small pink tablet with completely blank screen
(no UI, no text, no icons on screen), tiny pixel hearts floating up,
modern minimal pastel tech vibe
```

### 2-4. 정치 (`news_categories/politics.png`)
```
touri-bunny standing behind a tiny pink podium, raising one paw confidently,
soft pastel star burst behind, no text on podium, gentle leadership vibe
```

### 2-5. 경제 (`news_categories/economy.png`)
```
touri-bunny holding a heart-shaped coin, a tiny pink piggy bank beside,
floating gold coins (no markings, no numbers, no text), prosperity sparkles
```

### 2-6. 사회 (`news_categories/society.png`)
```
touri-bunny holding paws with a small bunny friend, both smiling warmly,
soft heart bubble between them, community warmth, only two bunnies
```

### 2-7. 스포츠 (`news_categories/sports.png`)
```
touri-bunny in a pink headband doing a small stretch, tiny dumbbell and
heart-shaped towel nearby (no text on towel), energetic cheerful pose
```

### 2-8. 영성 (`news_categories/spirituality.png`)
```
touri-bunny holding a small clear crystal that emits soft purple light,
crescent moon overhead, three floating stars, mystical lilac aura
```

### 2-9. 매니페스트 (`news_categories/manifest.png`)
```
touri-bunny reaching up toward a glowing pink star, eyes wide with wonder,
trail of small sparkles behind the paw, magical wish-making moment
```

### 2-10. 연애 (`news_categories/love.png`)
```
touri-bunny blushing while holding a big floating heart bubble,
small rose petals drifting around, romantic soft pink glow
```

### 2-11. 비즈니스 (`news_categories/business.png`)
```
touri-bunny wearing a tiny pink bow tie, carrying a small blank briefcase
(no text or logo), soft confident smile, professional yet cute vibe
```

### 2-12. 수능/교육 (`news_categories/education.png`)
```
touri-bunny wearing a tiny graduation cap with pink tassel,
holding a small blank rolled diploma (no text), proud smile,
star sparkles overhead
```

---

# 🌙 카테고리 3 — 영성 카드 추가 (4장)

> 사용처: `lib/screens/spirituality_screen.dart` Card 3~5 + 영성 진행률 완료 상태

### 3-1. 5분 호흡 명상 (`spirituality/breathing.png`)
```
touri-bunny sitting cross-legged with closed peaceful eyes,
soft pastel breathing bubble expanding from chest, gentle blue and pink aura,
calm meditation pose
```

### 3-2. 달의 위상 (`spirituality/moon_phase.png`)
```
touri-bunny gazing up at a large crescent moon, small stars scattered,
sitting on a soft cloud, dreamy night sky in pastel purple and pink,
serene wonder
```

### 3-3. 이번 주 manifestation 모음 (`spirituality/manifest_week.png`)
```
touri-bunny holding seven small floating star bubbles (each empty, no text),
arranged in a soft arc above the head, magical collection moment
```

### 3-4. 영성 완료 (`spirituality/done.png`)
```
touri-bunny floating peacefully with eyes closed gentle smile,
soft halo of seven small stars in a circle, golden warm light,
sense of completion and self-love
```

---

# 🥺 카테고리 4 — 빈 상태 일러스트 (6장)

> 사용처: 각 화면 데이터 없을 때 표시

### 4-1. 다이어리 빈 상태 (`empty_states/empty_diary.png`)
```
touri-bunny holding a tiny pen, looking at a completely blank open notebook
(no lines, no text), curious tilted head, gentle invitation vibe
```

### 4-2. 수집함 빈 상태 (`empty_states/empty_collection.png`)
```
touri-bunny peeking into an empty pastel pink treasure box,
disappointed but hopeful expression, small sparkle hovering inside the empty box
```

### 4-3. 뉴스 빈 상태 (`empty_states/empty_news.png`)
```
touri-bunny napping curled up on a folded blank newspaper (no text),
small Zz floating above, peaceful resting moment, soft afternoon light
```

### 4-4. 스티커 없음 (`empty_states/empty_stickers.png`)
```
touri-bunny holding an empty sticker sheet (completely blank, no markings),
looking up with hopeful eyes, small sparkle ready to fill the sheet
```

### 4-5. 한도 초과 (PremiumSheet) (`empty_states/quota_exceeded.png`)
```
touri-bunny stretching paws up trying to reach a glowing pink star
just out of reach, hopeful expression, golden sparkle aura,
suggesting upgrade moment
```

### 4-6. 네트워크 오류 (`empty_states/error.png`)
```
touri-bunny holding a small unplugged pink cable, slightly confused face,
tiny "?" bubble (just shape, no actual letter), gentle apologetic vibe
```

---

# ✨ 카테고리 5 (옵션) — 스티커 베이스 12장

> 사용처: 스티커 제작 기능 데모 + 사용자가 커스터마이즈할 베이스 캐릭터
> 우선순위: **낮음** (메뉴/뉴스 다 끝난 후)

12가지 표정/포즈 (각각 1024×1024, 투명 배경 권장):
1. `sticker_base/wave.png` — 손 흔드는 토우리
2. `sticker_base/heart_eyes.png` — 하트 눈 토우리
3. `sticker_base/wink.png` — 윙크 토우리
4. `sticker_base/cry.png` — 우는 토우리 (귀엽게)
5. `sticker_base/sleep.png` — 자는 토우리
6. `sticker_base/eat.png` — 딸기 먹는 토우리
7. `sticker_base/dance.png` — 춤추는 토우리
8. `sticker_base/think.png` — 생각하는 토우리
9. `sticker_base/celebrate.png` — 만세 토우리
10. `sticker_base/shy.png` — 부끄러운 토우리
11. `sticker_base/love.png` — 하트 안은 토우리
12. `sticker_base/sparkle.png` — 반짝 토우리

각 프롬프트 공통 베이스:
```
touri-bunny [pose], transparent background, single character isolated,
sticker style, thick clean outline, vivid soft pink palette,
no text, no shadows on background
```

---

# 📊 총 이미지 수

| 카테고리 | 장수 | 우선순위 |
|---|---|---|
| 메뉴 9칸 | 9 | ★★★ 필수 |
| 뉴스 카테고리 | 12 | ★★★ 필수 |
| 영성 카드 | 4 | ★★ 권장 |
| 빈 상태 | 6 | ★★ 권장 |
| 스티커 베이스 | 12 | ★ 옵션 |
| **총** | **43장** | |

비용 (fal.ai flux-lora ~₩50/장): **약 ₩2,150** (필수 21장만 하면 **₩1,050**)

---

# 🚀 Codex 실행 워크플로우

1. 이 파일을 Codex에 던지고 "필수 우선순위(★★★) 21장부터 생성해줘" 요청
2. 토우리 캐릭터 시트 + 깨끗한 기존 이미지 4장(`touri_morning`, `touri_self_love`, `touri_meditation`, `touri_celebration`) **참고 이미지로 함께 업로드**
3. 각 이미지 생성 후 텍스트 박힘 여부 확인 → 박혀있으면 negative prompt 더 강화해서 재생성
4. 폴더 구조대로 저장:
   ```bash
   mkdir -p assets/character/{menu_icons,news_categories,spirituality,empty_states,sticker_base}
   ```
5. 생성 끝나면 `pubspec.yaml` assets 섹션에 폴더 추가:
   ```yaml
   - assets/character/menu_icons/
   - assets/character/news_categories/
   - assets/character/spirituality/
   - assets/character/empty_states/
   ```
6. `flutter pub get` → menu_screen, news_screen 등에서 새 경로로 교체

---

# 🐛 디버깅 — 텍스트 박힘 재발 시

LoRA 학습 데이터에 텍스트 박힌 이미지(`scene_study` 등)가 12장 중 일부 들어가서 모델이 "토우리 + 텍스트"를 같이 학습한 상태. 이걸 negative로 강하게 누르려면:

```
negative_prompt: text, letters, words, korean, hangul, characters, typography,
captions, signs, logos, watermark, signature, handwriting, calligraphy,
written language, alphabet, symbols with meaning, paper with writing
```

guidance_scale을 4.0~4.5로 살짝 올리면 prompt 영향력 ↑ (텍스트 제거 효과 ↑).
그래도 안 되면 inpainting으로 텍스트 부분만 지우거나, 다른 시드로 재시도.

---

_작성: 2026-06-04, Cowork(Claude) → Codex 핸드오프_
_관련 파일: BRAND.md, HANDOFF.md, touri_lora_url.txt_
