# Chapter 13 - 3D Basics
# 03-lighting-basics.gd - 3D 조명 기초
#
# 이 파일에서 배울 내용:
# - DirectionalLight3D (태양광/방향 조명)
# - OmniLight3D (전방향 점광원)
# - SpotLight3D (스포트라이트)
# - 조명 속성과 그림자 설정

extends Node3D

func _ready():
	print("=== 3D 조명 기초 (Lighting Basics) ===\n")

	# 먼저 테스트용 오브젝트 생성
	_create_test_scene()

	# ============================================
	# 1. 3D 조명 개요
	# ============================================
	print("--- 1. 3D 조명 개요 ---\n")

	print("Godot 4 조명 시스템:")
	print("  Godot 4는 Vulkan 기반 물리 기반 렌더링(PBR) 사용")
	print("  조명 없이는 아무것도 보이지 않음!")
	print("  (에디터에서는 Preview Light가 자동 활성화)")
	print("")

	print("3가지 Light3D 노드:")
	print("  1. DirectionalLight3D - 태양광 (방향, 무한 거리)")
	print("  2. OmniLight3D        - 전구 (모든 방향, 제한 거리)")
	print("  3. SpotLight3D        - 손전등 (원뿔 모양, 제한 거리)")
	print("")

	print("공통 속성 (Light3D 부모 클래스):")
	print("  light_color: Color        -> 조명 색상")
	print("  light_energy: float       -> 조명 강도")
	print("  light_indirect_energy     -> 간접광 강도")
	print("  shadow_enabled: bool      -> 그림자 활성화")
	print("  light_bake_mode           -> 베이킹 모드")

	# ============================================
	# 2. DirectionalLight3D (방향광/태양광)
	# ============================================
	print("\n--- 2. DirectionalLight3D ---\n")

	var dir_light := DirectionalLight3D.new()
	dir_light.name = "Sun"

	# 방향 설정 (회전으로 빛 방향 결정)
	# -Y 방향이 기본 (위에서 아래로)
	# rotation으로 각도 조절
	dir_light.rotation_degrees = Vector3(-45, 30, 0)

	# 색상과 강도
	dir_light.light_color = Color(1.0, 0.95, 0.9)  # 약간 따뜻한 색
	dir_light.light_energy = 1.0                     # 기본 강도

	# 그림자 설정
	dir_light.shadow_enabled = true

	add_child(dir_light)

	print("DirectionalLight3D (태양광):")
	print("  - 위치는 의미 없음, 회전만 중요!")
	print("  - 모든 오브젝트에 같은 방향으로 빛이 들어옴")
	print("  - 태양, 달 등 무한히 먼 광원 표현")
	print("")
	print("  rotation_degrees = %s" % str(dir_light.rotation_degrees))
	print("  light_color = %s" % str(dir_light.light_color))
	print("  light_energy = %.1f" % dir_light.light_energy)
	print("  shadow_enabled = %s" % dir_light.shadow_enabled)
	print("")

	# DirectionalLight3D 고유 속성
	print("DirectionalLight3D 고유 속성:")
	print("  shadow_mode:")
	print("    SHADOW_ORTHOGONAL  = 하나의 그림자맵 (성능 좋음)")
	print("    SHADOW_PARALLEL_2_SPLITS = 2분할 (기본)")
	print("    SHADOW_PARALLEL_4_SPLITS = 4분할 (품질 좋음)")
	print("  -> 멀리 있는 그림자도 선명하게 유지")
	print("")

	# 시간대별 태양광 설정 예시
	print("시간대별 태양광:")
	var time_settings := {
		"아침": {"rotation": Vector3(-15, -90, 0), "color": Color(1.0, 0.8, 0.6), "energy": 0.7},
		"낮":   {"rotation": Vector3(-60, 0, 0),   "color": Color(1.0, 0.98, 0.95), "energy": 1.2},
		"저녁": {"rotation": Vector3(-10, 90, 0),  "color": Color(1.0, 0.5, 0.3), "energy": 0.5},
		"밤":   {"rotation": Vector3(-30, 180, 0), "color": Color(0.4, 0.5, 0.8), "energy": 0.1},
	}

	for time_name in time_settings:
		var s = time_settings[time_name]
		print("  %s: rotation=%s, color=%s, energy=%.1f" % [
			time_name, str(s["rotation"]), str(s["color"]), s["energy"]])

	# ============================================
	# 3. OmniLight3D (점광원/전구)
	# ============================================
	print("\n--- 3. OmniLight3D ---\n")

	var omni_light := OmniLight3D.new()
	omni_light.name = "PointLight"

	# 위치가 중요! (빛이 퍼져나가는 중심)
	omni_light.position = Vector3(0, 3, 0)

	# 색상과 강도
	omni_light.light_color = Color(1.0, 0.9, 0.7)  # 따뜻한 전구색
	omni_light.light_energy = 2.0

	# 범위와 감쇠
	omni_light.omni_range = 10.0       # 빛이 닿는 최대 거리
	omni_light.omni_attenuation = 1.0  # 감쇠 곡선 (1=선형, 2=더 급격)

	# 그림자
	omni_light.shadow_enabled = true

	add_child(omni_light)

	print("OmniLight3D (점광원):")
	print("  - 위치에서 모든 방향으로 빛을 방출")
	print("  - 전구, 횃불, 폭발 효과 등에 사용")
	print("  - range로 영향 범위 제한 (성능!)")
	print("")
	print("  position = %s" % str(omni_light.position))
	print("  light_energy = %.1f" % omni_light.light_energy)
	print("  omni_range = %.1f (최대 도달 거리)" % omni_light.omni_range)
	print("  omni_attenuation = %.1f (감쇠 곡선)" % omni_light.omni_attenuation)
	print("")

	print("omni_attenuation 감쇠 곡선:")
	print("  0.0 = 감쇠 없음 (거리 무관하게 밝음)")
	print("  0.5 = 완만한 감쇠")
	print("  1.0 = 선형 감쇠 (기본)")
	print("  2.0 = 급격한 감쇠 (가까이만 밝음)")
	print("  4.0 = 매우 급격한 감쇠")
	print("")

	# 여러 점광원 배치 예시
	print("복수 점광원 배치 예시:")
	var light_positions := [
		Vector3(-4, 2, -4),
		Vector3(4, 2, -4),
		Vector3(-4, 2, 4),
		Vector3(4, 2, 4),
	]

	for i in range(light_positions.size()):
		var light := OmniLight3D.new()
		light.name = "WallLight_%d" % i
		light.position = light_positions[i]
		light.omni_range = 6.0
		light.light_energy = 1.5
		light.light_color = Color(1.0, 0.85, 0.7)
		add_child(light)
		print("  %s at %s" % [light.name, str(light.position)])

	# ============================================
	# 4. SpotLight3D (스포트라이트)
	# ============================================
	print("\n--- 4. SpotLight3D ---\n")

	var spot_light := SpotLight3D.new()
	spot_light.name = "FlashLight"

	# 위치와 방향 (아래를 향함)
	spot_light.position = Vector3(0, 5, 0)
	spot_light.rotation_degrees = Vector3(-90, 0, 0)  # 아래를 향함

	# 색상과 강도
	spot_light.light_color = Color.WHITE
	spot_light.light_energy = 3.0

	# 범위와 각도
	spot_light.spot_range = 15.0        # 빛 도달 거리
	spot_light.spot_angle = 30.0        # 원뿔 절반 각도 (도)
	spot_light.spot_angle_attenuation = 1.0  # 가장자리 감쇠
	spot_light.spot_attenuation = 1.0        # 거리 감쇠

	# 그림자
	spot_light.shadow_enabled = true

	add_child(spot_light)

	print("SpotLight3D (스포트라이트):")
	print("  - 위치에서 특정 방향으로 원뿔형 빛 방출")
	print("  - 손전등, 무대조명, 가로등 등에 사용")
	print("  - -Z 방향이 빛이 나가는 방향 (앞쪽)")
	print("")
	print("  position = %s" % str(spot_light.position))
	print("  rotation_degrees = %s" % str(spot_light.rotation_degrees))
	print("  spot_range = %.1f (도달 거리)" % spot_light.spot_range)
	print("  spot_angle = %.1f도 (원뿔 절반 각도)" % spot_light.spot_angle)
	print("  spot_angle_attenuation = %.1f (가장자리 부드러움)" % spot_light.spot_angle_attenuation)
	print("")

	print("spot_angle 가이드:")
	print("  5~10도:  레이저/매우 집중된 빛")
	print("  15~30도: 손전등, 스포트라이트")
	print("  45~60도: 넓은 조명, 가로등")
	print("  89도:    거의 반구형 (최대값)")

	# ============================================
	# 5. 그림자 설정
	# ============================================
	print("\n--- 5. 그림자 설정 ---\n")

	print("그림자 공통 속성:")
	print("  shadow_enabled = true     -> 그림자 활성화")
	print("  shadow_bias = 0.1         -> 그림자 편향 (아티팩트 방지)")
	print("  shadow_normal_bias = 1.0  -> 법선 방향 편향")
	print("  shadow_blur = 1.0         -> 그림자 부드러움")
	print("  shadow_opacity = 1.0      -> 그림자 불투명도")
	print("")

	print("그림자 성능 팁:")
	print("  - 그림자는 비쌈! 필요한 조명에만 활성화")
	print("  - DirectionalLight3D: 1개만 그림자 권장")
	print("  - OmniLight3D: 큐브맵 6면 렌더링 (가장 비쌈!)")
	print("  - SpotLight3D: 1면만 렌더링 (점광원보다 저렴)")
	print("  - 작은 조명은 그림자 비활성화")
	print("")

	print("그림자 bias 문제:")
	print("  shadow_bias가 너무 낮으면:")
	print("    -> 셀프 섀도잉 (표면에 줄무늬 아티팩트)")
	print("  shadow_bias가 너무 높으면:")
	print("    -> 피터 팬 효과 (그림자가 오브젝트에서 떨어짐)")

	# ============================================
	# 6. 조명 레이어와 컬링
	# ============================================
	print("\n--- 6. 조명 레이어와 컬링 ---\n")

	print("조명 레이어 시스템:")
	print("  MeshInstance3D.layers  -> 오브젝트가 속한 레이어")
	print("  Light3D.light_cull_mask -> 조명이 영향을 줄 레이어")
	print("")

	# 특정 레이어에만 영향을 주는 조명
	var selective_light := OmniLight3D.new()
	selective_light.name = "SelectiveLight"
	selective_light.set_cull_mask_value(1, true)   # 레이어 1만 조명
	selective_light.set_cull_mask_value(2, false)  # 레이어 2는 제외
	add_child(selective_light)

	print("활용 예시:")
	print("  - 캐릭터만 비추는 조명 (레이어 2)")
	print("  - UI 3D 오브젝트 전용 조명 (레이어 10)")
	print("  - 특정 방의 조명이 다른 방에 영향 X")
	print("")

	print("코드로 레이어 설정:")
	print("  light.set_cull_mask_value(layer_number, enabled)")
	print("  mesh.set_layer_mask_value(layer_number, enabled)")

	# ============================================
	# 7. Light3D 베이킹 모드
	# ============================================
	print("\n--- 7. 베이킹 모드 ---\n")

	print("light_bake_mode 설정:")
	print("  BAKE_DISABLED  -> 베이킹 안 함 (실시간만)")
	print("  BAKE_STATIC    -> 정적 조명 베이킹 (기본)")
	print("  BAKE_DYNAMIC   -> 동적 베이킹 (GI)")
	print("")

	print("LightmapGI (라이트맵) 사용 시:")
	print("  정적 오브젝트의 조명을 미리 계산 (베이킹)")
	print("  실시간 연산 없이 고품질 조명 가능")
	print("  -> 정적 씬(건물, 지형)에 권장")
	print("")

	print("VoxelGI (볼셀 GI) 사용 시:")
	print("  실시간 간접광 (Global Illumination)")
	print("  빛이 벽에 반사되어 다른 면을 비추는 효과")
	print("  -> 동적 씬에 권장, 성능 비용 높음")

	# ============================================
	# 8. 조명 관련 유용한 패턴
	# ============================================
	print("\n--- 8. 실전 패턴 ---\n")

	# 깜박이는 조명 (코드 설명)
	print("깜박이는 조명 (횃불, 네온사인):")
	print("""  var base_energy: float = 2.0
  var flicker_speed: float = 10.0
  var flicker_amount: float = 0.5

  func _process(delta):
      var noise_val = sin(Time.get_ticks_msec() * 0.001 * flicker_speed)
      noise_val += sin(Time.get_ticks_msec() * 0.001 * flicker_speed * 2.3) * 0.5
      light.light_energy = base_energy + noise_val * flicker_amount""")
	print("")

	# 낮밤 주기 (코드 설명)
	print("낮밤 주기:")
	print("""  var day_duration: float = 120.0  # 120초 = 하루
  var time_of_day: float = 0.0     # 0~1

  func _process(delta):
      time_of_day += delta / day_duration
      if time_of_day > 1.0:
          time_of_day -= 1.0

      # 태양 각도 (0=일출, 0.5=일몰, 1=다시 일출)
      var angle = time_of_day * 360.0 - 90.0
      sun.rotation_degrees.x = angle

      # 색상 변화
      var t = time_of_day
      if t < 0.25:  # 일출
          sun.light_color = Color(1.0, 0.8, 0.6)
      elif t < 0.5:  # 낮
          sun.light_color = Color(1.0, 0.98, 0.95)
      elif t < 0.75:  # 일몰
          sun.light_color = Color(1.0, 0.5, 0.3)""")

	# ============================================
	# 9. 성능 최적화
	# ============================================
	print("\n--- 9. 성능 최적화 ---\n")

	print("조명 수 제한:")
	print("  - Forward+: 오브젝트당 최대 8개 조명 (기본)")
	print("  - 전체 조명 수: 가능하면 16개 이하 권장")
	print("  - 그림자 있는 조명: 4~6개 이하 권장")
	print("")

	print("최적화 기법:")
	print("  1. 거리에 따른 조명 LOD (멀리서 비활성화)")
	print("  2. OmniLight3D 대신 SpotLight3D 사용 (그림자 비용)")
	print("  3. 작은 조명은 shadow_enabled = false")
	print("  4. omni_range/spot_range를 필요한 만큼만 설정")
	print("  5. 정적 조명은 LightmapGI로 베이킹")
	print("  6. light_size > 0이면 소프트 섀도 (더 비쌈)")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. DirectionalLight3D: 태양광, 회전만 중요, 위치 무관")
	print("2. OmniLight3D: 점광원, 모든 방향, range로 범위 제한")
	print("3. SpotLight3D: 원뿔 조명, 방향+범위+각도 설정")
	print("4. shadow_enabled: 그림자는 비쌈, 선택적으로 사용")
	print("5. attenuation: 감쇠 곡선으로 빛 감소 패턴 제어")
	print("6. 레이어 마스크: 특정 오브젝트만 조명 가능")
	print("7. 베이킹: 정적 씬은 LightmapGI/VoxelGI 활용")


# 테스트 씬을 구성하는 헬퍼 함수
func _create_test_scene():
	# 바닥
	var floor_mi := MeshInstance3D.new()
	floor_mi.name = "TestFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(20, 20)
	floor_mi.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.6, 0.6, 0.6)
	floor_mi.material_override = floor_mat
	add_child(floor_mi)

	# 큐브 몇 개
	for i in range(3):
		var cube_mi := MeshInstance3D.new()
		cube_mi.name = "TestCube_%d" % i
		var cube_mesh := BoxMesh.new()
		cube_mi.mesh = cube_mesh
		cube_mi.position = Vector3((i - 1) * 3.0, 0.5, 0)
		add_child(cube_mi)

	# 구
	var sphere_mi := MeshInstance3D.new()
	sphere_mi.name = "TestSphere"
	sphere_mi.mesh = SphereMesh.new()
	sphere_mi.position = Vector3(0, 1.5, -3)
	add_child(sphere_mi)

	# 카메라
	var cam := Camera3D.new()
	cam.name = "TestCamera"
	cam.position = Vector3(0, 5, 8)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	add_child(cam)
