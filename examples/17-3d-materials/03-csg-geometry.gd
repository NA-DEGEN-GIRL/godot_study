# Chapter 17 - 3D Materials & Shaders
# 03-csg-geometry.gd - CSG 노드들, Union/Intersection/Subtraction
#
# 이 파일에서 배울 내용:
# - CSG (Constructive Solid Geometry) 개념
# - CSGBox3D, CSGSphere3D, CSGCylinder3D 등 기본 형태
# - Boolean 연산: Union, Intersection, Subtraction
# - CSGCombiner3D로 복합 형태 구성
# - CSG를 이용한 프로토타이핑과 레벨 디자인
# - CSG의 한계점과 MeshInstance3D 변환

extends Node3D

func _ready():
	print("=== Chapter 17-3: CSG Geometry ===\n")

	# -----------------------------------------------------------------
	# 1) CSG 기본 개념
	# -----------------------------------------------------------------
	print("--- 1. CSG (Constructive Solid Geometry) 개념 ---")

	print("  CSG는 기본 도형의 Boolean(불리언) 연산으로 복잡한 형태를 만드는 기법")
	print()
	print("  3가지 Boolean 연산:")
	print("    UNION (합집합)        - 두 형태를 합침")
	print("    INTERSECTION (교집합) - 겹치는 부분만 남김")
	print("    SUBTRACTION (차집합)  - 한 형태에서 다른 형태를 뺌")
	print()
	print("  Godot CSG 노드 종류:")
	print("    CSGBox3D       - 직육면체")
	print("    CSGSphere3D    - 구")
	print("    CSGCylinder3D  - 원기둥/원뿔")
	print("    CSGTorus3D     - 토러스 (도넛)")
	print("    CSGPolygon3D   - 다각형 압출")
	print("    CSGMesh3D      - 커스텀 메시 기반")
	print("    CSGCombiner3D  - Boolean 연산 컨테이너")
	print()

	# -----------------------------------------------------------------
	# 2) 기본 CSG 형태 생성
	# -----------------------------------------------------------------
	print("--- 2. 기본 CSG 형태 생성 ---")

	# CSGBox3D
	var csg_box := CSGBox3D.new()
	csg_box.size = Vector3(2, 1, 2)
	csg_box.position = Vector3(0, 0, 0)
	add_child(csg_box)
	print("  CSGBox3D 생성: size = ", csg_box.size)

	# CSGSphere3D
	var csg_sphere := CSGSphere3D.new()
	csg_sphere.radius = 1.0
	csg_sphere.radial_segments = 24    # 수평 분할
	csg_sphere.rings = 12              # 수직 분할
	csg_sphere.position = Vector3(4, 0, 0)
	add_child(csg_sphere)
	print("  CSGSphere3D 생성: radius = %.1f, segments = %d" % [
		csg_sphere.radius, csg_sphere.radial_segments
	])

	# CSGCylinder3D
	var csg_cylinder := CSGCylinder3D.new()
	csg_cylinder.radius = 0.8
	csg_cylinder.height = 2.0
	csg_cylinder.sides = 16           # 면 수 (높을수록 둥근)
	csg_cylinder.position = Vector3(8, 0, 0)
	add_child(csg_cylinder)
	print("  CSGCylinder3D 생성: radius = %.1f, height = %.1f" % [
		csg_cylinder.radius, csg_cylinder.height
	])

	# CSGCylinder3D - 원뿔 모드
	var csg_cone := CSGCylinder3D.new()
	csg_cone.radius = 1.0
	csg_cone.height = 2.0
	csg_cone.cone = true              # 원뿔 모드 활성화
	csg_cone.position = Vector3(12, 0, 0)
	add_child(csg_cone)
	print("  CSGCylinder3D (cone): 원뿔 모드")

	# CSGTorus3D
	var csg_torus := CSGTorus3D.new()
	csg_torus.inner_radius = 0.5
	csg_torus.outer_radius = 1.5
	csg_torus.ring_sides = 12
	csg_torus.sides = 24
	csg_torus.position = Vector3(16, 0, 0)
	add_child(csg_torus)
	print("  CSGTorus3D 생성: inner = %.1f, outer = %.1f" % [
		csg_torus.inner_radius, csg_torus.outer_radius
	])
	print()

	# -----------------------------------------------------------------
	# 3) CSG 재질 적용
	# -----------------------------------------------------------------
	print("--- 3. CSG에 재질 적용 ---")

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.3, 0.2)
	material.roughness = 0.4
	csg_box.material = material
	print("  CSG 노드는 material 속성으로 재질 설정")
	print("  csg_box.material = StandardMaterial3D")

	# 각 CSG 노드에 다른 재질 적용
	var mat_blue := StandardMaterial3D.new()
	mat_blue.albedo_color = Color(0.2, 0.4, 0.8)
	csg_sphere.material = mat_blue

	var mat_green := StandardMaterial3D.new()
	mat_green.albedo_color = Color(0.2, 0.7, 0.3)
	csg_cylinder.material = mat_green

	print("  각 CSG 노드에 개별 재질 적용 완료")
	print()

	# -----------------------------------------------------------------
	# 4) Boolean 연산 - UNION (합집합)
	# -----------------------------------------------------------------
	print("--- 4. Boolean: UNION (합집합) ---")

	var combiner_union := CSGCombiner3D.new()
	combiner_union.position = Vector3(0, 3, 0)
	add_child(combiner_union)

	var union_box := CSGBox3D.new()
	union_box.size = Vector3(2, 1, 1)
	union_box.operation = CSGShape3D.OPERATION_UNION
	combiner_union.add_child(union_box)

	var union_sphere := CSGSphere3D.new()
	union_sphere.radius = 0.8
	union_sphere.position = Vector3(1, 0, 0)
	union_sphere.operation = CSGShape3D.OPERATION_UNION
	combiner_union.add_child(union_sphere)

	print("  CSGCombiner3D + UNION:")
	print("    두 형태가 합쳐져서 하나의 형태가 됩니다")
	print("    겹치는 부분의 내부 면이 제거됩니다")
	print("    첫 번째 자식은 항상 기준(base) 형태")
	print()

	# -----------------------------------------------------------------
	# 5) Boolean 연산 - SUBTRACTION (차집합)
	# -----------------------------------------------------------------
	print("--- 5. Boolean: SUBTRACTION (차집합) ---")

	var combiner_sub := CSGCombiner3D.new()
	combiner_sub.position = Vector3(5, 3, 0)
	add_child(combiner_sub)

	# 기준 박스
	var sub_box := CSGBox3D.new()
	sub_box.size = Vector3(2, 2, 2)
	var mat_sub := StandardMaterial3D.new()
	mat_sub.albedo_color = Color(0.7, 0.7, 0.7)
	sub_box.material = mat_sub
	combiner_sub.add_child(sub_box)

	# 빼낼 구 (SUBTRACTION)
	var sub_sphere := CSGSphere3D.new()
	sub_sphere.radius = 1.2
	sub_sphere.position = Vector3(0.5, 0.5, 0.5)
	sub_sphere.operation = CSGShape3D.OPERATION_SUBTRACTION
	combiner_sub.add_child(sub_sphere)

	print("  CSGCombiner3D + SUBTRACTION:")
	print("    박스에서 구를 빼서 구멍을 만듭니다")
	print("    건축물의 창문, 동굴, 터널 등에 활용")
	print()
	print("  활용 예시:")
	print("    - 벽에 문/창문 구멍 뚫기")
	print("    - 치즈 구멍 효과")
	print("    - 파이프/튜브 내부 만들기")
	print()

	# 여러 구멍 예시 - 벽에 창문
	var wall := CSGCombiner3D.new()
	wall.position = Vector3(10, 3, 0)
	add_child(wall)

	var wall_base := CSGBox3D.new()
	wall_base.size = Vector3(4, 3, 0.3)
	var mat_wall := StandardMaterial3D.new()
	mat_wall.albedo_color = Color(0.85, 0.82, 0.75)
	wall_base.material = mat_wall
	wall.add_child(wall_base)

	# 창문 구멍 1
	var window1 := CSGBox3D.new()
	window1.size = Vector3(0.8, 1.2, 0.5)
	window1.position = Vector3(-1.0, 0.3, 0)
	window1.operation = CSGShape3D.OPERATION_SUBTRACTION
	wall.add_child(window1)

	# 창문 구멍 2
	var window2 := CSGBox3D.new()
	window2.size = Vector3(0.8, 1.2, 0.5)
	window2.position = Vector3(1.0, 0.3, 0)
	window2.operation = CSGShape3D.OPERATION_SUBTRACTION
	wall.add_child(window2)

	# 문 구멍
	var door := CSGBox3D.new()
	door.size = Vector3(1.0, 2.0, 0.5)
	door.position = Vector3(0, -0.5, 0)
	door.operation = CSGShape3D.OPERATION_SUBTRACTION
	wall.add_child(door)

	print("  벽 + 창문 예제:")
	print("    벽(Box) - 창문1(Box) - 창문2(Box) - 문(Box)")
	print("    SUBTRACTION으로 구멍 3개 생성")
	print()

	# -----------------------------------------------------------------
	# 6) Boolean 연산 - INTERSECTION (교집합)
	# -----------------------------------------------------------------
	print("--- 6. Boolean: INTERSECTION (교집합) ---")

	var combiner_inter := CSGCombiner3D.new()
	combiner_inter.position = Vector3(0, 6, 0)
	add_child(combiner_inter)

	var inter_box := CSGBox3D.new()
	inter_box.size = Vector3(2, 2, 2)
	combiner_inter.add_child(inter_box)

	var inter_sphere := CSGSphere3D.new()
	inter_sphere.radius = 1.3
	inter_sphere.operation = CSGShape3D.OPERATION_INTERSECTION
	combiner_inter.add_child(inter_sphere)

	print("  CSGCombiner3D + INTERSECTION:")
	print("    박스와 구가 겹치는 부분만 남습니다")
	print("    둥근 모서리의 큐브 효과")
	print()
	print("  활용 예시:")
	print("    - 렌즈 형태 (두 구의 교집합)")
	print("    - 둥근 큐브 만들기")
	print("    - 특수 형태 조합")
	print()

	# -----------------------------------------------------------------
	# 7) CSGPolygon3D - 다각형 압출
	# -----------------------------------------------------------------
	print("--- 7. CSGPolygon3D (다각형 압출) ---")

	var csg_polygon := CSGPolygon3D.new()

	# L자 형태의 다각형 정의
	var polygon_points := PackedVector2Array([
		Vector2(0, 0),
		Vector2(2, 0),
		Vector2(2, 0.5),
		Vector2(0.5, 0.5),
		Vector2(0.5, 2),
		Vector2(0, 2),
	])
	csg_polygon.polygon = polygon_points
	csg_polygon.depth = 1.0  # 압출 깊이
	csg_polygon.position = Vector3(5, 6, 0)
	add_child(csg_polygon)

	print("  CSGPolygon3D: 2D 다각형을 3D로 압출")
	print("  polygon = L자 형태 (6 포인트)")
	print("  depth = %.1f (압출 깊이)" % csg_polygon.depth)
	print()

	print("  압출 모드:")
	print("    MODE_DEPTH - 직선 방향으로 압출 (기본)")
	print("    MODE_SPIN - 축을 중심으로 회전 (선반 가공)")
	print("    MODE_PATH - 경로를 따라 압출")
	print()

	# Spin 모드 (회전 압출) 설명
	print("  Spin 모드 설정:")
	print("    csg_polygon.mode = CSGPolygon3D.MODE_SPIN")
	print("    csg_polygon.spin_degrees = 360  # 완전 회전")
	print("    # 꽃병, 그릇, 바퀴 등 회전체 생성")
	print()

	# -----------------------------------------------------------------
	# 8) CSG 충돌 생성
	# -----------------------------------------------------------------
	print("--- 8. CSG 충돌 설정 ---")

	# CSG는 자동으로 충돌체를 생성할 수 있습니다
	var csg_collidable := CSGBox3D.new()
	csg_collidable.size = Vector3(3, 0.5, 3)
	csg_collidable.use_collision = true  # 충돌 활성화
	csg_collidable.position = Vector3(0, -1, 0)
	add_child(csg_collidable)

	print("  use_collision = true 로 충돌 활성화")
	print("  CSG의 최종 형태에 맞는 충돌체가 자동 생성됩니다")
	print("  Boolean 연산 후의 결과 형태로 충돌체가 만들어짐")
	print()

	print("  충돌 레이어/마스크 설정:")
	print("    csg.collision_layer = 1  # 물리 레이어")
	print("    csg.collision_mask = 1   # 감지할 레이어")
	print()

	# -----------------------------------------------------------------
	# 9) CSG 프로토타이핑 실전 예제
	# -----------------------------------------------------------------
	print("--- 9. 프로토타이핑 예제: 간단한 건물 ---")

	var building := _create_simple_building(Vector3(15, 6, 0))
	add_child(building)

	print("  간단한 건물 프로토타입 생성 완료")
	print("  구성: 본체(Box) + 지붕(Cylinder) - 문(Box) - 창문들(Box)")
	print()

	# -----------------------------------------------------------------
	# 10) CSG 한계점과 대안
	# -----------------------------------------------------------------
	print("--- 10. CSG 한계점과 대안 ---")

	print("  CSG 장점:")
	print("    + 빠른 프로토타이핑")
	print("    + 코드로 절차적 생성 가능")
	print("    + Boolean 연산으로 복잡한 형태")
	print("    + 자동 충돌체 생성")
	print()

	print("  CSG 단점:")
	print("    - 성능 비용이 높음 (매 프레임 재계산 가능)")
	print("    - 복잡한 형태에서 글리치 발생 가능")
	print("    - LOD 지원 안 됨")
	print("    - UV 매핑 제한적")
	print()

	print("  최종 제품에서는:")
	print("    1. CSG로 프로토타입 제작")
	print("    2. 에디터에서 'Mesh > Bake Mesh' 실행")
	print("    3. MeshInstance3D로 변환하여 사용")
	print("    # 또는 Blender 등 외부 모델링 도구 사용")
	print()

	# CSG 노드 수 확인
	var csg_count := 0
	for child in get_children():
		if child is CSGShape3D or child is CSGCombiner3D:
			csg_count += 1
	print("  현재 씬의 CSG 노드 수: %d" % csg_count)
	print()

	print("=== 03-csg-geometry.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 간단한 건물 프로토타입 생성
func _create_simple_building(pos: Vector3) -> CSGCombiner3D:
	var building := CSGCombiner3D.new()
	building.position = pos

	# 건물 본체
	var body := CSGBox3D.new()
	body.size = Vector3(4, 3, 3)
	body.position = Vector3(0, 1.5, 0)
	var mat_body := StandardMaterial3D.new()
	mat_body.albedo_color = Color(0.82, 0.78, 0.7)
	body.material = mat_body
	building.add_child(body)

	# 지붕 (삼각 형태 - 박스를 45도 회전)
	var roof := CSGBox3D.new()
	roof.size = Vector3(4.5, 2, 3.5)
	roof.position = Vector3(0, 3.8, 0)
	roof.rotation_degrees = Vector3(0, 0, 45)
	var mat_roof := StandardMaterial3D.new()
	mat_roof.albedo_color = Color(0.6, 0.2, 0.15)
	roof.material = mat_roof
	building.add_child(roof)

	# 지붕 위 잘라내기 (아래 부분 제거)
	var roof_cut := CSGBox3D.new()
	roof_cut.size = Vector3(6, 2, 5)
	roof_cut.position = Vector3(0, 2.2, 0)
	roof_cut.operation = CSGShape3D.OPERATION_SUBTRACTION
	building.add_child(roof_cut)

	# 문
	var door_hole := CSGBox3D.new()
	door_hole.size = Vector3(0.8, 1.8, 1.0)
	door_hole.position = Vector3(0, 0.9, 1.5)
	door_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	building.add_child(door_hole)

	# 창문들
	for x_offset in [-1.2, 1.2]:
		var window := CSGBox3D.new()
		window.size = Vector3(0.6, 0.6, 1.0)
		window.position = Vector3(x_offset, 2.0, 1.5)
		window.operation = CSGShape3D.OPERATION_SUBTRACTION
		building.add_child(window)

	return building
