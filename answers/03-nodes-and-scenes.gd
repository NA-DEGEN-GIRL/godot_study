# 챕터 3: 노드와 씬 시스템 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - 노드 생명주기 (_init, _enter_tree, _ready, _process, _exit_tree)
# - 동적으로 노드 생성하고 트리에 추가하기
# - 노드 검색과 접근 ($, get_node, find_child)
# - 씬 인스턴싱 (PackedScene, instantiate)
# - 그룹(Group) 시스템으로 노드 분류
# - process_mode 설정으로 일시정지 제어

extends Node


# =============================================
# 생명주기 추적용 변수
# =============================================
var lifecycle_log: Array = []
var frame_count: int = 0
var max_frames: int = 3  # _process 테스트용 프레임 수 제한


# =============================================
# 연습 1: 생명주기 순서 이해
# =============================================
# 풀이: Godot 노드에는 정해진 생명주기(Lifecycle) 콜백이 있습니다.
# 1) _init(): 객체 생성 시 호출 (생성자 역할)
# 2) _enter_tree(): 씬 트리에 추가될 때 호출
# 3) _ready(): 모든 자식 노드가 준비된 후 호출 (한 번만)
# 4) _process(delta): 매 프레임 호출
# 5) _exit_tree(): 씬 트리에서 제거될 때 호출
# 추가 설명: _ready()는 씬 트리 진입 후 한 번만 호출되며,
# _process()는 매 프레임 반복 호출됩니다.

func _init():
	lifecycle_log.append("1._init() 호출됨")

func _enter_tree():
	lifecycle_log.append("2._enter_tree() 호출됨")

