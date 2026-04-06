# KillSnail

KillSnail은 macOS 메뉴바에서 조용히 실행되다가, 화면 어딘가에서 아주 느리게 마우스를 추격하는 AppKit 기반 장난감 앱입니다. 달팽이가 결국 커서에 닿으면 화면에 거대한 빨간 **YOU DEAD** 오버레이가 나타나고, 리셋으로 다시 게임을 시작할 수 있습니다.

## 프로젝트 개요

- **문제/목표**: 가벼운 macOS status bar 앱으로 “느리지만 결국 따라오는 달팽이” 경험을 만든다.
- **핵심 경험**:
  - 메뉴바에 상주한다.
  - 달팽이는 현재 마우스가 있는 화면의 반대편에서 시작한다.
  - 달팽이는 매우 느린 속도로 커서를 향해 움직인다.
  - 닿는 순간 빨간 `YOU DEAD` 텍스트가 커졌다 작아졌다 하며 나타난다.
  - `리셋`으로 즉시 재시작할 수 있다.

## 기술 스택

- Swift 5.10 / Swift 6.2 toolchain compatible
- AppKit
- Swift Package Manager (코어 로직 검증용)
- XcodeGen
- xcodebuild
- GitHub Actions
- create-dmg

## 요구 환경

- macOS 14 이상 권장
- Xcode 15 이상
- Homebrew (로컬 개발 및 CI 스크립트 재현용)

## 빠른 다운로드 방법

### 1) GitHub Releases에서 DMG 받기

1. [Releases](https://github.com/bssm-oss/killsnail/releases) 페이지로 이동합니다.
2. 최신 버전의 `KillSnail-vX.Y.Z.dmg` 파일을 다운로드합니다.
3. DMG를 열고 `KillSnail.app`을 Applications 폴더로 드래그합니다.
4. 서명/공증이 없는 초기 릴리즈에서는 Gatekeeper 경고가 뜰 수 있습니다.
   - Finder에서 앱을 우클릭 → `열기`
   - 또는 시스템 설정의 보안 경고에서 허용

### 2) Homebrew Cask로 설치하기

첫 릴리즈 이후에는 아래 방식으로 설치할 수 있습니다.

```bash
brew tap bssm-oss/killsnail https://github.com/bssm-oss/killsnail
brew install --cask killsnail
```

> 참고: Homebrew 설치 역시 초기 unsigned 릴리즈에서는 macOS 보안 경고를 완전히 없애주지 않습니다.

## 로컬 실행 방법

```bash
brew install xcodegen create-dmg
xcodegen generate
xcodebuild -project KillSnail.xcodeproj -scheme KillSnail CODE_SIGNING_ALLOWED=NO build
open .build/DerivedData/Build/Products/Debug/KillSnail.app
```

앱을 실행하면 메뉴바에 `🐌` 아이콘이 생깁니다.

## 테스트 실행 방법

```bash
xcodegen generate
xcodebuild -project KillSnail.xcodeproj -scheme KillSnail -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

전체 Xcode 앱 빌드를 바로 돌리기 어려운 환경에서는 코어 로직만 아래처럼 검증할 수 있습니다.

```bash
swift test
```

## 주요 스크립트

- `python3 scripts/read_version.py`: `project.yml`의 마케팅 버전 읽기
- `scripts/build_dmg.sh <version>`: Release 앱 빌드 + ZIP + DMG 생성
- `scripts/update_cask.sh <version> <sha256>`: Homebrew cask 버전과 체크섬 갱신

## 폴더 구조

```text
KillSnailApp/        AppKit 앱 진입점, 메뉴바, 윈도우/오버레이 UI
KillSnailCore/       순수 Swift 게임 규칙, 이동/충돌/리셋 로직
KillSnailTests/      코어 회귀 테스트
Casks/               Homebrew cask 정의
scripts/             빌드/릴리즈 보조 스크립트
docs/                변경 이력, 아키텍처, 테스트 문서
.github/workflows/   CI 및 릴리즈 자동화
```

## 아키텍처 개요

KillSnail은 세 층으로 나뉩니다.

1. **AppKit Shell**
   - `NSStatusItem` 기반 메뉴바 앱
   - 달팽이 윈도우 / 사망 오버레이 윈도우 관리
2. **Core Logic**
   - 시작 위치 계산
   - 느린 추격 이동
   - 충돌 판정
   - `idle / chasing / paused / dead` 상태 전이
3. **Release Surface**
   - GitHub Actions CI
   - 태그 기반 Release 생성
   - DMG 업로드
   - Homebrew cask 업데이트

자세한 내용은 [docs/architecture/app-overview.md](docs/architecture/app-overview.md)를 참고하세요.

## 핵심 사용자 흐름

1. 앱 실행
2. 메뉴바에 `🐌` 생성
3. 달팽이가 커서 반대편에서 등장
4. 천천히 커서를 추격
5. 충돌 시 `YOU DEAD` 오버레이 출력
6. `리셋` 또는 메뉴바 액션으로 재시작

## 개발 원칙

- AppKit 셸은 얇게 유지한다.
- 게임 규칙은 순수 Swift 코어에 둔다.
- 자동화보다 먼저 재현 가능성을 확보한다.
- 릴리즈 자동화는 태그를 기준으로 동작한다.
- 문서는 코드와 함께 업데이트한다.

## CI 개요

- `CI`: push / pull_request 에서 Xcode 프로젝트 생성 후 테스트 실행
- `Release`: `v*` 태그 push 시 테스트 → DMG/ZIP 생성 → GitHub Release 업로드 → cask 업데이트

## 알려진 제한 사항

- 초기 릴리즈는 **unsigned / not notarized** 상태일 수 있습니다.
- 따라서 다운로드 후 Gatekeeper 경고가 발생할 수 있습니다.
- 멀티 모니터에서는 커서가 이동한 화면을 기준으로 달팽이가 다시 배치됩니다.
- 앱은 재미용 유틸리티이며 자동 업데이트 기능은 아직 없습니다.

## 향후 계획 / 로드맵

- Developer ID 서명 / notarization 추가
- 다중 모니터 전환 효과 다듬기
- 애니메이션/사운드 리소스 개선
- 릴리즈 노트 자동화 개선

## 기여 방법

1. 브랜치 생성: `feat/...`, `fix/...`, `docs/...`
2. `xcodegen generate`
3. `xcodebuild ... test`
4. 문서 업데이트
5. PR 생성

자세한 작업 규칙은 [AGENTS.md](AGENTS.md)를 참고하세요.
