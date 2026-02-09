# 챕터 16: 3D 환경 설정
#
# 이 챕터에서는 다음을 학습합니다:
# - WorldEnvironment 노드와 Environment 리소스
# - 하늘(Sky) 설정과 ProceduralSkyMaterial
# - 조명 설정 (DirectionalLight3D, 앰비언트 라이트)
# - 안개(Fog) 효과 설정
# - 후처리 효과 (Glow, SSAO, Tonemap 등)

extends Node3D


# ============================================================
# 연습 1: WorldEnvironment 설정
# ============================================================
# WorldEnvironment는 3D 씬의 전체적인 분위기를 결정합니다.
# Environment 리소스를 통해 배경, 조명, 후처리 등을 설정합니다.

func create_world_environment_config(preset: String) -> Dictionary:
	# TODO: 환경 프리셋별 WorldEnvironment 설정을 반환하세요
	# preset: "outdoor_day", "outdoor_night", "indoor", "underwater"
	#
	# 반환 형식:
	# {
	#   "node_type": "WorldEnvironment",
	#   "preset": preset,
	#   "environment": {
	#     "background_mode": 배경 모드 문자열,
	#     "background_color": 배경 색상 (sky가 아닐 때),
	#     "ambient_light_source": 앰비언트 광원 문자열,
	#     "ambient_light_color": 앰비언트 라이트 색상,
	#     "ambient_light_energy": 앰비언트 라이트 강도,
	#     "tonemap_mode": 톤맵 모드 문자열,
	#     "tonemap_exposure": 노출 값
	#   }
	# }
	#
	# 프리셋별 설정:
	# - "outdoor_day":
	#   background_mode: "sky"
	#   ambient_light_source: "sky"
	#   ambient_light_color: Color(0.7, 0.75, 0.85)
	#   ambient_light_energy: 0.5
	#   tonemap_mode: "filmic"
	#   tonemap_exposure: 1.0
	#
	# - "outdoor_night":
	#   background_mode: "sky"
	#   ambient_light_source: "sky"
	#   ambient_light_color: Color(0.05, 0.05, 0.15)
	#   ambient_light_energy: 0.1
	#   tonemap_mode: "filmic"
	#   tonemap_exposure: 0.5
	#
	# - "indoor":
	#   background_mode: "color"
	#   background_color: Color(0.1, 0.1, 0.1)
	#   ambient_light_source: "color"
	#   ambient_light_color: Color(0.3, 0.28, 0.25)
	#   ambient_light_energy: 0.3
	#   tonemap_mode: "aces"
	#   tonemap_exposure: 1.0
	#
	# - "underwater":
	#   background_mode: "color"
	#   background_color: Color(0.0, 0.15, 0.3)
	#   ambient_light_source: "color"
	#   ambient_light_color: Color(0.1, 0.3, 0.5)
	#   ambient_light_energy: 0.4
	#   tonemap_mode: "filmic"
	#   tonemap_exposure: 0.8
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 2: Sky 생성
# ============================================================
# ProceduralSkyMaterial로 절차적 하늘을 생성합니다.
# 해/달의 위치, 하늘 색상, 구름 등을 코드로 설정할 수 있습니다.

