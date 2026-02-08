# 챕터 3: 노드와 씬 시스템
#
# 이 챕터에서는 다음을 학습합니다:
# - 노드 생명주기 콜백 (_init, _ready, _enter_tree 등)
# - 자식 노드를 코드로 동적 생성
# - 노드 검색 메서드 (get_node, find_child)
# - PackedScene을 이용한 씬 인스턴싱
# - 노드 그룹 시스템
# - process_mode를 이용한 일시정지 처리

extends Node


# =============================================
# 연습 1에서 사용할 생명주기 순서 배열
# =============================================
# TODO: Godot 노드의 생명주기 콜백 순서를 올바르게 나열하세요
# 보기: "_ready", "_init", "_enter_tree", "_process", "_exit_tree"
# 참고: 노드가 씬 트리에 추가될 때의 순서입니다
#       _process는 매 프레임 호출됩니다
var lifecycle_order: Array = []  # 여기를 수정하세요


func _ready():
	# =============================================
	# 연습 1: 노드 생명주기 순서 맞추기
	# =============================================
	# TODO: lifecycle_order 배열을 올바른 순서로 채우세요
	# 노드가 씬 트리에 추가될 때 호출되는 순서:
	# 1. _init() - 객체 생성 시
	# 2. _enter_tree() - 씬 트리에 진입 시
	# 3. _ready() - 모든 자식 노드가 준비된 후
	# 4. _process() - 매 프레임 반복 (씬 트리에 있는 동안)
	# 5. _exit_tree() - 씬 트리에서 제거 시
	#
	# 예: lifecycle_order = ["_init", "_enter_tree", ...]
	# 위 스크립트 상단의 lifecycle_order 변수를 수정하세요
	var answer1_correct = (lifecycle_order == ["_init", "_enter_tree", "_ready", "_process", "_exit_tree"])

	# =============================================
	# 연습 2: 자식 노드 동적 생성
	# =============================================
	# TODO: create_child_nodes() 함수를 완성하세요
	# 이 함수는 현재 노드 아래에 3개의 자식 Node를 생성합니다
	# - "ChildA", "ChildB", "ChildC" 이름을 가진 Node
	# 함수 호출 후 자식 노드 수를 확인합니다
	var before_count = get_child_count()
	create_child_nodes()
	var after_count = get_child_count()
	var answer2 = after_count - before_count  # 3이 되어야 합니다

	# =============================================
	# 연습 3: 노드 검색 (get_node, find_child)
	# =============================================
	# TODO: search_nodes() 함수를 완성하세요
	# 연습 2에서 생성한 자식 노드를 다양한 방법으로 검색합니다
	# - get_node("ChildA") 로 직접 경로 검색
	# - find_child("ChildB", true, false) 로 재귀 검색
	# - get_children()으로 전체 자식 목록 가져오기
	var search_results = search_nodes()

	# =============================================
	# 연습 4: 씬 인스턴싱 코드 작성
	# =============================================
	# TODO: instance_scene() 함수를 완성하세요
	# PackedScene을 로드하고 인스턴스를 생성하는 코드를 작성하세요
	# 실제 씬 파일이 없으므로 의사 코드(pseudocode)로 작성합니다
	# 반환값: 올바른 인스턴싱 절차를 설명하는 문자열 배열
	var scene_steps = instance_scene()

	# =============================================
	# 연습 5: 노드 그룹 활용
	# =============================================
	# TODO: setup_groups() 함수를 완성하세요
	# - "ChildA"를 "team_alpha" 그룹에 추가
	# - "ChildB"를 "team_alpha" 그룹에 추가
	# - "ChildC"를 "team_beta" 그룹에 추가
	# - "team_alpha" 그룹에 속한 노드 수를 반환
	var alpha_count = setup_groups()

	# =============================================
	# 연습 6: process_mode 설정
	# =============================================
	# TODO: setup_process_modes() 함수를 완성하세요
	# 각 자식 노드에 적절한 process_mode를 설정합니다
	# - "ChildA": PROCESS_MODE_PAUSABLE (일시정지 시 멈춤, 기본값)
	# - "ChildB": PROCESS_MODE_ALWAYS (일시정지와 관계없이 항상 실행)
	# - "ChildC": PROCESS_MODE_DISABLED (항상 비활성)
	# 설정 완료 후 각 노드의 process_mode 값을 딕셔너리로 반환
	var process_modes = setup_process_modes()

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 3: 노드와 씬 시스템 ===")

	print("--- 연습 1: 생명주기 순서 ---")
	print("결과 1 (순서 맞음): ", answer1_correct, " (기대값: true)")
	print("결과 1 (입력한 순서): ", lifecycle_order)

	print("--- 연습 2: 자식 노드 동적 생성 ---")
	print("결과 2 (추가된 자식 수): ", answer2, " (기대값: 3)")

	print("--- 연습 3: 노드 검색 ---")
	print("결과 3 (검색 결과): ", search_results)

	print("--- 연습 4: 씬 인스턴싱 ---")
	print("결과 4 (인스턴싱 절차): ", scene_steps)

	print("--- 연습 5: 그룹 활용 ---")
	print("결과 5 (team_alpha 멤버 수): ", alpha_count, " (기대값: 2)")

	print("--- 연습 6: process_mode ---")
	print("결과 6 (process_modes): ", process_modes)
	print("=== 완료 ===\n")


