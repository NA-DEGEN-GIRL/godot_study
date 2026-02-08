## 설정값

```yaml
subject: "Godot"              # 예: Python, React, Kubernetes, SQL
subject_en: "godot"       # 예: python, react, kubernetes, sql
subtitle: "Godot 초보부터 고수까지"             # 예: "파이썬 완전 정복", "React 마스터 클래스"
language: "ko"           # 예: ko (한국어), en (영어), ja (일본어)
code_language: "gdscript"      # 예: python, javascript, sql, yaml, bash
total_chapters: "알아서 설정"         # 예: 12
slides_per_chapter: "알아서 설정"
examples_per_chapter: "알아서 설정"
exercises_per_chapter: "알아서 설정"
tts_voice: "ko-KR-SunHiNeural"          # 예: ko-KR-SunHiNeural, en-US-JennyNeural
theme_color: "알아서 설정"        # 예: #3178C6 (TS blue), #3776AB (Python blue)
```

---

## Phase 1: 프로젝트 초기 구조 생성

### 지시문

```
아래 디렉토리 구조로 {{ subject }} 학습 프로젝트를 생성해줘.

프로젝트 루트: /root/study/{{ subject_en }}/

디렉토리 구조:
├── index.html                    # 메인 랜딩 페이지 (챕터 목록 그리드)
├── package.json                  # npm 설정 (필요시)
├── README.md                     # 프로젝트 설명
├── scripts/
│   └── generate_audio.py         # TTS 오디오 생성 스크립트
├── slides/
│   ├── css/
│   │   ├── custom.css            # Reveal.js 커스텀 테마
│   │   └── narration.css         # 나레이션 UI 스타일
│   ├── js/
│   │   └── narration.js          # 오디오 나레이션 시스템
│   ├── audio/                    # 생성된 MP3 파일 (챕터별 하위 폴더)
│   │   └── manifest.json
│   ├── 01-chapter-name.html      # 챕터별 슬라이드
│   ├── 02-chapter-name.html
│   └── ...
├── examples/                     # 실행 가능한 예제 코드
│   ├── 01-chapter-name/
│   │   ├── 01-example.{{ ext }}
│   │   └── 02-example.{{ ext }}
│   └── ...
├── exercises/                    # 연습 문제
│   ├── 01-chapter-name.{{ ext }}
│   └── ...
└── answers/                      # 연습 문제 정답
    ├── 01-chapter-name.{{ ext }}
    └── ...
```

---

## Phase 2: 챕터 커리큘럼 설계

### 지시문

```
{{ subject }} 학습을 위한 {{ total_chapters }}개 챕터 커리큘럼을 설계해줘.

규칙:
1. 난이도 순서: 기초 → 중급 → 고급 → 실전
2. 각 챕터는 하나의 핵심 주제에 집중
3. 이전 챕터의 개념을 다음 챕터에서 활용
4. 마지막 챕터는 실전 패턴/프로젝트

출력 형식:
| 챕터 | 제목 | 핵심 주제 | 난이도 (1-5) | 슬라이드 수 |
|------|------|----------|-------------|-----------|
| 01   | ...  | ...      | 1           | 15-20     |
| ...  | ...  | ...      | ...         | ...       |

각 챕터별 세부 토픽 3~5개도 나열해줘.
```

---

## Phase 3: index.html (랜딩 페이지) 생성

### 지시문

```
다음 구조로 index.html을 생성해줘.

필수 요소:
1. 히어로 섹션: 제목 "{{ subtitle }}", 통계 (N 챕터, N+ 슬라이드, N+ 예제)
2. 챕터 그리드: 반응형 카드 레이아웃 (CSS Grid, auto-fill, minmax 280px)
3. 각 카드: 챕터 번호, 제목, 설명, 태그, 난이도 (1-5 점)
4. 푸터: 실행 방법 안내

디자인 규칙:
- 폰트: Noto Sans KR + monospace (JetBrains Mono 또는 시스템 모노스페이스)
- 테마 색상: {{ theme_color }}
- 다크 테마 기본 (배경: #1a1a2e 계열)
- 카드 호버 효과: scale(1.03) + box-shadow
- 그라디언트 텍스트 제목
- 모바일 반응형
```

**참고 패턴 (index.html 카드 구조):**

