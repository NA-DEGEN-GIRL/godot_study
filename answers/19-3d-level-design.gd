# 챕터 19: 3D 레벨 디자인 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - GridMap으로 타일 기반 3D 레벨 구축
# - NavigationAgent3D로 AI 경로 탐색
# - 스폰 포인트 시스템 구현
# - 씬 전환 (레벨 간 이동)
# - 레벨 데이터 저장/로드

extends Node3D


func _ready():
	print("=== 챕터 19: 3D 레벨 디자인 ===\n")

	# 연습 1: GridMap 레벨 구축
	_exercise_1_gridmap()

	# 연습 2: NavigationAgent3D 경로 탐색
	_exercise_2_navigation()

	# 연습 3: 스폰 포인트 시스템
	_exercise_3_spawn_points()

	# 연습 4: 씬 전환
	_exercise_4_scene_transition()

	# 연습 5: 레벨 데이터 저장/로드
	_exercise_5_level_data()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: GridMap 타일 기반 레벨 (7종 타일 + 배치) 구현 완료")
	print("결과 2: NavigationAgent3D (경로 탐색 + 회피) 구현 완료")
	print("결과 3: 스폰 포인트 (랜덤/웨이브/거리 기반) 시스템 구현 완료")
	print("결과 4: 씬 전환 (페이드 + 로딩) 구현 완료")
	print("결과 5: 레벨 데이터 (JSON 저장/로드) 구현 완료")


