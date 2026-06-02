# 토우리 (Touri) — 매니페스테이션 다이어리 앱

> Flutter 앱. 7일 안에 누나에게 보여줄 프로토타입을 만드는 중. 단순 다이어리 X, AI · 매니페스테이션 · 스티커 · 동기부여가 들어간 실사용 앱.

## 🎯 현재 미션

- **목적**: 누나(검증자)에게 "이거 돈 낼 만한 진짜 앱이네" 인정받기
- **데드라인**: 1주일 (Day 1 = 2026-06-02 화요일 시작)
- **다음 주**: 같은 캐릭터로 PDF 디지털 플래너 (6개월 분량) 작업 예정
- **플랫폼**: 텀블벅 (90% 여성, 다이어리 꾸미기·영적 주제 친화)
- **타겟**: 13-40대 여성, 아기자기·덕후·애니메이션 좋아하는 타입

## 🐰 브랜드 핵심

- **사업자명**: 토우리 (Touri)
- **마스코트**: 토우리 토끼 (오른쪽 귀 하트 클립 ♡, 화이트+핑크 볼터치)
- **톤**: "언제나 네 편이에요" — 다정한 반말, 명령조 절대 금지
- **메인 컬러**: `#FFB6C1` (Touri Pink), 텍스트 `#8E7A7A` (warm brown, 검정 X)
- 자세한 가이드 → `BRAND.md`

## 📦 현재 진척

**Day 1 (완료)**:
- Flutter 프로젝트 셋업 (`flutter create .` 직전까지 → 사용자가 실행 완료)
- `pubspec.yaml` (google_fonts + 캐릭터 자산 등록)
- 테마 시스템 (`lib/theme/touri_colors.dart`, `touri_theme.dart`)
- placeholder 홈 화면 (현재 unused — `lib/screens/home_screen.dart`)

**Day 2 (완료)**:
- `lib/models/touri_mood.dart` — 무드 enum (4종: 비서/운동/식단/꿈)
- `lib/widgets/ai_companion_card.dart` — 상단 AI 카드
- `lib/widgets/mood_tray.dart` — 하단 무드 선택
- `lib/widgets/diary_paper.dart` — 워시테이프 + 줄종이 + 다짐
- `lib/screens/diary_screen.dart` — 메인 화면 조립
- `lib/main.dart` — DiaryScreen으로 라우팅
- 현재 작동: Chrome에서 `flutter run -d chrome` 가능, 무드 4종 토글되며 AI멘트·캐릭터·다짐 함께 변경

**Day 3-7 (예정)**:
- Day 3: 다이어리 본문 직접 쓰기 (TextField) + 자동 저장 + 매니페스테이션 보드 + 감사 일기 3가지
- Day 4: 스티커 드래그 시스템 + 위치·회전 저장
- Day 5: 로컬 저장 (Hive) + 캘린더 뷰 + 과거 다이어리 열람
- Day 6: AI 멘트 — Anthropic API 통합 (또는 더미 회전), 명언·affirmation DB
- Day 7: Android APK 빌드 + 폰 설치 + 30초 데모 영상

## 🚫 MVP 범위 밖 (이번 주 안 함)

- iOS 빌드 (Xcode/CocoaPods 셋업 복잡, Android만)
- 실제 서버·DB (Supabase 안 붙임, 로컬 저장만)
- 회원가입·로그인
- 실시간 친구 협업 (보여주기만 — 친구 커서 애니메이션은 시뮬레이션)
- 결제·구독 시스템
- 푸시 알림
- AI 토우리 음성 인터랙션

## 🏗️ 아키텍처

- **State management**: setState (단순함, 1주차엔 충분). 나중에 Riverpod 고려
- **저장**: shared_preferences → 추후 Hive
- **라우팅**: 단일 화면 시작, 점차 Navigator로 추가
- **AI**: 더미 회전 → Day 6에 Anthropic API (있으면)

## 📁 폴더 구조

