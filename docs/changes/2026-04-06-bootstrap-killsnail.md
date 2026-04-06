# 2026-04-06 KillSnail 부트스트랩

## 배경

원격 저장소는 비어 있었고, Swift/AppKit status bar 앱, DMG 릴리즈, Homebrew 설치 경로, 한국어 문서가 모두 필요한 상태였습니다.

## 목표

- AppKit 기반 메뉴바 앱의 첫 구조를 만든다.
- 달팽이 추격 / 사망 오버레이 / 리셋 동작의 최소 제품을 만든다.
- 테스트 가능한 코어와 릴리즈 자동화의 토대를 함께 만든다.

## 변경 내용

- XcodeGen 기반 프로젝트 정의 추가
- `KillSnailCore` 순수 로직 계층 추가
- AppKit 메뉴바/달팽이/오버레이 UI 추가
- XCTest 기반 코어 테스트 추가
- GitHub Actions CI / Release workflow 추가
- main 브랜치 버전 변경 시 태그를 자동 생성하는 workflow 추가
- DMG 생성 및 Homebrew cask 업데이트 스크립트 추가
- README / AGENTS / 아키텍처 문서 추가
- 이모지 기반 달팽이를 커스텀 픽셀 아트 달팽이와 앱 아이콘으로 교체

## 설계 이유

- 빈 저장소였기 때문에 재현 가능한 프로젝트 생성이 필요했고, 그 기준으로 XcodeGen을 선택했습니다.
- AppKit 셸과 코어 로직을 분리해 유지보수성과 테스트 가능성을 확보했습니다.
- 릴리즈 자동화는 태그를 기준으로 분리해 CI와 public release를 다르게 운영할 수 있게 했습니다.

## 영향 범위

- 앱 런타임 구조
- 테스트 구조
- 문서 구조
- CI / Release / Homebrew 배포 경로

## 검증 방법

- `xcodegen generate`
- `xcodebuild ... test`
- `scripts/build_dmg.sh <version>`
- 메뉴바 앱 실행 후 달팽이/오버레이 수동 확인

## 남아 있는 한계

- 초기 릴리즈는 unsigned / not notarized 상태일 수 있습니다.
- Homebrew 설치 경로는 제공되지만 Gatekeeper friction을 제거하지는 못합니다.
- unsigned / not notarized 상태에서는 첫 실행 시 로컬 승인 또는 quarantine 해제가 필요할 수 있습니다.

## 후속 과제

- Developer ID signing / notarization 도입
- 걷기/대기 프레임 애니메이션 추가
- 릴리즈 노트 자동 생성
- 다중 모니터 동작 세부 개선
