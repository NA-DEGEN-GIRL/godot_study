# Chapter 03 - Nodes and Scenes
# 02-node-management.gd - Dynamic Node Management
#
# 이 파일에서 배울 내용:
# - add_child()로 동적으로 노드 추가하기
# - remove_child(), queue_free()로 노드 제거하기
# - get_node(), $, find_child()로 노드 검색하기
# - reparent()로 노드 이동하기
# - 노드 그룹(Group) 활용법

extends Node

# ============================================
# 1. 동적 노드 생성과 추가
# ============================================

func _ready():
	print("=== 노드 관리 (Node Management) ===\n")

	# ============================================
	# 동적 노드 생성
	# ============================================
	print("--- 동적 노드 생성과 추가 ---\n")

	# Node 생성 (new() 메서드 사용)
	var child1 := Node.new()
	child1.name = "Child_A"

	var child2 := Node.new()
	child2.name = "Child_B"

	var child3 := Node.new()
	child3.name = "Child_C"

	# add_child()로 씬 트리에 추가
	add_child(child1)
	add_child(child2)
	add_child(child3)

	print("3개의 자식 노드를 추가했습니다")
	print("자식 노드 수: ", get_child_count())

	# 모든 자식 노드 확인
	print("\n현재 자식 노드 목록:")
	for child in get_children():
		print("  - %s (경로: %s)" % [child.name, child.get_path()])

	# ============================================
	# 2. 중첩 노드 구조 만들기
	# ============================================
	print("\n--- 중첩 노드 구조 ---\n")

	# 계층 구조 생성
	var enemies_group := Node.new()
	enemies_group.name = "Enemies"
	add_child(enemies_group)

	# Enemies 아래에 자식 노드 추가
	for i in range(3):
		var enemy := Node.new()
		enemy.name = "Enemy_%d" % i
		enemies_group.add_child(enemy)

	# 트리 구조 출력
	print("노드 트리 구조:")
	print_tree_structure(self, 0)

	# ============================================
	# 3. 노드 검색 (get_node, $, find_child)
	# ============================================
	print("\n--- 노드 검색 ---\n")

	# get_node() - 경로로 노드 찾기
	var found_a := get_node("Child_A")
	print("get_node('Child_A'): ", found_a.name)

	# $ 연산자 - get_node의 축약형
	var found_b := $Child_B
	print("$Child_B: ", found_b.name)

	# 중첩된 노드 접근
	var enemy_0 := get_node("Enemies/Enemy_0")
	print("get_node('Enemies/Enemy_0'): ", enemy_0.name)

	# $로 중첩 접근
	var enemy_1 := $Enemies/Enemy_1
	print("$Enemies/Enemy_1: ", enemy_1.name)

	# get_node_or_null() - 안전한 검색 (없으면 null)
	var maybe := get_node_or_null("NonExistent")
	print("\nget_node_or_null('NonExistent'): ", maybe)  # null

	# has_node() - 노드 존재 여부 확인
	print("has_node('Child_A'): ", has_node("Child_A"))
	print("has_node('NonExistent'): ", has_node("NonExistent"))

	# find_child() - 이름으로 재귀 검색
	var found_enemy := find_child("Enemy_2", true, false)
	if found_enemy:
		print("\nfind_child('Enemy_2'): ", found_enemy.get_path())

	# ============================================
	# 4. 노드 순서 관리
	# ============================================
	print("\n--- 노드 순서 ---\n")

	print("변경 전:")
	for i in range(get_child_count()):
		var child := get_child(i)
		print("  [%d] %s" % [i, child.name])

	# 노드 순서 변경
	var child_c := $Child_C
	move_child(child_c, 0)  # Child_C를 첫 번째로 이동

	print("\nChild_C를 맨 앞으로 이동 후:")
	for i in range(get_child_count()):
		var child := get_child(i)
		print("  [%d] %s" % [i, child.name])

	# 특정 인덱스의 자식 가져오기
	var first_child := get_child(0)
	var last_child := get_child(get_child_count() - 1)
	print("\n첫 번째 자식: ", first_child.name)
	print("마지막 자식: ", last_child.name)

	# ============================================
	# 5. reparent() - 노드 이동
	# ============================================
	print("\n--- reparent() 노드 이동 ---\n")

	print("이동 전 구조:")
	print_tree_structure(self, 0)

	# Child_A를 Enemies 아래로 이동
	var child_a := $Child_A
	var enemies := $Enemies
	child_a.reparent(enemies)

	print("\nChild_A를 Enemies 아래로 이동 후:")
	print_tree_structure(self, 0)

	# ============================================
	# 6. 노드 제거
	# ============================================
	print("\n--- 노드 제거 ---\n")

	print("제거 전 자식 수: ", get_child_count())

	# remove_child() - 씬 트리에서 분리 (메모리에는 남음)
	var child_b_ref := $Child_B
	remove_child(child_b_ref)
	print("remove_child('Child_B') 후 자식 수: ", get_child_count())
	print("Child_B는 메모리에 남아있음: ", child_b_ref != null)
	print("Child_B는 씬 트리에 없음: ", not child_b_ref.is_inside_tree())

	# 다시 추가할 수 있음
	add_child(child_b_ref)
	print("다시 추가 후 자식 수: ", get_child_count())

	# queue_free() - 프레임 끝에 노드를 완전히 제거 (권장)
	child_b_ref.queue_free()
	print("\nqueue_free('Child_B') 호출")
	print("  -> 현재 프레임 끝에 삭제됩니다")
	print("  -> queue_free()가 free()보다 안전합니다")
	print("  -> 다른 코드가 아직 이 노드를 참조하고 있을 수 있으므로")

	# free() - 즉시 제거 (주의 필요)
	# child.free()  # 즉시 삭제 - 다른 참조가 있으면 위험!

	# ============================================
	# 7. 노드 그룹 (Groups)
	# ============================================
	print("\n--- 노드 그룹 ---\n")

	# 그룹에 추가
	for enemy_node in enemies.get_children():
		enemy_node.add_to_group("enemies")
		enemy_node.add_to_group("damageable")

	$Child_C.add_to_group("players")
	$Child_C.add_to_group("damageable")

	# 그룹의 모든 노드 가져오기
	var all_enemies := get_tree().get_nodes_in_group("enemies")
	print("'enemies' 그룹:")
	for e in all_enemies:
		print("  - %s (경로: %s)" % [e.name, e.get_path()])

	var all_damageable := get_tree().get_nodes_in_group("damageable")
	print("\n'damageable' 그룹:")
	for d in all_damageable:
		print("  - %s" % d.name)

	# 그룹 확인
	print("\nEnemy_0의 그룹: ", enemies.get_child(0).get_groups() if enemies.get_child_count() > 0 else "없음")

	# 그룹의 모든 노드에 메서드 호출 (있으면)
	# get_tree().call_group("enemies", "take_damage", 10)
	print("\ncall_group 예제:")
	print("  get_tree().call_group('enemies', 'take_damage', 10)")
	print("  -> 'enemies' 그룹의 모든 노드에서 take_damage(10) 호출")

	# 그룹에서 제거
	if enemies.get_child_count() > 0:
		var first_enemy := enemies.get_child(0)
		first_enemy.remove_from_group("enemies")
		print("\n%s을 'enemies' 그룹에서 제거" % first_enemy.name)
		print("'enemies' 그룹 노드 수: ", get_tree().get_nodes_in_group("enemies").size())

	# ============================================
	# 8. 노드 속성과 메타데이터
	# ============================================
	print("\n--- 노드 속성과 메타데이터 ---\n")

	var test_node := $Child_C
	print("이름: ", test_node.name)
	print("경로: ", test_node.get_path())
	print("클래스: ", test_node.get_class())
	print("씬 트리 안: ", test_node.is_inside_tree())
	print("처리 활성: ", test_node.is_processing())

	# 메타데이터 설정 (커스텀 데이터 저장)
	test_node.set_meta("health", 100)
	test_node.set_meta("team", "blue")
	test_node.set_meta("damage_multiplier", 1.5)

	print("\n메타데이터:")
	print("  health: ", test_node.get_meta("health"))
	print("  team: ", test_node.get_meta("team"))
	print("  damage_multiplier: ", test_node.get_meta("damage_multiplier"))
	print("  메타 키 목록: ", test_node.get_meta_list())

	# 메타데이터 확인 및 기본값
	print("  has 'health': ", test_node.has_meta("health"))
	print("  get 'missing' (기본값): ", test_node.get_meta("missing", "없음"))

	# ============================================
	# 9. 씬 트리 유틸리티
	# ============================================
	print("\n--- 씬 트리 유틸리티 ---\n")

	# 현재 씬 정보
	var tree := get_tree()
	print("현재 씬 루트: ", tree.current_scene.name if tree.current_scene else "없음")
	print("노드 수: ", tree.get_node_count())
	print("현재 프레임: ", tree.get_frame())

	# owner 개념
	print("\nowner 속성:")
	print("  owner는 씬 파일(.tscn)의 루트 노드를 가리킵니다")
	print("  현재 노드의 owner: ", owner.name if owner else "없음")
	print("  에디터에서 저장할 노드를 결정하는 데 사용됩니다")

	# ============================================
	# 10. 실전 패턴: 동적 오브젝트 관리
	# ============================================
	print("\n--- 실전 패턴 ---\n")

	# 오브젝트 풀링 패턴 (개념)
	print("오브젝트 풀링 패턴:")
	print("  var bullet_pool: Array[Node] = []")
	print("  ")
	print("  func get_bullet() -> Node:")
	print("    for b in bullet_pool:")
	print("      if not b.visible:")
	print("        b.visible = true")
	print("        return b")
	print("    var new_bullet = bullet_scene.instantiate()")
	print("    add_child(new_bullet)")
	print("    bullet_pool.append(new_bullet)")
	print("    return new_bullet")

	# 안전한 노드 제거 패턴
	print("\n안전한 노드 제거:")
	print("  if is_instance_valid(node):")
	print("    node.queue_free()")

	# ============================================
	# 11. 최종 트리 구조 출력
	# ============================================
	print("\n--- 최종 노드 트리 ---\n")
	print_tree_structure(self, 0)

	# ============================================
	# 12. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Node.new() + add_child(): 동적 노드 생성")
	print("2. queue_free(): 안전한 노드 삭제 (프레임 끝)")
	print("3. $Name / get_node('path'): 노드 참조")
	print("4. find_child(): 재귀적 노드 검색")
	print("5. reparent(): 노드를 다른 부모로 이동")
	print("6. add_to_group() / get_nodes_in_group(): 그룹 관리")
	print("7. set_meta() / get_meta(): 커스텀 데이터 저장")
	print("8. is_instance_valid(): 노드 유효성 확인")


# ============================================
# Helper: 트리 구조 출력 함수
# ============================================

func print_tree_structure(node: Node, depth: int) -> void:
	var indent := ""
	for i in range(depth):
		indent += "  "

	var prefix := "└── " if depth > 0 else ""
	print("%s%s%s" % [indent, prefix, node.name])

	for child in node.get_children():
		print_tree_structure(child, depth + 1)
