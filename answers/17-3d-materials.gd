# 챕터 17: 3D 머티리얼과 셰이더 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - StandardMaterial3D 기본 속성 (Albedo, Normal, Roughness 등)
# - PBR (물리 기반 렌더링) 파라미터 이해
# - Emission (자체 발광) 머티리얼
# - CSG (Constructive Solid Geometry) 프리미티브
# - MultiMesh로 대량 오브젝트 인스턴싱
# - 셰이더 코드 기초 (Godot Shader Language)

extends Node3D


func _ready():
	print("=== 챕터 17: 3D 머티리얼과 셰이더 ===\n")

	# 연습 1: StandardMaterial3D 기본
	_exercise_1_standard_material()

	# 연습 2: PBR 파라미터
	_exercise_2_pbr_parameters()

	# 연습 3: Emission 머티리얼
	_exercise_3_emission()

	# 연습 4: CSG 프리미티브
	_exercise_4_csg()

	# 연습 5: MultiMesh 인스턴싱
	_exercise_5_multimesh()

	# 연습 6: 셰이더 기초
	_exercise_6_shader_basics()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: StandardMaterial3D 기본 속성 (Albedo, Metallic, Roughness) 설정 완료")
	print("결과 2: PBR 파라미터 비교 (금속, 플라스틱, 유리, 나무, 돌) 완료")
	print("결과 3: Emission 자체 발광 머티리얼 생성 완료")
	print("결과 4: CSG 프리미티브 (합집합, 교집합, 차집합) 구현 완료")
	print("결과 5: MultiMesh 대량 인스턴싱 (1000개) 구현 완료")
	print("결과 6: Godot 셰이더 언어 기초 코드 작성 완료")


# ==============================================================================
# 연습 1: StandardMaterial3D - 3D 오브젝트에 기본 머티리얼을 적용하고
#          주요 속성을 설정하세요.
# ==============================================================================
func _exercise_1_standard_material():
	# 풀이: StandardMaterial3D는 Godot의 기본 PBR 머티리얼입니다.
	#       albedo_color: 기본 색상 (디퓨즈)
	#       metallic: 금속성 (0=비금속, 1=금속)
	#       roughness: 거칠기 (0=매끈, 1=거침)
	#       albedo_texture: 텍스처 맵 (이미지 기반 색상)
	#       material_override: 메시 전체에 머티리얼 적용

	print("연습 1: StandardMaterial3D 기본")

	# 기본 머티리얼 생성
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2)  # 빨간색
	mat.metallic = 0.0                         # 비금속
	mat.roughness = 0.7                        # 약간 거친 표면

	# 메시에 적용
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "RedSphere"
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	mesh_inst.mesh = sphere
	mesh_inst.material_override = mat
	mesh_inst.position = Vector3(0, 0.5, 0)
	add_child(mesh_inst)

	print("  기본 머티리얼 적용:")
	print("    albedo_color: %s (빨간색)" % mat.albedo_color)
	print("    metallic: %.1f (비금속)" % mat.metallic)
	print("    roughness: %.1f (약간 거침)" % mat.roughness)
	print()

	# 주요 속성 설명
	print("  StandardMaterial3D 주요 속성:")
	print("    albedo_color: 기본 색상 (빛 흡수/반사)")
	print("    albedo_texture: 텍스처 이미지")
	print("    metallic: 금속성 (0~1, 반사 특성 변경)")
	print("    metallic_specular: 비금속 반사 강도 (기본 0.5)")
	print("    roughness: 거칠기 (0=거울, 1=무광)")
	print("    normal_enabled: 노멀 맵 사용 여부")
	print("    normal_texture: 범프/노멀 맵")
	print("    normal_scale: 노멀 맵 강도")
	print()

	# 머티리얼 적용 방법
	print("  머티리얼 적용 방법:")
	print("    1. material_override: 메시 전체에 적용 (우선순위 높음)")
	print("    2. mesh.surface_set_material(idx, mat): 서피스별 적용")
	print("    3. 메시 리소스 자체의 material: 기본 머티리얼")
	print()

	# 투명도 설정
	var transparent_mat := StandardMaterial3D.new()
	transparent_mat.albedo_color = Color(0.2, 0.5, 0.8, 0.5)  # 반투명
	transparent_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	print("  투명도 설정:")
	print("    transparency = TRANSPARENCY_ALPHA")
	print("    albedo_color.a = 0.5 (50%% 투명)")
	print("    TRANSPARENCY_DISABLED: 불투명 (기본)")
	print("    TRANSPARENCY_ALPHA: 알파 블렌딩")
	print("    TRANSPARENCY_ALPHA_SCISSOR: 알파 컷오프 (잎사귀)")
	print("    TRANSPARENCY_ALPHA_HASH: 디더링 투명")

	print("연습 1 완료: StandardMaterial3D 기본\n")


