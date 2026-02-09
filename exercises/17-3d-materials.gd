# 챕터 17: 3D 머티리얼과 셰이더
#
# 이 챕터에서는 다음을 학습합니다:
# - StandardMaterial3D 생성과 기본 속성
# - PBR (물리 기반 렌더링) 속성 설정
# - Emission(발광) 머티리얼
# - CSG (Constructive Solid Geometry) 조합
# - MultiMesh를 이용한 대량 인스턴싱
# - 기초 셰이더 코드 이해

extends Node3D


# ============================================================
# 연습 1: StandardMaterial3D 생성
# ============================================================
# StandardMaterial3D는 Godot 4의 기본 3D 머티리얼입니다.
# PBR 렌더링을 지원하며, 다양한 속성으로 재질을 표현합니다.

func create_standard_material(
	albedo_color: Color,
	material_name: String
) -> Dictionary:
	# TODO: StandardMaterial3D의 기본 설정을 Dictionary로 반환하세요
	#
	# 반환 형식:
	# {
	#   "material_type": "StandardMaterial3D",
	#   "name": material_name,
	#   "albedo_color": albedo_color,
	#   "albedo_texture": null (텍스처 경로, 없으면 null),
	#   "transparency": "disabled" (기본값),
	#   "cull_mode": "back" (뒷면 컬링),
	#   "shading_mode": "per_pixel",
	#   "vertex_color_use_as_albedo": false,
	#   "uv1_scale": Vector3(1, 1, 1),
	#   "uv1_offset": Vector3(0, 0, 0),
	#   "code_example": 코드 문자열
	# }
	#
	# code_example:
	# "var mat = StandardMaterial3D.new()\nmat.albedo_color = Color(...)\nmesh_instance.material_override = mat"
	#
	# TODO: albedo_color의 각 채널(r, g, b, a)을 0~1 범위로 클램프하세요
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 2: PBR 속성 설정
# ============================================================
# PBR(Physical Based Rendering)은 물리적으로 정확한 재질 표현입니다.
# Metallic, Roughness, Normal Map 등으로 사실적인 표면을 만듭니다.

func create_pbr_material(preset: String) -> Dictionary:
	# TODO: PBR 재질 프리셋을 Dictionary로 반환하세요
	# preset: "metal", "wood", "plastic", "glass", "stone", "fabric"
	#
	# 반환 형식:
	# {
	#   "preset": preset,
	#   "material_type": "StandardMaterial3D",
	#   "albedo_color": ...,
	#   "metallic": 0.0 ~ 1.0,
	#   "roughness": 0.0 ~ 1.0,
	#   "specular": 0.0 ~ 1.0,
	#   "normal_scale": 법선 맵 강도,
	#   "ao_enabled": 앰비언트 오클루전 사용 여부,
	#   "clearcoat": 클리어코트 값 (자동차 도장 같은 효과),
	#   "description": 재질 설명
	# }
	#
	# 프리셋별 설정:
	# - "metal":
	#   albedo_color: Color(0.8, 0.8, 0.85)
	#   metallic: 1.0, roughness: 0.2, specular: 0.5
	#   normal_scale: 1.0, ao_enabled: true, clearcoat: 0.0
	#   description: "광택 있는 금속 표면"
	#
	# - "wood":
	#   albedo_color: Color(0.55, 0.35, 0.15)
	#   metallic: 0.0, roughness: 0.7, specular: 0.3
	#   normal_scale: 1.5, ao_enabled: true, clearcoat: 0.0
	#   description: "거친 나무 표면"
	#
	# - "plastic":
	#   albedo_color: Color(0.8, 0.2, 0.2)
	#   metallic: 0.0, roughness: 0.4, specular: 0.5
	#   normal_scale: 0.5, ao_enabled: false, clearcoat: 0.3
	#   description: "매끄러운 플라스틱"
	#
	# - "glass":
	#   albedo_color: Color(0.9, 0.95, 1.0, 0.3)
	#   metallic: 0.0, roughness: 0.0, specular: 1.0
	#   normal_scale: 0.0, ao_enabled: false, clearcoat: 1.0
	#   description: "투명한 유리 (알파 0.3)"
	#
	# - "stone":
	#   albedo_color: Color(0.5, 0.48, 0.45)
	#   metallic: 0.0, roughness: 0.9, specular: 0.2
	#   normal_scale: 2.0, ao_enabled: true, clearcoat: 0.0
	#   description: "거친 돌 표면"
	#
	# - "fabric":
	#   albedo_color: Color(0.4, 0.3, 0.6)
	#   metallic: 0.0, roughness: 0.95, specular: 0.1
	#   normal_scale: 1.0, ao_enabled: true, clearcoat: 0.0
	#   description: "부드러운 직물"
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 3: Emission(발광) 머티리얼
# ============================================================
# Emission은 머티리얼 자체에서 빛을 방출하는 효과입니다.
# 네온 사인, 용암, UI 하이라이트 등에 사용됩니다.

