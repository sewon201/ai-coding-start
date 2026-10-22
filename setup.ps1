# AI 코딩 시작하기 - 윈도우 설치 스크립트
# 사용법: PowerShell에서  irm https://raw.githubusercontent.com/sewon201/ai-coding-start/main/setup.ps1 | iex
# 설치하는 것: Node.js LTS, Git, Claude Code, Codex, baze CLI  (이미 있으면 건너뜀)

& {
  $ErrorActionPreference = 'Continue'
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  function Say($msg)  { Write-Host "`n>> $msg" -ForegroundColor Cyan }
  function Ok($msg)   { Write-Host "   $msg" -ForegroundColor Green }
  function Warn($msg) { Write-Host "   $msg" -ForegroundColor Yellow }
  function Fail($msg) { Write-Host "`n   $msg" -ForegroundColor Red; Write-Host "   이 화면을 캡처해서 선생님한테 보내주세요.`n" -ForegroundColor Red }
  function Has($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }
  function RefreshPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
    $npmDir = Join-Path $env:APPDATA 'npm'
    if ($env:Path -notlike "*$npmDir*") { $env:Path += ";$npmDir" }
  }
  function WingetInstall($id, $label) {
    if (-not (Has 'winget')) {
      Fail "winget이 없어서 $label 을(를) 설치할 수 없어요. Microsoft Store에서 '앱 설치 관리자'를 업데이트하고 다시 해보세요."
      return $false
    }
    Warn "$label 설치 중... '디바이스를 변경하도록 허용' 창이 뜨면 [예]를 눌러주세요."
    winget install --id $id -e --source winget --accept-source-agreements --accept-package-agreements --silent | Out-Host
    RefreshPath
    return $true
  }

  Write-Host ""
  Write-Host "==============================================" -ForegroundColor White
  Write-Host "  AI 코딩 시작하기 - 설치를 시작할게요" -ForegroundColor White
  Write-Host "  다 끝날 때까지 이 창을 닫지 마세요 (5~10분)" -ForegroundColor White
  Write-Host "==============================================" -ForegroundColor White

  # 1. 스크립트 실행 허용 (npm, baze 명령이 막히지 않게)
  Say "1/5  실행 권한 확인"
  $policy = Get-ExecutionPolicy -Scope CurrentUser
  if ($policy -in @('Undefined','Restricted','AllSigned')) {
    try {
      Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force -ErrorAction Stop
      Ok "실행 권한을 RemoteSigned로 바꿨어요."
    } catch {
      Warn "실행 권한을 못 바꿨어요. 학교/회사 정책일 수 있어요. 일단 계속할게요."
    }
  } else {
    Ok "괜찮아요 ($policy)."
  }

  # 2. Node.js
  Say "2/5  Node.js 확인"
  RefreshPath
  $needNode = $true
  if (Has 'node') {
    $major = [int]((node -v) -replace '^v(\d+).*','$1')
    if ($major -ge 20) { $needNode = $false; Ok "이미 있어요 ($(node -v))." }
    else { Warn "Node.js 버전이 너무 낮아요 ($(node -v)). 새로 설치할게요." }
  }
  if ($needNode) {
    if (-not (WingetInstall 'OpenJS.NodeJS.LTS' 'Node.js')) { return }
    if (-not (Has 'node')) { Fail "Node.js 설치가 안 된 것 같아요. https://nodejs.org/ko 에서 LTS 버전을 직접 설치한 뒤 이 명령어를 다시 붙여넣어 주세요."; return }
    Ok "Node.js 설치 완료 ($(node -v))."
  }

  # 3. Git (Claude Code, Codex가 쓰면 좋아요. 실패해도 계속)
  Say "3/5  Git 확인"
  if (Has 'git') { Ok "이미 있어요." }
  else {
    [void](WingetInstall 'Git.Git' 'Git')
    if (Has 'git') { Ok "Git 설치 완료." } else { Warn "Git은 못 깔았지만 없어도 쓸 수는 있어요. 계속할게요." }
  }

  # 4. Claude Code, Codex, baze
  Say "4/5  Claude Code, Codex, baze 설치 (여기가 제일 오래 걸려요)"
  npm.cmd install -g @anthropic-ai/claude-code @openai/codex @mindlogic-ai/baze --no-fund --no-audit | Out-Host
  if ($LASTEXITCODE -ne 0) {
    Fail "설치 중에 문제가 생겼어요. 학교 와이파이라면 휴대폰 핫스팟으로 바꿔서 다시 해보세요."
    return
  }
  RefreshPath
  if (-not (Has 'baze.cmd')) { Fail "설치는 끝났는데 baze를 못 찾겠어요. PowerShell 창을 닫았다가 새로 열고 이 명령어를 다시 붙여넣어 주세요."; return }
  Ok "설치 완료."

  # 5. baze 키 등록
  Say "5/5  baze API 키 등록"
  if ($env:BAZE_API_KEY -or (Test-Path (Join-Path $HOME '.baze\credentials.json'))) {
    Ok "이미 키가 등록돼 있어요. 키를 바꾸고 싶으면 나중에 'baze login'을 치면 돼요."
  } else {
    Write-Host "   곧 baze가 API 키를 물어봐요. 그 줄이 나오면 메모장의 키를 붙여넣고 Enter." -ForegroundColor White
    Write-Host "   (마우스 오른쪽 클릭 = 붙여넣기)" -ForegroundColor White
    baze.cmd login
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $HOME '.baze\credentials.json'))) {
      Fail "키 등록이 안 됐어요. 'baze login'을 치고, 키를 묻는 줄이 나오면 그때 키를 붙여넣어 주세요."
      return
    }
    Ok "키 등록 완료."
  }

  Write-Host ""
  Write-Host "==============================================" -ForegroundColor Green
  Write-Host "  다 끝났어요!" -ForegroundColor Green
  Write-Host "  이 PowerShell 창을 닫고, 새로 열어서" -ForegroundColor Green
  Write-Host "  안내 페이지의 다음 단계로 가세요." -ForegroundColor Green
  Write-Host "==============================================" -ForegroundColor Green
  Write-Host ""
}