# ==============================================================================
# 연습 2: PBR 파라미터 - 다양한 재질(금속, 플라스틱, 유리 등)을
#          PBR 파라미터로 표현하세요.
# ==============================================================================
func _exercise_2_pbr_parameters():
	# 풀이: PBR(Physically Based Rendering)은 물리 법칙에 기반한 렌더링입니다.
	#       metallic과 roughness 두 가지 파라미터로 대부분의 재질을 표현합니다.
	#       금속: metallic=1.0, 색상이 반사색이 됨
	#       비금속: metallic=0.0, 색상이 디퓨즈색이 됨
	#       roughness가 낮으면 반사가 선명하고, 높으면 흐립니다.

	print("연습 2: PBR 파라미터")

	# 재질 프리셋
	var material_presets := {
		"금 (Gold)": {
			"color": Color(1.0, 0.84, 0.0),
			"metallic": 1.0, "roughness": 0.2
		},
		"은 (Silver)": {
			"color": Color(0.75, 0.75, 0.75),
			"metallic": 1.0, "roughness": 0.15
		},
		"구리 (Copper)": {
			"color": Color(0.72, 0.45, 0.2),
			"metallic": 1.0, "roughness": 0.35
		},
		"플라스틱 (Plastic)": {
			"color": Color(0.8, 0.1, 0.1),
			"metallic": 0.0, "roughness": 0.4
		},
		"고무 (Rubber)": {
			"color": Color(0.15, 0.15, 0.15),
			"metallic": 0.0, "roughness": 0.95
		},
		"유리 (Glass)": {
			"color": Color(0.9, 0.95, 1.0),
			"metallic": 0.0, "roughness": 0.0
		},
		"나무 (Wood)": {
			"color": Color(0.55, 0.35, 0.15),
			"metallic": 0.0, "roughness": 0.75
		},
		"돌 (Stone)": {
			"color": Color(0.5, 0.5, 0.45),
			"metallic": 0.0, "roughness": 0.85
		},
	}

	# 각 재질로 구 생성
	var x_offset := -6.0
	for preset_name in material_presets:
		var data: Dictionary = material_presets[preset_name]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = data["color"]
		mat.metallic = data["metallic"]
		mat.roughness = data["roughness"]

		# 유리는 투명하게
		if preset_name == "유리 (Glass)":
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.3

		var mesh_inst := MeshInstance3D.new()
		mesh_inst.name = preset_name.split(" ")[0]
		var sphere := SphereMesh.new()
		sphere.radius = 0.4
		sphere.height = 0.8
		mesh_inst.mesh = sphere
		mesh_inst.material_override = mat
		mesh_inst.position = Vector3(x_offset, 0.4, -2)
		add_child(mesh_inst)
		x_offset += 1.8

	print("  PBR 재질 프리셋:")
	print("    +-----------+----------+-----------+-------+")
	print("    | 재질      | Metallic | Roughness | 색상  |")
	print("    +-----------+----------+-----------+-------+")
	for preset_name in material_presets:
		var data: Dictionary = material_presets[preset_name]
		print("    | %-9s | %.1f      | %.2f      | %s |" % [
			preset_name.split("(")[0].strip_edges(),
			data["metallic"], data["roughness"],
			data["color"]
		])
	print("    +-----------+----------+-----------+-------+")
	print()

	# PBR 텍스처 맵 종류
	print("  PBR 텍스처 맵 종류:")
	print("    Albedo Map: 기본 색상 텍스처")
	print("    Normal Map: 표면 디테일 (범프)")
	print("    Roughness Map: 부분별 거칠기")
	print("    Metallic Map: 부분별 금속성")
	print("    AO Map: 앰비언트 오클루전 (자체 그림자)")
	print("    Height/Displacement Map: 실제 지오메트리 변형")
	print("    Emission Map: 자체 발광 영역")

	print("연습 2 완료: PBR 파라미터\n")


