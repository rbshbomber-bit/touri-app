#!/usr/bin/env bash
# 🐰 토우리 - 맥북에서 한 번에: git init + Flutter scaffolding + GitHub push
# 사용법:
#   cd ~/Documents/Claude/Projects/touri-app
#   chmod +x init-and-push.sh
#   ./init-and-push.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()      { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
err()     { echo -e "${RED}✗${NC} $*" >&2; }
section() { echo; echo -e "${CYAN}━━━ $* ━━━${NC}"; }

# ─── 사전 점검 ─────────────────────────────────────
section "사전 점검"
for cmd in git gh; do
  if ! command -v "$cmd" &>/dev/null; then
    err "$cmd 가 설치 안 됨"
    echo "  → brew install $cmd"
    exit 1
  fi
done
ok "git, gh 설치 확인"

if ! gh auth status &>/dev/null; then
  warn "gh 로그인 안 됨 → 로그인 진행"
  gh auth login
fi
GH_USER="$(gh api user --jq .login)"
ok "GitHub 로그인: $GH_USER"

# ─── Flutter scaffolding (선택) ────────────────────
section "Flutter 프로젝트 초기화"
if [[ -f "pubspec.yaml" ]]; then
  ok "이미 Flutter 프로젝트 존재 (pubspec.yaml 발견) → 스킵"
else
  if command -v flutter &>/dev/null; then
    read -r -p "Flutter create 실행할까? [Y/n] " ANSWER
    if [[ "${ANSWER:-Y}" =~ ^[Yy]$ ]]; then
      flutter create . --org com.touri --project-name touri \
        --platforms=android,ios,web
      ok "Flutter scaffolding 완료"
    else
      warn "스킵 — 나중에 'flutter create .' 직접 실행"
    fi
  else
    warn "flutter 미설치 → 스킵 (나중에 'brew install --cask flutter' 후 'flutter create .')"
  fi
fi

# ─── git 초기화 ───────────────────────────────────
section "git 초기화"
if [[ -d ".git" ]]; then
  ok "이미 git repo (.git 폴더 존재)"
else
  git init -b main
  ok "git init (branch: main)"
fi

# Git 사용자 설정 확인
if [[ -z "$(git config user.name || true)" ]]; then
  read -r -p "git user.name: " GIT_NAME
  git config user.name "$GIT_NAME"
fi
if [[ -z "$(git config user.email || true)" ]]; then
  read -r -p "git user.email: " GIT_EMAIL
  git config user.email "$GIT_EMAIL"
fi
ok "git user: $(git config user.name) <$(git config user.email)>"

# ─── 첫 커밋 ──────────────────────────────────────
section "스테이징 + 첫 커밋"
git add .
if git diff --cached --quiet; then
  warn "스테이징된 변경사항 없음 → 커밋 스킵"
else
  git commit -m "init: 토우리 v0.1 첫 커밋 🐰

- Flutter 프로젝트 초기 스캐폴딩
- GitHub Actions 워크플로우 (web/android/ios)
- 맥미니 셋업 스크립트
- .gitignore, .env.example, README"
  ok "첫 커밋 완료"
fi

# ─── GitHub repo 생성 + push ──────────────────────
section "GitHub repo 생성 + push"
if git remote get-url origin &>/dev/null; then
  ok "origin 리모트 이미 설정됨: $(git remote get-url origin)"
  git push -u origin main || warn "push 실패 → 수동으로 확인"
else
  REPO_NAME="touri-app"
  if gh repo view "${GH_USER}/${REPO_NAME}" &>/dev/null; then
    warn "GitHub에 ${GH_USER}/${REPO_NAME} 이미 존재 → 연결만"
    git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
    git push -u origin main
  else
    gh repo create "$REPO_NAME" --private --source=. --remote=origin --push \
      --description "🐰 토우리 - Flutter 앱"
    ok "GitHub private repo 생성 + push 완료"
  fi
fi

# ─── 마무리 ───────────────────────────────────────
section "✅ 완료"
REPO_URL="https://github.com/${GH_USER}/touri-app"
cat <<EOF

🎉 Repo가 GitHub에 올라갔어!
   ${REPO_URL}

📋 다음 단계:

1. 맥미니에서 셋업:
   ${YELLOW}curl -fsSL ${REPO_URL}/raw/main/setup-macmini.sh -o setup.sh${NC}
   ${YELLOW}chmod +x setup.sh${NC}
   ${YELLOW}REPO_OWNER=${GH_USER} ./setup.sh${NC}

2. Self-Hosted Runner 등록:
   ${REPO_URL}/settings/actions/runners/new

3. Secrets 등록:
   ${REPO_URL}/settings/secrets/actions

자세한 가이드: SETUP-MACMINI.md
EOF
ok "🐰"
