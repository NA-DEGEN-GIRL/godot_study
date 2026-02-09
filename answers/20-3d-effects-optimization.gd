# 챕터 20: 3D 이펙트와 최적화 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - GPUParticles3D로 3D 파티클 이펙트 생성
# - 폭발/불/연기 파티클 프리셋
# - Decal로 표면에 이미지 투사
# - LOD (Level of Detail) 거리별 디테일 전환
# - Occlusion Culling 차폐 컬링
# - 3D 성능 최적화 기법 종합

extends Node3D


func _ready():
	print("=== 챕터 20: 3D 이펙트와 최적화 ===\n")

	# 연습 1: GPUParticles3D 기본
	_exercise_1_gpu_particles_3d()

	# 연습 2: 파티클 프리셋 (불, 연기, 폭발)
	_exercise_2_particle_presets()

	# 연습 3: Decal
	_exercise_3_decal()

	# 연습 4: LOD (Level of Detail)
	_exercise_4_lod()

	# 연습 5: Occlusion Culling
	_exercise_5_occlusion_culling()

	# 연습 6: 3D 성능 최적화 종합
	_exercise_6_performance_optimization()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: GPUParticles3D (기본 설정 + 방출 형태) 생성 완료")
	print("결과 2: 파티클 프리셋 (불꽃, 연기, 폭발) 3종 생성 완료")
	print("결과 3: Decal (표면 투사 + 총알 자국) 구현 완료")
	print("결과 4: LOD (거리별 메시 전환 + HLOD) 구현 완료")
	print("결과 5: Occlusion Culling (OccluderInstance3D) 설정 완료")
	print("결과 6: 3D 성능 최적화 (렌더링 + 물리 + 코드) 체크리스트 완료")


# ==============================================================================
# 연습 1: GPUParticles3D - 3D 파티클 시스템의 기본을 설정하고
#          다양한 방출 형태를 구현하세요.
# ==============================================================================
func _exercise_1_gpu_particles_3d():
	# 풀이: GPUParticles3D는 GPU에서 계산되는 3D 파티클 시스템입니다.
	#       ParticleProcessMaterial로 물리와 시각 속성을 설정합니다.
	#       2D 파티클과 비슷하지만 3D 공간에서 동작합니다.
	#       direction이 Vector3이고, 방출 형태에 SPHERE, BOX, RING 등을 사용합니다.

	print("연습 1: GPUParticles3D 기본")

	# GPUParticles3D 생성
	var particles := GPUParticles3D.new()
	particles.name = "BasicParticles"
	particles.amount = 100
	particles.lifetime = 2.0
	particles.explosiveness = 0.0       # 0=균일 방출, 1=동시 방출
	particles.randomness = 0.5
	particles.fixed_fps = 0             # 0=무제한, 양수=고정 FPS
	particles.position = Vector3(0, 2, 0)

	# 메시 설정 (파티클의 시각적 형태)
	# 풀이: draw_pass_1에 메시를 할당하면 각 파티클이 해당 메시로 렌더링됩니다.
	#       QuadMesh (평면), SphereMesh (구), BoxMesh (상자) 등을 사용합니다.
	var quad := QuadMesh.new()
	quad.size = Vector2(0.1, 0.1)
	particles.draw_pass_1 = quad

	# ParticleProcessMaterial 설정
	var mat := ParticleProcessMaterial.new()
	particles.process_material = mat

	# 방향과 속도
	mat.direction = Vector3(0, 1, 0)      # 위쪽 방출
	mat.spread = 30.0                      # 퍼짐 각도 (도)
	mat.flatness = 0.0                     # 0=구형 퍼짐, 1=평면 퍼짐
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0

	# 중력
	mat.gravity = Vector3(0, -2.0, 0)     # 약한 중력

	# 크기
	mat.scale_min = 0.5
	mat.scale_max = 1.5

	# 감쇠
	mat.damping_min = 1.0
	mat.damping_max = 3.0

	add_child(particles)

	print("  GPUParticles3D 기본 설정:")
	print("    amount: %d" % particles.amount)
	print("    lifetime: %.1f초" % particles.lifetime)
	print("    explosiveness: %.1f" % particles.explosiveness)
	print("    draw_pass_1: QuadMesh (0.1x0.1)")
	print()

	print("  ParticleProcessMaterial:")
	print("    direction: %s (방출 방향)" % mat.direction)
	print("    spread: %.0f도 (퍼짐)" % mat.spread)
	print("    velocity: %.1f ~ %.1f" % [mat.initial_velocity_min, mat.initial_velocity_max])
	print("    gravity: %s" % mat.gravity)
	print("    scale: %.1f ~ %.1f" % [mat.scale_min, mat.scale_max])
	print("    damping: %.1f ~ %.1f" % [mat.damping_min, mat.damping_max])
	print()

	# 방출 형태 (Emission Shape)
	print("  방출 형태 (Emission Shape):")

	# Sphere 방출
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 1.0
	print("    SPHERE: 구 내부에서 방출 (r=%.1f)" % mat.emission_sphere_radius)

	# Box 방출
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(2, 0.5, 2)
	print("    BOX: 상자 내부에서 방출 (%s)" % mat.emission_box_extents)

	# Ring 방출
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	mat.emission_ring_radius = 3.0
	mat.emission_ring_inner_radius = 2.0
	mat.emission_ring_height = 0.5
	mat.emission_ring_axis = Vector3(0, 1, 0)
	print("    RING: 링 형태 방출 (r=%.1f, inner=%.1f)" % [
		mat.emission_ring_radius, mat.emission_ring_inner_radius
	])

	# Point로 복원
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	print("    POINT: 한 점에서 방출 (기본)")
	print()

	# Billboard 모드
	print("  Billboard 모드 (카메라 방향):")
	print("    BILLBOARD_DISABLED: 회전 없음 (3D 메시)")
	print("    BILLBOARD_ENABLED: 항상 카메라를 향함")
	print("    BILLBOARD_Y_ONLY: Y축만 카메라 향함 (나무 등)")
	print("    BILLBOARD_PARTICLES: 파티클 전용 빌보드")

	print("연습 1 완료: GPUParticles3D 기본\n")


