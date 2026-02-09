# Chapter 20 - 3D Effects & Optimization
# 02-decal-fog.gd - Decal, FogVolume, 환경 효과
#
# 이 파일에서 배울 내용:
# - Decal 노드로 표면에 투영하는 텍스처
# - FogVolume으로 국소적/체적 안개 효과
# - VoxelGI / SDFGI 글로벌 조명
# - ReflectionProbe로 실시간 반사
# - WorldEnvironment 고급 효과
# - Post-Processing 효과 체인

extends Node3D

func _ready():
	print("=== Chapter 20-2: Decal, Fog & Environment Effects ===\n")

	# -----------------------------------------------------------------
	# 1) Decal (데칼) 기본
	# -----------------------------------------------------------------
	print("--- 1. Decal 기본 ---")

	print("  Decal: 표면에 투영하는 텍스처 (스티커처럼)")
	print("  별도의 지오메트리 없이 표면에 이미지를 덧붙입니다")
	print()
	print("  활용 사례:")
	print("    - 총알 자국 (탄흔)")
	print("    - 피/페인트 자국")
	print("    - 균열/갈라짐")
	print("    - 바닥 표시 (마법진, 에임)")
	print("    - 그림자 블롭 (캐릭터 아래 원형 그림자)")
	print("    - 도로 표시, 낙서")
	print()

	# 데칼 생성
	var decal := Decal.new()
	decal.size = Vector3(2, 1, 2)         # 투영 영역 크기
	decal.position = Vector3(0, 0.5, 0)   # 표면 바로 위

	# 데칼 텍스처 설정 (코드에서 - 실제로는 텍스처 파일 사용)
	print("  Decal 속성:")
	print("    size = %s (투영 영역)" % str(decal.size))
	print("    position = %s" % str(decal.position))
	print()

	print("  텍스처 채널:")
	print("    texture_albedo   - 색상 텍스처")
	print("    texture_normal   - 노멀맵")
	print("    texture_orm      - ORM (Occlusion, Roughness, Metallic)")
	print("    texture_emission - 발광 텍스처")
	print()

	add_child(decal)

	# 데칼 속성
	decal.upper_fade = 0.3                # 윗면 페이드
	decal.lower_fade = 0.3                # 아랫면 페이드
	decal.normal_fade = 0.5               # 법선 각도 페이드
	decal.modulate = Color(1, 1, 1, 0.9)  # 전체 색상/알파

	print("  페이드 설정:")
	print("    upper_fade = %.1f (위쪽 가장자리 페이드)" % decal.upper_fade)
	print("    lower_fade = %.1f (아래쪽 가장자리 페이드)" % decal.lower_fade)
	print("    normal_fade = %.1f (급경사 표면 페이드)" % decal.normal_fade)
	print("    modulate = %s (색상/투명도 조절)" % str(decal.modulate))
	print()

	# 데칼 컬링
	decal.cull_mask = 0xFFFFFFFF          # 모든 레이어에 적용
	decal.distance_fade_enabled = true     # 거리 페이드
	decal.distance_fade_begin = 20.0       # 페이드 시작 거리
	decal.distance_fade_length = 5.0       # 페이드 길이

	print("  거리 페이드:")
	print("    distance_fade_enabled = true")
	print("    distance_fade_begin = %.0fm" % decal.distance_fade_begin)
	print("    distance_fade_length = %.0fm" % decal.distance_fade_length)
	print()

	# -----------------------------------------------------------------
	# 2) 동적 데칼 시스템
	# -----------------------------------------------------------------
	print("--- 2. 동적 데칼 시스템 ---")

	print("  총알 자국 데칼 생성 코드:")
	print()
	print("  func spawn_bullet_decal(hit_pos: Vector3, hit_normal: Vector3):")
	print("      var decal = Decal.new()")
	print("      decal.texture_albedo = preload(\"res://decals/bullet_hole.png\")")
	print("      decal.size = Vector3(0.3, 0.5, 0.3)")
	print("      decal.position = hit_pos + hit_normal * 0.01  # 약간 위로")
	print()
	print("      # 법선 방향으로 회전")
	print("      if hit_normal != Vector3.UP:")
	print("          decal.look_at(hit_pos + hit_normal)")
	print("          decal.rotate_object_local(Vector3.RIGHT, PI/2)")
	print()
	print("      # 랜덤 회전 (자연스럽게)")
	print("      decal.rotate_object_local(Vector3.UP, randf() * TAU)")
	print()
	print("      get_tree().current_scene.add_child(decal)")
	print()
	print("      # 일정 시간 후 페이드아웃 & 제거")
	print("      var tween = create_tween()")
	print("      tween.tween_interval(10.0)")
	print("      tween.tween_property(decal, \"modulate:a\", 0.0, 2.0)")
	print("      tween.tween_callback(decal.queue_free)")
	print()

	# 데칼 풀링
	print("  데칼 풀링 (성능 최적화):")
	print("    const MAX_DECALS = 50")
	print("    var decal_pool: Array[Decal] = []")
	print("    var decal_index := 0")
	print()
	print("    func get_next_decal() -> Decal:")
	print("        var decal = decal_pool[decal_index]")
	print("        decal_index = (decal_index + 1) %% MAX_DECALS")
	print("        return decal")
	print()

	# 여러 데칼 배치 데모
	for i in range(5):
		var demo_decal := Decal.new()
		demo_decal.size = Vector3(1, 0.5, 1)
		demo_decal.position = Vector3(i * 2.5, 0.25, 5)
		demo_decal.modulate = Color(1, 1, 1, 0.8)
		add_child(demo_decal)
	print("  데모: 5개 데칼 배치 완료")
	print()

	# -----------------------------------------------------------------
	# 3) FogVolume (체적 안개)
	# -----------------------------------------------------------------
	print("--- 3. FogVolume (체적 안개) ---")

	print("  FogVolume: 특정 영역에 안개 효과")
	print("  WorldEnvironment의 Volumetric Fog와 함께 사용")
	print()

	var fog_volume := FogVolume.new()
	fog_volume.size = Vector3(10, 3, 10)
	fog_volume.position = Vector3(0, 1.5, -5)
	fog_volume.shape = RenderingServer.FOG_VOLUME_SHAPE_BOX

	# FogMaterial 설정
	var fog_mat := FogMaterial.new()
	fog_mat.density = 0.5                    # 안개 밀도
	fog_mat.albedo = Color(0.7, 0.75, 0.8)  # 안개 색상

	fog_volume.material = fog_mat
	add_child(fog_volume)

	print("  FogVolume 설정:")
	print("    size = %s" % str(fog_volume.size))
	print("    shape = BOX")
	print("    density = %.1f" % fog_mat.density)
	print("    albedo = %s" % str(fog_mat.albedo))
	print()

	print("  FogVolume 형태:")
	print("    FOG_VOLUME_SHAPE_BOX       - 직육면체")
	print("    FOG_VOLUME_SHAPE_ELLIPSOID  - 타원체")
	print("    FOG_VOLUME_SHAPE_CONE       - 원뿔")
	print("    FOG_VOLUME_SHAPE_CYLINDER   - 원기둥")
	print("    FOG_VOLUME_SHAPE_WORLD      - 전체 세계")
	print()

	# 여러 안개 볼륨 활용
	print("  안개 활용 사례:")
	print("    - 깊은 계곡: 바닥에 FogVolume")
	print("    - 폭포 물안개: 작은 FogVolume")
	print("    - 독가스: 녹색 FogVolume")
	print("    - 마법 영역: 발광 FogVolume")
	print("    - 화재 연기: 움직이는 FogVolume")
	print()

	# -----------------------------------------------------------------
	# 4) WorldEnvironment 체적 안개
	# -----------------------------------------------------------------
	print("--- 4. WorldEnvironment Volumetric Fog ---")

	print("  체적 안개 활성화 (WorldEnvironment 필요):")
	print()
	print("  var env = WorldEnvironment.new()")
	print("  var environment = Environment.new()")
	print()
	print("  # 체적 안개 설정")
	print("  environment.volumetric_fog_enabled = true")
	print("  environment.volumetric_fog_density = 0.02")
	print("  environment.volumetric_fog_albedo = Color(0.8, 0.85, 0.9)")
	print("  environment.volumetric_fog_emission = Color(0.0, 0.0, 0.0)")
	print("  environment.volumetric_fog_emission_energy = 0.0")
	print("  environment.volumetric_fog_length = 64.0  # 최대 거리")
	print("  environment.volumetric_fog_detail_spread = 2.0")
	print("  environment.volumetric_fog_gi_inject = 1.0  # GI 연동")
	print()
	print("  # 높이 안개")
	print("  environment.fog_enabled = true")
	print("  environment.fog_light_color = Color(0.8, 0.85, 0.9)")
	print("  environment.fog_density = 0.001")
	print("  environment.fog_aerial_perspective = 0.5")
	print("  environment.fog_height = 0.0    # 안개 시작 높이")
	print("  environment.fog_height_density = 0.1")
	print()

	# -----------------------------------------------------------------
	# 5) ReflectionProbe (반사 프로브)
	# -----------------------------------------------------------------
	print("--- 5. ReflectionProbe ---")

	var reflection_probe := ReflectionProbe.new()
	reflection_probe.size = Vector3(10, 5, 10)
	reflection_probe.position = Vector3(0, 2.5, 0)
	reflection_probe.update_mode = ReflectionProbe.UPDATE_ONCE  # 한 번만
	reflection_probe.interior = false
	reflection_probe.box_projection = true
	add_child(reflection_probe)

	print("  ReflectionProbe: 주변 환경의 반사를 캡처")
	print()
	print("  속성:")
	print("    size = %s (영향 범위)" % str(reflection_probe.size))
	print("    update_mode:")
	print("      UPDATE_ONCE   - 한 번만 캡처 (정적 환경)")
	print("      UPDATE_ALWAYS - 매 프레임 캡처 (동적, 비용 높음)")
	print("    interior = false (실내/실외)")
	print("    box_projection = true (박스 투영 보정)")
	print("    intensity = 1.0 (반사 강도)")
	print("    max_distance = 0 (0=무한)")
	print()

	print("  활용:")
	print("    - 실내 공간: 방마다 ReflectionProbe")
	print("    - 물 표면: 반사 효과")
	print("    - 금속/유리 오브젝트 주변")
	print()

	# -----------------------------------------------------------------
	# 6) 글로벌 조명 (GI) 옵션
	# -----------------------------------------------------------------
	print("--- 6. 글로벌 조명 (GI) ---")

	print("  Godot 4의 GI 솔루션:")
	print()
	print("  a) LightmapGI (라이트맵 베이크):")
	print("     + 가장 품질 높은 간접 조명")
	print("     + 실행 시 비용 최소")
	print("     - 정적 오브젝트만")
	print("     - 베이크 시간 필요")
	print("     설정: LightmapGI 노드 추가 > 베이크")
	print()
	print("  b) VoxelGI:")
	print("     + 동적 오브젝트 지원")
	print("     + 실시간 간접 조명")
	print("     - 메모리 사용 높음")
	print("     - 범위 제한적")
	print("     설정: VoxelGI 노드 추가 > 베이크")
	print()
	print("  c) SDFGI (Signed Distance Field GI):")
	print("     + 대규모 실외 장면")
	print("     + 별도 베이크 불필요")
	print("     + 동적 지원")
	print("     - GPU 비용 높음")
	print("     - 작은 디테일 제한")
	print("     설정: Environment > SDFGI Enabled")
	print()

	# -----------------------------------------------------------------
	# 7) Post-Processing 효과
	# -----------------------------------------------------------------
	print("--- 7. Post-Processing 효과 ---")

	print("  Environment 노드에서 설정:")
	print()

	print("  a) Glow (블룸):")
	print("     environment.glow_enabled = true")
	print("     environment.glow_intensity = 0.8")
	print("     environment.glow_bloom = 0.1")
	print("     environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE")
	print()

	print("  b) Tonemap (톤 매핑):")
	print("     environment.tonemap_mode = Environment.TONE_MAP_FILMIC")
	print("     environment.tonemap_exposure = 1.0")
	print("     environment.tonemap_white = 1.0")
	print()

	print("  c) SSAO (Screen Space Ambient Occlusion):")
	print("     environment.ssao_enabled = true")
	print("     environment.ssao_radius = 1.0")
	print("     environment.ssao_intensity = 2.0")
	print()

	print("  d) SSR (Screen Space Reflections):")
	print("     environment.ssr_enabled = true")
	print("     environment.ssr_max_steps = 64")
	print("     environment.ssr_fade_in = 0.15")
	print()

	print("  e) SSIL (Screen Space Indirect Lighting):")
	print("     environment.ssil_enabled = true")
	print("     environment.ssil_radius = 5.0")
	print("     environment.ssil_intensity = 1.0")
	print()

	print("  f) DOF (Depth of Field):")
	print("     # Camera3D 속성에서 설정")
	print("     camera.attributes = CameraAttributesPractical.new()")
	print("     camera.attributes.dof_blur_far_enabled = true")
	print("     camera.attributes.dof_blur_far_distance = 10.0")
	print("     camera.attributes.dof_blur_far_transition = 5.0")
	print("     camera.attributes.dof_blur_amount = 0.05")
	print()

	# -----------------------------------------------------------------
	# 8) 안개 + 조명 조합 효과
	# -----------------------------------------------------------------
	print("--- 8. 분위기 조합 예시 ---")

	print("  호러 분위기:")
	print("    fog_density = 0.05 (짙은 안개)")
	print("    fog_color = Color(0.1, 0.1, 0.15)")
	print("    glow_bloom = 0.3")
	print("    ssao_intensity = 3.0")
	print("    tonemap = FILMIC")
	print()

	print("  몽환적 숲:")
	print("    volumetric_fog = 0.01")
	print("    fog_color = Color(0.5, 0.7, 0.4)")
	print("    glow_intensity = 1.5")
	print("    glow_bloom = 0.2")
	print("    FogVolume 여러 개 (나무 사이)")
	print()

	print("  사이버펑크 도시:")
	print("    fog_density = 0.002")
	print("    fog_color = Color(0.1, 0.05, 0.15)")
	print("    Emission 재질 (네온)")
	print("    glow_bloom = 0.15")
	print("    ssr_enabled = true (젖은 바닥 반사)")
	print()

	# -----------------------------------------------------------------
	# 9) 환경 효과 성능 비용
	# -----------------------------------------------------------------
	print("--- 9. 환경 효과 성능 비용 ---")

	print("  낮은 비용:")
	print("    - Fog (높이 안개)")
	print("    - Tonemap")
	print("    - Decal (소량)")
	print()
	print("  중간 비용:")
	print("    - Glow/Bloom")
	print("    - SSAO")
	print("    - ReflectionProbe (UPDATE_ONCE)")
	print("    - Volumetric Fog")
	print()
	print("  높은 비용:")
	print("    - SSR")
	print("    - SSIL")
	print("    - SDFGI")
	print("    - ReflectionProbe (UPDATE_ALWAYS)")
	print("    - DOF")
	print()
	print("  플랫폼별 권장:")
	print("    PC 고사양: 전부 활성화")
	print("    PC 중사양: SSR/SSIL 제외")
	print("    모바일: Fog + Glow만, SSAO/SSR 비활성화")
	print()

	print("=== 02-decal-fog.gd 완료 ===")