```html
<a href="slides/NN-chapter-name.html" class="chapter-card">
  <span class="chapter-num">Chapter NN</span>
  <h3>챕터 제목</h3>
  <p>챕터 설명 한 줄</p>
  <div class="tag-row">
    <span class="tag">토픽1</span>
    <span class="tag">토픽2</span>
  </div>
  <div class="difficulty">
    <span class="dot filled"></span>  <!-- 난이도 점 -->
    <span class="dot"></span>
  </div>
</a>
```

---

## Phase 4: CSS/JS 공통 파일 생성

### 지시문

```
Reveal.js 기반 슬라이드를 위한 CSS와 JS를 생성해줘.

### slides/css/custom.css

필수 클래스:
- .chapter-title: 챕터 타이틀 슬라이드 (큰 제목 + 부제목 + 배지)
- .key-point: 핵심 포인트 박스 (왼쪽 색상 테두리 + 배경)
- .compare-table: 비교 테이블 (줄무늬 행, 헤더 색상)
- .two-columns: 2단 레이아웃 (flexbox, gap: 1em)
- .badge, .badge-blue/green/red/orange: 인라인 색상 라벨
- .tip: 초록색 테두리 정보 박스
- .warning: 빨간색 테두리 경고 박스
- .nav-footer: 하단 네비게이션 바

슬라이드 규칙:
- section { max-height: 700px; overflow-y: auto; }
- 커스텀 스크롤바 ({{ theme_color }} 계열)
- Reveal.js night 테마 위에 오버라이드

### slides/css/narration.css

필수 요소:
- .narration-btn: 좌하단 고정 원형 버튼 (44x44px)
  - 재생/정지 SVG 아이콘
  - 재생 중 pulse 애니메이션
  - Space 키 힌트 (hover 시)
- .narration-progress: 상단 고정 진행바 (3px 높이)

### slides/js/narration.js

기능:
1. getChapterNum(): URL에서 챕터 번호 추출
2. getAudioPath(slideIndex): audio/{chapter}/slide-{NN}.mp3 경로 생성
3. hasNarration(): 현재 슬라이드에 data-narration 속성 존재 여부
4. createUI(): 버튼 + 진행바 DOM 생성
5. play(): Audio 객체 생성, 재생, 진행바 업데이트
6. stop(): 정지, 초기화
7. toggle(): 재생/정지 토글
8. onSlideChanged(): 슬라이드 변경 시 정지 + 버튼 표시/숨김

키보드: Space 키로 토글 (input/textarea 포커스 시 제외)
이벤트: Reveal.on('slidechanged', onSlideChanged)
```

---

## Phase 5: 슬라이드 HTML 생성

### 지시문 (챕터당 반복)

