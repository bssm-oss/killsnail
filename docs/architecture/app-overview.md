# KillSnail 아키텍처 개요

## 배경

KillSnail은 “마우스를 느리게 추격하는 메뉴바 달팽이”라는 단순한 아이디어를 갖고 있지만, 실제 구현은 전역 커서 좌표, AppKit 오버레이 윈도우, 릴리즈 패키징까지 포함합니다. 그래서 앱 셸과 게임 규칙을 분리한 구조가 필요합니다.

## 구조

### 1. AppKit Shell (`KillSnailApp`)

- `AppDelegate`: 앱 생명주기 진입점
- `StatusItemController`: 메뉴바 아이콘과 메뉴 액션
- `GameCoordinator`: AppKit과 코어 로직 사이의 조정 계층
- `SnailWindowController`: 떠다니는 달팽이 윈도우
- `DeathOverlayWindowController`: `YOU DEAD` 전체 화면 오버레이

### 2. Core (`KillSnailCore`)

- `SnailConfiguration`: 속도, 충돌 반경, 업데이트 주기
- `SnailGameEngine`: 시작/업데이트/사망/리셋 규칙
- `DesktopRect`, `DesktopPoint`: 순수 좌표 모델
- `GameSnapshot`: UI에 전달하는 읽기 전용 상태

### 3. Release Surface

- `project.yml`: XcodeGen 기반 프로젝트 정의
- `scripts/build_dmg.sh`: Release 빌드 + DMG/ZIP 생성
- `Casks/killsnail.rb`: Homebrew cask
- `.github/workflows/`: CI 및 태그 기반 릴리즈 자동화

## 설계 이유

- AppKit은 메뉴바 앱과 투명 borderless 윈도우 제어에 적합합니다.
- Core를 분리하면 이동/충돌/리셋을 XCTest로 검증할 수 있습니다.
- XcodeGen을 사용하면 빈 저장소에서도 재현 가능한 프로젝트 구성이 가능합니다.

## 상태 전이

KillSnail은 아래 상태를 사용합니다.

- `idle`: 아직 시작되지 않음
- `chasing`: 느린 추격 중
- `paused`: 일시정지
- `dead`: 충돌 이후 오버레이 출력 중

리셋은 부분 수정이 아니라 새 chase 세션 재생성으로 처리합니다. 이 방식이 상태 꼬임을 줄여 줍니다.

## 화면/좌표 처리

- 커서는 `NSEvent.mouseLocation`으로 읽습니다.
- 현재 커서가 속한 `NSScreen`의 `visibleFrame`을 기준으로 달팽이 활동 영역을 정합니다.
- 시작 위치는 현재 커서 좌표를 기준으로 화면 중심 대칭점에 가깝게 계산합니다.

## 릴리즈 전략

- 버전의 기준은 `project.yml`의 `MARKETING_VERSION`
- 릴리즈 트리거는 `vX.Y.Z` 태그 push
- 결과물은 GitHub Releases의 DMG/ZIP
- Homebrew는 formula가 아니라 **cask** 사용
- 서명/공증은 후속 단계로 분리