func create_emission_material(
	base_color: Color,
	emission_color: Color,
	emission_energy: float
) -> Dictionary:
	# TODO: Emission 머티리얼 설정을 Dictionary로 반환하세요
	#
	# 반환 형식:
	# {
	#   "material_type": "StandardMaterial3D",
	#   "albedo_color": base_color,
	#   "emission_enabled": true,
	#   "emission_color": emission_color,
	#   "emission_energy": max(emission_energy, 0.0),
	#   "emission_operator": "add",
	#   "emission_on_uv2": false,
	#   "is_bright": emission_energy > 2.0,
	#   "glow_compatible": emission_energy > 1.0 (Glow 후처리에 영향을 주는지),
	#   "total_brightness": emission_color의 밝기 * emission_energy,
	#   "code_example": 코드 문자열
	# }
	#
	# total_brightness 계산:
	# luminance = emission_color.r * 0.299 + emission_color.g * 0.587 + emission_color.b * 0.114
	# total_brightness = luminance * emission_energy
	#
	# code_example:
	# "var mat = StandardMaterial3D.new()\nmat.emission_enabled = true\nmat.emission = Color(...)\nmat.emission_energy_multiplier = ..."
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 4: CSG 조합
# ============================================================
# CSG(Constructive Solid Geometry)는 기본 도형을 조합하여
# 복잡한 형태를 만드는 방법입니다. 프로토타이핑에 유용합니다.

func create_csg_operation(
	shape_a: Dictionary,  # {"type": "box"/"sphere"/"cylinder", "size": Vector3, "position": Vector3}
	shape_b: Dictionary,
	operation: String     # "union", "intersection", "subtraction"
) -> Dictionary:
	# TODO: CSG 조합 설정을 Dictionary로 반환하세요
	#
	# CSG 연산 설명:
	# - "union": 합집합 (두 도형을 합침)
	# - "intersection": 교집합 (겹치는 부분만 남김)
	# - "subtraction": 차집합 (A에서 B를 뺌)
	#
	# 반환 형식:
	# {
	#   "operation": operation,
	#   "operation_description": 연산 설명 문자열,
	#   "shape_a": {
	#     "node_type": CSG 노드 타입명 (예: "CSGBox3D", "CSGSphere3D", "CSGCylinder3D"),
	#     "size": shape_a["size"],
	#     "position": shape_a["position"]
	#   },
	#   "shape_b": {
	#     "node_type": CSG 노드 타입명,
	#     "size": shape_b["size"],
	#     "position": shape_b["position"],
	#     "csg_operation": 연산 상수명
	#       ("union" -> "OPERATION_UNION",
	#        "intersection" -> "OPERATION_INTERSECTION",
	#        "subtraction" -> "OPERATION_SUBTRACTION")
	#   },
	#   "result_description": 결과 설명
	# }
	#
	# CSG 노드 타입 매핑:
	# "box" -> "CSGBox3D"
	# "sphere" -> "CSGSphere3D"
	# "cylinder" -> "CSGCylinder3D"
	# 그 외 -> "CSGMesh3D"
	#
	# result_description 예:
	# "CSGBox3D와 CSGSphere3D의 합집합(union)"
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 5: MultiMesh 설정
# ============================================================
# MultiMeshInstance3D는 동일한 메시를 대량으로 렌더링할 때 사용합니다.
# 풀밭, 나무, 돌 등 반복되는 오브젝트에 효율적입니다.

