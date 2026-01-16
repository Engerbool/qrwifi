# 카카오 인앱 브라우저 다운로드 해결 기록

> 2024년 - 카카오톡 인앱 브라우저에서 이미지 다운로드 성공까지의 여정

## 문제 상황

카카오톡에서 링크를 열면 카카오 인앱 브라우저가 실행됨. 이 환경에서 이미지 다운로드가 작동하지 않았음.

## 시도한 방법들과 실패 원인

### 1차 시도: Blob URL + anchor.click() ❌

```javascript
const blob = new Blob([imageBytes], { type: 'image/png' });
const url = URL.createObjectURL(blob);
anchor.href = url;
anchor.download = filename;
anchor.click();
URL.revokeObjectURL(url);
```

**결과**: 다운로드 상태창까지 뜨지만 실제 파일 저장 안 됨

**실패 원인**:
- Blob URL은 `blob:https://example.com/uuid-1234` 형태
- 브라우저 메모리의 임시 객체를 참조하는 URL
- 카카오 인앱 브라우저의 다운로드 매니저가 Blob URL을 제대로 처리하지 못함
- `revokeObjectURL()` 타이밍과 무관하게 실패 (지연시켜도 안 됨)

### 2차 시도: Data URL로 페이지 이동 ❌

```javascript
const base64 = btoa(imageBytes);
const dataUrl = `data:image/png;base64,${base64}`;
window.location.href = dataUrl;
// "이미지를 길게 눌러 저장하세요" 안내
```

**결과**: 이미지는 화면에 표시되지만 길게 눌러도 저장 옵션 안 나옴

**실패 원인**:
- 카카오 인앱 브라우저가 data URL 페이지에서 컨텍스트 메뉴(길게 누르기) 비활성화
- 인앱 브라우저의 보안 정책으로 추정

### 3차 시도 (성공): Data URL + anchor.click() ✅

```javascript
const base64 = btoa(imageBytes);
const dataUrl = `data:image/png;base64,${base64}`;
const anchor = document.createElement('a');
anchor.href = dataUrl;
anchor.download = filename;
anchor.click();
```

**결과**: 다운로드 성공!

## 왜 Blob URL은 안 되고 Data URL은 되는가?

### Blob URL의 특성
```
blob:https://qrwifi-poster.web.app/550e8400-e29b-41d4-a716-446655440000
```
- 브라우저 메모리에 저장된 객체를 **참조**하는 URL
- 해당 페이지 컨텍스트에서만 유효
- 외부 다운로드 매니저가 접근하면 이미 무효화되었거나 접근 불가
- 인앱 브라우저 → 시스템 다운로드 매니저로 핸드오프 시 URL 참조 실패

### Data URL의 특성
```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA...
```
- 데이터가 URL **자체에 인코딩**되어 있음
- 별도의 참조나 네트워크 요청 불필요
- 어떤 컨텍스트에서도 데이터에 직접 접근 가능
- 인앱 브라우저 → 다운로드 매니저 핸드오프 시에도 데이터 유지

### 핵심 차이점

| 구분 | Blob URL | Data URL |
|------|----------|----------|
| 데이터 위치 | 브라우저 메모리 (참조) | URL 문자열 내 (임베디드) |
| 유효 범위 | 생성한 페이지 컨텍스트 | 어디서든 유효 |
| 다운로드 매니저 호환 | 인앱 브라우저에서 실패 | 정상 작동 |
| URL 크기 | 짧음 (참조만) | 김 (전체 데이터 포함) |

## 최종 해결 코드 (Dart/Flutter Web)

```dart
// lib/services/export_service_web.dart

Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  final userAgent = web.window.navigator.userAgent.toLowerCase();

  // 인앱 브라우저 감지
  final isInAppBrowser = userAgent.contains('kakaotalk') ||
      userAgent.contains('naver') ||
      userAgent.contains('fban') ||
      userAgent.contains('fbav') ||
      userAgent.contains('instagram');

  if (isInAppBrowser) {
    // 인앱 브라우저: Data URL 방식 사용
    return _downloadWithDataUrl(imageBytes, filename);
  } else {
    // 일반 브라우저: Blob URL 방식 (더 효율적)
    return _downloadWithBlobUrl(imageBytes, filename);
  }
}

ExportResult _downloadWithDataUrl(Uint8List imageBytes, String filename) {
  final base64 = base64Encode(imageBytes);
  final dataUrl = 'data:image/png;base64,$base64';

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUrl;
  anchor.download = filename;
  anchor.style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return ExportResult(success: true, message: '포스터가 다운로드되었습니다!');
}
```

## 인앱 브라우저 감지 User-Agent 패턴

| 앱 | User-Agent 포함 문자열 |
|----|----------------------|
| 카카오톡 | `kakaotalk` |
| 네이버 | `naver` |
| 페이스북 | `fban`, `fbav` |
| 인스타그램 | `instagram` |

## 교훈

1. **Blob URL은 인앱 브라우저에서 불안정** - 다운로드 매니저 핸드오프 시 참조 실패
2. **Data URL은 데이터가 URL에 포함**되어 있어 컨텍스트 독립적
3. **인앱 브라우저 감지 후 분기 처리** 필요
4. 일반 브라우저에서는 Blob URL이 메모리 효율적 (큰 파일에서 유리)

## 카카오 인앱 브라우저의 추가 한계

### 파일명 문제
- 카카오 인앱 브라우저는 `download` 속성을 **무시**함
- Data URL의 base64 문자열이 파일명으로 저장됨
- 예: `Hrh0LAAAAAzytx7GnuII...FTkSuQmCC.png`

### 왜 해결 불가능한가?
| 방식 | 다운로드 | 파일명 | 카카오 결과 |
|------|---------|--------|------------|
| Blob URL | ❌ 실패 | ✅ 정상 | 다운로드 안 됨 |
| Data URL | ✅ 성공 | ❌ base64 | 다운로드는 되지만 파일명 이상 |

### 결론
- 카카오 인앱 브라우저에서는 **다운로드 성공이 우선**
- 파일명은 사용자가 갤러리에서 수동 변경 필요
- 삼성 인터넷, 크롬 등 일반 브라우저에서는 파일명 정상 저장
