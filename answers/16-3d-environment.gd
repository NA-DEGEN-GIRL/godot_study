# 챕터 16: 3D 환경 설정 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - WorldEnvironment 노드와 Environment 리소스
# - 하늘(Sky) 설정 (ProceduralSkyMaterial, PhysicalSkyMaterial)
# - 환경 조명 (Ambient Light, Reflection Probe)
# - 안개(Fog) 효과 (Volumetric Fog, Depth Fog)
# - 후처리 효과 (Glow, Tonemap, SSAO, SSR, DOF)

extends Node3D


func _ready():
	print("=== 챕터 16: 3D 환경 설정 ===\n")

	# 연습 1: WorldEnvironment 기본 설정
	_exercise_1_world_environment()

	# 연습 2: 하늘 (Sky) 설정
	_exercise_2_sky_setup()

	# 연습 3: 환경 조명
	_exercise_3_ambient_lighting()

	# 연습 4: 안개 효과
	_exercise_4_fog_effects()

	# 연습 5: 후처리 효과
	_exercise_5_post_processing()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: WorldEnvironment + Environment 리소스 생성 완료")
	print("결과 2: ProceduralSkyMaterial + PhysicalSkyMaterial 설정 완료")
	print("결과 3: 환경 조명 (Ambient + Reflection) 설정 완료")
	print("결과 4: 안개 (Volumetric + Depth + Height) 효과 설정 완료")
	print("결과 5: 후처리 (Glow, Tonemap, SSAO, SSR, DOF) 설정 완료")


# ==============================================================================
# 연습 1: WorldEnvironment - 3D 씬의 전체 환경을 제어하는
#          WorldEnvironment 노드와 Environment 리소스를 설정하세요.
# ==============================================================================
func _exercise_1_world_environment():
	# 풀이: WorldEnvironment는 3D 씬의 전체 환경(하늘, 안개, 후처리 등)을 정의합니다.
	#       Environment 리소스를 생성하여 환경 속성을 설정합니다.
	#       씬에 하나만 존재해야 하며, Camera3D의 environment 속성으로 카메라별로
	#       오버라이드할 수 있습니다.

	print("연습 1: WorldEnvironment 기본 설정")

	# WorldEnvironment 노드 생성
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	# Environment 리소스 생성
	var env := Environment.new()
	world_env.environment = env

	add_child(world_env)

	print("  WorldEnvironment 노드 생성 완료")
	print("  Environment 리소스 할당 완료")
	print()

	# 배경 모드
	# 풀이: background_mode는 3D 씬의 배경 렌더링 방식을 결정합니다.
	env.background_mode = Environment.BG_SKY  # 하늘
	print("  배경 모드 (background_mode):")
	print("    BG_CLEAR_COLOR: 단색 배경 (프로젝트 설정 색상)")
	print("    BG_COLOR: 사용자 지정 단색")
	print("    BG_SKY: 하늘 (Sky 리소스)")
	print("    BG_CANVAS: 2D 캔버스를 배경으로 (2D-in-3D)")
	print("    BG_KEEP: 이전 프레임 유지")
	print("    BG_CAMERA_FEED: 카메라 피드 (AR)")
	print("    현재: BG_SKY")
	print()

	# 배경 색상 모드
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.1, 0.15)
	print("  단색 배경 예시:")
	print("    background_mode: BG_COLOR")
	print("    background_color: %s (어두운 남색)" % env.background_color)
	print()

	# 다시 하늘로 전환
	env.background_mode = Environment.BG_SKY
	print("  -> 하늘 모드(BG_SKY)로 전환")

	# Camera3D 환경 오버라이드
	print()
	print("  카메라별 환경 오버라이드:")
	print("    Camera3D.environment = custom_env")
	print("    -> 해당 카메라에만 다른 환경 적용")
	print("    -> WorldEnvironment보다 우선순위 높음")

	print("연습 1 완료: WorldEnvironment\n")


