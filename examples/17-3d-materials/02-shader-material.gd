# Chapter 17 - 3D Materials & Shaders
# 02-shader-material.gd - ShaderMaterial, 간단한 셰이더, dissolve/rim/hologram
#
# 이 파일에서 배울 내용:
# - ShaderMaterial과 Shader 코드 기초
# - Godot Shading Language (GLSL 유사) 기본 구조
# - 커스텀 셰이더: Dissolve, Rim Light, Hologram 효과
# - Uniform 변수를 이용한 셰이더 파라미터 제어
# - VisualShader vs 코드 셰이더 비교

extends Node3D

func _ready():
	print("=== Chapter 17-2: ShaderMaterial & Custom Shaders ===\n")

	# -----------------------------------------------------------------
	# 1) ShaderMaterial 기본 개념
	# -----------------------------------------------------------------
	print("--- 1. ShaderMaterial 기본 개념 ---")

	print("  StandardMaterial3D: 미리 정의된 PBR 파라미터 조합")
	print("  ShaderMaterial: 커스텀 셰이더 코드로 완전한 제어")
	print()

	# ShaderMaterial 생성 기본 구조
	var shader := Shader.new()
	shader.code = """
shader_type spatial;

void vertex() {
	// 정점(버텍스) 처리
}

void fragment() {
	// 픽셀(프래그먼트) 처리
	ALBEDO = vec3(0.2, 0.6, 1.0);
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader

	print("  셰이더 생성 완료: ", shader)
	print("  ShaderMaterial에 셰이더 연결 완료")
	print()

	# 메시에 적용
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.material_override = material
	add_child(mesh_instance)
	print("  SphereMesh에 커스텀 셰이더 적용")
	print()

	# -----------------------------------------------------------------
	# 2) 셰이더 코드 기본 구조
	# -----------------------------------------------------------------
	print("--- 2. Godot 셰이더 코드 구조 ---")

	print("  shader_type spatial;  // 3D용 셰이더")
	print("  shader_type canvas_item;  // 2D용 셰이더")
	print("  shader_type particles;  // 파티클용 셰이더")
	print("  shader_type sky;  // 하늘용 셰이더")
	print("  shader_type fog;  // 안개용 셰이더")
	print()

	print("  3D spatial 셰이더의 주요 함수:")
	print("    vertex()   - 정점 위치/속성 변환")
	print("    fragment() - 픽셀별 색상/재질 계산")
	print("    light()    - 커스텀 라이팅 모델")
	print()

	print("  fragment()의 주요 출력 변수:")
	print("    ALBEDO    - vec3, 기본 색상 (0~1)")
	print("    METALLIC  - float, 금속성 (0~1)")
	print("    ROUGHNESS - float, 거칠기 (0~1)")
	print("    EMISSION  - vec3, 발광 색상")
	print("    NORMAL_MAP - vec3, 노멀 맵")
	print("    ALPHA     - float, 투명도 (0~1)")
	print()

	print("  vertex()의 주요 변수:")
	print("    VERTEX    - vec3, 정점 위치 (모델 공간)")
	print("    NORMAL    - vec3, 정점 법선")
	print("    UV        - vec2, 텍스처 좌표")
	print("    MODEL_MATRIX - mat4, 모델 변환 행렬")
	print("    TIME      - float, 경과 시간")
	print()

	# -----------------------------------------------------------------
	# 3) Uniform 변수 (셰이더 파라미터)
	# -----------------------------------------------------------------
	print("--- 3. Uniform 변수 ---")

	var shader_uniform := Shader.new()
	shader_uniform.code = """
shader_type spatial;

// uniform은 GDScript에서 값을 전달받는 변수
uniform vec3 custom_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float intensity : hint_range(0.0, 5.0) = 1.0;
uniform sampler2D custom_texture : hint_default_white;