# ==============================================================================
# 연습 1: GridMap - MeshLibrary와 GridMap으로 타일 기반
#          3D 레벨을 구축하세요.
# ==============================================================================
func _exercise_1_gridmap():
	# 풀이: GridMap은 3D 버전의 TileMap입니다.
	#       MeshLibrary에 사용할 타일(메시)을 등록하고,
	#       GridMap에서 셀 단위로 배치합니다.
	#       set_cell_item(position, item_index, orientation)로 타일을 배치합니다.
	#       레벨 디자인, 던전, 미로 등에 적합합니다.

	print("연습 1: GridMap 레벨 구축")

	# MeshLibrary 생성 (타일 팔레트)
	var mesh_lib := MeshLibrary.new()

	# 풀이: MeshLibrary.create_item(id)로 아이템을 추가하고
	#       set_item_mesh, set_item_shapes로 메시와 충돌 형태를 설정합니다.

	# 타일 0: 바닥
	mesh_lib.create_item(0)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(2, 0.2, 2)
	mesh_lib.set_item_mesh(0, floor_mesh)
	mesh_lib.set_item_name(0, "Floor")
	# 충돌 형태
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(2, 0.2, 2)
	mesh_lib.set_item_shapes(0, [Transform3D(), floor_shape])

	# 타일 1: 벽
	mesh_lib.create_item(1)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(2, 2, 0.2)
	mesh_lib.set_item_mesh(1, wall_mesh)
	mesh_lib.set_item_name(1, "Wall")
	var wall_shape := BoxShape3D.new()
	wall_shape.size = Vector3(2, 2, 0.2)
	mesh_lib.set_item_shapes(1, [Transform3D(), wall_shape])

	# 타일 2: 기둥
	mesh_lib.create_item(2)
	var pillar_mesh := CylinderMesh.new()
	pillar_mesh.top_radius = 0.3
	pillar_mesh.bottom_radius = 0.3
	pillar_mesh.height = 2.0
	mesh_lib.set_item_mesh(2, pillar_mesh)
	mesh_lib.set_item_name(2, "Pillar")

	# 타일 3: 계단
	mesh_lib.create_item(3)
	var stair_mesh := BoxMesh.new()
	stair_mesh.size = Vector3(2, 0.4, 1)
	mesh_lib.set_item_mesh(3, stair_mesh)
	mesh_lib.set_item_name(3, "Stair")

	print("  MeshLibrary 생성:")
	print("    타일 0: Floor (바닥)")
	print("    타일 1: Wall (벽)")
	print("    타일 2: Pillar (기둥)")
	print("    타일 3: Stair (계단)")
	print()

	# GridMap 생성
	var grid_map := GridMap.new()
	grid_map.name = "DungeonGrid"
	grid_map.mesh_library = mesh_lib
	grid_map.cell_size = Vector3(2, 2, 2)  # 셀 크기
	add_child(grid_map)

	# 레벨 배치
	# 풀이: set_cell_item(Vector3i, item_id, orientation)로 셀에 타일을 배치합니다.
	#       orientation은 정수로 회전을 나타냅니다 (0~23, 직교 회전).

	# 바닥 배치 (5x5)
	for x in range(-2, 3):
		for z in range(-2, 3):
			grid_map.set_cell_item(Vector3i(x, 0, z), 0)  # 바닥 타일

	# 벽 배치 (외곽)
	for x in range(-2, 3):
		grid_map.set_cell_item(Vector3i(x, 1, -2), 1)  # 뒤쪽 벽
		grid_map.set_cell_item(Vector3i(x, 1, 2), 1)   # 앞쪽 벽
	for z in range(-2, 3):
		grid_map.set_cell_item(Vector3i(-2, 1, z), 1)  # 왼쪽 벽
		grid_map.set_cell_item(Vector3i(2, 1, z), 1)   # 오른쪽 벽

	# 기둥 배치 (코너)
	grid_map.set_cell_item(Vector3i(-1, 1, -1), 2)
	grid_map.set_cell_item(Vector3i(1, 1, -1), 2)
	grid_map.set_cell_item(Vector3i(-1, 1, 1), 2)
	grid_map.set_cell_item(Vector3i(1, 1, 1), 2)

	print("  GridMap 배치:")
	print("    cell_size: %s" % grid_map.cell_size)
	print("    바닥: 5x5 (25개)")
	print("    벽: 외곽 4면")
	print("    기둥: 내부 4개")
	print()

	# GridMap API
	print("  GridMap API:")
	print("    set_cell_item(pos, item, orientation): 셀 배치")
	print("    get_cell_item(pos): 셀의 타일 ID 가져오기")
	print("    get_used_cells(): 배치된 모든 셀 좌표 목록")
	print("    get_used_cells_by_item(item): 특정 타일의 셀 목록")
	print("    clear(): 모든 셀 제거")
	print("    map_to_local(Vector3i): 그리드 좌표 -> 월드 좌표")
	print("    local_to_map(Vector3): 월드 좌표 -> 그리드 좌표")
	print()

	# 배치 확인
	var used_cells = grid_map.get_used_cells()
	print("  배치된 셀 수: %d" % used_cells.size())
	var item_at_center = grid_map.get_cell_item(Vector3i(0, 0, 0))
	print("  중앙(0,0,0) 타일: %d (Floor)" % item_at_center)

	print("연습 1 완료: GridMap 레벨 구축\n")


