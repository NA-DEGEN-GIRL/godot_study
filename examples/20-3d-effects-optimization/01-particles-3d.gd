# Chapter 20 - 3D Effects & Optimization
# 01-particles-3d.gd - GPUParticles3D, ParticleProcessMaterial, 트레일
#
# 이 파일에서 배울 내용:
# - GPUParticles3D vs CPUParticles3D 비교
# - ParticleProcessMaterial 속성 상세 설정
# - 다양한 파티클 효과: 불, 연기, 폭발, 마법
# - 파티클 트레일 (Trail)
# - Sub-Emitter (하위 방출기)
# - 파티클 성능 최적화

extends Node3D

func _ready():
	print("=== Chapter 20-1: 3D Particles ===\n")

	# -----------------------------------------------------------------
	# 1) GPU vs CPU 파티클
	# -----------------------------------------------------------------
	print("--- 1. GPUParticles3D vs CPUParticles3D ---")

	print("  GPUParticles3D:")
	print("    + GPU에서 계산 (매우 빠름)")
	print("    + 수만 개의 파티클 가능")
	print("    + 트레일 지원")
	print("    - 모바일/웹에서 제한적")
	print("    - 개별 파티클 제어 불가")
	print()
	print("  CPUParticles3D:")
	print("    + 모든 플랫폼 호환")
	print("    + 개별 파티클 접근 가능")
	print("    + GPUParticles3D에서 변환 가능")
	print("    - CPU 부담 (수천 개 이상 느림)")
	print("    - 트레일 미지원")
	print()
	print("  선택 기준:")
	print("    PC/콘솔 -> GPUParticles3D (기본)")
	print("    모바일/웹 -> CPUParticles3D 또는 최적화된 GPU")
	print()

	# -----------------------------------------------------------------
	# 2) 기본 GPUParticles3D 설정
	# -----------------------------------------------------------------
	print("--- 2. 기본 설정 ---")

	var particles := GPUParticles3D.new()
	particles.amount = 100                # 파티클 수
	particles.lifetime = 2.0              # 수명 (초)
	particles.one_shot = false            # 반복 여부
	particles.explosiveness = 0.0         # 0=연속, 1=한번에 전부
	particles.randomness = 0.5            # 랜덤 정도
	particles.fixed_fps = 0               # 고정 FPS (0=무제한)
	particles.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))

	print("  기본 속성:")
	print("    amount = %d" % particles.amount)
	print("    lifetime = %.1f초" % particles.lifetime)
	print("    one_shot = %s" % str(particles.one_shot))
	print("    explosiveness = %.1f" % particles.explosiveness)
	print("    randomness = %.1f" % particles.randomness)
	print()

	# -----------------------------------------------------------------
	# 3) ParticleProcessMaterial 설정
	# -----------------------------------------------------------------
	print("--- 3. ParticleProcessMaterial ---")

	var mat := ParticleProcessMaterial.new()

	# 방향과 퍼짐
	mat.direction = Vector3(0, 1, 0)      # 기본 방향 (위)
	mat.spread = 30.0                      # 퍼짐 각도

	# 초기 속도
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0

	# 중력
	mat.gravity = Vector3(0, -9.8, 0)

	# 크기
	mat.scale_min = 0.5
	mat.scale_max = 1.5

	# 색상
	mat.color = Color(1.0, 0.5, 0.0)     # 기본 색상

	particles.process_material = mat
	particles.position = Vector3(0, 0, 0)
	add_child(particles)

	print("  ParticleProcessMaterial 설정:")
	print("    direction = (0, 1, 0) (위쪽)")
	print("    spread = 30도")
	print("    initial_velocity = 2.0 ~ 5.0")
	print("    gravity = (0, -9.8, 0)")
	print("    scale = 0.5 ~ 1.5")
	print("    color = 주황색")
	print()

	# -----------------------------------------------------------------
	# 4) 불꽃 효과 (Fire)
	# -----------------------------------------------------------------
	print("--- 4. 불꽃 효과 ---")

	var fire := _create_fire_particles(Vector3(5, 0, 0))
	add_child(fire)

	print("  불꽃 파티클 속성:")
	print("    방향: 위 (spread: 15도)")
	print("    수명: 1.5초")
	print("    크기: 시간에 따라 감소")
	print("    색상: 노란색 -> 주황색 -> 빨간색 -> 투명")
	print("    중력: 약한 상승 (-2.0)")
	print()

	# -----------------------------------------------------------------
	# 5) 연기 효과 (Smoke)
	# -----------------------------------------------------------------
	print("--- 5. 연기 효과 ---")

	var smoke := _create_smoke_particles(Vector3(10, 0, 0))
	add_child(smoke)

	print("  연기 파티클 속성:")
	print("    방향: 위 (spread: 25도)")
	print("    수명: 3.0초")
	print("    크기: 시간에 따라 증가")
	print("    색상: 회색, 알파 감소")
	print("    속도: 느림 (0.5 ~ 1.5)")
	print()

	# -----------------------------------------------------------------
	# 6) 폭발 효과 (Explosion)
	# -----------------------------------------------------------------
	print("--- 6. 폭발 효과 ---")

	var explosion := _create_explosion_particles(Vector3(15, 2, 0))
	add_child(explosion)

	print("  폭발 파티클 속성:")
	print("    explosiveness = 1.0 (한번에 전부)")
	print("    one_shot = true")
	print("    속도: 빠름 (5 ~ 15)")
	print("    spread: 180도 (모든 방향)")
	print("    감속: damping으로 급격히 감속")
	print()

	# -----------------------------------------------------------------
	# 7) 마법 효과 (Magic Sparkle)
	# -----------------------------------------------------------------
	print("--- 7. 마법 효과 ---")

	var magic := _create_magic_particles(Vector3(20, 2, 0))
	add_child(magic)

	print("  마법 파티클 속성:")
	print("    emission_shape: SPHERE (구형 방출)")
	print("    색상: 무지개 그라데이션")
	print("    emission 발광 효과")
	print("    궤도 회전 (orbit_velocity)")
	print()

	# -----------------------------------------------------------------
	# 8) 색상 그라데이션 (ColorRamp)
	# -----------------------------------------------------------------
	print("--- 8. 색상/크기 곡선 ---")

	print("  시간에 따른 색상 변화 (Gradient):")
	print("    var gradient = Gradient.new()")
	print("    gradient.add_point(0.0, Color.WHITE)       # 시작")
	print("    gradient.add_point(0.3, Color.YELLOW)      # 30%%")
	print("    gradient.add_point(0.7, Color.RED)         # 70%%")
	print("    gradient.add_point(1.0, Color(1,0,0,0))    # 끝(투명)")
	print()
	print("    var tex = GradientTexture1D.new()")
	print("    tex.gradient = gradient")
	print("    material.color_ramp = tex")
	print()

	print("  시간에 따른 크기 변화 (CurveTexture):")
	print("    var curve = Curve.new()")
	print("    curve.add_point(Vector2(0, 0))     # 시작: 크기 0")
	print("    curve.add_point(Vector2(0.1, 1))   # 10%%: 최대 크기")
	print("    curve.add_point(Vector2(1, 0))     # 끝: 크기 0")
	print()
	print("    var curve_tex = CurveTexture.new()")
	print("    curve_tex.curve = curve")
	print("    material.scale_curve = curve_tex")
	print()

	# -----------------------------------------------------------------
	# 9) 방출 형태 (Emission Shape)
	# -----------------------------------------------------------------
	print("--- 9. 방출 형태 ---")

	print("  emission_shape_offset: 방출 위치 오프셋")
	print()
	print("  EMISSION_SHAPE_POINT - 한 점에서 방출 (기본)")
	print("  EMISSION_SHAPE_SPHERE - 구 내부에서 방출")
	print("    material.emission_sphere_radius = 2.0")
	print()
	print("  EMISSION_SHAPE_SPHERE_SURFACE - 구 표면에서 방출")
	print("  EMISSION_SHAPE_BOX - 박스 내부에서 방출")
	print("    material.emission_box_extents = Vector3(2, 0.5, 2)")
	print()
	print("  EMISSION_SHAPE_RING - 링 형태로 방출")
	print("    material.emission_ring_radius = 3.0")
	print("    material.emission_ring_inner_radius = 2.5")
	print("    material.emission_ring_height = 0.1")
	print()

	# 링 형태 데모
	var ring_particles := GPUParticles3D.new()
	ring_particles.amount = 200
	ring_particles.lifetime = 2.0
	var ring_mat := ParticleProcessMaterial.new()
	ring_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	ring_mat.emission_ring_radius = 3.0
	ring_mat.emission_ring_inner_radius = 2.8
	ring_mat.emission_ring_height = 0.1
	ring_mat.direction = Vector3(0, 1, 0)
	ring_mat.initial_velocity_min = 1.0
	ring_mat.initial_velocity_max = 2.0
	ring_mat.gravity = Vector3.ZERO
	ring_mat.color = Color(0.3, 0.8, 1.0)
	ring_particles.process_material = ring_mat

	# 파티클 메시 (쿼드 대신 작은 구)
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.05
	particle_mesh.height = 0.1
	ring_particles.draw_pass_1 = particle_mesh
	ring_particles.position = Vector3(25, 1, 0)
	add_child(ring_particles)

	print("  링 방출 데모: 반지름 3m 링에서 위로 방출")
	print()

	# -----------------------------------------------------------------
	# 10) 트레일 (Trail)
	# -----------------------------------------------------------------
	print("--- 10. 파티클 트레일 ---")

	var trail_particles := GPUParticles3D.new()
	trail_particles.amount = 50
	trail_particles.lifetime = 1.5
	trail_particles.trail_enabled = true       # 트레일 활성화
	trail_particles.trail_lifetime = 0.5       # 트레일 수명

	var trail_mat := ParticleProcessMaterial.new()
	trail_mat.direction = Vector3(1, 0.5, 0)
	trail_mat.initial_velocity_min = 3.0
	trail_mat.initial_velocity_max = 5.0
	trail_mat.gravity = Vector3(0, -5, 0)
	trail_mat.spread = 20.0
	trail_mat.color = Color(1.0, 0.8, 0.2)
	trail_particles.process_material = trail_mat

	# 트레일 메시 (리본 메시)
	var trail_mesh := RibbonTrailMesh.new()
	trail_mesh.size = 0.1
	trail_mesh.sections = 4
	trail_mesh.section_length = 0.2
	trail_particles.draw_pass_1 = trail_mesh

	trail_particles.position = Vector3(30, 3, 0)
	add_child(trail_particles)

	print("  트레일 설정:")
	print("    trail_enabled = true")
	print("    trail_lifetime = 0.5초 (꼬리 길이)")
	print("    RibbonTrailMesh 사용 (리본 형태)")
	print("    또는 TubeTrailMesh (튜브 형태)")
	print()
	print("  draw_pass 메시 종류:")
	print("    QuadMesh     - 항상 카메라를 향하는 사각형 (빌보드)")
	print("    SphereMesh   - 구형 파티클")
	print("    BoxMesh      - 박스형 파티클")
	print("    RibbonTrailMesh - 리본 트레일")
	print("    TubeTrailMesh   - 튜브 트레일")
	print("    커스텀 메시     - 나뭇잎, 파편 등")
	print()

	# -----------------------------------------------------------------
	# 11) 파티클 성능 팁
	# -----------------------------------------------------------------
	print("--- 11. 파티클 성능 팁 ---")

	print("  1. amount를 최소화")
	print("     크기를 크게, 수를 줄여서 같은 효과")
	print()
	print("  2. fixed_fps 설정")
	print("     particles.fixed_fps = 30  # 30FPS로 시뮬레이션")
	print("     높은 FPS 불필요한 파티클에 적용")
	print()
	print("  3. visibility_aabb 정확히 설정")
	print("     컬링이 올바르게 작동하도록")
	print()
	print("  4. 서브-에미터 최소화")
	print("     중첩된 파티클은 기하급수적 증가")
	print()
	print("  5. 트레일 section 수 줄이기")
	print("     많은 섹션 = 많은 폴리곤")
	print()
	print("  6. 원거리에서 비활성화")
	print("     if camera_distance > threshold:")
	print("         particles.emitting = false")
	print()

	print("=== 01-particles-3d.gd 완료 ===")