func _ready():
	lifecycle_log.append("3._ready() 호출됨")

	# 생명주기 로그 출력
	print("\n=== 챕터 3: 노드와 씬 시스템 ===")
	print("--- 연습 1: 생명주기 순서 ---")
	for log_entry in lifecycle_log:
		print("  ", log_entry)

	# =============================================
	# 연습 2: 동적 노드 생성
	# =============================================
	# 풀이: Node.new()로 노드를 코드에서 직접 생성할 수 있습니다.
	# 생성한 노드에 .name을 설정하고, add_child()로 현재 노드의 자식으로 추가합니다.
	# 추가 설명: 노드를 트리에 추가해야 _ready(), _process() 등이 호출됩니다.
	# 트리에 추가하지 않은 노드는 수동으로 .free()해야 메모리 누수가 발생하지 않습니다.
	print("--- 연습 2: 동적 노드 생성 ---")

	# Node2D 자식 3개 생성
	var node_a = Node2D.new()
	node_a.name = "DynamicNodeA"
	add_child(node_a)

	var node_b = Node2D.new()
	node_b.name = "DynamicNodeB"
	add_child(node_b)

	var node_c = Sprite2D.new()
	node_c.name = "DynamicSprite"
	add_child(node_c)

	# 자식 노드 수 확인
	var child_count: int = get_child_count()
	print("결과 2-1 (자식 노드 수): ", child_count)

	# 모든 자식 노드 이름 출력
	for child in get_children():
		print("  자식 노드: ", child.name, " (", child.get_class(), ")")

	# =============================================
	# 연습 3: 노드 검색
	# =============================================
	# 풀이: 노드를 찾는 여러 방법이 있습니다.
	# - $NodeName 또는 get_node("NodeName"): 직접 자식 경로로 접근
	# - find_child("Name", recursive, owned): 이름으로 자식 검색
	# - get_node_or_null(): 노드가 없으면 null 반환 (안전한 접근)
	# 추가 설명: $ 구문은 get_node()의 축약형입니다.
	# 상대 경로("Child/GrandChild")와 절대 경로("/root/Main/Node")를 모두 지원합니다.
	print("--- 연습 3: 노드 검색 ---")

	# get_node()로 자식 접근
	var found_a = get_node("DynamicNodeA")
	print("결과 3-1 (get_node): ", found_a.name if found_a else "없음")

	# get_node_or_null()로 안전하게 접근 (없으면 null)
	var found_missing = get_node_or_null("NonExistentNode")
	print("결과 3-2 (get_node_or_null 없는 노드): ", found_missing)

	# find_child()로 재귀 검색 (recursive=true, owned=false)
	var found_sprite = find_child("DynamicSprite", true, false)
	print("결과 3-3 (find_child): ", found_sprite.name if found_sprite else "없음")
	print("결과 3-3 (클래스): ", found_sprite.get_class() if found_sprite else "없음")

	# $ 구문 사용 (get_node의 축약형)
	var found_b = $DynamicNodeB
	print("결과 3-4 ($ 구문): ", found_b.name if found_b else "없음")

	# =============================================
	# 연습 4: 씬 인스턴싱 (개념 설명)
	# =============================================
	# 풀이: PackedScene은 씬 파일(.tscn)을 메모리에 로드한 리소스입니다.
	# .instantiate()를 호출하면 씬의 노드 트리 복사본을 생성합니다.
	# 실제 사용법:
	#   var scene = preload("res://scenes/enemy.tscn")  # 컴파일 시 로드
	#   var scene = load("res://scenes/enemy.tscn")      # 런타임 로드
	#   var instance = scene.instantiate()                # 인스턴스 생성
	#   add_child(instance)                               # 트리에 추가
	# 추가 설명: preload는 컴파일 시 로드하므로 더 빠르고,
	# load는 런타임에 동적으로 로드할 때 사용합니다.
	print("--- 연습 4: 씬 인스턴싱 (개념) ---")

	# 씬 파일이 없으므로 개념만 코드로 표현합니다
	var scene_path: String = "res://scenes/enemy.tscn"
	var explanation: String = "PackedScene.instantiate()로 씬 복사본을 생성합니다"

	# 동적 노드 생성으로 인스턴싱 개념을 시뮬레이션
	var simulated_enemy = CharacterBody2D.new()
	simulated_enemy.name = "Enemy_001"
	add_child(simulated_enemy)

	var simulated_enemy2 = CharacterBody2D.new()
	simulated_enemy2.name = "Enemy_002"
	add_child(simulated_enemy2)

	print("결과 4-1 (씬 경로): ", scene_path)
	print("결과 4-2 (설명): ", explanation)
	print("결과 4-3 (생성된 적 수): 2")

	# =============================================
	# 연습 5: 그룹(Group) 시스템
	# =============================================
	# 풀이: 그룹은 노드를 논리적으로 분류하는 태깅 시스템입니다.
	# - add_to_group("name"): 노드를 그룹에 추가
	# - is_in_group("name"): 그룹 소속 여부 확인
	# - get_tree().get_nodes_in_group("name"): 그룹의 모든 노드 조회
	# - remove_from_group("name"): 그룹에서 제거
	# 추가 설명: 그룹은 적 전체에 데미지, 아이템 전체 초기화 등
	# 같은 종류의 노드에 일괄 작업할 때 유용합니다.
	print("--- 연습 5: 그룹 시스템 ---")

	# 적 노드들을 "enemies" 그룹에 추가
	simulated_enemy.add_to_group("enemies")
	simulated_enemy2.add_to_group("enemies")

	# 일반 노드를 "allies" 그룹에 추가
	node_a.add_to_group("allies")
	node_b.add_to_group("allies")

	# 그룹 소속 확인
	var is_enemy: bool = simulated_enemy.is_in_group("enemies")
	print("결과 5-1 (Enemy_001은 enemies 그룹?): ", is_enemy)

	# 그룹의 모든 노드 조회
	var all_enemies: Array = get_tree().get_nodes_in_group("enemies")
	print("결과 5-2 (enemies 그룹 노드 수): ", all_enemies.size())
	for enemy in all_enemies:
		print("  적: ", enemy.name)

	var all_allies: Array = get_tree().get_nodes_in_group("allies")
	print("결과 5-3 (allies 그룹 노드 수): ", all_allies.size())

	# 그룹에서 제거
	simulated_enemy2.remove_from_group("enemies")
	var enemies_after_remove: Array = get_tree().get_nodes_in_group("enemies")
	print("결과 5-4 (제거 후 enemies 수): ", enemies_after_remove.size())

	# =============================================
	# 연습 6: process_mode 설정
	# =============================================
	# 풀이: process_mode는 게임이 일시정지(paused)될 때 노드의 동작을 제어합니다.
	# - PROCESS_MODE_INHERIT (0): 부모의 설정을 따름 (기본값)
	# - PROCESS_MODE_PAUSABLE (1): 일시정지 시 멈춤
	# - PROCESS_MODE_WHEN_PAUSED (2): 일시정지 중에만 동작
	# - PROCESS_MODE_ALWAYS (3): 항상 동작 (일시정지 무시)
	# - PROCESS_MODE_DISABLED (4): 항상 멈춤
	# 추가 설명: 일시정지 메뉴 UI는 PROCESS_MODE_ALWAYS로 설정해야
	# 게임이 일시정지되어도 UI가 동작합니다.
	print("--- 연습 6: process_mode ---")

	# 각 노드에 다른 process_mode 설정
	node_a.process_mode = Node.PROCESS_MODE_PAUSABLE
	node_b.process_mode = Node.PROCESS_MODE_ALWAYS
	node_c.process_mode = Node.PROCESS_MODE_DISABLED

	print("결과 6-1 (NodeA process_mode): ", node_a.process_mode, " (PAUSABLE)")
	print("결과 6-2 (NodeB process_mode): ", node_b.process_mode, " (ALWAYS)")
	print("결과 6-3 (NodeC process_mode): ", node_c.process_mode, " (DISABLED)")

	# process_mode 상수값 확인
	print("  INHERIT=", Node.PROCESS_MODE_INHERIT)
	print("  PAUSABLE=", Node.PROCESS_MODE_PAUSABLE)
	print("  WHEN_PAUSED=", Node.PROCESS_MODE_WHEN_PAUSED)
	print("  ALWAYS=", Node.PROCESS_MODE_ALWAYS)
	print("  DISABLED=", Node.PROCESS_MODE_DISABLED)

	print("=== 완료 ===\n")


func _process(delta):
	# 생명주기 테스트: 처음 몇 프레임만 로그 기록
	if frame_count < max_frames:
		frame_count += 1
		if frame_count == 1:
			print("--- 연습 1 보충: _process 호출 확인 ---")
		print("  _process() 호출 #", frame_count, " (delta: %.4f초)" % delta)


func _exit_tree():
	# 풀이: 씬 트리에서 제거될 때 호출되는 콜백입니다.
	# 정리(cleanup) 작업에 사용합니다.
	print("  _exit_tree() 호출됨 - 노드가 트리에서 제거됩니다")
