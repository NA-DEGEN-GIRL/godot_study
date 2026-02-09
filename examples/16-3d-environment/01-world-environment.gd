# Chapter 16 - 3D Environment
# 01-world-environment.gd - WorldEnvironment, Sky, Background
#
# 이 파일에서 배울 내용:
# - WorldEnvironment 노드와 Environment 리소스
# - 하늘(Sky) 설정: ProceduralSkyMaterial, 커스텀 Sky
# - 배경(Background) 모드: Sky, Color, Canvas
# - 앰비언트 라이트(Ambient Light) 설정

extends Node3D

func _ready():
	print("=== WorldEnvironment, Sky, Background ===\n")

	# ============================================
	# 1. WorldEnvironment 개요
	# ============================================
	print("--- 1. WorldEnvironment 개요 ---\n")

	print("WorldEnvironment이란?")
	print("  3D 씬의 환경 설정을 담당하는 노드")
	print("  하늘, 배경, 안개, 톤매핑, 후처리 등을 제어")
	print("  씬당 하나만 활성화 가능!")
	print("")

	print("구조:")
	print("  WorldEnvironment")
	print("    environment: Environment 리소스")
	print("    camera_attributes: CameraAttributes 리소스 (선택)")
	print("")

	print("Environment 리소스 주요 섹션:")
	print("  Background  -> 배경/하늘")
	print("  Ambient Light -> 간접광 (그림자 부분 밝기)")
	print("  Tonemap     -> 색조 매핑 (HDR->LDR 변환)")
	print("  SSR         -> 스크린 공간 반사")
	print("  SSAO        -> 스크린 공간 앰비언트 오클루전")
	print("  SSIL        -> 스크린 공간 간접광")
	print("  Glow        -> 발광/블룸")
	print("  Fog         -> 안개")
	print("  Volumetric Fog -> 볼류메트릭 안개")
	print("  Adjustment  -> 밝기/대비/채도 조정")

	# ============================================
	# 2. 코드로 WorldEnvironment 생성
	# ============================================
	print("\n--- 2. 코드로 생성 ---\n")

	# Environment 리소스 생성
	var env := Environment.new()

	# WorldEnvironment 노드 생성
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	add_child(world_env)

	print("WorldEnvironment 생성:")
	print("  var env = Environment.new()")
	print("  var world_env = WorldEnvironment.new()")
	print("  world_env.environment = env")
	print("  add_child(world_env)")

	# ============================================
	# 3. Background 설정
	# ============================================
	print("\n--- 3. Background 설정 ---\n")

	print("Background 모드:")
	print("  BG_CLEAR_COLOR -> 프로젝트 설정의 기본 색상")
	print("  BG_COLOR       -> 지정한 단색")
	print("  BG_SKY         -> Sky 리소스 사용 (기본, 권장)")
	print("  BG_CANVAS      -> 2D 위에 3D 렌더링")
	print("  BG_KEEP        -> 이전 프레임 유지")
	print("  BG_CAMERA_FEED -> 카메라 피드 (AR)")
	print("")

	# 단색 배경
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.1, 0.15)
	print("단색 배경:")
	print("  env.background_mode = BG_COLOR")
	print("  env.background_color = Color(0.1, 0.1, 0.15)")
	print("  -> 심플한 실내 씬, 프로토타이핑에 유용")
	print("")

	# Sky 배경 (기본)
	env.background_mode = Environment.BG_SKY
	print("하늘 배경:")
	print("  env.background_mode = BG_SKY")
	print("  env.sky = Sky.new()")
	print("  -> 가장 일반적인 야외 씬 설정")

	# ============================================
	# 4. ProceduralSkyMaterial
	# ============================================
	print("\n--- 4. ProceduralSkyMaterial ---\n")

	# Sky 생성
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()

	# 하늘 색상
	sky_material.sky_top_color = Color(0.4, 0.6, 0.95)        # 하늘 꼭대기 (진한 파랑)
	sky_material.sky_horizon_color = Color(0.7, 0.8, 0.95)    # 수평선 (연한 파랑)
	sky_material.sky_curve = 0.15                               # 색상 전환 곡선

	# 땅 색상
	sky_material.ground_bottom_color = Color(0.2, 0.17, 0.13)  # 땅 바닥 (갈색)
	sky_material.ground_horizon_color = Color(0.7, 0.75, 0.8)  # 수평선 (밝은 회색)
	sky_material.ground_curve = 0.02                             # 색상 전환 곡선

	# 태양
	sky_material.sun_angle_max = 30.0     # 태양 크기 (도)
	sky_material.sun_curve = 0.15         # 태양 가장자리 곡선

	sky.sky_material = sky_material
	env.sky = sky

	print("ProceduralSkyMaterial (절차적 하늘):")
	print("  코드로 하늘을 생성 (텍스처 필요 없음)")
	print("")
	print("  하늘 색상:")
	print("  sky_top_color     = %s (꼭대기)" % str(sky_material.sky_top_color))
	print("  sky_horizon_color = %s (수평선)" % str(sky_material.sky_horizon_color))
	print("  sky_curve = %.2f (전환 곡선)" % sky_material.sky_curve)
	print("")
	print("  땅 색상:")
	print("  ground_bottom_color  = %s (바닥)" % str(sky_material.ground_bottom_color))
	print("  ground_horizon_color = %s (수평선)" % str(sky_material.ground_horizon_color))
	print("")
	print("  태양:")
	print("  sun_angle_max = %.1f도 (크기)" % sky_material.sun_angle_max)
	print("  sun_curve = %.2f (선명도)" % sky_material.sun_curve)
	print("  -> DirectionalLight3D의 방향이 태양 위치를 결정!")

	# ============================================
	# 5. Sky 리소스 설정
	# ============================================
	print("\n--- 5. Sky 리소스 ---\n")

	print("Sky 속성:")
	print("  sky_material: ShaderMaterial 또는 ProceduralSkyMaterial")
	print("  process_mode: SKY_PROCESS_MODE_AUTOMATIC (기본)")
	print("  radiance_size: SKY_RADIANCE_SIZE_256 (반사 해상도)")
	print("")

	print("Sky process_mode:")
	print("  AUTOMATIC -> 자동 (하늘 변할 때만 업데이트)")
	print("  QUALITY   -> 고품질 (항상 풀 업데이트)")
	print("  INCREMENTAL -> 점진적 (프레임 분산)")
	print("  REALTIME  -> 실시간 (매 프레임, 낮밤 주기에 필요)")
	print("")

	# 실시간 하늘 업데이트 설정
	sky.process_mode = Sky.PROCESS_MODE_REALTIME
	print("낮밤 주기에서:")
	print("  sky.process_mode = PROCESS_MODE_REALTIME")
	print("  -> 매 프레임 하늘을 다시 렌더링 (비쌈!)")
	print("  -> 태양 위치가 변할 때 필요")

	# ============================================
	# 6. 커스텀 Sky (HDRI)
	# ============================================
	print("\n--- 6. 커스텀 Sky (HDRI/Panorama) ---\n")

	print("PanoramaSkyMaterial (HDRI 하늘):")
	print("""  var panorama_mat = PanoramaSkyMaterial.new()
  panorama_mat.panorama = load("res://assets/sky/sky_hdri.exr")
  # 또는 .hdr 파일도 가능

  var sky = Sky.new()
  sky.sky_material = panorama_mat
  env.sky = sky""")
	print("")

	print("HDRI 장점:")
	print("  - 사실적인 하늘 (사진 기반)")
	print("  - 자연스러운 반사와 간접광")
	print("  - 무료 HDRI: polyhaven.com, hdri-haven.com")
	print("")

	print("HDRI 주의사항:")
	print("  - 파일 크기가 클 수 있음 (4K = 수십 MB)")
	print("  - .exr 형식 권장 (HDR 정보 보존)")
	print("  - 낮은 해상도(2K)로도 충분히 좋음")

	# ============================================
	# 7. Ambient Light (앰비언트 라이트)
	# ============================================
	print("\n--- 7. Ambient Light ---\n")

	# 앰비언트 라이트 설정
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.5, 0.6, 0.7)
	env.ambient_light_energy = 0.5
	env.ambient_light_sky_contribution = 0.7

	print("Ambient Light (환경광):")
	print("  직접 빛이 닿지 않는 곳의 기본 밝기")
	print("  그림자 부분이 완전히 검지 않도록!")
	print("")

	print("ambient_light_source:")
	print("  AMBIENT_SOURCE_BG     -> 배경에서 (하늘 색상)")
	print("  AMBIENT_SOURCE_COLOR  -> 지정 색상")
	print("  AMBIENT_SOURCE_SKY    -> Sky에서 (가장 사실적)")
	print("  AMBIENT_SOURCE_DISABLED -> 비활성화 (완전 암흑)")
	print("")

	print("설정값:")
	print("  ambient_light_color = %s" % str(env.ambient_light_color))
	print("  ambient_light_energy = %.1f (강도)" % env.ambient_light_energy)
	print("  ambient_light_sky_contribution = %.1f" % env.ambient_light_sky_contribution)
	print("  -> sky_contribution: 하늘 색이 앰비언트에 얼마나 반영되는지")
	print("")

	print("시나리오별 설정:")
	print("  밝은 낮: energy=0.5, source=SKY")
	print("  흐린 날: energy=0.8, source=COLOR(회색)")
	print("  실내:    energy=0.2, source=COLOR(따뜻한 톤)")
	print("  공포:    energy=0.05, source=COLOR(차가운 파랑)")
	print("  우주:    energy=0.0, source=DISABLED")

	# ============================================
	# 8. Reflected Light (반사광)
	# ============================================
	print("\n--- 8. Reflected Light ---\n")

	print("반사광 소스:")
	print("  env.reflected_light_source:")
	print("  REFLECTION_SOURCE_BG      -> 배경에서")
	print("  REFLECTION_SOURCE_SKY     -> Sky에서 (기본)")
	print("  REFLECTION_SOURCE_DISABLED -> 비활성화")
	print("")

	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	print("ReflectionProbe (반사 프로브):")
	print("  특정 영역의 반사를 캡처하는 노드")
	print("  실내에서 바깥 하늘 대신 실내 반사 표시")
	print("""  var probe = ReflectionProbe.new()
  probe.size = Vector3(10, 4, 10)  # 영향 범위
  probe.interior = true  # 실내 모드 (하늘 반사 차단)
  probe.update_mode = ReflectionProbe.UPDATE_ONCE  # 한 번만 캡처""")

	# ============================================
	# 9. 시간대별 환경 프리셋
	# ============================================
	print("\n--- 9. 시간대별 프리셋 ---\n")

	var presets := {
		"맑은 낮": {
			"sky_top": Color(0.35, 0.55, 0.95),
			"sky_horizon": Color(0.65, 0.8, 0.95),
			"ground_horizon": Color(0.7, 0.75, 0.8),
			"ambient_energy": 0.5,
			"sun_energy": 1.2,
		},
		"일출/일몰": {
			"sky_top": Color(0.3, 0.35, 0.6),
			"sky_horizon": Color(0.9, 0.6, 0.3),
			"ground_horizon": Color(0.5, 0.4, 0.3),
			"ambient_energy": 0.3,
			"sun_energy": 0.8,
		},
		"흐린 날": {
			"sky_top": Color(0.5, 0.55, 0.6),
			"sky_horizon": Color(0.6, 0.63, 0.65),
			"ground_horizon": Color(0.55, 0.55, 0.55),
			"ambient_energy": 0.8,
			"sun_energy": 0.4,
		},
		"밤": {
			"sky_top": Color(0.02, 0.02, 0.05),
			"sky_horizon": Color(0.05, 0.05, 0.1),
			"ground_horizon": Color(0.03, 0.03, 0.05),
			"ambient_energy": 0.05,
			"sun_energy": 0.02,
		},
	}

	for preset_name in presets:
		var p = presets[preset_name]
		print("  %s:" % preset_name)
		print("    sky: %s -> %s" % [str(p["sky_top"]), str(p["sky_horizon"])])
		print("    ambient: %.2f, sun: %.1f" % [p["ambient_energy"], p["sun_energy"]])

	print("")
	print("프리셋 전환 코드:")
	print("""  func apply_preset(preset: Dictionary, duration: float = 2.0):
      var tween = create_tween().set_parallel(true)
      var sky_mat = env.sky.sky_material as ProceduralSkyMaterial

      tween.tween_property(sky_mat, "sky_top_color",
          preset["sky_top"], duration)
      tween.tween_property(sky_mat, "sky_horizon_color",
          preset["sky_horizon"], duration)
      tween.tween_property(env, "ambient_light_energy",
          preset["ambient_energy"], duration)
      tween.tween_property(sun, "light_energy",
          preset["sun_energy"], duration)""")

	# ============================================
	# 10. 테스트 씬 구성
	# ============================================

	_create_test_scene()

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. WorldEnvironment: 씬 환경 설정 노드 (1개만)")
	print("2. Environment: 모든 환경 속성을 담는 리소스")
	print("3. ProceduralSkyMaterial: 코드로 하늘 생성")
	print("4. PanoramaSkyMaterial: HDRI/사진 기반 하늘")
	print("5. BG_SKY: 가장 일반적인 배경 모드")
	print("6. Ambient Light: 그림자 부분의 기본 밝기")
	print("7. AMBIENT_SOURCE_SKY: 하늘에서 자연스러운 환경광")
	print("8. 시간대별 프리셋: Tween으로 부드럽게 전환")


