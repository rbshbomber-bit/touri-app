# 🐰 토우리 — 크로스머신 핸드오프

> 다른 컴퓨터에서 작업을 이어받는 사람(또는 LLM agent)을 위한 단일 진입 문서.
> 이 문서 하나로 **clone → 첫 빌드까지 30분 이내** 도달 가능.
>
> 마지막 갱신: 2026-06-04 (1주 스프린트 종료일)

---

## 1. 프로젝트 개요

**토우리(touri-app)** = Flutter 기반 모바일/웹 앱.
다이어리 + AI 그림 생성(✦ 그려줘) + 다마고치형 캐릭터 키우기 + 인앱 뉴스 + 스티커 제작 + 영성 루틴이 하나로 묶임. 사용자가 일기/매니페스테이션/감사를 쓰면 → AI가 토우리 일러스트를 그려주고 → 토우리가 자란다(별가루→마스터 5단계).

**현재 단계**: 1주 스프린트 프로토타입 완성 → 누나(검증자)에게 카톡으로 APK + 웹 URL 전달 → 30분 사용 후 피드백 받기 → 그 피드백으로 Tumblbug 크라우드펀딩 캠페인 시작.

**타겟**: 13~40대 한국 여성, kawaii/manifestation/일기 관심층.
**가격(예정)**: 그려줘 ₩1,500/회 (무료 주 3회), 구독 ₩4,900~9,900/월, 커스텀 ₩14,900, 평생권 ₩299,000.

---

## 2. 환경 셋업

| 항목 | 요구 사양 |
|---|---|
| **Flutter SDK** | `^3.5.0` (Dart 3.5+) — `pubspec.yaml` 환경 제약 |
| **Dart** | Flutter SDK에 포함 |
| **Android** | JDK 17 + Android SDK + Build Tools 34.0.0 + Platform 34 |
| **iOS** (옵션) | Xcode 15+, CocoaPods |
| **Python** (이미지 생성) | 3.10+ + Pillow, fal-client (scripts/ 내 LoRA 스크립트) |
| **Node** | 불필요 |
| **OS** | macOS / Linux / Windows 다 가능. 단 iOS 빌드는 macOS 전용 |

설치 (macOS):
```bash
brew install --cask flutter
brew install --cask temurin@17        # JDK 17
brew install --cask android-studio    # SDK 자동 설치
flutter doctor                         # 셋업 검증
```

---

## 3. 저장소 / Clone

- **GitHub URL**: https://github.com/rbshbomber-bit/touri-app.git
- **브랜치 전략**: `main` 단일 브랜치. 직접 push 또는 PR. dev 분기 없음.
- **현재 main HEAD**: `b63f774 feat: 토우리 성장 단계 5장 (별가루→마스터)`

첫 셋업:
```bash
git clone https://github.com/rbshbomber-bit/touri-app.git
cd touri-app
cp .env.example .env
# .env 열어서 키 채우기 (4번 섹션 참고)
flutter pub get
flutter run -d chrome     # 웹으로 가장 빠른 확인
# 또는
flutter run -d <android-device-id>   # adb devices로 ID 확인
```

`touri_lora_url.txt`는 `.gitignore` 대상. 별도로 받아야 함:
- fal.ai dashboard에서 학습된 LoRA 모델 URL 복사 → 한 줄로 저장
- 또는 `scripts/train_touri_lora.py` 재실행

---

## 4. 필수 비밀키 (.env)

`.env.example` 복사해서 `.env` 생성 후 채우기. **절대 commit X** (`.gitignore`에 들어있음).

| 변수 | 용도 | 발급 위치 |
|---|---|---|
| `ANTHROPIC_API_KEY` | Claude Haiku — 일기→영문 scene, 뉴스 요약, AI 코칭 | https://console.anthropic.com |
| `FAL_KEY` | fal.ai — LoRA 이미지 생성 (그려줘, 스티커 제작) | https://fal.ai/dashboard/keys |
| `SUPABASE_URL` | DB 엔드포인트 (Phase 2부터 사용) | Supabase Settings → API |
| `SUPABASE_ANON_KEY` | DB 익명 클라이언트 키 | 같은 위치 |
| `MESHY_API_KEY` | 3D 모델 변환 (옵션, 미구현) | https://www.meshy.ai |
| `FIREBASE_APP_ID` | App Distribution APK 자동 배포 (옵션) | Firebase Console |