# ==============================================================================
# 연습 2: Sky - 절차적 하늘과 물리 기반 하늘을 설정하세요.
# ==============================================================================
func _exercise_2_sky_setup():
	# 풀이: Sky 리소스는 3D 배경의 하늘을 정의합니다.
	#       ProceduralSkyMaterial: 간단한 색상 기반 하늘 (성능 좋음)
	#       PhysicalSkyMaterial: 물리 기반 대기 산란 하늘 (사실적)
	#       PanoramaSkyMaterial: HDR 파노라마 텍스처 하늘 (사진 기반)
	#       ShaderMaterial: 커스텀 셰이더로 만든 하늘

	print("연습 2: 하늘 (Sky) 설정")

	# ProceduralSkyMaterial - 절차적 하늘
	var proc_sky_mat := ProceduralSkyMaterial.new()
	proc_sky_mat.sky_top_color = Color(0.3, 0.5, 0.9)       # 하늘 상단 (진한 파랑)
	proc_sky_mat.sky_horizon_color = Color(0.65, 0.75, 0.9)  # 수평선 (연한 파랑)
	proc_sky_mat.ground_bottom_color = Color(0.15, 0.12, 0.1) # 지면 하단
	proc_sky_mat.ground_horizon_color = Color(0.5, 0.45, 0.4) # 지면 수평선
	proc_sky_mat.sky_curve = 0.15          # 하늘 색상 전환 곡선
	proc_sky_mat.ground_curve = 0.02       # 지면 색상 전환 곡선
	proc_sky_mat.sun_angle_max = 30.0      # 태양 글로우 크기 (도)
	proc_sky_mat.sun_curve = 0.15          # 태양 글로우 곡선

	var sky := Sky.new()
	sky.sky_material = proc_sky_mat
	sky.radiance_size = Sky.RADIANCE_SIZE_256  # 반사용 라디언스 맵 크기

	# Environment에 할당
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky

	var world_env := WorldEnvironment.new()
	world_env.name = "SkyDemo"
	world_env.environment = env
	add_child(world_env)

	print("  ProceduralSkyMaterial:")
	print("    sky_top_color: %s (하늘 상단)" % proc_sky_mat.sky_top_color)
	print("    sky_horizon_color: %s (수평선)" % proc_sky_mat.sky_horizon_color)
	print("    ground_bottom_color: %s (지면 하단)" % proc_sky_mat.ground_bottom_color)
	print("    sky_curve: %.2f (색상 전환)" % proc_sky_mat.sky_curve)
	print("    sun_angle_max: %.0f도 (태양 크기)" % proc_sky_mat.sun_angle_max)
	print()

	# PhysicalSkyMaterial - 물리 기반 하늘
	# 풀이: 레일리/미 산란을 시뮬레이션하여 사실적인 대기를 표현합니다.
	#       DirectionalLight3D의 방향이 태양 위치를 결정합니다.
	var phys_sky_mat := PhysicalSkyMaterial.new()
	phys_sky_mat.rayleigh_coefficient = 2.0     # 레일리 산란 (파란 하늘)
	phys_sky_mat.mie_coefficient = 0.005        # 미 산란 (해질녘 붉은 빛)
	phys_sky_mat.mie_eccentricity = 0.8         # 미 산란 방향성
	phys_sky_mat.turbidity = 10.0               # 대기 탁도
	phys_sky_mat.sun_disk_scale = 1.0           # 태양 원반 크기
	phys_sky_mat.ground_color = Color(0.1, 0.07, 0.034) # 지면 반사

	print("  PhysicalSkyMaterial:")
	print("    rayleigh_coefficient: %.1f (레일리 산란 - 파란 하늘)" % phys_sky_mat.rayleigh_coefficient)
	print("    mie_coefficient: %.3f (미 산란 - 석양)" % phys_sky_mat.mie_coefficient)
	print("    mie_eccentricity: %.1f (미 산란 방향성)" % phys_sky_mat.mie_eccentricity)
	print("    turbidity: %.1f (대기 탁도)" % phys_sky_mat.turbidity)
	print("    sun_disk_scale: %.1f (태양 크기)" % phys_sky_mat.sun_disk_scale)
	print()

	# 시간대별 하늘 프리셋
	print("  시간대별 하늘 프리셋 (DirectionalLight3D rotation.x):")
	print("    -90도: 정오 (태양 바로 위)")
	print("    -45도: 오후 (비스듬한 햇살)")
	print("    -10도: 석양 (붉은 하늘)")
	print("    0도: 수평선 (일출/일몰)")
	print("    30도: 밤 (태양 아래)")
	print()

	# Sky 리소스 크기
	print("  Sky radiance_size:")
	print("    RADIANCE_SIZE_32: 매우 낮은 품질 (모바일)")
	print("    RADIANCE_SIZE_256: 기본 품질")
	print("    RADIANCE_SIZE_1024: 높은 품질")
	print("    RADIANCE_SIZE_2048: 매우 높은 품질")

	print("연습 2 완료: 하늘 설정\n")


