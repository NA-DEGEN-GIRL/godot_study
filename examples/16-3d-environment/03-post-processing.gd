# Chapter 16 - 3D Environment
# 03-post-processing.gd - 후처리 효과 (Post-Processing)
#
# 이 파일에서 배울 내용:
# - SSAO (Screen Space Ambient Occlusion)
# - SSR (Screen Space Reflections)
# - Glow/Bloom 효과
# - Tonemap, 안개, 색조 보정

extends Node3D

# 환경 참조
var env: Environment
var world_env: WorldEnvironment

func _ready():
	print("=== 후처리 효과 (Post-Processing) ===\n")

	_create_scene()

	# ============================================
	# 1. 후처리 개요
	# ============================================
	print("--- 1. 후처리 개요 ---\n")

	print("후처리(Post-Processing)란?")
	print("  3D 씬을 렌더링한 '후에' 화면 전체에 효과를 적용")
	print("  Environment 리소스에서 대부분 설정")
	print("")

	print("Godot 4 후처리 효과 목록:")
	print("  SSAO    -> 구석/틈새를 어둡게 (깊이감)")
	print("  SSIL    -> 간접광 시뮬레이션 (색 번짐)")
	print("  SSR     -> 실시간 반사 (바닥 반사 등)")
	print("  Glow    -> 밝은 부분 발광 (블룸)")
	print("  Tonemap -> HDR을 화면에 표시 가능한 범위로")
	print("  Fog     -> 거리 기반 안개")
	print("  Vol.Fog -> 볼류메트릭 안개 (빛 줄기)")
	print("  DOF     -> 피사계 심도 (배경 흐림)")
	print("  Adjustment -> 밝기/대비/채도 보정")
	print("")

	print("성능 순서 (저렴 -> 비쌈):")
	print("  Tonemap < Adjustment < Fog < Glow < SSAO < SSR < SSIL < Vol.Fog")

	# ============================================
	# 2. Tonemap (색조 매핑)
	# ============================================
	print("\n--- 2. Tonemap ---\n")

	print("Tonemap이란?")
	print("  HDR(High Dynamic Range) 색상을")
	print("  LDR(Low Dynamic Range = 화면)으로 변환")
	print("  -> 너무 밝은 색이 자연스럽게 보이도록!")
	print("")

	env.tonemap_mode = Environment.TONE_MAP_ACES
	env.tonemap_exposure = 1.0
	env.tonemap_white = 1.0

	print("tonemap_mode 종류:")
	print("  TONE_MAP_LINEAR  -> 변환 없음 (세탁된 느낌)")
	print("  TONE_MAP_REINHARDT -> 부드러운 롤오프")
	print("  TONE_MAP_FILMIC  -> 영화 느낌")
	print("  TONE_MAP_ACES    -> 업계 표준 (권장)")
	print("")

	print("설정:")
	print("  tonemap_exposure = %.1f (노출)" % env.tonemap_exposure)
	print("    -> 높으면 밝아짐, 낮으면 어두워짐")
	print("  tonemap_white = %.1f (백색점)" % env.tonemap_white)
	print("    -> 이 값 이상의 밝기는 순백으로")
	print("")

	print("일반적으로 ACES를 사용하면 됩니다!")
	print("  가장 자연스러운 색 재현")
	print("  어두운 부분과 밝은 부분 모두 디테일 유지")

	# ============================================
	# 3. SSAO (Screen Space Ambient Occlusion)
	# ============================================
	print("\n--- 3. SSAO ---\n")

	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 2.0
	env.ssao_power = 1.5
	env.ssao_detail = 0.5
	env.ssao_light_affect = 0.0

	print("SSAO란?")
	print("  구석, 틈새, 접촉면을 어둡게 만드는 효과")
	print("  실제 간접광 없이도 깊이감과 입체감을 부여")
	print("  거의 모든 3D 게임에서 사용하는 필수 효과!")
	print("")

	print("SSAO 속성:")
	print("  ssao_enabled = true")
	print("  ssao_radius = %.1f (검사 반경, 커지면 넓은 음영)" % env.ssao_radius)
	print("  ssao_intensity = %.1f (음영 강도)" % env.ssao_intensity)
	print("  ssao_power = %.1f (음영 대비)" % env.ssao_power)
	print("  ssao_detail = %.1f (세밀한 음영)" % env.ssao_detail)
	print("  ssao_light_affect = %.1f (직접광에 영향 여부)" % env.ssao_light_affect)
	print("  ssao_sharpness = 0.98 (선명도)")
	print("")

	print("SSAO 가이드:")
	print("  부드러운 AO: radius=1.0, intensity=1.0")
	print("  강한 AO:     radius=2.0, intensity=3.0")
	print("  성능 절약:   quality를 LOW로")
	print("")

	print("SSAO 품질 (ProjectSettings):")
	print("  Rendering > Environment > SSAO >")
	print("    quality: LOW / MEDIUM / HIGH / ULTRA")
	print("    half_size: true (절반 해상도, 성능 2배)")

	# ============================================
	# 4. SSIL (Screen Space Indirect Lighting)
	# ============================================
	print("\n--- 4. SSIL ---\n")

	env.ssil_enabled = false  # 비쌈, 설명만

	print("SSIL이란?")
	print("  화면 공간 간접 조명")
	print("  빨간 벽 옆의 물체가 빨갛게 물드는 효과")
	print("  SSAO보다 한 단계 위의 사실감")
	print("")

	print("SSIL 속성:")
	print("  ssil_enabled = true")
	print("  ssil_radius = 5.0 (검사 반경)")
	print("  ssil_intensity = 1.0 (간접광 강도)")
	print("  ssil_sharpness = 0.98")
	print("  ssil_normal_rejection = 1.0")
	print("")

	print("** SSIL은 매우 비쌉니다! **")
	print("  고사양 PC에서만 사용 권장")
	print("  모바일/저사양에서는 비활성화")
	print("  VoxelGI나 SDFGI로 대체 가능")

	# ============================================
	# 5. SSR (Screen Space Reflections)
	# ============================================
	print("\n--- 5. SSR ---\n")

	env.ssr_enabled = true
	env.ssr_max_steps = 64
	env.ssr_fade_in = 0.15
	env.ssr_fade_out = 2.0
	env.ssr_depth_tolerance = 0.2

	print("SSR이란?")
	print("  실시간 화면 공간 반사")
	print("  바닥에 비치는 반사, 물 표면 반사 등")
	print("  -> 화면에 보이는 것만 반사 가능 (한계)")
	print("")

	print("SSR 속성:")
	print("  ssr_enabled = true")
	print("  ssr_max_steps = %d (레이마칭 단계, 높을수록 정확)" % env.ssr_max_steps)
	print("  ssr_fade_in = %.2f (가까운 반사 페이드인)" % env.ssr_fade_in)
	print("  ssr_fade_out = %.1f (먼 반사 페이드아웃)" % env.ssr_fade_out)
	print("  ssr_depth_tolerance = %.1f (깊이 허용 오차)" % env.ssr_depth_tolerance)
	print("")

	print("SSR 한계:")
	print("  - 화면 밖의 오브젝트는 반사 불가")
	print("  - 가장자리에서 반사가 끊김")
	print("  - 거친 표면에서는 효과 미미")
	print("  -> roughness < 0.4인 재질에서 효과적!")
	print("")

	print("SSR + ReflectionProbe 조합:")
	print("  SSR:            화면 내 실시간 반사 (동적)")
	print("  ReflectionProbe: 화면 밖 반사 보완 (캡처)")
	print("  -> 두 개를 함께 사용하면 최상의 결과!")

	# ============================================
	# 6. Glow (블룸)
	# ============================================
	print("\n--- 6. Glow (블룸) ---\n")

	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_strength = 1.0
	env.glow_bloom = 0.1
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 1.0
	env.glow_hdr_scale = 2.0

	print("Glow(Bloom)이란?")
	print("  밝은 부분이 주변으로 빛이 번지는 효과")
	print("  네온, 폭발, 마법, 태양 등의 발광 표현")
	print("  -> 시각적으로 가장 임팩트 있는 후처리!")
	print("")

	print("Glow 속성:")
	print("  glow_enabled = true")
	print("  glow_intensity = %.1f (전체 강도)" % env.glow_intensity)
	print("  glow_strength = %.1f (레벨별 강도)" % env.glow_strength)
	print("  glow_bloom = %.1f (저밝기도 글로우)" % env.glow_bloom)
	print("  glow_hdr_threshold = %.1f (이 밝기 이상이면 글로우)" % env.glow_hdr_threshold)
	print("  glow_hdr_scale = %.1f (HDR 스케일)" % env.glow_hdr_scale)
	print("")

	print("glow_blend_mode:")
	print("  ADDITIVE -> 더하기 (밝아짐, 기본)")
	print("  SCREEN   -> 스크린 (부드러운 밝아짐)")
	print("  SOFTLIGHT -> 소프트 라이트 (미묘한 글로우)")
	print("  REPLACE  -> 완전 교체 (특수 효과)")
	print("")

	# Glow 레벨 (미프맵 기반)
	print("Glow 레벨 (1~7):")
	print("  각 레벨은 다른 블러 크기")
	print("  Level 1: 매우 작은 글로우")
	print("  Level 4: 중간 글로우 (기본)")
	print("  Level 7: 매우 넓은 글로우")

	env.set_glow_level(0, true)
	env.set_glow_level(1, true)
	env.set_glow_level(2, false)
	env.set_glow_level(3, true)
	env.set_glow_level(4, false)
	env.set_glow_level(5, true)
	env.set_glow_level(6, false)

	print("  env.set_glow_level(0, true)   # 레벨 1 ON")
	print("  env.set_glow_level(3, true)   # 레벨 4 ON")
	print("  -> 여러 레벨을 조합해 글로우 형태 조절")
	print("")

	print("발광 머티리얼과 함께:")
	print("  material.emission_enabled = true")
	print("  material.emission = Color(1, 0.5, 0)")
	print("  material.emission_energy_multiplier = 5.0")
	print("  -> emission_energy가 glow_hdr_threshold보다 높으면 글로우!")

	# ============================================
	# 7. Fog (안개)
	# ============================================
	print("\n--- 7. Fog (안개) ---\n")

	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.75, 0.8)
	env.fog_light_energy = 1.0
	env.fog_density = 0.001
	env.fog_sun_scatter = 0.3

	print("Fog 속성:")
	print("  fog_enabled = true")
	print("  fog_light_color = %s (안개 색)" % str(env.fog_light_color))
	print("  fog_light_energy = %.1f (안개 밝기)" % env.fog_light_energy)
	print("  fog_density = %.4f (밀도, 높을수록 짙음)" % env.fog_density)
	print("  fog_sun_scatter = %.1f (태양 방향 산란)" % env.fog_sun_scatter)
	print("")

	print("fog_mode:")
	print("  FOG_MODE_EXPONENTIAL -> 지수적 증가 (기본)")
	print("  -> density 값으로 두께 조절")
	print("")

	print("Depth Fog (거리 안개):")
	print("  fog_depth_begin = 10.0  (안개 시작 거리)")
	print("  fog_depth_end = 100.0   (완전 안개 거리)")
	print("  fog_depth_curve = 1.0   (밀도 곡선)")
	print("")

	print("Height Fog (높이 안개):")
	print("  fog_height = 0.0          (안개 기준 높이)")
	print("  fog_height_density = 0.0  (높이 안개 밀도)")
	print("  -> 계곡에 안개가 깔리는 효과!")
	print("")

	print("분위기별 안개 설정:")
	print("  맑은 날:  density=0.0001, color=하늘색")
	print("  안개낀 날: density=0.005, color=회색")
	print("  공포:     density=0.01, color=어두운 회색")
	print("  수중:     density=0.05, color=파랑, depth_begin=1")
	print("  용암:     density=0.03, color=빨강/주황")

	# ============================================
	# 8. Volumetric Fog (볼류메트릭 안개)
	# ============================================
	print("\n--- 8. Volumetric Fog ---\n")

	env.volumetric_fog_enabled = false  # 비쌈, 설명만

	print("Volumetric Fog이란?")
	print("  3D 공간에서 빛이 안개를 통과하며 산란")
	print("  빛 줄기(God Rays) 효과!")
	print("  일반 Fog보다 훨씬 사실적이지만 비쌈")
	print("")

	print("Volumetric Fog 속성:")
	print("  volumetric_fog_enabled = true")
	print("  volumetric_fog_density = 0.05")
	print("  volumetric_fog_albedo = Color.WHITE")
	print("  volumetric_fog_emission = Color.BLACK")
	print("  volumetric_fog_emission_energy = 1.0")
	print("  volumetric_fog_anisotropy = 0.2  (빛 산란 방향)")
	print("  volumetric_fog_length = 64.0  (안개 거리)")
	print("")

	print("FogVolume 노드:")
	print("  특정 영역에만 볼류메트릭 안개 적용")
	print("""  var fog_volume = FogVolume.new()
  fog_volume.size = Vector3(10, 5, 10)
  fog_volume.material = FogMaterial.new()
  fog_volume.material.density = 0.1
  fog_volume.material.albedo = Color(0.8, 0.8, 0.9)""")
	print("  -> 특정 방, 동굴, 늪지에 안개 배치")

	# ============================================
	# 9. Adjustment (색보정)
	# ============================================
	print("\n--- 9. Adjustment (색보정) ---\n")

	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 1.1

	print("Adjustment 속성:")
	print("  adjustment_enabled = true")
	print("  adjustment_brightness = %.1f (밝기, 1.0=기본)" % env.adjustment_brightness)
	print("  adjustment_contrast = %.2f (대비, 1.0=기본)" % env.adjustment_contrast)
	print("  adjustment_saturation = %.1f (채도, 1.0=기본)" % env.adjustment_saturation)
	print("")

	print("  brightness: 0.5=어두움, 1.0=기본, 1.5=밝음")
	print("  contrast:   0.5=흐릿, 1.0=기본, 1.5=선명")
	print("  saturation: 0.0=흑백, 1.0=기본, 2.0=과채도")
	print("")

	print("Color Correction (LUT):")
	print("  adjustment_color_correction = GradientTexture1D")
	print("  -> 전문적인 색보정 (영화 색감)")
	print("  -> Photoshop/DaVinci에서 LUT 만들어 적용 가능")
	print("")

	print("분위기별 보정:")
	print("  따뜻한 느낌: brightness=1.05, saturation=1.2")
	print("  차가운 느낌: brightness=0.95, contrast=1.1, saturation=0.8")
	print("  레트로:      saturation=0.5, contrast=1.2")
	print("  흑백:        saturation=0.0")
	print("  피격 효과:   잠시 saturation=0.3, brightness=1.3")

	# ============================================
	# 10. DOF (Depth of Field / 피사계 심도)
	# ============================================
	print("\n--- 10. DOF (피사계 심도) ---\n")

	print("CameraAttributes로 설정:")
	print("""  var cam_attr = CameraAttributesPractical.new()

  # 배경 흐림 (원거리)
  cam_attr.dof_blur_far_enabled = true
  cam_attr.dof_blur_far_distance = 20.0
  cam_attr.dof_blur_far_transition = 5.0

  # 전경 흐림 (근거리)
  cam_attr.dof_blur_near_enabled = true
  cam_attr.dof_blur_near_distance = 2.0
  cam_attr.dof_blur_near_transition = 1.0

  # 흐림 강도
  cam_attr.dof_blur_amount = 0.1

  camera.attributes = cam_attr""")
	print("")

	print("DOF 활용:")
	print("  조준 시: 먼 배경 흐림 (집중 효과)")
	print("  컷씬:   인물 포커스 (영화적 연출)")
	print("  메뉴:   배경 흐림 (UI 강조)")
	print("  대화:   NPC 포커스 (주변 흐림)")

	# ============================================
	# 11. 후처리 프리셋 (실전)
	# ============================================
	print("\n--- 11. 후처리 프리셋 ---\n")

	print("1) 사실적인 야외:")
	print("   Tonemap=ACES, SSAO=ON, SSR=ON")
	print("   Glow=약하게(0.3), Fog=약간")
	print("   Adjustment: 기본")
	print("")

	print("2) 스타일리시 액션:")
	print("   Tonemap=ACES, SSAO=ON")
	print("   Glow=강하게(1.5), 블룸=0.3")
	print("   Adjustment: contrast=1.2, saturation=1.3")
	print("")

	print("3) 공포:")
	print("   Tonemap=FILMIC, SSAO=강하게")
	print("   Glow=OFF, Fog=짙게")
	print("   Adjustment: brightness=0.8, saturation=0.5")
	print("")

	print("4) 몽환적/꿈:")
	print("   Tonemap=ACES, SSIL=ON")
	print("   Glow=강하게(2.0), bloom=0.5")
	print("   Fog=가벼운 높이 안개")
	print("   Adjustment: saturation=0.7")
	print("")

	print("5) 레트로/픽셀:")
	print("   Tonemap=LINEAR")
	print("   모든 후처리 OFF")
	print("   뷰포트 해상도 낮춤 (픽셀화)")
	print("   Adjustment: contrast=1.3, saturation=0.6")

	# ============================================
	# 12. 성능 최적화
	# ============================================
	print("\n--- 12. 성능 최적화 ---\n")

	print("후처리 성능 영향 (해상도에 비례!):")
	print("  - 4K에서는 1080p 대비 4배 비용")
	print("  - half_size 옵션 활용 (SSAO, SSIL)")
	print("")

	print("최적화 옵션 (ProjectSettings):")
	print("  SSAO: half_size=true, quality=MEDIUM")
	print("  SSR:  max_steps 줄이기 (32~64)")
	print("  Glow: 기본 설정이면 충분히 저렴")
	print("  Fog:  일반 Fog는 거의 무료")
	print("  Vol.Fog: 저사양에서 비활성화")
	print("")

	print("그래픽 품질 프리셋:")
	print("""  func set_quality(level: int):
      match level:
          0:  # Low
              env.ssao_enabled = false
              env.ssr_enabled = false
              env.ssil_enabled = false
              env.glow_enabled = false
              env.volumetric_fog_enabled = false
          1:  # Medium
              env.ssao_enabled = true
              env.ssr_enabled = false
              env.glow_enabled = true
          2:  # High
              env.ssao_enabled = true
              env.ssr_enabled = true
              env.glow_enabled = true
          3:  # Ultra
              env.ssao_enabled = true
              env.ssr_enabled = true
              env.ssil_enabled = true
              env.glow_enabled = true
              env.volumetric_fog_enabled = true""")

	# ============================================
	# 13. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Tonemap ACES: 거의 모든 경우에 권장")
	print("2. SSAO: 깊이감 부여 (필수급 효과)")
	print("3. SSR: 실시간 반사 (매끈한 바닥에 효과적)")
	print("4. Glow: 밝은 부분 발광 (emission과 함께)")
	print("5. Fog: 거리 안개 (분위기 + 최적화)")
	print("6. Vol.Fog: 빛 줄기 (고사양)")
	print("7. Adjustment: 밝기/대비/채도 간편 보정")
	print("8. DOF: 피사계 심도 (CameraAttributes)")
	print("9. 그래픽 품질 프리셋으로 다양한 사양 대응")


