# 🚀 Codex 큰 배치 작업 — 한 번에 진행

> 변승환님 Codex 맥스 구독 = 토큰 무제한. 한 번에 묶어서 다 처리.
> fal.ai 비용만 ₩250 정도. 코드 작업은 호출 거의 없음.

---

## 📋 작업 목록 (우선순위 순)

### 1. 🌸 봄팩 5장 재생성 (~₩250)

대상: `assets/character/packs/spring/03.png, 04.png, 07.png, 10.png, 11.png`

기존 5장은 **흰 사각형 덧칠 자국** 있음. 새 random seed로 재생성:

- `spring/03` 봄나물 한복 — 머리 위 흰 사각형 제거
- `spring/04` 진달래 한복 — 좌상단 흰 사각형 제거
- `spring/07` 딸기 한복 — 옆 큰 흰 둥근 자국 제거
- `spring/10` 꽃길 한복 — 좌상단/우상단 흰 자국 제거
- `spring/11` 차 마시는 한복 — 액자 같은 흰 박스들 다 제거

핵심 지시:
- **새 random seed** (이전 seed는 글씨/덧칠 학습됨)
- **한복은 유지** (지난 4장 fix할 때 한복 빠진 케이스 있었음 — 그러지 말 것)
- 박스 자국 / 깨진 글씨 박히면 다른 seed 최대 3회 재시도
- 그래도 박히면 **inpainting**으로 자연스럽게 채우기 (흰 페인트 덧칠 X)
- 인접 환경 단순화 (책/액자/배너 등 "텍스트 표면" 줄이기)

### 2. 🔧 Flutter 빌드 검증

```bash
cd ~/Documents/Claude/Projects/touri-app
flutter clean
flutter pub get
flutter analyze
```

에러 다 잡기. 흔한 케이스:
- 새 추가된 폴더(`assets/character/menu_icons/` 등) pubspec.yaml 등록 누락
- 새 위젯(TouriAppBar, PetStatusCard) import 누락
- const 위반

### 3. 📱 실제 실행 + 스크린샷 (변승환님 검증용)

```bash
flutter run -d chrome
```

확인 항목:
- [ ] 홈 탭: PetStatusCard 보임 (별가루 단계, 능력치 막대)
- [ ] 메뉴 탭: 10칸 그리드, 토우리 키우기 칸 추가됨
- [ ] 다이어리 들어가서 본문 10자 이상 작성 → "💗 마음 +1" 토스트
- [ ] 메뉴 → 토우리 키우기 → 일일 돌보기 3개 버튼
- [ ] 모든 sub 화면에 통일된 TouriAppBar (← 뒤로 + 🏠 홈으로)
- [ ] 시즌팩 화면 — 봄팩 한복 토우리들

각 화면 스크린샷 + 변승환님께 보고

### 4. ✦ 그려줘 풀 플로우 검증 (가장 중요한 paid 기능)

`.env` 키 살아있는지:
```bash
awk -F= '/^(FAL_KEY|ANTHROPIC_API_KEY)=/ {print $1": "length($2)"자"}' .env
```

흐름:
1. 다이어리 → 본문 짧게 적기 ("오늘 아침에 햇살이 너무 좋았어")
2. 무드 선택
3. 보라색 **✦ 그려줘** 버튼 클릭
4. 콘솔 로그 + 네트워크 모니터링:
   - Claude Haiku 호출 (200 OK)
   - 영문 scene 추출 (콘솔 출력 확인)
   - fal.ai submit (request_id 받음)
   - 폴링 → COMPLETED
   - 이미지 URL 받고 다운로드
   - 다이어리에 GeneratedImageView 등장
5. "✨ 새 토우리 도착! 반짝임 +2" 스낵바
6. 수집함에 누적 확인
7. 카운터 3→2 감소

실패 시 디버깅:
- 401 → 키 만료, .env 확인 (값 노출 X)
- Claude 에러 → x-api-key 헤더 확인
- fal.ai 에러 → Authorization: Key <KEY> 형식 확인
- LoRA 404 → touri_lora_url.txt 유효성

### 5. 📰 인앱 뉴스 + Haiku 요약 (Phase 1.5)

목표: news_screen이 외부 링크 대신 인앱 표시. Haiku로 3줄 요약.

작업:
- `lib/services/news_service.dart` 수정 — Google News RSS (`https://news.google.com/rss/search?q={query}&hl=ko`)
- 각 RSS item을 NewsItem 모델로 파싱 (제목/원문URL/published)
- Claude Haiku로 본문 3줄 요약 (영성/Manifest/IT 등 카테고리별 다른 검색어)
- `lib/screens/news_detail_screen.dart` 새로 만들기 — 토우리 카테고리 썸네일 + 제목 + 3줄 요약 + 원문 보기 옵션
- `news_screen.dart`에서 외부 링크 fallback 제거 — 사용자가 거부한 흐름

웹 CORS 문제 — Chrome에서 RSS 직접 못 가져올 수 있음. 모바일 빌드에선 OK. 일단 모바일 우선.

### 6. 🎨 스티커 제작 = 사용자 사진 → fal.ai img2img (Phase 2 핵심 paid)

목표: 사용자가 자기 사진/반려동물 사진 업로드 → 토우리 스타일로 변환.

작업:
- `lib/screens/sticker_make_screen.dart` 새로 만들기
- `image_picker` 패키지 추가 (pubspec.yaml)
- 사용자 사진 업로드 → 미리보기
- 변환 버튼: fal.ai `flux-lora-image-to-image` endpoint 호출
- 파라미터: `image_url` (사용자 사진), `prompt: "touri-bunny style, kawaii watercolor"`, `strength: 0.6`, `lora: touri_lora_url, scale: 0.85`
- 결과 미리보기 + 수집함 저장
- 한도 체크 (커스텀 토우리는 ₩14,900 일회 결제 / 평생권 ₩299,000)

### 7. 📲 Android APK 빌드 (Day 7 목표)

```bash
flutter build apk --release
```

APK 파일 위치: `build/app/outputs/flutter-apk/app-release.apk`

변승환님 폰에 설치 → 데모 영상 30초 (홈 → 메뉴 → 다이어리 → 그려줘 → 결과)

---

## 🎯 검증 체크리스트 (작업 끝나고 변승환님께 보고)

- [ ] 봄팩 5장 깨끗하게 재생성 (한복 유지)
- [ ] 시즌팩 48장 전부 검수 통과
- [ ] flutter analyze 에러 0
- [ ] 홈/메뉴/모든 sub 화면 스크린샷
- [ ] 그려줘 실제 작동 확인 (생성된 이미지 1장)
- [ ] 인앱 뉴스 카드 3장 + Haiku 요약 표시
- [ ] 스티커 제작 화면 + img2img 테스트 (1장)
- [ ] APK 빌드 + 폰 설치 + 데모 영상

---

## ⚠️ 보안 (절대 지킬 것)

- `.env` 절대 commit X, 채팅에 키 값 노출 X
- `nano .env`로만 편집
- 키 길이만 확인: `awk -F= '/^(FAL_KEY|ANTHROPIC_API_KEY)=/ {print $1": "length($2)"자"}' .env`
- 스크린샷에 키 들어가면 안 됨

---

_작성: 2026-06-04, 멀티 작업 배치 핸드오프_
_관련: CLAUDE_CODE_NEXT.md, HANDOFF.md, IMAGE_PROMPTS_SEASONAL.md, TOURI_ROADMAP.md_
