# 🔄 토우리 — 재생성 프롬프트 (텍스트 박힘 fix)

> 1차 생성 43장 중 12장에 텍스트가 박혀 재생성 필요.
> **핵심 변경**: 종이/책/배너/말풍선 같은 "텍스트 표면" 요소 자체를 제거하거나 "완전히 매끈한 표면" 강조.

---

## ⚠️ 강화된 공통 규칙

### 새 Negative prompt (훨씬 강화)
```
text, letters, words, korean characters, hangul, english characters,
chinese characters, japanese characters, alphabet, numbers, digits,
captions, titles, headers, banners with text, ribbons with text,
paper with writing, book covers with text, newspaper headlines,
scrolls with markings, signs, labels, watermarks, signatures,
stamps, logos, brand marks, typography, calligraphy, handwriting,
speech bubbles with text, thought bubbles with text,
written language, symbols with meaning, decorative text,
"morning routine", "diary", "news", any english phrase
```

### Positive 추가 키워드 (매 프롬프트에 박기)
```
completely blank surface, smooth featureless paper,
no writing anywhere, no decorations on objects, single character only,
absolutely no text or letters in the image
```

### 기술 파라미터 변경
- `guidance_scale: 4.5` (3.5 → 4.5, prompt 영향력 ↑)
- `num_inference_steps: 32` (28 → 32, 디테일 정제)
- 새 seed 사용 (이전 seed 텍스트 생성 학습됨)

---

# 📁 재생성 12장

## 🍓 메뉴 (3장)

### M1. `menu_icons/diary.png` (재생성)
**문제**: 좌상단에 "두 디올으드 / 하은 으난튬모훙라" 깨진 한글
**새 프롬프트**:
```
touri-bunny sitting cheerfully, holding a single strawberry pen up in one paw,
small heart sticker floating beside, cream background,
NO desk, NO open book, NO notebook, NO paper anywhere in the image,
just the bunny with a pen and a few sparkles
```
> 책/노트 제거가 핵심. 펜만 들고 있으면 "다이어리" 컨셉 충분.

### M2. `menu_icons/season_pack.png` (재생성)
**문제**: 좌상단 "로은와 콩디" 깨진 한글
**새 프롬프트**:
```
touri-bunny standing in the center, surrounded by four small floating
seasonal symbols (cherry blossom petal, sunflower bloom, maple leaf, red rose),
each symbol in a small soft glow bubble,
NO labels, NO text bubbles, NO banners, NO callout boxes,
just pure floating symbols around the bunny
```

### M3. `menu_icons/news.png` (재생성)
**문제**: 하단 "리트을어 이기구응" + 신문 표지 "KHHHG"
**새 프롬프트**:
```
touri-bunny sitting holding a folded pastel pink blank paper sheet
(completely blank, no print, no text, no headlines, totally smooth white surface),
small sun ray and coffee cup beside, cream background,
NO newspaper layout, NO columns, NO articles, NO writing on paper
```
> 신문 → "blank paper" 단순화.

---

## 📰 뉴스 카테고리 (5장)

### N1. `news_categories/life.png` (재생성)
**문제**: "Morniny routine" 영문 + 깨진 한글 박힘
**새 프롬프트**:
```
touri-bunny holding a heart-shaped pink mug with both paws, blushing happily,
small lipstick tube and candle beside on a smooth surface,
cream background, cozy soft morning vibe,
NO planner with writing, NO any text in the scene, NO banners, NO titles
```

### N2. `news_categories/culture.png` (재생성)
**문제**: 책 표지에 글씨, 배경에 작은 사인
**새 프롬프트**:
```
touri-bunny hugging a closed blank pastel book to chest (book is completely smooth,
no title, no cover art with text, no spine text),
dreamy eyes, soft sparkles around, cream background,
NO theater curtain, NO ticket, NO signs, single character only
```

### N3. `news_categories/economy.png` (재생성)
**문제**: 상단 "노두리 시루언괴 눈니" 박힘
**새 프롬프트**:
```
touri-bunny holding a single heart-shaped pink coin in paws, smiling cheerfully,
small piggy bank beside (pig is plain pink, NO markings on body),
two floating golden coins nearby (coins are completely plain, no symbols, no numbers),
cream background, NO banners, NO labels above
```