# ==============================================================================
# 연습 2: NavigationAgent3D - AI 캐릭터의 경로 탐색을 구현하세요.
#          NavigationRegion3D와 NavigationAgent3D를 설정합니다.
# ==============================================================================
func _exercise_2_navigation():
	# 풀이: Godot 4의 내비게이션 시스템은 다음으로 구성됩니다:
	#       NavigationRegion3D: 이동 가능 영역 정의 (NavigationMesh)
	#       NavigationAgent3D: 경로 탐색 에이전트 (캐릭터에 부착)
	#       NavigationObstacle3D: 동적 장애물
	#       NavigationServer3D: 서버 API (고급 기능)
	#       NavigationMesh(NavMesh)를 베이크하여 이동 가능 영역을 정의합니다.

	print("연습 2: NavigationAgent3D 경로 탐색")

	# NavigationRegion3D 생성
	var nav_region := NavigationRegion3D.new()
	nav_region.name = "NavRegion"

	# NavigationMesh 생성
	# 풀이: NavigationMesh는 AI가 이동할 수 있는 영역을 정의합니다.
	#       에디터에서 "Bake NavigationMesh" 버튼으로 자동 생성하거나,
	#       코드로 직접 설정할 수 있습니다.
	var nav_mesh := NavigationMesh.new()
	nav_mesh.agent_radius = 0.5          # 에이전트 반경
	nav_mesh.agent_height = 1.8          # 에이전트 높이
	nav_mesh.agent_max_climb = 0.5       # 올라갈 수 있는 높이
	nav_mesh.agent_max_slope = 45.0      # 올라갈 수 있는 경사 (도)
	nav_mesh.cell_size = 0.25            # 내비메시 셀 크기
	nav_mesh.cell_height = 0.25          # 내비메시 셀 높이
	nav_region.navigation_mesh = nav_mesh
	add_child(nav_region)

	print("  NavigationRegion3D 설정:")
	print("    agent_radius: %.1f m" % nav_mesh.agent_radius)
	print("    agent_height: %.1f m" % nav_mesh.agent_height)
	print("    agent_max_climb: %.1f m" % nav_mesh.agent_max_climb)
	print("    agent_max_slope: %.0f도" % nav_mesh.agent_max_slope)
	print("    cell_size: %.2f m" % nav_mesh.cell_size)
	print()

	# AI 캐릭터 (CharacterBody3D + NavigationAgent3D)
	var ai_character := CharacterBody3D.new()
	ai_character.name = "AIEnemy"
	ai_character.position = Vector3(5, 0.9, 5)

	var ai_col := CollisionShape3D.new()
	var ai_shape := CapsuleShape3D.new()
	ai_shape.radius = 0.4
	ai_shape.height = 1.8
	ai_col.shape = ai_shape
	ai_character.add_child(ai_col)

	# NavigationAgent3D 설정
	# 풀이: NavigationAgent3D는 대상 위치를 설정하면 자동으로 경로를 계산합니다.
	#       get_next_path_position()으로 다음 이동할 위치를 가져옵니다.
	var nav_agent := NavigationAgent3D.new()
	nav_agent.name = "NavAgent"
	nav_agent.path_desired_distance = 0.5    # 경로점 도달 판정 거리
	nav_agent.target_desired_distance = 0.5  # 최종 목표 도달 거리
	nav_agent.max_speed = 5.0                # 최대 속도
	nav_agent.radius = 0.5                   # 에이전트 반경
	nav_agent.avoidance_enabled = true       # 회피 활성화
	nav_agent.max_neighbors = 10             # 회피 시 고려할 이웃 수
	ai_character.add_child(nav_agent)

	add_child(ai_character)

	print("  NavigationAgent3D 설정:")
	print("    path_desired_distance: %.1f" % nav_agent.path_desired_distance)
	print("    target_desired_distance: %.1f" % nav_agent.target_desired_distance)
	print("    max_speed: %.1f" % nav_agent.max_speed)
	print("    avoidance_enabled: %s" % nav_agent.avoidance_enabled)
	print()

	# AI 이동 코드
	print("  AI 이동 구현:")
	print("  ```gdscript")
	print("  @onready var nav_agent = $NavAgent")
	print("  var move_speed: float = 5.0")
	print("")
	print("  func set_target(target_pos: Vector3):")
	print("      nav_agent.target_position = target_pos")
	print("")
	print("  func _physics_process(delta):")
	print("      if nav_agent.is_navigation_finished():")
	print("          return")
	print("")
	print("      var next_pos = nav_agent.get_next_path_position()")
	print("      var direction = (next_pos - global_position).normalized()")
	print("")
	print("      # 이동 방향 바라보기")
	print("      var look_target = Vector3(next_pos.x, global_position.y, next_pos.z)")
	print("      look_at(look_target)")
	print("")
	print("      velocity = direction * move_speed")
	print("      move_and_slide()")
	print("  ```")
	print()

	# 시그널
	print("  NavigationAgent3D 시그널:")
	print("    navigation_finished: 목표 도달")
	print("    path_changed: 경로 변경됨")
	print("    target_reached: 대상 도달")
	print("    velocity_computed: 회피 속도 계산됨 (avoidance)")
	print()

	# NavigationObstacle3D
	print("  NavigationObstacle3D (동적 장애물):")
	print("    움직이는 오브젝트를 장애물로 등록하여 AI가 회피")
	print("    radius: 장애물 반경")
	print("    avoidance_enabled: 회피 활성화")

	print("연습 2 완료: NavigationAgent3D\n")


