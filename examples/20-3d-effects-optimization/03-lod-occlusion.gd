# Chapter 20 - 3D Effects & Optimization
# 03-lod-occlusion.gd - LOD, Visibility Range, Occlusion Culling
#
# 이 파일에서 배울 내용:
# - LOD (Level of Detail) 개념과 구현
# - Visibility Range (HLOD)로 거리별 메시 전환
# - OccluderInstance3D로 오클루전 컬링
# - GeometryInstance3D 가시성 설정
# - 카메라 기반 최적화 기법

extends Node3D

func _ready():
	print("=== Chapter 20-3: LOD & Occlusion Culling ===\n")

	# -----------------------------------------------------------------
	# 1) LOD (Level of Detail) 개념
	# -----------------------------------------------------------------
	print("--- 1. LOD 개념 ---")

	print("  LOD: 카메라 거리에 따라 메시의 디테일 수준을 변경")
	print("  가까이 -> 고품질 메시 (많은 폴리곤)")
	print("  멀리   -> 저품질 메시 (적은 폴리곤)")
	print()
	print("  LOD 0 (가까움): 5000 폴리곤  - 최고 품질")
	print("  LOD 1 (중간):   2000 폴리곤  - 중간 품질")
	print("  LOD 2 (먼 거리): 500 폴리곤  - 낮은 품질")
	print("  LOD 3 (최원거리): 50 폴리곤  - 임포스터/빌보드")
	print()
	print("  장점:")
	print("    - GPU 부담 대폭 감소 (먼 오브젝트)")
	print("    - 시각적 품질 거의 동일")
	print("    - 대규모 오픈 월드 필수")
	print()

	# -----------------------------------------------------------------
	# 2) Godot의 자동 LOD (Mesh LOD)
	# -----------------------------------------------------------------
	print("--- 2. 자동 Mesh LOD ---")

	print("  Godot 4는 임포트 시 자동 LOD 생성을 지원합니다:")
	print()
	print("  임포트 설정 (GLTF/OBJ):")
	print("    리소스 선택 > Import 패널")
	print("    Meshes > LOD Mode = Auto")
	print("    Meshes > LOD Normal Merge Angle = 60도")
	print("    Meshes > LOD Normal Split Angle = 25도")
	print()

	# 수동 LOD 메시 생성 데모
	print("  코드에서 LOD 설정:")
	print("    mesh.surface_get_lods() - LOD 레벨 확인")
	print("    프로젝트 설정 > Rendering > Mesh LOD")
	print("    mesh_lod_threshold - LOD 전환 임계값")
	print()

	# LOD 레벨별 메시 생성
	var lod_meshes: Array[Mesh] = []

	# LOD 0 - 높은 디테일
	var lod0 := SphereMesh.new()
	lod0.radial_segments = 64
	lod0.rings = 32
	lod_meshes.append(lod0)

	# LOD 1 - 중간 디테일
	var lod1 := SphereMesh.new()
	lod1.radial_segments = 16
	lod1.rings = 8
	lod_meshes.append(lod1)

	# LOD 2 - 낮은 디테일
	var lod2 := SphereMesh.new()
	lod2.radial_segments = 8
	lod2.rings = 4
	lod_meshes.append(lod2)

	print("  수동 LOD 메시 생성:")
	for i in range(lod_meshes.size()):
		var m: SphereMesh = lod_meshes[i] as SphereMesh
		print("    LOD %d: segments=%d, rings=%d" % [
			i, m.radial_segments, m.rings
		])
	print()

	# -----------------------------------------------------------------
	# 3) Visibility Range (HLOD)
	# -----------------------------------------------------------------
	print("--- 3. Visibility Range ---")

	print("  GeometryInstance3D의 visibility_range_* 속성으로")
	print("  거리에 따라 메시 표시/숨김을 제어합니다")
	print()

	# LOD 0 - 가까운 거리 (0~20m)
	var mesh_lod0 := MeshInstance3D.new()
	mesh_lod0.mesh = lod0
	mesh_lod0.visibility_range_begin = 0.0
	mesh_lod0.visibility_range_end = 20.0
	mesh_lod0.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	var mat0 := StandardMaterial3D.new()
	mat0.albedo_color = Color(0.2, 0.6, 0.9)
	mesh_lod0.material_override = mat0
	add_child(mesh_lod0)

	# LOD 1 - 중간 거리 (20~50m)
	var mesh_lod1 := MeshInstance3D.new()
	mesh_lod1.mesh = lod1
	mesh_lod1.position = Vector3(0, 0, 0)  # 같은 위치
	mesh_lod1.visibility_range_begin = 20.0
	mesh_lod1.visibility_range_end = 50.0
	mesh_lod1.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	var mat1 := StandardMaterial3D.new()
	mat1.albedo_color = Color(0.6, 0.9, 0.2)
	mesh_lod1.material_override = mat1
	add_child(mesh_lod1)

	# LOD 2 - 먼 거리 (50~100m)
	var mesh_lod2 := MeshInstance3D.new()
	mesh_lod2.mesh = lod2
	mesh_lod2.position = Vector3(0, 0, 0)
	mesh_lod2.visibility_range_begin = 50.0
	mesh_lod2.visibility_range_end = 100.0
	mesh_lod2.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = Color(0.9, 0.3, 0.2)
	mesh_lod2.material_override = mat2
	add_child(mesh_lod2)

	print("  Visibility Range 설정:")
	print("    LOD 0 (파랑): 0 ~ 20m")
	print("    LOD 1 (녹색): 20 ~ 50m")
	print("    LOD 2 (빨강): 50 ~ 100m")
	print()

	print("  속성:")
	print("    visibility_range_begin - 보이기 시작하는 거리")
	print("    visibility_range_end   - 사라지는 거리")
	print("    visibility_range_begin_margin - 시작 마진")
	print("    visibility_range_end_margin   - 종료 마진")
	print()

	print("  visibility_range_fade_mode:")
	print("    VISIBILITY_RANGE_FADE_DISABLED - 즉시 전환")
	print("    VISIBILITY_RANGE_FADE_SELF     - 자체 페이드")
	print("    VISIBILITY_RANGE_FADE_DEPENDENCIES - 의존성 페이드")
	print()

	# -----------------------------------------------------------------
	# 4) Occlusion Culling (오클루전 컬링)
	# -----------------------------------------------------------------
	print("--- 4. Occlusion Culling ---")

	print("  오클루전 컬링: 다른 오브젝트에 가려진 오브젝트를 렌더링 건너뛰기")
	print("  예: 벽 뒤의 오브젝트는 그리지 않음")
	print()

	print("  활성화:")
	print("    프로젝트 설정 > Rendering > Occlusion Culling")
	print("    use_occlusion_culling = true")
	print()

	# OccluderInstance3D 생성
	var occluder := OccluderInstance3D.new()
	var box_occluder := BoxOccluder3D.new()
	box_occluder.size = Vector3(5, 3, 0.3)
	occluder.occluder = box_occluder
	occluder.position = Vector3(0, 1.5, -3)
	add_child(occluder)

	print("  OccluderInstance3D 설정:")
	print("    BoxOccluder3D: size = %s" % str(box_occluder.size))
	print("    위치: %s (벽처럼 배치)" % str(occluder.position))
	print()

	print("  오클루더 형태:")
	print("    BoxOccluder3D      - 직육면체 (벽, 건물)")
	print("    SphereOccluder3D   - 구 (둥근 오브젝트)")
	print("    PolygonOccluder3D  - 다각형 (불규칙 형태)")
	print("    QuadOccluder3D     - 사각형 (얇은 벽)")
	print()

	# 벽 뒤에 오브젝트 배치 (오클루전 대상)
	var hidden_obj := MeshInstance3D.new()
	hidden_obj.mesh = BoxMesh.new()
	hidden_obj.position = Vector3(0, 1, -6)
	var hidden_mat := StandardMaterial3D.new()
	hidden_mat.albedo_color = Color.RED
	hidden_obj.material_override = hidden_mat
	add_child(hidden_obj)

	# 시각적 벽 (오클루더와 일치)
	var wall_mesh := MeshInstance3D.new()
	var wall_box := BoxMesh.new()
	wall_box.size = Vector3(5, 3, 0.3)
	wall_mesh.mesh = wall_box
	wall_mesh.position = Vector3(0, 1.5, -3)
	add_child(wall_mesh)

	print("  벽(오클루더) 뒤의 빨간 박스:")
	print("    카메라가 벽 앞에 있으면 렌더링 건너뜀")
	print("    -> draw call 절감!")
	print()

	# -----------------------------------------------------------------
	# 5) 자동 오클루전 (StaticBody3D)
	# -----------------------------------------------------------------
	print("--- 5. 자동 오클루전 ---")

	print("  Godot 4에서 오클루전 자동화:")
	print()
	print("  방법 1: 에디터에서 자동 베이크")
	print("    프로젝트 설정 > Rendering > Occlusion Culling")
	print("    OccluderInstance3D의 bake_simplification 설정")
	print()
	print("  방법 2: MeshInstance3D에서 자동 생성")
	print("    mesh_instance.generate_occluder() - 메시 기반 오클루더")
	print("    # 에디터 > Mesh 메뉴 > Create Occluder")
	print()

	# -----------------------------------------------------------------
	# 6) Frustum Culling (절두체 컬링)
	# -----------------------------------------------------------------
	print("--- 6. Frustum Culling ---")

	print("  절두체 컬링: 카메라 시야 밖의 오브젝트를 자동으로 건너뜀")
	print("  Godot에서 기본으로 활성화되어 있습니다")
	print()
	print("  올바른 작동을 위해:")
	print("    1. AABB가 정확해야 함 (자동 계산)")
	print("    2. 커스텀 메시는 수동 AABB 설정 필요:")
	print("       mesh_instance.custom_aabb = AABB(pos, size)")
	print()
	print("  파티클 AABB:")
	print("    GPUParticles3D.visibility_aabb = AABB(...)")
	print("    # 너무 작으면 파티클이 갑자기 사라짐")
	print("    # 너무 크면 불필요한 렌더링")
	print()

	# -----------------------------------------------------------------
	# 7) 거리 기반 최적화
	# -----------------------------------------------------------------
	print("--- 7. 거리 기반 최적화 ---")

	print("  거리에 따른 최적화 전략:")
	print()

	# 대규모 배치 데모
	var distance_groups := {
		"근거리 (0-30m)": {"count": 0, "features": "풀 렌더링 + 그림자 + 물리"},
		"중거리 (30-80m)": {"count": 0, "features": "LOD 1 + 간소화 그림자"},
		"원거리 (80-200m)": {"count": 0, "features": "LOD 2 + 그림자 없음"},
		"초원거리 (200m+)": {"count": 0, "features": "빌보드/임포스터 또는 숨김"},
	}

	for dist_name in distance_groups:
		var info: Dictionary = distance_groups[dist_name]
		print("    %s:" % dist_name)
		print("      %s" % info["features"])
	print()

	print("  코드에서 거리 기반 제어:")
	print("    func _process(delta):")
	print("        var camera = get_viewport().get_camera_3d()")
	print("        var dist = global_position.distance_to(camera.global_position)")
	print()
	print("        if dist > 200:")
	print("            visible = false")
	print("        elif dist > 80:")
	print("            shadow_mode = SHADOW_CASTING_SETTING_OFF")
	print("        elif dist > 30:")
	print("            # LOD 전환")
	print("            pass")
	print()

	# -----------------------------------------------------------------
	# 8) GeometryInstance3D 추가 설정
	# -----------------------------------------------------------------
	print("--- 8. GeometryInstance3D 설정 ---")

	print("  모든 시각 오브젝트의 기본 속성:")
	print()
	print("  그림자 설정:")
	print("    cast_shadow:")
	print("      SHADOW_CASTING_SETTING_OFF     - 그림자 없음")
	print("      SHADOW_CASTING_SETTING_ON      - 그림자 있음 (기본)")
	print("      SHADOW_CASTING_SETTING_DOUBLE_SIDED - 양면 그림자")
	print("      SHADOW_CASTING_SETTING_SHADOWS_ONLY - 그림자만 (메시 안 보임)")
	print()

	print("  GI 설정:")
	print("    gi_mode:")
	print("      GI_MODE_DISABLED - GI 비활성화")
	print("      GI_MODE_STATIC   - 정적 GI (라이트맵)")
	print("      GI_MODE_DYNAMIC  - 동적 GI")
	print()

	print("  렌더 레이어:")
	print("    layers - 비트마스크로 카메라별 가시성 제어")
	print("    Camera3D.cull_mask와 매칭")
	print()

	# 데모: 그림자 설정
	var shadow_demo := MeshInstance3D.new()
	shadow_demo.mesh = BoxMesh.new()
	shadow_demo.position = Vector3(5, 1, 5)
	shadow_demo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(shadow_demo)
	print("  데모: BoxMesh cast_shadow = ON")
	print()

	# -----------------------------------------------------------------
	# 9) LOD 전환 부드럽게 하기
	# -----------------------------------------------------------------
	print("--- 9. LOD 전환 부드럽게 ---")

	print("  LOD 전환 시 팝핑(갑작스런 변화) 방지:")
	print()
	print("  방법 1: Visibility Range Fade")
	print("    visibility_range_fade_mode = FADE_SELF")
	print("    -> 자동 알파 페이드")
	print()
	print("  방법 2: Dithering (디더링)")
	print("    셰이더에서 디더 패턴으로 투명도 전환")
	print("    -> 알파 블렌딩보다 가벼움")
	print()
	print("  방법 3: 여유 구간 (Hysteresis)")
	print("    전환 거리에 여유를 두어 반복 전환 방지")
	print("    visibility_range_begin_margin = 2.0")
	print("    visibility_range_end_margin = 2.0")
	print()

	# -----------------------------------------------------------------
	# 10) 컬링 디버그
	# -----------------------------------------------------------------
	print("--- 10. 컬링 디버그 ---")

	print("  Performance 모니터:")
	var render_objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var render_draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	print("    렌더링 오브젝트: %.0f" % render_objects)
	print("    Draw Calls: %.0f" % render_draw_calls)
	print()

	print("  디버그 시각화:")
	print("    에디터 > View > View Frustum (절두체 확인)")
	print("    프로젝트 설정 > Debug > Rendering")
	print()
	print("  프로파일링:")
	print("    RenderingServer.get_rendering_info():")
	print("    - RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME")
	print("    - RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME")
	print("    - RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME")
	print()

	var total_prims := RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME
	)
	print("    현재 프레임 총 프리미티브: %d" % total_prims)
	print()

	print("  최적화 우선순위:")
	print("    1. 오클루전 컬링 (가려진 것 안 그리기)")
	print("    2. LOD (먼 것 간단하게)")
	print("    3. Frustum Culling (시야 밖 안 그리기) - 자동")
	print("    4. 거리 페이드 (아주 먼 것 숨기기)")
	print()

	print("=== 03-lod-occlusion.gd 완료 ===")
