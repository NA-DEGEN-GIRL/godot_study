# Chapter 16 - 3D Environment
# 02-lighting-system.gd - 조명 시스템, 그림자, 에너지, 색온도
#
# 이 파일에서 배울 내용:
# - 완전한 조명 시스템 설계
# - 그림자 품질과 설정
# - 에너지(강도)와 색온도 활용
# - 낮밤 주기 조명 시스템

extends Node3D

# ============================================
# 낮밤 시스템 변수
# ============================================

var time_of_day := 0.25       # 0~1 (0.25 = 오전 6시)
var day_duration := 120.0     # 하루 길이 (초)
var auto_cycle := false       # 자동 순환

# 조명 참조
var sun: DirectionalLight3D
var moon: DirectionalLight3D
var env: Environment
var sky_material: ProceduralSkyMaterial

func _ready():
	print("=== 조명 시스템 ===\n")

	_create_scene()

	# ============================================
	# 1. 조명 설계 원칙
	# ============================================
	print("--- 1. 조명 설계 원칙 ---\n")

	print("3점 조명 (Three-Point Lighting):")
	print("  1. Key Light (주광):")
	print("     -> 주된 빛 (태양, 주 조명)")
	print("     -> 가장 밝고 그림자를 만듦")
	print("     -> DirectionalLight3D 또는 강한 SpotLight3D")
	print("")
	print("  2. Fill Light (보조광):")
	print("     -> 그림자를 부드럽게 채움")
	print("     -> Key Light보다 약한 반대쪽 조명")
	print("     -> 또는 Ambient Light로 대체")
	print("")
	print("  3. Rim/Back Light (역광):")
	print("     -> 뒤에서 비추는 빛")
	print("     -> 실루엣/윤곽을 강조")
	print("     -> 캐릭터를 배경에서 분리")
	print("")

	print("게임 조명 가이드:")
	print("  야외: DirectionalLight3D (태양) + Ambient + Sky")
	print("  실내: OmniLight3D/SpotLight3D + 약한 Ambient")
	print("  지하: SpotLight3D (손전등) + 최소 Ambient")
	print("  공포: 매우 낮은 조명 + 강한 그림자")

	# ============================================
	# 2. Light3D 에너지 (강도)
	# ============================================
	print("\n--- 2. 에너지(강도) 설정 ---\n")

	print("light_energy (물리 단위):")
	print("  Godot 4는 물리 기반 조명 단위 사용 가능")
	print("  -> Project Settings > Rendering > Lights and Shadows")
	print("     > Use Physical Light Units = true")
	print("")

	print("물리 단위 OFF (기본):")
	print("  energy = 0.0  -> 꺼짐")
	print("  energy = 0.5  -> 어두운 조명")
	print("  energy = 1.0  -> 일반 강도")
	print("  energy = 2.0  -> 밝은 조명")
	print("  energy = 4.0  -> 매우 밝음")
	print("")

	print("물리 단위 ON:")
	print("  DirectionalLight3D: lux (럭스)")
	print("    햇빛: 100,000 lux")
	print("    흐린 날: 10,000 lux")
	print("    달빛: 0.1 lux")
	print("")
	print("  OmniLight3D/SpotLight3D: lumens (루멘)")
	print("    양초: 12 lumens")
	print("    전구 60W: 800 lumens")
	print("    형광등: 3,000 lumens")
	print("    투광등: 50,000 lumens")

	# ============================================
	# 3. 색온도 (Color Temperature)
	# ============================================
	print("\n--- 3. 색온도 ---\n")

	print("색온도 (Kelvin):")
	print("  촛불:           ~1,800K (매우 따뜻한 주황)")
	print("  백열등:         ~2,700K (따뜻한 노랑)")
	print("  할로겐:         ~3,000K (따뜻한 백색)")
	print("  형광등(주광색): ~4,000K (중성 백색)")
	print("  맑은 낮:        ~5,500K (순백)")
	print("  흐린 하늘:      ~6,500K (약간 차가운 백색)")
	print("  푸른 하늘:      ~10,000K (매우 차가운 파랑)")
	print("")

	# 색온도를 Color로 변환하는 함수 (근사)
	print("Godot에서 색온도 적용:")
	print("  light.light_color = kelvin_to_color(3000)  # 따뜻한 전구색")
	print("")

	# 색온도 예시
	var temperatures := [1800, 2700, 4000, 5500, 6500, 10000]
	print("색온도별 색상 예시:")
	for temp in temperatures:
		var color := _kelvin_to_color(temp)
		print("  %5dK -> Color(%.2f, %.2f, %.2f)" % [temp, color.r, color.g, color.b])
	print("")

	print("분위기별 색온도 가이드:")
	print("  따뜻한/편안한: 2700~3500K (거실, 카페)")
	print("  중성/업무용:   4000~5000K (사무실, 학교)")
	print("  차가운/긴장:   6500~8000K (병원, 공포)")
	print("  비현실적:     극단적 값 (파랑/빨강 조명)")

	# ============================================
	# 4. 그림자 시스템
	# ============================================
	print("\n--- 4. 그림자 시스템 ---\n")

	print("그림자 품질 설정 (ProjectSettings):")
	print("  Rendering > Lights and Shadows >")
	print("    directional_shadow/size: 2048~4096 (해상도)")
	print("    directional_shadow/soft_shadow_filter_quality")
	print("    positional_shadow/soft_shadow_filter_quality")
	print("")

	print("DirectionalLight3D 그림자:")
	sun.shadow_enabled = true
	print("  shadow_enabled = true")
	print("")

	print("  shadow_mode (분할 모드):")
	print("    SHADOW_ORTHOGONAL       -> 1분할 (가까운 곳만)")
	print("    SHADOW_PARALLEL_2_SPLITS -> 2분할 (기본, 균형)")
	print("    SHADOW_PARALLEL_4_SPLITS -> 4분할 (최고 품질)")
	print("    -> 분할이 많을수록 멀리까지 선명, 더 비쌈")
	print("")

	print("  directional_shadow_max_distance:")
	print("    그림자가 보이는 최대 거리")
	print("    값이 클수록 멀리까지 그림자, 가까운 곳 품질 하락")
	print("    일반적으로 50~200 사이")
	print("")

	print("  shadow_bias / shadow_normal_bias:")
	print("    너무 낮음 -> 셀프 섀도잉 (줄무늬 아티팩트)")
	print("    너무 높음 -> 피터 팬 (그림자 떠다님)")
	print("    bias=0.1~0.2, normal_bias=1.0~2.0 권장")

	# ============================================
	# 5. OmniLight3D / SpotLight3D 그림자
	# ============================================
	print("\n--- 5. 점광/스팟 그림자 ---\n")

	print("OmniLight3D 그림자:")
	print("  omni_shadow_mode:")
	print("    SHADOW_DUAL_PARABOLOID -> 2면 렌더링 (성능)")
	print("    SHADOW_CUBE            -> 6면 렌더링 (품질)")
	print("  -> 6면 = 모든 방향 그림자, 매우 비쌈!")
	print("  -> 가능하면 SpotLight3D로 대체 (1면만)")
	print("")

	print("SpotLight3D 그림자:")
	print("  1면만 렌더링 (가장 저렴한 동적 그림자)")
	print("  -> 손전등, 가로등 등에 최적")
	print("")

	print("그림자 최적화 전략:")
	print("  1. 중요한 조명 1~2개만 그림자 활성화")
	print("  2. 거리에 따라 그림자 토글")
	print("""     func _process(delta):
         var dist = global_position.distance_to(camera.global_position)
         shadow_enabled = dist < shadow_distance""")
	print("  3. OmniLight3D -> SpotLight3D로 교체 (비용 1/6)")
	print("  4. 정적 오브젝트는 LightmapGI로 베이킹")

	# ============================================
	# 6. 낮밤 주기 시스템
	# ============================================
	print("\n--- 6. 낮밤 주기 ---\n")

	print("낮밤 주기 코드:")
	print("""  var time_of_day: float = 0.25  # 0.25 = 오전 6시
  var day_duration: float = 120.0  # 120초 = 하루

  # 시간대 구간
  # 0.0~0.25 : 밤 (자정~새벽)
  # 0.25~0.35: 일출
  # 0.35~0.65: 낮
  # 0.65~0.75: 일몰
  # 0.75~1.0 : 밤

  func _process(delta):
      if auto_cycle:
          time_of_day += delta / day_duration
          if time_of_day > 1.0:
              time_of_day -= 1.0
          update_sun_position()
          update_sky_colors()
          update_lighting()""")
	print("")

	print("태양 위치 계산:")
	print("""  func update_sun_position():
      # 시간을 각도로 변환 (0.25 = 일출, 0.75 = 일몰)
      var sun_angle = (time_of_day - 0.25) * 360.0
      sun.rotation_degrees.x = -sun_angle

      # 태양이 수평선 아래면 달빛으로 전환
      var is_daytime = time_of_day > 0.25 and time_of_day < 0.75
      sun.visible = is_daytime
      moon.visible = not is_daytime""")

	# ============================================
	# 7. 조명 그룹 관리
	# ============================================
	print("\n--- 7. 조명 그룹 관리 ---\n")

	print("대규모 씬에서 조명 관리:")
	print("""  # 조명을 그룹으로 관리
  class_name LightManager
  extends Node

  var all_lights: Array[Light3D] = []
  var light_groups: Dictionary = {}  # {"indoor": [...], "outdoor": [...]}

  func register_light(light: Light3D, group: String = "default"):
      all_lights.append(light)
      if not light_groups.has(group):
          light_groups[group] = []
      light_groups[group].append(light)

  func set_group_enabled(group: String, enabled: bool):
      if light_groups.has(group):
          for light in light_groups[group]:
              light.visible = enabled

  func set_group_energy(group: String, energy: float, duration: float = 0.0):
      if light_groups.has(group):
          for light in light_groups[group]:
              if duration > 0:
                  var tween = create_tween()
                  tween.tween_property(light, "light_energy", energy, duration)
              else:
                  light.light_energy = energy""")

	# ============================================
	# 8. 실전: 분위기별 조명 레시피
	# ============================================
	print("\n--- 8. 분위기별 조명 레시피 ---\n")

	print("1) 밝은 야외:")
	print("   Sun: energy=1.2, color=5500K, shadow=2_SPLITS")
	print("   Ambient: SKY, energy=0.5")
	print("   Sky: 파란 하늘, 밝은 수평선")
	print("")

	print("2) 어두운 실내 (던전):")
	print("   Sun: 없음")
	print("   Ambient: COLOR(0.02, 0.02, 0.03), energy=0.1")
	print("   횃불: OmniLight3D, color=2000K, energy=2.0, range=5")
	print("   깜박임 효과 추가")
	print("")

	print("3) 네온 사이버펑크:")
	print("   Sun: 약함, energy=0.3")
	print("   Ambient: COLOR(0.05, 0.02, 0.08), energy=0.2")
	print("   네온: SpotLight3D, 다양한 색, energy=3~5")
	print("   Glow 후처리 강하게")
	print("")

	print("4) 공포:")
	print("   Sun: 없음 또는 달빛(0.05)")
	print("   Ambient: 거의 없음, energy=0.02")
	print("   손전등: SpotLight3D 1개, 좁은 각도")
	print("   갑자기 켜지는 조명으로 공포감")
	print("")

	print("5) 수중:")
	print("   Directional: color=(0.1, 0.3, 0.5), energy=0.3")
	print("   Ambient: COLOR(0.05, 0.1, 0.2), energy=0.4")
	print("   Fog 활성화, 짧은 거리")
	print("   Volumetric Fog 가능")

	# ============================================
	# 9. CameraAttributes
	# ============================================
	print("\n--- 9. CameraAttributes ---\n")

	print("CameraAttributesPractical:")
	print("  카메라의 노출, DOF(피사계 심도) 등 설정")
	print("")

	print("자동 노출 (Auto Exposure):")
	print("""  var cam_attr = CameraAttributesPractical.new()
  cam_attr.auto_exposure_enabled = true
  cam_attr.auto_exposure_min_sensitivity = 50.0
  cam_attr.auto_exposure_max_sensitivity = 800.0
  cam_attr.auto_exposure_speed = 2.0  # 적응 속도

  # WorldEnvironment에 적용
  world_env.camera_attributes = cam_attr
  # 또는 Camera3D에 직접 적용
  camera.attributes = cam_attr""")
	print("")

	print("자동 노출 효과:")
	print("  어두운 곳 -> 밝아짐 (동공 확장)")
	print("  밝은 곳 -> 어두워짐 (동공 수축)")
	print("  -> 터널에서 나올 때 눈부심 효과!")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. 3점 조명: Key + Fill + Rim으로 기본 구성")
	print("2. light_energy: 조명 강도 (1.0 = 기본)")
	print("3. 색온도: 2700K(따뜻) ~ 6500K(차가운) 분위기 결정")
	print("4. 그림자 분할: 2_SPLITS가 성능/품질 균형")
	print("5. shadow_bias: 아티팩트 방지 (0.1~0.2 권장)")
	print("6. OmniLight3D 그림자 = 6면 렌더링 -> 비쌈!")
	print("7. 낮밤 주기: time_of_day로 태양 각도+색상 보간")
	print("8. CameraAttributes: 자동 노출로 현실감 증가")


