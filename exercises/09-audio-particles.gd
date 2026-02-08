# 챕터 9: 오디오와 파티클
#
# 이 챕터에서는 다음을 학습합니다:
# - AudioStreamPlayer를 코드로 생성하고 제어하기
# - 볼륨(dB)과 피치 조절
# - AudioServer를 통한 오디오 버스 제어
# - GPUParticles2D 설정 및 파라미터 조정
# - 폭발, 연기 등 파티클 프리셋 만들기

extends Node2D

# ============================================================
# 연습 1: AudioStreamPlayer 설정
# ============================================================
# AudioStreamPlayer를 코드로 생성하고 기본 속성을 설정합니다.
# 배경음악(BGM)과 효과음(SFX)을 재생하는 기본 구조입니다.

func create_audio_player(bus_name: String, volume_db: float) -> AudioStreamPlayer:
	# TODO: AudioStreamPlayer를 생성하세요
	# TODO: bus 속성을 bus_name으로 설정하세요
	# TODO: volume_db 속성을 volume_db 파라미터로 설정하세요
	# TODO: autoplay를 false로 설정하세요
	# TODO: 생성한 AudioStreamPlayer를 반환하세요
	var player = null  # 여기를 수정하세요
	return player

func play_sound(player: AudioStreamPlayer, stream: AudioStream) -> void:
	# TODO: player가 null이면 return하세요
	# TODO: player.stream을 stream으로 설정하세요
	# TODO: player.play()을 호출하세요
	pass  # 여기를 수정하세요

func stop_with_fade(player: AudioStreamPlayer, duration: float) -> Tween:
	# TODO: player가 null이면 null을 반환하세요
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: tween_property로 "volume_db"를 -80.0까지 duration 동안 낮추세요
	#       (힌트: -80dB는 사실상 무음입니다)
	# TODO: tween.tween_callback(player.stop)으로 페이드 완료 후 정지하세요
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween


# ============================================================
# 연습 2: 볼륨/피치 조절 함수
# ============================================================
# 볼륨과 피치를 동적으로 조절하는 유틸리티 함수를 만듭니다.
# 슬로우모션 효과, 거리 기반 소리 감쇠 등에 활용됩니다.

func set_volume_percent(player: AudioStreamPlayer, percent: float) -> void:
	# TODO: percent를 0.0 ~ 100.0 범위로 clamp하세요
	# TODO: 퍼센트를 dB로 변환하세요:
	#       - 0%이면 volume_db를 -80.0으로 설정 (무음)
	#       - 그 외에는 linear_to_db(percent / 100.0)을 사용하세요
	# TODO: player.volume_db에 변환된 값을 설정하세요
	pass  # 여기를 수정하세요

func set_slowmo_pitch(player: AudioStreamPlayer, time_scale: float) -> void:
	# TODO: time_scale을 0.1 ~ 3.0 범위로 clamp하세요
	# TODO: player.pitch_scale을 time_scale로 설정하세요
	#       (시간이 느려지면 피치도 낮아지는 효과)
	pass  # 여기를 수정하세요

func volume_percent_to_db(percent: float) -> float:
	# TODO: percent(0~100)를 dB 값으로 변환하여 반환하세요
	# TODO: 0%이면 -80.0을 반환하세요
	# TODO: 그 외에는 linear_to_db(percent / 100.0)을 반환하세요
	var db = 0.0  # 여기를 수정하세요
	return db


# ============================================================
# 연습 3: AudioBus 음량 조절
# ============================================================
# AudioServer를 사용하여 오디오 버스의 볼륨을 조절합니다.
# Master, BGM, SFX 등 버스별로 독립적인 음량 제어가 가능합니다.

func get_bus_volume_percent(bus_name: String) -> float:
	# TODO: AudioServer.get_bus_index(bus_name)으로 버스 인덱스를 구하세요
	# TODO: 인덱스가 -1이면 (존재하지 않는 버스) 0.0을 반환하세요
	# TODO: AudioServer.get_bus_volume_db(bus_idx)로 dB 값을 구하세요
	# TODO: db_to_linear(db) * 100.0으로 퍼센트 값을 계산하여 반환하세요
	var percent = 0.0  # 여기를 수정하세요
	return percent

