# 웹 UX 개선 TODO

> WiFi QR Poster Generator - 웹 플랫폼 최적화

## Phase 1: 호버/포커스 상태 추가

### `lib/widgets/toss_button.dart`
- [ ] `GestureDetector` → `MouseRegion` + `GestureDetector` 조합
- [ ] `_isHovered` 상태 추가
- [ ] 호버 시 배경색 밝기 변화 (10% 밝게)
- [ ] `cursor: SystemMouseCursors.click` 추가

### `lib/widgets/toss_card.dart`
- [ ] 호버 시 elevation/shadow 증가 효과
- [ ] 커서 변경 (클릭 가능 시)

### `lib/widgets/template_picker.dart`
- [ ] 카테고리 칩에 호버 상태 추가
- [ ] 템플릿 카드에 호버 스케일/shadow 효과

### `lib/widgets/size_picker.dart`
- [ ] 크기 카드에 호버 border 색상 변화

### `lib/widgets/icon_picker.dart`
- [ ] 아이콘 그리드 아이템 호버 효과
- [ ] 업로드 영역 호버 시 배경색 변화

### `lib/widgets/font_picker.dart`
- [ ] 폰트 옵션 호버 효과

---

## Phase 2: 반응형 레이아웃 유틸리티

### `lib/utils/responsive.dart` (신규)
- [ ] 브레이크포인트 정의 (600, 900, 1200px)
- [ ] `isMobile()`, `isTablet()`, `isDesktop()` 헬퍼
- [ ] `gridCrossAxisCount()` 동적 열 수 계산
- [ ] `screenPadding()` 반응형 패딩

---

## Phase 3: 화면별 반응형 레이아웃

### `lib/screens/editor_screen.dart`
- [ ] 데스크톱: 2컬럼 레이아웃 (폼 | 실시간 미리보기)
- [ ] 콘텐츠 `maxWidth` 제한 (1000px)
- [ ] 섹션 간 간격 반응형 조정

### `lib/screens/home_screen.dart`
- [ ] 캐릭터 이미지 크기 반응형 (120px → 160px)
- [ ] 대화 섹션 `maxWidth` 조정
- [ ] 헤더 토글 크기/간격 조정

### `lib/screens/preview_screen.dart`
- [ ] 포스터 미리보기 크기 반응형
- [ ] 액션 버튼 패딩 조정

---

## Phase 4: 그리드/리스트 동적 열 수

### `lib/widgets/icon_picker.dart`
- [ ] `crossAxisCount: 4` → `Responsive.gridCrossAxisCount(context)`

### `lib/widgets/template_picker.dart`
- [ ] 템플릿 카드 크기 반응형

### `lib/widgets/font_picker.dart`
- [ ] 폰트 옵션 레이아웃 반응형

---

## Phase 5: 폼 필드 포커스 상태 복원

### `lib/widgets/wifi_form.dart`
- [ ] 포커스 시 subtle한 border 표시
- [ ] TooltipTriggerMode: 웹에서 hover 지원

### `lib/screens/editor_screen.dart`
- [ ] 제목/메시지/서명 TextField 포커스 스타일 통일

---

## Phase 6: 플랫폼별 분기 처리

- [ ] `kIsWeb` 기반 HapticFeedback 비활성화
- [ ] 웹: 호버로 툴팁 표시
- [ ] 모바일: 탭으로 툴팁 표시

---

## 검증 체크리스트

- [ ] 모든 버튼에 호버 효과 확인
- [ ] Tab 키로 전체 UI 탐색 가능
- [ ] Enter 키로 버튼 활성화
- [ ] 반응형 레이아웃 동작 (320px, 768px, 1280px, 1920px)
- [ ] 그리드 열 수 동적 변경 확인
- [ ] `flutter analyze` 통과
