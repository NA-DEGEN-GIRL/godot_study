# 챕터 10: 타일맵 & 레벨 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - TileMap의 set_cell로 코드로 타일 배치
# - local_to_map / map_to_local 좌표 변환
# - 씬 전환과 페이드 효과 구현
# - 레벨 데이터 구조 설계와 진행 관리
# - 체크포인트 시스템 구현

extends Node2D

# 레벨 관리 변수
var levels: Array[Dictionary] = []
var current_level_id: int = -1

# 체크포인트 변수
var current_checkpoint_id: int = -1
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_data: Dictionary = {}

# TileMap 참조
var tilemap: TileMap

func _ready():
	print("=== 챕터 10: 타일맵 & 레벨 ===\n")

	# TileMap 생성
	_setup_tilemap()

	# 연습 1: set_cell
	_exercise_1_set_cell()

	# 연습 2: 좌표 변환
	_exercise_2_coordinate_conversion()

	# 연습 3: 씬 전환
	_exercise_3_scene_transition()

	# 연습 4: 레벨 데이터
	_exercise_4_level_data()

	# 연습 5: 체크포인트
	_exercise_5_checkpoint()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: set_cell로 절차적 레벨 생성 완료 (30x10 타일)")
	print("결과 2: 좌표 변환 (local -> map -> local) 테스트 완료")
	print("결과 3: 씬 전환 (페이드 전환 시뮬레이션) 완료")
	print("결과 4: 레벨 데이터 - %d개 레벨, 진행 시뮬레이션 완료" % levels.size())
	print("결과 5: 체크포인트 - 마지막 체크포인트=%d, 부활 위치=%s" % [
		current_checkpoint_id, checkpoint_position
	])


func _setup_tilemap():
	tilemap = TileMap.new()
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tilemap.tile_set = tileset
	add_child(tilemap)


# ==============================================================================
# 연습 1: set_cell - 코드로 타일을 배치하고 절차적 레벨을 생성하세요.
# ==============================================================================
func _exercise_1_set_cell():
	# 풀이: tilemap.set_cell(layer, coords, source_id, atlas_coords)로 타일을 배치합니다.
	#       layer=레이어 인덱스, coords=Vector2i(맵 좌표), source_id=TileSet 소스 ID,
	#       atlas_coords=아틀라스 내 타일 위치입니다.
	#       erase_cell(layer, coords)로 타일을 제거합니다.
	#       source_id를 -1로 설정해도 타일이 제거됩니다.
	#       절차적 생성 시 2차원 배열로 레벨을 설계한 후 반복문으로 배치합니다.

	print("연습 1: set_cell - 절차적 레벨 생성")

	# set_cell 함수 시그니처 설명
	print("  set_cell(layer, coords, source_id, atlas_coords, alternative)")
	print("    layer        - 레이어 인덱스 (0부터)")
	print("    coords       - Vector2i 맵 좌표")
	print("    source_id    - TileSet 소스 ID (-1 = 타일 제거)")
	print("    atlas_coords - 아틀라스 내 위치 (Vector2i)")
	print()

	# 실제 배치 예시 (TileSet 소스가 없으므로 시뮬레이션)
	print("  사용 예시:")
	print("    tilemap.set_cell(0, Vector2i(3, 5), 0, Vector2i(0, 0))")
	print("    tilemap.erase_cell(0, Vector2i(3, 5))")
	print()

	# 타일 정보 조회
	var check = tilemap.get_cell_source_id(0, Vector2i(0, 0))
	print("  빈 타일 조회: source_id = %d (-1 = 빈 타일)" % check)
	print()

	# 절차적 레벨 생성 시뮬레이션
	var level_width = 30
	var level_height = 10
	var ground_y = 8

	# 2D 배열로 레벨 맵 생성
	var level_map: Array[Array] = []
	for y in range(level_height):
		var row: Array[int] = []
		row.resize(level_width)
		row.fill(0)
		level_map.append(row)

	# 바닥 생성
	for x in range(level_width):
		level_map[ground_y][x] = 1
		level_map[ground_y + 1][x] = 1

	# 플랫폼 생성
	var platforms = [
		{"x": 5, "y": 5, "width": 4},
		{"x": 12, "y": 6, "width": 3},
		{"x": 18, "y": 4, "width": 5},
		{"x": 25, "y": 5, "width": 3},
	]

	for plat in platforms:
		for dx in range(plat["width"]):
			var px = plat["x"] + dx
			if px < level_width:
				level_map[plat["y"]][px] = 2

	# 시각화 출력
	print("  절차적 레벨 (30x10):")
	for y in range(level_height):
		var row_str = "    "
		for x in range(level_width):
			match level_map[y][x]:
				0: row_str += "."
				1: row_str += "#"
				2: row_str += "="
		print(row_str)
	print("    범례: . = 빈 공간, # = 바닥, = = 플랫폼")
	print()

	# 실제 TileMap 배치 코드
	print("  실제 배치 코드 (TileSet이 있을 때):")
	print("    for y in range(level_height):")
	print("        for x in range(level_width):")
	print("            if level_map[y][x] == 1:")
	print("                tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))")
	print("            elif level_map[y][x] == 2:")
	print("                tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))")

	print("연습 1 완료: set_cell 타일 배치")


