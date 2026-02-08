# Chapter 09 - Audio & Particles
# 02-audio-bus.gd - AudioServer와 버스 이펙트
#
# 이 파일에서 배울 내용:
# - AudioServer 싱글톤을 통한 버스 관리
# - 버스 볼륨, 뮤트, 솔로 제어
# - 오디오 이펙트(Reverb, Delay, EQ 등) 추가/제거
# - 런타임에서 버스 구조 동적 생성
# - 오디오 미터링(피크 레벨) 읽기

extends Node

func _ready():
	print("=== Chapter 09-2: AudioServer와 Bus 이펙트 ===\n")

	# -----------------------------------------------------------------
	# 1) AudioServer 기본 정보
	# -----------------------------------------------------------------
	print("--- 1. AudioServer 기본 정보 ---")

	# AudioServer는 오디오 시스템의 전역 싱글톤
	print("  오디오 드라이버: ", AudioServer.get_driver_name())
	print("  믹스 레이트: ", AudioServer.get_mix_rate(), " Hz")
	print("  버스 개수: ", AudioServer.bus_count)
	print()

	# 현재 버스 목록 출력
	print("  현재 버스 목록:")
	for i in range(AudioServer.bus_count):
		var name = AudioServer.get_bus_name(i)
		var vol = AudioServer.get_bus_volume_db(i)
		var mute = AudioServer.is_bus_mute(i)
		var solo = AudioServer.is_bus_solo(i)
		var send = AudioServer.get_bus_send(i)
		var effect_count = AudioServer.get_bus_effect_count(i)
		print("    [%d] '%s': vol=%.1f dB, mute=%s, solo=%s, send='%s', effects=%d" % [
			i, name, vol, mute, solo, send, effect_count
		])
	print()

	# -----------------------------------------------------------------
	# 2) 버스 볼륨 제어
	# -----------------------------------------------------------------
	print("--- 2. 버스 볼륨 제어 ---")

	# Master 버스의 볼륨 조절
	var master_idx = AudioServer.get_bus_index("Master")
	print("  Master 버스 인덱스: ", master_idx)

	# 원래 볼륨 저장
	var original_vol = AudioServer.get_bus_volume_db(master_idx)
	print("  원래 볼륨: ", original_vol, " dB")

	# 볼륨 변경
	AudioServer.set_bus_volume_db(master_idx, -10.0)
	print("  볼륨 -> -10 dB 변경: ", AudioServer.get_bus_volume_db(master_idx), " dB")

	# 복원
	AudioServer.set_bus_volume_db(master_idx, original_vol)
	print("  볼륨 복원: ", AudioServer.get_bus_volume_db(master_idx), " dB")
	print()

	# 볼륨 슬라이더 매핑 예시 (UI 0~100% -> dB)
	print("  UI 슬라이더 -> 데시벨 매핑:")
	for slider_val in [100, 80, 60, 40, 20, 10, 0]:
		var db = _slider_to_db(slider_val)
		print("    슬라이더 %3d%% -> %6.1f dB" % [slider_val, db])
	print()

	# -----------------------------------------------------------------
	# 3) 뮤트와 솔로
	# -----------------------------------------------------------------
	print("--- 3. 뮤트(Mute)와 솔로(Solo) ---")

	print("  Mute: 해당 버스의 출력을 무음으로 만듦")
	print("  Solo: 해당 버스만 출력하고 나머지는 무음")
	print()

	# 뮤트 시연
	AudioServer.set_bus_mute(master_idx, true)
	print("  Master 뮤트 ON: ", AudioServer.is_bus_mute(master_idx))

	AudioServer.set_bus_mute(master_idx, false)
	print("  Master 뮤트 OFF: ", AudioServer.is_bus_mute(master_idx))

	# 솔로 시연
	AudioServer.set_bus_solo(master_idx, true)
	print("  Master 솔로 ON: ", AudioServer.is_bus_solo(master_idx))

	AudioServer.set_bus_solo(master_idx, false)
	print("  Master 솔로 OFF: ", AudioServer.is_bus_solo(master_idx))
	print()

	# -----------------------------------------------------------------
	# 4) 동적 버스 생성
	# -----------------------------------------------------------------
	print("--- 4. 동적 버스 생성 ---")

	# 새 버스 추가
	var new_bus_idx = AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(new_bus_idx, "SFX")
	AudioServer.set_bus_send(new_bus_idx, "Master")  # Master로 라우팅
	AudioServer.set_bus_volume_db(new_bus_idx, -3.0)
	print("  'SFX' 버스 추가됨 (인덱스: %d)" % new_bus_idx)
	print("    send -> 'Master'")
	print("    volume: -3.0 dB")

	# 두 번째 버스 추가
	var bgm_bus_idx = AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(bgm_bus_idx, "BGM")
	AudioServer.set_bus_send(bgm_bus_idx, "Master")
	AudioServer.set_bus_volume_db(bgm_bus_idx, -6.0)
	print("  'BGM' 버스 추가됨 (인덱스: %d)" % bgm_bus_idx)
	print()

	# 현재 버스 구조 출력
	print("  현재 버스 구조:")
	for i in range(AudioServer.bus_count):
		var bname = AudioServer.get_bus_name(i)
		var bsend = AudioServer.get_bus_send(i)
		var bvol = AudioServer.get_bus_volume_db(i)
		if bsend == "":
			print("    [%d] %s (%.1f dB) <- 루트" % [i, bname, bvol])
		else:
			print("    [%d] %s (%.1f dB) -> %s" % [i, bname, bvol, bsend])
	print()

	# -----------------------------------------------------------------
	# 5) 오디오 이펙트 종류
	# -----------------------------------------------------------------
	print("--- 5. 오디오 이펙트 종류 ---")

	print("  Godot 4에서 제공하는 주요 오디오 이펙트:")
	print("    AudioEffectReverb       - 잔향 (공간감)")
	print("    AudioEffectDelay        - 딜레이 (에코)")
	print("    AudioEffectChorus       - 코러스 (두껍고 풍성한 소리)")
	print("    AudioEffectDistortion   - 디스토션 (왜곡)")
	print("    AudioEffectEQ6          - 6밴드 이퀄라이저")
	print("    AudioEffectEQ10         - 10밴드 이퀄라이저")
	print("    AudioEffectEQ21         - 21밴드 이퀄라이저")
	print("    AudioEffectFilter       - 주파수 필터 (HPF/LPF/BPF)")
	print("    AudioEffectLimiter      - 리미터 (최대 볼륨 제한)")
	print("    AudioEffectCompressor   - 컴프레서 (다이나믹 레인지 축소)")
	print("    AudioEffectAmplify      - 증폭")
	print("    AudioEffectPanner       - 좌우 패닝")
	print("    AudioEffectPhaser       - 페이저 효과")
	print("    AudioEffectPitchShift   - 피치 시프트")
	print("    AudioEffectRecord       - 녹음")
	print("    AudioEffectSpectrumAnalyzer - 스펙트럼 분석")
	print()

	# -----------------------------------------------------------------
	# 6) 이펙트 추가 및 설정
	# -----------------------------------------------------------------
	print("--- 6. 이펙트 추가 및 설정 ---")

	# SFX 버스에 리버브 추가
	var sfx_idx = AudioServer.get_bus_index("SFX")

	var reverb = AudioEffectReverb.new()
	reverb.room_size = 0.6
	reverb.damping = 0.5
	reverb.wet = 0.3  # 원음 대비 이펙트 비율
	reverb.dry = 0.7
	AudioServer.add_bus_effect(sfx_idx, reverb)
	print("  SFX 버스에 Reverb 추가:")
	print("    room_size: ", reverb.room_size)
	print("    damping: ", reverb.damping)
	print("    wet/dry: ", reverb.wet, " / ", reverb.dry)
	print()

	# SFX 버스에 리미터 추가
	var limiter = AudioEffectLimiter.new()
	limiter.ceiling_db = -0.1
	limiter.threshold_db = -6.0
	AudioServer.add_bus_effect(sfx_idx, limiter)
	print("  SFX 버스에 Limiter 추가:")
	print("    ceiling_db: ", limiter.ceiling_db)
	print("    threshold_db: ", limiter.threshold_db)
	print()

	# BGM 버스에 로우패스 필터 추가
	var bgm_idx = AudioServer.get_bus_index("BGM")

	var lpf = AudioEffectFilter.new()
	# 필터는 기본적으로 로우패스 (AudioEffectLowPassFilter 사용 권장)
	AudioServer.add_bus_effect(bgm_idx, lpf)
	print("  BGM 버스에 Filter 추가")
	print()

	# 이펙트 목록 확인
	print("  SFX 버스 이펙트 목록:")
	for i in range(AudioServer.get_bus_effect_count(sfx_idx)):
		var effect = AudioServer.get_bus_effect(sfx_idx, i)
		var enabled = AudioServer.is_bus_effect_enabled(sfx_idx, i)
		print("    [%d] %s (enabled: %s)" % [i, effect.get_class(), enabled])
	print()

	# -----------------------------------------------------------------
	# 7) 이펙트 활성화/비활성화
	# -----------------------------------------------------------------
	print("--- 7. 이펙트 활성화/비활성화 ---")

	# 이펙트 개별 on/off
	AudioServer.set_bus_effect_enabled(sfx_idx, 0, false)  # Reverb 비활성화
	print("  SFX Reverb 비활성화: enabled = ",
		AudioServer.is_bus_effect_enabled(sfx_idx, 0))

	AudioServer.set_bus_effect_enabled(sfx_idx, 0, true)   # Reverb 활성화
	print("  SFX Reverb 활성화: enabled = ",
		AudioServer.is_bus_effect_enabled(sfx_idx, 0))
	print()

	# 이펙트 제거
	print("  이펙트 제거 전 개수: ", AudioServer.get_bus_effect_count(sfx_idx))
	# AudioServer.remove_bus_effect(sfx_idx, 0)  # 인덱스 0번 이펙트 제거
	print("  (제거는 주석 처리 - 이후 참조를 위해 유지)")
	print()

	# -----------------------------------------------------------------
	# 8) 오디오 미터링 (피크 레벨 읽기)
	# -----------------------------------------------------------------
	print("--- 8. 오디오 미터링 ---")

	print("  AudioServer.get_bus_peak_volume_left_db(bus_idx, channel)")
	print("  AudioServer.get_bus_peak_volume_right_db(bus_idx, channel)")
	print()

	# 현재 피크 레벨 읽기 (재생 중이 아니므로 -INF)
	var peak_left = AudioServer.get_bus_peak_volume_left_db(master_idx, 0)
	var peak_right = AudioServer.get_bus_peak_volume_right_db(master_idx, 0)
	print("  Master 피크 레벨:")
	print("    Left: ", peak_left, " dB")
	print("    Right: ", peak_right, " dB")
	print("    (재생 중이 아니므로 매우 낮은 값)")
	print()

	# VU 미터 시뮬레이션
	print("  VU 미터 시각화 예시 (시뮬레이션):")
	_simulate_vu_meter(-40.0, "  ")
	_simulate_vu_meter(-20.0, "  ")
	_simulate_vu_meter(-10.0, "  ")
	_simulate_vu_meter(-3.0, "  ")
	_simulate_vu_meter(0.0, "  ")
	print()

	# -----------------------------------------------------------------
	# 9) 스펙트럼 분석기 설정
	# -----------------------------------------------------------------
	print("--- 9. 스펙트럼 분석기 ---")

	var spectrum = AudioEffectSpectrumAnalyzerInstance
	print("  AudioEffectSpectrumAnalyzer를 버스에 추가하면")
	print("  주파수별 크기를 실시간으로 분석할 수 있습니다.")
	print()
	print("  설정 방법:")
	print("    1. AudioEffectSpectrumAnalyzer를 버스에 추가")
	print("    2. AudioServer.get_bus_effect_instance(bus_idx, effect_idx)")
	print("    3. instance.get_magnitude_for_frequency_range(from, to)")
	print()
	print("  활용 사례:")
	print("    - 음악 비주얼라이저")
	print("    - 리듬 게임의 비트 감지")
	print("    - 음성 레벨에 따른 캐릭터 입 모양 변경")
	print()

	# -----------------------------------------------------------------
	# 10) 실용 패턴: 오디오 설정 매니저
	# -----------------------------------------------------------------
	print("--- 10. 실용 패턴: 오디오 설정 매니저 ---")

	print("  게임 옵션 메뉴를 위한 오디오 설정 관리:")
	print()

	# 설정 저장/불러오기 시뮬레이션
	var settings = {
		"master_volume": 80,
		"bgm_volume": 60,
		"sfx_volume": 100,
		"voice_volume": 90,
		"mute_all": false
	}

	print("  현재 설정:")
	for key in settings:
		print("    %s: %s" % [key, settings[key]])
	print()

	# 설정 적용 시뮬레이션
	print("  설정 적용:")
	_apply_audio_settings(settings)
	print()

	# -----------------------------------------------------------------
	# 11) 정리: 동적으로 추가한 버스 제거
	# -----------------------------------------------------------------
	print("--- 11. 정리 ---")

	# 추가한 버스 제거 (역순으로 제거해야 인덱스 문제 없음)
	var buses_to_remove = []
	for i in range(AudioServer.bus_count - 1, 0, -1):
		var bname = AudioServer.get_bus_name(i)
		if bname in ["SFX", "BGM"]:
			buses_to_remove.append({"idx": i, "name": bname})

	for bus_info in buses_to_remove:
		AudioServer.remove_bus(bus_info["idx"])
		print("  '%s' 버스 제거됨" % bus_info["name"])

	print("  최종 버스 개수: ", AudioServer.bus_count)
	print()

	print("=== 02-audio-bus.gd 완료 ===")