# ==============================================================================
# 연습 2: 파티클 프리셋 - 불꽃, 연기, 폭발 이펙트를 만드세요.
# ==============================================================================
func _exercise_2_particle_presets():
	# 풀이: 각 이펙트에 맞는 ParticleProcessMaterial 파라미터를 조합합니다.
	#       색상 그라디언트(color_ramp)와 크기 커브(scale_curve)를 사용하여
	#       수명에 따라 시각적 속성을 변화시킵니다.

	print("연습 2: 파티클 프리셋")

	# === 1) 불꽃 이펙트 ===
	var fire := GPUParticles3D.new()
	fire.name = "FireFX"
	fire.amount = 80
	fire.lifetime = 1.0
	fire.position = Vector3(-4, 0.5, 0)

	var fire_quad := QuadMesh.new()
	fire_quad.size = Vector2(0.3, 0.3)
	fire.draw_pass_1 = fire_quad

	var fire_mat := ParticleProcessMaterial.new()
	fire.process_material = fire_mat

	fire_mat.direction = Vector3(0, 1, 0)
	fire_mat.spread = 15.0
	fire_mat.gravity = Vector3(0, -0.5, 0)  # 약간의 위쪽 가속 (뜨거운 공기)
	fire_mat.initial_velocity_min = 1.0
	fire_mat.initial_velocity_max = 3.0
	fire_mat.damping_min = 1.0
	fire_mat.damping_max = 2.0
	fire_mat.scale_min = 0.5
	fire_mat.scale_max = 1.5

	# 불꽃 색상 그라디언트
	var fire_grad := Gradient.new()
	fire_grad.set_color(0, Color(1.0, 0.9, 0.3, 1.0))     # 밝은 노랑
	fire_grad.add_point(0.3, Color(1.0, 0.5, 0.0, 0.9))   # 주황
	fire_grad.add_point(0.6, Color(0.8, 0.1, 0.0, 0.6))   # 빨강
	fire_grad.set_color(1, Color(0.2, 0.0, 0.0, 0.0))     # 어둡고 투명

	var fire_grad_tex := GradientTexture1D.new()
	fire_grad_tex.gradient = fire_grad
	fire_mat.color_ramp = fire_grad_tex

	# 크기 커브 (작게 시작 -> 커짐 -> 사라짐)
	var fire_curve := Curve.new()
	fire_curve.add_point(Vector2(0.0, 0.0))
	fire_curve.add_point(Vector2(0.1, 1.0))
	fire_curve.add_point(Vector2(0.7, 0.8))
	fire_curve.add_point(Vector2(1.0, 0.0))
	var fire_curve_tex := CurveTexture.new()
	fire_curve_tex.curve = fire_curve
	fire_mat.scale_curve = fire_curve_tex

	# 방출 형태 (원형 바닥)
	fire_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	fire_mat.emission_sphere_radius = 0.3

	add_child(fire)

	print("  1) 불꽃 이펙트:")
	print("    amount: %d, lifetime: %.1f초" % [fire.amount, fire.lifetime])
	print("    spread: %.0f도, velocity: %.1f~%.1f" % [
		fire_mat.spread, fire_mat.initial_velocity_min, fire_mat.initial_velocity_max
	])
	print("    색상: 노랑 -> 주황 -> 빨강 -> 투명")
	print("    크기: 0 -> 1 -> 0.8 -> 0")
	print()

	# === 2) 연기 이펙트 ===
	var smoke := GPUParticles3D.new()
	smoke.name = "SmokeFX"
	smoke.amount = 40
	smoke.lifetime = 3.0
	smoke.position = Vector3(-4, 1.5, 0)  # 불꽃 위에

	var smoke_quad := QuadMesh.new()
	smoke_quad.size = Vector2(0.5, 0.5)
	smoke.draw_pass_1 = smoke_quad

	var smoke_mat := ParticleProcessMaterial.new()
	smoke.process_material = smoke_mat

	smoke_mat.direction = Vector3(0, 1, 0)
	smoke_mat.spread = 25.0
	smoke_mat.gravity = Vector3(0.3, -0.2, 0)  # 바람에 의한 수평 이동
	smoke_mat.initial_velocity_min = 0.5
	smoke_mat.initial_velocity_max = 1.5
	smoke_mat.damping_min = 0.5
	smoke_mat.damping_max = 1.0
	smoke_mat.scale_min = 1.0
	smoke_mat.scale_max = 3.0

	# 연기 색상 (회색 -> 투명)
	var smoke_grad := Gradient.new()
	smoke_grad.set_color(0, Color(0.3, 0.3, 0.3, 0.5))
	smoke_grad.add_point(0.4, Color(0.4, 0.4, 0.4, 0.3))
	smoke_grad.set_color(1, Color(0.5, 0.5, 0.5, 0.0))

	var smoke_grad_tex := GradientTexture1D.new()
	smoke_grad_tex.gradient = smoke_grad
	smoke_mat.color_ramp = smoke_grad_tex

	# 연기 크기 (커지면서 사라짐)
	var smoke_curve := Curve.new()
	smoke_curve.add_point(Vector2(0.0, 0.3))
	smoke_curve.add_point(Vector2(0.5, 0.7))
	smoke_curve.add_point(Vector2(1.0, 1.0))
	var smoke_curve_tex := CurveTexture.new()
	smoke_curve_tex.curve = smoke_curve
	smoke_mat.scale_curve = smoke_curve_tex

	add_child(smoke)

	print("  2) 연기 이펙트:")
	print("    amount: %d, lifetime: %.1f초" % [smoke.amount, smoke.lifetime])
	print("    gravity: %s (바람 영향)" % smoke_mat.gravity)
	print("    색상: 회색 -> 투명")
	print("    크기: 작게 -> 크게 (퍼짐)")
	print()

	# === 3) 폭발 이펙트 ===
	var explosion := GPUParticles3D.new()
	explosion.name = "ExplosionFX"
	explosion.amount = 200
	explosion.lifetime = 0.8
	explosion.one_shot = true               # 한 번만 방출
	explosion.explosiveness = 1.0           # 동시 방출
	explosion.emitting = false              # 수동 트리거
	explosion.position = Vector3(4, 1, 0)

	var explosion_quad := QuadMesh.new()
	explosion_quad.size = Vector2(0.15, 0.15)
	explosion.draw_pass_1 = explosion_quad

	var explosion_mat := ParticleProcessMaterial.new()
	explosion.process_material = explosion_mat

	explosion_mat.direction = Vector3(0, 0, 0)
	explosion_mat.spread = 180.0             # 전 방향
	explosion_mat.gravity = Vector3(0, 5, 0) # 위로 약간 (열기)
	explosion_mat.initial_velocity_min = 5.0
	explosion_mat.initial_velocity_max = 15.0
	explosion_mat.damping_min = 5.0
	explosion_mat.damping_max = 10.0

	# 폭발 색상 (흰색 -> 노랑 -> 빨강 -> 연기)
	var exp_grad := Gradient.new()
	exp_grad.set_color(0, Color.WHITE)
	exp_grad.add_point(0.1, Color.YELLOW)
	exp_grad.add_point(0.3, Color.ORANGE_RED)
	exp_grad.add_point(0.6, Color(0.3, 0.1, 0.0, 0.5))
	exp_grad.set_color(1, Color(0.1, 0.1, 0.1, 0.0))

	var exp_grad_tex := GradientTexture1D.new()
	exp_grad_tex.gradient = exp_grad
	explosion_mat.color_ramp = exp_grad_tex

	add_child(explosion)

	# 트리거
	explosion.emitting = true

	print("  3) 폭발 이펙트:")
	print("    amount: %d, lifetime: %.1f초" % [explosion.amount, explosion.lifetime])
	print("    one_shot: %s, explosiveness: %.1f" % [explosion.one_shot, explosion.explosiveness])
	print("    spread: 180도 (전방향)")
	print("    velocity: %.1f ~ %.1f (빠른 확산)" % [
		explosion_mat.initial_velocity_min, explosion_mat.initial_velocity_max
	])
	print("    색상: 흰색 -> 노랑 -> 빨강 -> 연기 -> 투명")
	print()

	# 이펙트 트리거 방법
	print("  이펙트 트리거:")
	print("    explosion.emitting = true     # 재생 시작")
	print("    explosion.restart()           # 재시작")
	print("    explosion.finished.connect()  # 완료 시그널")
	print()
	print("  일회성 이펙트 패턴:")
	print("    func spawn_explosion(pos: Vector3):")
	print("        var fx = explosion_scene.instantiate()")
	print("        fx.position = pos")
	print("        fx.emitting = true")
	print("        add_child(fx)")
	print("        fx.finished.connect(fx.queue_free)")

	print("연습 2 완료: 파티클 프리셋\n")