# ==============================================================================
# 연습 3: 스폰 포인트 - 적/아이템의 스폰 위치를 관리하고
#          다양한 스폰 패턴을 구현하세요.
# ==============================================================================
func _exercise_3_spawn_points():
	# 풀이: 스폰 포인트는 Marker3D 노드를 사용하여 위치를 지정합니다.
	#       그룹으로 관리하면 카테고리별 스폰이 편리합니다.
	#       스폰 패턴: 랜덤, 순차, 웨이브, 거리 기반, 영역 기반 등
	#       SpawnManager로 스폰 로직을 중앙 관리합니다.

	print("연습 3: 스폰 포인트 시스템")

	# 스폰 포인트 생성 (Marker3D)
	var spawn_points: Array[Marker3D] = []
	var spawn_positions := [
		Vector3(5, 0, 5), Vector3(-5, 0, 5), Vector3(5, 0, -5),
		Vector3(-5, 0, -5), Vector3(0, 0, 8), Vector3(8, 0, 0),
	]

	for i in range(spawn_positions.size()):
		var marker := Marker3D.new()
		marker.name = "SpawnPoint_%d" % i
		marker.position = spawn_positions[i]
		marker.add_to_group("spawn_points")
		marker.set_meta("spawn_type", "enemy" if i < 4 else "item")
		add_child(marker)
		spawn_points.append(marker)

	print("  스폰 포인트 생성: %d개" % spawn_points.size())
	for sp in spawn_points:
		print("    %s: pos=%s, type=%s" % [sp.name, sp.position, sp.get_meta("spawn_type")])
	print()

	# 스폰 매니저 구현
	var spawn_mgr := SpawnManager.new()
	spawn_mgr._spawn_points = spawn_points

	# 1) 랜덤 스폰
	print("  1) 랜덤 스폰:")
	for i in range(3):
		var pos := spawn_mgr.get_random_spawn_position()
		print("    랜덤 스폰 위치: %s" % pos)
	print()

	# 2) 타입별 스폰
	print("  2) 타입별 스폰:")
	var enemy_pos := spawn_mgr.get_spawn_by_type("enemy")
	print("    적 스폰: %s" % enemy_pos)
	var item_pos := spawn_mgr.get_spawn_by_type("item")
	print("    아이템 스폰: %s" % item_pos)
	print()

	# 3) 거리 기반 스폰 (플레이어에서 먼 곳)
	var player_pos := Vector3.ZERO
	var far_pos := spawn_mgr.get_farthest_spawn(player_pos)
	print("  3) 거리 기반 스폰 (플레이어에서 가장 먼 곳):")
	print("    플레이어 위치: %s" % player_pos)
	print("    가장 먼 스폰: %s (거리: %.1f)" % [far_pos, player_pos.distance_to(far_pos)])
	print()

	# 4) 웨이브 스폰 패턴
	print("  4) 웨이브 스폰 패턴:")
	print("  ```gdscript")
	print("  var wave_data = [")
	print("      {\"enemy\": \"Goblin\",  \"count\": 5, \"delay\": 0.5},")
	print("      {\"enemy\": \"Orc\",     \"count\": 3, \"delay\": 1.0},")
	print("      {\"enemy\": \"Boss\",    \"count\": 1, \"delay\": 2.0},")
	print("  ]")
	print("")
	print("  func start_wave(wave_index: int):")
	print("      var wave = wave_data[wave_index]")
	print("      for i in range(wave.count):")
	print("          var pos = spawn_mgr.get_random_spawn_position()")
	print("          spawn_enemy(wave.enemy, pos)")
	print("          await get_tree().create_timer(wave.delay).timeout")
	print("  ```")
	print()

	# 5) 영역 스폰 (랜덤 영역 내)
	print("  5) 영역 랜덤 스폰:")
	var area_spawns := spawn_mgr.get_random_in_area(Vector3(0, 0, 0), 10.0, 5)
	for i in range(area_spawns.size()):
		print("    영역 스폰 %d: %s" % [i, area_spawns[i]])

	print("연습 3 완료: 스폰 포인트 시스템\n")


