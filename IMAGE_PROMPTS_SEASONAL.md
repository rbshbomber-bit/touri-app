# 🌸 시즌팩 재생성 — 한국 컨셉 + 깨진 글씨 제거

> 현재 `assets/character/packs/{spring,summer,autumn,valentine}/01~12.png` 다수에:
> 1. **일본 기모노** 박혀있음 (한복이어야 함)
> 2. **깨진 한글 글씨** 박혀있음
>
> 봄팩 12장은 우선 재생성, 나머지는 시간 되는 대로.

---

## ⚠️ 공통 규칙 (모든 시즌팩에 자동 적용)

### Trigger
```
touri-bunny
```

### 강화 Negative (글씨 박힘 + 일본 요소 제거)
```
text, letters, words, korean hangul, japanese characters, chinese characters,
captions, banners with text, watermarks, signatures, logos,
kimono, yukata, obi belt, japanese style, geisha, fan with text,
torii gate, japanese flag, sakura petals with text,
multiple characters, blurry, low quality
```

### Positive style suffix
```
kawaii watercolor illustration, soft pastel palette, puffy fluffy bunny,
dashed outline body, big shiny black eyes, blush cheeks, sparkles,
clean cream background, picture book style, korean traditional aesthetic
```

### 기술 파라미터
- model: `fal-ai/flux-lora`
- LoRA: `touri_lora_url.txt` (scale 1.0)
- size: `square_hd`
- inference_steps: 32
- guidance_scale: 4.5

---

# 🌸 봄팩 — 한국 봄 (벚꽃·진달래·딸기)

**의상 공통**: 한국 한복 (짧은 저고리 + 풍성한 치마 + 고름 리본)
- 저고리: 흰색 or 연분홍, 옷고름 분홍/빨강
- 치마: 풍성한 분홍/연한 라벤더
- **금지**: 기모노 깃 (V자 교차), 두꺼운 띠(obi)

### `packs/spring/01.png` — 벚꽃나무 아래 한복 토우리
```
touri-bunny wearing a pink and white korean hanbok dress (short jeogori jacket
with pink ribbon ties at chest, full flowing chima skirt with cherry blossom
embroidery), sitting peacefully under a blooming cherry blossom tree,
soft pink petals falling, cream background
```

### `packs/spring/02.png` — 한복 + 부채
```
touri-bunny wearing a soft pink korean hanbok with delicate plum blossom
pattern on the skirt, holding a small round korean traditional fan (부채)
with cherry blossom motif, cheerful smile, cream background
```

### `packs/spring/03.png` — 봄나물 토우리
```
touri-bunny in mint-green hanbok jeogori and yellow chima skirt,
holding a small bamboo basket filled with spring herbs and tiny flowers,
soft sunny meadow background
```

### `packs/spring/04.png` — 진달래꽃 한복
```
touri-bunny in lilac hanbok with deep pink ribbon ties, surrounded by
floating azalea (진달래) flowers, gentle spring wind blowing,
korean traditional aesthetic
```

### `packs/spring/05.png` — 봄비 한복 우산
```
touri-bunny in pastel pink hanbok holding a small korean traditional
oil-paper umbrella (기름종이 우산), light spring rain falling,
small puddles reflecting petals, cozy mood
```

### `packs/spring/06.png` — 그네 타는 한복
```
touri-bunny in bright coral hanbok riding a small korean traditional
swing (그네) tied with colorful ribbons between two trees,
joyful expression, cherry blossoms in air
```

### `packs/spring/07.png` — 딸기 한복
```
touri-bunny in white hanbok with strawberry print on chima skirt,
holding a basket of fresh strawberries, blushing cheeks,
warm spring sunlight, cream background
```

### `packs/spring/08.png` — 봄 한복 꽃다발
```
touri-bunny in soft yellow hanbok with pink ribbon, hugging a large
bouquet of pastel spring flowers (peonies, tulips, magnolia),
sparkles around, cream background
```

