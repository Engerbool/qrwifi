# Implementation Plan: Poster Canvas Editor

**Status**: 🔄 In Progress
**Started**: 2026-01-14
**Last Updated**: 2026-01-15
**Estimated Completion**: TBD

---

**CRITICAL INSTRUCTIONS**: After completing each phase:
1. Check off completed task checkboxes
2. Run all quality gate validation commands
3. Verify ALL quality gate items pass
4. Update "Last Updated" date above
5. Document learnings in Notes section
6. Only then proceed to next phase

**DO NOT skip quality gates or proceed with failing checks**

---

## Overview

### Feature Description
포스터 캔버스 에디터 기능 - 템플릿으로 포스터를 생성한 후, 각 요소(QR코드, 제목, 메시지, SSID/PW, 서명)를 자유롭게 편집할 수 있는 기능

**주요 기능**:
- 드래그로 요소 이동 (웹: 마우스, 모바일: 터치)
- 크기 조절 (웹: 핸들 드래그, 모바일: 핀치)
- X, Y, 크기 값 직접 입력
- 색상 변경 (텍스트, QR코드 전경/배경)
- 폰트 변경 (요소별)
- Z-order 자동 관리 (마지막 이동 = 최상단)

### Success Criteria
- [ ] 모든 포스터 요소를 드래그로 이동 가능
- [ ] 크기 조절이 웹과 모바일 모두에서 동작
- [ ] 속성 패널에서 수치 직접 입력 가능
- [ ] 색상 및 폰트 변경이 실시간 반영
- [ ] 편집 완료 후 다운로드 화면으로 이동
- [ ] 다운로드 화면에서 다시 수정 버튼으로 재편집 가능
- [ ] 기존 기능(템플릿 선택, 내보내기) 정상 동작

### User Impact
사용자가 템플릿 기반으로 빠르게 포스터를 만든 후, 세부 레이아웃을 자유롭게 조정할 수 있어 더 개인화된 결과물 생성 가능

---

## Architecture Decisions

| Decision | Rationale | Trade-offs |
|----------|-----------|------------|
| `Stack` + `Positioned` 레이아웃 | 자유로운 요소 배치에 적합, Flutter 기본 위젯 | 복잡한 중첩 시 성능 고려 필요 |
| `GestureDetector` 제스처 처리 | 크로스플랫폼 지원, Flutter 네이티브 | 복잡한 멀티터치는 추가 처리 필요 |
| 리스트 순서 기반 Z-order | 별도 버튼 없이 직관적, 구현 단순 | 명시적 레이어 컨트롤 불가 |
| `PosterElement` 모델 추가 | 요소별 상태 독립 관리 | Provider 복잡도 증가 |
| 별도 `CanvasEditorScreen` | 기존 화면 영향 최소화 | 코드 중복 가능성 |

---

## Dependencies

### Required Before Starting
- [ ] 기존 `PosterProvider` 동작 확인
- [ ] `PosterCanvas` 위젯 구조 이해
- [ ] 현재 라우트 구조 파악

### External Dependencies
- flutter: ^3.0.0 (기존)
- provider: ^6.0.0 (기존)
- flutter_colorpicker: ^1.0.0 (새로 추가 예정)

---

## Test Strategy

### Testing Approach
**TDD Principle**: Write tests FIRST, then implement to make them pass

### Test Pyramid for This Feature
| Test Type | Coverage Target | Purpose |
|-----------|-----------------|---------|
| **Unit Tests** | ≥80% | PosterElement 모델, Provider 로직 |
| **Widget Tests** | Critical paths | 제스처 처리, UI 상호작용 |
| **Integration Tests** | Key user flows | 전체 편집 플로우 |

### Test File Organization
```
test/
├── unit/
│   ├── models/
│   │   └── poster_element_test.dart
│   └── providers/
│       └── poster_provider_editor_test.dart
├── widget/
│   ├── editable_element_test.dart
│   ├── resize_handle_test.dart
│   └── property_panel_test.dart
└── integration/
    └── editor_flow_test.dart
```