func create_sky_config(time_of_day: float) -> Dictionary:
	# TODO: 하루 시간(0.0~24.0)에 따른 하늘 설정을 반환하세요
	# time_of_day: 0.0=자정, 6.0=일출, 12.0=정오, 18.0=일몰, 24.0=자정
	#
	# 1. 태양 각도 계산:
	#    sun_angle = ((time_of_day - 6.0) / 12.0) * 180.0 - 90.0
	#    (6시에 수평선, 12시에 최고점, 18시에 수평선)
	#    sun_angle를 -90 ~ 90 범위로 클램프
	#
	# 2. 시간대별 하늘 색상:
	#    - 밤 (time_of_day < 5 or time_of_day > 20):
	#      sky_top: Color(0.01, 0.01, 0.05)
	#      sky_horizon: Color(0.02, 0.02, 0.08)
	#      ground_horizon: Color(0.02, 0.02, 0.05)
	#      sun_energy: 0.0
	#
	#    - 일출/일몰 (5 <= time_of_day < 7 or 17 < time_of_day <= 20):
	#      sky_top: Color(0.2, 0.15, 0.3)
	#      sky_horizon: Color(0.9, 0.5, 0.2)
	#      ground_horizon: Color(0.4, 0.25, 0.15)
	#      sun_energy: 0.5
	#
	#    - 낮 (7 <= time_of_day <= 17):
	#      sky_top: Color(0.3, 0.5, 0.85)
	#      sky_horizon: Color(0.55, 0.7, 0.9)
	#      ground_horizon: Color(0.35, 0.4, 0.35)
	#      sun_energy: 1.0
	#
	# 반환 형식:
	# {
	#   "sky_material": "ProceduralSkyMaterial",
	#   "time_of_day": time_of_day,
	#   "sun_angle_degrees": sun_angle,
	#   "sky_top_color": ...,
	#   "sky_horizon_color": ...,
	#   "ground_horizon_color": ...,
	#   "sun_energy": ...,
	#   "is_daytime": 7 <= time_of_day <= 17,
	#   "is_night": time_of_day < 5 or time_of_day > 20,
	#   "period": "night" / "dawn_dusk" / "day"
	# }
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 3: 조명 설정
# ============================================================
# 3D 씬의 조명은 분위기를 결정짓는 핵심 요소입니다.
# 주광(key), 보조광(fill), 역광(rim)의 3점 조명이 기본입니다.

func create_three_point_lighting(scene_type: String) -> Dictionary:
	# TODO: 3점 조명 설정을 Dictionary로 반환하세요
	# scene_type: "standard", "dramatic", "soft"
	#
	# 반환 형식:
	# {
	#   "scene_type": scene_type,
	#   "key_light": {
	#     "type": "DirectionalLight3D",
	#     "rotation_degrees": ...,
	#     "color": ...,
	#     "energy": ...,
	#     "shadow_enabled": true
	#   },
	#   "fill_light": {
	#     "type": "DirectionalLight3D",
	#     "rotation_degrees": ...,
	#     "color": ...,
	#     "energy": ...,
	#     "shadow_enabled": false
	#   },
	#   "rim_light": {
	#     "type": "DirectionalLight3D",
	#     "rotation_degrees": ...,
	#     "color": ...,
	#     "energy": ...,
	#     "shadow_enabled": false
	#   }
	# }
	#
	# "standard" (일반):
	#   key: rotation(-45, -45, 0), color(1, 0.95, 0.9), energy 1.0
	#   fill: rotation(-30, 45, 0), color(0.6, 0.7, 0.85), energy 0.3
	#   rim: rotation(-20, 180, 0), color(0.9, 0.9, 1.0), energy 0.4
	#
	# "dramatic" (극적):
	#   key: rotation(-60, -30, 0), color(1.0, 0.85, 0.7), energy 1.5
	#   fill: rotation(-20, 60, 0), color(0.3, 0.3, 0.5), energy 0.1
	#   rim: rotation(-10, 170, 0), color(1.0, 0.9, 0.8), energy 0.8
	#
	# "soft" (부드러운):
	#   key: rotation(-40, -40, 0), color(0.95, 0.95, 1.0), energy 0.7
	#   fill: rotation(-35, 50, 0), color(0.7, 0.75, 0.85), energy 0.5
	#   rim: rotation(-25, 175, 0), color(0.85, 0.85, 0.9), energy 0.3
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 4: 안개 설정
# ============================================================
# 안개(Fog)는 깊이감과 분위기를 더합니다.
# Volumetric Fog와 일반 Depth Fog를 설정할 수 있습니다.