func set_bus_volume_percent(bus_name: String, percent: float) -> void:
	# TODO: AudioServer.get_bus_index(bus_name)으로 버스 인덱스를 구하세요
	# TODO: 인덱스가 -1이면 return하세요
	# TODO: percent를 0.0 ~ 100.0 범위로 clamp하세요
	# TODO: 퍼센트를 dB로 변환하세요 (volume_percent_to_db 함수 활용)
	# TODO: AudioServer.set_bus_volume_db(bus_idx, db)로 볼륨을 설정하세요
	pass  # 여기를 수정하세요

func set_bus_mute(bus_name: String, muted: bool) -> void:
	# TODO: AudioServer.get_bus_index(bus_name)으로 버스 인덱스를 구하세요
	# TODO: 인덱스가 -1이면 return하세요
	# TODO: AudioServer.set_bus_mute(bus_idx, muted)로 음소거를 설정하세요
	pass  # 여기를 수정하세요


# ============================================================
# 연습 4: GPUParticles2D 설정
# ============================================================
# GPUParticles2D를 코드로 생성하고 ParticleProcessMaterial을 설정합니다.
# 파티클 시스템의 기본 구조를 이해합니다.

func create_basic_particles() -> GPUParticles2D:
	# TODO: GPUParticles2D를 생성하세요
	# TODO: ParticleProcessMaterial을 생성하세요
	# TODO: 머티리얼의 속성을 설정하세요:
	#       - direction = Vector3(0, -1, 0)  (위로 방출)
	#       - initial_velocity_min = 50.0
	#       - initial_velocity_max = 100.0
	#       - gravity = Vector3(0, 98, 0)  (중력 영향)
	#       - spread = 30.0  (퍼짐 각도)
	#       - scale_min = 0.5
	#       - scale_max = 1.5
	# TODO: 파티클 노드의 속성을 설정하세요:
	#       - process_material = 위에서 생성한 머티리얼
	#       - amount = 20
	#       - lifetime = 1.5
	#       - one_shot = false
	#       - emitting = false  (수동으로 시작)
	# TODO: 생성한 GPUParticles2D를 반환하세요
	var particles = null  # 여기를 수정하세요
	return particles


# ============================================================
# 연습 5: 파티클 프리셋 함수 (폭발)
# ============================================================
# 폭발 효과 파티클을 생성하는 프리셋 함수입니다.
# one_shot 모드로 한 번만 재생되고 자동으로 제거됩니다.

func create_explosion_effect(pos: Vector2, particle_count: int, color: Color) -> GPUParticles2D:
	# TODO: GPUParticles2D를 생성하세요
	# TODO: position을 pos로 설정하세요
	# TODO: ParticleProcessMaterial을 생성하세요
	# TODO: 머티리얼의 속성을 설정하세요:
	#       - direction = Vector3(0, 0, 0)  (전 방향)
	#       - spread = 180.0  (완전한 원형 퍼짐)
	#       - initial_velocity_min = 100.0
	#       - initial_velocity_max = 300.0
	#       - gravity = Vector3(0, 200, 0)  (약간의 중력)
	#       - damping_min = 2.0
	#       - damping_max = 5.0
	#       - scale_min = 0.3
	#       - scale_max = 1.0
	#       - color = color 파라미터로 설정
	# TODO: 파티클 노드의 속성을 설정하세요:
	#       - process_material = 위에서 생성한 머티리얼
	#       - amount = particle_count
	#       - lifetime = 0.8
	#       - one_shot = true  (한 번만 재생)
	#       - explosiveness = 1.0  (모든 파티클 동시 방출)
	#       - emitting = true  (즉시 시작)
	# TODO: 파티클 종료 후 자동 삭제를 위한 타이머를 설정하세요:
	#       - 트리에 추가 후 get_tree().create_timer(1.5).timeout 시그널에
	#         particles.queue_free를 연결하세요
	#       (힌트: 이 함수 안에서는 add_child 후 타이머를 연결하세요)
	# TODO: 생성한 GPUParticles2D를 반환하세요
	var particles = null  # 여기를 수정하세요
	return particles

