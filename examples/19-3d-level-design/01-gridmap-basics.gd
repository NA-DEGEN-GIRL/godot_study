# Chapter 19 - 3D Level Design
# 01-gridmap-basics.gd - GridMap, MeshLibrary, 코드로 배치
#
# 이 파일에서 배울 내용:
# - GridMap의 개념과 타일맵 비교
# - MeshLibrary 리소스 이해
# - 코드에서 GridMap 셀 배치/삭제
# - 회전, 방향 설정
# - 절차적 맵 생성 (던전, 미로)
# - GridMap과 네비게이션 연동

extends Node3D

func _ready():
	print("=== Chapter 19-1: GridMap Basics ===\n")

	# -----------------------------------------------------------------
	# 1) GridMap 개념
	# -----------------------------------------------------------------
	print("--- 1. GridMap 개념 ---")

	print("  GridMap = 3D 버전의 TileMap")
	print("  3D 격자에 미리 정의된 메시(타일)를 배치합니다")
	print()
	print("  구성 요소:")
	print("    MeshLibrary - 사용할 메시 모음 (타일셋)")
	print("    GridMap     - 격자 배치 관리 노드")
	print()
	print("  장점:")
	print("    - 빠른 레벨 프로토타이핑")
	print("    - 메모리 효율적 (같은 메시 재사용)")
	print("    - 코드로 절차적 생성 가능")
	print("    - 자동 충돌/네비게이션 생성")
	print()
	print("  TileMap과의 비교:")
	print("    TileMap (2D): x, y 좌표, 스프라이트 기반")
	print("    GridMap (3D): x, y, z 좌표, 메시 기반")
	print()

	# -----------------------------------------------------------------
	# 2) MeshLibrary 생성
	# -----------------------------------------------------------------
	print("--- 2. MeshLibrary 생성 ---")

	# 코드에서 MeshLibrary 생성
	var mesh_library := MeshLibrary.new()

	# 아이템 0: 바닥 타일
	var floor_id := 0
	mesh_library.create_item(floor_id)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(2, 0.2, 2)
	mesh_library.set_item_mesh(floor_id, floor_mesh)
	mesh_library.set_item_name(floor_id, "Floor")

	# 아이템 1: 벽 타일
	var wall_id := 1
	mesh_library.create_item(wall_id)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(2, 2, 0.2)
	mesh_library.set_item_mesh(wall_id, wall_mesh)
	mesh_library.set_item_name(wall_id, "Wall")

	# 아이템 2: 기둥
	var pillar_id := 2
	mesh_library.create_item(pillar_id)
	var pillar_mesh := CylinderMesh.new()
	pillar_mesh.top_radius = 0.2
	pillar_mesh.bottom_radius = 0.3
	pillar_mesh.height = 2.0
	mesh_library.set_item_mesh(pillar_id, pillar_mesh)
	mesh_library.set_item_name(pillar_id, "Pillar")

	# 아이템 3: 계단
	var stairs_id := 3
	mesh_library.create_item(stairs_id)
	var stairs_mesh := BoxMesh.new()
	stairs_mesh.size = Vector3(2, 1, 2)
	mesh_library.set_item_mesh(stairs_id, stairs_mesh)
	mesh_library.set_item_name(stairs_id, "Stairs")

	print("  MeshLibrary 아이템 수: %d" % mesh_library.get_item_list().size())
	for item_id in mesh_library.get_item_list():
		print("    [%d] %s" % [item_id, mesh_library.get_item_name(item_id)])
	print()

	# 에디터에서 MeshLibrary 생성 방법
	print("  에디터에서 MeshLibrary 만들기:")
	print("    1. 3D 씬에 MeshInstance3D들 배치")
	print("    2. 각 메시에 StaticBody3D + CollisionShape3D 추가")
	print("    3. 메뉴 > Scene > Export As... > MeshLibrary")
	print("    4. .meshlib 파일로 저장")
	print()

	# -----------------------------------------------------------------
	# 3) GridMap 노드 생성과 설정
	# -----------------------------------------------------------------
	print("--- 3. GridMap 설정 ---")

	var grid_map := GridMap.new()
	grid_map.mesh_library = mesh_library
	grid_map.cell_size = Vector3(2, 2, 2)  # 셀 크기 (메시 크기와 맞추기)
	add_child(grid_map)

	print("  GridMap 설정:")
	print("    cell_size = %s (각 셀의 크기)" % str(grid_map.cell_size))
	print("    mesh_library = MeshLibrary (%d 아이템)" % mesh_library.get_item_list().size())
	print()

	print("  cell_size 주요 속성:")
	print("    cell_size.x - 가로 크기")
	print("    cell_size.y - 높이")
	print("    cell_size.z - 세로 크기")
	print("    보통 메시 크기와 동일하게 설정")
	print()

	# -----------------------------------------------------------------
	# 4) 셀 배치와 삭제
	# -----------------------------------------------------------------
	print("--- 4. 셀 배치/삭제 ---")

	# 바닥 배치 (5x5)
	for x in range(5):
		for z in range(5):
			grid_map.set_cell_item(Vector3i(x, 0, z), floor_id)

	print("  바닥 5x5 배치: set_cell_item(Vector3i(x, 0, z), floor_id)")

	# 벽 배치 (테두리)
	for x in range(5):
		grid_map.set_cell_item(Vector3i(x, 1, 0), wall_id)    # 앞면 벽
		grid_map.set_cell_item(Vector3i(x, 1, 4), wall_id)    # 뒷면 벽
	for z in range(1, 4):
		grid_map.set_cell_item(Vector3i(0, 1, z), wall_id,
			_get_orientation_index(1))  # 좌측 벽 (90도 회전)
		grid_map.set_cell_item(Vector3i(4, 1, z), wall_id,
			_get_orientation_index(1))  # 우측 벽

	print("  벽 테두리 배치: 앞뒤 + 좌우 (회전)")

	# 모서리에 기둥 배치
	grid_map.set_cell_item(Vector3i(0, 1, 0), pillar_id)
	grid_map.set_cell_item(Vector3i(4, 1, 0), pillar_id)
	grid_map.set_cell_item(Vector3i(0, 1, 4), pillar_id)
	grid_map.set_cell_item(Vector3i(4, 1, 4), pillar_id)

	print("  모서리 기둥 4개 배치")
	print()

	# 셀 읽기
	var cell_item := grid_map.get_cell_item(Vector3i(2, 0, 2))
	print("  셀 읽기: get_cell_item(Vector3i(2,0,2)) = %d" % cell_item)

	# 셀 삭제 (INVALID_CELL_ITEM = -1)
	print("  셀 삭제: set_cell_item(pos, GridMap.INVALID_CELL_ITEM)")
	print("  또는: set_cell_item(pos, -1)")

	# 사용된 셀 목록
	var used_cells := grid_map.get_used_cells()
	print("  사용된 셀 수: %d" % used_cells.size())
	print()

	# -----------------------------------------------------------------
	# 5) 셀 회전 (Orientation)
	# -----------------------------------------------------------------
	print("--- 5. 셀 회전 ---")

	print("  GridMap 셀 회전은 orientation 인덱스로 지정합니다")
	print("  set_cell_item(position, item_id, orientation)")
	print()

	print("  기본 방향 (orientation = 0):")
	print("    메시가 원래 방향 그대로 배치됩니다")
	print()

	print("  회전은 Basis의 직교 회전 행렬 인덱스입니다:")
	print("    총 24가지 방향 (6면 x 4회전)")
	print()

	print("  간단한 회전 방법:")
	print("    # get_orthogonal_index()로 Basis에서 인덱스 얻기")
	print("    var basis = Basis()")
	print("    basis = basis.rotated(Vector3.UP, PI/2)  # Y축 90도")
	print("    var orientation = grid_map.get_orthogonal_index_from_basis(basis)")
	print("    grid_map.set_cell_item(pos, item, orientation)")
	print()

	# 회전 데모
	for i in range(4):
		var basis := Basis()
		basis = basis.rotated(Vector3.UP, i * PI / 2)
		var orient := _get_orientation_index(i)
		print("    %d도 회전 -> orientation index = %d" % [i * 90, orient])
	print()

	# -----------------------------------------------------------------
	# 6) 절차적 맵 생성: 던전
	# -----------------------------------------------------------------
	print("--- 6. 절차적 던전 생성 ---")

	var dungeon_map := GridMap.new()
	dungeon_map.mesh_library = mesh_library
	dungeon_map.cell_size = Vector3(2, 2, 2)
	dungeon_map.position = Vector3(15, 0, 0)
	add_child(dungeon_map)

	# 간단한 던전 생성 (방 + 복도)
	_generate_simple_dungeon(dungeon_map, floor_id, wall_id)

	var dungeon_cells := dungeon_map.get_used_cells()
	print("  던전 셀 수: %d" % dungeon_cells.size())
	print()

	# -----------------------------------------------------------------
	# 7) 절차적 맵 생성: 미로
	# -----------------------------------------------------------------
	print("--- 7. 절차적 미로 생성 ---")

	var maze_map := GridMap.new()
	maze_map.mesh_library = mesh_library
	maze_map.cell_size = Vector3(2, 2, 2)
	maze_map.position = Vector3(30, 0, 0)
	add_child(maze_map)

	# 미로 생성 (간단한 알고리즘)
	var maze_size := 9
	_generate_maze(maze_map, maze_size, floor_id, wall_id)

	print("  미로 크기: %dx%d" % [maze_size, maze_size])
	print("  미로 셀 수: %d" % maze_map.get_used_cells().size())
	print()

	# -----------------------------------------------------------------
	# 8) GridMap 유틸리티
	# -----------------------------------------------------------------
	print("--- 8. GridMap 유틸리티 ---")

	# 월드 좌표 <-> 맵 좌표 변환
	var world_pos := Vector3(4, 0, 6)
	var map_pos := grid_map.local_to_map(world_pos)
	var back_to_world := grid_map.map_to_local(map_pos)
	print("  좌표 변환:")
	print("    월드 -> 맵: local_to_map(%s) = %s" % [world_pos, map_pos])
	print("    맵 -> 월드: map_to_local(%s) = %s" % [map_pos, back_to_world])
	print()

	# 특정 아이템 ID의 셀 찾기
	var floor_cells := grid_map.get_used_cells_by_item(floor_id)
	var wall_cells := grid_map.get_used_cells_by_item(wall_id)
	print("  아이템별 셀 수:")
	print("    바닥(Floor): %d 셀" % floor_cells.size())
	print("    벽(Wall): %d 셀" % wall_cells.size())
	print()

	# 전체 초기화
	print("  전체 초기화: grid_map.clear()")
	print()

	# -----------------------------------------------------------------
	# 9) 충돌과 네비게이션
	# -----------------------------------------------------------------
	print("--- 9. 충돌 & 네비게이션 ---")

	print("  MeshLibrary 아이템에 충돌 설정:")
	print("    mesh_library.set_item_shapes(id, [shape_info])")
	print("    # shape_info = [Transform3D, Shape3D] 쌍의 배열")
	print()

	# 바닥 타일에 충돌 설정 (코드에서)
	var collision_shape := BoxShape3D.new()
	collision_shape.size = Vector3(2, 0.2, 2)
	var shape_array := []
	shape_array.append(Transform3D())       # 변환
	shape_array.append(collision_shape)       # 형태
	mesh_library.set_item_shapes(floor_id, shape_array)

	print("  바닥 타일에 BoxShape3D 충돌 설정 완료")
	print()

	print("  네비게이션 메시 설정:")
	print("    var nav_mesh = NavigationMesh.new()")
	print("    mesh_library.set_item_navigation_mesh(id, nav_mesh)")
	print("    # GridMap이 자동으로 네비게이션 영역 합성")
	print()

	print("  에디터에서의 설정:")
	print("    1. MeshLibrary 소스 씬에서")
	print("    2. 각 타일에 StaticBody3D + CollisionShape3D 추가")
	print("    3. NavigationRegion3D + NavigationMesh 추가")
	print("    4. MeshLibrary로 Export 시 자동 포함")
	print()

	# -----------------------------------------------------------------
	# 10) 성능 팁
	# -----------------------------------------------------------------
	print("--- 10. GridMap 성능 팁 ---")

	print("  1. 셀 크기는 메시와 정확히 맞추기")
	print("     -> 틈이나 겹침 방지")
	print()
	print("  2. MeshLibrary 메시는 가능한 단순하게")
	print("     -> LOD가 없으므로 폴리곤 수 관리")
	print()
	print("  3. 대규모 맵에서는 청크 단위 로딩")
	print("     -> 여러 GridMap을 영역별로 나누기")
	print()
	print("  4. 런타임 수정은 최소화")
	print("     -> set_cell_item()은 내부 메시 재구성 유발")
	print("     -> 일괄 수정 후 한 번만 업데이트")
	print()
	print("  5. 그림자, 조명 고려")
	print("     -> cell_scale 속성으로 메시 스케일 미세 조정")
	print()

	print("=== 01-gridmap-basics.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 간단한 방향 인덱스 (Y축 90도 단위 회전)
func _get_orientation_index(quarter_turns: int) -> int:
	var basis := Basis()
	basis = basis.rotated(Vector3.UP, quarter_turns * PI / 2.0)
	# Basis의 직교 인덱스 계산 (간단한 매핑)
	match quarter_turns % 4:
		0: return 0   # 0도
		1: return 16  # 90도
		2: return 10  # 180도
		3: return 22  # 270도
	return 0


## 간단한 던전 생성
func _generate_simple_dungeon(grid: GridMap, floor_id: int, wall_id: int):
	# 방 1 (5x5)
	_fill_room(grid, Vector3i(0, 0, 0), Vector3i(5, 1, 5), floor_id, wall_id)

	# 복도 (1x3)
	for z in range(5, 8):
		grid.set_cell_item(Vector3i(2, 0, z), floor_id)

	# 방 2 (4x4)
	_fill_room(grid, Vector3i(0, 0, 8), Vector3i(4, 1, 4), floor_id, wall_id)

	print("  방 2개 + 복도 생성 완료")


## 방 채우기 (바닥 + 벽)
func _fill_room(grid: GridMap, origin: Vector3i, size: Vector3i, floor_id: int, wall_id: int):
	for x in range(size.x):
		for z in range(size.z):
			# 바닥
			grid.set_cell_item(origin + Vector3i(x, 0, z), floor_id)

			# 벽 (테두리만)
			if x == 0 or x == size.x - 1 or z == 0 or z == size.z - 1:
				grid.set_cell_item(origin + Vector3i(x, 1, z), wall_id)


## 간단한 미로 생성 (재귀적 분할 방식 간소화)
func _generate_maze(grid: GridMap, size: int, floor_id: int, wall_id: int):
	# 전체를 바닥으로 채우기
	for x in range(size):
		for z in range(size):
			grid.set_cell_item(Vector3i(x, 0, z), floor_id)

	# 벽 격자 패턴 (홀수 좌표에 벽)
	for x in range(size):
		for z in range(size):
			if x == 0 or z == 0 or x == size - 1 or z == size - 1:
				grid.set_cell_item(Vector3i(x, 1, z), wall_id)  # 외벽
			elif x % 2 == 0 and z % 2 == 0:
				grid.set_cell_item(Vector3i(x, 1, z), wall_id)  # 기둥

				# 기둥에서 랜덤 방향으로 벽 확장
				var directions := [
					Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
					Vector3i(0, 0, 1), Vector3i(0, 0, -1)
				]
				var dir: Vector3i = directions[randi() % 4]
				var wall_pos := Vector3i(x, 1, z) + dir
				if wall_pos.x > 0 and wall_pos.x < size - 1 and wall_pos.z > 0 and wall_pos.z < size - 1:
					grid.set_cell_item(wall_pos, wall_id)
