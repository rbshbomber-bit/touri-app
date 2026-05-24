# 🖥️ 맥미니 빌드 서버 셋업 가이드

> 한 번만 하면 끝. 이후엔 맥북에서 `git push`만 하면 맥미니가 알아서 빌드.

## ⚙️ 1단계 — 맥미니에서 setup-macmini.sh 실행

맥미니 터미널에서 (이 repo가 GitHub에 push된 후):

```bash
# (방법 A) GitHub에서 바로 받기
REPO_OWNER=<your-github-username>
curl -fsSL "https://raw.githubusercontent.com/${REPO_OWNER}/touri-app/main/setup-macmini.sh" -o setup.sh
chmod +x setup.sh
REPO_OWNER="$REPO_OWNER" ./setup.sh

# (방법 B) 이미 USB/AirDrop 등으로 옮긴 경우
chmod +x setup-macmini.sh
REPO_OWNER=<your-github-username> ./setup-macmini.sh
```

스크립트가 자동으로 처리:
1. Xcode CLT
2. Homebrew
3. git, gh, cocoapods, tailscale 등
4. Flutter SDK
5. SSH 원격 로그인 활성화
6. 잠자기 방지 (`pmset`)
7. Tailscale 안내
8. Repo clone → `~/touri-app`

## 🏃 2단계 — GitHub Self-Hosted Runner 등록

이게 핵심. 맥미니가 GitHub의 "워커"로 등록되어, push 발생 시 자동으로 일감을 받음.

1. 브라우저에서: `https://github.com/<your-username>/touri-app/settings/actions/runners/new`
2. **macOS / ARM64** 선택
3. GitHub이 보여주는 명령어를 맥미니에 그대로 복붙. 대략 이런 모양:

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-osx-arm64-2.X.X.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.X.X/actions-runner-osx-arm64-2.X.X.tar.gz
tar xzf ./actions-runner-osx-arm64-2.X.X.tar.gz

./config.sh --url https://github.com/<your-username>/touri-app --token AXXXXXX
# 질문들:
#   runner group: Default (엔터)
#   runner name: touri-macmini (또는 그냥 엔터)
#   labels: 엔터 (기본 macOS, ARM64 자동 부여)
#   work folder: _work (엔터)
```

4. **백그라운드 데몬으로 등록** (재부팅해도 자동 실행):

```bash
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status     # ← "started" 표시되어야 함
```

5. GitHub repo → Settings → Actions → Runners 에서 **"Idle"** 상태 확인 ✓

## 🍎 3단계 — Xcode 1회 셋업 (iOS 빌드용)

iOS 빌드 안 할 거면 스킵.

```bash
# 맥미니 GUI 환경에서
open -a Xcode

# Xcode 첫 실행 → 라이센스 동의 → 추가 컴포넌트 설치
# Preferences → Accounts → '+' → Apple ID 로그인
# Preferences → Locations → Command Line Tools 선택 확인
```

iOS 빌드 워크플로우 활성화하려면:
- GitHub repo → Settings → Variables → New repository variable
- Name: `IOS_BUILD_ENABLED`, Value: `true`

## 🔔 4단계 — Secrets 등록

`GitHub repo → Settings → Secrets and variables → Actions → New repository secret`

필수:
- `ANTHROPIC_API_KEY`
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`

선택:
- `VERCEL_TOKEN` — 웹 자동 배포
- `FIREBASE_TOKEN`, `FIREBASE_APP_ID` — APK 자동 배포
- `MESHY_API_KEY` — 3D 변환
- `SLACK_WEBHOOK` — 빌드 완료 알림

## ✅ 5단계 — 첫 빌드 테스트

맥북에서:
```bash
cd ~/Documents/Claude/Projects/touri-app
git commit --allow-empty -m "ci: 첫 빌드 테스트"
git push
```

브라우저에서:
- `https://github.com/<your-username>/touri-app/actions`
- 워크플로우가 "queued" → "in progress" → "success" 흐름이면 성공 🎉

맥미니에서 결과 확인:
```bash
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Touri-Builds/
```

## 🛠️ 트러블슈팅

### Runner가 "Offline"
```bash
cd ~/actions-runner
sudo ./svc.sh stop && sudo ./svc.sh start
sudo ./svc.sh status
```

### iOS 빌드 실패 (코드사인)
- Xcode에서 `ios/Runner.xcworkspace` 열고
- Signing & Capabilities → Team 선택
- 첫 빌드는 GUI에서 한 번 수동으로 (Provisioning Profile 생성)

### 맥미니 발열 / 빌드 너무 자주 돔
- `.github/workflows/build.yml`의 `paths:` 필터로 제한 (이미 적용됨)
- 또는 `[ci skip]` 을 커밋 메시지에 넣으면 빌드 안 함

### Tailscale 안 됨
- 양쪽 기기 모두 같은 계정으로 로그인했는지 확인
- 맥미니 디바이스 이름이 `touri-mac-mini` 인지 확인
- 맥북에서: `ping touri-mac-mini` 로 통신 확인

## 🔄 일상 워크플로우 요약

```
[맥북]                          [맥미니]
git pull                        ← 항상 동기화
... 코드 작성 ...
git add .
git commit -m "feat: ..."
git push  ─────────────────→    GitHub Actions 자동 트리거
                                ↓
                                flutter build apk/web
                                ↓
                                iCloud Drive에 APK 저장
                                ↓
                                (Slack/Firebase 알림)
```

맥미니에서 직접 작업할 일 거의 없음. 다만:
- **GUI 작업이 필요할 때만** (Xcode 첫 셋업, Tailscale 로그인 등)
- **로그 확인**: `cd ~/actions-runner && tail -f _diag/Runner_*.log`