### `packs/spring/09.png` — 한옥 마당 한복
```
touri-bunny in elegant pink hanbok standing in a korean traditional
hanok courtyard (한옥 마당), wooden door behind, hanging lanterns,
peaceful afternoon
```

### `packs/spring/10.png` — 꽃길 한복
```
touri-bunny in light blue hanbok walking on a path covered with
cherry blossom petals, looking up dreamily, soft pink glow,
korean spring aesthetic
```

### `packs/spring/11.png` — 차 마시는 한복
```
touri-bunny in cream-colored hanbok sitting at a low korean traditional
table (소반), holding a small ceramic teacup with steaming tea,
cozy floral atmosphere
```

### `packs/spring/12.png` — 봄 만끽 한복 점프
```
touri-bunny in pink hanbok jumping joyfully in the air, hanbok skirt
flowing, cherry blossom petals swirling around, sparkles and hearts,
celebration of spring
```

---

# ☀️ 여름팩 — 한국 여름 (모시·소나기·바다)

**의상 공통**: 모시 한복 (얇은 여름 한복, 시원한 색)
- 저고리: 흰색 모시 (반투명한 천), 옷고름 옥색/하늘색
- 치마: 옥색/하늘색/연두

### `packs/summer/01.png` — 모시 한복 + 부채
```
touri-bunny wearing a white mosi hanbok (sheer cotton ramie summer hanbok)
with jade green ribbon ties, holding a korean traditional round fan (buchae)
with peony pattern, cooling herself, soft summer breeze, cream background
```

### `packs/summer/02.png` — 수박 한복
```
touri-bunny in light blue mosi hanbok, hugging a large fresh watermelon slice,
cherry seeds scattered, blushing cheeks, summer afternoon vibe, cream background
```

### `packs/summer/03.png` — 빙수 한복
```
touri-bunny in mint mosi hanbok sitting at a low korean table eating a
mountain of bingsu (korean shaved ice) topped with red bean and fruit,
cool refreshing summer treat, cream background
```

### `packs/summer/04.png` — 연꽃 연못 한복
```
touri-bunny in pale jade mosi hanbok sitting on a wooden pavilion (정자)
overlooking a lotus pond with blooming pink lotuses, dragonflies floating,
peaceful summer scene
```

### `packs/summer/05.png` — 백일홍 한복
```
touri-bunny in white mosi hanbok with pink ribbon, standing among
blooming crepe myrtle (백일홍) flowers, gentle summer wind,
korean traditional aesthetic, cream background
```

### `packs/summer/06.png` — 한강 산책 한복
```
touri-bunny in light sky-blue mosi hanbok walking along a riverside path
with a small parasol, soft sunset reflecting on water, peaceful walk,
modern korean summer aesthetic
```

### `packs/summer/07.png` — 매미 한복
```
touri-bunny in pale green mosi hanbok climbing a tree trunk, a small cute
cicada (매미) friend beside, summer leaves rustling, sunny afternoon,
nostalgic korean summer
```

### `packs/summer/08.png` — 평상 누워있는 한복
```
touri-bunny in soft cream mosi hanbok lying lazily on a korean traditional
wooden bed (평상), one paw fanning herself, watermelon slice beside,
hot summer afternoon vibe
```

### `packs/summer/09.png` — 한옥 마루 + 풍경
```
touri-bunny in pale jade mosi hanbok sitting on a wooden hanok porch (마루),
small wind chime (풍경) hanging from eaves, soft summer rain falling,
cozy peaceful mood
```

### `packs/summer/10.png` — 비단부채 춤 한복
```
touri-bunny in pale pink and white mosi hanbok performing a traditional
korean fan dance (부채춤), holding two large pink silk fans spread wide,
graceful pose, sparkles around
```

### `packs/summer/11.png` — 옥수수 한복
```
touri-bunny in yellow-cream mosi hanbok holding a freshly steamed
korean corn (찐옥수수), happy smile, summer farm aesthetic,
cream background
```

