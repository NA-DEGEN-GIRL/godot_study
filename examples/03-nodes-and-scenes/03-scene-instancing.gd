# Chapter 03 - Nodes and Scenes
# 03-scene-instancing.gd - Scene Instancing and PackedScene
#
# 이 파일에서 배울 내용:
# - PackedScene의 개념과 instantiate() 사용법
# - preload()와 load()로 씬 로딩하기
# - 씬 인스턴스를 동적으로 생성하고 관리하기
# - 씬 전환 (Scene Transition) 방법

extends Node

# ============================================
# 1. PackedScene 개념
# ============================================

# PackedScene은 .tscn 파일을 메모리에 로드한 상태입니다.
# "설계도"와 같아서, instantiate()로 여러 개의 인스턴스를 만들 수 있습니다.
#
# 비유:
# PackedScene = 쿠키 틀 (설계도)
# instantiate() = 쿠키 틀로 쿠키 찍기 (실제 객체 생성)
# add_child() = 쿠키를 접시에 올리기 (씬 트리에 추가)

# preload로 씬을 미리 로드 (컴파일 시점)
# 실제 프로젝트에서는 존재하는 .tscn 파일 경로를 사용합니다:
# const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn")
# const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
# const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion.tscn")

# 시뮬레이션을 위한 변수
var spawn_count: int = 0
var enemy_container: Node = null