```
touri-app/
├── BRAND.md                ← 브랜드 가이드 (꼭 읽기)
├── CLAUDE.md               ← 이 파일
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart           ← TouriApp 진입점
│   ├── models/
│   │   └── touri_mood.dart ← 무드 enum
│   ├── screens/
│   │   ├── diary_screen.dart ← 메인 화면
│   │   └── home_screen.dart  ← Day 1 placeholder (unused)
│   ├── theme/
│   │   ├── touri_colors.dart
│   │   └── touri_theme.dart
│   └── widgets/
│       ├── ai_companion_card.dart
│       ├── diary_paper.dart
│       └── mood_tray.dart
├── assets/character/scenes/
│   ├── character_sheet.png  ← 캐릭터 시트 (가장 중요)
│   ├── lookbook_merchandise.png
│   ├── scene_grid_9panels.png
│   ├── scene_secretary.png
│   ├── scene_exercise.png
│   ├── scene_diet.png
│   └── thumbs/             ← 400px 썸네일
├── prototype/
│   └── index.html          ← 디자인 시안 (브라우저로 직접 열면 됨)
├── setup-macmini.sh        ← 맥미니 환경 셋업 (1회용)
├── init-and-push.sh        ← 맥북 초기 셋업 (1회용)
└── .github/workflows/build.yml ← GitHub Actions (self-hosted runner)
```

## 🎨 디자인 원칙 (BRAND.md에서 추출)

- 폰트: `Gaegu` (로고/헤더), `Noto Sans KR` (본문), `Nanum Pen Script` (다이어리 손글씨)
- 둥글기: `borderRadius` 14~18px (큰 카드는 18, 작은 요소는 14)
- 그림자: 부드럽게만 (`TouriPink @ 0.2 opacity, blur 10`)
- 워시테이프 효과: 60% opacity, 살짝 회전
- 줄종이: 28px 간격 가로선, `#F4E0D2` 색

## 🚦 코드 규칙

- 주석 최소화 (한국어 짧은 설명만 OK)
- 위젯은 작게 쪼개기 (한 파일 200줄 이하 권장)
- 색은 항상 `TouriColors.xxx` 사용 (hex 직접 X)
- 텍스트 스타일은 `Theme.of(context).textTheme.xxx` 또는 `TouriTheme.handwriting()`
- `setState`는 작은 단위로, 비싼 위젯은 `const`로

## 🛠️ 실행 명령어

```bash
# 의존성 설치
flutter pub get

# Chrome에서 실행 (가장 빠른 확인)
flutter run -d chrome

# 연결된 폰에서 실행
flutter devices                    # 디바이스 ID 확인
flutter run -d <device-id>

# Android APK 빌드 (배포용)
flutter build apk --release

# 코드 분석
flutter analyze

# 의존성 트리
flutter pub deps
```

## 📝 GitHub

- Repo: `rbshbomber-bit/touri-app` (private)
- Branch: `main`
- 현재 마지막 push 커밋: `9a4ac0d` (BRAND.md + 캐릭터 자산 + prototype v0.2)
- Day 1-2 Flutter 코드는 **아직 commit 안 됨** — 작업 시작 전에 commit 권장

## 🤝 협업 상황

- **사용자**: 변승환 (rbshbomber@gmail.com), 비기술 배경. 기획·디자인 결정 담당
- **개발자**: Claude (당신). 코드·아키텍처·실행 담당
- **검증자**: 누나 (Day 7에 보여줄 사람)
- 사용자는 맥미니에서 작업 중. 맥북에도 touri-app 폴더 있는데 동기화 미완료 (보류 중)

## 💬 톤 가이드 (Claude → 사용자)

- 한국어로 답변
- 코드 변경 시 무엇을 왜 바꿨는지 짧게 설명
- 큰 결정은 사용자에게 먼저 물어보기
- "이거 어때요?" 같은 짧은 핑 자주 보내서 방향 확인