# ============================================
# 색온도 -> Color 변환 (Planckian Locus 근사)
# ============================================

func _kelvin_to_color(kelvin: int) -> Color:
	var temp := kelvin / 100.0
	var r: float
	var g: float
	var b: float

	# Red
	if temp <= 66:
		r = 1.0
	else:
		r = 1.29293618 * pow(temp - 60, -0.1332047592)
		r = clamp(r, 0.0, 1.0)

	# Green
	if temp <= 66:
		g = 0.39008157876 * log(temp) - 0.63184144378
	else:
		g = 1.12989086 * pow(temp - 60, -0.0755148492)
	g = clamp(g, 0.0, 1.0)

	# Blue
	if temp >= 66:
		b = 1.0
	elif temp <= 19:
		b = 0.0
	else:
		b = 0.54320678911 * log(temp - 10) - 1.19625408914
		b = clamp(b, 0.0, 1.0)

	return Color(r, g, b)


# ============================================
# 씬 구성
# ============================================

func _create_scene():
	# Environment
	env = Environment.new()
	env.background_mode = Environment.BG_SKY

	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.35, 0.55, 0.95)
	sky_material.sky_horizon_color = Color(0.65, 0.8, 0.95)

	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5

	# Tonemap
	env.tonemap_mode = Environment.TONE_MAP_ACES

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	# 태양
	sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_energy = 1.0
	sun.light_color = _kelvin_to_color(5500)
	sun.shadow_enabled = true
	add_child(sun)

	# 달
	moon = DirectionalLight3D.new()
	moon.name = "Moon"
	moon.rotation_degrees = Vector3(-30, -150, 0)
	moon.light_energy = 0.05
	moon.light_color = Color(0.5, 0.6, 0.8)
	moon.visible = false
	add_child(moon)

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
	fmat.albedo_color = Color(0.4, 0.45, 0.35)
	floor_mi.material_override = fmat
	floor_body.add_child(floor_mi)
	add_child(floor_body)

	# 테스트 오브젝트들 (다양한 머티리얼)
	# 금속 구
	var metal_sphere := MeshInstance3D.new()
	metal_sphere.mesh = SphereMesh.new()
	metal_sphere.position = Vector3(-3, 1, -3)
	var metal_mat := StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.8, 0.8, 0.8)
	metal_mat.metallic = 1.0
	metal_mat.roughness = 0.1
	metal_sphere.material_override = metal_mat
	add_child(metal_sphere)

	# 나무 큐브
	var wood_cube := MeshInstance3D.new()
	wood_cube.mesh = BoxMesh.new()
	wood_cube.position = Vector3(0, 0.5, -3)
	var wood_mat := StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.2)
	wood_mat.metallic = 0.0
	wood_mat.roughness = 0.8
	wood_cube.material_override = wood_mat
	add_child(wood_cube)

	# 플라스틱 원기둥
	var plastic_cyl := MeshInstance3D.new()
	plastic_cyl.mesh = CylinderMesh.new()
	plastic_cyl.position = Vector3(3, 1, -3)
	var plastic_mat := StandardMaterial3D.new()
	plastic_mat.albedo_color = Color(0.9, 0.2, 0.3)
	plastic_mat.metallic = 0.0
	plastic_mat.roughness = 0.4
	plastic_cyl.material_override = plastic_mat
	add_child(plastic_cyl)

	# 실내 조명 예시 (OmniLight3D)
	var indoor_light := OmniLight3D.new()
	indoor_light.position = Vector3(0, 3, 0)
	indoor_light.light_color = _kelvin_to_color(2700)  # 따뜻한 전구색
	indoor_light.light_energy = 1.5
	indoor_light.omni_range = 8.0
	add_child(indoor_light)

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 4, 8)
	cam.look_at(Vector3(0, 0.5, -1))
	cam.make_current()
	add_child(cam)