void fragment() {
	vec4 tex = texture(custom_texture, UV);
	ALBEDO = custom_color * tex.rgb;
	EMISSION = custom_color * intensity;
}
"""

	var mat_uniform := ShaderMaterial.new()
	mat_uniform.shader = shader_uniform

	# GDScript에서 uniform 값 설정
	mat_uniform.set_shader_parameter("custom_color", Vector3(0.0, 1.0, 0.5))
	mat_uniform.set_shader_parameter("intensity", 2.0)

	var color_val = mat_uniform.get_shader_parameter("custom_color")
	var intensity_val = mat_uniform.get_shader_parameter("intensity")
	print("  set_shader_parameter(\"custom_color\", Vector3(0, 1, 0.5))")
	print("  set_shader_parameter(\"intensity\", 2.0)")
	print("  읽기 - custom_color: ", color_val)
	print("  읽기 - intensity: ", intensity_val)
	print()

	print("  Uniform 힌트 종류:")
	print("    source_color - 색상 피커 표시")
	print("    hint_range(min, max) - 슬라이더 표시")
	print("    hint_default_white - 기본 흰색 텍스처")
	print("    hint_default_black - 기본 검은색 텍스처")
	print("    hint_normal - 노멀 맵 텍스처")
	print()

	# -----------------------------------------------------------------
	# 4) Dissolve (디졸브) 셰이더
	# -----------------------------------------------------------------
	print("--- 4. Dissolve 셰이더 ---")

	var shader_dissolve := Shader.new()
	shader_dissolve.code = """
shader_type spatial;

// 디졸브 효과: 노이즈 텍스처 기반으로 점진적으로 사라짐
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 edge_color : source_color = vec3(1.0, 0.5, 0.0);
uniform float edge_width : hint_range(0.0, 0.1) = 0.02;
uniform vec3 albedo_color : source_color = vec3(0.8, 0.8, 0.8);

// 간단한 노이즈 함수 (실제로는 텍스처 사용 권장)
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	float noise_val = noise(UV * 10.0);

	// dissolve_amount보다 작은 영역은 투명하게
	if (noise_val < dissolve_amount) {
		discard;
	}

	// 가장자리에 발광 색상
	float edge = smoothstep(dissolve_amount, dissolve_amount + edge_width, noise_val);
	ALBEDO = mix(edge_color, albedo_color, edge);
	EMISSION = edge_color * (1.0 - edge) * 3.0;
}
"""

	var mat_dissolve := ShaderMaterial.new()
	mat_dissolve.shader = shader_dissolve
	mat_dissolve.set_shader_parameter("dissolve_amount", 0.3)

	var dissolve_mesh := MeshInstance3D.new()
	dissolve_mesh.mesh = BoxMesh.new()
	dissolve_mesh.material_override = mat_dissolve
	dissolve_mesh.position = Vector3(-3, 0, 0)
	add_child(dissolve_mesh)

	print("  디졸브 셰이더 적용 완료")
	print("  dissolve_amount = 0.3 (30%% 사라짐)")
	print("  edge_color = 주황색 (가장자리 발광)")
	print()
	print("  디졸브 애니메이션 코드:")
	print("    var tween = create_tween()")
	print("    tween.tween_method(func(v):")
	print("        mat.set_shader_parameter(\"dissolve_amount\", v)")
	print("    , 0.0, 1.0, 2.0)  # 2초에 걸쳐 0->1")
	print()

	# -----------------------------------------------------------------
	# 5) Rim Light (림 라이트) 셰이더
	# -----------------------------------------------------------------
	print("--- 5. Rim Light 셰이더 ---")

	var shader_rim := Shader.new()
	shader_rim.code = """
shader_type spatial;