func _create_test_scene():
	# 바닥
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(30, 0.1, 30)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var fmesh := BoxMesh.new()
	fmesh.size = Vector3(30, 0.1, 30)
	floor_mi.mesh = fmesh
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.35, 0.4, 0.3)
	floor_mi.material_override = fmat
	floor_body.add_child(floor_mi)
	add_child(floor_body)

	# 오브젝트들
	var objects := [
		{"mesh": SphereMesh.new(), "pos": Vector3(-3, 1, -3), "color": Color(0.8, 0.3, 0.2)},
		{"mesh": BoxMesh.new(), "pos": Vector3(0, 0.5, -4), "color": Color(0.3, 0.6, 0.8)},
		{"mesh": CylinderMesh.new(), "pos": Vector3(3, 1, -3), "color": Color(0.7, 0.7, 0.2)},
	]

	for obj in objects:
		var mi := MeshInstance3D.new()
		mi.mesh = obj["mesh"]
		mi.position = obj["pos"]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = obj["color"]
		mat.metallic = 0.3
		mat.roughness = 0.5
		mi.material_override = mat
		add_child(mi)

	# 태양
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.0
	sun.light_color = Color(1.0, 0.97, 0.92)
	sun.shadow_enabled = true
	add_child(sun)

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 3, 8)
	cam.look_at(Vector3(0, 0.5, 0))
	cam.make_current()
	add_child(cam)