# ==============================================================================
# 연습 2: 좌표 변환 - local_to_map과 map_to_local로 좌표를 변환하세요.
# ==============================================================================
func _exercise_2_coordinate_conversion():
	# 풀이: tilemap.local_to_map(local_pos)은 로컬(픽셀) 좌표를 맵(타일) 좌표로 변환합니다.
	#       tilemap.map_to_local(map_pos)은 맵 좌표를 로컬 좌표(타일 중심)로 변환합니다.
	#       마우스 클릭 -> local_to_map -> 어떤 타일인지 확인하는 패턴이 자주 사용됩니다.
	#       get_surrounding_cells()로 인접 타일(4방향)을 가져올 수 있습니다.

	print("\n연습 2: 좌표 변환 (타일 크기: %s)" % tilemap.tile_set.tile_size)

	# 좌표 변환 예시
	var test_positions = [
		Vector2(0, 0),
		Vector2(8, 8),
		Vector2(16, 16),
		Vector2(24, 32),
		Vector2(100, 75),
		Vector2(-10, -10),
	]

	print("  로컬 -> 맵 -> 로컬(중심) 변환:")
	for pos in test_positions:
		var map_coord = tilemap.local_to_map(pos)
		var back_to_local = tilemap.map_to_local(map_coord)
		print("    로컬 %s -> 맵 %s -> 로컬(중심) %s" % [pos, map_coord, back_to_local])
	print()

	# 주변 타일 탐색
	var center = Vector2i(5, 5)
	var neighbors = tilemap.get_surrounding_cells(center)
	print("  주변 타일 (get_surrounding_cells):")
	print("    중심: %s" % center)
	for n in neighbors:
		var direction = Vector2i(n.x - center.x, n.y - center.y)
		print("    이웃 %s (방향: %s)" % [n, direction])
	print()

	# 8방향 탐색 (대각선 포함 - 수동 계산)
	print("  8방향 이웃 (대각선 포함):")
	var directions_8 = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]
	for d in directions_8:
		print("    %s + %s = %s" % [center, d, center + d])
	print()

	# 마우스 클릭 패턴
	print("  마우스로 타일 배치 패턴:")
	print("    func _input(event):")
	print("        if event is InputEventMouseButton:")
	print("            var local_pos = tilemap.to_local(event.position)")
	print("            var map_pos = tilemap.local_to_map(local_pos)")
	print("            if event.button_index == MOUSE_BUTTON_LEFT:")
	print("                tilemap.set_cell(0, map_pos, 0, Vector2i(0, 0))")
	print("            elif event.button_index == MOUSE_BUTTON_RIGHT:")
	print("                tilemap.erase_cell(0, map_pos)")

	print("연습 2 완료: 좌표 변환")