### N4. `news_categories/sports.png` (재생성)
**문제**: 상단 "土기 둠쪽 와랴" + 수건에 "TUDAP"
**새 프롬프트**:
```
touri-bunny wearing a pink headband doing a small cheerful stretch pose,
single pink dumbbell beside (plain, no weight numbers, no markings),
NO towel, NO mat, NO any cloth surface, NO text bubble above the bunny,
cream background, single character only
```

### N5. `news_categories/business.png` (재생성, 마이너)
**문제**: 우하단 작은 도장(빨간 사각형) 안에 글씨
**새 프롬프트**:
```
touri-bunny wearing a tiny pink bow tie, holding a small smooth brown briefcase
(briefcase has NO logo, NO stamp, NO emblem, completely plain leather surface),
cream background, NO watermark in corners, NO signature, NO stamps anywhere
```

---

## 🌙 영성 (1장)

### S1. `spirituality/manifest_week.png` (재생성)
**문제**: 상단 분홍 배너에 "루 킬 브 투 라 른" 박힘
**새 프롬프트**:
```
touri-bunny sitting peacefully in the center, looking up with hopeful eyes,
seven small cute star characters floating around in a soft arc above
(stars have tiny smile faces but NO text on them),
cream background with soft sparkles,
NO banner, NO ribbon, NO sign, NO arch with text, completely textless scene
```

---

## 🥺 빈 상태 (3장)

### E1. `empty_states/empty_news.png` (재생성)
**문제**: 상단 "의 윜 콘 툴 츊 후노 내" + 신문 표지에 작은 글씨
**새 프롬프트**:
```
touri-bunny napping curled up peacefully on a folded smooth pastel pink blanket
(blanket is completely plain, no print, no pattern, no text),
small Zz shape floating above (just the letter shape as decoration, no other text),
soft afternoon light, cream background,
NO newspaper, NO paper, NO writing surface anywhere
```
> 신문 → 매끈한 담요로 컨셉 변경.

### E2. `empty_states/quota_exceeded.png` (재생성)
**문제**: 상단 "다하 트노 좀 라러" 박힘
**새 프롬프트**:
```
touri-bunny stretching both paws up high trying to reach a glowing pink star
just out of reach, hopeful tilted head, golden sparkle aura around the star,
cream background, NO banner above, NO sign, NO callout, NO text bubble
```

### E3. `empty_states/error.png` (재생성)
**문제**: 상단 "궨 야운 오제더" + 말풍선
**새 프롬프트**:
```
touri-bunny sitting confused with one paw holding an unplugged small pink cable,
slightly tilted head, single small "?" shape floating beside (just the question
mark glyph as decoration, NO other characters, NO speech bubble with text),
cream background, NO banner, NO sign above
```

---

# 🔧 Codex 스크립트 수정

`scripts/generate_image_prompt_assets.py`에서 이 12장만 재생성하는 모드 추가:

```python
REGENERATE_ONLY = [
    "menu_icons/diary",
    "menu_icons/season_pack",
    "menu_icons/news",
    "news_categories/life",
    "news_categories/culture",
    "news_categories/economy",
    "news_categories/sports",
    "news_categories/business",
    "spirituality/manifest_week",
    "empty_states/empty_news",
    "empty_states/quota_exceeded",
    "empty_states/error",
]
```

비용: 12장 × ₩50 = **약 ₩600**

---

# 🐛 그래도 텍스트 박히면

FLUX 모델이 "종이/책/신문" 같은 명사를 보면 자동으로 글씨를 채우려는 경향이 강함. 추가 fallback:

1. **컨셉 자체를 텍스트 없는 사물로 변경**
   - 신문 → 매끈한 종이 또는 태블릿 (빈 화면)
   - 책 → 닫힌 책 + 표지에 하트 도장
   - 노트 → 노트 아예 빼고 펜만

2. **Inpainting으로 텍스트 부분만 지우기**
   - 깨진 텍스트 영역 마스킹 → 같은 프롬프트로 inpaint
   - fal.ai `flux-lora-inpainting` endpoint 사용

3. **포토샵/Pixelmator 수동 지우기**
   - 12장 정도라 수동도 빠름 (각 1분)
   - 텍스트 위에 같은 색 페인트 → blur

---

_작성: 2026-06-04, 검수 후 재생성용_
_관련: IMAGE_PROMPTS.md (1차 프롬프트)_