func create_multimesh_config(
	instance_count: int,
	distribution: String  # "grid", "random", "circle"
) -> Dictionary:
	# TODO: MultiMesh 배치 설정을 Dictionary로 반환하세요
	# instance_count: 인스턴스 수 (최소 1, 최대 10000으로 클램프)
	# distribution: 배치 방식
	#
	# 반환 형식:
	# {
	#   "node_type": "MultiMeshInstance3D",
	#   "instance_count": 클램프된 값,
	#   "distribution": distribution,
	#   "transform_format": "3D",
	#   "use_colors": true,
	#   "use_custom_data": false,
	#   "visible_instance_count": instance_count (초기에는 전체 표시),
	#   "instances": 처음 5개 인스턴스의 위치 배열 (미리보기)
	# }
	#
	# 배치 방식별 인스턴스 위치 계산 (처음 5개만):
	# - "grid":
	#   한 줄에 ceil(sqrt(instance_count))개씩 배치
	#   간격 2.0
	#   instances[i] = Vector3((i % cols) * 2.0, 0, (i / cols) * 2.0)
	#
	# - "random":
	#   범위 내 랜덤 배치 (재현을 위해 시드 기반 계산)
	#   instances[i] = Vector3(
	#     fmod(float(i * 7 + 3), 20.0) - 10.0,
	#     0,
	#     fmod(float(i * 13 + 7), 20.0) - 10.0
	#   )
	#
	# - "circle":
	#   원형으로 배치
	#   angle = (float(i) / instance_count) * TAU
	#   radius = 5.0
	#   instances[i] = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 6: 셰이더 코드 기초
# ============================================================
# Godot의 셰이더 언어는 GLSL과 유사합니다.
# 셰이더로 머티리얼의 한계를 넘어선 시각 효과를 구현합니다.