# ==============================================================================
# 연습 3: 씬 전환 - 페이드 인/아웃 전환을 시뮬레이션하고
#          ColorRect + Tween 패턴을 구현하세요.
# ==============================================================================
func _exercise_3_scene_transition():
	# 풀이: CanvasLayer(최상위 레이어) 위에 ColorRect(검정, alpha=0)를 배치합니다.
	#       전환 시 Tween으로 alpha를 0->1(페이드 아웃) 한 뒤 씬을 교체하고,
	#       다시 alpha를 1->0(페이드 인)으로 변경합니다.
	#       is_transitioning 플래그로 중복 전환을 방지합니다.
	#       CanvasLayer.layer = 100으로 모든 UI 위에 오버레이합니다.

	print("\n연습 3: 씬 전환 (페이드 효과)")

	# 페이드 오버레이 생성
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100

	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)  # 검정, 투명
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_rect)
	add_child(canvas_layer)

	print("  페이드 오버레이 생성:")
	print("    CanvasLayer.layer = 100 (최상위)")
	print("    ColorRect color = Color(0, 0, 0, 0) (검정, 투명)")
	print("    mouse_filter = MOUSE_FILTER_IGNORE (클릭 무시)")
	print()

	# 페이드 아웃 시뮬레이션
	print("  페이드 아웃 시뮬레이션 (0.5초):")
	_simulate_fade("out", 0.5)
	print()

	# 페이드 인 시뮬레이션
	print("  페이드 인 시뮬레이션 (0.5초):")
	_simulate_fade("in", 0.5)
	print()

	# 전체 전환 코드
	print("  SceneManager (Autoload) 전환 코드:")
	print("    var _fade_rect: ColorRect")
	print("    var _is_transitioning: bool = false")
	print()
	print("    func change_scene(path: String, duration := 0.5):")
	print("        if _is_transitioning: return")
	print("        _is_transitioning = true")
	print()
	print("        # 페이드 아웃")
	print("        var tween = create_tween()")
	print("        tween.tween_property(_fade_rect, \"color:a\", 1.0, duration)")
	print("        await tween.finished")
	print()
	print("        # 씬 전환")
	print("        get_tree().change_scene_to_file(path)")
	print("        await get_tree().process_frame")
	print()
	print("        # 페이드 인")
	print("        var tween2 = create_tween()")
	print("        tween2.tween_property(_fade_rect, \"color:a\", 0.0, duration)")
	print("        await tween2.finished")
	print("        _is_transitioning = false")
	print()

	# 씬 간 데이터 전달
	print("  씬 간 데이터 전달 방법:")
	print("    방법 1: Autoload 변수 (GameData.selected_level = 3)")
	print("    방법 2: 수동 전환 시 직접 설정 (scene.init_data = data)")
	print("    방법 3: Meta 데이터 (root.set_meta(\"key\", value))")

	canvas_layer.queue_free()
	print("연습 3 완료: 씬 전환 패턴 구현")


func _simulate_fade(direction: String, duration: float):
	var steps = 5
	for i in range(steps + 1):
		var t = float(i) / steps
		var alpha: float
		if direction == "out":
			alpha = t
		else:
			alpha = 1.0 - t
		var time_at = t * duration
		var desc = ""
		if alpha < 0.01:
			desc = "(투명)"
		elif alpha > 0.99:
			desc = "(불투명)"
		print("    t=%.2fs: alpha=%.2f %s" % [time_at, alpha, desc])