# ==============================================================================
# 연습 3: Emission - 자체 발광하는 머티리얼을 만드세요.
#          Glow 후처리와 결합하여 빛나는 효과를 구현하세요.
# ==============================================================================
func _exercise_3_emission():
	# 풀이: emission_enabled = true로 자체 발광을 활성화합니다.
	#       emission: 발광 색상
	#       emission_energy_multiplier: 발광 강도 (1.0 이상이면 HDR 범위)
	#       Environment의 Glow와 결합하면 실제로 빛나는 듯한 블룸 효과가 생깁니다.
	#       emission_energy가 높을수록 Glow에 더 많이 기여합니다.

	print("연습 3: Emission (자체 발광)")

	# 발광 머티리얼 생성
	var emit_mat := StandardMaterial3D.new()
	emit_mat.albedo_color = Color(0.1, 0.1, 0.1)    # 기본색은 어둡게
	emit_mat.emission_enabled = true
	emit_mat.emission = Color(0.0, 1.0, 0.5)        # 초록색 발광
	emit_mat.emission_energy_multiplier = 3.0        # 강한 발광

	var glow_sphere := MeshInstance3D.new()
	glow_sphere.name = "GlowingSphere"
	var sphere := SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	glow_sphere.mesh = sphere
	glow_sphere.material_override = emit_mat
	glow_sphere.position = Vector3(2, 1, 0)
	add_child(glow_sphere)

	print("  발광 머티리얼:")
	print("    emission_enabled: %s" % emit_mat.emission_enabled)
	print("    emission: %s (초록색)" % emit_mat.emission)
	print("    emission_energy_multiplier: %.1f" % emit_mat.emission_energy_multiplier)
	print("    albedo_color: %s (어두운 기본색)" % emit_mat.albedo_color)
	print()

	# 다양한 발광 색상
	var emission_presets := [
		{"name": "네온 블루", "color": Color(0.0, 0.5, 1.0), "energy": 4.0},
		{"name": "레드 알람", "color": Color(1.0, 0.0, 0.0), "energy": 5.0},
		{"name": "골드 글로우", "color": Color(1.0, 0.8, 0.0), "energy": 2.0},
		{"name": "마법 보라", "color": Color(0.7, 0.0, 1.0), "energy": 3.5},
	]

	var x := -3.0
	for preset in emission_presets:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.05, 0.05, 0.05)
		mat.emission_enabled = true
		mat.emission = preset["color"]
		mat.emission_energy_multiplier = preset["energy"]

		var inst := MeshInstance3D.new()
		inst.name = preset["name"]
		var s := SphereMesh.new()
		s.radius = 0.25
		s.height = 0.5
		inst.mesh = s
		inst.material_override = mat
		inst.position = Vector3(x, 1, -3)
		add_child(inst)
		x += 2.0

	print("  발광 프리셋:")
	for preset in emission_presets:
		print("    %s: color=%s, energy=%.1f" % [
			preset["name"], preset["color"], preset["energy"]
		])
	print()

	# Glow와의 결합
	print("  Glow 결합 (Environment 설정):")
	print("    glow_enabled = true")
	print("    glow_hdr_threshold = 1.0")
	print("    -> emission_energy > 1.0인 머티리얼이 블룸 효과 발생")
	print("    -> energy가 높을수록 더 강한 글로우")
	print()

	# 발광 + 조명 방출
	print("  발광 오브젝트 + OmniLight3D:")
	print("    Emission은 시각적 효과만 (주변을 비추지 않음)")
	print("    실제 조명이 필요하면 OmniLight3D를 자식으로 추가:")
	print("    ```gdscript")
	print("    var light = OmniLight3D.new()")
	print("    light.light_color = emission_color")
	print("    light.light_energy = 2.0")
	print("    light.omni_range = 5.0")
	print("    glow_sphere.add_child(light)")
	print("    ```")

	print("연습 3 완료: Emission 머티리얼\n")