추가 별도 파일:
- `touri_lora_url.txt` — fal.ai에 업로드된 토우리 LoRA safetensors URL (한 줄, .gitignore)

키 없어도 앱은 빌드되고 fallback 모드로 실행됨 (그려줘/뉴스 요약은 더미).

길이 확인 (값 노출 X):
```bash
awk -F= '/^(FAL_KEY|ANTHROPIC_API_KEY)=/ {print $1": "length($2)"자"}' .env
```

---

## 5. 현재 진행도

### 자산 (총 ~100장 진짜 토우리 일러스트)

| 폴더 | 장수 | 용도 |
|---|---|---|
| `assets/character/menu_icons/` | 9 | 메뉴 그리드 |
| `assets/character/news_categories/` | 12 | 뉴스 카테고리 썸네일 |
| `assets/character/spirituality/` | 4 | 영성 카드 |
| `assets/character/empty_states/` | 6 | 빈 상태 |
| `assets/character/packs/{spring,summer,autumn,valentine}/` | 48 | 시즌팩 한복 |
| `assets/character/pet/` | 5 | 성장 5단계 (stardust/baby/friend/sparkle/master) |
| `assets/character/sticker_base/` | 12 | 스티커 베이스 포즈 |
| `assets/character/scenes/` | 12 | LoRA 학습 원본 |
| `assets/character/generated/` | ~30 | 결과 + preview |

전부 LoRA 학습된 토우리 캐릭터(트리거 `touri-bunny`)로 생성. 봄팩까지 시즌별 한복 통일.

### 기능 완성도

- ✅ 다이어리 (무드 + 본문 + 매니페스테이션 + 감사 + 스티커)
- ✅ ✦ 그려줘 — Claude Haiku로 한국어→영문 변환 → fal.ai LoRA → 결과 부착
- ✅ 토우리 키우기 MVP (5단계 + 능력치 5종 + 일일 돌보기 + 출석 streak)
- ✅ 인앱 뉴스 + Haiku 3줄 요약
- ✅ 스티커 제작 (img2img) — 사용자 사진 → 토우리 스타일
- ✅ 시즌팩 화면
- ✅ 통일된 navigation (TouriAppBar — ← 뒤로 + 🏠 홈)
- ✅ 홈 피드 (뉴스 우선 + PetStatusCard + AffirmationCard + Manifest)

### 빌드/배포 셋업

- ✅ GitHub Actions Android APK 빌드 (Ubuntu runner, SDK 자동 셋업)
- ✅ GitHub Actions Web 빌드 + GitHub Pages 자동 배포
- ✅ GitHub Secrets 3개 등록 (`FAL_KEY`, `ANTHROPIC_API_KEY`, `TOURI_LORA_URL`)
- ⚠️ Repo Public 전환 필요 (Pages 활성화) — 미완

### 남은 작업

| # | 작업 | 누가 | 예상 시간 |
|---|---|---|---|
| 1 | 최근 commit push (성장 5장) | 변승환 / Codex | 1분 |
| 2 | APK 폰 검증 (그려줘 1회 실호출) | 변승환 폰 | 10분 |
| 3 | Repo Public 전환 + Pages Source 설정 | 변승환 GitHub UI | 2분 |
| 4 | 웹 배포 URL 확인 | 자동 | 10분 (빌드) |
| 5 | 누나에게 APK + 웹 URL + README_KOREAN.md 카톡 | 변승환 | 5분 |
| 6 | 누나 30분 사용 + 피드백 | 누나 | 1일 |
| 7 | Supabase 마이그레이션 (Phase 2) | Codex + Cowork | 1-2주 |
| 8 | Tumblbug 캠페인 시작 | 변승환 + 디자이너 | Phase 2 후 |

---

## 6. 빌드 & 배포

### 로컬 빌드

**Web (가장 빠른 검증)**:
```bash
flutter run -d chrome
```

**Android APK (release)**:
```bash
flutter build apk --release
# 결과: build/app/outputs/flutter-apk/app-release.apk
```

**iOS** (macOS + Xcode 필요):
```bash
flutter build ios --release
flutter build ipa --release
```

### GitHub Actions 자동 빌드

