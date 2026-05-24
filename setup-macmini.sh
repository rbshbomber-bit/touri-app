#!/usr/bin/env bash
# 🐰 토우리 - 맥미니 빌드 서버 셋업 스크립트
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/<your-username>/touri-app/main/setup-macmini.sh -o setup.sh
#   chmod +x setup.sh
#   ./setup.sh

set -euo pipefail

# ─── 컬러 출력 ──────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
log()    { echo -e "${CYAN}▶${NC} $*"; }
ok()     { echo -e "${GREEN}✓${NC} $*"; }
warn()   { echo -e "${YELLOW}⚠${NC} $*"; }
err()    { echo -e "${RED}✗${NC} $*" >&2; }
section(){ echo; echo -e "${CYAN}━━━ $* ━━━${NC}"; }

# ─── 설정 (필요시 수정) ──────────────────────────────
REPO_OWNER="${REPO_OWNER:-CHANGE_ME}"          # GitHub 사용자명
REPO_NAME="${REPO_NAME:-touri-app}"
PROJECT_DIR="${HOME}/touri-app"

# ─── 사전 검사 ──────────────────────────────────────
section "사전 검사"
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "이 스크립트는 macOS 전용이야"; exit 1
fi
ARCH="$(uname -m)"
ok "macOS $(sw_vers -productVersion) on ${ARCH}"

if [[ "$REPO_OWNER" == "CHANGE_ME" ]]; then
  warn "REPO_OWNER가 설정되지 않았어. 환경변수로 넘기거나 스크립트 상단 수정:"
  warn "  REPO_OWNER=your-github-username ./setup.sh"
  read -r -p "GitHub 사용자명 입력: " REPO_OWNER
  [[ -z "$REPO_OWNER" ]] && { err "사용자명 필요"; exit 1; }
fi

# ─── 1. Xcode CLT ──────────────────────────────────
section "1/8  Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  log "설치 중... GUI 팝업이 뜨면 '설치' 클릭"
  xcode-select --install || true
  warn "설치 완료 후 다시 ./setup.sh 실행해줘"
  exit 0
fi
ok "이미 설치됨: $(xcode-select -p)"

# ─── 2. Homebrew ───────────────────────────────────
section "2/8  Homebrew"
if ! command -v brew &>/dev/null; then
  log "Homebrew 설치 중..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon이면 PATH 등록
  if [[ "$ARCH" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
ok "$(brew --version | head -1)"

# ─── 3. 필수 도구 ──────────────────────────────────
section "3/8  필수 CLI 도구"
BREW_PKGS=(git gh cocoapods tailscale jq tree)
for pkg in "${BREW_PKGS[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    ok "$pkg 이미 설치됨"
  else
    log "$pkg 설치 중..."
    brew install "$pkg"
  fi
done

# ─── 4. Flutter ────────────────────────────────────
section "4/8  Flutter SDK"
if ! command -v flutter &>/dev/null; then
  log "Flutter 설치 중 (brew cask)..."
  brew install --cask flutter
else
  ok "Flutter $(flutter --version | head -1)"
fi
log "flutter doctor 실행..."
flutter doctor || warn "doctor 경고 → Xcode/Android Studio 추가 셋업 필요할 수 있음"

# ─── 5. SSH (원격 접속용) ──────────────────────────
section "5/8  SSH 원격 로그인"
if sudo systemsetup -getremotelogin 2>/dev/null | grep -q "On"; then
  ok "SSH 이미 켜져있음"
else
  log "SSH 활성화 (sudo 비밀번호 필요)"
  sudo systemsetup -setremotelogin on
fi

# ─── 6. 잠자기 방지 ────────────────────────────────
section "6/8  잠자기 방지 (빌드 중 멈춤 방지)"
log "디스플레이는 꺼져도 시스템은 안 자게 설정"
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a powernap 1
ok "pmset 설정 완료"
pmset -g | head -20

# ─── 7. Tailscale ──────────────────────────────────
section "7/8  Tailscale (원격 접속)"
if pgrep -x Tailscale &>/dev/null || pgrep -x tailscaled &>/dev/null; then
  ok "Tailscale 데몬 실행 중"
else
  warn "Tailscale 앱을 실행하고 로그인해줘 (GUI)"
  open -a "Tailscale" 2>/dev/null || open "https://tailscale.com/download/mac"
fi
log "디바이스 이름을 'touri-mac-mini'로 변경:"
echo "  → Tailscale 메뉴바 → 디바이스 이름 → 'touri-mac-mini'"

# ─── 8. Repo Clone ─────────────────────────────────
section "8/8  Repo Clone"
if [[ -d "$PROJECT_DIR/.git" ]]; then
  ok "이미 clone되어 있음: $PROJECT_DIR"
  (cd "$PROJECT_DIR" && git pull --rebase || true)
else
  # gh 로그인 확인
  if ! gh auth status &>/dev/null; then
    log "GitHub 로그인 필요..."
    gh auth login
  fi
  log "Clone 중: ${REPO_OWNER}/${REPO_NAME}"
  gh repo clone "${REPO_OWNER}/${REPO_NAME}" "$PROJECT_DIR"
fi
(cd "$PROJECT_DIR" && flutter pub get || warn "pubspec.yaml 없으면 정상")

# ─── 마무리 ────────────────────────────────────────
section "✅ 셋업 완료"
cat <<EOF

다음 단계:

1. ${YELLOW}Tailscale${NC} 로그인 + 디바이스 이름을 'touri-mac-mini'로 변경

2. ${YELLOW}GitHub Self-Hosted Runner${NC} 등록:
   - https://github.com/${REPO_OWNER}/${REPO_NAME}/settings/actions/runners/new
   - macOS / ARM64 선택
   - 표시되는 명령어를 그대로 복붙 실행
   - 완료 후 백그라운드 자동 실행:
       cd ~/actions-runner
       sudo ./svc.sh install
       sudo ./svc.sh start

3. ${YELLOW}Xcode${NC} 한 번 열어서 Apple ID 로그인 (iOS 빌드용)
       open -a Xcode

4. 첫 빌드 테스트:
   - 맥북에서 'git commit --allow-empty -m "test"' + push
   - GitHub Actions 탭에서 맥미니가 받았는지 확인

iCloud Drive 빌드 출력 폴더는 자동 생성됨:
   ~/Library/Mobile Documents/com~apple~CloudDocs/Touri-Builds/

EOF
ok "🐰 토우리 빌드 서버 준비 완료!"
