# 챕터 1: Godot 엔진 소개
#
# 이 챕터에서는 다음을 학습합니다:
# - print() 함수로 콘솔 출력하기
# - 변수 선언과 초기화
# - @export 변수로 에디터 노출
# - _ready() 생명주기와 노드 정보
# - 프로젝트 경로 시스템 (res://, user://)

extends Node

# 연습 3에서 사용할 @export 변수
# TODO: 아래 변수들을 @export 키워드를 사용하여 에디터에서 편집 가능하게 만드세요
# 예: @export var speed: float = 100.0
var player_name: String = ""  # 여기를 수정하세요
var player_speed: float = 0.0  # 여기를 수정하세요
var player_health: int = 0  # 여기를 수정하세요


func _ready():
	# =============================================
	# 연습 1: print()로 자기소개 출력
	# =============================================
	# TODO: print() 함수를 사용하여 자기소개를 출력하세요
	# 최소 3줄 이상 출력해야 합니다
	# 예:
	#   print("안녕하세요! 저는 홍길동입니다.")
	#   print("나이: 25세")
	#   print("Godot 엔진을 배우고 있습니다!")
	var answer1 = null  # 여기를 수정하세요 (출력 후 "done" 문자열로 변경)

	# =============================================
	# 연습 2: 변수 선언 (이름, 나이, 취미)
	# =============================================
	# TODO: 아래 변수들을 적절한 값으로 선언하세요
	# - my_name: String 타입, 본인 이름
	# - my_age: int 타입, 본인 나이
	# - my_hobby: String 타입, 본인 취미
	# 예: var my_name: String = "홍길동"
	var my_name = null  # 여기를 수정하세요
	var my_age = null  # 여기를 수정하세요
	var my_hobby = null  # 여기를 수정하세요

	# =============================================
	# 연습 3: @export 변수 확인
	# =============================================
	# TODO: 이 스크립트 상단의 변수 3개를 @export로 수정한 뒤,
	# 아래에서 해당 변수들의 값을 출력하세요
	# @export 변수는 에디터 인스펙터에서 값을 편집할 수 있습니다
	# 예: print("플레이어 이름: ", player_name)
	var answer3 = null  # 여기를 수정하세요 (@export 변수 3개 모두 설정했으면 "done")

	# =============================================
	# 연습 4: _ready()에서 노드 정보 출력
	# =============================================
	# TODO: 현재 노드의 정보를 출력하세요
	# - self.name: 노드 이름
	# - self.get_class(): 노드 클래스명
	# - self.get_path(): 노드 경로
	# - self.get_parent(): 부모 노드 (null일 수 있음)
	# 예: print("노드 이름: ", self.name)
	var node_name = null  # 여기를 수정하세요 (self.name 값으로 설정)
	var node_class = null  # 여기를 수정하세요 (self.get_class() 값으로 설정)
	var node_path = null  # 여기를 수정하세요 (self.get_path() 값으로 설정)

	# =============================================
	# 연습 5: 프로젝트 경로 출력 (res://, user://)
	# =============================================
	# TODO: Godot의 특수 경로를 출력하세요
	# - res:// : 프로젝트 리소스 경로 (읽기 전용, 게임 에셋 위치)
	# - user:// : 사용자 데이터 경로 (읽기/쓰기 가능, 세이브 파일 등)
	#
	# ProjectSettings.globalize_path()를 사용하여 실제 OS 경로를 확인하세요
	# 예: var res_path = ProjectSettings.globalize_path("res://")
	var res_path = null  # 여기를 수정하세요
	var user_path = null  # 여기를 수정하세요

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