### Coverage Requirements by Phase
- **Phase 1**: PosterElement 모델 테스트 (≥90%)
- **Phase 2**: 위젯 기본 렌더링 테스트 (≥70%)
- **Phase 3**: 드래그 제스처 테스트 (≥80%)
- **Phase 4**: 리사이즈 제스처 테스트 (≥80%)
- **Phase 5**: 속성 패널 테스트 (≥75%)
- **Phase 6**: 통합 플로우 테스트 (≥70%)

---

## Implementation Phases

### Phase 1: Foundation - Data Model & Provider
**Goal**: 요소별 위치/크기/스타일 관리를 위한 데이터 모델 및 Provider 확장
**Estimated Time**: 2-3 hours
**Status**: ✅ Complete

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 1.1**: `PosterElement` 모델 단위 테스트
  - File: `test/unit/models/poster_element_test.dart`
  - Expected: Tests FAIL - PosterElement 클래스 미존재
  - Test cases:
    - 요소 생성 및 기본값 검증
    - 위치/크기 업데이트
    - Z-index 변경
    - copyWith 동작
    - JSON 직렬화/역직렬화

- [ ] **Test 1.2**: `PosterProvider` 에디터 기능 테스트
  - File: `test/unit/providers/poster_provider_editor_test.dart`
  - Expected: Tests FAIL - 에디터 관련 메서드 미존재
  - Test cases:
    - 요소 리스트 초기화
    - 요소 선택/해제
    - 요소 위치 업데이트
    - 요소 크기 업데이트
    - Z-order 업데이트 (이동 시 최상단)
    - 템플릿 → 요소 변환

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 1.3**: `PosterElement` 모델 생성
  - File: `lib/models/poster_element.dart`
  - 구현 내용:
    ```dart
    enum ElementType { qrCode, title, message, ssidPassword, signature }

    class PosterElement {
      final String id;
      final ElementType type;
      double x, y;
      double width, height;
      int zIndex;
      Color? textColor;
      Color? backgroundColor;
      String? fontFamily;
      double? fontSize;
      String? content;
    }
    ```

- [ ] **Task 1.4**: `PosterProvider` 에디터 메서드 추가
  - File: `lib/providers/poster_provider.dart`
  - 추가 메서드:
    - `List<PosterElement> _elements`
    - `PosterElement? _selectedElement`
    - `initializeElements()` - 현재 설정을 기반으로 요소 생성
    - `selectElement(String id)`
    - `deselectElement()`
    - `updateElementPosition(String id, double x, double y)`
    - `updateElementSize(String id, double w, double h)`
    - `bringToFront(String id)` - Z-index 업데이트
    - `updateElementStyle(...)` - 색상, 폰트 등

- [ ] **Task 1.5**: 템플릿 → 요소 변환 로직
  - File: `lib/providers/poster_provider.dart`
  - 현재 `PosterTemplate` + `PosterSize` 설정을 기반으로
  - 초기 위치/크기 계산 로직 구현

**REFACTOR: Clean Up Code**
- [ ] **Task 1.6**: 코드 정리
  - [ ] 중복 제거
  - [ ] 네이밍 개선
  - [ ] 인라인 문서화

#### Quality Gate

