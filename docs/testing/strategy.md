# 테스트 전략

## 자동 테스트

현재 자동 테스트는 `KillSnailCore` 중심으로 구성합니다.

- 시작 위치가 현재 커서 반대편에서 계산되는지
- 달팽이가 커서를 향해 천천히 이동하는지
- 충돌 시 dead 상태로 넘어가는지
- 리셋이 현재 화면 기준으로 다시 시작하는지

이 범위가 우선인 이유는 AppKit 오버레이보다 코어 규칙이 회귀 위험이 크기 때문입니다.

## 수동 검증

AppKit UI는 아래 시나리오를 수동으로 확인합니다.

1. 앱 실행 후 메뉴바 아이콘 표시
2. 달팽이 윈도우가 화면에 나타나고 천천히 이동
3. 충돌 후 `YOU DEAD` 오버레이 표시
4. `리셋` 버튼과 메뉴바 `리셋` 액션 동작

## 릴리즈 검증

- DMG mount 성공
- `KillSnail.app` drag-to-Applications 가능 여부
- Release workflow가 DMG, ZIP, checksums 업로드 여부
- Homebrew cask 버전/체크섬 반영 여부
