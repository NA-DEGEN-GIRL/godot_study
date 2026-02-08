# 챕터 1: Godot 엔진 소개 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - print() 함수로 콘솔 출력하기
# - 변수 선언과 초기화
# - @export 변수로 에디터 노출
# - _ready() 생명주기와 노드 정보
# - 프로젝트 경로 시스템 (res://, user://)

extends Node

# 연습 3에서 사용할 @export 변수
# 풀이: @export 키워드를 변수 선언 앞에 붙이면 에디터의 인스펙터 패널에서
# 값을 직접 편집할 수 있습니다. 타입 힌트를 함께 사용하면 에디터가
# 적절한 입력 UI를 자동으로 제공합니다.
@export var player_name: String = "Hero"
@export var player_speed: float = 100.0
@export var player_health: int = 100


func _ready():
	# =============================================
	# 연습 1: print()로 자기소개 출력
	# =============================================
	# 풀이: print() 함수는 GDScript에서 가장 기본적인 출력 함수입니다.
	# 문자열을 인자로 전달하면 Godot의 출력 패널(Output)에 텍스트가 표시됩니다.
	# 디버깅이나 정보 확인 시 자주 사용합니다.
	print("안녕하세요! 저는 홍길동입니다.")
	print("나이: 25세")
	print("Godot 엔진을 배우고 있습니다!")
	var answer1 = "done"  # <- 출력 완료 후 "done" 설정

	# =============================================
	# 연습 2: 변수 선언 (이름, 나이, 취미)
	# =============================================
	# 풀이: GDScript에서 변수는 var 키워드로 선언합니다.
	# 타입 힌트(: Type)를 사용하면 타입 안전성이 높아지고,
	# 에디터의 자동 완성 기능도 더 잘 동작합니다.
	# 추가 설명: String, int, float 등은 GDScript의 내장 타입입니다.
	var my_name: String = "홍길동"
	var my_age: int = 25
	var my_hobby: String = "게임 개발"

	# =============================================
	# 연습 3: @export 변수 확인
	# =============================================
	# 풀이: 스크립트 상단에서 @export 키워드를 추가했습니다.
	# @export는 변수를 에디터 인스펙터에 노출시킵니다.
	# 씬(.tscn)에 이 스크립트를 붙인 노드를 선택하면
	# 인스펙터에서 player_name, player_speed, player_health를 편집할 수 있습니다.
	# 추가 설명: @export_range, @export_enum 등 다양한 변형이 있습니다.
	print("플레이어 이름: ", player_name)
	print("플레이어 속도: ", player_speed)
	print("플레이어 체력: ", player_health)
	var answer3 = "done"  # <- @export 변수 3개 모두 설정 완료

	# =============================================
	# 연습 4: _ready()에서 노드 정보 출력
	# =============================================
	# 풀이: self 키워드는 현재 노드 인스턴스를 가리킵니다.
	# - self.name: 씬 트리에서의 노드 이름
	# - self.get_class(): 노드의 클래스명 (예: "Node", "Sprite2D")
	# - self.get_path(): 씬 트리에서의 절대 경로 (예: "/root/Main")
	# 추가 설명: self는 생략 가능하지만, 명확성을 위해 사용하는 것이 좋습니다.
	var node_name = self.name
	var node_class = self.get_class()
	var node_path = self.get_path()

	print("노드 이름: ", node_name)
	print("노드 클래스: ", node_class)
	print("노드 경로: ", node_path)

	# =============================================
	# 연습 5: 프로젝트 경로 출력 (res://, user://)
	# =============================================
	# 풀이: Godot은 두 가지 특수 경로 접두어를 사용합니다.
	# - res:// : 프로젝트 루트 디렉토리. 게임 에셋(씬, 스크립트, 이미지 등)이 위치합니다.
	#            빌드 후에는 읽기 전용입니다.
	# - user:// : 사용자 데이터 디렉토리. 세이브 파일, 설정 등을 저장합니다.
	#            항상 읽기/쓰기 가능합니다.
	# ProjectSettings.globalize_path()는 Godot 경로를 실제 OS 파일시스템 경로로 변환합니다.
	var res_path = ProjectSettings.globalize_path("res://")
	var user_path = ProjectSettings.globalize_path("user://")

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 1: Godot 엔진 소개 ===")
	print("--- 연습 1 ---")
	print("결과 1 (자기소개 출력 완료): ", answer1)

	print("--- 연습 2 ---")
	print("결과 2-1 (이름): ", my_name)
	print("결과 2-2 (나이): ", my_age)
	print("결과 2-3 (취미): ", my_hobby)

	print("--- 연습 3 ---")
	print("결과 3 (@export 설정 완료): ", answer3)
	print("  player_name: ", player_name)
	print("  player_speed: ", player_speed)
	print("  player_health: ", player_health)

	print("--- 연습 4 ---")
	print("결과 4-1 (노드 이름): ", node_name)
	print("결과 4-2 (노드 클래스): ", node_class)
	print("결과 4-3 (노드 경로): ", node_path)

	print("--- 연습 5 ---")
	print("결과 5-1 (res:// 경로): ", res_path)
	print("결과 5-2 (user:// 경로): ", user_path)
	print("=== 완료 ===\n")