func spawn_explosion_at(pos: Vector2) -> void:
	# TODO: create_explosion_effect를 호출하세요
	#       - pos: pos 파라미터
	#       - particle_count: 30
	#       - color: Color.ORANGE
	# TODO: 생성된 파티클을 add_child로 씬에 추가하세요
	# TODO: "폭발 효과 생성: {pos}"를 출력하세요
	pass  # 여기를 수정하세요


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 9: 오디오와 파티클 ===")
	print("")

	# 테스트 1: AudioStreamPlayer 생성
	var bgm_player = create_audio_player("Master", -10.0)
	if bgm_player != null:
		print("결과 1 (AudioStreamPlayer 생성):", bgm_player is AudioStreamPlayer)
		print("결과 1 (버스):", bgm_player.bus)
		print("결과 1 (볼륨 dB):", bgm_player.volume_db)
		print("결과 1 (자동 재생):", bgm_player.autoplay)
		add_child(bgm_player)
	else:
		print("결과 1: null - AudioStreamPlayer를 생성하세요")
	print("")

	# 테스트 2: 볼륨/피치 조절
	var test_player = AudioStreamPlayer.new()
	add_child(test_player)
	set_volume_percent(test_player, 50.0)
	print("결과 2 (50% 볼륨 dB):", test_player.volume_db)
	set_volume_percent(test_player, 0.0)
	print("결과 2 (0% 볼륨 dB):", test_player.volume_db)
	set_volume_percent(test_player, 100.0)
	print("결과 2 (100% 볼륨 dB):", test_player.volume_db)
	set_slowmo_pitch(test_player, 0.5)
	print("결과 2 (슬로우모션 피치):", test_player.pitch_scale)
	var db_50 = volume_percent_to_db(50.0)
	var db_0 = volume_percent_to_db(0.0)
	print("결과 2 (50% -> dB):", db_50)
	print("결과 2 (0% -> dB):", db_0)
	print("")

	# 테스트 3: AudioBus 음량
	var master_vol = get_bus_volume_percent("Master")
	print("결과 3 (Master 볼륨 %):", master_vol)
	set_bus_volume_percent("Master", 80.0)
	var new_vol = get_bus_volume_percent("Master")
	print("결과 3 (Master 80% 설정 후):", new_vol)
	# 원래 볼륨으로 복원
	set_bus_volume_percent("Master", 100.0)
	var nonexist_vol = get_bus_volume_percent("NonExistentBus")
	print("결과 3 (존재하지 않는 버스):", nonexist_vol)
	print("")

	# 테스트 4: GPUParticles2D 생성
	var particles = create_basic_particles()
	if particles != null:
		print("결과 4 (GPUParticles2D 생성):", particles is GPUParticles2D)
		print("결과 4 (파티클 수):", particles.amount)
		print("결과 4 (수명):", particles.lifetime)
		print("결과 4 (방출 중):", particles.emitting)
		print("결과 4 (머티리얼 존재):", particles.process_material != null)
		add_child(particles)
	else:
		print("결과 4: null - GPUParticles2D를 생성하세요")
	print("")

	# 테스트 5: 폭발 파티클 프리셋
	var explosion = create_explosion_effect(Vector2(400, 300), 30, Color.ORANGE)
	if explosion != null:
		print("결과 5 (폭발 파티클 생성):", explosion is GPUParticles2D)
		print("결과 5 (위치):", explosion.position)
		print("결과 5 (one_shot):", explosion.one_shot)
		print("결과 5 (explosiveness):", explosion.explosiveness)
		print("결과 5 (방출 중):", explosion.emitting)
		add_child(explosion)
	else:
		print("결과 5: null - 폭발 파티클을 생성하세요")
	print("")

	print("=== 챕터 9 완료 ===")
