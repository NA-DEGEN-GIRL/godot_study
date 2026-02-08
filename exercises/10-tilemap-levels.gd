# 챕터 10: 타일맵과 레벨 디자인
#
# 이 챕터에서는 다음을 학습합니다:
# - TileMapLayer의 set_cell로 코드에서 타일 배치하기
# - 월드 좌표와 타일 좌표 간의 변환
# - 씬 전환과 레벨 로딩
# - 레벨 데이터 구조 설계
# - 체크포인트 시스템 구현

extends Node2D

# ============================================================
# 연습 1: 타일 배치 함수 (set_cell)
# ============================================================
# TileMapLayer의 set_cell 메서드로 타일을 코드에서 배치합니다.
# 절차적 레벨 생성, 동적 지형 변경 등에 활용됩니다.

func place_tile(tilemap: TileMapLayer, grid_pos: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	# TODO: tilemap이 null이면 return하세요
	# TODO: tilemap.set_cell(grid_pos, source_id, atlas_coords)를 호출하세요
	#       (힌트: set_cell의 파라미터: 타일 좌표, 소스 ID, 아틀라스 좌표)
	pass  # 여기를 수정하세요

func place_floor_row(tilemap: TileMapLayer, start_x: int, end_x: int, y: int, source_id: int, atlas_coords: Vector2i) -> void:
	# TODO: start_x부터 end_x까지 반복하면서 y 행에 타일을 배치하세요
	# TODO: 각 위치에 place_tile 함수를 호출하세요
	#       (힌트: for x in range(start_x, end_x + 1): ...)
	pass  # 여기를 수정하세요

func place_rectangle(tilemap: TileMapLayer, top_left: Vector2i, size: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	# TODO: top_left 위치에서 size 크기만큼 직사각형 영역에 타일을 배치하세요
	# TODO: 이중 for 루프를 사용하세요
	#       for y in range(top_left.y, top_left.y + size.y):
	#           for x in range(top_left.x, top_left.x + size.x):
	#               place_tile(...)
	pass  # 여기를 수정하세요

func erase_tile(tilemap: TileMapLayer, grid_pos: Vector2i) -> void:
	# TODO: tilemap이 null이면 return하세요
	# TODO: tilemap.erase_cell(grid_pos)를 호출하여 타일을 제거하세요
	pass  # 여기를 수정하세요


# ============================================================
# 연습 2: 좌표 변환 (local_to_map, map_to_local)
# ============================================================
# 월드(픽셀) 좌표와 타일맵 그리드 좌표를 상호 변환합니다.
# 마우스 클릭 위치를 타일 좌표로, 타일 좌표를 월드 위치로 변환할 때 사용합니다.

func world_to_tile(tilemap: TileMapLayer, world_pos: Vector2) -> Vector2i:
	# TODO: tilemap이 null이면 Vector2i.ZERO를 반환하세요
	# TODO: tilemap.local_to_map(world_pos)를 호출하여 타일 좌표를 구하세요
	#       (월드 좌표 -> 타일 그리드 좌표)
	# TODO: 변환된 타일 좌표를 반환하세요
	var tile_pos = Vector2i.ZERO  # 여기를 수정하세요
	return tile_pos

func tile_to_world(tilemap: TileMapLayer, tile_pos: Vector2i) -> Vector2:
	# TODO: tilemap이 null이면 Vector2.ZERO를 반환하세요
	# TODO: tilemap.map_to_local(tile_pos)를 호출하여 월드 좌표를 구하세요
	#       (타일 그리드 좌표 -> 월드 좌표, 타일 중심)
	# TODO: 변환된 월드 좌표를 반환하세요
	var world_pos = Vector2.ZERO  # 여기를 수정하세요
	return world_pos

func get_tile_at_mouse(tilemap: TileMapLayer) -> Vector2i:
	# TODO: tilemap이 null이면 Vector2i.ZERO를 반환하세요
	# TODO: tilemap.get_local_mouse_position()으로 마우스의 로컬 좌표를 구하세요
	# TODO: world_to_tile 함수를 호출하여 타일 좌표로 변환하세요
	# TODO: 변환된 타일 좌표를 반환하세요
	var tile_pos = Vector2i.ZERO  # 여기를 수정하세요
	return tile_pos


# ============================================================
# 연습 3: 씬 전환 함수
# ============================================================
# 레벨 씬을 코드로 전환합니다.
# 페이드 효과를 포함한 부드러운 전환을 구현합니다.

var is_transitioning: bool = false

func change_level(scene_path: String) -> void:
	# TODO: is_transitioning이 true이면 return하세요 (중복 전환 방지)
	# TODO: is_transitioning을 true로 설정하세요
	# TODO: ResourceLoader.exists(scene_path)로 씬 파일 존재 여부를 확인하세요
	#       존재하지 않으면 에러 메시지를 출력하고 is_transitioning을 false로 복원 후 return
	# TODO: get_tree().change_scene_to_file(scene_path)를 호출하세요
	# TODO: is_transitioning을 false로 설정하세요
	# TODO: "레벨 전환: {scene_path}"를 출력하세요
	pass  # 여기를 수정하세요

func change_level_with_fade(scene_path: String) -> void:
	# TODO: is_transitioning이 true이면 return하세요
	# TODO: is_transitioning을 true로 설정하세요
	# TODO: 페이드 아웃용 ColorRect를 생성하세요:
	#       - color = Color.BLACK
	#       - modulate.a = 0 (처음엔 투명)
	#       - CanvasLayer를 생성하여 layer = 100 으로 설정
	#       - CanvasLayer에 ColorRect를 추가
	#       - 씬에 CanvasLayer를 추가
	# TODO: Tween으로 modulate.a를 0에서 1로 0.5초 동안 페이드 아웃하세요
	# TODO: tween_callback으로 get_tree().change_scene_to_file(scene_path) 호출
	# TODO: 이 함수의 전체 구조를 출력하세요: "페이드 전환: {scene_path}"
	pass  # 여기를 수정하세요


# ============================================================
# 연습 4: 레벨 데이터 구조 정의
# ============================================================
# 레벨의 메타데이터를 Dictionary로 구조화합니다.
# 레벨 선택 화면, 진행도 관리 등에 사용됩니다.

func create_level_data(level_id: int, level_name: String, scene_path: String) -> Dictionary:
	# TODO: 레벨 데이터 Dictionary를 생성하여 반환하세요
	# TODO: 포함할 키:
	#       - "id": level_id
	#       - "name": level_name
	#       - "scene_path": scene_path
	#       - "unlocked": (level_id == 1이면 true, 아니면 false)
	#       - "stars": 0  (획득한 별 수, 0~3)
	#       - "best_time": 0.0  (최고 기록)
	#       - "completed": false
	var data = {}  # 여기를 수정하세요
	return data

func create_level_list() -> Array:
	# TODO: 5개의 레벨 데이터를 담은 배열을 생성하여 반환하세요
	# TODO: create_level_data 함수를 활용하세요:
	#       - 레벨 1: "숲 속 모험", "res://levels/level_01.tscn"
	#       - 레벨 2: "어두운 동굴", "res://levels/level_02.tscn"
	#       - 레벨 3: "화산 지대", "res://levels/level_03.tscn"
	#       - 레벨 4: "얼음 성", "res://levels/level_04.tscn"
	#       - 레벨 5: "최종 보스", "res://levels/level_05.tscn"
	var levels = []  # 여기를 수정하세요
	return levels

func unlock_next_level(levels: Array, completed_level_id: int) -> void:
	# TODO: levels 배열을 순회하며 completed_level_id와 일치하는 레벨을 찾으세요
	# TODO: 해당 레벨의 "completed"를 true로 설정하세요
	# TODO: 다음 레벨(completed_level_id + 1)이 있으면 "unlocked"를 true로 설정하세요
	# TODO: "레벨 {id} 완료! 레벨 {id+1} 해금!"을 출력하세요
	pass  # 여기를 수정하세요


# ============================================================
# 연습 5: 체크포인트 저장/불러오기
# ============================================================
# 플레이어의 위치와 상태를 체크포인트로 저장하고 복원합니다.
# 죽으면 마지막 체크포인트에서 다시 시작하는 시스템입니다.

var checkpoint_data: Dictionary = {}

func save_checkpoint(player_pos: Vector2, player_hp: float, collected_items: Array, level_id: int) -> Dictionary:
	# TODO: 체크포인트 데이터를 Dictionary로 구성하세요:
	#       - "position": {"x": player_pos.x, "y": player_pos.y}
	#       - "hp": player_hp
	#       - "collected_items": collected_items.duplicate()  (배열 복사)
	#       - "level_id": level_id
	#       - "timestamp": Time.get_unix_time_from_system()
	# TODO: checkpoint_data 변수에 저장하세요
	# TODO: "체크포인트 저장: 위치={player_pos}, HP={player_hp}"를 출력하세요
	# TODO: checkpoint_data를 반환하세요
	var data = {}  # 여기를 수정하세요
	return data

func load_checkpoint() -> Dictionary:
	# TODO: checkpoint_data가 비어있으면 빈 Dictionary를 반환하세요
	# TODO: checkpoint_data를 반환하세요
	# TODO: "체크포인트 불러오기: 레벨={level_id}"를 출력하세요
	var data = {}  # 여기를 수정하세요
	return data

func restore_player_from_checkpoint(checkpoint: Dictionary) -> Dictionary:
	# TODO: checkpoint가 비어있으면 빈 Dictionary를 반환하세요
	# TODO: 복원할 데이터를 Dictionary로 구성하여 반환하세요:
	#       - "position": Vector2(checkpoint["position"]["x"], checkpoint["position"]["y"])
	#       - "hp": checkpoint["hp"]
	#       - "collected_items": checkpoint["collected_items"]
	# TODO: "플레이어 복원: 위치={position}"을 출력하세요
	var restored = {}  # 여기를 수정하세요
	return restored


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 10: 타일맵과 레벨 디자인 ===")
	print("")

	# 테스트 1: 타일 배치 (TileMapLayer 없이 로직만 테스트)
	print("결과 1 (타일 배치 함수 정의 확인):")
	print("  place_tile 함수 존재:", has_method("place_tile"))
	print("  place_floor_row 함수 존재:", has_method("place_floor_row"))
	print("  place_rectangle 함수 존재:", has_method("place_rectangle"))
	print("  erase_tile 함수 존재:", has_method("erase_tile"))
	# null 전달 시 안전하게 처리되는지 확인
	place_tile(null, Vector2i(0, 0), 0, Vector2i(0, 0))
	erase_tile(null, Vector2i(0, 0))
	print("  null 안전성 테스트 통과")
	print("")

	# 테스트 2: 좌표 변환 (TileMapLayer 없이 null 안전성 테스트)
	var tile_result = world_to_tile(null, Vector2(160, 160))
	print("결과 2 (null TileMap 좌표 변환):", tile_result)
	var world_result = tile_to_world(null, Vector2i(5, 5))
	print("결과 2 (null TileMap 월드 변환):", world_result)
	print("  world_to_tile 함수 존재:", has_method("world_to_tile"))
	print("  tile_to_world 함수 존재:", has_method("tile_to_world"))
	print("  get_tile_at_mouse 함수 존재:", has_method("get_tile_at_mouse"))
	print("")

	# 테스트 3: 씬 전환
	print("결과 3 (씬 전환 함수 정의 확인):")
	print("  change_level 함수 존재:", has_method("change_level"))
	print("  change_level_with_fade 함수 존재:", has_method("change_level_with_fade"))
	print("  is_transitioning:", is_transitioning)
	print("")

	# 테스트 4: 레벨 데이터 구조
	var test_level = create_level_data(1, "테스트 레벨", "res://levels/test.tscn")
	print("결과 4 (레벨 데이터):", test_level)
	var levels = create_level_list()
	print("결과 4 (레벨 수):", levels.size())
	if levels.size() > 0:
		print("결과 4 (첫 레벨 이름):", levels[0].get("name", "없음"))
		print("결과 4 (첫 레벨 해금):", levels[0].get("unlocked", false))
		if levels.size() > 1:
			print("결과 4 (둘째 레벨 해금):", levels[1].get("unlocked", false))
		unlock_next_level(levels, 1)
		if levels.size() > 1:
			print("결과 4 (레벨 1 완료 후 레벨 2 해금):", levels[1].get("unlocked", false))
	print("")

	# 테스트 5: 체크포인트
	var cp = save_checkpoint(Vector2(500, 200), 75.0, ["coin_1", "key_a"], 2)
	print("결과 5 (체크포인트 저장):", cp)
	var loaded_cp = load_checkpoint()
	print("결과 5 (체크포인트 불러오기):", loaded_cp)
	if loaded_cp.size() > 0:
		var restored = restore_player_from_checkpoint(loaded_cp)
		print("결과 5 (플레이어 복원):", restored)
	else:
		print("결과 5: 빈 체크포인트 - save_checkpoint를 구현하세요")
	# 빈 체크포인트 복원 테스트
	checkpoint_data = {}
	var empty_load = load_checkpoint()
	print("결과 5 (빈 체크포인트 불러오기):", empty_load)
	print("")

	print("=== 챕터 10 완료 ===")