# ==============================================================================
# 연습 3: Decal - 표면에 이미지를 투사하는 데칼을 생성하세요.
#          총알 자국, 피 자국, 발자국 등에 사용합니다.
# ==============================================================================
func _exercise_3_decal():
	# 풀이: Decal 노드는 주변 표면에 텍스처를 투사합니다.
	#       size로 투사 영역 크기를 설정하고, 방향(로컬 -Y)이 투사 방향입니다.
	#       albedo_mix로 기존 색상과의 혼합 비율을 조절합니다.
	#       cull_mask로 어떤 레이어의 오브젝트에 투사할지 설정합니다.

	print("연습 3: Decal (표면 투사)")

	# Decal 생성
	var decal := Decal.new()
	decal.name = "BulletHole"
	decal.position = Vector3(0, 0.05, 2)  # 바닥 바로 위
	decal.size = Vector3(0.5, 1.0, 0.5)   # 투사 영역 (가로, 높이, 세로)
	decal.cull_mask = 0xFFFFFFFF           # 모든 레이어에 투사
	decal.albedo_mix = 0.8                 # 80% 적용 (투명도)
	decal.modulate = Color(0.2, 0.2, 0.2, 0.9)  # 어둡게
	add_child(decal)

	print("  Decal 기본 설정:")
	print("    position: %s" % decal.position)
	print("    size: %s (투사 영역)" % decal.size)
	print("    albedo_mix: %.1f (기존 색상과 혼합)" % decal.albedo_mix)
	print("    modulate: %s" % decal.modulate)
	print()

	# Decal 텍스처 종류
	print("  Decal 텍스처 종류:")
	print("    texture_albedo: 색상 텍스처 (주 이미지)")
	print("    texture_normal: 노멀 맵 (표면 디테일)")
	print("    texture_orm: ORM 맵 (AO, Roughness, Metallic)")
	print("    texture_emission: 발광 텍스처")
	print()

	# 총알 자국 시스템
	print("  총알 자국 시스템:")
	print("  ```gdscript")
	print("  const MAX_DECALS = 50")
	print("  var decal_pool: Array[Decal] = []")
	print("  var decal_index: int = 0")
	print("")
	print("  func spawn_bullet_hole(hit_pos: Vector3, hit_normal: Vector3):")
	print("      var decal: Decal")
	print("      if decal_pool.size() < MAX_DECALS:")
	print("          decal = Decal.new()")
	print("          decal.size = Vector3(0.2, 0.5, 0.2)")
	print("          decal.texture_albedo = bullet_hole_texture")
	print("          add_child(decal)")
	print("          decal_pool.append(decal)")
	print("      else:")
	print("          decal = decal_pool[decal_index]")
	print("          decal_index = (decal_index + 1) % MAX_DECALS")
	print("")
	print("      decal.global_position = hit_pos + hit_normal * 0.01")
	print("")
	print("      # 법선 방향으로 회전 (표면에 맞추기)")
	print("      if hit_normal != Vector3.UP:")
	print("          decal.look_at(hit_pos + hit_normal)")
	print("          decal.rotate_object_local(Vector3.RIGHT, PI/2)")
	print("  ```")
	print()

	# Decal 주의사항
	print("  Decal 주의사항:")
	print("    - size.y는 투사 깊이 (얼마나 깊이 투사할지)")
	print("    - 얇은 오브젝트에서는 뒤쪽 면에도 보일 수 있음")
	print("    - lower_fade/upper_fade로 가장자리 부드럽게")
	print("    - 너무 많으면 성능 저하 (오브젝트 풀 사용)")
	print()

	# 시간 경과 페이드
	print("  시간 경과 페이드 (자동 제거):")
	print("    func _spawn_decal_with_fade(pos, normal, lifetime = 5.0):")
	print("        var decal = _create_decal(pos, normal)")
	print("        var tween = create_tween()")
	print("        tween.tween_property(decal, \"modulate:a\", 0.0, 1.0)")
	print("        tween.set_delay(lifetime)")
	print("        tween.tween_callback(decal.queue_free)")

	print("연습 3 완료: Decal\n")