# ==============================================================================
# 연습 4: CSG - Constructive Solid Geometry로 프리미티브를 조합하여
#          복합 3D 형태를 만드세요.
# ==============================================================================
func _exercise_4_csg():
	# 풀이: CSG(Constructive Solid Geometry)는 간단한 도형을 조합하여
	#       복잡한 형태를 만드는 기법입니다. 프로토타이핑에 유용합니다.
	#       연산 모드:
	#       OPERATION_UNION: 합집합 (두 도형 합치기)
	#       OPERATION_INTERSECTION: 교집합 (겹치는 부분만)
	#       OPERATION_SUBTRACTION: 차집합 (빼기)
	#       부모 CSG에 자식 CSG를 추가하면 연산이 적용됩니다.

	print("연습 4: CSG 프리미티브")

	# CSG 합집합 (Union) - 두 도형 합치기
	var csg_union := CSGCombiner3D.new()
	csg_union.name = "CSG_Union"
	csg_union.position = Vector3(-4, 1, 3)
	csg_union.use_collision = true  # 충돌 형태 자동 생성

	var box_a := CSGBox3D.new()
	box_a.size = Vector3(1, 1, 1)
	csg_union.add_child(box_a)

	var sphere_a := CSGSphere3D.new()
	sphere_a.radius = 0.6
	sphere_a.position = Vector3(0.5, 0.5, 0)
	sphere_a.operation = CSGShape3D.OPERATION_UNION
	csg_union.add_child(sphere_a)

	add_child(csg_union)

	print("  CSG 합집합 (Union):")
	print("    Box(1,1,1) + Sphere(r=0.6)")
	print("    use_collision: %s (충돌 자동 생성)" % csg_union.use_collision)
	print()

	# CSG 차집합 (Subtraction) - 구멍 뚫기
	# 풀이: OPERATION_SUBTRACTION은 부모 CSG에서 자식 CSG를 빼냅니다.
	#       창문, 문, 터널 등을 만들 때 유용합니다.
	var csg_sub := CSGBox3D.new()
	csg_sub.name = "CSG_Subtraction"
	csg_sub.size = Vector3(2, 2, 2)
	csg_sub.position = Vector3(0, 1, 3)

	var mat_sub := StandardMaterial3D.new()
	mat_sub.albedo_color = Color(0.6, 0.4, 0.2)
	csg_sub.material = mat_sub

	var hole := CSGSphere3D.new()
	hole.radius = 0.8
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION  # 빼기
	csg_sub.add_child(hole)

	# 수직 원통 구멍
	var tunnel := CSGCylinder3D.new()
	tunnel.radius = 0.4
	tunnel.height = 3.0
	tunnel.rotation.x = deg_to_rad(90)  # 수평으로 눕힘
	tunnel.operation = CSGShape3D.OPERATION_SUBTRACTION
	csg_sub.add_child(tunnel)

	add_child(csg_sub)

	print("  CSG 차집합 (Subtraction):")
	print("    Box(2,2,2) - Sphere(r=0.8) - Cylinder(r=0.4)")
	print("    -> 상자에 구멍 2개 뚫기")
	print()

	# CSG 교집합 (Intersection)
	var csg_inter := CSGBox3D.new()
	csg_inter.name = "CSG_Intersection"
	csg_inter.size = Vector3(1.5, 1.5, 1.5)
	csg_inter.position = Vector3(4, 1, 3)

	var sphere_b := CSGSphere3D.new()
	sphere_b.radius = 1.0
	sphere_b.operation = CSGShape3D.OPERATION_INTERSECTION
	csg_inter.add_child(sphere_b)

	add_child(csg_inter)

	print("  CSG 교집합 (Intersection):")
	print("    Box(1.5) intersect Sphere(r=1.0)")
	print("    -> 둥근 모서리의 큐브")
	print()

	# CSG 타입 목록
	print("  CSG 노드 타입:")
	print("    CSGBox3D: 직육면체")
	print("    CSGSphere3D: 구")
	print("    CSGCylinder3D: 원통/원뿔 (cone=true)")
	print("    CSGTorus3D: 도넛 (토러스)")
	print("    CSGPolygon3D: 2D 폴리곤을 3D로 돌출")
	print("    CSGMesh3D: 외부 메시 사용")
	print("    CSGCombiner3D: 자식 CSG 그룹화")
	print()

	# 주의사항
	print("  CSG 주의사항:")
	print("    - 프로토타이핑/레벨 디자인용 (최종 에셋은 메시 사용)")
	print("    - 복잡한 CSG는 성능에 영향")
	print("    - use_collision=true로 자동 충돌 형태 생성 가능")
	print("    - CSG 결과를 MeshInstance3D로 변환 (에디터에서 Bake)")

	print("연습 4 완료: CSG 프리미티브\n")


