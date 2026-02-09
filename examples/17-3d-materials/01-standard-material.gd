# Chapter 17 - 3D Materials & Shaders
# 01-standard-material.gd - StandardMaterial3D, Albedo, Metallic/Roughness, Normal Map, Emission
#
# 이 파일에서 배울 내용:
# - StandardMaterial3D의 기본 속성과 생성법
# - Albedo (기본 색상/텍스처) 설정
# - Metallic과 Roughness (PBR 재질)
# - Normal Map을 이용한 표면 디테일
# - Emission (자체 발광) 효과
# - 투명도, 백페이스 렌더링, UV 옵션

extends Node3D

func _ready():
	print("=== Chapter 17-1: StandardMaterial3D ===\n")

	# -----------------------------------------------------------------
	# 1) StandardMaterial3D 기본 생성
	# -----------------------------------------------------------------
	print("--- 1. StandardMaterial3D 기본 생성 ---")

	# StandardMaterial3D는 Godot의 기본 PBR 재질입니다
	# PBR = Physically Based Rendering (물리 기반 렌더링)
	var material := StandardMaterial3D.new()

	print("  재질 생성 완료: ", material)
	print("  재질 타입: ", material.get_class())
	print()

	# MeshInstance3D에 재질 적용하기
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.material_override = material
	add_child(mesh_instance)

	print("  SphereMesh에 재질 적용 완료")
	print("  material_override: 모든 서피스에 동일 재질 적용")
	print("  set_surface_override_material(0, mat): 특정 서피스만 적용")
	print()

	# -----------------------------------------------------------------
	# 2) Albedo - 기본 색상과 텍스처
	# -----------------------------------------------------------------
	print("--- 2. Albedo (기본 색상) ---")

	# Albedo는 물체의 기본 색상입니다
	var mat_red := StandardMaterial3D.new()
	mat_red.albedo_color = Color(1.0, 0.2, 0.2)  # 빨간색
	print("  albedo_color = Color(1.0, 0.2, 0.2)")
	print("  설정된 색상: ", mat_red.albedo_color)

	# 다양한 색상 지정 방법
	var mat_hex := StandardMaterial3D.new()
	mat_hex.albedo_color = Color.html("#3498db")  # 16진수
	print("  Color.html(\"#3498db\"): ", mat_hex.albedo_color)

	var mat_named := StandardMaterial3D.new()
	mat_named.albedo_color = Color.CORNFLOWER_BLUE  # 이름 상수
	print("  Color.CORNFLOWER_BLUE: ", mat_named.albedo_color)

	# Albedo 텍스처 설정 (파일이 있을 경우)
	print()
	print("  텍스처 적용 코드:")
	print("    var tex = load(\"res://textures/brick.png\")")
	print("    material.albedo_texture = tex")
	print("    material.albedo_color = Color.WHITE  # 텍스처 원색 유지")
	print()

	# 색상 + 텍스처 조합
	print("  색상과 텍스처는 곱셈(multiply)으로 합성됩니다")
	print("  albedo_color * albedo_texture = 최종 색상")
	print("  흰색(WHITE) + 텍스처 = 텍스처 원래 색상")
	print("  빨간색 + 텍스처 = 텍스처에 빨간 틴트")
	print()

	# -----------------------------------------------------------------
	# 3) Metallic과 Roughness (PBR 핵심)
	# -----------------------------------------------------------------
	print("--- 3. Metallic & Roughness ---")

	# Metallic: 금속성 (0.0 = 비금속, 1.0 = 완전 금속)
	# Roughness: 거칠기 (0.0 = 매끈/거울, 1.0 = 완전 거침)

	# 반짝이는 금속
	var mat_metal := StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.9, 0.85, 0.7)  # 골드
	mat_metal.metallic = 1.0
	mat_metal.roughness = 0.2
	print("  금속 재질:")
	print("    metallic = %.1f" % mat_metal.metallic)
	print("    roughness = %.1f" % mat_metal.roughness)

	# 무광 플라스틱
	var mat_plastic := StandardMaterial3D.new()
	mat_plastic.albedo_color = Color(0.8, 0.2, 0.2)
	mat_plastic.metallic = 0.0
	mat_plastic.roughness = 0.8
	print("  플라스틱 재질:")
	print("    metallic = %.1f" % mat_plastic.metallic)
	print("    roughness = %.1f" % mat_plastic.roughness)

	# 거울/유리
	var mat_mirror := StandardMaterial3D.new()
	mat_mirror.metallic = 1.0
	mat_mirror.roughness = 0.0
	print("  거울 재질:")
	print("    metallic = %.1f" % mat_mirror.metallic)
	print("    roughness = %.1f" % mat_mirror.roughness)

	print()
	print("  Metallic/Roughness 조합 가이드:")
	print("    금속 + 매끈 (1.0, 0.1) = 크롬, 거울")
	print("    금속 + 거침 (1.0, 0.7) = 녹슨 철, 무광 금속")
	print("    비금속 + 매끈 (0.0, 0.1) = 유리, 광택 플라스틱")
	print("    비금속 + 거침 (0.0, 0.9) = 나무, 돌, 고무")
	print()

	# Metallic 텍스처 맵
	print("  텍스처 맵 사용:")
	print("    material.metallic_texture = load(\"res://metal_map.png\")")
	print("    material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED")
	print("    # 흔히 ORM 텍스처 사용: R=Occlusion, G=Roughness, B=Metallic")
	print()

	# -----------------------------------------------------------------
	# 4) Normal Map (법선 맵)
	# -----------------------------------------------------------------
	print("--- 4. Normal Map ---")

	print("  Normal Map은 실제 지오메트리 추가 없이 표면 디테일을 표현합니다")
	print("  보라색/파란색 이미지로, 각 픽셀이 표면의 방향을 나타냅니다")
	print()

	var mat_normal := StandardMaterial3D.new()
	mat_normal.normal_enabled = true
	# mat_normal.normal_texture = load("res://textures/brick_normal.png")
	mat_normal.normal_scale = 1.0  # 법선 맵 강도 (0.0 ~ 2.0+)
	print("  normal_enabled = true")
	print("  normal_scale = %.1f  (강도 조절)" % mat_normal.normal_scale)
	print()

	print("  Normal Map 설정 코드:")
	print("    material.normal_enabled = true")
	print("    material.normal_texture = load(\"res://normal.png\")")
	print("    material.normal_scale = 1.5  # 강도 높이기")
	print()

	print("  주의사항:")
	print("    - Normal Map은 반드시 OpenGL/DirectX 형식 확인")
	print("    - Godot은 OpenGL 형식 사용 (Y+ = 위)")
	print("    - 텍스처 임포트 시 'Normal Map' 체크 필수")
	print("    - normal_scale을 높이면 디테일 강해짐 (과도하면 부자연스러움)")
	print()

	# -----------------------------------------------------------------
	# 5) Emission (자체 발광)
	# -----------------------------------------------------------------
	print("--- 5. Emission (자체 발광) ---")

	# Emission은 재질 자체가 빛을 내는 효과입니다
	var mat_emissive := StandardMaterial3D.new()
	mat_emissive.emission_enabled = true
	mat_emissive.emission = Color(0.0, 1.0, 0.5)    # 발광 색상
	mat_emissive.emission_energy_multiplier = 2.0    # 발광 강도
	print("  emission_enabled = true")
	print("  emission = Color(0.0, 1.0, 0.5)  # 녹색 발광")
	print("  emission_energy_multiplier = %.1f" % mat_emissive.emission_energy_multiplier)
	print()

	# Emission 텍스처
	print("  Emission 텍스처 사용:")
	print("    material.emission_texture = load(\"res://emission_map.png\")")
	print("    # 텍스처의 밝은 부분만 발광합니다")
	print()

	# Emission 연산자 설정
	print("  emission_operator 옵션:")
	print("    EMISSION_OP_ADD (기본) - 발광이 기존 색상에 더해짐")
	print("    EMISSION_OP_MULTIPLY - 발광이 기존 색상과 곱해짐")
	print()

	print("  활용 예시:")
	print("    - 네온 사인, LED 조명")
	print("    - 마법 무기의 빛나는 룬")
	print("    - 용암, 불꽃 효과")
	print("    - UI 하이라이트 오브젝트")
	print()

	# Emission으로 Bloom 효과 (WorldEnvironment 필요)
	print("  Bloom과 함께 사용:")
	print("    - WorldEnvironment에서 Glow 활성화")
	print("    - emission_energy_multiplier > 1.0 설정")
	print("    - Glow threshold 이상의 밝기가 번짐 효과 생성")
	print()

	# -----------------------------------------------------------------
	# 6) 투명도 설정
	# -----------------------------------------------------------------
	print("--- 6. 투명도 (Transparency) ---")

	# 반투명 재질
	var mat_transparent := StandardMaterial3D.new()
	mat_transparent.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_transparent.albedo_color = Color(0.2, 0.5, 1.0, 0.5)  # alpha = 0.5
	print("  transparency = TRANSPARENCY_ALPHA")
	print("  albedo_color alpha = 0.5 (50%% 투명)")
	print()

	print("  투명도 모드:")
	print("    TRANSPARENCY_DISABLED - 불투명 (기본, 가장 빠름)")
	print("    TRANSPARENCY_ALPHA - 알파 블렌딩 (반투명)")
	print("    TRANSPARENCY_ALPHA_SCISSOR - 알파 커트아웃 (나뭇잎 등)")
	print("    TRANSPARENCY_ALPHA_HASH - 디더링 방식 투명도")
	print("    TRANSPARENCY_ALPHA_DEPTH_PRE_PASS - 깊이 우선 패스")
	print()

	# 알파 커트아웃 (나뭇잎, 울타리 등에 적합)
	var mat_cutout := StandardMaterial3D.new()
	mat_cutout.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat_cutout.alpha_scissor_threshold = 0.5  # 0.5 미만 알파는 투명
	print("  Alpha Scissor (커트아웃):")
	print("    alpha_scissor_threshold = 0.5")
	print("    알파 0.5 미만 = 완전 투명, 이상 = 완전 불투명")
	print("    정렬 문제 없이 빠름 (나뭇잎, 풀에 적합)")
	print()

	# -----------------------------------------------------------------
	# 7) 기타 유용한 속성들
	# -----------------------------------------------------------------
	print("--- 7. 기타 속성들 ---")

	# 양면 렌더링
	var mat_twoside := StandardMaterial3D.new()
	mat_twoside.cull_mode = BaseMaterial3D.CULL_DISABLED  # 양면
	print("  cull_mode 옵션:")
	print("    CULL_BACK (기본) - 뒷면 숨김 (일반 메시)")
	print("    CULL_FRONT - 앞면 숨김 (특수 효과)")
	print("    CULL_DISABLED - 양면 렌더링 (나뭇잎, 천)")
	print()

	# UV 스케일링
	var mat_uv := StandardMaterial3D.new()
	mat_uv.uv1_scale = Vector3(2.0, 2.0, 1.0)  # 텍스처 2배 타일링
	mat_uv.uv1_offset = Vector3(0.5, 0.0, 0.0)  # UV 오프셋
	print("  UV 스케일링:")
	print("    uv1_scale = Vector3(2, 2, 1)  # 2x2 타일링")
	print("    uv1_offset = Vector3(0.5, 0, 0)  # 가로 50%% 이동")
	print()

	# AO (Ambient Occlusion)
	print("  Ambient Occlusion (AO):")
	print("    material.ao_enabled = true")
	print("    material.ao_texture = load(\"res://ao_map.png\")")
	print("    material.ao_light_affect = 0.5  # AO가 직접광에 영향")
	print()

	# Detail 텍스처 (두 번째 레이어)
	print("  Detail 텍스처 (이중 레이어):")
	print("    material.detail_enabled = true")
	print("    material.detail_albedo = load(\"res://detail.png\")")
	print("    material.detail_uv_layer = BaseMaterial3D.DETAIL_UV_2")
	print("    # 가까이에서 볼 때 더 세밀한 디테일 표현")
	print()

	# -----------------------------------------------------------------
	# 8) 재질 예제 모음 - 다양한 재질 만들기
	# -----------------------------------------------------------------
	print("--- 8. 실용 재질 레시피 ---")

	# 나무 재질
	_create_demo_material("나무 바닥", {
		"albedo": Color(0.55, 0.35, 0.17),
		"metallic": 0.0,
		"roughness": 0.7,
	})

	# 유리 재질
	_create_demo_material("유리", {
		"albedo": Color(0.8, 0.9, 1.0, 0.3),
		"metallic": 0.1,
		"roughness": 0.0,
		"transparent": true,
	})

	# 네온 발광
	_create_demo_material("네온 조명", {
		"albedo": Color(0.0, 0.0, 0.0),
		"metallic": 0.0,
		"roughness": 0.5,
		"emission": Color(1.0, 0.0, 0.5),
		"emission_energy": 3.0,
	})

	# 크롬
	_create_demo_material("크롬 금속", {
		"albedo": Color(0.9, 0.9, 0.92),
		"metallic": 1.0,
		"roughness": 0.05,
	})

	print()

	# -----------------------------------------------------------------
	# 9) 동적 재질 변경
	# -----------------------------------------------------------------
	print("--- 9. 동적 재질 변경 ---")

	print("  런타임에 재질 속성을 변경할 수 있습니다:")
	print()
	print("  # 피격 시 빨간색 플래시")
	print("  func take_damage():")
	print("      var mat = mesh.material_override as StandardMaterial3D")
	print("      mat.albedo_color = Color.RED")
	print("      await get_tree().create_timer(0.1).timeout")
	print("      mat.albedo_color = original_color")
	print()

	print("  주의: material_override는 공유될 수 있습니다!")
	print("  독립적 변경이 필요하면 duplicate()를 사용하세요:")
	print("    mesh.material_override = material.duplicate()")
	print()

	# 실제 동적 변경 데모
	var demo_mesh := MeshInstance3D.new()
	demo_mesh.mesh = BoxMesh.new()
	var demo_mat := StandardMaterial3D.new()
	demo_mat.albedo_color = Color.WHITE
	demo_mesh.material_override = demo_mat
	add_child(demo_mesh)
	demo_mesh.position = Vector3(3, 0, 0)

	# 색상 변경 시연
	demo_mat.albedo_color = Color.RED
	print("  데모: 재질 색상을 WHITE -> RED로 변경")
	print("  현재 albedo_color: ", demo_mat.albedo_color)
	print()

	print("=== 01-standard-material.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 데모용 재질 생성 및 속성 출력
func _create_demo_material(mat_name: String, props: Dictionary) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()

	if props.has("albedo"):
		mat.albedo_color = props["albedo"]
	if props.has("metallic"):
		mat.metallic = props["metallic"]
	if props.has("roughness"):
		mat.roughness = props["roughness"]
	if props.has("transparent"):
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if props.has("emission"):
		mat.emission_enabled = true
		mat.emission = props["emission"]
	if props.has("emission_energy"):
		mat.emission_energy_multiplier = props["emission_energy"]

	print("  [%s] albedo=%s, metallic=%.1f, roughness=%.1f" % [
		mat_name, mat.albedo_color, mat.metallic, mat.roughness
	])
	if mat.emission_enabled:
		print("    emission=%s, energy=%.1f" % [mat.emission, mat.emission_energy_multiplier])

	return mat