- **트리거**: `main` 브랜치 push 또는 Actions 페이지 `Run workflow` 수동
- **결과**:
  - Android APK → Actions Artifacts → `touri-apk-<sha>` ZIP 다운로드
  - Web → `touri-web-<sha>` + GitHub Pages 자동 배포
- **빌드 시간**: 약 10-15분

### Web 배포 (GitHub Pages)

- **URL**: https://rbshbomber-bit.github.io/touri-app/
- **base-href**: `/touri-app/` (subpath라 필수)
- **1회 셋업**: Settings → Pages → Source = `GitHub Actions`
- **⚠️ Repo가 Private이면 무료 계정으로 Pages 불가** — Public 전환 or Pro 결제

상세: `WEB_DEPLOY.md`

---

## 7. GitHub Actions / Secrets

### 워크플로우 파일
`.github/workflows/build.yml` — 3개 job:
- `android` (Ubuntu runner) — APK 빌드 + 아티팩트
- `web` (Ubuntu runner) — Web 빌드 + Pages 아티팩트
- `deploy_web` (Ubuntu runner) — GitHub Pages 배포 (web에 의존)

### Secrets (Settings → Secrets and variables → Actions)
- `FAL_KEY` — fal.ai 호출용
- `ANTHROPIC_API_KEY` — Claude Haiku 호출용
- `TOURI_LORA_URL` — LoRA safetensors URL (한 줄)

없으면 빈 `.env`로 빌드 → fallback 모드 (그려줘는 더미 텍스트만).

### 실패 시 확인 순서
1. Actions 탭 → 빨간 X 빌드 클릭 → 실패한 step 펼치기
2. 에러 메시지 마지막 30줄 보기 (root cause)
3. `gh run view <run-id> --log-failed | tail -100`
4. 0초 fail = workflow YAML 문법 에러 (env/vars 컨텍스트 잘못)
5. 빌드 도중 fail = Gradle/Flutter/pub get 에러 → 로컬 재현

---

## 8. 자주 막히는 부분 + 해결책

### Claude Code CLI 로그인 만료
**증상**: `API Error: 401 Invalid authentication credentials` / `Please run /login`
**해결**: Claude Code 터미널에 `/login` → 브라우저 로그인 → 큐 명령 재실행

### Android 빌드 시 namespace 누락
**증상**: `Namespace not specified` (Gradle 8+)
**해결**: `android/app/build.gradle.kts`에 `namespace = "com.touri.touri"` 확인.

### Flutter pub get 실패
**증상**: 패키지 충돌, Dart SDK mismatch
**해결**:
```bash
flutter clean
rm -rf .dart_tool pubspec.lock
flutter pub get
```

### fal.ai 호출 실패
**증상**: 401/403, LoRA 404
**해결**:
- `.env`의 `FAL_KEY` 길이 확인 (60자 이상 정상)
- `touri_lora_url.txt`가 빈 줄/공백 없는지
- 헤더: `Authorization: Key <KEY>` (Bearer 아님)
- LoRA URL을 브라우저로 직접 열어 .safetensors 다운로드 확인

### Anthropic Claude 호출 실패
**증상**: 401
**해결**:
- 헤더 `x-api-key: <KEY>` (Authorization 아님)
- `anthropic-version: 2023-06-01` 헤더
- 모델 ID: `claude-haiku-4-5-20251001`

### GitHub Pages 배포 안 됨
**증상**: 빌드 통과했는데 URL 404
**해결**:
- Settings → Pages → Source가 `GitHub Actions`로 설정됐는지
- Repo Private이면 Pages 불가 → Public 전환 or Pro
- base-href가 `/touri-app/`로 빌드됐는지

### OneDrive/iCloud 동기화로 assets 깎임
**증상**: `assets/character/` 파일들이 0바이트 또는 사라짐
**원인**: 클라우드 동기화 충돌 / placeholder만 남고 본체 미다운로드
**해결**:
- `git log --oneline -- assets/character/` 로 마지막 정상 commit 찾기
- `git checkout <sha> -- assets/character/` 로 복구
- 또는 `git fsck --lost-found`로 dangling commit 추적
- OneDrive 우클릭 → "항상 이 기기에 보관" 설정
- 또는 클라우드 외부 폴더로 프로젝트 이동