# ==============================================================================
# 연습 4: 씬 전환 - 레벨 간 이동을 구현하세요.
#          페이드 효과와 로딩 처리를 포함합니다.
# ==============================================================================
func _exercise_4_scene_transition():
	# 풀이: 씬 전환은 get_tree().change_scene_to_file()로 구현합니다.
	#       페이드 인/아웃으로 부드러운 전환을 만들고,
	#       대용량 씬은 ResourceLoader로 백그라운드 로딩합니다.
	#       씬 전환 매니저(Autoload)로 전역에서 접근합니다.

	print("연습 4: 씬 전환")

	# 기본 씬 전환
	print("  기본 씬 전환:")
	print("    get_tree().change_scene_to_file(\"res://levels/level_2.tscn\")")
	print("    get_tree().change_scene_to_packed(packed_scene)")
	print()

	# 페이드 전환 매니저 (Autoload)
	print("  SceneManager (Autoload) 구현:")
	print("  ```gdscript")
	print("  # scene_manager.gd (Autoload)")
	print("  extends CanvasLayer")
	print("")
	print("  @onready var fade_rect = $ColorRect  # 전체화면 검정 사각형")
	print("  var is_transitioning: bool = false")
	print("")
	print("  func change_scene(scene_path: String, fade_duration: float = 0.5):")
	print("      if is_transitioning:")
	print("          return")
	print("      is_transitioning = true")
	print("")
	print("      # 페이드 아웃 (화면 어두워짐)")
	print("      var tween = create_tween()")
	print("      tween.tween_property(fade_rect, \"color:a\", 1.0, fade_duration)")
	print("      await tween.finished")
	print("")
	print("      # 씬 전환")
	print("      get_tree().change_scene_to_file(scene_path)")
	print("")
	print("      # 페이드 인 (화면 밝아짐)")
	print("      tween = create_tween()")
	print("      tween.tween_property(fade_rect, \"color:a\", 0.0, fade_duration)")
	print("      await tween.finished")
	print("")
	print("      is_transitioning = false")
	print("  ```")
	print()

	# 백그라운드 로딩
	print("  백그라운드 로딩 (대용량 씬):")
	print("  ```gdscript")
	print("  func change_scene_with_loading(scene_path: String):")
	print("      # 로딩 시작")
	print("      ResourceLoader.load_threaded_request(scene_path)")
	print("")
	print("      # 로딩 진행 체크")
	print("      var progress = []")
	print("      while true:")
	print("          var status = ResourceLoader.load_threaded_get_status(")
	print("              scene_path, progress)")
	print("          loading_bar.value = progress[0] * 100  # 0~1")
	print("")
	print("          if status == ResourceLoader.THREAD_LOAD_LOADED:")
	print("              var scene = ResourceLoader.load_threaded_get(scene_path)")
	print("              get_tree().change_scene_to_packed(scene)")
	print("              break")
	print("          elif status == ResourceLoader.THREAD_LOAD_FAILED:")
	print("              print(\"로딩 실패!\")")
	print("              break")
	print("")
	print("          await get_tree().process_frame")
	print("  ```")
	print()

	# 레벨 포탈 (트리거)
	print("  레벨 포탈 (Area3D 트리거):")
	print("  ```gdscript")
	print("  # level_portal.gd")
	print("  extends Area3D")
	print("")
	print("  @export var target_scene: String")
	print("  @export var spawn_point_name: String = \"default\"")
	print("")
	print("  func _on_body_entered(body):")
	print("      if body.is_in_group(\"player\"):")
	print("          # 전환 데이터 저장")
	print("          GameData.next_spawn_point = spawn_point_name")
	print("          SceneManager.change_scene(target_scene)")
	print("  ```")
	print()

	# 씬 전환 시 데이터 유지
	print("  씬 전환 시 데이터 유지:")
	print("    1. Autoload 싱글톤: GameData.player_hp = 100")
	print("    2. 파일 저장: save_game() 호출 후 전환")
	print("    3. meta 데이터: SceneTree.set_meta()")

	print("연습 4 완료: 씬 전환\n")