func create_fog_config(fog_type: String, density: float) -> Dictionary:
	# TODO: 안개 유형별 설정을 Dictionary로 반환하세요
	# fog_type: "depth", "height", "volumetric"
	# density: 안개 밀도 (0.0 ~ 1.0)
	#
	# density를 0.0 ~ 1.0 범위로 클램프하세요
	#
	# 반환 형식:
	# {
	#   "fog_enabled": true,
	#   "fog_type": fog_type,
	#   "density": 클램프된 density,
	#   "properties": 유형별 속성
	# }
	#
	# "depth" (깊이 기반 안개):
	# properties:
	# {
	#   "fog_light_color": Color(0.7, 0.75, 0.8),
	#   "fog_light_energy": 1.0,
	#   "fog_sun_scatter": 0.5,
	#   "fog_density": density * 0.01,
	#   "fog_aerial_perspective": 0.5,
	#   "fog_sky_affect": 0.5
	# }
	#
	# "height" (높이 기반 안개):
	# properties:
	# {
	#   "fog_light_color": Color(0.8, 0.85, 0.9),
	#   "fog_light_energy": 1.0,
	#   "fog_density": density * 0.005,
	#   "fog_height": 0.0,
	#   "fog_height_density": density * 0.1,
	#   "fog_aerial_perspective": 0.3
	# }
	#
	# "volumetric" (볼류메트릭 안개):
	# properties:
	# {
	#   "volumetric_fog_enabled": true,
	#   "volumetric_fog_density": density * 0.05,
	#   "volumetric_fog_albedo": Color(0.9, 0.9, 0.95),
	#   "volumetric_fog_emission": Color(0.0, 0.0, 0.0),
	#   "volumetric_fog_emission_energy": 0.0,
	#   "volumetric_fog_gi_inject": 1.0,
	#   "volumetric_fog_length": 200.0,
	#   "volumetric_fog_anisotropy": 0.2
	# }
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 5: 후처리 효과 (Glow, SSAO)
# ============================================================
# 후처리(Post-Processing)는 최종 렌더링에 시각적 효과를 추가합니다.
# Environment 리소스에서 Glow, SSAO, SSR, SDFGI 등을 설정합니다.