# ==============================================================================
# 연습 3: 환경 조명 - Ambient Light와 Reflection Probe를 설정하세요.
# ==============================================================================
func _exercise_3_ambient_lighting():
	# 풀이: 환경 조명은 직접광이 닿지 않는 영역을 밝히는 간접광입니다.
	#       ambient_light_source: 간접광 소스 (하늘, 단색, 비활성)
	#       ambient_light_color/energy: 간접광 색상과 강도
	#       reflected_light_source: 반사광 소스
	#       ReflectionProbe: 특정 영역의 환경 반사를 캡처합니다.

	print("연습 3: 환경 조명")

	var env := Environment.new()

	# Ambient Light (간접광) 설정
	# 풀이: ambient_light_source는 그늘진 영역의 기본 밝기를 결정합니다.
	#       BG_SKY를 사용하면 하늘 색상이 간접광으로 사용됩니다.
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5       # 간접광 강도
	env.ambient_light_sky_contribution = 1.0  # 하늘 기여도

	print("  Ambient Light (간접광):")
	print("    source: AMBIENT_SOURCE_SKY (하늘에서 간접광)")
	print("    energy: %.1f" % env.ambient_light_energy)
	print("    sky_contribution: %.1f" % env.ambient_light_sky_contribution)
	print()

	# 단색 Ambient Light
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.2, 0.3)  # 차가운 간접광
	env.ambient_light_energy = 0.3

	print("  단색 Ambient Light:")
	print("    source: AMBIENT_SOURCE_COLOR")
	print("    color: %s (차가운 톤)" % env.ambient_light_color)
	print("    energy: %.1f" % env.ambient_light_energy)
	print()

	# Ambient Light 소스 비교
	print("  Ambient Light 소스:")
	print("    AMBIENT_SOURCE_BG: 배경에서 자동 (하늘/색상)")
	print("    AMBIENT_SOURCE_SKY: 하늘에서만")
	print("    AMBIENT_SOURCE_COLOR: 사용자 지정 단색")
	print("    AMBIENT_SOURCE_DISABLED: 비활성 (완전히 어두움)")
	print()

	# Reflected Light (반사광)
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	print("  Reflected Light (반사광):")
	print("    source: REFLECTION_SOURCE_SKY (하늘 반사)")
	print("    REFLECTION_SOURCE_BG: 배경에서 반사")
	print("    REFLECTION_SOURCE_DISABLED: 반사 없음")
	print()

	# ReflectionProbe 생성
	# 풀이: ReflectionProbe는 특정 영역에서 환경을 캡처하여
	#       해당 영역의 오브젝트에 사실적인 반사를 적용합니다.
	var probe := ReflectionProbe.new()
	probe.name = "RoomReflection"
	probe.size = Vector3(10, 5, 10)         # 캡처 영역 크기
	probe.origin_offset = Vector3(0, 0, 0)  # 캡처 중심 오프셋
	probe.intensity = 1.0                   # 반사 강도
	probe.interior = false                  # 실내 모드 (true면 하늘 제거)
	probe.max_distance = 50.0               # 최대 렌더 거리
	probe.update_mode = ReflectionProbe.UPDATE_ONCE  # 한 번만 캡처
	add_child(probe)

	print("  ReflectionProbe:")
	print("    size: %s (캡처 영역)" % probe.size)
	print("    intensity: %.1f" % probe.intensity)
	print("    interior: %s (실내 모드)" % probe.interior)
	print("    update_mode: UPDATE_ONCE (한 번 캡처)")
	print("    UPDATE_ALWAYS: 매 프레임 (성능 비용 높음)")

	print("연습 3 완료: 환경 조명\n")


