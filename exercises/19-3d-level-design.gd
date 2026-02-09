# 챕터 19: 3D 레벨 디자인
#
# 이 챕터에서는 다음을 학습합니다:
# - GridMap을 이용한 타일 기반 레벨 구축
# - NavigationAgent3D로 AI 경로 탐색
# - 스폰 포인트 시스템 설계
# - 씬 전환(Scene Transition) 처리
# - 레벨 데이터 저장/불러오기

extends Node3D


# ============================================================
# 연습 1: GridMap 배치
# ============================================================
# GridMap은 3D 타일맵으로, 격자 기반 레벨을 효율적으로 구축합니다.
# MeshLibrary에 등록된 타일을 격자 좌표에 배치합니다.

func create_gridmap_config() -> Dictionary:
	# TODO: GridMap 설정을 Dictionary로 반환하세요
	#
	# 반환 형식:
	# {
	#   "node_type": "GridMap",
	#   "cell_size": Vector3(2.0, 2.0, 2.0),
	#   "cell_center_x": true,
	#   "cell_center_y": false,
	#   "cell_center_z": true,
	#   "mesh_library_items": [
	#     {"id": 0, "name": "Floor", "description": "바닥 타일"},
	#     {"id": 1, "name": "Wall", "description": "벽 타일"},
	#     {"id": 2, "name": "Pillar", "description": "기둥"},
	#     {"id": 3, "name": "Stairs", "description": "계단"},
	#     {"id": 4, "name": "Door", "description": "문"}
	#   ],
	#   "code_examples": {
	#     "set_cell": "gridmap.set_cell_item(Vector3i(x, y, z), item_id)",
	#     "get_cell": "var item = gridmap.get_cell_item(Vector3i(x, y, z))",
	#     "clear_cell": "gridmap.set_cell_item(Vector3i(x, y, z), -1)",
	#     "world_to_map": "var map_pos = gridmap.local_to_map(world_pos)",
	#     "map_to_world": "var world_pos = gridmap.map_to_local(Vector3i(x, y, z))"
	#   }
	# }
	var config = {}  # 여기를 수정하세요
	return config

func generate_room_layout(width: int, depth: int, height: int) -> Dictionary:
	# TODO: 방 레이아웃을 GridMap 셀 데이터로 생성하세요
	# width, depth: 방의 가로, 세로 크기 (타일 단위, 최소 3)
	# height: 벽 높이 (타일 단위, 최소 2)
	#
	# width, depth를 최소 3, height를 최소 2로 클램프하세요
	#
	# 생성 규칙:
	# 1. 바닥 (y=0): 0~width-1, 0~depth-1 전체를 Floor(id=0)로 채움
	# 2. 벽 (y=0~height-1):
	#    x=0 또는 x=width-1 또는 z=0 또는 z=depth-1인 테두리를 Wall(id=1)로 채움
	#    단, y=0인 바닥 레이어 테두리도 Wall로 덮어씌움
	# 3. 문 (y=0, y=1):
	#    z=depth/2 위치의 x=0 (왼쪽 벽)에 Door(id=4)를 배치
	#
	# 반환 형식:
	# {
	#   "width": width,
	#   "depth": depth,
	#   "height": height,
	#   "cells": [
	#     {"position": Vector3i(x, y, z), "item_id": id, "item_name": 이름},
	#     ...
	#   ],
	#   "total_cells": cells 배열 크기,
	#   "floor_count": 바닥 타일 수,
	#   "wall_count": 벽 타일 수,
	#   "door_position": 문 위치 Vector3i
	# }
	var layout = {}  # 여기를 수정하세요
	return layout


# ============================================================
# 연습 2: NavigationAgent3D 경로 탐색
# ============================================================
# NavigationAgent3D는 네비게이션 메시 위에서 최적 경로를 계산합니다.
# AI 적 캐릭터의 이동, 순찰 등에 사용됩니다.

func create_navigation_config() -> Dictionary:
	# TODO: NavigationAgent3D 설정을 Dictionary로 반환하세요
	#
	# 반환 형식:
	# {
	#   "node_type": "NavigationAgent3D",
	#   "path_desired_distance": 1.0 (경로점 도달 판정 거리),
	#   "target_desired_distance": 1.0 (목표 도달 판정 거리),
	#   "path_max_distance": 3.0 (경로 이탈 재계산 거리),
	#   "avoidance_enabled": true,
	#   "radius": 0.5,
	#   "height": 1.8,
	#   "max_speed": 5.0,
	#   "navigation_layers": 1,
	#   "signals": [
	#     "navigation_finished",
	#     "velocity_computed",
	#     "path_changed",
	#     "target_reached"
	#   ],
	#   "code_example": "agent.target_position = target\nvar next = agent.get_next_path_position()\nvar dir = (next - global_position).normalized()\nvelocity = dir * speed"
	# }
	var config = {}  # 여기를 수정하세요
	return config