### `packs/summer/12.png` — 칠월칠석 별 한복
```
touri-bunny in deep navy mosi hanbok looking up at the milky way and stars,
two bridge magpies overhead (chilseok legend), dreamy starry sky,
cream-night background, korean folktale mood
```

---

# 🍁 가을팩 — 한국 가을 (단풍·추석·국화)

**의상 공통**: 풍성한 가을 한복 + 노리개
- 저고리: 짙은 빨강/주황/머스타드
- 치마: 갈색/머스타드/와인
- 노리개 (한복 장식) 살짝 매달림

### `packs/autumn/01.png` — 단풍 든 한복
```
touri-bunny wearing a deep red and mustard yellow korean hanbok with
norigae accessory, sitting under a maple tree with red and orange autumn
leaves falling, cozy autumn light, cream background
```

### `packs/autumn/02.png` — 추석 송편 한복
```
touri-bunny in soft mustard hanbok holding a tray of fresh half-moon shaped
songpyeon (송편) rice cakes in pink, green, white colors, korean chuseok
celebration, warm warm light
```

### `packs/autumn/03.png` — 한가위 보름달 한복
```
touri-bunny in autumn-orange hanbok bowing toward a huge bright full moon,
silhouette of mountains behind, korean chuseok tradition,
peaceful evening sky, cream background
```

### `packs/autumn/04.png` — 감 따는 한복
```
touri-bunny in burnt orange hanbok reaching up to pick a ripe orange
persimmon (감) from a tree branch, more persimmons hanging,
autumn harvest vibe, cream background
```

### `packs/autumn/05.png` — 국화꽃 한복
```
touri-bunny in deep burgundy hanbok holding a bouquet of yellow and white
chrysanthemums (국화), traditional korean autumn flower symbol,
elegant pose, cream background
```

### `packs/autumn/06.png` — 추석 차례상 한복
```
touri-bunny in formal cream and red hanbok standing beside a korean
traditional ancestral table (차례상) with fruits, songpyeon, and a small
incense burner, respectful chuseok mood
```

### `packs/autumn/07.png` — 코스모스 한복
```
touri-bunny in light pink hanbok walking through a field of pink and white
cosmos flowers, gentle autumn breeze swaying the flowers,
romantic countryside scene
```

### `packs/autumn/08.png` — 단풍놀이 한복
```
touri-bunny in red and gold hanbok sitting on a wooden pavilion in a
mountain temple (산사) covered in autumn maple leaves, scenic korean
autumn landscape behind
```

### `packs/autumn/09.png` — 추석 제기차기 한복
```
touri-bunny in playful orange and brown hanbok kicking a colorful
korean shuttlecock (제기) in mid-air, chuseok game tradition,
cheerful pose, cream background
```

### `packs/autumn/10.png` — 가을 들녘 한복
```
touri-bunny in golden mustard hanbok standing in a golden rice paddy
field at harvest time, rice stalks swaying, blue sky and white clouds,
korean countryside autumn
```

### `packs/autumn/11.png` — 호박 추수 한복
```
touri-bunny in pumpkin-orange hanbok hugging a large round korean pumpkin
(호박), other small pumpkins around, autumn harvest celebration,
cream background
```

### `packs/autumn/12.png` — 가을밤 별 한복
```
touri-bunny in deep wine red hanbok sitting on a wooden porch at night,
looking up at a starry autumn sky with the harvest moon, small ondol
fire glowing inside, cozy cold autumn night
```

---

# 💖 발렌타인팩 — 글로벌 (한복 아님)

발렌타인은 한국/일본 구분 없는 글로벌 컨셉. 깨진 글씨만 확실히 제거.
의상은 일반 토우리 (귀여운 분홍 보타이/리본 정도).

### `packs/valentine/01.png` — 큰 하트 안기
```
touri-bunny hugging a giant fluffy pink heart pillow to chest, blushing
cheeks, small floating hearts around, sparkles, cream background
```