**STOP: Do NOT proceed to Phase 2 until ALL checks pass**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test test/unit/models/poster_element_test.dart` - 통과
- [ ] `flutter test test/unit/providers/poster_provider_editor_test.dart` - 통과

**Code Quality**:
- [ ] `dart format lib/models/poster_element.dart`
- [ ] `dart format lib/providers/poster_provider.dart`

**Validation Commands**:
```bash
flutter analyze
flutter test test/unit/models/
flutter test test/unit/providers/
dart format --output=none --set-exit-if-changed lib/models/ lib/providers/
```

**Manual Test Checklist**:
- [ ] Provider에서 요소 초기화 확인 (디버그 출력)
- [ ] 요소 선택/해제 동작 확인

---

### Phase 2: Canvas Editor Screen - Basic Structure
**Goal**: 새 `CanvasEditorScreen` 화면 생성 및 요소 렌더링
**Estimated Time**: 2-3 hours
**Status**: ⏳ Pending

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 2.1**: `CanvasEditorScreen` 위젯 테스트
  - File: `test/widget/canvas_editor_screen_test.dart`
  - Expected: Tests FAIL - 화면 미존재
  - Test cases:
    - 화면 렌더링
    - 요소들이 Stack 내에 표시
    - 뒤로가기 버튼 동작
    - 완료 버튼 표시

- [ ] **Test 2.2**: `EditableElement` 위젯 테스트
  - File: `test/widget/editable_element_test.dart`
  - Expected: Tests FAIL - 위젯 미존재
  - Test cases:
    - 요소 타입별 렌더링 (QR, 텍스트 등)
    - 선택 시 테두리 표시
    - 탭으로 선택

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 2.3**: `CanvasEditorScreen` 생성
  - File: `lib/screens/canvas_editor_screen.dart`
  - 구현 내용:
    - AppBar (뒤로가기, 제목, 완료 버튼)
    - `AspectRatio`로 포스터 비율 유지
    - `Stack` + `Positioned`로 요소 배치
    - 각 요소를 `EditableElement` 위젯으로 래핑

- [ ] **Task 2.4**: `EditableElement` 위젯 생성
  - File: `lib/widgets/editable_element.dart`
  - 구현 내용:
    - `PosterElement` 기반 렌더링
    - 타입별 자식 위젯 (QrWidget, Text 등)
    - 선택 상태에 따른 테두리/핸들 표시
    - `onTap` 콜백으로 선택

- [ ] **Task 2.5**: 라우트 추가
  - File: `lib/config/routes.dart`
  - `static const String canvasEditor = '/canvas-editor';`
  - 라우트 맵에 추가

**REFACTOR: Clean Up Code**
- [ ] **Task 2.6**: 코드 정리
  - [ ] 위젯 분리 검토
  - [ ] 상수 추출 (패딩, 색상 등)

#### Quality Gate

**STOP: Do NOT proceed to Phase 3 until ALL checks pass**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test test/widget/canvas_editor_screen_test.dart` - 통과
- [ ] `flutter test test/widget/editable_element_test.dart` - 통과

**Validation Commands**:
```bash
flutter analyze
flutter test test/widget/
dart format --output=none --set-exit-if-changed lib/screens/ lib/widgets/
```

**Manual Test Checklist**:
- [ ] 웹에서 `/canvas-editor` 라우트 접근 가능
- [ ] 요소들이 포스터 캔버스 내에 표시
- [ ] 요소 탭 시 선택 테두리 표시
- [ ] 다른 곳 탭 시 선택 해제

---

### Phase 3: Drag & Move Functionality
**Goal**: 터치/마우스로 요소 이동 기능 구현
**Estimated Time**: 3-4 hours
**Status**: ⏳ Pending

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 3.1**: 드래그 제스처 테스트
  - File: `test/widget/drag_gesture_test.dart`
  - Expected: Tests FAIL - 드래그 로직 미존재
  - Test cases:
    - Pan 제스처 시작/업데이트/종료
    - 위치 업데이트 Provider 호출
    - 경계 제한 동작

- [ ] **Test 3.2**: Z-order 업데이트 테스트
  - File: `test/unit/providers/zorder_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - 이동 시 `bringToFront` 호출
    - Z-index 정렬 순서 확인

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 3.3**: `GestureDetector` 통합
  - File: `lib/widgets/editable_element.dart`
  - 구현 내용:
    - `onPanStart`: 드래그 시작, 요소 선택
    - `onPanUpdate`: 위치 업데이트
    - `onPanEnd`: Z-order 업데이트 (최상단으로)

- [ ] **Task 3.4**: 경계 제한 로직
  - File: `lib/providers/poster_provider.dart`
  - 구현 내용:
    - `updateElementPosition`에서 경계 검사
    - 캔버스 밖으로 나가지 않도록 클램핑

- [ ] **Task 3.5**: 좌표 변환 유틸리티
  - File: `lib/utils/coordinate_utils.dart` (새 파일)
  - 구현 내용:
    - 화면 좌표 → 캔버스 좌표 변환
    - 비율 계산 (미리보기 크기 ↔ 실제 픽셀)

**REFACTOR: Clean Up Code**
- [ ] **Task 3.6**: 코드 정리
  - [ ] 제스처 핸들러 분리
  - [ ] 좌표 변환 로직 통합

#### Quality Gate

**STOP: Do NOT proceed to Phase 4 until ALL checks pass**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test` - 모든 테스트 통과

**Validation Commands**:
```bash
flutter analyze
flutter test
```