func _ready():
	print("=== 씬 인스턴싱 (Scene Instancing) ===\n")

	# ============================================
	# 2. preload vs load 복습
	# ============================================
	print("--- preload vs load ---\n")

	# preload() - 컴파일 시점 로딩
	# const SCENE_A = preload("res://scenes/a.tscn")
	# 장점: 즉시 사용 가능, 로딩 지연 없음
	# 제한: 경로가 문자열 리터럴이어야 함

	# load() - 런타임 로딩
	# var scene_b = load("res://scenes/b.tscn")
	# 장점: 변수로 경로 지정 가능, 동적 로딩
	# 단점: 호출 시 로딩 시간 발생

	print("preload():")
	print("  - 컴파일 시점에 로드")
	print("  - 문자열 리터럴만 가능")
	print("  - 자주 사용하는 작은 씬에 적합")
	print("  - 예: const BULLET = preload('res://scenes/bullet.tscn')")

	print("\nload():")
	print("  - 런타임에 로드")
	print("  - 변수로 경로 지정 가능")
	print("  - 큰 씬이나 조건부 로딩에 적합")
	print("  - 예: var scene = load(path)")

	# 실제 파일이 없으므로 개념 시뮬레이션
	# load() 시도
	var test_load = load("res://icon.svg")
	if test_load:
		print("\nload('res://icon.svg') 성공: ", test_load.get_class())
	else:
		print("\nload('res://icon.svg'): 파일 없음 (정상)")

	# ============================================
	# 3. instantiate() 기본 사용법
	# ============================================
	print("\n--- instantiate() 기본 ---\n")

	# PackedScene을 사용하는 전체 흐름:
	#
	# 1단계: 씬 로드
	# var scene = preload("res://scenes/enemy.tscn")
	#
	# 2단계: 인스턴스 생성
	# var instance = scene.instantiate()
	#
	# 3단계: 속성 설정 (선택사항)
	# instance.position = Vector2(100, 200)
	# instance.speed = 150.0
	#
	# 4단계: 씬 트리에 추가
	# add_child(instance)

	print("씬 인스턴싱 기본 흐름:")
	print("  1. var scene = preload('res://enemy.tscn')")
	print("  2. var instance = scene.instantiate()")
	print("  3. instance.position = Vector2(100, 200)")
	print("  4. add_child(instance)")

	# Node로 시뮬레이션
	print("\n씬 인스턴싱 시뮬레이션:")
	enemy_container = Node.new()
	enemy_container.name = "EnemyContainer"
	add_child(enemy_container)

	# 여러 개의 "적" 노드를 동적 생성
	for i in range(5):
		var enemy := create_mock_enemy(i)
		enemy_container.add_child(enemy)
		print("  적 생성: %s" % enemy.name)

	print("총 적 수: ", enemy_container.get_child_count())

	# ============================================
	# 4. PackedScene 수동 생성
	# ============================================
	print("\n--- PackedScene 수동 생성 ---\n")

	# 코드로 PackedScene을 만들 수도 있습니다 (고급 기능)
	var pack := PackedScene.new()

	# 노드 구조 생성
	var root := Node2D.new()
	root.name = "MyCustomScene"

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	root.add_child(sprite)
	sprite.owner = root  # owner 설정 필수 (저장 시 포함됨)

	var collision := Node.new()
	collision.name = "CollisionShape"
	root.add_child(collision)
	collision.owner = root

	# PackedScene으로 패킹
	var result := pack.pack(root)
	if result == OK:
		print("PackedScene 수동 생성 성공!")
		print("씬 상태: ", pack.get_state())

		# 이 PackedScene에서 인스턴스 생성
		var instance1 := pack.instantiate()
		var instance2 := pack.instantiate()
		print("인스턴스1: ", instance1.name)
		print("인스턴스2: ", instance2.name)
		print("인스턴스1 자식: ", instance1.get_child_count())

		# 정리
		instance1.queue_free()
		instance2.queue_free()

	root.queue_free()  # 원본 정리

	# ============================================
	# 5. 씬 인스턴스 관리 패턴
	# ============================================
	print("\n--- 인스턴스 관리 패턴 ---\n")

	# 패턴 1: 컨테이너 노드 사용
	print("패턴 1 - 컨테이너 노드:")
	print("  var enemies_node = Node.new()")
	print("  enemies_node.name = 'Enemies'")
	print("  add_child(enemies_node)")
	print("  enemies_node.add_child(enemy_instance)")
	print("  -> 그룹화하여 관리하기 쉬움")

	# 패턴 2: 배열로 추적
	print("\n패턴 2 - 배열 추적:")
	var tracked_nodes: Array[Node] = []
	for i in range(3):
		var node_item := Node.new()
		node_item.name = "Tracked_%d" % i
		add_child(node_item)
		tracked_nodes.append(node_item)
	print("  추적 중인 노드: %d개" % tracked_nodes.size())

	# 추적된 노드 정리
	for tracked in tracked_nodes:
		tracked.queue_free()
	tracked_nodes.clear()
	print("  정리 후: %d개" % tracked_nodes.size())

	# ============================================
	# 6. 씬 전환 (Scene Transition)
	# ============================================
	print("\n--- 씬 전환 ---\n")

	# 방법 1: change_scene_to_file() - 가장 간단
	print("방법 1 - change_scene_to_file():")
	print("  get_tree().change_scene_to_file('res://scenes/level_2.tscn')")
	print("  -> 현재 씬을 완전히 교체")
	print("  -> 이전 씬의 모든 노드가 삭제됨")

	# 방법 2: change_scene_to_packed() - 미리 로드한 씬 사용
	print("\n방법 2 - change_scene_to_packed():")
	print("  var next_scene = preload('res://scenes/level_2.tscn')")
	print("  get_tree().change_scene_to_packed(next_scene)")
	print("  -> preload된 씬으로 교체 (더 빠름)")

	# 방법 3: 수동 씬 전환 (가장 유연)
	print("\n방법 3 - 수동 씬 전환 (고급):")
	print("  func change_scene(new_scene_path: String):")
	print("    var current = get_tree().current_scene")
	print("    current.queue_free()")
	print("    var new_scene = load(new_scene_path).instantiate()")
	print("    get_tree().root.add_child(new_scene)")
	print("    get_tree().current_scene = new_scene")

	# 방법 4: 전환 효과와 함께 (실전)
	print("\n방법 4 - 페이드 전환:")
	print("  func transition_to(scene_path: String):")
	print("    # 페이드 아웃")
	print("    var tween = create_tween()")
	print("    tween.tween_property($FadeRect, 'color:a', 1.0, 0.5)")
	print("    await tween.finished")
	print("    # 씬 변경")
	print("    get_tree().change_scene_to_file(scene_path)")
	print("    # 페이드 인은 새 씬의 _ready()에서")

	# ============================================
	# 7. 실전 예제: 스포너 (Spawner)
	# ============================================
	print("\n--- 실전 예제: 스포너 ---\n")

	print("적 스포너 예제 코드:\n")
	print("""# enemy_spawner.gd
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_enemies: int = 10

var enemies: Array[Node] = []

func _ready():
    var timer = Timer.new()
    timer.wait_time = spawn_interval
    timer.timeout.connect(_on_spawn_timer)
    timer.autostart = true
    add_child(timer)

func _on_spawn_timer():
    # 죽은 적 정리
    enemies = enemies.filter(
        func(e): return is_instance_valid(e)
    )

    if enemies.size() >= max_enemies:
        return

    var enemy = enemy_scene.instantiate()
    enemy.global_position = get_random_spawn_position()
    get_parent().add_child(enemy)
    enemies.append(enemy)

func get_random_spawn_position() -> Vector2:
    return Vector2(
        randf_range(-200, 200),
        randf_range(-200, 200)
    )""")

	# ============================================
	# 8. 실전 예제: 오브젝트 풀
	# ============================================
	print("\n--- 실전 예제: 오브젝트 풀 ---\n")

	print("오브젝트 풀 예제 코드:\n")
	print("""# bullet_pool.gd
extends Node

@export var bullet_scene: PackedScene
@export var pool_size: int = 50

var pool: Array[Node] = []

func _ready():
    # 풀 초기화 - 미리 생성
    for i in range(pool_size):
        var bullet = bullet_scene.instantiate()
        bullet.visible = false
        bullet.set_process(false)
        add_child(bullet)
        pool.append(bullet)

func get_bullet() -> Node:
    # 비활성 총알 찾기
    for bullet in pool:
        if not bullet.visible:
            bullet.visible = true
            bullet.set_process(true)
            return bullet

    # 풀이 모두 사용 중이면 새로 생성
    var bullet = bullet_scene.instantiate()
    add_child(bullet)
    pool.append(bullet)
    return bullet

func return_bullet(bullet: Node):
    bullet.visible = false
    bullet.set_process(false)""")

	# ============================================
	# 9. ResourceLoader 비동기 로딩
	# ============================================
	print("\n--- 비동기 씬 로딩 ---\n")

	print("큰 씬을 로딩할 때 게임이 멈추지 않도록:")
	print("")
	print("""# async_loader.gd
extends Node

var loading_path: String = ""

func load_scene_async(path: String):
    loading_path = path
    ResourceLoader.load_threaded_request(path)

func _process(delta):
    if loading_path == "":
        return

    var status = ResourceLoader.load_threaded_get_status(loading_path)

    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            # 로딩 진행률 표시
            var progress = []
            ResourceLoader.load_threaded_get_status(loading_path, progress)
            print("로딩: %.0f%%" % (progress[0] * 100))

        ResourceLoader.THREAD_LOAD_LOADED:
            var scene = ResourceLoader.load_threaded_get(loading_path)
            get_tree().change_scene_to_packed(scene)
            loading_path = ""

        ResourceLoader.THREAD_LOAD_FAILED:
            print("로딩 실패!")
            loading_path = ""
""")

	# ============================================
	# 10. 현재 트리 구조 확인
	# ============================================
	print("--- 최종 트리 구조 ---\n")
	print_tree_pretty(self, "")

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. PackedScene: 씬 파일의 메모리 표현 (설계도)")
	print("2. instantiate(): PackedScene에서 인스턴스 생성")
	print("3. preload(): 컴파일 시점 로딩 (빠름)")
	print("4. load(): 런타임 로딩 (유연함)")
	print("5. change_scene_to_file(): 간단한 씬 전환")
	print("6. 컨테이너 노드: 동적 인스턴스 그룹화")
	print("7. 오브젝트 풀: 빈번한 생성/삭제 최적화")
	print("8. ResourceLoader: 비동기 로딩 (큰 씬)")


# ============================================
# Helper 함수들
# ============================================

# 모의 적 노드 생성
func create_mock_enemy(index: int) -> Node:
	var enemy := Node.new()
	enemy.name = "Enemy_%d" % index
	enemy.set_meta("health", randi_range(50, 150))
	enemy.set_meta("damage", randi_range(5, 20))
	enemy.set_meta("type", ["Slime", "Goblin", "Skeleton", "Bat", "Wolf"][index % 5])
	return enemy


# 예쁜 트리 구조 출력
func print_tree_pretty(node: Node, prefix: String) -> void:
	var children := node.get_children()
	for i in range(children.size()):
		var child := children[i]
		var is_last := (i == children.size() - 1)
		var connector := "└── " if is_last else "├── "
		var child_prefix := prefix + ("    " if is_last else "│   ")

		var meta_info := ""
		if child.has_meta("type"):
			meta_info = " [%s HP:%d]" % [child.get_meta("type"), child.get_meta("health")]

		print("%s%s%s%s" % [prefix, connector, child.name, meta_info])
		print_tree_pretty(child, child_prefix)