func simulate_pathfinding(
	start: Vector3,
	end: Vector3,
	obstacles: Array  # [{"position": Vector3, "radius": float}, ...]
) -> Dictionary:
	# TODO: 간단한 경로 탐색을 시뮬레이션하세요
	# 실제 NavigationServer를 사용하지 않고, 직선 경로와 장애물 회피를 계산합니다
	#
	# 1. 직선 거리: start.distance_to(end)
	# 2. 경유점(waypoints) 생성:
	#    - 시작점 추가
	#    - 각 obstacle 확인: 직선 경로(start->end)에서 장애물과의 거리가
	#      radius + 0.5 이내이면 우회점 추가
	#      우회점 = obstacle.position + (obstacle.position에서 직선까지의 수직 방향) * (radius + 1.0)
	#    - 간소화: 각 장애물에 대해 측면으로 우회하는 점 추가
	#      obstacle_to_line 방향의 수직 벡터로 (radius + 1.0)만큼 이동
	#    - 끝점 추가
	# 3. 경로 길이: waypoints 사이 거리 합산
	#
	# 간소화된 우회 알고리즘:
	# direction = (end - start).normalized()
	# right = Vector3(direction.z, 0, -direction.x) (수평 직교 벡터)
	# 장애물이 경로 위에 있으면 right 방향으로 우회
	#
	# 반환 형식:
	# {
	#   "start": start,
	#   "end": end,
	#   "direct_distance": 직선 거리,
	#   "waypoints": 경유점 배열,
	#   "path_length": 실제 경로 길이,
	#   "obstacle_count": 장애물 수,
	#   "detour_needed": 우회 필요 여부,
	#   "path_efficiency": direct_distance / path_length (1.0이면 직선)
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 3: 스폰 포인트 시스템
# ============================================================
# 스폰 포인트는 플레이어, 적, 아이템이 생성되는 위치입니다.
# 게임 모드에 따라 스폰 위치 선택 로직이 달라집니다.

var spawn_points: Array = []

func register_spawn_point(
	point_name: String,
	position: Vector3,
	point_type: String,  # "player", "enemy", "item", "boss"
	team: int            # 0: 중립, 1: 팀1, 2: 팀2
) -> Dictionary:
	# TODO: 스폰 포인트를 등록하세요
	#
	# 1. 스폰 포인트 데이터를 생성:
	# {
	#   "name": point_name,
	#   "position": position,
	#   "type": point_type,
	#   "team": team,
	#   "is_occupied": false,
	#   "cooldown": 0.0,
	#   "total_spawns": 0
	# }
	#
	# 2. spawn_points 배열에 추가
	#
	# 반환 형식:
	# {
	#   "registered": true,
	#   "spawn_point": 생성된 데이터,
	#   "total_points": 전체 스폰 포인트 수
	# }
	var result = {}  # 여기를 수정하세요
	return result

func find_best_spawn_point(
	point_type: String,
	team: int,
	avoid_position: Vector3,  # 이 위치에서 가장 먼 포인트 선택 (적 스폰 등)
	min_distance: float       # 최소 거리 제한
) -> Dictionary:
	# TODO: 조건에 맞는 최적의 스폰 포인트를 찾으세요
	#
	# 조건:
	# 1. point_type이 일치해야 함
	# 2. team이 일치해야 함 (team이 0이면 모든 팀 허용)
	# 3. is_occupied가 false여야 함
	# 4. avoid_position과의 거리가 min_distance 이상이어야 함
	#
	# 최적 선택: 조건을 만족하는 포인트 중 avoid_position과 가장 먼 포인트
	#
	# 반환 형식:
	# {
	#   "found": 포인트를 찾았는지,
	#   "spawn_point": 찾은 포인트 데이터 (못 찾으면 null),
	#   "distance_from_avoid": 회피 위치와의 거리 (못 찾으면 -1.0),
	#   "candidates_count": 조건을 만족한 후보 수
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 4: 씬 전환
# ============================================================
# 레벨 간 이동, 메뉴-게임 전환 등 씬을 교체하는 방법입니다.
# 페이드 인/아웃 효과와 로딩 화면을 포함합니다.