# ==============================================================================
# 연습 4: 안개 효과 - Volumetric Fog, Depth Fog, Height Fog를
#          설정하세요.
# ==============================================================================
func _exercise_4_fog_effects():
	# 풀이: 안개는 분위기 연출과 원거리 오브젝트를 자연스럽게 숨기는 데 사용합니다.
	#       Godot 4에서는 Environment의 fog 속성과 volumetric_fog 속성을 사용합니다.
	#       fog: 전통적 깊이/높이 안개 (가벼움)
	#       volumetric_fog: 볼류메트릭 안개 (빛 산란, 무거움)

	print("연습 4: 안개 효과")

	var env := Environment.new()

	# Depth Fog (깊이 안개)
	# 풀이: 카메라로부터 거리에 따라 안개가 짙어집니다.
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.75, 0.8)  # 회백색 안개
	env.fog_light_energy = 1.0
	env.fog_sun_scatter = 0.2            # 태양 방향 산란
	env.fog_density = 0.01               # 안개 밀도 (0~1, 낮을수록 투명)

	print("  Depth Fog (깊이 안개):")
	print("    fog_enabled: %s" % env.fog_enabled)
	print("    light_color: %s" % env.fog_light_color)
	print("    light_energy: %.1f" % env.fog_light_energy)
	print("    sun_scatter: %.1f (태양 빛 산란)" % env.fog_sun_scatter)
	print("    density: %.3f" % env.fog_density)
	print()

	# Height Fog (높이 안개)
	# 풀이: 높이에 따라 안개 밀도가 변합니다. 계곡이나 저지대에 안개가 깔리는 효과.
	env.fog_aerial_perspective = 0.5     # 대기 원근감 (먼 물체가 안개빛)
	env.fog_sky_affect = 0.3             # 하늘에 안개 적용 정도

	print("  Height Fog 관련:")
	print("    aerial_perspective: %.1f (대기 원근감)" % env.fog_aerial_perspective)
	print("    sky_affect: %.1f (하늘 안개 적용)" % env.fog_sky_affect)
	print()

	# Volumetric Fog (볼류메트릭 안개)
	# 풀이: 빛이 안개를 통과하면서 산란하는 효과를 시뮬레이션합니다.
	#       God ray(신의 빛) 효과를 자연스럽게 만들 수 있습니다.
	#       성능 비용이 높으므로 모바일에서는 사용을 피합니다.
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.05           # 볼류메트릭 밀도
	env.volumetric_fog_albedo = Color(0.9, 0.9, 0.95)  # 안개 색상
	env.volumetric_fog_emission = Color(0.0, 0.0, 0.0)  # 자체 발광
	env.volumetric_fog_emission_energy = 0.0
	env.volumetric_fog_anisotropy = 0.6         # 빛 산란 방향성 (0=등방, 1=전방)
	env.volumetric_fog_length = 64.0            # 안개 렌더 거리
	env.volumetric_fog_detail_spread = 2.0      # 디테일 확산

	print("  Volumetric Fog (볼류메트릭 안개):")
	print("    enabled: %s" % env.volumetric_fog_enabled)
	print("    density: %.2f" % env.volumetric_fog_density)
	print("    albedo: %s (안개 색상)" % env.volumetric_fog_albedo)
	print("    anisotropy: %.1f (빛 산란 방향, 0=등방)" % env.volumetric_fog_anisotropy)
	print("    length: %.0f m (렌더 거리)" % env.volumetric_fog_length)
	print()

	# FogVolume (국소 안개)
	# 풀이: FogVolume 노드는 특정 영역에만 볼류메트릭 안개를 배치합니다.
	var fog_volume := FogVolume.new()
	fog_volume.name = "LocalFog"
	fog_volume.size = Vector3(5, 2, 5)
	fog_volume.position = Vector3(0, 1, -5)

	var fog_mat := FogMaterial.new()
	fog_mat.density = 0.5
	fog_mat.albedo = Color(0.8, 0.85, 0.9)
	fog_volume.material = fog_mat
	add_child(fog_volume)

	print("  FogVolume (국소 안개):")
	print("    size: %s" % fog_volume.size)
	print("    position: %s" % fog_volume.position)
	print("    density: %.1f" % fog_mat.density)
	print("    albedo: %s" % fog_mat.albedo)
	print()

	# 안개 프리셋 비교
	print("  안개 프리셋 예시:")
	print("    +-------------+--------+--------+-------+----------+")
	print("    | 분위기      | 밀도   | 색상   | 높이  | 볼류메트릭|")
	print("    +-------------+--------+--------+-------+----------+")
	print("    | 맑은 날     | 0.001  | 흰색   | -     | OFF      |")
	print("    | 흐린 아침   | 0.01   | 연회색 | O     | OFF      |")
	print("    | 짙은 안개   | 0.05   | 회색   | O     | ON       |")
	print("    | 공포 분위기 | 0.03   | 녹색   | O     | ON       |")
	print("    | God Ray     | 0.02   | 흰색   | -     | ON(0.8)  |")
	print("    +-------------+--------+--------+-------+----------+")

	print("연습 4 완료: 안개 효과\n")