# =============================================================================
# 파티클 생성 함수
# =============================================================================

## 불꽃 파티클
func _create_fire_particles(pos: Vector3) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = 80
	p.lifetime = 1.5
	p.position = pos

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 15.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 3.0
	mat.gravity = Vector3(0, -2.0, 0)  # 약한 상승
	mat.damping_min = 2.0
	mat.damping_max = 4.0

	# 색상 그라데이션 (불꽃)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.5))         # 밝은 노란색
	gradient.add_point(0.3, Color(1.0, 0.6, 0.0))       # 주황
	gradient.add_point(0.7, Color(0.8, 0.1, 0.0))       # 빨강
	gradient.set_color(1, Color(0.3, 0.0, 0.0, 0.0))    # 투명
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = gradient
	mat.color_ramp = color_ramp

	# 크기 변화
	mat.scale_min = 0.3
	mat.scale_max = 0.8

	p.process_material = mat

	# 빌보드 메시
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.5, 0.5)
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mesh_mat.vertex_color_use_as_albedo = true
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_mat.emission_enabled = true
	mesh_mat.emission = Color.WHITE
	mesh_mat.emission_energy_multiplier = 2.0
	mesh.material = mesh_mat
	p.draw_pass_1 = mesh

	return p


## 연기 파티클
func _create_smoke_particles(pos: Vector3) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = 40
	p.lifetime = 3.0
	p.position = pos

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 25.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.5
	mat.gravity = Vector3(0, 0.5, 0)  # 약한 상승
	mat.damping_min = 1.0
	mat.damping_max = 2.0

	# 연기 색상
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.4, 0.4, 0.4, 0.6))
	gradient.set_color(1, Color(0.6, 0.6, 0.6, 0.0))
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = gradient
	mat.color_ramp = color_ramp

	mat.scale_min = 0.5
	mat.scale_max = 1.0

	p.process_material = mat

	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.0, 1.0)
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mesh_mat.vertex_color_use_as_albedo = true
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mesh_mat
	p.draw_pass_1 = mesh

	return p