```
챕터 {{ NN }}의 슬라이드를 생성해줘.

### HTML 기본 구조

<!DOCTYPE html>
<html lang="{{ language }}">
<head>
  <meta charset="utf-8">
  <title>Chapter {{ NN }}: {{ 제목 }} - {{ subtitle }}</title>
  <!-- Reveal.js 4.6.1 CDN -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/reveal.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/theme/night.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/plugin/highlight/monokai.min.css">
  <link rel="stylesheet" href="css/custom.css">
  <link rel="stylesheet" href="css/narration.css">
</head>
<body>
  <div class="reveal">
    <div class="slides">
      <!-- 슬라이드들 -->
    </div>
  </div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/reveal.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/plugin/highlight/highlight.min.js"></script>
  <script>
    Reveal.initialize({
      hash: true, slideNumber: true,
      plugins: [RevealHighlight],
      transition: 'slide', height: 700,
      center: false, margin: 0.04,
      minScale: 0.2, maxScale: 1.5,
      keyboard: { 38: null, 40: null },
      mouseWheel: false
    });
    // 위/아래 화살표 → 슬라이드 내 스크롤
    document.addEventListener('keydown', function(e) {
      if (e.keyCode === 38 || e.keyCode === 40) {
        var slide = Reveal.getCurrentSlide();
        if (!slide) return;
        var amount = 80;
        slide.scrollTop += (e.keyCode === 38 ? -amount : amount);
        e.preventDefault(); e.stopPropagation();
      }
    }, true);
  </script>
  <script src="js/narration.js"></script>
</body>
</html>

### 슬라이드 패턴

**슬라이드 1 - 타이틀:**
<section data-narration="챕터 N, [주제]입니다. 이 챕터에서는 [내용1], [내용2], [내용3]을 학습합니다. [왜 중요한지]. [실전 활용처].">
  <div class="chapter-title">
    <div class="chapter-number">Chapter NN</div>
    <h1>챕터 제목</h1>
    <p class="subtitle">부제목</p>
    <p>
      <span class="badge badge-blue">토픽1</span>
      <span class="badge badge-green">토픽2</span>
    </p>
  </div>
</section>

**일반 슬라이드 (코드 예시):**
<section data-narration="150~300자 나레이션. 코드가 무엇을 하는지 구체적으로 설명.">
  <h2>슬라이드 제목</h2>
  <pre><code class="language-{{ code_language }}" data-trim data-noescape>
// 코드 예시
  </code></pre>
  <div class="tip fragment">
    <strong>팁:</strong> 추가 설명
  </div>
</section>

**비교 슬라이드:**
<section data-narration="...">
  <h2>A vs B 비교</h2>
  <div class="two-columns">
    <div><h3>A 방식</h3><pre><code>...</code></pre></div>
    <div><h3>B 방식</h3><pre><code>...</code></pre></div>
  </div>
</section>

**요약 슬라이드 (마지막):**
<section data-narration="챕터 N을 마치겠습니다. 가장 중요한 포인트는 [핵심]. [실전 조언]. 다음 챕터에서는 [미리보기].">
  <h2>Chapter NN 요약</h2>
  <div class="key-point">
    <h3>핵심 정리</h3>
    <ul>
      <li class="fragment"><strong>개념1</strong>: 설명</li>
      <li class="fragment"><strong>개념2</strong>: 설명</li>
    </ul>
  </div>
  <p class="fragment">
    <a href="NN+1-next-chapter.html">다음 챕터: ... &rarr;</a>
  </p>
</section>
```

### 나레이션 작성 규칙

```
data-narration 작성 규칙:

1. 길이: 150~300자 (최소 120자)
2. 코드 슬라이드: 코드가 무엇을 하는지 반드시 설명
   - 나쁜 예: "인터페이스는 객체 구조를 정의합니다."
   - 좋은 예: "이 코드에서 User 인터페이스는 name은 문자열, age는 숫자여야 한다고 정의합니다. 속성을 빠뜨리거나 잘못된 타입을 넣으면 컴파일 에러가 발생합니다."

3. 꺾쇠괄호 금지 (HTML 파싱 깨짐)
   - Array<number> → "Array 제네릭 형태" 또는 "배열 타입"
   - Promise<T> → "Promise 제네릭"
   - <T> → "꺾쇠 T" 또는 "타입 매개변수 T"
   - 큰따옴표 금지 (속성값 깨짐) → 작은따옴표 또는 다른 표현 사용

4. 타이틀 슬라이드 패턴:
   "챕터 N, [주제]입니다. 이 챕터에서는 [내용1], [내용2], [내용3]을 학습합니다. [왜 중요한지]. [실전 활용처]."

5. 요약 슬라이드 패턴:
   "챕터 N을 마치겠습니다. 가장 중요한 포인트는 [핵심]. [실전 조언]. 다음 챕터에서는 [미리보기]."

6. 초보자가 알아들을 수 있게:
   - 전문 용어 첫 등장 시 쉬운 설명 병기
   - "살펴보겠습니다" 같은 모호한 표현 금지
   - 구체적으로: "이 코드에서", "왼쪽 예시를 보면", "표에서 보듯이" 등
```

---

## Phase 6: 예제 코드 생성

### 지시문

```
각 챕터별 실행 가능한 예제 코드를 생성해줘.

위치: examples/{{ NN }}-chapter-name/

파일 형식:
/**
 * Chapter {{ NN }} - {{ 챕터 제목 }}
 * {{ NN }}-{{ 설명 }}.{{ ext }}
 *
 * 이 파일에서 배울 내용:
 * - 개념 1
 * - 개념 2
 */

// ============================================
// 1. 섹션 제목
// ============================================

console.log("=== 섹션 ===\n");

// 코드 + 인라인 주석 설명
// 실행 결과가 콘솔에 출력되도록

규칙:
1. 모든 파일은 독립적으로 실행 가능해야 함
2. console.log로 실행 결과 확인 가능
3. 주석은 {{ language }}로 작성
4. 섹션 구분선으로 가독성 확보
5. 실행 방법 주석 포함
```