# ==============================================================================
# 연습 5: 후처리 효과 - Glow, Tonemap, SSAO, SSR, DOF를
#          설정하세요.
# ==============================================================================
func _exercise_5_post_processing():
	# 풀이: 후처리(Post-Processing)는 최종 렌더링된 이미지에 시각 효과를 적용합니다.
	#       Environment 리소스에서 대부분의 후처리 설정을 제어합니다.
	#       성능 영향이 크므로 타겟 플랫폼에 맞게 조절해야 합니다.

	print("연습 5: 후처리 효과")

	var env := Environment.new()

	# 1) Glow (블룸) - 밝은 영역이 빛나는 효과
	# 풀이: HDR 렌더링에서 밝기 임계값을 초과한 픽셀이 주변으로 번지는 효과입니다.
	env.glow_enabled = true
	env.glow_intensity = 0.8         # 글로우 강도
	env.glow_strength = 1.0          # 글로우 세기
	env.glow_bloom = 0.3             # 블룸 양 (0=없음, 1=최대)
	env.glow_hdr_threshold = 1.0     # HDR 밝기 임계값
	env.glow_hdr_scale = 2.0         # HDR 스케일
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE

	print("  1) Glow (블룸):")
	print("    enabled: %s" % env.glow_enabled)
	print("    intensity: %.1f (전체 강도)" % env.glow_intensity)
	print("    bloom: %.1f (번짐 양)" % env.glow_bloom)
	print("    hdr_threshold: %.1f (임계값, 이 이상이 빛남)" % env.glow_hdr_threshold)
	print("    blend_mode: ADDITIVE")
	print()

	# 2) Tonemap - HDR을 LDR로 변환하는 색조 매핑
	# 풀이: 톤맵은 HDR(높은 다이내믹 레인지) 렌더링 결과를
	#       모니터가 표시할 수 있는 LDR로 변환합니다.
	env.tonemap_mode = Environment.TONE_MAP_FILMIC  # 영화풍
	env.tonemap_exposure = 1.0           # 노출 (밝기)
	env.tonemap_white = 1.0              # 화이트 포인트

	print("  2) Tonemap (색조 매핑):")
	print("    mode: TONE_MAP_FILMIC (영화풍, 부드러운 하이라이트)")
	print("    exposure: %.1f (노출)" % env.tonemap_exposure)
	print("    white: %.1f (화이트 포인트)" % env.tonemap_white)
	print()
	print("    톤맵 모드 비교:")
	print("    LINEAR: 변환 없음 (밝은 영역 클리핑)")
	print("    REINHARDT: 부드러운 롤오프")
	print("    FILMIC: 영화풍 (권장)")
	print("    ACES: 영화 산업 표준 (가장 사실적)")
	print()

	# 3) SSAO (Screen Space Ambient Occlusion) - 화면 공간 주변 차폐
	# 풀이: 모서리와 틈새에 자연스러운 그림자를 추가합니다.
	env.ssao_enabled = true
	env.ssao_radius = 1.0                # 검사 반경 (미터)
	env.ssao_intensity = 2.0             # 차폐 강도
	env.ssao_power = 1.5                 # 감쇠 곡선
	env.ssao_detail = 0.5                # 세밀한 디테일
	env.ssao_light_affect = 0.0          # 직접광 영향 (0=간접광만)

	print("  3) SSAO (주변 차폐):")
	print("    enabled: %s" % env.ssao_enabled)
	print("    radius: %.1f m (검사 반경)" % env.ssao_radius)
	print("    intensity: %.1f (차폐 강도)" % env.ssao_intensity)
	print("    detail: %.1f (세밀함)" % env.ssao_detail)
	print("    light_affect: %.1f (직접광 영향)" % env.ssao_light_affect)
	print()

	# 4) SSR (Screen Space Reflections) - 화면 공간 반사
	# 풀이: 화면에 보이는 오브젝트만으로 반사를 계산합니다.
	#       바닥 반사, 물 반사 등에 사용합니다.
	env.ssr_enabled = true
	env.ssr_max_steps = 64               # 반사 검색 단계 수
	env.ssr_fade_in = 0.15               # 페이드 인 거리
	env.ssr_fade_out = 2.0               # 페이드 아웃 거리
	env.ssr_depth_tolerance = 0.2        # 깊이 허용 오차

	print("  4) SSR (화면 공간 반사):")
	print("    enabled: %s" % env.ssr_enabled)
	print("    max_steps: %d (검색 단계)" % env.ssr_max_steps)
	print("    fade_in: %.2f" % env.ssr_fade_in)
	print("    fade_out: %.1f" % env.ssr_fade_out)
	print("    depth_tolerance: %.1f" % env.ssr_depth_tolerance)
	print()

	# 5) DOF (Depth of Field) - 피사계 심도 (배경 흐림)
	# 풀이: 카메라의 초점 거리에 따라 배경이나 전경을 흐리게 합니다.
	#       영화적 연출이나 미니어처 효과에 사용합니다.
	print("  5) DOF (피사계 심도):")
	print("    Camera3D의 속성으로 설정:")
	print("    ```gdscript")
	print("    camera.attributes = CameraAttributesPractical.new()")
	print("    var attr = camera.attributes as CameraAttributesPractical")
	print("")
	print("    # 원거리 흐림 (배경 보케)")
	print("    attr.dof_blur_far_enabled = true")
	print("    attr.dof_blur_far_distance = 10.0  # 시작 거리")
	print("    attr.dof_blur_far_transition = 5.0 # 전환 거리")
	print("")
	print("    # 근거리 흐림 (전경 흐림)")
	print("    attr.dof_blur_near_enabled = true")
	print("    attr.dof_blur_near_distance = 1.0  # 시작 거리")
	print("    attr.dof_blur_near_transition = 1.0")
	print("")
	print("    attr.dof_blur_amount = 0.1  # 흐림 강도")
	print("    ```")
	print()

	# 후처리 성능 비용 순위
	print("  후처리 성능 비용 (낮음 -> 높음):")
	print("    1. Tonemap: 거의 무료")
	print("    2. Adjustments (밝기/대비/채도): 가벼움")
	print("    3. Glow: 보통")
	print("    4. SSAO: 높음")
	print("    5. SSR: 매우 높음")
	print("    6. SDFGI: 매우 높음")
	print("    7. Volumetric Fog: 높음")

	print("연습 5 완료: 후처리 효과\n")