### `packs/valentine/02.png` — 초콜릿 박스
```
touri-bunny opening a heart-shaped chocolate box, various truffles inside,
excited expression, pink ribbon on the box, sweet vibe
```

### `packs/valentine/03.png` — 사랑 편지
```
touri-bunny holding a sealed pink envelope with a red heart wax seal,
sparkles around, shy blushing smile, cream background, NO writing on envelope
```

### `packs/valentine/04.png` — 장미 한 송이
```
touri-bunny holding a single perfect red rose with both paws, looking at it
dreamily, small heart petals floating, cream background
```

### `packs/valentine/05.png` — 두 마리 커플 토우리
```
two touri-bunnies sitting close together holding paws, one slightly pink-tinted
and one cream, a heart bubble floating between them, romantic moment,
cream background — exception: two characters allowed here
```

### `packs/valentine/06.png` — 분홍 풍선
```
touri-bunny holding a bundle of heart-shaped pink and red balloons floating up,
joyful expression, slight breeze, cream background
```

### `packs/valentine/07.png` — 케이크 + 촛불
```
touri-bunny sitting at a small table with a heart-shaped pink layered cake,
single candle lit, soft warm glow, anticipation in eyes, cream background
```

### `packs/valentine/08.png` — 큐피드 토우리
```
touri-bunny dressed as a cute cupid with tiny fluffy white wings, holding
a small pink bow and heart-tipped arrow, mischievous smile,
gentle sparkles, cream background
```

### `packs/valentine/09.png` — 데이트 카페
```
touri-bunny sitting at a cute pink cafe table, heart-shaped latte art in cup,
small slice of strawberry cake on plate, soft window light,
romantic afternoon, NO text on menu or cups
```

### `packs/valentine/10.png` — 키스 마크
```
touri-bunny blowing a kiss, lip-shaped pink hearts floating from mouth,
blushing wink, sparkles, cream background
```

### `packs/valentine/11.png` — 약속 반지
```
touri-bunny holding a tiny ring with a small heart-shaped pink gem on a
soft velvet cushion, dreamy hopeful eyes, sparkles, cream background
```

### `packs/valentine/12.png` — 사랑 자물쇠
```
touri-bunny attaching a small heart-shaped padlock to a fence, key dangling
from a pink ribbon, bridge railing in background, romantic gesture,
NO text on padlock
```

---

# 🚀 Codex 실행 우선순위

| 단계 | 작업 | 비용 (₩50/장) |
|---|---|---|
| **1차 (필수)** | 봄팩 12장 한복 재생성 | ₩600 |
| **2차** | 발렌타인팩 글씨 박힌 거 검수 + 재생성 | ~₩200 |
| **3차** | 여름팩 12장 한복 디자인 + 생성 | ₩600 |
| **4차** | 가을팩 12장 한복 디자인 + 생성 | ₩600 |
| **총** | ~48장 | **~₩2,000** |

---

# 🐛 자주 박히는 일본 요소 — 확실히 빼기

negative에 명시적으로 박을 키워드:
```
kimono, yukata, obi (japanese belt), japanese kimono collar V-shape,
geisha makeup, japanese tea ceremony, japanese fan (sensu),
torii gate, koi fish, japanese paper lantern (chochin),
japanese architecture, shoji screen, tatami, samurai, ninja
```

대신 positive에 박을 한국 키워드:
```
korean hanbok (chima skirt + jeogori jacket with ribbon ties),
korean traditional aesthetic, hanok wooden architecture,
korean lanterns (cheongsachorong), korean fan (buchae) with peony,
korean accessories (norigae, binyeo hairpin)
```

---

_작성: 2026-06-04, 시즌팩 한국화 + 글씨 박힘 fix_
_관련: IMAGE_PROMPTS.md, IMAGE_PROMPTS_REGENERATE.md_