### `.env` / `touri_lora_url.txt` 누락 → bundle asset fail
**증상**: Flutter pub get 통과, build 단계에서 "asset not found"
**원인**: pubspec.yaml `assets:`에 `.env` 등록됐는데 `.gitignore`라 CI에 없음
**해결**: CI workflow에 `Prepare runtime assets` step 추가 (현재 build.yml 적용됨) — Secrets 있으면 진짜 값, 없으면 빈 파일 생성.

### 이미지 텍스트 박힘 / 흰 덧칠 자국
**증상**: fal.ai 결과에 깨진 한글 또는 흰 사각형 덧칠
**해결**:
- Negative prompt 강화 (`IMAGE_PROMPTS_REGENERATE.md`)
- 새 random seed로 재생성 (최대 3회)
- 텍스트 표면(책/신문/배너) 자체 제거하는 컨셉으로 prompt 단순화
- **후처리 흰색 덧칠 절대 금지** — 가려진 자국 더 어색함

---

## 9. 컨벤션 / 코드 스타일

### 폴더 구조
```
touri-app/
├── lib/
│   ├── main.dart
│   ├── theme/                 # 색/폰트 디자인 시스템
│   ├── models/                # touri_pet, touri_entry, growth_stage
│   ├── services/              # pet_service, claude_service, fal_*, news_service
│   ├── widgets/               # PetStatusCard, TouriAppBar 등 재사용
│   ├── screens/               # home_feed, menu, diary, pet_care 등
│   └── data/                  # sticker_catalog, sticker_packs (정적)
├── assets/character/          # 모든 토우리 일러스트
├── android/                   # Android 네이티브
├── ios/                       # iOS 네이티브
├── web/                       # Web 셸 (index.html, manifest)
├── scripts/                   # Python LoRA 생성 스크립트
└── .github/workflows/         # CI/CD
```

### 명명 규칙
- 파일: `snake_case.dart`
- 클래스: `PascalCase`
- 변수/메서드: `camelCase`
- 위젯: 명사 (`PetStatusCard`) / 화면: `XxxScreen`
- 서비스 싱글톤: `XxxService.instance`

### Commit 메시지
한국어 + Conventional Commits:
```
feat: 토우리 키우기 + 시즌팩 한복 + 인앱 뉴스
ci: workflow 단순화 — 0초 fail 원인 제거
docs: update HANDOFF for cross-machine sync
fix: pet_status_card overflow on small screens
```

타입: `feat`, `fix`, `ci`, `docs`, `refactor`, `chore`.

### 브랜치
`main` 단일. 안정성 우선이면 PR + review, 빠른 진행이면 직접 push.

---

## 10. 의사결정 로그 / 컨텍스트

### 왜 fal.ai LoRA?
- 12장 학습 데이터만으로 정체성 유지된 토우리 캐릭터 무한 생성
- 트리거 단어 `touri-bunny` 박으면 항상 같은 컨셉
- 1장당 ~₩50 비용, 사용자 ₩1,500 청구 → 마진 97%

### 왜 모바일+웹 동시?
- 누나(검증자) PC 브라우저로 즉시 미리 보기
- 친구 추천 시 설치 부담 없이 "링크 하나로 체험"
- Phase 2 Supabase 후 계정 sync로 폰/PC 같은 데이터

### 토우리 디자인 핵심 원칙
- 핑크 `#FFB6C1` + 라일락 + 코코아 텍스트 (검정 X)
- 다정한 반말, 명령조 X
- 별가루 → 마스터 5단계 = "별에서 온 존재가 자란다"
- 상세: `BRAND.md`

### 토우리 세계관 — 별가루 컨셉
"알에서 부화" 아님 — "별가루가 모여 토우리 형성". 매니페스테이션/영성 컨셉과 한 줄기 흐름. 마스터 도달 후 = 별의 화신 → 별자리 그림 (Phase 2 무한 progression). 토끼는 포유류라 알에서 부화하는 게 어색하다는 사용자 지적으로 결정됨.

### 1주 스프린트 데드라인
- 시작: 2026-05-28
- 프로토타입 완성: 2026-06-04 (오늘)
- 누나 검증: 2026-06-05~11
- Tumblbug 캠페인 시작: Phase 2 (Supabase) 완료 후

### 누나에게 검증받을 것
1. 가격 ₩1,500/회 적정한지
2. 사용 흐름에 어색한 부분
3. 친구한테 추천하고 싶은지
4. 별가루→마스터 컨셉 직관적인지
5. 그려줘 결과 품질 만족스러운지