func create_scene_transition_config(transition_type: String) -> Dictionary:
	# TODO: 씬 전환 설정을 Dictionary로 반환하세요
	# transition_type: "instant", "fade", "slide", "loading_screen"
	#
	# 반환 형식:
	# {
	#   "transition_type": transition_type,
	#   "properties": 유형별 속성,
	#   "code_example": 구현 코드 문자열,
	#   "steps": 전환 단계 배열
	# }
	#
	# "instant":
	#   properties: {}
	#   steps: ["get_tree().change_scene_to_file(path)"]
	#   code_example: "get_tree().change_scene_to_file(\"res://levels/level2.tscn\")"
	#
	# "fade":
	#   properties: {
	#     "fade_out_duration": 0.5,
	#     "fade_in_duration": 0.5,
	#     "color": Color(0, 0, 0)
	#   }
	#   steps: [
	#     "1. 페이드 아웃 (화면을 어둡게)",
	#     "2. 씬 교체",
	#     "3. 페이드 인 (화면을 밝게)"
	#   ]
	#   code_example: "var tween = create_tween()\ntween.tween_property(fade_rect, \"color:a\", 1.0, 0.5)\ntween.tween_callback(get_tree().change_scene_to_file.bind(path))\ntween.tween_property(fade_rect, \"color:a\", 0.0, 0.5)"
	#
	# "slide":
	#   properties: {
	#     "direction": "left",
	#     "duration": 0.8
	#   }
	#   steps: [
	#     "1. 새 씬을 화면 밖에서 슬라이드 인",
	#     "2. 현재 씬을 반대 방향으로 슬라이드 아웃",
	#     "3. 이전 씬 제거"
	#   ]
	#   code_example: "# AnimationPlayer로 슬라이드 전환 구현"
	#
	# "loading_screen":
	#   properties: {
	#     "loading_scene": "res://ui/loading_screen.tscn",
	#     "min_display_time": 1.0,
	#     "show_progress": true
	#   }
	#   steps: [
	#     "1. 로딩 화면 표시",
	#     "2. ResourceLoader.load_threaded_request(path) 호출",
	#     "3. ResourceLoader.load_threaded_get_status()로 진행률 확인",
	#     "4. 로딩 완료 시 ResourceLoader.load_threaded_get()으로 리소스 획득",
	#     "5. get_tree().change_scene_to_packed(scene) 호출",
	#     "6. 로딩 화면 제거"
	#   ]
	#   code_example: "ResourceLoader.load_threaded_request(path)\n# _process에서:\nvar status = ResourceLoader.load_threaded_get_status(path, progress)\nif status == ResourceLoader.THREAD_LOAD_LOADED:\n    var scene = ResourceLoader.load_threaded_get(path)\n    get_tree().change_scene_to_packed(scene)"
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 5: 레벨 데이터 저장/불러오기
# ============================================================
# 레벨의 상태(오브젝트 위치, 열린 문, 수집한 아이템 등)를
# 파일로 저장하고 불러오는 시스템입니다.

func create_level_save_data(level_name: String, objects: Array) -> Dictionary:
	# TODO: 레벨 상태를 저장 가능한 형식으로 변환하세요
	# level_name: 레벨 이름
	# objects: 레벨의 오브젝트 배열
	#   [{"name": "Chest1", "position": Vector3, "type": "chest", "opened": false}, ...]
	#
	# 반환 형식:
	# {
	#   "save_version": 1,
	#   "level_name": level_name,
	#   "timestamp": Time.get_datetime_string_from_system(),
	#   "objects": 오브젝트 데이터 배열 (위치를 Dictionary로 변환),
	#   "object_count": 오브젝트 수,
	#   "save_path": "user://saves/{level_name}_save.json",
	#   "code_save": 저장 코드 문자열,
	#   "code_load": 불러오기 코드 문자열
	# }
	#
	# 오브젝트 위치 변환:
	# Vector3(x, y, z) -> {"x": x, "y": y, "z": z}
	# (JSON은 Vector3를 직접 지원하지 않으므로)
	#
	# code_save:
	# "var file = FileAccess.open(path, FileAccess.WRITE)\nfile.store_string(JSON.stringify(data))\nfile.close()"
	#
	# code_load:
	# "var file = FileAccess.open(path, FileAccess.READ)\nvar json = JSON.new()\njson.parse(file.get_as_text())\nvar data = json.data\nfile.close()"
	var save_data = {}  # 여기를 수정하세요
	return save_data

func serialize_vector3(vec: Vector3) -> Dictionary:
	# TODO: Vector3를 JSON 호환 Dictionary로 변환하세요
	# {"x": vec.x, "y": vec.y, "z": vec.z}
	var result = {}  # 여기를 수정하세요
	return result