# ==============================================================================
# 연습 4: 레벨 데이터 - 레벨 진행 시스템을 구현하세요.
#          레벨 목록, 잠금 해제, 클리어 기록을 관리합니다.
# ==============================================================================
func _exercise_4_level_data():
	# 풀이: Dictionary로 각 레벨의 메타 정보(id, name, scene_path, unlocked,
	#       completed, best_time, stars)를 정의합니다.
	#       complete_level()에서 기록 갱신(더 좋은 것만)과 다음 레벨 잠금 해제를 처리합니다.
	#       serialize_progress() / deserialize_progress()로 진행 상태를 저장/복원합니다.

	print("\n연습 4: 레벨 데이터 구조")

	# 레벨 등록
	_register_levels()
	print("  등록된 레벨 수: %d" % levels.size())
	for level in levels:
		print("    [%d] %s - %s, %s" % [
			level.id, level.name,
			"OPEN" if level.unlocked else "LOCKED",
			"CLEAR" if level.completed else "-----"
		])
	print()

	# 레벨 0 플레이 시뮬레이션
	print("  [시뮬레이션] 레벨 0 시작")
	_start_level(0)
	print("    현재 레벨: %d (%s)" % [current_level_id, levels[current_level_id].name])

	# 레벨 0 클리어
	print("  [시뮬레이션] 레벨 0 클리어 (45.3초, 별 2개)")
	_complete_level(0, 2, 45.3)
	print()

	# 레벨 1 클리어
	_start_level(1)
	_complete_level(1, 3, 32.1)

	# 레벨 2 클리어
	_complete_level(2, 1, 78.5)

	print("  클리어 후 상태:")
	for level in levels:
		var lock = "OPEN" if level.unlocked else "LOCKED"
		var done = "CLEAR" if level.completed else "-----"
		var stars = "*".repeat(level.stars) + ".".repeat(3 - level.stars)
		var time_str = "%.1fs" % level.best_time if level.best_time >= 0 else "--.-s"
		print("    [%d] %-12s %6s %5s [%s] %s" % [
			level.id, level.name, lock, done, stars, time_str
		])
	print()

	# 기록 갱신 (더 좋은 기록만 유지)
	print("  레벨 0 재도전 (38.7초, 별 3개):")
	_complete_level(0, 3, 38.7)
	print("    갱신: 최고기록=%.1fs, 별=%d" % [levels[0].best_time, levels[0].stars])
	print()

	# 더 나쁜 기록은 무시
	print("  레벨 0 재도전 (55.0초, 별 1개):")
	_complete_level(0, 1, 55.0)
	print("    결과: 최고기록=%.1fs, 별=%d (변화 없음)" % [levels[0].best_time, levels[0].stars])
	print()

	# 전체 진행도
	var cleared = levels.filter(func(l): return l.completed).size()
	var total_stars = 0
	for l in levels:
		total_stars += l.stars
	print("  전체 진행도: %d/%d 레벨, 별 %d/%d" % [
		cleared, levels.size(), total_stars, levels.size() * 3
	])
	print()

	# 직렬화
	var save_data = _serialize_progress()
	print("  직렬화 결과:")
	for key in save_data:
		print("    %s: %s" % [key, save_data[key]])

	print("연습 4 완료: 레벨 데이터 시스템")


func _register_levels():
	levels.clear()
	levels.append({"id": 0, "name": "Green Hills", "scene_path": "res://levels/level_00.tscn",
		"unlocked": true, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 3})
	levels.append({"id": 1, "name": "Desert Ruins", "scene_path": "res://levels/level_01.tscn",
		"unlocked": false, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 4})
	levels.append({"id": 2, "name": "Ice Cave", "scene_path": "res://levels/level_02.tscn",
		"unlocked": false, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 5})
	levels.append({"id": 3, "name": "Lava Castle", "scene_path": "res://levels/level_03.tscn",
		"unlocked": false, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 3})
	levels.append({"id": 4, "name": "Sky Temple", "scene_path": "res://levels/level_04.tscn",
		"unlocked": false, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 6})
	levels.append({"id": 5, "name": "Final Boss", "scene_path": "res://levels/level_05.tscn",
		"unlocked": false, "completed": false, "best_time": -1.0, "stars": 0, "total_checkpoints": 2})


func _start_level(level_id: int):
	if level_id < 0 or level_id >= levels.size():
		return
	if not levels[level_id].unlocked:
		return
	current_level_id = level_id
	_reset_checkpoints()


