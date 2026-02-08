# 챕터 9: 오디오 & 파티클 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - AudioStreamPlayer 노드 생성과 재생 제어
# - volume_db, pitch_scale 속성 조절
# - AudioBus 동적 생성과 이펙트 추가
# - GPUParticles2D와 ParticleProcessMaterial 설정
# - 폭발 이펙트 프리셋 만들기

extends Node2D

func _ready():
	print("=== 챕터 9: 오디오 & 파티클 ===\n")

	# 연습 1: AudioStreamPlayer 기초
	var player = _exercise_1_audio_stream_player()

	# 연습 2: 볼륨과 피치 제어
	_exercise_2_volume_pitch(player)

	# 연습 3: AudioBus 설정
	var bus_name = _exercise_3_audio_bus()

	# 연습 4: GPUParticles2D 기본 설정
	var particles = _exercise_4_gpu_particles()

	# 연습 5: 폭발 이펙트 프리셋
	var explosion = _exercise_5_explosion_preset()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: AudioStreamPlayer 생성 - bus='%s', playing=%s" % [
		player.bus, player.playing
	])
	print("결과 2: 볼륨/피치 제어 완료 - volume_db=%.1f, pitch_scale=%.2f" % [
		player.volume_db, player.pitch_scale
	])
	print("결과 3: AudioBus '%s' 생성 완료" % bus_name)
	print("결과 4: GPUParticles2D 생성 - amount=%d, lifetime=%.1f" % [
		particles.amount, particles.lifetime
	])
	print("결과 5: 폭발 프리셋 생성 - one_shot=%s, explosiveness=%.1f" % [
		explosion.one_shot, explosion.explosiveness
	])

	# 정리: 동적으로 추가한 버스 제거
	_cleanup_bus(bus_name)
	player.queue_free()


# ==============================================================================
# 연습 1: AudioStreamPlayer - 오디오 플레이어 노드를 코드로 생성하고
#          기본 속성을 확인하세요.
# ==============================================================================
func _exercise_1_audio_stream_player() -> AudioStreamPlayer:
	# 풀이: AudioStreamPlayer.new()로 인스턴스를 생성하고 add_child로 추가합니다.
	#       volume_db(볼륨), pitch_scale(피치), bus(출력 버스), max_polyphony(동시 재생 수)
	#       등의 기본 속성을 확인합니다. play()로 재생, stop()으로 정지합니다.

	var player = AudioStreamPlayer.new()
	player.name = "SFXPlayer"
	add_child(player)

	# 기본 속성 확인
	print("연습 1: AudioStreamPlayer 생성")
	print("  volume_db: %.1f (0 = 원본 볼륨)" % player.volume_db)
	print("  pitch_scale: %.1f (1.0 = 원본 피치)" % player.pitch_scale)
	print("  max_polyphony: %d (동시 재생 수)" % player.max_polyphony)
	print("  bus: '%s' (출력 버스)" % player.bus)
	print("  playing: %s" % player.playing)
	print()

	# 재생 제어 메서드 정리
	print("  재생 제어 메서드:")
	print("    play(from_position)     - 재생 시작")
	print("    stop()                  - 재생 정지")
	print("    seek(to_position)       - 재생 위치 이동")
	print("    stream_paused = true    - 일시정지")
	print("    get_playback_position() - 현재 위치(초)")
	print()

	# AudioStreamPlayer2D (위치 기반 사운드) 비교
	print("  AudioStreamPlayer 종류:")
	print("    AudioStreamPlayer   - UI/BGM (위치 무관)")
	print("    AudioStreamPlayer2D - 2D 효과음 (거리 감쇠)")
	print("    AudioStreamPlayer3D - 3D 효과음 (공간 음향)")

	# finished 시그널 연결
	player.finished.connect(func():
		print("  >> [시그널] 오디오 재생 완료!")
	)

	print("연습 1 완료: AudioStreamPlayer 노드 생성")
	return player


