# 챕터 8: 애니메이션 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - Tween으로 페이드 인/아웃 구현
# - Tween 체이닝으로 순차/동시 애니메이션
# - 이징 함수(Easing)의 종류와 적용
# - AnimationPlayer를 코드로 제어
# - 상태 전환 애니메이션 시스템
# - 화면 흔들기(Screen Shake) 효과

extends Node2D

# 테스트용 노드
var demo_sprite: Sprite2D
var demo_label: Label
var demo_panel: Panel

func _ready():
	print("=== 챕터 8: 애니메이션 ===\n")

	_setup_nodes()

	# 연습 1: Tween 페이드
	_exercise_1_tween_fade()

	# 연습 2: Tween 체이닝
	_exercise_2_tween_chaining()

	# 연습 3: 이징 함수
	_exercise_3_easing_functions()

	# 연습 4: AnimationPlayer 코드 제어
	_exercise_4_animation_player_code()

	# 연습 5: 상태 전환 애니메이션
	_exercise_5_state_transition()

	# 연습 6: 화면 흔들기
	_exercise_6_screen_shake()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: 페이드 Tween 생성 완료")
	print("결과 2: 체이닝 애니메이션 (이동 -> 회전 -> 스케일) 설정 완료")
	print("결과 3: 6가지 이징 비교 라벨 생성 완료")
	print("결과 4: AnimationPlayer 'bounce' 애니메이션 코드 생성 완료")
	print("결과 5: 상태 전환 시뮬레이션 (IDLE -> RUN -> JUMP -> FALL -> IDLE)")
	print("결과 6: 화면 흔들기 함수 구현 완료")


func _setup_nodes():
	demo_sprite = Sprite2D.new()
	demo_sprite.name = "DemoSprite"
	demo_sprite.position = Vector2(100, 150)
	add_child(demo_sprite)

	demo_label = Label.new()
	demo_label.name = "DemoLabel"
	demo_label.text = "Animation Test"
	demo_label.position = Vector2(100, 40)
	demo_label.add_theme_font_size_override("font_size", 22)
	add_child(demo_label)

	demo_panel = Panel.new()
	demo_panel.name = "DemoPanel"
	demo_panel.position = Vector2(300, 80)
	demo_panel.size = Vector2(150, 80)
	add_child(demo_panel)


# ==============================================================================
# 연습 1: Tween 페이드 - 노드를 페이드 인/아웃하는 함수를 구현하세요.
# ==============================================================================
func _exercise_1_tween_fade():
	# 풀이: create_tween()으로 Tween을 생성하고 tween_property로
	#       modulate:a (알파) 값을 0에서 1로 (페이드 인) 또는
	#       1에서 0으로 (페이드 아웃) 변경합니다.
	#       페이드 아웃 후에는 tween_callback으로 visible = false 처리합니다.

	# 페이드 아웃 (1.0 -> 0.0)
	var tween_out = create_tween()
	tween_out.tween_property(demo_label, "modulate:a", 0.0, 0.5)
	tween_out.tween_callback(func(): demo_label.visible = false)

	# 1초 후 페이드 인 (0.0 -> 1.0)
	tween_out.tween_callback(func():
		demo_label.visible = true
	).set_delay(0.5)
	tween_out.tween_property(demo_label, "modulate:a", 1.0, 0.5)

	print("연습 1 완료: 페이드 아웃(0.5초) -> 대기(0.5초) -> 페이드 인(0.5초)")

	# 재사용 가능한 페이드 함수 정의
	# fade_in / fade_out 은 아래에서 함수로도 정의

func fade_in(node: CanvasItem, duration: float = 0.3) -> Tween:
	node.modulate.a = 0.0
	node.visible = true
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

func fade_out(node: CanvasItem, duration: float = 0.3) -> Tween:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): node.visible = false)
	return tween


