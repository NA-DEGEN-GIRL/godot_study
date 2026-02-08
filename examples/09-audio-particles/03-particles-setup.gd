# Chapter 09 - Audio & Particles
# 03-particles-setup.gd - GPUParticles2D와 파티클 시스템
#
# 이 파일에서 배울 내용:
# - GPUParticles2D vs CPUParticles2D 차이점
# - ParticleProcessMaterial 속성 상세 설명
# - 방출 형태(Emission Shape) 종류
# - 색상, 크기, 속도 커브 설정
# - 실용적인 파티클 이펙트 프리셋 만들기

extends Node2D

func _ready():
	print("=== Chapter 09-3: GPUParticles2D 파티클 시스템 ===\n")

	# -----------------------------------------------------------------
	# 1) GPUParticles2D vs CPUParticles2D
	# -----------------------------------------------------------------
	print("--- 1. GPU vs CPU 파티클 비교 ---")

	print("  +---------------------+------------------+------------------+")
	print("  | 항목                | GPUParticles2D   | CPUParticles2D   |")
	print("  +---------------------+------------------+------------------+")
	print("  | 처리 위치           | GPU              | CPU              |")
	print("  | 파티클 수           | 수천~수만 가능   | 수백 권장        |")
	print("  | 호환성              | GPU 필요         | 모든 환경        |")
	print("  | 머티리얼            | ProcessMaterial  | 속성 직접 설정   |")
	print("  | 커스텀 셰이더       | 지원             | 미지원           |")
	print("  | 웹 내보내기         | 제한적           | 호환 좋음        |")
	print("  | 트레일(궤적)        | sub_emitter 지원 | 미지원           |")
	print("  +---------------------+------------------+------------------+")
	print()

	# -----------------------------------------------------------------
	# 2) GPUParticles2D 기본 설정
	# -----------------------------------------------------------------
	print("--- 2. GPUParticles2D 기본 속성 ---")

	var particles = GPUParticles2D.new()
	add_child(particles)

	# 기본 속성 확인
	print("  emitting: ", particles.emitting, " (방출 여부)")
	print("  amount: ", particles.amount, " (파티클 수)")
	print("  lifetime: ", particles.lifetime, " (수명, 초)")
	print("  one_shot: ", particles.one_shot, " (1회만 방출)")
	print("  preprocess: ", particles.preprocess, " (사전 처리 시간)")
	print("  explosiveness: ", particles.explosiveness, " (폭발성 0~1)")
	print("  randomness: ", particles.randomness, " (랜덤 비율)")
	print("  speed_scale: ", particles.speed_scale, " (전체 속도 배율)")
	print("  fixed_fps: ", particles.fixed_fps, " (고정 FPS, 0=가변)")
	print("  interpolate: ", particles.interpolate, " (보간 여부)")
	print()

	# 주요 속성 설명
	print("  주요 속성 설명:")
	print("    amount - 동시에 존재하는 최대 파티클 수")
	print("    lifetime - 각 파티클의 생존 시간")
	print("    one_shot - true면 한 번만 방출 후 멈춤 (폭발 효과)")
	print("    explosiveness - 0=고르게 방출, 1=한꺼번에 방출")
	print("    preprocess - 씬 시작 시 이미 진행된 것처럼 보이게 함")
	print()

	# -----------------------------------------------------------------
	# 3) ParticleProcessMaterial 생성 및 기본 설정
	# -----------------------------------------------------------------
	print("--- 3. ParticleProcessMaterial 기본 설정 ---")

	var material = ParticleProcessMaterial.new()
	particles.process_material = material

	# 방향 (Direction)
	material.direction = Vector3(0, -1, 0)  # 위쪽 (Y축 음수가 위)
	material.spread = 45.0  # 방향으로부터의 퍼짐 각도 (도)
	print("  direction: ", material.direction, " (방출 방향)")
	print("  spread: ", material.spread, " 도 (퍼짐 각도)")
	print()

	# 중력 (Gravity)
	material.gravity = Vector3(0, 98, 0)  # 아래로 중력
	print("  gravity: ", material.gravity, " (중력 벡터)")
	print("  참고: 2D에서 X=좌우, Y=상하, Z=미사용")
	print()

	# 초기 속도 (Initial Velocity)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	print("  initial_velocity: %.0f ~ %.0f" % [
		material.initial_velocity_min, material.initial_velocity_max
	])
	print()

	# -----------------------------------------------------------------
	# 4) 방출 형태 (Emission Shape)
	# -----------------------------------------------------------------
	print("--- 4. 방출 형태 (Emission Shape) ---")

	print("  사용 가능한 방출 형태:")
	print("    EMISSION_SHAPE_POINT        = %d (점)" % ParticleProcessMaterial.EMISSION_SHAPE_POINT)
	print("    EMISSION_SHAPE_SPHERE       = %d (구)" % ParticleProcessMaterial.EMISSION_SHAPE_SPHERE)
	print("    EMISSION_SHAPE_SPHERE_SURFACE = %d (구 표면)" % ParticleProcessMaterial.EMISSION_SHAPE_SPHERE_SURFACE)
	print("    EMISSION_SHAPE_BOX          = %d (박스)" % ParticleProcessMaterial.EMISSION_SHAPE_BOX)
	print("    EMISSION_SHAPE_RING         = %d (링)" % ParticleProcessMaterial.EMISSION_SHAPE_RING)
	print()

	# 점 방출 (기본값)
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	print("  현재: POINT - 한 점에서 모든 파티클 방출")
	print()

	# 구 방출
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 30.0
	print("  SPHERE 설정: 반지름 = ", material.emission_sphere_radius, " px")
	print()

	# 박스 방출
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(100, 50, 0)  # 2D에서 Z=0
	print("  BOX 설정: extents = ", material.emission_box_extents)
	print("  (중심에서 각 축으로의 거리, 총 크기는 2배)")
	print()

	# 링 방출
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	material.emission_ring_radius = 50.0
	material.emission_ring_inner_radius = 40.0
	material.emission_ring_height = 0.0  # 2D에서는 0
	material.emission_ring_axis = Vector3(0, 0, 1)  # Z축 기준 (2D 평면)
	print("  RING 설정:")
	print("    외경: ", material.emission_ring_radius)
	print("    내경: ", material.emission_ring_inner_radius)
	print("    축: ", material.emission_ring_axis)
	print()

	# 기본값으로 복원
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT

	# -----------------------------------------------------------------
	# 5) 색상 설정
	# -----------------------------------------------------------------
	print("--- 5. 색상 설정 ---")

	# 단일 색상
	material.color = Color.ORANGE
	print("  단일 색상: ", material.color)
	print()

	# 그라디언트 (수명에 따른 색상 변화)
	var gradient = Gradient.new()
	gradient.set_color(0, Color.YELLOW)          # 시작: 노랑
	gradient.add_point(0.5, Color.ORANGE_RED)    # 중간: 주황빨강
	gradient.set_color(1, Color(1, 0, 0, 0))    # 끝: 빨강 + 투명

	var gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient

	material.color_ramp = gradient_tex
	print("  색상 그라디언트 설정:")
	print("    0.0 (시작): YELLOW")
	print("    0.5 (중간): ORANGE_RED")
	print("    1.0 (끝):   RED + 투명 (alpha=0)")
	print()

	# 색상 초기 범위 (파티클마다 다른 시작 색상)
	var init_gradient = Gradient.new()
	init_gradient.set_color(0, Color.RED)
	init_gradient.set_color(1, Color.YELLOW)
	var init_gradient_tex = GradientTexture1D.new()
	init_gradient_tex.gradient = init_gradient

	material.color_initial_ramp = init_gradient_tex
	print("  초기 색상 범위: RED ~ YELLOW")
	print("  (각 파티클이 이 범위에서 랜덤 시작 색상을 가짐)")
	print()

	# -----------------------------------------------------------------
	# 6) 크기 커브 (Scale)
	# -----------------------------------------------------------------
	print("--- 6. 크기 커브 (Scale) ---")

	# 수명에 따른 크기 변화
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))   # 시작: 크기 0
	scale_curve.add_point(Vector2(0.1, 1.0))   # 10%: 최대 크기
	scale_curve.add_point(Vector2(0.8, 1.0))   # 80%: 최대 유지
	scale_curve.add_point(Vector2(1.0, 0.0))   # 끝: 크기 0

	var scale_curve_tex = CurveTexture.new()
	scale_curve_tex.curve = scale_curve

	material.scale_min = 1.0
	material.scale_max = 3.0
	material.scale_curve = scale_curve_tex

	print("  크기 범위: %.1f ~ %.1f" % [material.scale_min, material.scale_max])
	print("  크기 커브:")
	print("    0%%  -> 0.0 (보이지 않음)")
	print("    10%% -> 1.0 (빠르게 나타남)")
	print("    80%% -> 1.0 (유지)")
	print("    100%% -> 0.0 (사라짐)")
	print()

	# -----------------------------------------------------------------
	# 7) 속도, 가속, 감속 파라미터
	# -----------------------------------------------------------------
	print("--- 7. 물리 파라미터 ---")

	# 각속도 (Angular Velocity) - 파티클 회전
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	print("  각속도: %.0f ~ %.0f 도/초" % [
		material.angular_velocity_min, material.angular_velocity_max
	])

	# 궤도 속도 (Orbit Velocity) - 중심 주위 공전
	# 참고: orbit_velocity는 커브로 설정
	print("  궤도 속도: 중심점 주위로 공전하는 효과")

	# 선형 가속 (Linear Acceleration)
	material.linear_accel_min = -10.0
	material.linear_accel_max = 10.0
	print("  선형 가속: %.0f ~ %.0f" % [
		material.linear_accel_min, material.linear_accel_max
	])

	# 반경 가속 (Radial Acceleration) - 중심에서 멀어지거나 가까워지는 가속
	material.radial_accel_min = 5.0
	material.radial_accel_max = 10.0
	print("  반경 가속: %.0f ~ %.0f (양수=바깥, 음수=안쪽)" % [
		material.radial_accel_min, material.radial_accel_max
	])

	# 접선 가속 (Tangential Acceleration) - 원형 이동
	material.tangential_accel_min = 0.0
	material.tangential_accel_max = 5.0
	print("  접선 가속: %.0f ~ %.0f" % [
		material.tangential_accel_min, material.tangential_accel_max
	])

	# 감쇠 (Damping) - 속도 감소
	material.damping_min = 5.0
	material.damping_max = 10.0
	print("  감쇠: %.0f ~ %.0f (마찰 효과)" % [
		material.damping_min, material.damping_max
	])
	print()

	# -----------------------------------------------------------------
	# 8) 실용 프리셋: 불꽃 이펙트
	# -----------------------------------------------------------------
	print("--- 8. 프리셋: 불꽃(Fire) 이펙트 ---")

	var fire = _create_fire_particles()
	add_child(fire)
	fire.position = Vector2(200, 400)
	print("  불꽃 파티클 생성됨 (위치: %s)" % fire.position)
	_print_particle_summary(fire, "  ")
	print()

	# -----------------------------------------------------------------
	# 9) 실용 프리셋: 폭발 이펙트
	# -----------------------------------------------------------------
	print("--- 9. 프리셋: 폭발(Explosion) 이펙트 ---")

	var explosion = _create_explosion_particles()
	add_child(explosion)
	explosion.position = Vector2(500, 300)
	print("  폭발 파티클 생성됨 (위치: %s)" % explosion.position)
	_print_particle_summary(explosion, "  ")
	print()

	# -----------------------------------------------------------------
	# 10) 실용 프리셋: 비/눈 이펙트
	# -----------------------------------------------------------------
	print("--- 10. 프리셋: 비(Rain) / 눈(Snow) ---")

	var rain = _create_rain_particles()
	add_child(rain)
	rain.position = Vector2(400, -50)
	print("  비 파티클 생성됨 (위치: %s)" % rain.position)
	_print_particle_summary(rain, "  ")
	print()

	var snow = _create_snow_particles()
	add_child(snow)
	snow.position = Vector2(400, -50)
	print("  눈 파티클 생성됨 (위치: %s)" % snow.position)
	_print_particle_summary(snow, "  ")
	print()

	# -----------------------------------------------------------------
	# 11) 실용 프리셋: 스파크(불꽃 튀김)
	# -----------------------------------------------------------------
	print("--- 11. 프리셋: 스파크(Spark) ---")

	var sparks = _create_spark_particles()
	add_child(sparks)
	sparks.position = Vector2(300, 350)
	print("  스파크 파티클 생성됨 (위치: %s)" % sparks.position)
	_print_particle_summary(sparks, "  ")
	print()

	# -----------------------------------------------------------------
	# 12) CPUParticles2D로 변환
	# -----------------------------------------------------------------
	print("--- 12. CPUParticles2D 사용법 ---")

	# CPUParticles2D는 GPU 의존 없이 동작
	var cpu_particles = CPUParticles2D.new()
	add_child(cpu_particles)

	# CPUParticles2D는 ProcessMaterial 대신 직접 속성 설정
	cpu_particles.amount = 50
	cpu_particles.lifetime = 2.0
	cpu_particles.one_shot = false
	cpu_particles.explosiveness = 0.0
	cpu_particles.direction = Vector2(0, -1)
	cpu_particles.spread = 30.0
	cpu_particles.gravity = Vector2(0, 98)
	cpu_particles.initial_velocity_min = 30.0
	cpu_particles.initial_velocity_max = 60.0
	cpu_particles.scale_amount_min = 2.0
	cpu_particles.scale_amount_max = 5.0
	cpu_particles.color = Color.CYAN

	print("  CPUParticles2D 속성 (직접 설정):")
	print("    amount: ", cpu_particles.amount)
	print("    direction: ", cpu_particles.direction)
	print("    spread: ", cpu_particles.spread)
	print("    gravity: ", cpu_particles.gravity)
	print("    initial_velocity: %.0f ~ %.0f" % [
		cpu_particles.initial_velocity_min, cpu_particles.initial_velocity_max
	])
	print("    color: ", cpu_particles.color)
	print()

	# GPUParticles2D -> CPUParticles2D 변환 (에디터에서)
	print("  에디터에서 변환: GPUParticles2D 선택 -> 'Particle' 메뉴")
	print("  -> 'Convert to CPUParticles2D'")
	print("  (모든 설정이 자동 변환됨)")
	print()

	# -----------------------------------------------------------------
	# 13) 파티클 성능 팁
	# -----------------------------------------------------------------
	print("--- 13. 파티클 성능 팁 ---")

	print("  1. amount는 필요한 만큼만 사용 (시각 품질 vs 성능)")
	print("  2. 모바일에서는 CPUParticles2D가 더 안정적")
	print("  3. fixed_fps 설정으로 일관된 성능 유지")
	print("  4. visibility_rect를 설정하여 화면 밖 컬링")
	print("  5. one_shot + emitting=false로 필요할 때만 재생")
	print("  6. 텍스처 사이즈를 작게 유지 (32x32 ~ 64x64)")
	print("  7. sub_emitter는 성능 부담이 크므로 신중하게")
	print()

	# visibility_rect 설정 예시
	particles.visibility_rect = Rect2(-200, -200, 400, 400)
	print("  visibility_rect 설정: ", particles.visibility_rect)
	print("  (이 영역 밖으로 나가면 파티클 렌더링 중단)")
	print()

	print("=== 03-particles-setup.gd 완료 ===")