// 림 라이트: 물체 가장자리를 밝게 표현 (프레넬 효과)
uniform vec3 albedo_color : source_color = vec3(0.2, 0.2, 0.3);
uniform vec3 rim_color : source_color = vec3(0.0, 0.8, 1.0);
uniform float rim_power : hint_range(0.5, 10.0) = 3.0;
uniform float rim_intensity : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	// 프레넬 계산: 시선과 법선의 각도에 따른 효과
	// VIEW: 카메라에서 픽셀로의 방향 (뷰 공간)
	// NORMAL: 표면의 법선 방향 (뷰 공간)
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), rim_power);

	ALBEDO = albedo_color;
	EMISSION = rim_color * fresnel * rim_intensity;
	ROUGHNESS = 0.6;
	METALLIC = 0.1;
}
"""

	var mat_rim := ShaderMaterial.new()
	mat_rim.shader = shader_rim

	var rim_mesh := MeshInstance3D.new()
	rim_mesh.mesh = SphereMesh.new()
	rim_mesh.material_override = mat_rim
	rim_mesh.position = Vector3(0, 2, 0)
	add_child(rim_mesh)

	print("  림 라이트 셰이더 적용 완료")
	print("  프레넬 효과: pow(1.0 - dot(NORMAL, VIEW), power)")
	print("  rim_power가 높을수록 가장자리만 밝음")
	print("  rim_power가 낮으면 넓게 퍼짐")
	print()
	print("  활용:")
	print("    - 캐릭터 선택 하이라이트")
	print("    - 마법/에너지 쉴드 효과")
	print("    - 역광 효과 (캐릭터 윤곽선)")
	print()

	# -----------------------------------------------------------------
	# 6) Hologram (홀로그램) 셰이더
	# -----------------------------------------------------------------
	print("--- 6. Hologram 셰이더 ---")

	var shader_holo := Shader.new()
	shader_holo.code = """
shader_type spatial;
render_mode blend_add, cull_disabled, unshaded;

// 홀로그램 효과: 스캔라인 + 투명 + 프레넬
uniform vec3 holo_color : source_color = vec3(0.0, 0.7, 1.0);
uniform float scanline_count : hint_range(10.0, 200.0) = 80.0;
uniform float scanline_speed : hint_range(0.0, 5.0) = 1.0;
uniform float flicker_speed : hint_range(0.0, 10.0) = 3.0;
uniform float alpha_base : hint_range(0.0, 1.0) = 0.3;
uniform float rim_strength : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	// 프레넬 (가장자리 밝게)
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), 2.0);

	// 스캔라인 효과 (수평선이 위로 이동)
	float scanline = sin((UV.y + TIME * scanline_speed) * scanline_count * 3.14159) * 0.5 + 0.5;
	scanline = pow(scanline, 2.0);

	// 깜빡임 효과
	float flicker = sin(TIME * flicker_speed) * 0.1 + 0.9;

	// 최종 합성
	float alpha = (alpha_base + fresnel * rim_strength) * flicker;
	alpha *= mix(0.5, 1.0, scanline);

	ALBEDO = holo_color;
	ALPHA = clamp(alpha, 0.0, 1.0);
}
"""

	var mat_holo := ShaderMaterial.new()
	mat_holo.shader = shader_holo

	var holo_mesh := MeshInstance3D.new()
	holo_mesh.mesh = CylinderMesh.new()
	holo_mesh.material_override = mat_holo
	holo_mesh.position = Vector3(3, 2, 0)
	add_child(holo_mesh)

	print("  홀로그램 셰이더 적용 완료")
	print("  render_mode:")
	print("    blend_add - 가산 블렌딩 (빛나는 효과)")
	print("    cull_disabled - 양면 렌더링")
	print("    unshaded - 조명 영향 없음")
	print()
	print("  효과 구성 요소:")
	print("    1. 프레넬 - 가장자리 밝게")
	print("    2. 스캔라인 - 수평 줄무늬 이동")
	print("    3. 깜빡임 - sin(TIME)으로 흔들림")
	print()

	# -----------------------------------------------------------------
	# 7) 셰이더에서 TIME 활용
	# -----------------------------------------------------------------
	print("--- 7. TIME 기반 애니메이션 ---")

	print("  TIME 내장 변수로 셰이더 애니메이션 구현:")
	print()
	print("  // 물결 효과 (vertex)")
	print("  void vertex() {")
	print("      VERTEX.y += sin(VERTEX.x * 4.0 + TIME * 2.0) * 0.3;")
	print("  }")
	print()
	print("  // 색상 펄스 (fragment)")
	print("  void fragment() {")
	print("      float pulse = sin(TIME * 3.0) * 0.5 + 0.5;")
	print("      ALBEDO = mix(color_a, color_b, pulse);")
	print("  }")
	print()
	print("  // UV 스크롤 (fragment)")
	print("  void fragment() {")
	print("      vec2 scrolled_uv = UV + vec2(TIME * 0.1, 0.0);")
	print("      ALBEDO = texture(albedo_tex, scrolled_uv).rgb;")
	print("  }")
	print()

	# 물결 셰이더 데모
	var shader_wave := Shader.new()
	shader_wave.code = """