# =============================================================================
# 헬퍼 함수들
# =============================================================================

# 슬라이더 값(0~100)을 데시벨로 변환 (로그 스케일)
func _slider_to_db(value: int) -> float:
	if value <= 0:
		return -80.0
	# 로그 스케일로 자연스러운 볼륨 변화
	return linear_to_db(value / 100.0)


# VU 미터 시각화
func _simulate_vu_meter(db_value: float, indent: String = ""):
	var normalized = remap(db_value, -60.0, 0.0, 0.0, 1.0)
	normalized = clampf(normalized, 0.0, 1.0)
	var bar_length = int(normalized * 30)
	var bar = ""
	for i in range(30):
		if i < bar_length:
			if i > 25:
				bar += "!"  # 클리핑 영역
			elif i > 20:
				bar += "#"  # 높은 레벨
			else:
				bar += "="  # 정상 레벨
		else:
			bar += "-"
	print("%s  [%s] %.1f dB" % [indent, bar, db_value])


# 오디오 설정 적용
func _apply_audio_settings(settings: Dictionary):
	# Master 볼륨
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		if settings.get("mute_all", false):
			AudioServer.set_bus_mute(master_idx, true)
			print("    Master: 뮤트 적용")
		else:
			AudioServer.set_bus_mute(master_idx, false)
			var master_db = _slider_to_db(settings.get("master_volume", 100))
			AudioServer.set_bus_volume_db(master_idx, master_db)
			print("    Master: %.1f dB (%d%%)" % [master_db, settings.get("master_volume", 100)])

	# 카테고리별 버스 (존재하는 경우에만)
	for bus_name in ["BGM", "SFX", "Voice"]:
		var idx = AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			var key = bus_name.to_lower() + "_volume"
			var vol = settings.get(key, 100)
			AudioServer.set_bus_volume_db(idx, _slider_to_db(vol))
			print("    %s: %.1f dB (%d%%)" % [bus_name, _slider_to_db(vol), vol])
		else:
			print("    %s: 버스 없음 (스킵)" % bus_name)