func get_shader_examples() -> Dictionary:
	# TODO: 기본 셰이더 코드 예제를 Dictionary로 반환하세요
	#
	# 반환 형식:
	# {
	#   "color_shader": {
	#     "description": "단색 셰이더 - 오브젝트를 단색으로 렌더링",
	#     "shader_type": "spatial",
	#     "code": "shader_type spatial;\nuniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 1.0);\nvoid fragment() {\n    ALBEDO = color.rgb;\n}"
	#   },
	#   "dissolve_shader": {
	#     "description": "디졸브 셰이더 - 노이즈 패턴으로 사라지는 효과",
	#     "shader_type": "spatial",
	#     "code": "shader_type spatial;\nuniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;\nuniform sampler2D noise_texture;\nvoid fragment() {\n    float noise = texture(noise_texture, UV).r;\n    if (noise < dissolve_amount) {\n        discard;\n    }\n    ALBEDO = vec3(0.8);\n}"
	#   },
	#   "wave_shader": {
	#     "description": "파도 셰이더 - 버텍스를 물결 모양으로 변형",
	#     "shader_type": "spatial",
	#     "code": "shader_type spatial;\nuniform float wave_speed = 2.0;\nuniform float wave_height = 0.5;\nvoid vertex() {\n    VERTEX.y += sin(VERTEX.x * 2.0 + TIME * wave_speed) * wave_height;\n}"
	#   },
	#   "fresnel_shader": {
	#     "description": "프레넬 셰이더 - 가장자리 발광 효과",
	#     "shader_type": "spatial",
	#     "code": "shader_type spatial;\nuniform vec4 fresnel_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);\nuniform float fresnel_power = 3.0;\nvoid fragment() {\n    float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);\n    ALBEDO = vec3(0.1);\n    EMISSION = fresnel_color.rgb * fresnel;\n}"
	#   },
	#   "shader_types": {
	#     "spatial": "3D 오브젝트용 셰이더",
	#     "canvas_item": "2D 오브젝트 및 UI용 셰이더",
	#     "particles": "파티클 시스템용 셰이더",
	#     "sky": "하늘 배경용 셰이더",
	#     "fog": "볼류메트릭 안개용 셰이더"
	#   }
	# }
	var examples = {}  # 여기를 수정하세요
	return examples


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 17: 3D 머티리얼과 셰이더 ===")
	print("")

	# 테스트 1: StandardMaterial3D
	print("--- 연습 1: StandardMaterial3D ---")
	var mat_red = create_standard_material(Color(1, 0, 0), "RedMaterial")
	var mat_blue = create_standard_material(Color(0.2, 0.4, 0.9), "BlueMaterial")
	print("결과 1-1 (빨간 머티리얼):", mat_red)
	print("결과 1-2 (파란 머티리얼):", mat_blue)
	print("")

	# 테스트 2: PBR 머티리얼
	print("--- 연습 2: PBR 속성 ---")
	var pbr_metal = create_pbr_material("metal")
	var pbr_wood = create_pbr_material("wood")
	var pbr_glass = create_pbr_material("glass")
	print("결과 2-1 (금속):", pbr_metal)
	if pbr_metal.has("metallic"):
		print("  Metallic:", pbr_metal["metallic"], " (기대값: 1.0)")
		print("  Roughness:", pbr_metal["roughness"], " (기대값: 0.2)")
	print("결과 2-2 (나무):", pbr_wood)
	print("결과 2-3 (유리):", pbr_glass)
	if pbr_glass.has("albedo_color"):
		print("  투명도:", pbr_glass["albedo_color"], " (알파: 0.3)")
	print("")

	# 테스트 3: Emission 머티리얼
	print("--- 연습 3: Emission 머티리얼 ---")
	var emit_neon = create_emission_material(
		Color(0.1, 0.1, 0.1), Color(0.0, 1.0, 0.5), 3.0
	)
	var emit_lava = create_emission_material(
		Color(0.3, 0.05, 0.0), Color(1.0, 0.3, 0.0), 5.0
	)
	var emit_dim = create_emission_material(
		Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5), 0.5
	)
	print("결과 3-1 (네온):", emit_neon)
	if emit_neon.has("is_bright"):
		print("  밝은 발광:", emit_neon["is_bright"], " (기대값: true)")
	print("결과 3-2 (용암):", emit_lava)
	print("결과 3-3 (어두운 발광):", emit_dim)
	if emit_dim.has("glow_compatible"):
		print("  Glow 호환:", emit_dim["glow_compatible"], " (기대값: false)")
	print("")

	# 테스트 4: CSG 조합
	print("--- 연습 4: CSG 조합 ---")
	var csg_union = create_csg_operation(
		{"type": "box", "size": Vector3(2, 2, 2), "position": Vector3.ZERO},
		{"type": "sphere", "size": Vector3(1.5, 1.5, 1.5), "position": Vector3(1, 0, 0)},
		"union"
	)
	var csg_sub = create_csg_operation(
		{"type": "box", "size": Vector3(3, 3, 3), "position": Vector3.ZERO},
		{"type": "cylinder", "size": Vector3(1, 4, 1), "position": Vector3.ZERO},
		"subtraction"
	)
	print("결과 4-1 (합집합):", csg_union)
	print("결과 4-2 (차집합):", csg_sub)
	print("")

	# 테스트 5: MultiMesh
	print("--- 연습 5: MultiMesh 설정 ---")
	var mm_grid = create_multimesh_config(100, "grid")
	var mm_random = create_multimesh_config(500, "random")
	var mm_circle = create_multimesh_config(20, "circle")
	print("결과 5-1 (그리드 배치):", mm_grid)
	if mm_grid.has("instances"):
		print("  처음 5개 위치:", mm_grid["instances"])
	print("결과 5-2 (랜덤 배치):", mm_random)
	print("결과 5-3 (원형 배치):", mm_circle)
	print("")

	# 테스트 6: 셰이더 코드
	print("--- 연습 6: 셰이더 코드 ---")
	var shaders = get_shader_examples()
	print("결과 6 (셰이더 예제 수):", shaders.size())
	if shaders.has("color_shader"):
		print("결과 6-1 (단색 셰이더):", shaders["color_shader"].get("description", ""))
	if shaders.has("fresnel_shader"):
		print("결과 6-2 (프레넬 셰이더):", shaders["fresnel_shader"].get("description", ""))
	if shaders.has("shader_types"):
		print("결과 6-3 (셰이더 유형):", shaders["shader_types"])
	print("")

	print("=== 챕터 17 완료 ===")