# ==============================================================================
# 연습 2: 볼륨과 피치 - volume_db와 pitch_scale을 조절하고
#          퍼센트 <-> 데시벨 변환 함수를 구현하세요.
# ==============================================================================
func _exercise_2_volume_pitch(player: AudioStreamPlayer):
	# 풀이: volume_db는 데시벨 단위(-80 ~ +24)로 동작합니다.
	#       linear_to_db()로 0~1 선형 값을 데시벨로 변환하고,
	#       db_to_linear()로 역변환합니다.
	#       pitch_scale은 재생 속도와 음높이를 동시에 변경합니다(1.0 = 원본).
	#       randf_range(0.9, 1.1)로 매번 약간 다른 피치를 적용하면 자연스러운 효과음이 됩니다.

	print("\n연습 2: 볼륨과 피치 제어")

	# 볼륨 제어 (데시벨 스케일)
	print("  볼륨 데시벨 스케일:")
	print("    0 dB   = 원본 볼륨 (100%%)")
	print("    -6 dB  = 약 50%% 볼륨")
	print("    -20 dB = 약 10%% 볼륨")
	print("    -80 dB = 거의 무음")
	print()

	# 퍼센트 -> 데시벨 변환
	print("  퍼센트 -> 데시벨 변환:")
	for pct in [100, 75, 50, 25, 10, 0]:
		var db_val = _percent_to_db(pct)
		print("    %3d%% -> %6.1f dB" % [pct, db_val])
	print()

	# linear_to_db / db_to_linear 유틸리티
	var linear_50 = db_to_linear(-6.0)
	var db_from_50 = linear_to_db(0.5)
	print("  db_to_linear(-6.0) = %.2f" % linear_50)
	print("  linear_to_db(0.5) = %.2f dB" % db_from_50)
	print()

	# 볼륨 설정
	player.volume_db = -6.0
	print("  플레이어 볼륨 설정: %.1f dB (약 50%%)" % player.volume_db)

	# 피치 제어
	print("\n  피치 제어 (pitch_scale):")
	print("    1.0 = 원본 속도/음높이")
	print("    2.0 = 2배속, 한 옥타브 높음")
	print("    0.5 = 반속, 한 옥타브 낮음")
	print()

	# 랜덤 피치 변형 (효과음 다양화)
	print("  랜덤 피치 변형 (효과음 반복 시 자연스러움):")
	for i in range(5):
		var random_pitch = randf_range(0.9, 1.1)
		print("    재생 %d: pitch = %.3f" % [i + 1, random_pitch])

	player.pitch_scale = 1.05
	print("\n  플레이어 피치 설정: %.2f" % player.pitch_scale)

	print("연습 2 완료: 볼륨/피치 제어")


# 퍼센트(0~100)를 데시벨로 변환하는 헬퍼 함수
func _percent_to_db(percent: int) -> float:
	if percent <= 0:
		return -80.0
	return linear_to_db(percent / 100.0)