## 폭발 파티클
func _create_explosion_particles(pos: Vector3) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = 150
	p.lifetime = 1.0
	p.one_shot = true
	p.explosiveness = 1.0
	p.position = pos
	p.emitting = true

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0  # 모든 방향
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 15.0
	mat.gravity = Vector3(0, -9.8, 0)
	mat.damping_min = 5.0
	mat.damping_max = 10.0

	# 폭발 색상
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.8))
	gradient.add_point(0.2, Color(1.0, 0.5, 0.0))
	gradient.set_color(1, Color(0.3, 0.1, 0.0, 0.0))
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = gradient
	mat.color_ramp = color_ramp

	mat.scale_min = 0.2
	mat.scale_max = 0.5

	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.2
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.vertex_color_use_as_albedo = true
	mesh_mat.emission_enabled = true
	mesh_mat.emission = Color(1.0, 0.5, 0.0)
	mesh.material = mesh_mat
	p.draw_pass_1 = mesh

	return p


## 마법 파티클
func _create_magic_particles(pos: Vector3) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = 100
	p.lifetime = 2.0
	p.position = pos

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 1.5
	mat.direction = Vector3(0, 0, 0)
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = 0.5
	mat.gravity = Vector3.ZERO

	# 궤도 회전
	mat.orbit_velocity_min = 0.3
	mat.orbit_velocity_max = 0.8

	# 무지개 색상
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.5, 0.0, 1.0))
	gradient.add_point(0.25, Color(0.0, 0.5, 1.0))
	gradient.add_point(0.5, Color(0.0, 1.0, 0.5))
	gradient.add_point(0.75, Color(1.0, 1.0, 0.0))
	gradient.set_color(1, Color(1.0, 0.0, 0.5, 0.0))
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = gradient
	mat.color_ramp = color_ramp

	mat.scale_min = 0.1
	mat.scale_max = 0.3

	p.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.vertex_color_use_as_albedo = true
	mesh_mat.emission_enabled = true
	mesh_mat.emission = Color.WHITE
	mesh_mat.emission_energy_multiplier = 3.0
	mesh.material = mesh_mat
	p.draw_pass_1 = mesh

	return p
