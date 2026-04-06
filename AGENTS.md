# AGENTS.md

## 프로젝트 목적

KillSnail은 macOS 메뉴바에서 실행되는 AppKit 기반 장난감 앱입니다. 앱은 달팽이 이모지 기반 추격 오버레이를 띄우고, 마우스를 천천히 따라오다가 충돌 시 `YOU DEAD` 효과를 보여줍니다.

## 빠른 시작 명령

```bash
brew install xcodegen create-dmg
xcodegen generate
xcodebuild -project KillSnail.xcodeproj -scheme KillSnail -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

## 설치 / 실행 / 테스트 명령

### 프로젝트 생성

```bash
xcodegen generate
```

### Debug 빌드

```bash
xcodebuild -project KillSnail.xcodeproj -scheme KillSnail CODE_SIGNING_ALLOWED=NO build
```

### 테스트

```bash
xcodebuild -project KillSnail.xcodeproj -scheme KillSnail -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

### 코어 로직 빠른 검증

```bash
swift test
```

### DMG 생성

```bash
scripts/build_dmg.sh 0.1.0
```

## 기본 작업 순서

1. 저장소 현실 파악
2. 관련 문서 확인 (`README.md`, `AGENTS.md`, `docs/`)
3. `xcodegen generate`
4. 변경 작업 수행
5. 테스트 실행
6. 문서 갱신
7. 필요 시 DMG/릴리즈 경로 검증

## 완료 조건

- 기능 변경이 코드와 문서에 모두 반영됨
- `xcodebuild ... test` 실행 결과가 확인됨
- 빌드 또는 DMG 검증 결과가 남아 있음
- README / AGENTS / docs 가 일치함
- 릴리즈 관련 변경이면 workflow / cask / script 가 함께 갱신됨

## 코드 스타일 원칙

- AppKit 셸은 얇게 유지하고, 게임 규칙은 `KillSnailCore`에 둡니다.
- UI 코드에서 좌표/충돌/속도 규칙을 직접 구현하지 않습니다.
- 상태 전이는 명시적 enum 으로 관리합니다.
- 임시 플래그보다 작은 순수 함수와 테스트 가능한 타입을 우선합니다.

## 파일 구조 원칙

- `KillSnailApp/`: AppKit, 메뉴바, 윈도우, 오버레이
- `KillSnailCore/`: 순수 Swift 로직
- `KillSnailTests/`: 코어 테스트
- `scripts/`: 빌드/배포 스크립트
- `Casks/`: Homebrew cask
- `docs/`: 변경/아키텍처/테스트 문서

## 문서화 원칙

- 기능 의미가 바뀌면 `README.md` 또는 `docs/changes/`를 갱신합니다.
- 아키텍처 판단이 바뀌면 `docs/architecture/`를 갱신합니다.
- 테스트 전략이 바뀌면 `docs/testing/`를 갱신합니다.
- 버전 태깅/릴리즈 자동화가 바뀌면 `.github/workflows/`와 관련 문서를 함께 갱신합니다.

## 테스트 원칙

- 코어 로직은 반드시 XCTest로 보호합니다.
- UI는 수동 검증 결과를 함께 남깁니다.
- 서명/공증이 없는 릴리즈는 그 사실을 문서에 숨기지 않습니다.

## 브랜치 / 커밋 / PR 규칙

- 브랜치: `feat/...`, `fix/...`, `docs/...`, `ci/...`
- 커밋: 기능/테스트/문서/CI를 가능하면 분리
- PR 본문에는 배경, 변경 요약, 테스트 결과, 수동 검증, 문서 반영, 리스크 포함

## 민감한 경로 / 수정 주의 경로

- `.github/workflows/`: 릴리즈 자동화가 걸려 있으므로 신중히 수정
- `Casks/killsnail.rb`: 실제 배포 URL/체크섬 반영 경로
- `project.yml`: 버전, 번들 ID, 타깃 구조의 기준

## 작업 전 체크리스트

- [ ] 현재 브랜치가 main이 아님
- [ ] `README.md`, `AGENTS.md`, `docs/` 확인
- [ ] 변경 범위와 테스트 범위 정의
- [ ] 릴리즈 영향 여부 확인

## 작업 후 체크리스트

- [ ] `xcodegen generate`
- [ ] `xcodebuild ... test`
- [ ] 문서 갱신
- [ ] 필요 시 `scripts/build_dmg.sh` 검증
- [ ] git diff 검토

## 절대 하면 안 되는 것

- 실행하지 않은 테스트를 통과했다고 말하지 않기
- unsigned 릴리즈를 notarized 릴리즈처럼 설명하지 않기
- AppKit UI 안에 코어 규칙을 마구 섞지 않기
- `.sisyphus/` 같은 로컬 에이전트 메타데이터를 프로젝트 소스로 커밋하지 않기
