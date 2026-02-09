# Chapter 13 - 3D Basics
# 02-mesh-and-camera.gd - MeshInstance3D와 Camera3D
#
# 이 파일에서 배울 내용:
# - MeshInstance3D로 3D 오브젝트 코드 생성
# - 프리미티브 메시 종류와 속성
# - Camera3D 설정 (Perspective vs Orthographic)
# - 카메라 제어와 뷰포트

extends Node3D

func _ready():
	print("=== MeshInstance3D와 Camera3D ===\n")

	# ============================================
	# 1. MeshInstance3D 기본
	# ============================================
	print("--- 1. MeshInstance3D 기본 ---\n")

	print("MeshInstance3D란?")
	print("  3D 메시(형태)를 화면에 그리는 노드")
	print("  Mesh 리소스를 할당해서 모양을 결정")
	print("  Material을 할당해서 외관을 결정")
	print("")

	# 코드로 MeshInstance3D 생성
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MyBox"

	# BoxMesh 할당
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(2.0, 1.0, 3.0)  # 가로, 세로, 깊이
	mesh_instance.mesh = box_mesh

	add_child(mesh_instance)
	print("BoxMesh 생성:")
	print("  mesh_instance.mesh = BoxMesh.new()")
	print("  size = %s (가로, 세로, 깊이)" % str(box_mesh.size))
	print("  subdivide_width = %d" % box_mesh.subdivide_width)
	print("  subdivide_height = %d" % box_mesh.subdivide_height)
	print("  subdivide_depth = %d" % box_mesh.subdivide_depth)

	# ============================================
	# 2. 프리미티브 메시 종류
	# ============================================
	print("\n--- 2. 프리미티브 메시 종류 ---\n")

	# BoxMesh - 직육면체
	var box := BoxMesh.new()
	box.size = Vector3(1, 1, 1)
	print("BoxMesh (직육면체):")
	print("  size = Vector3(가로, 세로, 깊이)")
	print("  subdivide_width/height/depth = 세분화")
	print("")

	# SphereMesh - 구
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 32    # 가로 세분화
	sphere.rings = 16              # 세로 세분화
	print("SphereMesh (구):")
	print("  radius = %.1f, height = %.1f" % [sphere.radius, sphere.height])
	print("  radial_segments = %d (가로 분할)" % sphere.radial_segments)
	print("  rings = %d (세로 분할)" % sphere.rings)
	print("  is_hemisphere = false (반구 모드)")
	print("")

	# CylinderMesh - 원기둥
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.5
	cylinder.bottom_radius = 0.5
	cylinder.height = 2.0
	print("CylinderMesh (원기둥):")
	print("  top_radius = %.1f" % cylinder.top_radius)
	print("  bottom_radius = %.1f" % cylinder.bottom_radius)
	print("  height = %.1f" % cylinder.height)
	print("  top_radius != bottom_radius -> 원뿔/절두체!")
	print("")

	# CapsuleMesh - 캡슐
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.5
	capsule.height = 2.0
	print("CapsuleMesh (캡슐):")
	print("  radius = %.1f" % capsule.radius)
	print("  height = %.1f (반구 포함 전체 높이)" % capsule.height)
	print("  -> 캐릭터 충돌체로 자주 사용!")
	print("")

	# PlaneMesh - 평면
	var plane := PlaneMesh.new()
	plane.size = Vector2(10, 10)
	print("PlaneMesh (평면):")
	print("  size = %s" % str(plane.size))
	print("  subdivide_width/depth = 세분화")
	print("  -> 바닥, 벽, 물 표면 등에 사용")
	print("")

	# PrismMesh - 삼각기둥
	var prism := PrismMesh.new()
	print("PrismMesh (삼각기둥):")
	print("  left_to_right = %.1f (꼭짓점 위치)" % prism.left_to_right)
	print("  size = %s" % str(prism.size))
	print("")

	# TorusMesh - 도넛
	var torus := TorusMesh.new()
	torus.inner_radius = 0.5
	torus.outer_radius = 1.0
	print("TorusMesh (도넛):")
	print("  inner_radius = %.1f (안쪽 반경)" % torus.inner_radius)
	print("  outer_radius = %.1f (바깥 반경)" % torus.outer_radius)

	# ============================================
	# 3. 코드로 여러 메시 배치
	# ============================================
	print("\n--- 3. 코드로 여러 메시 배치 ---\n")

	# 여러 오브젝트를 코드로 배치하는 예제
	var meshes_info: Array[Dictionary] = [
		{"name": "Floor", "mesh": PlaneMesh.new(), "pos": Vector3(0, 0, 0)},
		{"name": "Pillar1", "mesh": CylinderMesh.new(), "pos": Vector3(-3, 1, 0)},
		{"name": "Pillar2", "mesh": CylinderMesh.new(), "pos": Vector3(3, 1, 0)},
		{"name": "Ball", "mesh": SphereMesh.new(), "pos": Vector3(0, 3, 0)},
	]

	print("코드로 씬 구성:")
	for info in meshes_info:
		var mi := MeshInstance3D.new()
		mi.name = info["name"]
		mi.mesh = info["mesh"]
		mi.position = info["pos"]
		add_child(mi)
		print("  %s: %s at %s" % [info["name"], info["mesh"].get_class(), str(info["pos"])])

	print("")
	print("총 자식 노드 수: %d" % get_child_count())

	# ============================================
	# 4. Material 기본 (StandardMaterial3D)
	# ============================================
	print("\n--- 4. Material 기본 ---\n")

	# StandardMaterial3D로 색상 설정
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.2, 0.2)  # 빨간색
	material.metallic = 0.5
	material.roughness = 0.3

	# MeshInstance3D에 머티리얼 적용
	# 방법 1: mesh의 surface에 직접
	# 방법 2: material_override로 전체 덮어쓰기
	mesh_instance.material_override = material

	print("StandardMaterial3D 주요 속성:")
	print("  albedo_color = Color(0.8, 0.2, 0.2) -> 기본 색상")
	print("  metallic = 0.5  -> 금속성 (0: 비금속, 1: 금속)")
	print("  roughness = 0.3 -> 거칠기 (0: 매끄러움, 1: 거침)")
	print("  emission = Color(...) -> 자체 발광 색상")
	print("  emission_energy = 1.0 -> 발광 강도")
	print("")

	# 간편한 머티리얼 생성 함수
	print("머티리얼 적용 방법:")
	print("  mesh_instance.material_override = material  # 전체 적용")
	print("  mesh_instance.set_surface_override_material(0, material)  # 특정 면")
	print("")

	# 투명 머티리얼
	var transparent_mat := StandardMaterial3D.new()
	transparent_mat.albedo_color = Color(0.2, 0.5, 1.0, 0.5)  # 반투명 파란색
	transparent_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	print("투명 머티리얼:")
	print("  transparency = TRANSPARENCY_ALPHA")
	print("  albedo_color.a = 0.5  (50%% 투명)")
	print("  TRANSPARENCY_DISABLED = 불투명 (기본)")
	print("  TRANSPARENCY_ALPHA = 알파 블렌딩")
	print("  TRANSPARENCY_ALPHA_SCISSOR = 알파 컷아웃 (잎사귀)")

	# ============================================
	# 5. Camera3D 기본
	# ============================================
	print("\n--- 5. Camera3D 기본 ---\n")

	var camera := Camera3D.new()
	camera.name = "MainCamera"

	# 카메라 위치와 방향 설정
	camera.position = Vector3(0, 5, 10)
	camera.look_at(Vector3.ZERO)  # 원점을 바라봄

	add_child(camera)
	camera.make_current()  # 현재 활성 카메라로 설정

	print("Camera3D 생성:")
	print("  position = %s" % str(camera.position))
	print("  look_at(Vector3.ZERO)  -> 원점을 바라봄")
	print("  make_current()  -> 이 카메라를 활성 카메라로 설정")
	print("")

	print("활성 카메라:")
	print("  뷰포트당 하나의 카메라만 활성화 가능")
	print("  camera.make_current() 또는 camera.current = true")
	print("  get_viewport().get_camera_3d() -> 현재 활성 카메라")

	# ============================================
	# 6. Perspective vs Orthographic
	# ============================================
	print("\n--- 6. 투영 방식 ---\n")

	# Perspective (원근 투영) - 기본값
	print("Perspective (원근 투영):")
	print("  camera.projection = Camera3D.PROJECTION_PERSPECTIVE")
	print("  camera.fov = 75.0  (시야각, 도 단위)")
	print("  - 멀리 있는 물체가 작게 보임 (현실적)")
	print("  - FPS, TPS 등 대부분의 3D 게임에 사용")
	print("  - FOV가 클수록 넓게 보임 (어안 렌즈 효과)")
	print("")

	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 75.0
	print("  현재 FOV = %.1f도" % camera.fov)
	print("")

	# Orthographic (직교 투영)
	print("Orthographic (직교 투영):")
	print("  camera.projection = Camera3D.PROJECTION_ORTHOGONAL")
	print("  camera.size = 10.0  (보이는 영역 크기)")
	print("  - 거리에 상관없이 크기 동일 (원근감 없음)")
	print("  - 전략 게임, 아이소메트릭, 2.5D에 사용")
	print("  - size가 클수록 넓게 보임")
	print("")

	# Near/Far 클리핑
	print("클리핑 평면:")
	print("  camera.near = %.1f  (이것보다 가까우면 안 보임)" % camera.near)
	print("  camera.far = %.1f   (이것보다 멀면 안 보임)" % camera.far)
	print("  -> near를 너무 작게 하면 Z-fighting 발생")
	print("  -> far를 너무 크게 하면 성능 저하")

	# ============================================
	# 7. 카메라 속성 상세
	# ============================================
	print("\n--- 7. 카메라 속성 상세 ---\n")

	print("FOV (Field of View) 가이드:")
	print("  60도: 좁은 시야, 줌인 느낌")
	print("  75도: 일반적인 게임 기본값")
	print("  90도: 넓은 시야, FPS에서 인기")
	print("  110도: 매우 넓음, 어안 느낌")
	print("  -> 달리기 시 FOV를 올리면 속도감 UP!")
	print("")

	# Keep Aspect
	print("Keep Aspect:")
	print("  KEEP_WIDTH  -> 창 크기 변경 시 가로 기준")
	print("  KEEP_HEIGHT -> 창 크기 변경 시 세로 기준 (기본)")
	print("")

	# Cull Mask
	print("Cull Mask (컬링 마스크):")
	print("  어떤 레이어의 오브젝트를 렌더링할지 결정")
	print("  camera.set_cull_mask_value(layer, enabled)")
	print("  -> 미니맵 카메라에서 특정 오브젝트만 렌더링 등")

	# ============================================
	# 8. 카메라 유틸리티 함수
	# ============================================
	print("\n--- 8. 카메라 유틸리티 ---\n")

	# project_ray_origin / project_ray_normal
	print("스크린 좌표 -> 3D 레이:")
	print("  var origin = camera.project_ray_origin(screen_pos)")
	print("  var normal = camera.project_ray_normal(screen_pos)")
	print("  -> 마우스 클릭으로 3D 오브젝트 선택할 때 사용!")
	print("")

	# project_position - 스크린 좌표를 3D 위치로
	print("스크린 좌표 -> 3D 위치:")
	print("  var world_pos = camera.project_position(screen_pos, distance)")
	print("  -> 특정 깊이(distance)에서의 월드 좌표")
	print("")

	# unproject_position - 3D 위치를 스크린 좌표로
	print("3D 위치 -> 스크린 좌표:")
	print("  var screen_pos = camera.unproject_position(world_pos)")
	print("  -> 3D 오브젝트 위에 UI 표시할 때 사용!")
	print("")

	# is_position_behind - 카메라 뒤에 있는지
	print("위치가 카메라 뒤에 있는지:")
	print("  camera.is_position_behind(world_pos) -> bool")
	print("  -> 화면 밖 마커 표시 여부 결정에 유용")

	# ============================================
	# 9. 다중 카메라와 전환
	# ============================================
	print("\n--- 9. 다중 카메라 전환 ---\n")

	# 두 번째 카메라 생성
	var camera2 := Camera3D.new()
	camera2.name = "TopDownCamera"
	camera2.position = Vector3(0, 20, 0)
	camera2.rotation_degrees = Vector3(-90, 0, 0)  # 아래를 바라봄
	add_child(camera2)

	print("카메라 전환:")
	print("  # 방법 1: make_current()")
	print("  camera_top.make_current()")
	print("")
	print("  # 방법 2: current 속성")
	print("  camera_top.current = true")
	print("")
	print("  # 방법 3: 보간으로 부드러운 전환")
	print("  var tween = create_tween()")
	print("  tween.tween_property(camera, 'global_position',")
	print("                       target_pos, 1.0)")
	print("  tween.parallel().tween_property(camera, 'fov',")
	print("                                  target_fov, 1.0)")

	# ============================================
	# 10. 실전: 간단한 씬 구성
	# ============================================
	print("\n--- 10. 실전: 씬 구성 코드 ---\n")

	print("""# 코드로 기본 3D 씬 구성하기
func setup_scene():
    # 바닥
    var floor_mi = MeshInstance3D.new()
    var floor_mesh = PlaneMesh.new()
    floor_mesh.size = Vector2(20, 20)
    floor_mi.mesh = floor_mesh
    var floor_mat = StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.3, 0.5, 0.3)
    floor_mi.material_override = floor_mat
    add_child(floor_mi)

    # 큐브들 배치
    for i in range(5):
        var cube_mi = MeshInstance3D.new()
        var cube_mesh = BoxMesh.new()
        cube_mesh.size = Vector3(1, 1 + i * 0.5, 1)
        cube_mi.mesh = cube_mesh
        cube_mi.position = Vector3(i * 2 - 4, cube_mesh.size.y / 2.0, 0)

        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(i * 0.2, 0.3, 1.0 - i * 0.2)
        cube_mi.material_override = mat
        add_child(cube_mi)

    # 카메라
    var cam = Camera3D.new()
    cam.position = Vector3(0, 5, 10)
    cam.look_at(Vector3.ZERO)
    cam.make_current()
    add_child(cam)""")

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. MeshInstance3D: 3D 오브젝트를 화면에 그리는 노드")
	print("2. 프리미티브 메시: Box, Sphere, Cylinder, Capsule, Plane 등")
	print("3. StandardMaterial3D: 색상, 금속성, 거칠기 설정")
	print("4. Camera3D: 3D 씬을 화면에 투영")
	print("5. Perspective: 원근감 있는 투영 (fov)")
	print("6. Orthographic: 원근감 없는 투영 (size)")
	print("7. project/unproject: 스크린 <-> 3D 좌표 변환")
	print("8. make_current(): 활성 카메라 전환")
