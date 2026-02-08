# Godot 초보부터 고수까지

Godot Engine 4 + GDScript 학습 과정입니다.

## 구성

- **12 챕터** / **220+ 슬라이드** / **100+ 코드 예제**
- Reveal.js 기반 슬라이드 (브라우저에서 열기)
- TTS 나레이션 지원 (Space 키로 재생)

## 커리큘럼

| # | 제목 | 핵심 주제 |
|---|------|----------|
| 01 | Godot 엔진 소개 | 엔진 개요, 설치, 에디터 UI |
| 02 | GDScript 기초 | 변수, 자료형, 함수, 조건문, 반복문 |
| 03 | 노드와 씬 | 노드 트리, 씬 구조, 인스턴싱 |
| 04 | 2D 게임 기초 | Sprite2D, 입력 처리, CharacterBody2D |
| 05 | 물리와 충돌 | RigidBody2D, Area2D, 충돌 레이어 |
| 06 | 시그널과 그룹 | 시그널, 커스텀 시그널, 그룹 |
| 07 | UI 시스템 | Control 노드, 레이아웃, 테마, HUD |
| 08 | 애니메이션 | AnimationPlayer, Tween, 상태 머신 |
| 09 | 오디오와 파티클 | AudioStreamPlayer, GPUParticles2D |
| 10 | 타일맵과 레벨 | TileMap, TileSet, 씬 전환 |
| 11 | 리소스와 데이터 | Resource, 저장/불러오기, Autoload |
| 12 | 실전 프로젝트 패턴 | 디자인 패턴, 최적화, 내보내기 |

## 실행 방법

### 슬라이드
브라우저에서 `slides/01-introduction.html` 을 직접 열거나, Live Server를 사용하세요.

### 예제 코드
1. Godot Engine 4.x를 설치합니다.
2. 새 프로젝트를 생성합니다.
3. `examples/` 폴더의 `.gd` 파일을 Node에 붙여 실행합니다.

### TTS 나레이션 생성
```bash
pip install edge-tts
python scripts/generate_audio.py
```