# =============================================================================
# 파티클 프리셋 팩토리 함수들
# =============================================================================

# 불꽃(Fire) 이펙트
func _create_fire_particles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 80
	p.lifetime = 1.5
	p.explosiveness = 0.0
	p.randomness = 0.3

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 20.0
	mat.gravity = Vector3(0, -20, 0)  # 불꽃은 위로 (음의 중력)
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 50.0
	mat.scale_min = 3.0
	mat.scale_max = 8.0
	mat.damping_min = 2.0
	mat.damping_max = 5.0

	# 불꽃 색상 그라디언트
	var grad = Gradient.new()
	grad.set_color(0, Color(1.0, 0.9, 0.3, 1.0))     # 밝은 노랑
	grad.add_point(0.3, Color(1.0, 0.5, 0.0, 0.9))   # 주황
	grad.add_point(0.6, Color(0.8, 0.2, 0.0, 0.6))   # 어두운 빨강
	grad.set_color(1, Color(0.3, 0.1, 0.1, 0.0))     # 연기 + 투명
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = grad
	mat.color_ramp = grad_tex

	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 10.0

	p.process_material = mat
	return p


# 폭발(Explosion) 이펙트
func _create_explosion_particles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 120
	p.lifetime = 0.8
	p.one_shot = true
	p.explosiveness = 1.0  # 모든 파티클 동시 방출
	p.emitting = false     # 수동으로 트리거

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0  # 전 방향
	mat.gravity = Vector3(0, 200, 0)  # 중력으로 떨어짐
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 300.0
	mat.scale_min = 2.0
	mat.scale_max = 6.0
	mat.damping_min = 10.0
	mat.damping_max = 20.0

	# 폭발 색상
	var grad = Gradient.new()
	grad.set_color(0, Color.WHITE)
	grad.add_point(0.2, Color.YELLOW)
	grad.add_point(0.5, Color.ORANGE_RED)
	grad.set_color(1, Color(0.2, 0.2, 0.2, 0.0))
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = grad
	mat.color_ramp = grad_tex

	p.process_material = mat
	return p


