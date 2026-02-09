# Chapter 17 - 3D Materials & Shaders
# 04-multimesh-surface.gd - MultiMeshInstance3D, SurfaceTool, 절차적 메시
#
# 이 파일에서 배울 내용:
# - MultiMeshInstance3D로 대량 오브젝트 효율적 렌더링
# - SurfaceTool로 코드에서 메시 생성
# - ImmediateMesh로 디버그/런타임 지오메트리
# - ArrayMesh로 완전한 절차적 메시 생성
# - 절차적 지형, 격자, 커스텀 형태

extends Node3D

func _ready():
	print("=== Chapter 17-4: MultiMesh & SurfaceTool ===\n")

	# -----------------------------------------------------------------
	# 1) MultiMeshInstance3D 개념
	# -----------------------------------------------------------------
	print("--- 1. MultiMeshInstance3D 개념 ---")

	print("  MultiMesh = 동일한 메시를 수천~수만 개 효율적으로 그리는 방법")
	print("  일반 MeshInstance3D: 각각 별도 draw call")
	print("  MultiMesh: 단 1번의 draw call로 전부 렌더링")
	print()
	print("  활용 사례:")
	print("    - 풀밭 (수만 개의 풀잎)")
	print("    - 숲 (수천 개의 나무)")
	print("    - 군중 (대규모 NPC)")
	print("    - 파티클 대안 (총알, 파편)")
	print("    - 반복적 장식물 (돌, 꽃)")
	print()

	# -----------------------------------------------------------------
	# 2) MultiMeshInstance3D 기본 사용법
	# -----------------------------------------------------------------
	print("--- 2. MultiMeshInstance3D 기본 사용법 ---")

	# MultiMesh 리소스 생성
	var multi_mesh := MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.mesh = BoxMesh.new()  # 원본 메시 설정
	multi_mesh.instance_count = 100  # 인스턴스 수

	# MultiMeshInstance3D 노드에 연결
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = multi_mesh

	# 각 인스턴스의 위치/회전/스케일 설정
	for i in range(multi_mesh.instance_count):
		var transform := Transform3D()
		# 10x10 격자 배치
		var x := (i % 10) * 2.0
		var z := (i / 10) * 2.0
		transform.origin = Vector3(x, 0, z)
		# 약간의 랜덤 회전
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		# 약간의 랜덤 스케일
		var s := randf_range(0.5, 1.5)
		transform = transform.scaled(Vector3(s, s, s))
		multi_mesh.set_instance_transform(i, transform)

	add_child(mmi)

	print("  MultiMesh 생성: %d 인스턴스" % multi_mesh.instance_count)
	print("  메시: BoxMesh (모든 인스턴스 동일)")
	print("  배치: 10x10 격자, 랜덤 회전/스케일")
	print()

	# -----------------------------------------------------------------
	# 3) MultiMesh 색상과 커스텀 데이터
	# -----------------------------------------------------------------
	print("--- 3. MultiMesh 인스턴스 색상 ---")

	var colored_mm := MultiMesh.new()
	colored_mm.transform_format = MultiMesh.TRANSFORM_3D
	colored_mm.use_colors = true  # 인스턴스별 색상 활성화
	colored_mm.use_custom_data = true  # 커스텀 데이터 활성화

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	colored_mm.mesh = sphere_mesh
	colored_mm.instance_count = 50

	# 재질에 USE_INSTANCE_CUSTOM 설정
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true  # 인스턴스 색상을 albedo로 사용
	sphere_mesh.material = mat

	for i in range(colored_mm.instance_count):
		var transform := Transform3D()
		var angle := float(i) / colored_mm.instance_count * TAU
		var radius_pos := 5.0
		transform.origin = Vector3(
			cos(angle) * radius_pos + 30,
			sin(float(i) * 0.5) * 2.0,
			sin(angle) * radius_pos
		)
		colored_mm.set_instance_transform(i, transform)

		# 인스턴스별 색상 설정
		var hue := float(i) / colored_mm.instance_count
		colored_mm.set_instance_color(i, Color.from_hsv(hue, 0.8, 1.0))

		# 커스텀 데이터 (셰이더에서 INSTANCE_CUSTOM으로 접근)
		colored_mm.set_instance_custom_data(i, Color(float(i), 0, 0, 1))

	var colored_mmi := MultiMeshInstance3D.new()
	colored_mmi.multimesh = colored_mm
	add_child(colored_mmi)

	print("  use_colors = true: 인스턴스별 색상 지정")
	print("  use_custom_data = true: 셰이더에 데이터 전달")
	print("  vertex_color_use_as_albedo: 인스턴스 색상을 재질 색상으로")
	print("  원형 배치 + 무지개 색상 50개 구 생성")
	print()

	# -----------------------------------------------------------------
	# 4) MultiMesh 동적 업데이트
	# -----------------------------------------------------------------
	print("--- 4. MultiMesh 동적 업데이트 ---")

	print("  런타임에 인스턴스 변환 변경:")
	print("    multi_mesh.set_instance_transform(index, new_transform)")
	print()
	print("  인스턴스 수 변경:")
	print("    multi_mesh.instance_count = new_count")
	print("    # 주의: 카운트 변경 시 기존 데이터 초기화됨!")
	print()
	print("  가시성 제어 (인스턴스 숨기기):")
	print("    # 스케일을 0으로 설정하여 숨김")
	print("    var t = Transform3D().scaled(Vector3.ZERO)")
	print("    multi_mesh.set_instance_transform(i, t)")
	print()
	print("  visible_instance_count로 부분 표시:")

	multi_mesh.visible_instance_count = 50  # 100개 중 50개만 표시
	print("    visible_instance_count = 50 (100개 중 50개만)")
	multi_mesh.visible_instance_count = -1  # 전체 표시 (-1)
	print("    visible_instance_count = -1 (전체 표시)")
	print()

	# -----------------------------------------------------------------
	# 5) SurfaceTool - 코드로 메시 생성
	# -----------------------------------------------------------------
	print("--- 5. SurfaceTool 기본 사용법 ---")

	# 삼각형 하나 만들기
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# 법선 설정 (조명 계산용)
	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(-1, -1, 0))

	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, -1, 0))

	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(0.5, 0))
	st.add_vertex(Vector3(0, 1, 0))

	# 메시로 커밋
	var triangle_mesh := st.commit()

	var tri_instance := MeshInstance3D.new()
	tri_instance.mesh = triangle_mesh
	tri_instance.position = Vector3(0, 5, -5)
	add_child(tri_instance)

	print("  SurfaceTool로 삼각형 생성:")
	print("    1. begin(PRIMITIVE_TRIANGLES)")
	print("    2. set_normal(), set_uv() 설정")
	print("    3. add_vertex() 로 정점 추가")
	print("    4. commit()으로 ArrayMesh 생성")
	print()

	# -----------------------------------------------------------------
	# 6) SurfaceTool - 절차적 평면 메시
	# -----------------------------------------------------------------
	print("--- 6. 절차적 평면 메시 생성 ---")

	var plane_mesh := _create_procedural_plane(10, 10, 1.0)
	var plane_instance := MeshInstance3D.new()
	plane_instance.mesh = plane_mesh
	plane_instance.position = Vector3(25, 0, -5)
	var plane_mat := StandardMaterial3D.new()
	plane_mat.albedo_color = Color(0.3, 0.7, 0.3)
	plane_instance.material_override = plane_mat
	add_child(plane_instance)

	print("  절차적 평면: %dx%d 격자" % [10, 10])
	print("  정점 수: %d" % [11 * 11])
	print("  삼각형 수: %d" % [10 * 10 * 2])
	print()

	# -----------------------------------------------------------------
	# 7) SurfaceTool - 절차적 지형 (높이맵 시뮬레이션)
	# -----------------------------------------------------------------
	print("--- 7. 절차적 지형 (높이맵) ---")

	var terrain_mesh := _create_procedural_terrain(20, 20, 1.0, 2.0)
	var terrain_instance := MeshInstance3D.new()
	terrain_instance.mesh = terrain_mesh
	terrain_instance.position = Vector3(0, 0, -15)
	var terrain_mat := StandardMaterial3D.new()
	terrain_mat.albedo_color = Color(0.4, 0.55, 0.25)
	terrain_instance.material_override = terrain_mat
	add_child(terrain_instance)

	print("  절차적 지형 생성: 20x20 격자")
	print("  sin/cos 기반 높이 변화 (높이 2.0)")
	print("  SurfaceTool.generate_normals()로 자동 법선 계산")
	print()

	# -----------------------------------------------------------------
	# 8) ImmediateMesh - 즉시 그리기
	# -----------------------------------------------------------------
	print("--- 8. ImmediateMesh ---")

	var imm_mesh := ImmediateMesh.new()

	# 라인 그리기
	imm_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	imm_mesh.surface_set_color(Color.RED)
	imm_mesh.surface_add_vertex(Vector3(0, 0, 0))
	imm_mesh.surface_add_vertex(Vector3(3, 0, 0))

	imm_mesh.surface_set_color(Color.GREEN)
	imm_mesh.surface_add_vertex(Vector3(0, 0, 0))
	imm_mesh.surface_add_vertex(Vector3(0, 3, 0))

	imm_mesh.surface_set_color(Color.BLUE)
	imm_mesh.surface_add_vertex(Vector3(0, 0, 0))
	imm_mesh.surface_add_vertex(Vector3(0, 0, 3))
	imm_mesh.surface_end()

	var imm_instance := MeshInstance3D.new()
	imm_instance.mesh = imm_mesh
	imm_instance.position = Vector3(40, 3, 0)
	add_child(imm_instance)

	print("  ImmediateMesh: 즉시 모드 그리기")
	print("  주요 용도:")
	print("    - 디버그 시각화 (라인, 포인트)")
	print("    - 런타임 지오메트리 (레이저, 궤적)")
	print("    - 경로 표시, 와이어프레임")
	print()
	print("  surface_begin() -> add_vertex() -> surface_end()")
	print("  clear_surfaces()로 매 프레임 새로 그릴 수 있음")
	print()

	# -----------------------------------------------------------------
	# 9) ArrayMesh - 저수준 메시 생성
	# -----------------------------------------------------------------
	print("--- 9. ArrayMesh (저수준 접근) ---")

	var arr_mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	# 정점 배열
	var vertices := PackedVector3Array([
		Vector3(-1, 0, -1), Vector3(1, 0, -1),
		Vector3(1, 0, 1), Vector3(-1, 0, 1)
	])

	# 법선 배열
	var normals := PackedVector3Array([
		Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP
	])

	# UV 배열
	var uvs := PackedVector2Array([
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)
	])

	# 인덱스 배열 (삼각형 2개 = 쿼드)
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3])

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var arr_instance := MeshInstance3D.new()
	arr_instance.mesh = arr_mesh
	arr_instance.position = Vector3(40, 0, -5)
	add_child(arr_instance)

	print("  ArrayMesh: 배열로 직접 메시 데이터 지정")
	print("  Mesh.ARRAY_VERTEX - 정점 위치 (필수)")
	print("  Mesh.ARRAY_NORMAL - 법선 벡터")
	print("  Mesh.ARRAY_TEX_UV - UV 좌표")
	print("  Mesh.ARRAY_INDEX  - 삼각형 인덱스")
	print("  Mesh.ARRAY_COLOR  - 정점 색상")
	print()
	print("  SurfaceTool vs ArrayMesh:")
	print("    SurfaceTool: 편리하고 직관적 (법선 자동 생성)")
	print("    ArrayMesh: 최대 성능, 완전한 제어")
	print()

	# -----------------------------------------------------------------
	# 10) 성능 비교
	# -----------------------------------------------------------------
	print("--- 10. 메시 생성 성능 비교 ---")

	var start := Time.get_ticks_usec()
	var _mesh1 := _create_procedural_plane(50, 50, 0.5)
	var surface_time := Time.get_ticks_usec() - start

	start = Time.get_ticks_usec()
	var _mesh2 := _create_plane_arraymesh(50, 50, 0.5)
	var array_time := Time.get_ticks_usec() - start

	print("  50x50 평면 메시 생성 시간:")
	print("    SurfaceTool: %d us" % surface_time)
	print("    ArrayMesh:   %d us" % array_time)
	print()

	print("  렌더링 성능 (draw call 비교):")
	print("    MeshInstance3D x 1000 = 1000 draw calls")
	print("    MultiMeshInstance3D x 1 (1000 인스턴스) = 1 draw call")
	print("    -> MultiMesh가 수십~수백 배 효율적!")
	print()

	print("=== 04-multimesh-surface.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## SurfaceTool로 절차적 평면 생성
func _create_procedural_plane(width: int, depth: int, cell_size: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(depth):
		for x in range(width):
			var x0 := float(x) * cell_size
			var z0 := float(z) * cell_size
			var x1 := x0 + cell_size
			var z1 := z0 + cell_size

			# 삼각형 1
			st.set_uv(Vector2(float(x) / width, float(z) / depth))
			st.add_vertex(Vector3(x0, 0, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z) / depth))
			st.add_vertex(Vector3(x1, 0, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x1, 0, z1))

			# 삼각형 2
			st.set_uv(Vector2(float(x) / width, float(z) / depth))
			st.add_vertex(Vector3(x0, 0, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x1, 0, z1))
			st.set_uv(Vector2(float(x) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x0, 0, z1))

	st.generate_normals()
	return st.commit()


## SurfaceTool로 절차적 지형 생성 (높이맵 시뮬레이션)
func _create_procedural_terrain(width: int, depth: int, cell_size: float, height_scale: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(depth):
		for x in range(width):
			var x0 := float(x) * cell_size
			var z0 := float(z) * cell_size
			var x1 := x0 + cell_size
			var z1 := z0 + cell_size

			# 높이 계산 (sin/cos 기반 간단한 지형)
			var h00 := _height_at(x0, z0, height_scale)
			var h10 := _height_at(x1, z0, height_scale)
			var h11 := _height_at(x1, z1, height_scale)
			var h01 := _height_at(x0, z1, height_scale)

			# 삼각형 1
			st.set_uv(Vector2(float(x) / width, float(z) / depth))
			st.add_vertex(Vector3(x0, h00, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z) / depth))
			st.add_vertex(Vector3(x1, h10, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x1, h11, z1))

			# 삼각형 2
			st.set_uv(Vector2(float(x) / width, float(z) / depth))
			st.add_vertex(Vector3(x0, h00, z0))
			st.set_uv(Vector2(float(x + 1) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x1, h11, z1))
			st.set_uv(Vector2(float(x) / width, float(z + 1) / depth))
			st.add_vertex(Vector3(x0, h01, z1))

	st.generate_normals()
	return st.commit()


## 높이 함수 (간단한 sin/cos 지형)
func _height_at(x: float, z: float, scale: float) -> float:
	return (sin(x * 0.5) * cos(z * 0.3) + sin(x * 0.2 + z * 0.4)) * scale * 0.5


## ArrayMesh로 평면 생성 (저수준)
func _create_plane_arraymesh(width: int, depth: int, cell_size: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	# 정점 생성
	for z in range(depth + 1):
		for x in range(width + 1):
			vertices.append(Vector3(x * cell_size, 0, z * cell_size))
			normals.append(Vector3.UP)
			uvs.append(Vector2(float(x) / width, float(z) / depth))

	# 인덱스 생성
	for z in range(depth):
		for x in range(width):
			var i := z * (width + 1) + x
			indices.append(i)
			indices.append(i + 1)
			indices.append(i + width + 2)
			indices.append(i)
			indices.append(i + width + 2)
			indices.append(i + width + 1)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