func deserialize_vector3(data: Dictionary) -> Vector3:
	# TODO: Dictionary를 Vector3로 복원하세요
	# data에 "x", "y", "z" 키가 없으면 0.0을 기본값으로 사용
	var vec = Vector3.ZERO  # 여기를 수정하세요
	return vec


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 19: 3D 레벨 디자인 ===")
	print("")

	# 테스트 1: GridMap
	print("--- 연습 1: GridMap 배치 ---")
	var gm_config = create_gridmap_config()
	print("결과 1-1 (GridMap 설정):", gm_config)
	var room = generate_room_layout(5, 6, 3)
	print("결과 1-2 (방 레이아웃):")
	if room.has("total_cells"):
		print("  총 셀:", room["total_cells"])
	if room.has("floor_count"):
		print("  바닥:", room["floor_count"])
	if room.has("wall_count"):
		print("  벽:", room["wall_count"])
	if room.has("door_position"):
		print("  문 위치:", room["door_position"])
	print("")

	# 테스트 2: NavigationAgent3D
	print("--- 연습 2: 경로 탐색 ---")
	var nav_config = create_navigation_config()
	print("결과 2-1 (내비게이션 설정):", nav_config)
	var path1 = simulate_pathfinding(
		Vector3.ZERO, Vector3(20, 0, 0),
		[{"position": Vector3(10, 0, 0), "radius": 2.0}]
	)
	print("결과 2-2 (장애물 1개 경로):", path1)
	if path1.has("detour_needed"):
		print("  우회 필요:", path1["detour_needed"], " (기대값: true)")
	if path1.has("path_efficiency"):
		print("  효율:", path1["path_efficiency"])

	var path2 = simulate_pathfinding(
		Vector3.ZERO, Vector3(10, 0, 10), []
	)
	print("결과 2-3 (장애물 없는 경로):", path2)
	if path2.has("detour_needed"):
		print("  우회 필요:", path2["detour_needed"], " (기대값: false)")
	print("")

	# 테스트 3: 스폰 포인트
	print("--- 연습 3: 스폰 포인트 ---")
	spawn_points = []
	register_spawn_point("SpawnA", Vector3(0, 0, 0), "player", 1)
	register_spawn_point("SpawnB", Vector3(20, 0, 0), "player", 1)
	register_spawn_point("SpawnC", Vector3(40, 0, 0), "player", 2)
	register_spawn_point("EnemySpawn1", Vector3(10, 0, 10), "enemy", 0)
	register_spawn_point("EnemySpawn2", Vector3(30, 0, -10), "enemy", 0)
	print("결과 3-1 (등록된 포인트):", spawn_points.size(), " (기대값: 5)")

	var best_spawn = find_best_spawn_point("player", 1, Vector3.ZERO, 5.0)
	print("결과 3-2 (최적 스폰):", best_spawn)
	if best_spawn.has("spawn_point") and best_spawn["spawn_point"] != null:
		print("  선택:", best_spawn["spawn_point"]["name"], " (기대값: SpawnB)")

	var enemy_spawn = find_best_spawn_point("enemy", 0, Vector3.ZERO, 0.0)
	print("결과 3-3 (적 스폰):", enemy_spawn)
	print("")

	# 테스트 4: 씬 전환
	print("--- 연습 4: 씬 전환 ---")
	var trans_fade = create_scene_transition_config("fade")
	var trans_load = create_scene_transition_config("loading_screen")
	print("결과 4-1 (페이드 전환):", trans_fade)
	if trans_fade.has("steps"):
		print("  단계 수:", trans_fade["steps"].size(), " (기대값: 3)")
	print("결과 4-2 (로딩 전환):", trans_load)
	if trans_load.has("steps"):
		print("  단계 수:", trans_load["steps"].size(), " (기대값: 6)")
	print("")

	# 테스트 5: 레벨 데이터
	print("--- 연습 5: 레벨 데이터 ---")
	var test_objects = [
		{"name": "Chest1", "position": Vector3(5, 0, 3), "type": "chest", "opened": false},
		{"name": "Enemy1", "position": Vector3(10, 0, -5), "type": "enemy", "health": 100},
		{"name": "Key1", "position": Vector3(2, 1, 8), "type": "item", "collected": true}
	]
	var save = create_level_save_data("dungeon_01", test_objects)
	print("결과 5-1 (저장 데이터):", save)
	if save.has("save_path"):
		print("  저장 경로:", save["save_path"])

	var ser_vec = serialize_vector3(Vector3(1.5, 2.0, -3.5))
	print("결과 5-2 (직렬화):", ser_vec, " (기대값: {x:1.5, y:2, z:-3.5})")

	var deser_vec = deserialize_vector3({"x": 1.5, "y": 2.0, "z": -3.5})
	print("결과 5-3 (역직렬화):", deser_vec, " (기대값: (1.5, 2, -3.5))")

	var deser_empty = deserialize_vector3({})
	print("결과 5-4 (빈 데이터):", deser_empty, " (기대값: (0, 0, 0))")
	print("")

	print("=== 챕터 19 완료 ===")