# ==============================================================================
# 연습 2: Tween 체이닝 - 순차 실행과 동시 실행을 조합하세요.
#          이동 -> (회전+스케일 동시) -> 원위치 순서로 애니메이션하세요.
# ==============================================================================
func _exercise_2_tween_chaining():
	# 풀이: 기본 Tween은 순차 실행됩니다. .parallel()을 붙이면 이전 Tweener와
	#       동시에 실행됩니다. chain()은 set_parallel(true) 이후 다시 순차로
	#       전환할 때 사용합니다. set_delay()로 시작 지연을 줄 수 있습니다.

	var tween = create_tween()

	# Phase 1: 오른쪽으로 이동 (순차)
	tween.tween_property(demo_sprite, "position", Vector2(350, 150), 0.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Phase 2: 회전 + 스케일 동시 실행
	tween.tween_property(demo_sprite, "rotation", PI * 2, 0.5) \
		.set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(demo_sprite, "scale", Vector2(1.5, 1.5), 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Phase 3: 원위치로 복귀 (이동 + 스케일 + 회전 동시)
	tween.tween_property(demo_sprite, "position", Vector2(100, 150), 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(demo_sprite, "scale", Vector2.ONE, 0.5)
	tween.parallel().tween_property(demo_sprite, "rotation", 0.0, 0.5)

	# 완료 콜백
	tween.tween_callback(func(): print("  >> 체이닝 애니메이션 완료!"))

	print("연습 2 완료: 이동(0.6초) -> 회전+스케일(0.5초) -> 원위치(0.5초)")


# ==============================================================================
# 연습 3: 이징 함수 - 6가지 이징을 비교하여 시각적으로 보여주세요.
# ==============================================================================
func _exercise_3_easing_functions():
	# 풀이: 여러 TransitionType + EaseType 조합을 배열로 정의하고,
	#       각각에 대해 Label 마커를 생성한 뒤 동일한 거리를 이동시킵니다.
	#       set_trans()와 set_ease()를 tween_property에 체이닝합니다.

	var easings = [
		{"label": "LINEAR",      "trans": Tween.TRANS_LINEAR,  "ease": Tween.EASE_IN_OUT},
		{"label": "SINE OUT",    "trans": Tween.TRANS_SINE,    "ease": Tween.EASE_OUT},
		{"label": "QUAD OUT",    "trans": Tween.TRANS_QUAD,    "ease": Tween.EASE_OUT},
		{"label": "BACK OUT",    "trans": Tween.TRANS_BACK,    "ease": Tween.EASE_OUT},
		{"label": "ELASTIC OUT", "trans": Tween.TRANS_ELASTIC, "ease": Tween.EASE_OUT},
		{"label": "BOUNCE OUT",  "trans": Tween.TRANS_BOUNCE,  "ease": Tween.EASE_OUT},
	]

	for i in range(easings.size()):
		var data = easings[i]
		var y_pos = 220 + i * 25

		# 이름 라벨
		var name_label = Label.new()
		name_label.text = data.label
		name_label.position = Vector2(20, y_pos)
		name_label.add_theme_font_size_override("font_size", 12)
		add_child(name_label)

		# 이동 마커
		var marker = Label.new()
		marker.text = ">>>"
		marker.position = Vector2(140, y_pos)
		marker.add_theme_color_override("font_color", Color.CYAN)
		marker.add_theme_font_size_override("font_size", 12)
		add_child(marker)

		# 이징 적용된 Tween
		var tween = create_tween()
		tween.tween_property(marker, "position:x", 500.0, 2.0) \
			.set_trans(data.trans).set_ease(data.ease) \
			.set_delay(0.5)  # 약간의 딜레이로 관찰 가능하게

	print("연습 3 완료: 6가지 이징 비교 (LINEAR, SINE, QUAD, BACK, ELASTIC, BOUNCE)")
	print("  각 이징의 특성:")
	print("  - LINEAR: 일정한 속도, 기계적")
	print("  - SINE OUT: 부드러운 감속")
	print("  - QUAD OUT: 자연스러운 감속 (가장 범용)")
	print("  - BACK OUT: 목표를 살짝 넘었다 돌아옴 (팝 효과)")
	print("  - ELASTIC OUT: 탄성/스프링 진동")
	print("  - BOUNCE OUT: 공 튀기기 효과")


# ==============================================================================
# 연습 4: AnimationPlayer 코드 제어 - 코드로 Animation을 생성하고 재생하세요.
# ==============================================================================
func _exercise_4_animation_player_code():
	# 풀이: AnimationPlayer.new()로 플레이어를 생성하고,
	#       Animation.new()로 리소스를 만듭니다. add_track(TYPE_VALUE)로
	#       트랙을 추가하고, track_set_path로 대상 속성을 지정합니다.
	#       track_insert_key로 키프레임을 삽입합니다.
	#       AnimationLibrary에 등록한 후 play()로 재생합니다.

	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)

	# 'bounce' 애니메이션 생성
	var anim = Animation.new()
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_LINEAR

	# 트랙 1: Y 위치 바운스
	var pos_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(pos_track, "DemoSprite:position:y")
	anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(pos_track, 0.0, 150.0)
	anim.track_insert_key(pos_track, 0.5, 120.0)  # 위로 올라감
	anim.track_insert_key(pos_track, 1.0, 150.0)   # 원위치

	# 트랙 2: 스케일 (찌그러짐/늘어남)
	var scale_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(scale_track, "DemoSprite:scale")
	anim.track_insert_key(scale_track, 0.0, Vector2(1.0, 1.0))
	anim.track_insert_key(scale_track, 0.25, Vector2(1.2, 0.8))   # 납작
	anim.track_insert_key(scale_track, 0.5, Vector2(0.85, 1.15))  # 길쭉
	anim.track_insert_key(scale_track, 0.75, Vector2(1.05, 0.95))
	anim.track_insert_key(scale_track, 1.0, Vector2(1.0, 1.0))

	# 트랙 3: 투명도 깜빡임
	var alpha_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(alpha_track, "DemoSprite:modulate")
	anim.track_insert_key(alpha_track, 0.0, Color(1, 1, 1, 1))
	anim.track_insert_key(alpha_track, 0.5, Color(1, 1, 1, 0.6))
	anim.track_insert_key(alpha_track, 1.0, Color(1, 1, 1, 1))

	# AnimationLibrary에 등록
	var library = AnimationLibrary.new()
	library.add_animation("bounce", anim)
	anim_player.add_animation_library("", library)

	# 재생
	anim_player.play("bounce")

	# 시그널 연결
	anim_player.animation_finished.connect(func(anim_name):
		print("  >> 애니메이션 '%s' 완료" % anim_name)
	)

	print("연습 4 완료: AnimationPlayer 'bounce' 생성 (3트랙: 위치, 스케일, 투명도)")
	print("  재생 중: %s (길이: %.1f초, 루프: %s)" % [
		anim_player.current_animation,
		anim.length,
		"예" if anim.loop_mode != Animation.LOOP_NONE else "아니오"
	])


# ==============================================================================
# 연습 5: 상태 전환 - enum 기반 상태 머신으로 애니메이션 상태를 전환하세요.
# ==============================================================================

enum PlayerState { IDLE, RUN, JUMP, FALL, ATTACK }
var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState = PlayerState.IDLE

func _exercise_5_state_transition():
	# 풀이: enum으로 상태를 정의하고, change_state() 함수에서 이전 상태 종료 처리와
	#       새 상태 진입 처리를 수행합니다. 각 상태에 맞는 애니메이션 이름을
	#       매핑하여 전환 시 자동으로 재생합니다.

	var state_names = ["IDLE", "RUN", "JUMP", "FALL", "ATTACK"]

	# 상태 전환 시뮬레이션
	var transitions = [
		PlayerState.RUN,
		PlayerState.JUMP,
		PlayerState.FALL,
		PlayerState.IDLE,
		PlayerState.ATTACK,
		PlayerState.IDLE,
	]

	print("연습 5: 상태 전환 시뮬레이션")
	for new_state in transitions:
		var old_name = state_names[current_state]
		_change_player_state(new_state)
		var new_name = state_names[current_state]
		var anim_name = _get_anim_for_state(current_state)
		print("  %s -> %s (anim: '%s')" % [old_name, new_name, anim_name])

	print("연습 5 완료: 상태 전환 시스템 구현")

func _change_player_state(new_state: PlayerState):
	if new_state == current_state:
		return
	# 이전 상태 종료 처리
	match current_state:
		PlayerState.ATTACK:
			pass  # 공격 종료 처리
		PlayerState.JUMP:
			pass  # 점프 종료

	previous_state = current_state
	current_state = new_state

	# 새 상태 진입 처리
	match new_state:
		PlayerState.IDLE:
			pass  # anim_player.play("idle", 0.1)
		PlayerState.RUN:
			pass  # anim_player.play("run", 0.1)
		PlayerState.JUMP:
			pass  # anim_player.play("jump")
		PlayerState.FALL:
			pass  # anim_player.play("fall", 0.2)
		PlayerState.ATTACK:
			pass  # anim_player.play("attack")

func _get_anim_for_state(state: PlayerState) -> String:
	match state:
		PlayerState.IDLE: return "idle"
		PlayerState.RUN: return "run"
		PlayerState.JUMP: return "jump"
		PlayerState.FALL: return "fall"
		PlayerState.ATTACK: return "attack"
	return "idle"


# ==============================================================================
# 연습 6: 화면 흔들기 - Tween으로 카메라/노드를 흔드는 함수를 구현하세요.
# ==============================================================================
func _exercise_6_screen_shake():
	# 풀이: 원래 위치를 저장한 후, 루프 안에서 랜덤 오프셋을 생성하여
	#       tween_property로 짧은 시간에 위치를 변경합니다. 강도(intensity)를
	#       점차 줄여 자연스러운 감쇠 효과를 만듭니다.
	#       마지막에 원래 위치로 복귀시킵니다.

	# 화면 흔들기 함수 (demo_panel에 적용)
	_shake_node(demo_panel, 8.0, 0.4)

	print("연습 6 완료: 화면 흔들기 구현 (강도: 8px, 시간: 0.4초)")
	print("  원리: 랜덤 오프셋을 감쇠시키며 반복 적용")

func _shake_node(node: Control, intensity: float = 5.0, duration: float = 0.3):
	var original_pos = node.position
	var tween = create_tween()
	var step_time = 0.04  # 각 흔들림 간격
	var steps = int(duration / step_time)

	for i in range(steps):
		# 강도를 점차 감소 (감쇠)
		var current_intensity = intensity * (1.0 - float(i) / steps)
		var offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		tween.tween_property(node, "position", original_pos + offset, step_time)

	# 마지막에 원래 위치로 복귀
	tween.tween_property(node, "position", original_pos, step_time)