# ============================================
# 씬 구성
# ============================================

func _create_scene():
	# Environment 설정
	env = Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.35, 0.55, 0.95)
	sky_mat.sky_horizon_color = Color(0.65, 0.8, 0.95)
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.sky = sky

	# 앰비언트
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.4

	# Tonemap
	env.tonemap_mode = Environment.TONE_MAP_ACES

	# 후처리 기본 활성화
	env.ssao_enabled = true
	env.ssao_intensity = 2.0

	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.05

	env.fog_enabled = true
	env.fog_density = 0.0005
	env.fog_light_color = Color(0.7, 0.75, 0.85)

	world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	# 태양
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)

	# 바닥 (반사 테스트용: 매끈한 바닥)
	var floor_mi := MeshInstance3D.new()
	var fmesh := PlaneMesh.new()
	fmesh.size = Vector2(30, 30)
	floor_mi.mesh = fmesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.3, 0.3, 0.35)
	floor_mat.metallic = 0.3
	floor_mat.roughness = 0.2  # 매끈 -> SSR 반사 잘 보임
	floor_mi.material_override = floor_mat
	add_child(floor_mi)

	# 바닥 물리
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(30, 0.01, 30)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	add_child(floor_body)

	# 발광 오브젝트 (Glow 테스트)
	var glow_sphere := MeshInstance3D.new()
	var gs_mesh := SphereMesh.new()
	gs_mesh.radius = 0.5
	gs_mesh.height = 1.0
	glow_sphere.mesh = gs_mesh
	glow_sphere.position = Vector3(-3, 1, -4)
	var glow_mat := StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1, 0.5, 0.1)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1, 0.5, 0.1)
	glow_mat.emission_energy_multiplier = 5.0
	glow_sphere.material_override = glow_mat
	add_child(glow_sphere)

	# 파란 발광
	var glow_sphere2 := MeshInstance3D.new()
	glow_sphere2.mesh = gs_mesh.duplicate()
	glow_sphere2.position = Vector3(3, 1, -4)
	var glow_mat2 := StandardMaterial3D.new()
	glow_mat2.albedo_color = Color(0.1, 0.4, 1.0)
	glow_mat2.emission_enabled = true
	glow_mat2.emission = Color(0.1, 0.4, 1.0)
	glow_mat2.emission_energy_multiplier = 4.0
	glow_sphere2.material_override = glow_mat2
	add_child(glow_sphere2)

	# 일반 오브젝트들 (SSAO 테스트)
	var objects := [
		{"pos": Vector3(-1, 0.5, -3), "size": Vector3(1, 1, 1), "color": Color(0.7, 0.2, 0.2)},
		{"pos": Vector3(1, 0.5, -3), "size": Vector3(1, 1, 1), "color": Color(0.2, 0.7, 0.3)},
		{"pos": Vector3(0, 0.5, -5), "size": Vector3(2, 1, 0.2), "color": Color(0.5, 0.5, 0.6)},
		{"pos": Vector3(0, 1.5, -5), "size": Vector3(2, 1, 0.2), "color": Color(0.5, 0.5, 0.6)},
	]

	for obj in objects:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = obj["size"]
		mi.mesh = mesh
		mi.position = obj["pos"]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = obj["color"]
		mat.metallic = 0.1
		mat.roughness = 0.6
		mi.material_override = mat
		add_child(mi)

	# 금속 구 (SSR 반사 테스트)
	var metal_ball := MeshInstance3D.new()
	metal_ball.mesh = SphereMesh.new()
	metal_ball.position = Vector3(0, 1, -2)
	var metal_mat := StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.9, 0.9, 0.9)
	metal_mat.metallic = 1.0
	metal_mat.roughness = 0.05
	metal_ball.material_override = metal_mat
	add_child(metal_ball)

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 3, 6)
	cam.look_at(Vector3(0, 0.5, -2))
	cam.fov = 70.0
	cam.make_current()
	add_child(cam)