# ==============================================================================
# 연습 5: MultiMesh - MultiMeshInstance3D로 대량의 동일 오브젝트를
#          효율적으로 렌더링하세요.
# ==============================================================================
func _exercise_5_multimesh():
	# 풀이: MultiMesh는 동일한 메시를 GPU 인스턴싱으로 대량 렌더링합니다.
	#       1000개의 개별 MeshInstance3D 대신 1개의 MultiMesh로 처리하면
	#       드로우 콜이 1회로 줄어 성능이 대폭 향상됩니다.
	#       각 인스턴스의 위치/회전/스케일을 Transform3D로 설정합니다.
	#       인스턴스별 색상(use_colors)이나 커스텀 데이터도 설정 가능합니다.

	print("연습 5: MultiMesh 인스턴싱")

	# MultiMesh 리소스 생성
	var multi_mesh := MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.use_colors = true             # 인스턴스별 색상 사용
	multi_mesh.instance_count = 1000         # 인스턴스 수

	# 메시 설정 (작은 큐브)
	var box := BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	multi_mesh.mesh = box

	# 인스턴스 배치 (랜덤 위치 + 색상)
	# 풀이: set_instance_transform()로 각 인스턴스의 위치/회전/스케일을,
	#       set_instance_color()로 개별 색상을 설정합니다.
	for i in range(multi_mesh.instance_count):
		var transform := Transform3D()
		# 랜덤 위치 (20x20 영역)
		transform.origin = Vector3(
			randf_range(-10, 10),
			randf_range(0, 5),
			randf_range(-10, 10)
		)
		# 랜덤 회전
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		transform = transform.rotated(Vector3.RIGHT, randf() * TAU)

		# 랜덤 스케일
		var s := randf_range(0.5, 1.5)
		transform = transform.scaled(Vector3(s, s, s))

		multi_mesh.set_instance_transform(i, transform)

		# 랜덤 색상
		var color := Color(randf(), randf(), randf())
		multi_mesh.set_instance_color(i, color)

	# MultiMeshInstance3D 노드에 할당
	var mm_instance := MultiMeshInstance3D.new()
	mm_instance.name = "GrassField"
	mm_instance.multimesh = multi_mesh

	# 머티리얼 (인스턴스 색상 사용)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true  # 인스턴스 색상을 albedo로 사용
	mm_instance.material_override = mat

	add_child(mm_instance)

	print("  MultiMesh 생성:")
	print("    instance_count: %d" % multi_mesh.instance_count)
	print("    mesh: BoxMesh (0.3 x 0.3 x 0.3)")
	print("    use_colors: %s" % multi_mesh.use_colors)
	print("    transform_format: TRANSFORM_3D")
	print()

	# 성능 비교
	print("  성능 비교 (1000개 큐브):")
	print("    개별 MeshInstance3D: ~1000 드로우 콜")
	print("    MultiMesh:          ~1 드로우 콜")
	print("    -> 약 1000배 드로우 콜 감소!")
	print()

	# 동적 업데이트
	# 풀이: visible_instance_count를 변경하면 표시할 인스턴스 수를 동적으로 조절합니다.
	#       -1이면 모든 인스턴스 표시, 양수면 해당 수만큼만 표시합니다.
	multi_mesh.visible_instance_count = 500  # 500개만 표시
	print("  visible_instance_count: %d (1000 중 500만 표시)" % multi_mesh.visible_instance_count)
	multi_mesh.visible_instance_count = -1  # 다시 전부 표시
	print("  visible_instance_count: -1 (전부 표시)")
	print()

	# MultiMesh 사용 사례
	print("  MultiMesh 사용 사례:")
	print("    - 잔디/풀/꽃 (수만 개)")
	print("    - 나무/바위 분포 (수천 개)")
	print("    - 총알/파편 (고속 생성)")
	print("    - 군중/적 무리")
	print("    - 별/파티클 대체")
	print()

	# 인스턴스 데이터 설정 방법
	print("  인스턴스 데이터 설정:")
	print("    set_instance_transform(i, transform3d)")
	print("    set_instance_color(i, color)")
	print("    set_instance_custom_data(i, color)  # 셰이더에 전달")
	print("    -> custom_data는 Color(r,g,b,a)로 4개의 float를 전달")

	print("연습 5 완료: MultiMesh 인스턴싱\n")