---

## Phase 7: 연습 문제 + 정답 생성

### 지시문

```
각 챕터별 연습 문제와 정답을 생성해줘.

### 연습 문제 (exercises/{{ NN }}-chapter-name.{{ ext }})

형식:
/**
 * 챕터 {{ NN }}: {{ 제목 }}
 *
 * 학습 내용:
 * - 개념1
 * - 개념2
 */

// 연습 1: {{ 설명 }}
// TODO: {{ 구체적 지시사항 }}
// 예시: {{ 기대 결과 }}
const answer1 = undefined;  // 여기를 수정하세요

// ... 5~7개 연습 문제

// 테스트 (수정하지 마세요)
console.log('=== 챕터 N: 제목 ===');
console.log('연습 1:', answer1);

### 정답 (answers/{{ NN }}-chapter-name.{{ ext }})

형식:
/**
 * 챕터 {{ NN }}: {{ 제목 }} - 정답
 */

// 연습 1: {{ 설명 }}
// 풀이: {{ 왜 이렇게 풀었는지 설명 }}
const answer1 = /* 정답 코드 */;

// 테스트 (연습 문제와 동일)

규칙:
1. 연습 문제는 해당 챕터에서 배운 개념만 사용
2. 쉬운 것 → 어려운 것 순서
3. 정답에는 풀이 설명 포함
4. 테스트 코드는 연습/정답 파일에서 동일
```

---

## Phase 8: TTS 오디오 생성

### 지시문

```
TTS 오디오 생성 스크립트를 생성해줘.

위치: scripts/generate_audio.py

기능:
1. slides/*.html에서 data-narration 속성 파싱
2. edge-tts 라이브러리로 MP3 생성
3. manifest.json으로 변경분만 재생성 (SHA-256 해시)
4. CLI 인자: --voice, --chapter, --force, --list-voices

사용법:
  pip install edge-tts
  python scripts/generate_audio.py                    # 전체 생성
  python scripts/generate_audio.py --chapter 03       # 특정 챕터
  python scripts/generate_audio.py --force             # 전체 재생성
  python scripts/generate_audio.py --list-voices       # 음성 목록

기본 음성: {{ tts_voice }}

오디오 파일 경로: slides/audio/{{ NN }}/slide-{{ MM }}.mp3
```

---

## Phase 9: 검증 체크리스트

### 지시문

```
모든 자료 생성 후 다음을 검증해줘:

1. 슬라이드 검증:
   - 모든 <section>에 data-narration 속성 존재
   - 나레이션 길이: 120자 이상, 300자 이하
   - 나레이션에 < > " 문자 없음
   - 코드 슬라이드에 코드 설명 포함

2. 예제 코드 검증:
   - 모든 파일 독립 실행 가능
   - 문법 에러 없음
   - 콘솔 출력 포함

3. 연습/정답 검증:
   - 연습 문제의 TODO 부분이 placeholder (undefined, null 등)
   - 정답 파일에 실제 구현 존재
   - 테스트 코드 동일

4. 오디오 검증:
   - MP3 파일 수 == data-narration 속성 수
   - manifest.json 존재

5. 네비게이션 검증:
   - index.html → 각 챕터 링크 동작
   - 각 챕터 → 이전/다음 챕터 링크 존재
```

---

## 실행 순서 요약

| 단계 | 작업 | 병렬 가능 |
|------|------|----------|
| 1 | 프로젝트 구조 + package.json + README | - |
| 2 | 커리큘럼 설계 (챕터 목록) | - |
| 3 | index.html 생성 | - |
| 4 | CSS/JS 공통 파일 생성 | - |
| 5 | 슬라이드 HTML 생성 (12개) | 3~4개씩 병렬 |
| 6 | 예제 코드 생성 | 슬라이드와 병렬 |
| 7 | 연습 문제 + 정답 생성 | 슬라이드와 병렬 |
| 8 | 슬라이드 리뷰 & 개선 | 3~4개씩 병렬 |
| 9 | 나레이션 보강 (150~300자) | 3~4개씩 병렬 |
| 10 | TTS 오디오 생성 | - |
| 11 | 전체 검증 | - |
| 12 | git commit & push | - |