func create_post_processing_config(quality: String) -> Dictionary:
	# TODO: 후처리 품질별 설정을 Dictionary로 반환하세요
	# quality: "low", "medium", "high"
	#
	# 반환 형식:
	# {
	#   "quality_preset": quality,
	#   "glow": {
	#     "enabled": true,
	#     "intensity": ...,
	#     "strength": ...,
	#     "bloom": ...,
	#     "blend_mode": ...,
	#     "hdr_threshold": ...,
	#     "levels": 활성화할 레벨 수
	#   },
	#   "ssao": {
	#     "enabled": ...,
	#     "radius": ...,
	#     "intensity": ...,
	#     "power": ...,
	#     "detail": ...,
	#     "horizon": ...,
	#     "light_affect": ...
	#   },
	#   "ssr": {
	#     "enabled": ...,
	#     "max_steps": ...,
	#     "fade_in": ...,
	#     "fade_out": ...,
	#     "depth_tolerance": ...
	#   },
	#   "ssil": {
	#     "enabled": ...,
	#     "radius": ...,
	#     "intensity": ...,
	#     "normal_rejection": ...
	#   }
	# }
	#
	# "low":
	#   glow: enabled true, intensity 0.5, strength 0.8, bloom 0.1,
	#         blend_mode "additive", hdr_threshold 1.2, levels 3
	#   ssao: enabled false
	#   ssr: enabled false
	#   ssil: enabled false
	#
	# "medium":
	#   glow: enabled true, intensity 0.8, strength 1.0, bloom 0.2,
	#         blend_mode "softlight", hdr_threshold 1.0, levels 5
	#   ssao: enabled true, radius 1.0, intensity 2.0, power 1.5,
	#         detail 0.5, horizon 0.06, light_affect 0.0
	#   ssr: enabled false
	#   ssil: enabled false
	#
	# "high":
	#   glow: enabled true, intensity 1.0, strength 1.2, bloom 0.3,
	#         blend_mode "softlight", hdr_threshold 0.8, levels 7
	#   ssao: enabled true, radius 2.0, intensity 3.0, power 2.0,
	#         detail 1.0, horizon 0.06, light_affect 0.1
	#   ssr: enabled true, max_steps 64, fade_in 0.15, fade_out 2.0,
	#        depth_tolerance 0.2
	#   ssil: enabled true, radius 5.0, intensity 1.0, normal_rejection 1.0
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 16: 3D 환경 설정 ===")
	print("")

	# 테스트 1: WorldEnvironment
	print("--- 연습 1: WorldEnvironment 설정 ---")
	var env_day = create_world_environment_config("outdoor_day")
	var env_night = create_world_environment_config("outdoor_night")
	var env_indoor = create_world_environment_config("indoor")
	var env_water = create_world_environment_config("underwater")
	print("결과 1-1 (야외 낮):", env_day)
	print("결과 1-2 (야외 밤):", env_night)
	print("결과 1-3 (실내):", env_indoor)
	print("결과 1-4 (수중):", env_water)
	print("")

	# 테스트 2: Sky 설정
	print("--- 연습 2: Sky 생성 ---")
	var sky_midnight = create_sky_config(0.0)
	var sky_dawn = create_sky_config(6.0)
	var sky_noon = create_sky_config(12.0)
	var sky_sunset = create_sky_config(18.0)
	print("결과 2-1 (자정):", sky_midnight)
	if sky_midnight.has("period"):
		print("  시간대:", sky_midnight["period"], " (기대값: night)")
	print("결과 2-2 (일출):", sky_dawn)
	if sky_dawn.has("period"):
		print("  시간대:", sky_dawn["period"], " (기대값: dawn_dusk)")
	print("결과 2-3 (정오):", sky_noon)
	if sky_noon.has("sun_angle_degrees"):
		print("  태양 각도:", sky_noon["sun_angle_degrees"], " (기대값: 90)")
	print("결과 2-4 (일몰):", sky_sunset)
	print("")

	# 테스트 3: 조명
	print("--- 연습 3: 3점 조명 ---")
	var light_std = create_three_point_lighting("standard")
	var light_dra = create_three_point_lighting("dramatic")
	var light_soft = create_three_point_lighting("soft")
	print("결과 3-1 (표준 조명):", light_std)
	print("결과 3-2 (극적 조명):", light_dra)
	print("결과 3-3 (부드러운 조명):", light_soft)
	print("")

	# 테스트 4: 안개
	print("--- 연습 4: 안개 설정 ---")
	var fog_depth = create_fog_config("depth", 0.5)
	var fog_height = create_fog_config("height", 0.8)
	var fog_vol = create_fog_config("volumetric", 0.3)
	var fog_clamp = create_fog_config("depth", 1.5)
	print("결과 4-1 (깊이 안개):", fog_depth)
	print("결과 4-2 (높이 안개):", fog_height)
	print("결과 4-3 (볼류메트릭):", fog_vol)
	if fog_clamp.has("density"):
		print("결과 4-4 (클램프 확인):", fog_clamp["density"], " (기대값: 1.0)")
	print("")

	# 테스트 5: 후처리
	print("--- 연습 5: 후처리 효과 ---")
	var pp_low = create_post_processing_config("low")
	var pp_med = create_post_processing_config("medium")
	var pp_high = create_post_processing_config("high")
	print("결과 5-1 (낮은 품질):", pp_low)
	if pp_low.has("ssao"):
		print("  SSAO 활성:", pp_low["ssao"].get("enabled", "미설정"), " (기대값: false)")
	print("결과 5-2 (중간 품질):", pp_med)
	if pp_med.has("ssao"):
		print("  SSAO 활성:", pp_med["ssao"].get("enabled", "미설정"), " (기대값: true)")
	print("결과 5-3 (높은 품질):", pp_high)
	if pp_high.has("ssr"):
		print("  SSR 활성:", pp_high["ssr"].get("enabled", "미설정"), " (기대값: true)")
	print("")

	print("=== 챕터 16 완료 ===")