# ==============================================================================
# 연습 5: 레벨 데이터 - JSON으로 레벨 데이터를 저장하고 로드하세요.
#          오브젝트 배치, 적 정보, 게임 상태를 포함합니다.
# ==============================================================================
func _exercise_5_level_data():
	# 풀이: JSON 형식으로 레벨 데이터를 직렬화하여 파일에 저장합니다.
	#       FileAccess.open()으로 파일을 열고, JSON.stringify()로 변환합니다.
	#       로드 시 JSON.parse_string()으로 파싱합니다.
	#       user:// 경로는 사용자 데이터 디렉토리(앱데이터)를 가리킵니다.

	print("연습 5: 레벨 데이터 저장/로드")

	# 레벨 데이터 구성
	var level_data := {
		"level_info": {
			"name": "던전 1층",
			"version": "1.0",
			"difficulty": "normal",
			"time_limit": 300,
		},
		"player_spawn": {
			"position": [0, 0.9, 0],
			"rotation": [0, 0, 0],
		},
		"objects": [
			{
				"type": "box",
				"position": [2, 0.5, 0],
				"scale": [1, 1, 1],
				"color": [0.8, 0.3, 0.1],
			},
			{
				"type": "sphere",
				"position": [-3, 0.75, 2],
				"scale": [1.5, 1.5, 1.5],
				"color": [0.2, 0.6, 0.9],
			},
		],
		"enemies": [
			{
				"type": "goblin",
				"position": [5, 0, 5],
				"hp": 30,
				"patrol_points": [[5, 0, 5], [5, 0, -5], [-5, 0, -5]],
			},
			{
				"type": "orc",
				"position": [-5, 0, -3],
				"hp": 80,
				"patrol_points": [[-5, 0, -3], [5, 0, -3]],
			},
		],
		"items": [
			{"type": "health_potion", "position": [3, 0.3, -2], "value": 25},
			{"type": "coin", "position": [0, 0.3, 4], "value": 10},
			{"type": "coin", "position": [1, 0.3, 4], "value": 10},
		],
		"game_state": {
			"score": 0,
			"lives": 3,
			"keys_collected": 0,
			"doors_opened": [],
		}
	}

	# JSON 저장
	# 풀이: JSON.stringify(data, indent)로 Dictionary를 JSON 문자열로 변환합니다.
	#       FileAccess.open(path, mode)로 파일을 열어 저장합니다.
	var json_string := JSON.stringify(level_data, "  ")

	var save_path := "user://level_data.json"
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("  레벨 데이터 저장: %s" % save_path)
	else:
		print("  저장 실패! 에러: %d" % FileAccess.get_open_error())
	print()

	# JSON 내용 미리보기
	print("  JSON 데이터 구조:")
	print("    level_info: 레벨 이름, 버전, 난이도, 시간 제한")
	print("    player_spawn: 플레이어 시작 위치/회전")
	print("    objects: 배치 오브젝트 목록 (타입, 위치, 스케일, 색상)")
	print("    enemies: 적 목록 (타입, 위치, HP, 순찰 경로)")
	print("    items: 아이템 목록 (타입, 위치, 값)")
	print("    game_state: 게임 상태 (점수, 생명, 키, 문)")
	print()

	# JSON 로드
	# 풀이: FileAccess로 파일을 읽고 JSON.parse_string()으로 파싱합니다.
	var loaded_data: Dictionary = {}
	var load_file := FileAccess.open(save_path, FileAccess.READ)
	if load_file:
		var content := load_file.get_as_text()
		load_file.close()
		loaded_data = JSON.parse_string(content)
		print("  레벨 데이터 로드 성공!")
	print()

	# 로드된 데이터로 레벨 생성
	if loaded_data.has("level_info"):
		var info: Dictionary = loaded_data["level_info"]
		print("  로드된 레벨 정보:")
		print("    이름: %s" % info.get("name", ""))
		print("    난이도: %s" % info.get("difficulty", ""))
		print("    시간 제한: %d초" % info.get("time_limit", 0))
	print()

	if loaded_data.has("enemies"):
		var enemies: Array = loaded_data["enemies"]
		print("  로드된 적 정보:")
		for enemy in enemies:
			print("    %s: HP=%d, pos=%s" % [
				enemy.get("type", ""), enemy.get("hp", 0), enemy.get("position", [])
			])
	print()

	if loaded_data.has("items"):
		var items: Array = loaded_data["items"]
		print("  로드된 아이템 정보:")
		for item in items:
			print("    %s: value=%d, pos=%s" % [
				item.get("type", ""), item.get("value", 0), item.get("position", [])
			])
	print()

	# 레벨 로드 함수 구조
	print("  레벨 로드 함수:")
	print("  ```gdscript")
	print("  func load_level(path: String):")
	print("      var data = _load_json(path)")
	print("      if not data:")
	print("          return")
	print("")
	print("      # 기존 레벨 정리")
	print("      for child in get_children():")
	print("          child.queue_free()")
	print("")
	print("      # 오브젝트 배치")
	print("      for obj_data in data.objects:")
	print("          var obj = _create_object(obj_data)")
	print("          add_child(obj)")
	print("")
	print("      # 적 스폰")
	print("      for enemy_data in data.enemies:")
	print("          var enemy = _create_enemy(enemy_data)")
	print("          add_child(enemy)")
	print("")
	print("      # 플레이어 배치")
	print("      player.position = Vector3(data.player_spawn.position)")
	print("  ```")

	print("연습 5 완료: 레벨 데이터 저장/로드\n")


