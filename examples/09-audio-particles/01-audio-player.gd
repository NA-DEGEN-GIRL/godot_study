# Chapter 09 - Audio & Particles
# 01-audio-player.gd - 오디오 재생 시스템
#
# 이 파일에서 배울 내용:
# - AudioStreamPlayer / 2D / 3D 노드의 차이점
# - play(), stop(), pause 등 재생 제어
# - volume_db, pitch_scale 속성 조절
# - AudioBus 라우팅 기초
# - 스트림 리소스(WAV, OGG, MP3) 로드

extends Node

# =============================================================================
# 오디오 플레이어 기초
# =============================================================================

# AudioStreamPlayer  - UI 사운드, BGM 등 위치 무관 사운드
# AudioStreamPlayer2D - 2D 공간에서 위치 기반 사운드 (거리 감쇠)
# AudioStreamPlayer3D - 3D 공간에서 위치 기반 사운드

# 주요 오디오 스트림 포맷:
# - AudioStreamWAV (.wav)   : 비압축, 효과음에 적합
# - AudioStreamOggVorbis (.ogg) : 압축, BGM에 적합
# - AudioStreamMP3 (.mp3)   : 압축, BGM에 적합 (Godot 4.x 지원)

func _ready():
	print("=== Chapter 09-1: AudioStreamPlayer 기초 ===\n")

	# -----------------------------------------------------------------
	# 1) AudioStreamPlayer 노드 생성과 기본 설정
	# -----------------------------------------------------------------
	print("--- 1. AudioStreamPlayer 노드 생성 ---")

	var player = AudioStreamPlayer.new()
	add_child(player)

	# 주요 속성 확인
	print("  기본 volume_db: ", player.volume_db)       # 0.0 (원본 볼륨)
	print("  기본 pitch_scale: ", player.pitch_scale)    # 1.0 (원본 피치)
	print("  기본 max_polyphony: ", player.max_polyphony) # 1 (동시 재생 수)
	print("  기본 bus: '", player.bus, "'")               # "Master"
	print("  현재 재생 중: ", player.playing)              # false
	print()

	# -----------------------------------------------------------------
	# 2) 볼륨 제어 (volume_db)
	# -----------------------------------------------------------------
	print("--- 2. 볼륨 제어 (데시벨 스케일) ---")

	# volume_db는 데시벨 단위 (-80 ~ +24 범위)
	# 0 dB = 원본 볼륨, -6 dB = 절반, -INF = 무음
	player.volume_db = 0.0
	print("  0 dB = 원본 볼륨 (100%)")

	player.volume_db = -6.0
	print("  -6 dB = 약 50% 볼륨")

	player.volume_db = -20.0
	print("  -20 dB = 약 10% 볼륨")

	player.volume_db = -80.0
	print("  -80 dB = 거의 무음")

	# 선형 값 <-> 데시벨 변환 유틸리티
	var linear_50_percent = db_to_linear(-6.0)
	var db_from_linear = linear_to_db(0.5)
	print("  db_to_linear(-6.0) = ", snapped(linear_50_percent, 0.01))
	print("  linear_to_db(0.5) = ", snapped(db_from_linear, 0.01), " dB")
	print()

	# 볼륨 변환 헬퍼 함수 시연
	print("  볼륨 퍼센트 변환 예시:")
	for pct in [100, 75, 50, 25, 10, 0]:
		var db_val = _percent_to_db(pct)
		print("    %d%% -> %.1f dB" % [pct, db_val])
	print()

	# -----------------------------------------------------------------
	# 3) 피치 제어 (pitch_scale)
	# -----------------------------------------------------------------
	print("--- 3. 피치 제어 (pitch_scale) ---")

	# pitch_scale은 재생 속도와 음높이를 동시에 변경
	# 1.0 = 원본, 2.0 = 2배속(한 옥타브 높게), 0.5 = 반속(한 옥타브 낮게)
	player.pitch_scale = 1.0
	print("  pitch_scale 1.0 = 원본 속도/음높이")

	player.pitch_scale = 1.5
	print("  pitch_scale 1.5 = 1.5배 빠르고 높은 소리")

	player.pitch_scale = 0.8
	print("  pitch_scale 0.8 = 느리고 낮은 소리")

	# 랜덤 피치로 효과음 변형 (같은 효과음이 반복될 때 자연스러움)
	print("  랜덤 피치 변형 예시 (효과음 다양화):")
	for i in range(5):
		var random_pitch = randf_range(0.9, 1.1)
		print("    재생 %d: pitch = %.3f" % [i + 1, random_pitch])
	print()

	# -----------------------------------------------------------------
	# 4) 재생 제어 메서드
	# -----------------------------------------------------------------
	print("--- 4. 재생 제어 메서드 ---")

	print("  play(from_position)  - 처음부터 또는 지정 위치에서 재생")
	print("  stop()               - 재생 정지 (위치 초기화)")
	print("  seek(to_position)    - 재생 위치 이동")
	print("  get_playback_position() - 현재 재생 위치 (초)")
	print("  stream_paused        - true/false로 일시정지 제어")
	print()

	# 재생 제어 시뮬레이션
	print("  [시뮬레이션] 재생 제어 흐름:")
	print("    1. player.play()              -> 처음부터 재생")
	print("    2. player.play(5.0)           -> 5초 지점부터 재생")
	print("    3. player.stream_paused = true  -> 일시정지")
	print("    4. player.stream_paused = false -> 재개")
	print("    5. player.seek(10.0)          -> 10초 지점으로 이동")
	print("    6. player.stop()              -> 정지")
	print()

	# -----------------------------------------------------------------
	# 5) AudioBus 라우팅
	# -----------------------------------------------------------------
	print("--- 5. AudioBus 라우팅 ---")

	# 기본 버스 구조: Master (항상 존재)
	# 프로젝트 설정에서 추가 버스 생성 가능: BGM, SFX, Voice 등
	print("  기본 버스: 'Master'")
	print("  일반적인 버스 구조:")
	print("    Master")
	print("    +-- BGM    (배경음악)")
	print("    +-- SFX    (효과음)")
	print("    +-- Voice  (음성)")
	print("    +-- UI     (UI 사운드)")
	print()

	# 버스 지정 방법
	player.bus = "Master"  # 기본값
	print("  player.bus = 'Master'  (기본)")
	# player.bus = "SFX"   # SFX 버스가 있을 때
	# player.bus = "BGM"   # BGM 버스가 있을 때

	# AudioServer를 통한 버스 정보 확인
	var bus_count = AudioServer.bus_count
	print("  현재 버스 개수: ", bus_count)
	for i in range(bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		var bus_vol = AudioServer.get_bus_volume_db(i)
		var bus_mute = AudioServer.is_bus_mute(i)
		print("    버스 [%d] '%s': volume=%.1f dB, mute=%s" % [i, bus_name, bus_vol, bus_mute])
	print()

	# -----------------------------------------------------------------
	# 6) AudioStreamPlayer2D - 위치 기반 사운드
	# -----------------------------------------------------------------
	print("--- 6. AudioStreamPlayer2D (위치 기반 사운드) ---")

	var player_2d = AudioStreamPlayer2D.new()
	add_child(player_2d)

	# 2D 오디오 고유 속성
	print("  max_distance: ", player_2d.max_distance, " (들리는 최대 거리)")
	print("  attenuation: ", player_2d.attenuation, " (감쇠 커브 지수)")
	print("  max_polyphony: ", player_2d.max_polyphony)
	print("  panning_strength: ", player_2d.panning_strength, " (좌우 패닝 강도)")
	print()

	# 거리에 따른 볼륨 감쇠 시뮬레이션
	print("  거리별 예상 볼륨 (attenuation=1.0 기준):")
	var max_dist = player_2d.max_distance
	for dist in [0, 100, 500, 1000, 2000]:
		var ratio = 1.0 - (float(dist) / max_dist)
		ratio = clampf(ratio, 0.0, 1.0)
		print("    거리 %d px: 약 %.0f%% 볼륨" % [dist, ratio * 100])
	print()

	# -----------------------------------------------------------------
	# 7) 시그널 활용
	# -----------------------------------------------------------------
	print("--- 7. 오디오 시그널 ---")

	print("  'finished' 시그널 - 재생이 끝났을 때 발생")
	print("  활용 예시:")
	print("    - BGM 루프: finished 시그널에서 다시 play()")
	print("    - 효과음 큐: finished 시그널에서 다음 사운드 재생")
	print("    - 자동 제거: finished 시그널에서 queue_free()")
	print()

	# 시그널 연결 예시 (실제 오디오 없이 구조만)
	player.finished.connect(_on_audio_finished)
	print("  player.finished 시그널 연결 완료")
	print()

	# -----------------------------------------------------------------
	# 8) 실용 패턴: SFX 매니저
	# -----------------------------------------------------------------
	print("--- 8. 실용 패턴: SFX 매니저 ---")

	var sfx_manager = SFXManager.new()
	print("  SFXManager 클래스 정의:")
	print("    - play_sfx(stream, volume, pitch_variance)")
	print("    - 자동으로 AudioStreamPlayer 풀 관리")
	print("    - 동시 재생 제한으로 성능 보호")
	print()

	# -----------------------------------------------------------------
	# 9) 실용 패턴: BGM 크로스페이드
	# -----------------------------------------------------------------
	print("--- 9. 실용 패턴: BGM 크로스페이드 ---")

	print("  크로스페이드 구현 원리:")
	print("    1. 두 개의 AudioStreamPlayer 사용 (A, B)")
	print("    2. A에서 재생 중일 때 B에 새 BGM 할당")
	print("    3. Tween으로 A 페이드아웃 + B 페이드인 동시 진행")
	print("    4. A 페이드아웃 완료 후 stop()")
	print()

	# 크로스페이드 시뮬레이션
	_simulate_crossfade()
	print()

	# -----------------------------------------------------------------
	# 10) 정리: 오디오 플레이어 비교표
	# -----------------------------------------------------------------
	print("--- 10. 오디오 플레이어 비교표 ---")
	print("  +-----------------------+---------+---------+---------+")
	print("  | 속성                  | Player  | 2D      | 3D      |")
	print("  +-----------------------+---------+---------+---------+")
	print("  | 위치 기반             |    X    |    O    |    O    |")
	print("  | 거리 감쇠             |    X    |    O    |    O    |")
	print("  | 좌우 패닝             |    X    |    O    |    O    |")
	print("  | Doppler 효과          |    X    |    X    |    O    |")
	print("  | 적합한 용도           |  BGM/UI | 2D SFX  | 3D SFX  |")
	print("  +-----------------------+---------+---------+---------+")
	print()

	# 정리
	player.queue_free()
	player_2d.queue_free()
	print("=== 01-audio-player.gd 완료 ===")


# =============================================================================
# 헬퍼 함수들
# =============================================================================

# 퍼센트(0~100)를 데시벨로 변환
func _percent_to_db(percent: int) -> float:
	if percent <= 0:
		return -80.0
	return linear_to_db(percent / 100.0)


# 재생 완료 시그널 콜백
func _on_audio_finished():
	print("  [시그널] 오디오 재생 완료!")


# 크로스페이드 시뮬레이션
func _simulate_crossfade():
	print("  [크로스페이드 시뮬레이션]")
	var duration = 2.0
	var steps = 5
	for i in range(steps + 1):
		var t = float(i) / steps
		var vol_a = 1.0 - t  # 페이드아웃
		var vol_b = t          # 페이드인
		var db_a = linear_to_db(maxf(vol_a, 0.001))
		var db_b = linear_to_db(maxf(vol_b, 0.001))
		print("    t=%.1fs: BGM_A=%.0f%% (%.1f dB) | BGM_B=%.0f%% (%.1f dB)" % [
			t * duration, vol_a * 100, db_a, vol_b * 100, db_b
		])


# =============================================================================
# SFX 매니저 내부 클래스
# =============================================================================

class SFXManager:
	# 효과음 동시 재생 관리를 위한 패턴
	var max_players: int = 8
	var _available_players: Array[AudioStreamPlayer] = []

	func _init():
		pass

	# 실제 사용 시에는 Node를 상속하고 _ready()에서
	# AudioStreamPlayer 풀을 미리 생성해둡니다.
	#
	# func play_sfx(stream: AudioStream, volume_db: float = 0.0,
	#               pitch_variance: float = 0.0) -> void:
	#     var player = _get_available_player()
	#     if player:
	#         player.stream = stream
	#         player.volume_db = volume_db
	#         if pitch_variance > 0.0:
	#             player.pitch_scale = randf_range(
	#                 1.0 - pitch_variance, 1.0 + pitch_variance)
	#         player.play()