# 비(Rain) 이펙트
func _create_rain_particles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 200
	p.lifetime = 1.5

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0.1, 1, 0)  # 약간 기울어진 비
	mat.spread = 5.0
	mat.gravity = Vector3(0, 400, 0)
	mat.initial_velocity_min = 200.0
	mat.initial_velocity_max = 300.0
	mat.scale_min = 1.0
	mat.scale_max = 2.0

	mat.color = Color(0.6, 0.7, 0.9, 0.6)

	# 넓은 영역에서 방출
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(400, 0, 0)

	p.process_material = mat
	return p


# 눈(Snow) 이펙트
func _create_snow_particles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 100
	p.lifetime = 5.0
	p.randomness = 0.5

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 15.0
	mat.gravity = Vector3(0, 30, 0)  # 느린 중력
	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 30.0
	mat.angular_velocity_min = -45.0
	mat.angular_velocity_max = 45.0
	mat.tangential_accel_min = -5.0
	mat.tangential_accel_max = 5.0  # 좌우 흔들림
	mat.scale_min = 2.0
	mat.scale_max = 5.0

	mat.color = Color(1.0, 1.0, 1.0, 0.8)

	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(400, 0, 0)

	p.process_material = mat
	return p


# 스파크(Spark) 이펙트
func _create_spark_particles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 40
	p.lifetime = 0.6
	p.one_shot = true
	p.explosiveness = 0.9
	p.emitting = false

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.gravity = Vector3(0, 300, 0)
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 250.0
	mat.scale_min = 1.0
	mat.scale_max = 2.0
	mat.damping_min = 5.0
	mat.damping_max = 15.0

	# 스파크 색상 (밝은 노랑 -> 주황 -> 사라짐)
	var grad = Gradient.new()
	grad.set_color(0, Color(1.0, 1.0, 0.8, 1.0))
	grad.add_point(0.3, Color(1.0, 0.8, 0.2, 0.9))
	grad.set_color(1, Color(1.0, 0.4, 0.0, 0.0))
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = grad
	mat.color_ramp = grad_tex

	p.process_material = mat
	return p


# 파티클 요약 출력
func _print_particle_summary(p: GPUParticles2D, indent: String = ""):
	print("%s  amount=%d, lifetime=%.1fs, one_shot=%s, explosiveness=%.1f" % [
		indent, p.amount, p.lifetime, p.one_shot, p.explosiveness
	])
	if p.process_material is ParticleProcessMaterial:
		var mat: ParticleProcessMaterial = p.process_material
		print("%s  direction=%s, spread=%.0f, gravity=%s" % [
			indent, mat.direction, mat.spread, mat.gravity
		])
		print("%s  velocity=%.0f~%.0f, scale=%.0f~%.0f" % [
			indent, mat.initial_velocity_min, mat.initial_velocity_max,
			mat.scale_min, mat.scale_max
		])