# =============================================
# 연습 2: 자식 노드 동적 생성 함수
# =============================================
# TODO: 3개의 자식 Node를 생성하여 현재 노드에 추가하세요
# 각 노드의 이름은 "ChildA", "ChildB", "ChildC" 입니다
# 힌트:
#   var child = Node.new()
#   child.name = "ChildA"
#   add_child(child)
func create_child_nodes():
	pass  # 여기를 수정하세요


# =============================================
# 연습 3: 노드 검색 함수
# =============================================
# TODO: 자식 노드를 검색하여 결과를 딕셔너리로 반환하세요
# 반환 형식:
# {
#   "by_path": <get_node("ChildA")의 이름>,
#   "by_find": <find_child("ChildB", true, false)의 이름>,
#   "children_names": <모든 자식 노드 이름 배열>
# }
# 힌트: get_children()으로 자식 목록을 얻은 뒤 각 노드의 name을 배열에 추가
func search_nodes() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 4: 씬 인스턴싱 함수
# =============================================
# TODO: 씬을 인스턴싱하는 올바른 절차를 문자열 배열로 반환하세요
# 실제 씬 파일이 없으므로, 아래 단계를 올바른 순서의 코드 문자열로 작성합니다:
# 단계:
#   1) "var scene = load(\"res://path/to/scene.tscn\")"   또는 preload
#   2) "var instance = scene.instantiate()"
#   3) "instance.position = Vector2(100, 100)"  (선택: 속성 설정)
#   4) "add_child(instance)"
func instance_scene() -> Array:
	return []  # 여기를 수정하세요


# =============================================
# 연습 5: 노드 그룹 설정 함수
# =============================================
# TODO: 자식 노드들을 그룹에 추가하고, "team_alpha" 그룹의 멤버 수를 반환하세요
# 힌트:
#   get_node("ChildA").add_to_group("team_alpha")
#   get_tree().get_nodes_in_group("team_alpha").size()
func setup_groups() -> int:
	return 0  # 여기를 수정하세요


# =============================================
# 연습 6: process_mode 설정 함수
# =============================================
# TODO: 각 자식 노드의 process_mode를 설정하고 결과를 반환하세요
# process_mode 값:
#   Node.PROCESS_MODE_PAUSABLE = 1 (기본값, 일시정지 시 멈춤)
#   Node.PROCESS_MODE_ALWAYS = 3 (항상 실행)
#   Node.PROCESS_MODE_DISABLED = 4 (비활성)
#
# 반환 형식:
# {
#   "ChildA": <process_mode 값>,
#   "ChildB": <process_mode 값>,
#   "ChildC": <process_mode 값>
# }
# 힌트: get_node("ChildA").process_mode = Node.PROCESS_MODE_PAUSABLE
func setup_process_modes() -> Dictionary:
	return {}  # 여기를 수정하세요