# ==============================================================================
# 연습 6: 셰이더 기초 - Godot 셰이더 언어로 기본 셰이더를 작성하세요.
# ==============================================================================
func _exercise_6_shader_basics():
	# 풀이: Godot 셰이더 언어는 GLSL과 유사한 자체 셰이딩 언어입니다.
	#       shader_type spatial; 로 3D 셰이더를 선언합니다.
	#       vertex(): 정점 위치/속성 변경
	#       fragment(): 픽셀 색상/속성 결정
	#       ShaderMaterial에 Shader 리소스를 할당하여 사용합니다.

	print("연습 6: 셰이더 기초")

	# 기본 색상 셰이더
	var color_shader := Shader.new()
	color_shader.code = """
shader_type spatial;

// uniform: GDScript에서 설정 가능한 파라미터
uniform vec4 base_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    ALBEDO = base_color.rgb;
    ROUGHNESS = roughness_value;
    METALLIC = 0.0;
}
"""

	var color_mat := ShaderMaterial.new()
	color_mat.shader = color_shader
	color_mat.set_shader_parameter("base_color", Color(1.0, 0.3, 0.0))
	color_mat.set_shader_parameter("roughness_value", 0.3)

	var shader_sphere := MeshInstance3D.new()
	shader_sphere.name = "ShaderSphere"
	var s := SphereMesh.new()
	s.radius = 0.5
	s.height = 1.0
	shader_sphere.mesh = s
	shader_sphere.material_override = color_mat
	shader_sphere.position = Vector3(-2, 0.5, -5)
	add_child(shader_sphere)

	print("  기본 색상 셰이더:")
	print("    shader_type spatial;  // 3D 셰이더")
	print("    uniform vec4 base_color;")
	print("    ALBEDO = base_color.rgb;")
	print()

	# 움직이는 정점 셰이더 (물결)
	var wave_shader := Shader.new()
	wave_shader.code = """
shader_type spatial;

uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;
uniform float wave_height : hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0;
uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.8, 0.8);

void vertex() {
    // 정점의 Y좌표를 sin파로 변형 (물결 효과)
    float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) *
                 cos(VERTEX.z * wave_frequency + TIME * wave_speed * 0.7);
    VERTEX.y += wave * wave_height;

    // 법선 재계산 (조명이 올바르게 적용되도록)
    NORMAL = normalize(vec3(
        -cos(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_height * wave_frequency,
        1.0,
        sin(VERTEX.z * wave_frequency + TIME * wave_speed * 0.7) * wave_height * wave_frequency
    ));
}

void fragment() {
    ALBEDO = water_color.rgb;
    ALPHA = water_color.a;
    ROUGHNESS = 0.05;
    METALLIC = 0.3;
    SPECULAR = 0.8;
}
"""

	var wave_mat := ShaderMaterial.new()
	wave_mat.shader = wave_shader
	wave_mat.set_shader_parameter("wave_speed", 2.0)
	wave_mat.set_shader_parameter("wave_height", 0.2)
	wave_mat.set_shader_parameter("wave_frequency", 3.0)

	var water_plane := MeshInstance3D.new()
	water_plane.name = "WaterSurface"
	var plane := PlaneMesh.new()
	plane.size = Vector2(10, 10)
	plane.subdivide_width = 50    # 물결을 위한 충분한 정점
	plane.subdivide_depth = 50
	water_plane.mesh = plane
	water_plane.material_override = wave_mat
	water_plane.position = Vector3(0, 0, -8)
	add_child(water_plane)

	print("  물결 셰이더 (vertex shader):")
	print("    vertex(): VERTEX.y = sin(x + TIME) * height")
	print("    wave_speed: 2.0, wave_height: 0.2")
	print("    subdivide: 50 x 50 (정점 밀도)")
	print()

	# 셰이더 구조 설명
	print("  Godot 셰이더 구조:")
	print("    shader_type spatial;  // 3D (spatial), 2D (canvas_item), 파티클 (particles)")
	print("")
	print("    // 렌더링 모드")
	print("    render_mode unshaded;        // 조명 무시")
	print("    render_mode blend_add;       // 가산 블렌딩")
	print("    render_mode cull_disabled;   // 양면 렌더링")
	print("")
	print("    // 유니폼 (외부 파라미터)")
	print("    uniform float speed;")
	print("    uniform vec4 color : source_color;")
	print("    uniform sampler2D texture_albedo;")
	print("")
	print("    // 정점 셰이더")
	print("    void vertex() {")
	print("        VERTEX += NORMAL * displacement;")
	print("    }")
	print("")
	print("    // 프래그먼트 셰이더")
	print("    void fragment() {")
	print("        ALBEDO = texture(texture_albedo, UV).rgb;")
	print("        ROUGHNESS = 0.5;")
	print("        METALLIC = 0.0;")
	print("        EMISSION = glow_color * glow_strength;")
	print("    }")
	print()

	# GDScript에서 셰이더 파라미터 제어
	print("  GDScript에서 셰이더 파라미터 제어:")
	print("    mat.set_shader_parameter(\"base_color\", Color.RED)")
	print("    mat.set_shader_parameter(\"wave_speed\", 3.0)")
	print("    var val = mat.get_shader_parameter(\"wave_speed\")")

	print("연습 6 완료: 셰이더 기초\n")