# ==============================================================================
# 연습 4: LOD (Level of Detail) - 거리에 따라 메시 디테일을
#          자동으로 전환하세요.
# ==============================================================================
func _exercise_4_lod():
	# 풀이: LOD는 카메라 거리에 따라 메시의 디테일 레벨을 변경하여
	#       성능을 최적화하는 기법입니다.
	#       Godot 4에서는 여러 방법으로 LOD를 구현할 수 있습니다:
	#       1) 메시 자체 LOD (Mesh.lod_generate)
	#       2) VisibleOnScreenNotifier3D 기반 수동 전환
	#       3) 거리 기반 코드 전환
	#       4) visibility_range (MeshInstance3D)

	print("연습 4: LOD (Level of Detail)")

	# MeshInstance3D visibility_range 사용
	# 풀이: visibility_range_begin/end로 메시가 보이는 거리를 설정합니다.
	#       여러 디테일 레벨의 메시를 겹쳐 놓고 거리별로 표시합니다.
	var lod_parent := Node3D.new()
	lod_parent.name = "TreeLOD"
	lod_parent.position = Vector3(5, 0, -5)

	# LOD 0: 고디테일 (가까이)
	var lod0 := MeshInstance3D.new()
	lod0.name = "LOD0_High"
	var sphere_hi := SphereMesh.new()
	sphere_hi.radius = 1.0
	sphere_hi.height = 2.0
	sphere_hi.radial_segments = 32
	sphere_hi.rings = 16
	lod0.mesh = sphere_hi
	lod0.visibility_range_begin = 0.0
	lod0.visibility_range_end = 20.0       # 0~20m에서 보임
	lod0.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	var mat0 := StandardMaterial3D.new()
	mat0.albedo_color = Color(0.2, 0.6, 0.2)
	lod0.material_override = mat0
	lod_parent.add_child(lod0)

	# LOD 1: 중디테일 (중간)
	var lod1 := MeshInstance3D.new()
	lod1.name = "LOD1_Medium"
	var sphere_md := SphereMesh.new()
	sphere_md.radius = 1.0
	sphere_md.height = 2.0
	sphere_md.radial_segments = 16
	sphere_md.rings = 8
	lod1.mesh = sphere_md
	lod1.visibility_range_begin = 20.0     # 20m부터
	lod1.visibility_range_end = 50.0       # 50m까지
	lod1.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	var mat1 := StandardMaterial3D.new()
	mat1.albedo_color = Color(0.2, 0.55, 0.2)
	lod1.material_override = mat1
	lod_parent.add_child(lod1)

	# LOD 2: 저디테일 (멀리)
	var lod2 := MeshInstance3D.new()
	lod2.name = "LOD2_Low"
	var sphere_lo := SphereMesh.new()
	sphere_lo.radius = 1.0
	sphere_lo.height = 2.0
	sphere_lo.radial_segments = 8
	sphere_lo.rings = 4
	lod2.mesh = sphere_lo
	lod2.visibility_range_begin = 50.0     # 50m부터
	lod2.visibility_range_end = 150.0      # 150m까지 (이후 안 보임)
	var mat2 := StandardMaterial3D.new()
	mat2.albedo_color = Color(0.2, 0.5, 0.2)
	lod2.material_override = mat2
	lod_parent.add_child(lod2)

	add_child(lod_parent)

	print("  visibility_range LOD 설정:")
	print("    LOD 0 (고): 0~20m, 32 segments, 16 rings")
	print("    LOD 1 (중): 20~50m, 16 segments, 8 rings")
	print("    LOD 2 (저): 50~150m, 8 segments, 4 rings")
	print("    150m+: 안 보임")
	print()

	print("  visibility_range_fade_mode:")
	print("    DISABLED: 즉시 전환")
	print("    SELF: 자신이 페이드")
	print("    DEPENDENCIES: 의존성 기반 페이드")
	print()

	# 코드 기반 LOD 전환
	print("  코드 기반 LOD (수동):")
	print("  ```gdscript")
	print("  @onready var lod_meshes = [$LOD0, $LOD1, $LOD2]")
	print("  @export var lod_distances = [20.0, 50.0, 150.0]")
	print("")
	print("  func _process(delta):")
	print("      var cam_pos = get_viewport().get_camera_3d().global_position")
	print("      var dist = global_position.distance_to(cam_pos)")
	print("")
	print("      for i in range(lod_meshes.size()):")
	print("          lod_meshes[i].visible = false")
	print("")
	print("      if dist < lod_distances[0]:")
	print("          lod_meshes[0].visible = true")
	print("      elif dist < lod_distances[1]:")
	print("          lod_meshes[1].visible = true")
	print("      elif dist < lod_distances[2]:")
	print("          lod_meshes[2].visible = true")
	print("  ```")
	print()

	# HLOD 개념
	print("  HLOD (Hierarchical LOD):")
	print("    멀리 있는 여러 오브젝트를 하나의 메시로 합쳐서 렌더링")
	print("    예: 100개의 나무 -> 먼 거리에서 1개의 숲 메시로 대체")
	print("    드로우 콜 대폭 감소")

	print("연습 4 완료: LOD\n")


