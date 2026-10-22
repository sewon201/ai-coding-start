# AI 코딩 시작하기

학교에서 받은 baze 계정으로 Claude Code와 Codex를 쓰도록 안내하는 페이지입니다.

- 안내 페이지: https://sewon201.github.io/ai-coding-start/
- 윈도우 설치: `irm https://raw.githubusercontent.com/sewon201/ai-coding-start/main/setup.ps1 | iex`
- 맥 설치: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sewon201/ai-coding-start/main/setup.sh)"`
- 태블릿: https://codespaces.new/sewon201/ai-coding-start?quickstart=1

## 파일

| 파일 | 하는 일 |
|---|---|
| `index.html` | 안내 페이지 (기기 고르고 한 단계씩) |
| `setup.ps1` | 윈도우: Node.js, Git, Claude Code, Codex, baze 설치 후 `baze login` |
| `setup.sh` | 맥: nvm으로 Node.js, Claude Code, Codex, baze 설치 후 `baze login` (sudo 없음) |
| `.devcontainer/` | 태블릿용 Codespaces. 열리면 세 프로그램이 미리 깔려 있음 |
| `START.md` | Codespaces가 열리면 처음 보이는 안내 |
| `ai-practice/` | Codespaces 터미널이 열리는 연습 폴더 |

## 참고

- baze 연동 문서: https://docs.mindlogic.ai/docs/general/api-gateway/integrations/baze-cli
- 학생 API 키는 각자 계정 크레딧에서 차감됩니다.
