# 🐰 토우리 (Touri)

> 어디서든 코딩 → `git push` → 맥미니가 자동으로 APK/웹/iOS 빌드

## 📦 프로젝트 구조

```
touri-app/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions → 맥미니 self-hosted runner
├── lib/                       # Flutter 앱 코드 (flutter create 이후 생성)
├── assets/                    # 이미지, 폰트, 3D 모델 등
├── android/                   # Android 네이티브 (flutter create 이후 생성)
├── ios/                       # iOS 네이티브 (flutter create 이후 생성)
├── web/                       # 웹 빌드 산출물
├── setup-macmini.sh           # 맥미니 빌드 서버 초기 셋업 스크립트
├── pubspec.yaml               # Flutter 의존성
├── .gitignore
├── .env.example               # 환경변수 템플릿 (.env는 커밋 금지)
└── README.md
```

## 🚀 빠른 시작 (맥북 / 메인 개발 기기)

이미 셋업되어 있다면 일상 워크플로우는:

```bash
git pull                                # 최신 가져오기
# ... 코드 작성 ...
git add .
git commit -m "feat: 새 기능"
git push                                # → 맥미니가 자동 빌드 시작
```

## 🛠️ 첫 셋업 (한 번만)

### 0. 사전 준비
- Flutter SDK 설치 (`brew install --cask flutter` 또는 공식 설치 가이드)
- `gh` (GitHub CLI) 로그인 확인: `gh auth status`

### 1. Flutter 프로젝트 초기화 (이 폴더에서)
```bash
cd ~/Documents/Claude/Projects/touri-app
flutter create . --org com.touri --project-name touri
flutter pub get
```

### 2. 첫 커밋 + GitHub Push
```bash
git add .
git commit -m "feat: Flutter 초기 스캐폴딩 + 빌드 워크플로우"
git push -u origin main
```

### 3. 맥미니 셋업 (맥미니 터미널에서 한 번)
자세한 가이드는 [`SETUP-MACMINI.md`](./SETUP-MACMINI.md) 참조.

```bash
curl -fsSL https://raw.githubusercontent.com/<your-username>/touri-app/main/setup-macmini.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

### 4. GitHub Actions Self-Hosted Runner 등록
1. GitHub repo → Settings → Actions → Runners → **New self-hosted runner**
2. macOS / ARM64 선택
3. 표시되는 명령어를 맥미니 터미널에 그대로 복붙
4. 백그라운드 자동 실행 등록:
   ```bash
   cd ~/actions-runner
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

## 🔐 필요한 Secrets

`GitHub repo → Settings → Secrets and variables → Actions` 에 등록:

| 이름 | 용도 | 받는 곳 |
|------|------|---------|
| `ANTHROPIC_API_KEY` | AI 챗봇 | https://console.anthropic.com |
| `SUPABASE_URL` | 백엔드 | https://supabase.com |
| `SUPABASE_ANON_KEY` | 백엔드 | Supabase 프로젝트 설정 |
| `MESHY_API_KEY` | 3D 변환(선택) | https://meshy.ai/settings |
| `VERCEL_TOKEN` | 웹 자동 배포(선택) | https://vercel.com/account/tokens |
| `FIREBASE_TOKEN` | APK 자동 배포(선택) | `firebase login:ci` |
| `FIREBASE_APP_ID` | Firebase App ID(선택) | Firebase Console |

## 🔄 맥북 ↔ 맥미니 동시 작업 팁

두 기기 모두 같은 repo를 보기 때문에 **항상 `git pull` 먼저, `git push` 후 알리기**.

```bash
# 작업 시작 전 (어느 기기든)
git pull --rebase

# 충돌 방지를 위해 작은 단위로 커밋
git add . && git commit -m "..."
git push
```

원격 협업이 필요하면:
- **Tailscale**로 맥미니에 SSH 접속해서 직접 작업
- **VSCode Remote-SSH**로 맥미니 폴더 열기
- iPhone/iPad: **Working Copy**(git) + **Termius**(SSH)

## 📅 다음 단계

- [ ] Flutter 초기 스캐폴딩 (`flutter create .`)
- [ ] 맥미니 셋업 스크립트 실행
- [ ] Self-hosted runner 등록
- [ ] Vercel 가입 + 웹 도메인 (`touri.app`)
- [ ] Firebase App Distribution 셋업
- [ ] Apple Developer Program ($99/년)
- [ ] Google Play Console ($25 일회성)

---
🐰 _마지막 업데이트: 2026-05-24_