# ==============================================================================
# 연습 5: Occlusion Culling - 다른 오브젝트에 가려진 오브젝트를
#          렌더링에서 제외하세요.
# ==============================================================================
func _exercise_5_occlusion_culling():
	# 풀이: Occlusion Culling은 카메라에서 보이지 않는(다른 오브젝트에 가려진)
	#       오브젝트를 렌더링에서 제외하여 성능을 최적화합니다.
	#       Godot 4에서는 OccluderInstance3D 노드를 사용합니다.
	#       프로젝트 설정에서 occlusion culling을 활성화해야 합니다.

	print("연습 5: Occlusion Culling (차폐 컬링)")

	# OccluderInstance3D 생성
	# 풀이: OccluderInstance3D는 다른 오브젝트를 가리는 "차폐체"를 정의합니다.
	#       큰 벽, 건물 등에 배치하면 뒤에 있는 오브젝트가 렌더링되지 않습니다.
	var occluder := OccluderInstance3D.new()
	occluder.name = "WallOccluder"
	occluder.position = Vector3(0, 2, -5)

	# BoxOccluder3D 생성
	var box_occluder := BoxOccluder3D.new()
	box_occluder.size = Vector3(10, 4, 0.5)  # 넓은 벽
	occluder.occluder = box_occluder

	add_child(occluder)

	print("  OccluderInstance3D 생성:")
	print("    position: %s" % occluder.position)
	print("    occluder: BoxOccluder3D")
	print("    size: %s" % box_occluder.size)
	print()

	# Occluder 종류
	print("  Occluder 종류:")
	print("    BoxOccluder3D: 직육면체 차폐 (벽, 건물)")
	print("    SphereOccluder3D: 구형 차폐 (큰 구체)")
	print("    PolygonOccluder3D: 다각형 차폐 (비정형)")
	print("    QuadOccluder3D: 사각형 평면 차폐 (바닥)")
	print("    ArrayOccluder3D: 메시 기반 차폐 (복잡한 형태)")
	print()

	# 프로젝트 설정
	print("  프로젝트 설정:")
	print("    Rendering > Occlusion Culling > Use Occlusion Culling = On")
	print("    -> 프로젝트 설정에서 활성화해야 동작합니다")
	print()

	# Occlusion Culling 작동 원리
	print("  작동 원리:")
	print("    1. OccluderInstance3D가 '차폐 영역'을 정의")
	print("    2. 카메라 시점에서 차폐체 뒤에 있는 오브젝트 판별")
	print("    3. 완전히 가려진 오브젝트는 렌더링 생략")
	print("    4. AABB(바운딩 박스) 기준으로 판단")
	print()

	# 자동 차폐 (MeshInstance3D)
	print("  MeshInstance3D 자동 차폐:")
	print("    기본적으로 MeshInstance3D도 차폐체로 사용 가능")
	print("    RenderingServer.mesh_set_shadow_mesh() 활용")
	print()

	# 최적화 팁
	print("  Occlusion Culling 팁:")
	print("    1. 큰 정적 오브젝트(벽, 건물)에만 Occluder 배치")
	print("    2. Occluder 형태는 최대한 단순하게 (Box > Polygon)")
	print("    3. 실내 환경에서 가장 효과적")
	print("    4. 실외 넓은 환경에서는 효과 제한적")
	print("    5. 디버그 뷰어로 차폐 상태 확인")
	print()

	# 디버그
	print("  디버그 확인:")
	print("    Viewport > Debug Draw > Occlusion Culling")
	print("    -> 어떤 오브젝트가 컬링되는지 시각화")

	print("연습 5 완료: Occlusion Culling\n")