**Manual Test Checklist**:
- [ ] 웹: 마우스로 요소 드래그 이동
- [ ] 모바일(에뮬레이터): 터치로 요소 드래그 이동
- [ ] 이동 후 요소가 최상단으로 올라옴
- [ ] 캔버스 밖으로 요소 이동 불가

---

### Phase 4: Resize Functionality
**Goal**: 테두리 드래그(웹) / 핀치(모바일)로 크기 조절
**Estimated Time**: 3-4 hours
**Status**: ⏳ Pending

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 4.1**: 리사이즈 핸들 테스트
  - File: `test/widget/resize_handle_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - 8개 핸들 렌더링 (모서리 4 + 변 4)
    - 핸들 드래그 시 크기 변경
    - 방향별 크기 조절 (좌상단, 우하단 등)

- [ ] **Test 4.2**: 핀치 제스처 테스트 (모바일)
  - File: `test/widget/pinch_gesture_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - Scale 제스처 감지
    - 비율 유지 리사이즈

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 4.3**: 리사이즈 핸들 위젯
  - File: `lib/widgets/resize_handles.dart`
  - 구현 내용:
    - 8개 핸들 위치 계산
    - 핸들별 커서 스타일 (웹)
    - 핸들 드래그 콜백

- [ ] **Task 4.4**: 핸들 드래그 로직
  - File: `lib/widgets/editable_element.dart`
  - 구현 내용:
    - 각 핸들 방향에 따른 크기/위치 조절
    - 최소 크기 제한
    - QR코드는 정사각형 유지

- [ ] **Task 4.5**: 핀치 제스처 (모바일)
  - File: `lib/widgets/editable_element.dart`
  - 구현 내용:
    - `onScaleUpdate` 처리
    - 기존 `onPan` 제스처와 공존
    - 비율 유지 리사이즈

**REFACTOR: Clean Up Code**
- [ ] **Task 4.6**: 코드 정리
  - [ ] 핸들 로직 추상화
  - [ ] 플랫폼별 분기 정리

#### Quality Gate

**STOP: Do NOT proceed to Phase 5 until ALL checks pass**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test` - 모든 테스트 통과

**Validation Commands**:
```bash
flutter analyze
flutter test
flutter run -d chrome  # 웹에서 수동 테스트
flutter run -d emulator  # 모바일에서 수동 테스트
```

**Manual Test Checklist**:
- [ ] 웹: 8개 핸들 표시 확인
- [ ] 웹: 각 핸들 드래그로 크기 조절
- [ ] 웹: QR코드 정사각형 유지
- [ ] 모바일: 핀치로 크기 조절
- [ ] 최소 크기 제한 동작

---

### Phase 5: Property Panel - Direct Input
**Goal**: X, Y, 크기, 색상, 폰트 직접 입력 패널
**Estimated Time**: 3-4 hours
**Status**: ⏳ Pending

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 5.1**: 속성 패널 테스트
  - File: `test/widget/property_panel_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - 선택된 요소의 속성 표시
    - X, Y 입력 시 위치 변경
    - 크기 입력 시 크기 변경
    - 요소 미선택 시 패널 숨김

- [ ] **Test 5.2**: 색상 피커 테스트
  - File: `test/widget/color_picker_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - 텍스트 색상 변경
    - QR 전경색/배경색 변경

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 5.3**: 속성 패널 위젯
  - File: `lib/widgets/property_panel.dart`
  - 구현 내용:
    - 하단 시트 또는 사이드 패널
    - 위치 입력 (X, Y TextField)
    - 크기 입력 (Width, Height TextField)
    - 선택 요소 타입에 따른 조건부 표시

- [ ] **Task 5.4**: 색상 피커 통합
  - pubspec.yaml에 `flutter_colorpicker` 추가
  - File: `lib/widgets/property_panel.dart`
  - 구현 내용:
    - 텍스트 요소: textColor
    - QR 요소: foregroundColor, backgroundColor

- [ ] **Task 5.5**: 폰트 선택기 통합
  - File: `lib/widgets/property_panel.dart`
  - 기존 `FontPicker` 재사용
  - 요소별 독립 폰트 설정

- [ ] **Task 5.6**: 숫자 입력 검증
  - File: `lib/widgets/property_panel.dart`
  - 구현 내용:
    - 숫자만 입력 가능
    - 범위 검증 (음수 불가, 최대값 제한)
    - 실시간 업데이트

**REFACTOR: Clean Up Code**
- [ ] **Task 5.7**: 코드 정리
  - [ ] 패널 섹션 위젯화
  - [ ] 입력 필드 재사용 컴포넌트

#### Quality Gate

**STOP: Do NOT proceed to Phase 6 until ALL checks pass**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test` - 모든 테스트 통과
- [ ] `flutter pub get` - 새 패키지 설치 성공