shader_type spatial;

uniform vec3 wave_color : source_color = vec3(0.2, 0.4, 0.8);
uniform float wave_height : hint_range(0.0, 2.0) = 0.3;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wave_frequency : hint_range(1.0, 20.0) = 4.0;

void vertex() {
	VERTEX.y += sin(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_height;
	VERTEX.y += cos(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 0.8) * wave_height * 0.5;
}

void fragment() {
	ALBEDO = wave_color;
	ROUGHNESS = 0.1;
	METALLIC = 0.3;
}
"""

	var mat_wave := ShaderMaterial.new()
	mat_wave.shader = shader_wave

	var plane := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(6, 6)
	plane_mesh.subdivide_width = 32
	plane_mesh.subdivide_depth = 32
	plane.mesh = plane_mesh
	plane.material_override = mat_wave
	plane.position = Vector3(0, -2, 0)
	add_child(plane)

	print("  물결 셰이더 데모: PlaneMesh에 파도 효과 적용")
	print("  subdivide 32x32로 충분한 정점 확보 (변형 가능하도록)")
	print()

	# -----------------------------------------------------------------
	# 8) VisualShader vs 코드 셰이더
	# -----------------------------------------------------------------
	print("--- 8. VisualShader vs 코드 셰이더 ---")

	print("  VisualShader (노드 기반):")
	print("    장점: 시각적, 초보자 친화적, 실시간 프리뷰")
	print("    단점: 복잡한 로직 어려움, 파일 크기 큼")
	print("    생성: VisualShader.new(), 에디터에서 노드 연결")
	print()
	print("  코드 셰이더 (Shader):")
	print("    장점: 유연성, 최적화 용이, 버전 관리 적합")
	print("    단점: GLSL 지식 필요, 디버깅 어려움")
	print("    생성: Shader.new(), .gdshader 파일")
	print()

	# VisualShader 코드 생성 예시
	var visual_shader := VisualShader.new()
	visual_shader.set_mode(Shader.MODE_SPATIAL)
	print("  VisualShader 생성: ", visual_shader)
	print("  실제로는 에디터에서 노드를 드래그&드롭으로 연결합니다")
	print()

	# -----------------------------------------------------------------
	# 9) 셰이더 성능 팁
	# -----------------------------------------------------------------
	print("--- 9. 셰이더 성능 팁 ---")

	print("  1. branch(분기) 최소화:")
	print("     나쁨: if (condition) { ... } else { ... }")
	print("     좋음: mix(a, b, step(threshold, value))")
	print()
	print("  2. 텍스처 샘플링 줄이기:")
	print("     각 texture() 호출은 비용이 높음")
	print("     가능하면 채널 패킹 (RGBA에 여러 데이터)")
	print()
	print("  3. 정밀도 힌트 사용:")
	print("     lowp, mediump, highp (모바일에서 중요)")
	print()
	print("  4. 복잡한 계산은 vertex()에서:")
	print("     vertex()는 정점 수만큼, fragment()는 픽셀 수만큼 실행")
	print("     가능한 계산은 vertex()에서 varying으로 전달")
	print()
	print("  5. render_mode 최적화:")
	print("     unshaded - 조명 계산 생략 (UI, 파티클)")
	print("     skip_vertex_transform - 수동 변환 시")
	print()

	print("=== 02-shader-material.gd 완료 ===")
