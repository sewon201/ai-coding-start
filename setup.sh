#!/bin/bash
# AI 코딩 시작하기 - 맥 설치 스크립트
# 사용법: 터미널에서  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sewon201/ai-coding-start/main/setup.sh)"
# 설치하는 것: Node.js LTS(nvm), Claude Code, Codex, baze CLI  (이미 있으면 건너뜀)
# 관리자 비밀번호(sudo)는 쓰지 않아요.

NVM_VERSION="v0.40.3"

say()  { printf "\n\033[36m>> %s\033[0m\n" "$1"; }
ok()   { printf "   \033[32m%s\033[0m\n" "$1"; }
warn() { printf "   \033[33m%s\033[0m\n" "$1"; }
fail() { printf "\n   \033[31m%s\033[0m\n   \033[31m이 화면을 캡처해서 선생님한테 보내주세요.\033[0m\n\n" "$1"; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

echo ""
echo "=============================================="
echo "  AI 코딩 시작하기 - 설치를 시작할게요"
echo "  다 끝날 때까지 터미널을 닫지 마세요 (5~10분)"
echo "=============================================="

# 1. Node.js
say "1/3  Node.js 확인"
use_nvm=1
if has node; then
  major=$(node -v | sed -E 's/^v([0-9]+).*/\1/')
  prefix=$(npm prefix -g 2>/dev/null)
  if [ "$major" -ge 20 ] && [ -w "$prefix/lib" ] 2>/dev/null; then
    use_nvm=0
    ok "이미 있어요 ($(node -v))."
  else
    warn "지금 있는 Node.js는 그대로 두고, 내 계정 전용으로 하나 더 설치할게요."
  fi
fi

if [ "$use_nvm" = 1 ]; then
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    touch "$HOME/.zshrc"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" \
      | METHOD=script PROFILE="$HOME/.zshrc" bash \
      || fail "nvm 설치에 실패했어요. 학교 와이파이라면 휴대폰 핫스팟으로 바꿔서 다시 해보세요."
    # bash를 쓰는 맥도 있어서 같이 적어둬요
    if [ -f "$HOME/.bash_profile" ] && ! grep -q 'NVM_DIR' "$HOME/.bash_profile"; then
      printf '\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n' >> "$HOME/.bash_profile"
    fi
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh" || fail "nvm을 불러오지 못했어요."
  nvm install --lts || fail "Node.js 설치에 실패했어요."
  nvm alias default 'lts/*' >/dev/null
  nvm use default >/dev/null
  ok "Node.js 설치 완료 ($(node -v))."
fi

# 2. Claude Code, Codex, baze
say "2/3  Claude Code, Codex, baze 설치 (여기가 제일 오래 걸려요)"
npm install -g @anthropic-ai/claude-code @openai/codex @mindlogic-ai/baze --no-fund --no-audit \
  || fail "설치 중에 문제가 생겼어요. 앞에 sudo를 붙이지 말고, 학교 와이파이라면 핫스팟으로 바꿔서 다시 해보세요."
has baze || fail "설치는 끝났는데 baze를 못 찾겠어요. 터미널을 command + Q로 끄고 다시 연 다음 이 명령어를 다시 붙여넣어 주세요."
ok "설치 완료."

# 3. baze 키 등록
say "3/3  baze API 키 등록"
if [ -n "$BAZE_API_KEY" ] || [ -f "$HOME/.baze/credentials.json" ]; then
  ok "이미 키가 등록돼 있어요. 키를 바꾸고 싶으면 나중에 'baze login'을 치면 돼요."
else
  echo "   곧 baze가 API 키를 물어봐요. 그 줄이 나오면 메모장의 키를 붙여넣고(command + V) Enter."
  baze login && [ -f "$HOME/.baze/credentials.json" ] \
    || fail "키 등록이 안 됐어요. 'baze login'을 치고, 키를 묻는 줄이 나오면 그때 키를 붙여넣어 주세요."
  ok "키 등록 완료."
fi

echo ""
printf "\033[32m==============================================\n"
printf "  다 끝났어요!\n"
printf "  터미널을 command + Q로 완전히 끄고 다시 열어서\n"
printf "  안내 페이지의 다음 단계로 가세요.\n"
printf "==============================================\033[0m\n\n"