### 후처리 흰색 덧칠 금지 (어렵게 배운 교훈)
fal.ai 결과에 깨진 한글이 박혀나오면 OCR + 흰 사각형 덮기로 가리는 후처리를 시도했었음 → 사용자가 즉시 알아챔 ("억지로 하얀색으로 지우더라고"). 정답은 prompt 단계에서 글씨 자체 막기 + 다른 seed 재시도. 후처리는 절대 X.

---

## 11. 관련 문서 인덱스

| 파일 | 한 줄 설명 |
|---|---|
| `BRAND.md` | 컬러 팔레트 + 캐릭터 톤 + 머천 목록 |
| `HANDOFF.md` | **이 문서** — 크로스머신 핸드오프 |
| `TOURI_ROADMAP.md` | Phase 1/2/3 로드맵 (별자리, 마스터 5길, 커뮤니티) |
| `SUPABASE_MIGRATION.md` | Phase 2 백엔드 마스터플랜 (스키마+Auth+Realtime) |
| `WEB_DEPLOY.md` | GitHub Pages 자동 배포 안내 |
| `GITHUB_PAGES_DEPLOY.md` | Codex 작성 push 안내 (영문) |
| `IMAGE_PROMPTS.md` | 1차 fal.ai 프롬프트 43장 |
| `IMAGE_PROMPTS_REGENERATE.md` | 텍스트 박힘 fix용 강화 negative |
| `IMAGE_PROMPTS_SEASONAL.md` | 시즌팩 48장 한복 컨셉 |
| `README.md` | 영문 기본 README |
| `README_KOREAN.md` | 누나용 3분 사용 가이드 |
| `DEMO_SCRIPT.md` | 30초 데모 영상 시나리오 |
| `TUMBLBUG_DRAFT.md` | 크라우드펀딩 캠페인 초안 |
| `CODEX_BIG_BATCH.md` | Codex에 던지는 멀티 작업 묶음 |
| `CLAUDE_CODE_NEXT.md` | Claude Code 다음 작업 핸드오프 |
| `CLAUDE.md` | 프로젝트 컨텍스트 |
| `SETUP-MACMINI.md` | self-hosted runner 셋업 (지금은 미사용, Ubuntu로 이전) |

---

## 12. 다음 컴퓨터 첫 30분 체크리스트

도착하자마자 순서대로:

```bash
# 1. clone
git clone https://github.com/rbshbomber-bit/touri-app.git
cd touri-app

# 2. Flutter 버전 확인
flutter --version
# Flutter 3.24+ 권장. ^3.5.0 이상이면 OK.

# 3. .env 셋업
cp .env.example .env
nano .env    # ANTHROPIC_API_KEY, FAL_KEY 입력 (필수)
# touri_lora_url.txt도 별도로 받아서 한 줄 저장

# 4. 의존성
flutter pub get

# 5. 기기 확인
flutter devices
# 또는: adb devices

# 6. 실행
flutter run -d chrome              # 가장 빠른 검증
# 또는
flutter run -d <android-device>

# 7. 최근 commit 확인
git log --oneline -5

# 8. GitHub Actions 상태
gh run list --limit 5

# 9. (필요시) 최근 APK 다운로드
gh run download <run-id> -n touri-apk-<sha>
```

체크 사항:
- [ ] `flutter doctor` 모든 항목 ✓
- [ ] `flutter run -d chrome` 정상 띄움
- [ ] 홈 화면에 PetStatusCard 보임 (별가루 토우리)
- [ ] 메뉴 → 다이어리 → 본문 입력 후 ✦ 그려줘 클릭 → 결과 등장
- [ ] `git log -5`에 `b63f774` 또는 이후 commit 보임
- [ ] GitHub Actions 마지막 빌드 초록 ✓

---

## 🆘 막혔을 때

1. **8번 섹션** "자주 막히는 부분" 먼저 확인
2. 관련 .md 문서 (**11번 인덱스**) 참조
3. `git log --all --oneline -20`로 최근 변경 흐름 파악
4. Claude Code에 이 문서 던지고 "현재 상태 진단해줘" 요청
5. 변승환 (rbshbomber@gmail.com)에 카톡

---

_작성: 2026-06-04, 1주 스프린트 종료일_
_현재 main HEAD: `b63f774 feat: 토우리 성장 단계 5장 (별가루→마스터)`_