# ==============================================================================
# 연습 3: AudioBus - AudioServer로 새 버스를 동적 생성하고
#          리버브 이펙트를 추가하세요.
# ==============================================================================
func _exercise_3_audio_bus() -> String:
	# 풀이: AudioServer.add_bus()로 새 버스를 추가하고,
	#       set_bus_name()으로 이름, set_bus_send()로 라우팅 대상,
	#       set_bus_volume_db()로 볼륨을 설정합니다.
	#       AudioEffectReverb.new()로 리버브 이펙트를 생성하고
	#       add_bus_effect()로 버스에 추가합니다.

	print("\n연습 3: AudioBus 동적 생성")

	# 현재 버스 정보
	print("  현재 버스 개수: %d" % AudioServer.bus_count)
	for i in range(AudioServer.bus_count):
		var bname = AudioServer.get_bus_name(i)
		var bvol = AudioServer.get_bus_volume_db(i)
		print("    [%d] '%s': %.1f dB" % [i, bname, bvol])
	print()

	# 새 SFX 버스 생성
	var new_idx = AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(new_idx, "SFX")
	AudioServer.set_bus_send(new_idx, "Master")
	AudioServer.set_bus_volume_db(new_idx, -3.0)
	print("  'SFX' 버스 추가 (인덱스: %d)" % new_idx)
	print("    send -> 'Master'")
	print("    volume: -3.0 dB")
	print()

	# 리버브 이펙트 추가
	var sfx_idx = AudioServer.get_bus_index("SFX")
	var reverb = AudioEffectReverb.new()
	reverb.room_size = 0.6
	reverb.damping = 0.5
	reverb.wet = 0.3
	reverb.dry = 0.7
	AudioServer.add_bus_effect(sfx_idx, reverb)
	print("  SFX 버스에 Reverb 이펙트 추가:")
	print("    room_size: %.1f" % reverb.room_size)
	print("    damping: %.1f" % reverb.damping)
	print("    wet/dry: %.1f / %.1f" % [reverb.wet, reverb.dry])
	print()

	# 리미터 이펙트 추가
	var limiter = AudioEffectLimiter.new()
	limiter.ceiling_db = -0.1
	limiter.threshold_db = -6.0
	AudioServer.add_bus_effect(sfx_idx, limiter)
	print("  SFX 버스에 Limiter 이펙트 추가:")
	print("    ceiling_db: %.1f" % limiter.ceiling_db)
	print("    threshold_db: %.1f" % limiter.threshold_db)
	print()

	# 이펙트 목록 확인
	print("  SFX 버스 이펙트 목록:")
	for i in range(AudioServer.get_bus_effect_count(sfx_idx)):
		var effect = AudioServer.get_bus_effect(sfx_idx, i)
		var enabled = AudioServer.is_bus_effect_enabled(sfx_idx, i)
		print("    [%d] %s (enabled: %s)" % [i, effect.get_class(), enabled])
	print()

	# 뮤트/솔로 시연
	AudioServer.set_bus_mute(sfx_idx, true)
	print("  SFX 뮤트 ON: %s" % AudioServer.is_bus_mute(sfx_idx))
	AudioServer.set_bus_mute(sfx_idx, false)
	print("  SFX 뮤트 OFF: %s" % AudioServer.is_bus_mute(sfx_idx))

	# 최종 버스 구조
	print("\n  최종 버스 구조:")
	for i in range(AudioServer.bus_count):
		var bname = AudioServer.get_bus_name(i)
		var bsend = AudioServer.get_bus_send(i)
		var bvol = AudioServer.get_bus_volume_db(i)
		var effects = AudioServer.get_bus_effect_count(i)
		if bsend == "":
			print("    [%d] %s (%.1f dB, effects=%d) <- 루트" % [i, bname, bvol, effects])
		else:
			print("    [%d] %s (%.1f dB, effects=%d) -> %s" % [i, bname, bvol, effects, bsend])

	print("연습 3 완료: AudioBus 'SFX' 생성 + 이펙트 추가")
	return "SFX"


# 버스 정리 헬퍼
func _cleanup_bus(bus_name: String):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx > 0:
		AudioServer.remove_bus(idx)