**Validation Commands**:
```bash
flutter pub get
flutter analyze
flutter test
```

**Manual Test Checklist**:
- [ ] 요소 선택 시 속성 패널 표시
- [ ] X, Y 입력으로 위치 변경
- [ ] 크기 입력으로 크기 변경
- [ ] 색상 피커로 색상 변경
- [ ] 폰트 선택으로 폰트 변경
- [ ] 입력값 실시간 반영

---

### Phase 6: Flow Integration & Polish
**Goal**: 화면 간 네비게이션 연결 및 완성도 향상
**Estimated Time**: 2-3 hours
**Status**: ⏳ Pending

#### Tasks

**RED: Write Failing Tests First**
- [ ] **Test 6.1**: 네비게이션 플로우 테스트
  - File: `test/integration/editor_flow_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - PreviewScreen → CanvasEditor 이동
    - CanvasEditor → PreviewScreen 이동 (완료)
    - 상태 유지 확인

- [ ] **Test 6.2**: 번역 테스트
  - File: `test/unit/translations_test.dart`
  - Expected: Tests FAIL
  - Test cases:
    - 에디터 관련 번역 키 존재
    - 한국어/영어 모두 제공

**GREEN: Implement to Make Tests Pass**
- [ ] **Task 6.3**: PreviewScreen 수정 버튼 연결
  - File: `lib/screens/preview_screen.dart`
  - 구현 내용:
    - "수정" 버튼 → `CanvasEditorScreen` 이동
    - `Navigator.pushNamed(context, AppRoutes.canvasEditor)`

- [ ] **Task 6.4**: CanvasEditorScreen 완료 버튼 연결
  - File: `lib/screens/canvas_editor_screen.dart`
  - 구현 내용:
    - "완료" 버튼 → `PreviewScreen` 이동
    - 편집된 요소 상태를 포스터에 반영

- [ ] **Task 6.5**: 포스터 렌더링 업데이트
  - File: `lib/widgets/poster_canvas.dart`
  - 구현 내용:
    - `PosterProvider.elements` 기반 렌더링 옵션
    - 에디터 모드 활성화 시 자유 배치
    - 비활성화 시 기존 고정 레이아웃

- [ ] **Task 6.6**: 번역 추가
  - File: `lib/config/translations.dart`
  - 추가 키:
    - `edit_layout` / `레이아웃 수정`
    - `done` / `완료`
    - `position` / `위치`
    - `size` / `크기`
    - `text_color` / `텍스트 색상`
    - `qr_foreground` / `QR 전경색`
    - `qr_background` / `QR 배경색`
    - `font` / `글씨체`

- [ ] **Task 6.7**: 상태 저장/복원 검증
  - 에디터 ↔ 프리뷰 왕복 시 상태 유지 확인
  - 앱 종료 후 재시작 시 동작 확인

**REFACTOR: Clean Up Code**
- [ ] **Task 6.8**: 최종 정리
  - [ ] 불필요한 코드 제거
  - [ ] 로깅/디버그 코드 정리
  - [ ] 주석 정리

#### Quality Gate

**STOP: This is the FINAL phase - ensure everything works**

**TDD Compliance**:
- [ ] Tests written FIRST and initially failed
- [ ] Production code written to make tests pass
- [ ] Code improved while tests still pass

**Build & Tests**:
- [ ] `flutter analyze` - 오류 없음
- [ ] `flutter test` - 모든 테스트 통과

**Full Validation Commands**:
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build web
flutter build apk
```

