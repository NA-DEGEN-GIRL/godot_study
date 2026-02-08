# Chapter 10 - TileMap & Level Design
# 01-tilemap-code.gd - TileMap 코드 제어
#
# 이 파일에서 배울 내용:
# - TileMapLayer (Godot 4.3+) 코드로 타일 배치/제거
# - set_cell, get_cell_source_id, erase_cell
# - local_to_map, map_to_local 좌표 변환
# - get_used_cells, get_surrounding_cells 탐색
# - 절차적 레벨 생성 기초

extends Node2D

func _ready():
	print("=== Chapter 10-1: TileMap 코드 제어 ===\n")

	# -----------------------------------------------------------------
	# 1) TileMap 기본 개념
	# -----------------------------------------------------------------
	print("--- 1. TileMap 기본 개념 ---")

	print("  TileMap 구조 (Godot 4.x):")
	print("    TileMap 노드")
	print("    +-- TileSet 리소스 (타일 정의)")
	print("    |   +-- Source 0: Atlas 텍스처")
	print("    |   |   +-- 타일 (0,0), (1,0), (0,1), ...")
	print("    |   +-- Source 1: 다른 텍스처")
	print("    +-- Layer 0: 배경")
	print("    +-- Layer 1: 지형")
	print("    +-- Layer 2: 장식")
	print()

	print("  Godot 4.3+ TileMapLayer 노드:")
	print("    기존 TileMap의 레이어가 독립 노드로 분리")
	print("    TileMapLayer는 개별적으로 TileSet을 참조")
	print()

	# -----------------------------------------------------------------
	# 2) TileMap 좌표 시스템
	# -----------------------------------------------------------------
	print("--- 2. TileMap 좌표 시스템 ---")

	# TileMap 생성 (코드에서 TileSet 없이 좌표 시스템 설명)
	var tilemap = TileMap.new()
	add_child(tilemap)

	# 타일 크기 설정은 TileSet에서 관리
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tilemap.tile_set = tileset

	print("  타일 크기: ", tileset.tile_size)
	print()

	# 좌표 변환 함수 설명
	print("  좌표 변환 함수:")
	print("    local_to_map(local_pos)  - 로컬 좌표 -> 맵(타일) 좌표")
	print("    map_to_local(map_pos)    - 맵(타일) 좌표 -> 로컬 좌표 (중심점)")
	print()

	# 좌표 변환 예시
	print("  좌표 변환 예시 (타일 크기: 16x16):")
	var test_positions = [
		Vector2(0, 0),
		Vector2(8, 8),
		Vector2(16, 16),
		Vector2(24, 32),
		Vector2(100, 75),
		Vector2(-10, -10)
	]

	for pos in test_positions:
		var map_coord = tilemap.local_to_map(pos)
		var back_to_local = tilemap.map_to_local(map_coord)
		print("    로컬 %s -> 맵 %s -> 로컬(중심) %s" % [pos, map_coord, back_to_local])
	print()

	# -----------------------------------------------------------------
	# 3) set_cell - 타일 배치
	# -----------------------------------------------------------------
	print("--- 3. set_cell - 타일 배치 ---")

	print("  set_cell(layer, coords, source_id, atlas_coords, alternative_tile)")
	print("    layer         - 레이어 인덱스 (0부터)")
	print("    coords        - Vector2i 맵 좌표")
	print("    source_id     - TileSet 소스 ID")
	print("    atlas_coords  - 아틀라스 내 타일 위치 (Vector2i)")
	print("    alternative   - 대체 타일 ID (회전/반전 등)")
	print()

	# 실제 TileSet 소스가 없으므로 호출 구조만 설명
	print("  사용 예시 (TileSet 소스가 있을 때):")
	print("    # 레이어 0, 위치 (3,5)에 소스 0의 (0,0) 타일 배치")
	print("    tilemap.set_cell(0, Vector2i(3, 5), 0, Vector2i(0, 0))")
	print()
	print("    # 레이어 1, 위치 (3,5)에 소스 0의 (2,1) 타일 배치")
	print("    tilemap.set_cell(1, Vector2i(3, 5), 0, Vector2i(2, 1))")
	print()

	# 빈 타일 배치 (지우기와 동일)
	print("    # 타일 제거: source_id를 -1로 설정")
	print("    tilemap.set_cell(0, Vector2i(3, 5), -1)")
	print()

	# -----------------------------------------------------------------
	# 4) erase_cell - 타일 제거
	# -----------------------------------------------------------------
	print("--- 4. erase_cell - 타일 제거 ---")

	print("  tilemap.erase_cell(layer, coords)")
	print("    # 레이어 0, 위치 (3,5)의 타일 제거")
	print("    tilemap.erase_cell(0, Vector2i(3, 5))")
	print()

	# -----------------------------------------------------------------
	# 5) get_cell 정보 조회
	# -----------------------------------------------------------------
	print("--- 5. 타일 정보 조회 ---")

	print("  조회 함수들:")
	print("    get_cell_source_id(layer, coords)     - 소스 ID (-1이면 빈 타일)")
	print("    get_cell_atlas_coords(layer, coords)  - 아틀라스 내 위치")
	print("    get_cell_alternative_tile(layer, coords) - 대체 타일 ID")
	print()

	# 빈 타일 조회 예시
	var empty_check = tilemap.get_cell_source_id(0, Vector2i(0, 0))
	print("  빈 타일 조회 (0,0): source_id = ", empty_check, " (-1 = 빈 타일)")
	print()

	# 타일 존재 확인 패턴
	print("  타일 존재 확인 패턴:")
	print("    func is_tile_at(layer: int, coords: Vector2i) -> bool:")
	print("        return tilemap.get_cell_source_id(layer, coords) != -1")
	print()

	# -----------------------------------------------------------------
	# 6) get_used_cells - 사용된 타일 목록
	# -----------------------------------------------------------------
	print("--- 6. 사용된 타일 목록 조회 ---")

	print("  get_used_cells(layer) -> Array[Vector2i]")
	print("    해당 레이어에서 타일이 배치된 모든 좌표 반환")
	print()

	var used = tilemap.get_used_cells(0)
	print("  현재 레이어 0 사용된 타일: ", used.size(), " 개")
	print()

	print("  get_used_cells_by_id(layer, source_id, atlas_coords)")
	print("    특정 소스와 아틀라스 좌표에 해당하는 타일만 반환")
	print()

	# -----------------------------------------------------------------
	# 7) get_surrounding_cells - 주변 타일
	# -----------------------------------------------------------------
	print("--- 7. 주변 타일 탐색 ---")

	print("  get_surrounding_cells(coords) -> Array[Vector2i]")
	print("    사각 그리드: 4방향 이웃 반환")
	print("    육각 그리드: 6방향 이웃 반환")
	print()

	var center = Vector2i(5, 5)
	var neighbors = tilemap.get_surrounding_cells(center)
	print("  중심 타일 %s의 이웃:" % center)
	for n in neighbors:
		var direction = Vector2i(n.x - center.x, n.y - center.y)
		print("    %s (방향: %s)" % [n, direction])
	print()

	# 8방향 이웃 (대각선 포함) - 수동 계산
	print("  8방향 이웃 (대각선 포함) - 수동 계산:")
	var directions_8 = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]
	for d in directions_8:
		print("    %s + %s = %s" % [center, d, center + d])
	print()

	# -----------------------------------------------------------------
	# 8) 절차적 레벨 생성 예시
	# -----------------------------------------------------------------
	print("--- 8. 절차적 레벨 생성 ---")

	# 간단한 플랫폼 레벨 생성 시뮬레이션
	print("  간단한 절차적 플랫폼 생성 (시뮬레이션):")
	var level_width = 30
	var level_height = 10
	var ground_y = 8

	# 레벨 맵을 문자열로 시각화
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

	# 실제 TileMap에 배치하는 코드
	print("  실제 배치 코드 (TileSet 소스가 있을 때):")
	print("    for y in range(level_height):")
	print("        for x in range(level_width):")
	print("            if level_map[y][x] == 1:")
	print("                tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))")
	print("            elif level_map[y][x] == 2:")
	print("                tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))")
	print()

	# -----------------------------------------------------------------
	# 9) 마우스 클릭으로 타일 배치 패턴
	# -----------------------------------------------------------------
	print("--- 9. 마우스로 타일 배치 패턴 ---")

	print("  func _input(event):")
	print("      if event is InputEventMouseButton:")
	print("          if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:")
	print("              var local_pos = tilemap.to_local(event.position)")
	print("              var map_pos = tilemap.local_to_map(local_pos)")
	print("              tilemap.set_cell(0, map_pos, 0, Vector2i(0, 0))")
	print("          elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:")
	print("              var local_pos = tilemap.to_local(event.position)")
	print("              var map_pos = tilemap.local_to_map(local_pos)")
	print("              tilemap.erase_cell(0, map_pos)")
	print()

	# -----------------------------------------------------------------
	# 10) TileMap 유틸리티 함수 모음
	# -----------------------------------------------------------------
	print("--- 10. TileMap 유틸리티 함수 모음 ---")

	print("  유용한 유틸리티 패턴:")
	print()

	# 영역 채우기
	print("  # 직사각형 영역 채우기")
	print("  func fill_rect(layer, from, to, source, atlas):")
	print("      for x in range(from.x, to.x + 1):")
	print("          for y in range(from.y, to.y + 1):")
	print("              tilemap.set_cell(layer, Vector2i(x,y), source, atlas)")
	print()

	# 영역 지우기
	print("  # 영역 지우기")
	print("  func clear_rect(layer, from, to):")
	print("      for x in range(from.x, to.x + 1):")
	print("          for y in range(from.y, to.y + 1):")
	print("              tilemap.erase_cell(layer, Vector2i(x, y))")
	print()

	# A* 경로찾기용 그리드 생성
	print("  # 이동 가능 타일로 AStarGrid2D 설정")
	print("  func setup_astar(layer):")
	print("      var astar = AStarGrid2D.new()")
	print("      astar.region = tilemap.get_used_rect()")
	print("      astar.cell_size = Vector2(16, 16)")
	print("      astar.update()")
	print("      for cell in tilemap.get_used_cells(layer):")
	print("          astar.set_point_solid(cell, true)")
	print("      return astar")
	print()

	# get_used_rect
	print("  get_used_rect() - 타일이 있는 영역의 바운딩 박스:")
	var rect = tilemap.get_used_rect()
	print("    현재: ", rect, " (타일 없음)")
	print()

	print("=== 01-tilemap-code.gd 완료 ===")