---

## 빠른 시작 (원샷 프롬프트)

아래 프롬프트를 그대로 복사하여 LLM에게 전달하면 됩니다.
`{{ }}` 부분만 교체하세요.

```
{{ subtitle }} 학습 자료를 만들어줘.

구조: /root/study/{{ subject_en }}/
- Reveal.js 4.6.1 기반 슬라이드 (night 테마, monokai 코드 하이라이팅)
- {{ total_chapters }}개 챕터, 챕터당 15~22 슬라이드
- 코드 언어: {{ code_language }}
- 나레이션 언어: {{ language }}
- TTS 음성: {{ tts_voice }}
- 테마 색상: {{ theme_color }}

포함할 것:
1. index.html - 챕터 그리드 랜딩 페이지 (다크 테마, 반응형)
2. slides/*.html - Reveal.js 슬라이드 (data-narration 속성으로 나레이션)
3. slides/css/custom.css - 커스텀 테마 (key-point, compare-table, two-columns, badge, tip, warning 클래스)
4. slides/css/narration.css - 나레이션 버튼/진행바 UI
5. slides/js/narration.js - Space키로 오디오 재생, 슬라이드 변경 시 자동 정지
6. examples/ - 챕터별 실행 가능한 예제 코드
7. exercises/ - TODO 형식 연습 문제
8. answers/ - 풀이 설명 포함 정답
9. scripts/generate_audio.py - edge-tts 기반 MP3 생성 (manifest.json 캐싱)

나레이션 규칙:
- 150~300자, 코드가 무엇을 하는지 구체적 설명
- 꺾쇠괄호/큰따옴표 금지 (HTML 파싱 깨짐)
- 타이틀: "챕터 N, [주제]입니다. 이 챕터에서는 [A], [B], [C]를 학습합니다."
- 요약: "챕터 N을 마치겠습니다. 가장 중요한 포인트는 [핵심]. [실전 조언]."

난이도 기초→고급 순서로 커리큘럼을 설계하고, 전체 자료를 생성해줘.
```

---

## 주제별 예시 설정값

### Python

```yaml
subject: "Python"
subject_en: "python"
subtitle: "파이썬 완전 정복"
language: "ko"
code_language: "python"
total_chapters: 12
tts_voice: "ko-KR-SunHiNeural"
theme_color: "#3776AB"
```

챕터 예시: 기초 문법, 자료형, 함수, OOP, 모듈/패키지, 파일 I/O, 예외처리, 데코레이터/제너레이터, 정규식, 테스팅, 웹 스크래핑, 실전 프로젝트

### React

```yaml
subject: "React"
subject_en: "react"
subtitle: "React 마스터 클래스"
language: "ko"
code_language: "tsx"
total_chapters: 12
tts_voice: "ko-KR-SunHiNeural"
theme_color: "#61DAFB"
```

챕터 예시: JSX 기초, 컴포넌트, Props/State, 이벤트, 조건부 렌더링, 리스트, Hooks 기초, 커스텀 훅, Context/Reducer, React Router, API 연동, 성능 최적화

### SQL

```yaml
subject: "SQL"
subject_en: "sql"
subtitle: "SQL 완전 정복"
language: "ko"
code_language: "sql"
total_chapters: 10
tts_voice: "ko-KR-SunHiNeural"
theme_color: "#F29111"
```

챕터 예시: SELECT 기초, WHERE/ORDER, JOIN, 집계함수/GROUP BY, 서브쿼리, INSERT/UPDATE/DELETE, 인덱스, 트랜잭션, 윈도우 함수, 실전 쿼리 최적화

### Kubernetes

```yaml
subject: "Kubernetes"
subject_en: "k8s"
subtitle: "쿠버네티스 완전 정복"
language: "ko"
code_language: "yaml"
total_chapters: 12
tts_voice: "ko-KR-SunHiNeural"
theme_color: "#326CE5"
```

챕터 예시: 컨테이너 기초, Pod, Deployment, Service, ConfigMap/Secret, Volume, Namespace, Ingress, RBAC, Helm, 모니터링, 실전 배포 전략