# ==============================================================================
# 연습 6: 3D 성능 최적화 - 렌더링, 물리, 코드 최적화 기법을
#          종합적으로 정리하세요.
# ==============================================================================
func _exercise_6_performance_optimization():
	# 풀이: 3D 게임 성능 최적화는 렌더링, 물리, 코드, 메모리 4가지 영역에서
	#       병목을 찾아 해결합니다. Godot의 Profiler, Monitor, 디버그 뷰를 활용하여
	#       병목 지점을 파악한 후 적절한 최적화를 적용합니다.

	print("연습 6: 3D 성능 최적화 종합")

	# === 렌더링 최적화 ===
	print("  [렌더링 최적화]")
	print("    [x] LOD (Level of Detail) 적용")
	print("    [x] Occlusion Culling 활성화 (실내 환경)")
	print("    [x] Frustum Culling 확인 (자동, AABB 정확히)")
	print("    [x] MultiMesh로 대량 동일 오브젝트 인스턴싱")
	print("    [x] 그림자 해상도 최적화 (먼 조명은 낮은 해상도)")
	print("    [x] 불필요한 그림자 비활성화 (shadow_enabled = false)")
	print("    [x] 조명 수 제한 (Omni/Spot 최소화)")
	print("    [x] 머티리얼 공유 (같은 머티리얼 리소스 재사용)")
	print("    [x] 텍스처 크기 적절히 (Power of 2, 압축)")
	print("    [x] 후처리 효과 필요한 것만 (SSAO, SSR 선택적)")
	print("    [x] 투명 오브젝트 최소화 (알파 블렌딩 비용 높음)")
	print("    [x] 메시 정점 수 최적화 (보이지 않는 면 제거)")
	print()

	# === 물리 최적화 ===
	print("  [물리 최적화]")
	print("    [x] 충돌 레이어/마스크 최소화 (필요한 것만 활성)")
	print("    [x] 간단한 충돌 형태 사용 (Sphere > Box > Capsule > Convex > Concave)")
	print("    [x] ConcavePolygonShape3D는 StaticBody3D에만 사용")
	print("    [x] 정적 오브젝트는 StaticBody3D 사용 (RigidBody3D 아님)")
	print("    [x] 물리 레이어 불필요한 충돌 비활성화")
	print("    [x] RayCast3D 최소화 (캐시 활용)")
	print("    [x] Area3D.monitoring 필요할 때만 활성화")
	print("    [x] physics_fps 조정 (기본 60, 필요시 30)")
	print()

	# === 코드 최적화 ===
	print("  [코드 최적화]")
	print("    [x] @onready로 노드 참조 캐싱")
	print("    [x] 타입 지정 변수 사용 (var x: int)")
	print("    [x] _process()에서 불필요한 할당 제거")
	print("    [x] distance_squared_to() 사용 (sqrt 생략)")
	print("    [x] 화면 밖 노드 set_process(false)")
	print("    [x] 오브젝트 풀링 (빈번한 생성/삭제)")
	print("    [x] 시그널로 매 프레임 체크 대체")
	print("    [x] 그룹 순회보다 직접 참조")
	print("    [x] String 연결보다 format 사용")
	print()

	# === 메모리 최적화 ===
	print("  [메모리 최적화]")
	print("    [x] 텍스처 압축 (VRAM/S3TC/ETC2)")
	print("    [x] 사용하지 않는 리소스 해제 (queue_free)")
	print("    [x] 텍스처 아틀라스 사용")
	print("    [x] LOD로 원거리 저해상도 메시")
	print("    [x] StreamTexture 사용 (자동 압축/밉맵)")
	print()

	# Performance 모니터
	print("  Performance 모니터링:")
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var objects := Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var memory := Performance.get_monitor(Performance.MEMORY_STATIC)
	var render_objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)

	print("    FPS: %.0f" % fps)
	print("    Object count: %.0f" % objects)
	print("    Node count: %.0f" % nodes)
	print("    Static memory: %.2f MB" % (memory / 1048576.0))
	print("    Render objects: %.0f" % render_objects)
	print("    Draw calls: %.0f" % draw_calls)
	print()

	# 벤치마크: distance_to vs distance_squared_to
	print("  벤치마크: distance_to vs distance_squared_to (%d회)" % 10000)
	var iterations := 10000
	var pos_a := Vector3(100, 50, 200)
	var pos_b := Vector3(500, 100, 600)
	var threshold := 300.0
	var threshold_sq := threshold * threshold

	var start := Time.get_ticks_usec()
	for i in range(iterations):
		var _c := pos_a.distance_to(pos_b) < threshold
	var dist_time := Time.get_ticks_usec() - start

	start = Time.get_ticks_usec()
	for i in range(iterations):
		var _c := pos_a.distance_squared_to(pos_b) < threshold_sq
	var dist_sq_time := Time.get_ticks_usec() - start

	print("    distance_to():         %d us" % dist_time)
	print("    distance_squared_to(): %d us" % dist_sq_time)
	if dist_sq_time > 0:
		print("    squared가 약 %.1fx 빠름" % (float(dist_time) / dist_sq_time))
	print()

	# 프로파일링 도구
	print("  프로파일링 도구:")
	print("    Debugger > Profiler: 함수별 실행 시간")
	print("    Debugger > Monitors: FPS, 메모리, 드로우 콜")
	print("    Debugger > Visual Profiler: GPU 사용량")
	print("    Time.get_ticks_usec(): 코드 구간 벤치마크")
	print("    Performance.get_monitor(): 런타임 모니터")
	print()

	# 플랫폼별 최적화
	print("  플랫폼별 최적화:")
	print("    +----------+----------+----------+----------+")
	print("    | 설정     | Desktop  | Mobile   | Web      |")
	print("    +----------+----------+----------+----------+")
	print("    | SSAO     | ON       | OFF      | OFF      |")
	print("    | SSR      | ON       | OFF      | OFF      |")
	print("    | Glow     | ON       | 낮은품질 | OFF      |")
	print("    | Shadows  | 높음     | 낮음     | 최소     |")
	print("    | LOD 거리 | 넓음     | 좁음     | 좁음     |")
	print("    | 파티클   | 많음     | 적음     | 최소     |")
	print("    | Fog      | Volume   | Depth    | OFF      |")
	print("    +----------+----------+----------+----------+")

	print("연습 6 완료: 3D 성능 최적화 종합\n")