# ==============================================================================
# 연습 4: GPUParticles2D - 기본 파티클 시스템을 코드로 설정하세요.
#          방출 형태, 색상 그라디언트, 크기 커브를 포함하세요.
# ==============================================================================
func _exercise_4_gpu_particles() -> GPUParticles2D:
	# 풀이: GPUParticles2D.new()로 파티클 노드를 생성하고,
	#       ParticleProcessMaterial.new()로 처리 머티리얼을 만듭니다.
	#       direction(방출 방향), spread(퍼짐 각도), gravity(중력),
	#       initial_velocity(초기 속도)를 설정합니다.
	#       Gradient + GradientTexture1D로 수명에 따른 색상 변화를,
	#       Curve + CurveTexture로 수명에 따른 크기 변화를 적용합니다.

	print("\n연습 4: GPUParticles2D 기본 설정")

	var particles = GPUParticles2D.new()
	particles.name = "FireParticles"
	particles.amount = 60
	particles.lifetime = 1.5
	particles.explosiveness = 0.0
	particles.randomness = 0.3
	particles.position = Vector2(200, 400)
	add_child(particles)

	print("  기본 속성:")
	print("    amount: %d (파티클 수)" % particles.amount)
	print("    lifetime: %.1f초 (수명)" % particles.lifetime)
	print("    explosiveness: %.1f (0=고르게, 1=한꺼번에)" % particles.explosiveness)
	print("    randomness: %.1f" % particles.randomness)
	print()

	# ParticleProcessMaterial 생성
	var material = ParticleProcessMaterial.new()
	particles.process_material = material

	# 방출 방향과 속도
	material.direction = Vector3(0, -1, 0)  # 위쪽
	material.spread = 25.0
	material.gravity = Vector3(0, -30, 0)  # 위로 떠오름 (음의 중력)
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 50.0
	material.scale_min = 3.0
	material.scale_max = 8.0
	material.damping_min = 2.0
	material.damping_max = 5.0

	print("  물리 파라미터:")
	print("    direction: %s (방출 방향)" % material.direction)
	print("    spread: %.0f도 (퍼짐 각도)" % material.spread)
	print("    gravity: %s (중력)" % material.gravity)
	print("    velocity: %.0f ~ %.0f" % [material.initial_velocity_min, material.initial_velocity_max])
	print("    scale: %.0f ~ %.0f" % [material.scale_min, material.scale_max])
	print()

	# 방출 형태 (구형)
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 10.0
	print("  방출 형태: SPHERE (반지름 %.0f px)" % material.emission_sphere_radius)
	print()

	# 색상 그라디언트 (수명에 따른 색상 변화)
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.9, 0.3, 1.0))     # 시작: 밝은 노랑
	gradient.add_point(0.3, Color(1.0, 0.5, 0.0, 0.9))   # 중간: 주황
	gradient.add_point(0.6, Color(0.8, 0.2, 0.0, 0.6))   # 후반: 어두운 빨강
	gradient.set_color(1, Color(0.3, 0.1, 0.1, 0.0))     # 끝: 연기 + 투명

	var gradient_tex = GradientTexture1D.new()
	gradient_tex.gradient = gradient
	material.color_ramp = gradient_tex

	print("  색상 그라디언트:")
	print("    0%%  -> 밝은 노랑 (alpha=1.0)")
	print("    30%% -> 주황 (alpha=0.9)")
	print("    60%% -> 어두운 빨강 (alpha=0.6)")
	print("    100%% -> 연기색 (alpha=0.0, 투명)")
	print()

	# 크기 커브 (수명에 따른 크기 변화)
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))   # 시작: 크기 0
	scale_curve.add_point(Vector2(0.1, 1.0))   # 10%: 최대
	scale_curve.add_point(Vector2(0.8, 1.0))   # 80%: 유지
	scale_curve.add_point(Vector2(1.0, 0.0))   # 끝: 크기 0

	var scale_curve_tex = CurveTexture.new()
	scale_curve_tex.curve = scale_curve
	material.scale_curve = scale_curve_tex

	print("  크기 커브:")
	print("    0%%  -> 0.0 (나타남)")
	print("    10%% -> 1.0 (빠르게 최대)")
	print("    80%% -> 1.0 (유지)")
	print("    100%% -> 0.0 (사라짐)")

	# visibility_rect 설정 (성능 최적화)
	particles.visibility_rect = Rect2(-200, -300, 400, 400)
	print("\n  visibility_rect: %s (컬링 영역)" % particles.visibility_rect)

	print("연습 4 완료: GPUParticles2D 불꽃 이펙트 생성")
	return particles