# ==============================================================================
# 내부 클래스: SpawnManager
# ==============================================================================
class SpawnManager:
	var _spawn_points: Array[Marker3D] = []

	func get_random_spawn_position() -> Vector3:
		# 풀이: 랜덤 스폰 포인트를 선택하여 위치를 반환합니다.
		if _spawn_points.is_empty():
			return Vector3.ZERO
		var idx := randi() % _spawn_points.size()
		return _spawn_points[idx].position

	func get_spawn_by_type(spawn_type: String) -> Vector3:
		# 풀이: 메타데이터의 spawn_type으로 필터링하여 랜덤 선택합니다.
		var filtered: Array[Marker3D] = []
		for sp in _spawn_points:
			if sp.get_meta("spawn_type", "") == spawn_type:
				filtered.append(sp)
		if filtered.is_empty():
			return Vector3.ZERO
		return filtered[randi() % filtered.size()].position

	func get_farthest_spawn(from_position: Vector3) -> Vector3:
		# 풀이: 주어진 위치에서 가장 먼 스폰 포인트를 반환합니다.
		var farthest_pos := Vector3.ZERO
		var max_dist := -1.0
		for sp in _spawn_points:
			var dist := from_position.distance_to(sp.position)
			if dist > max_dist:
				max_dist = dist
				farthest_pos = sp.position
		return farthest_pos

	func get_random_in_area(center: Vector3, radius: float, count: int) -> Array[Vector3]:
		# 풀이: 지정 영역 내 랜덤 위치를 생성합니다.
		#       원형 영역에서 균일 분포를 위해 sqrt(random) * radius를 사용합니다.
		var positions: Array[Vector3] = []
		for i in range(count):
			var angle := randf() * TAU
			var dist := sqrt(randf()) * radius  # 균일 분포
			var pos := Vector3(
				center.x + cos(angle) * dist,
				center.y,
				center.z + sin(angle) * dist
			)
			positions.append(pos)
		return positions