func _complete_level(level_id: int, stars: int, time: float):
	if level_id < 0 or level_id >= levels.size():
		return
	var level = levels[level_id]
	level.completed = true

	# 기록 갱신 (더 좋은 것만)
	if level.best_time < 0 or time < level.best_time:
		level.best_time = time
	if stars > level.stars:
		level.stars = stars

	# 다음 레벨 잠금 해제
	var next_id = level_id + 1
	if next_id < levels.size() and not levels[next_id].unlocked:
		levels[next_id].unlocked = true


func _serialize_progress() -> Dictionary:
	var data = {}
	for level in levels:
		data["level_%d" % level.id] = {
			"id": level.id,
			"name": level.name,
			"unlocked": level.unlocked,
			"completed": level.completed,
			"best_time": level.best_time,
			"stars": level.stars,
		}
	return data


# ==============================================================================
# 연습 5: 체크포인트 - 체크포인트 시스템을 구현하세요.
#          플레이어 위치와 게임 상태를 체크포인트에 저장하고,
#          사망 시 마지막 체크포인트에서 부활합니다.
# ==============================================================================
func _exercise_5_checkpoint():
	# 풀이: reach_checkpoint(id, position, extra_data)로 체크포인트에 도달 시
	#       ID, 위치, 추가 데이터를 저장합니다. 이미 지나간 체크포인트(id <= current_checkpoint_id)는
	#       무시합니다. get_respawn_position()으로 부활 위치를 가져옵니다.
	#       reset_checkpoints()로 레벨 시작 시 초기화합니다.

	print("\n연습 5: 체크포인트 시스템")

	# 초기화
	current_level_id = 0
	_reset_checkpoints()

	print("  체크포인트 구현 원리:")
	print("    1. 레벨에 체크포인트 Area2D 배치")
	print("    2. 플레이어가 체크포인트에 닿으면 저장")
	print("    3. 사망 시 마지막 체크포인트에서 부활")
	print()

	# 체크포인트 도달 시뮬레이션
	print("  [시뮬레이션] 체크포인트 진행:")

	_reach_checkpoint(0, Vector2(500, 300))
	print("    체크포인트 0 도달: 위치=%s" % checkpoint_position)

	_reach_checkpoint(1, Vector2(1200, 250))
	print("    체크포인트 1 도달: 위치=%s" % checkpoint_position)

	_reach_checkpoint(2, Vector2(2000, 400))
	print("    체크포인트 2 도달: 위치=%s" % checkpoint_position)
	print()

	# 이미 지나간 체크포인트 무시
	_reach_checkpoint(1, Vector2(999, 999))
	print("  체크포인트 1 재방문: 무시됨 (현재 ID=%d)" % current_checkpoint_id)
	print()

	# 사망 후 부활
	print("  [시뮬레이션] 플레이어 사망!")
	var respawn = _get_respawn_position()
	print("    부활 위치: %s (체크포인트 %d)" % [respawn, current_checkpoint_id])
	print()

	# 추가 데이터 저장
	print("  체크포인트에 게임 상태 저장:")
	_reach_checkpoint(3, Vector2(2500, 350), {
		"hp": 80,
		"coins": 15,
		"keys": ["red_key"],
		"enemies_defeated": 12,
	})
	print("    체크포인트 3 데이터: %s" % checkpoint_data)
	print()

	# 체크포인트 초기화 (레벨 재시작)
	print("  레벨 재시작 시 체크포인트 초기화:")
	_reset_checkpoints()
	print("    checkpoint_id = %d, position = %s" % [
		current_checkpoint_id, checkpoint_position
	])

	print("연습 5 완료: 체크포인트 시스템")


func _reach_checkpoint(id: int, position: Vector2, extra_data: Dictionary = {}):
	if id <= current_checkpoint_id:
		return  # 이미 지난 체크포인트

	current_checkpoint_id = id
	checkpoint_position = position
	checkpoint_data = extra_data


func _get_respawn_position() -> Vector2:
	if current_checkpoint_id >= 0:
		return checkpoint_position
	return Vector2.ZERO  # 시작 지점


func _reset_checkpoints():
	current_checkpoint_id = -1
	checkpoint_position = Vector2.ZERO
	checkpoint_data = {}