# ==============================================================================
# 연습 5: 폭발 프리셋 - one_shot 모드의 폭발 파티클 이펙트를 만드세요.
#          전 방향(spread=180) 방출, 중력 적용, 감쇠 포함.
# ==============================================================================
func _exercise_5_explosion_preset() -> GPUParticles2D:
	# 풀이: one_shot=true, explosiveness=1.0으로 설정하면 모든 파티클이
	#       한꺼번에 방출되는 폭발 효과를 만들 수 있습니다.
	#       spread=180으로 전 방향 방출, 높은 initial_velocity로 빠르게 퍼지고,
	#       damping으로 점차 감속하며, gravity로 아래로 떨어지게 합니다.
	#       emitting=false로 시작하고, 필요할 때 emitting=true 또는 restart()로 트리거합니다.

	print("\n연습 5: 폭발(Explosion) 이펙트 프리셋")

	var explosion = GPUParticles2D.new()
	explosion.name = "ExplosionFX"
	explosion.amount = 120
	explosion.lifetime = 0.8
	explosion.one_shot = true          # 한 번만 방출
	explosion.explosiveness = 1.0      # 모든 파티클 동시 방출
	explosion.emitting = false         # 수동 트리거 대기
	explosion.position = Vector2(500, 300)
	add_child(explosion)

	print("  폭발 파티클 속성:")
	print("    amount: %d" % explosion.amount)
	print("    lifetime: %.1f초" % explosion.lifetime)
	print("    one_shot: %s (한 번만 방출)" % explosion.one_shot)
	print("    explosiveness: %.1f (동시 방출)" % explosion.explosiveness)
	print("    emitting: %s (수동 트리거 대기)" % explosion.emitting)
	print()

	# ParticleProcessMaterial 설정
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0                  # 전 방향
	mat.gravity = Vector3(0, 200, 0)    # 아래로 떨어짐
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 300.0
	mat.scale_min = 2.0
	mat.scale_max = 6.0
	mat.damping_min = 10.0
	mat.damping_max = 20.0
	explosion.process_material = mat

	print("  물리 설정:")
	print("    spread: %.0f도 (전 방향)" % mat.spread)
	print("    gravity: %s (아래로 중력)" % mat.gravity)
	print("    velocity: %.0f ~ %.0f (빠른 초기 속도)" % [
		mat.initial_velocity_min, mat.initial_velocity_max
	])
	print("    damping: %.0f ~ %.0f (감속)" % [mat.damping_min, mat.damping_max])
	print()

	# 폭발 색상 그라디언트 (흰색 -> 노랑 -> 주황빨강 -> 연기)
	var grad = Gradient.new()
	grad.set_color(0, Color.WHITE)                       # 시작: 흰색 섬광
	grad.add_point(0.2, Color.YELLOW)                    # 노랑
	grad.add_point(0.5, Color.ORANGE_RED)                # 주황빨강
	grad.set_color(1, Color(0.2, 0.2, 0.2, 0.0))       # 끝: 연기 + 투명

	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = grad
	mat.color_ramp = grad_tex

	print("  폭발 색상 그라디언트:")
	print("    0%%  -> WHITE (섬광)")
	print("    20%% -> YELLOW")
	print("    50%% -> ORANGE_RED")
	print("    100%% -> 연기색 (투명)")
	print()

	# 트리거 방법 설명
	print("  폭발 트리거 방법:")
	print("    explosion.emitting = true   # 재생 시작")
	print("    explosion.restart()         # 또는 restart()로 재시작")
	print()

	# 트리거 시뮬레이션
	print("  [시뮬레이션] 폭발 트리거!")
	explosion.emitting = true
	print("    emitting = %s (재생 시작됨)" % explosion.emitting)
	print()

	# 자동 제거 패턴 설명
	print("  일회성 이펙트 자동 제거 패턴:")
	print("    explosion.finished.connect(func():")
	print("        explosion.queue_free()")
	print("    )")

	print("연습 5 완료: 폭발 이펙트 프리셋 생성")
	return explosion