**Manual Test Checklist - Full Flow**:
- [ ] HomeScreen에서 포스터 생성 시작
- [ ] EditorScreen에서 WiFi 정보 입력
- [ ] PreviewScreen에서 미리보기 확인
- [ ] "수정" 버튼으로 CanvasEditor 진입
- [ ] 요소 드래그 이동 (웹 + 모바일)
- [ ] 요소 크기 조절 (웹 + 모바일)
- [ ] 속성 패널에서 직접 입력
- [ ] 색상/폰트 변경
- [ ] "완료" 버튼으로 PreviewScreen 복귀
- [ ] 다운로드 버튼으로 이미지 저장
- [ ] 다시 "수정" 버튼으로 재편집 가능

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| 제스처 충돌 (드래그 vs 핀치) | Medium | Medium | 제스처 우선순위 명확히, `GestureArena` 활용 |
| 좌표 변환 오차 | Medium | High | 유틸리티 함수 단위 테스트, 비율 계산 검증 |
| 성능 저하 (많은 요소) | Low | Medium | 요소 수 제한, `RepaintBoundary` 활용 |
| 플랫폼별 동작 차이 | Medium | Medium | 웹/모바일 분기 처리, 각 플랫폼 테스트 |
| Provider 복잡도 증가 | High | Low | 에디터 전용 Provider 분리 고려 |

---

## Rollback Strategy

### If Phase 1 Fails
- `lib/models/poster_element.dart` 삭제
- `lib/providers/poster_provider.dart` 변경 사항 되돌리기
- 테스트 파일 삭제

### If Phase 2 Fails
- `lib/screens/canvas_editor_screen.dart` 삭제
- `lib/widgets/editable_element.dart` 삭제
- `lib/config/routes.dart` 라우트 제거
- Phase 1 완료 상태로 복원

### If Phase 3-4 Fails
- 해당 Phase 변경 사항 되돌리기
- 이전 Phase 완료 상태로 복원

### If Phase 5 Fails
- `flutter_colorpicker` 패키지 제거
- `lib/widgets/property_panel.dart` 삭제
- 이전 Phase 완료 상태로 복원

### If Phase 6 Fails
- `lib/screens/preview_screen.dart` 변경 되돌리기
- `lib/config/translations.dart` 변경 되돌리기
- 이전 Phase 완료 상태로 복원

---

## Progress Tracking

### Completion Status
- **Phase 1**: ✅ 100%
- **Phase 2**: ⏳ 0%
- **Phase 3**: ⏳ 0%
- **Phase 4**: ⏳ 0%
- **Phase 5**: ⏳ 0%
- **Phase 6**: ⏳ 0%

**Overall Progress**: 16% complete (1/6 phases)

### Time Tracking
| Phase | Estimated | Actual | Variance |
|-------|-----------|--------|----------|
| Phase 1 | 2-3 hours | - | - |
| Phase 2 | 2-3 hours | - | - |
| Phase 3 | 3-4 hours | - | - |
| Phase 4 | 3-4 hours | - | - |
| Phase 5 | 3-4 hours | - | - |
| Phase 6 | 2-3 hours | - | - |
| **Total** | 15-21 hours | - | - |

---

## Notes & Learnings

### Implementation Notes
- (구현 중 발견한 인사이트 기록)

### Blockers Encountered
- (발생한 블로커와 해결 방법 기록)

### Improvements for Future Plans
- (다음에 개선할 점 기록)

---

## References

### Documentation
- Flutter GestureDetector: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
- flutter_colorpicker: https://pub.dev/packages/flutter_colorpicker

### Related Files
- `lib/providers/poster_provider.dart` - 기존 상태 관리
- `lib/widgets/poster_canvas.dart` - 기존 포스터 렌더링
- `lib/screens/preview_screen.dart` - 프리뷰 화면
- `lib/config/routes.dart` - 라우트 정의

---

## Final Checklist

**Before marking plan as COMPLETE**:
- [ ] All phases completed with quality gates passed
- [ ] Full integration testing performed
- [ ] Documentation updated
- [ ] Performance acceptable (60fps)
- [ ] 웹, Android, iOS(에뮬레이터) 테스트 완료
- [ ] 한국어/영어 번역 완료
- [ ] 기존 기능 회귀 테스트 통과

---

**Plan Status**: ⏳ Pending
**Next Action**: Phase 1 시작 - `PosterElement` 모델 테스트 작성
**Blocked By**: None
