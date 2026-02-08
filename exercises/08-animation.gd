# 챕터 8: 애니메이션
#
# 이 챕터에서는 다음을 학습합니다:
# - Tween을 활용한 프로퍼티 애니메이션
# - Tween 체이닝과 병렬 실행
# - 이징(Easing) 함수와 전환 타입
# - AnimationPlayer 코드 생성
# - 애니메이션 상태 관리
# - 화면 효과 구현 (화면 흔들기)

extends Node2D

# ============================================================
# 연습 1: Tween으로 페이드 인
# ============================================================
# Tween을 사용하여 노드의 투명도를 0에서 1로 서서히 변경합니다.
# UI 등장, 씬 전환, 캐릭터 출현 등에 활용됩니다.

func fade_in(target: CanvasItem, duration: float) -> Tween:
	# TODO: target의 modulate.a (알파값)를 0으로 설정하세요 (처음엔 투명)
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: tween_property로 "modulate:a"를 1.0까지 duration 동안 변경하세요
	#       (힌트: tween.tween_property(target, "modulate:a", 1.0, duration))
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween


# ============================================================
# 연습 2: Tween 체이닝 (이동 후 회전)
# ============================================================
# Tween 체이닝으로 여러 애니메이션을 순차적으로 실행합니다.
# 이동 완료 후 회전하는 연출을 만들어 봅니다.

func move_then_rotate(target: Node2D, destination: Vector2, angle: float) -> Tween:
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: set_parallel(false)로 순차 실행 모드를 설정하세요 (기본값이지만 명시적으로)
	# TODO: tween_property로 "position"을 destination까지 1.0초 동안 이동하세요
	# TODO: tween_property로 "rotation"을 angle까지 0.5초 동안 회전하세요
	#       (체이닝: 이동이 끝난 후 회전이 시작됩니다)
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween

func move_and_rotate_parallel(target: Node2D, destination: Vector2, angle: float) -> Tween:
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: set_parallel(true)로 병렬 실행 모드를 설정하세요
	# TODO: tween_property로 "position"을 destination까지 1.0초 동안 이동하세요
	# TODO: tween_property로 "rotation"을 angle까지 1.0초 동안 회전하세요
	#       (병렬: 이동과 회전이 동시에 진행됩니다)
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween


# ============================================================
# 연습 3: 이징 함수 선택
# ============================================================
# 이징 함수를 적용하여 자연스러운 움직임을 만듭니다.
# set_ease()와 set_trans()를 사용합니다.

func bounce_move(target: Node2D, destination: Vector2) -> Tween:
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: tween_property로 "position"을 destination까지 1.5초 동안 이동하세요
	# TODO: set_trans(Tween.TRANS_BOUNCE)로 바운스 전환을 설정하세요
	# TODO: set_ease(Tween.EASE_OUT)로 이즈 아웃을 설정하세요
	#       (힌트: tween.tween_property(...).set_trans(...).set_ease(...) 체이닝 가능)
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween

func elastic_scale(target: Node2D, target_scale: Vector2) -> Tween:
	# TODO: create_tween()으로 Tween을 생성하세요
	# TODO: tween_property로 "scale"을 target_scale까지 0.8초 동안 변경하세요
	# TODO: set_trans(Tween.TRANS_ELASTIC)로 탄성 전환을 설정하세요
	# TODO: set_ease(Tween.EASE_OUT)로 이즈 아웃을 설정하세요
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween


# ============================================================
# 연습 4: AnimationPlayer 코드 생성
# ============================================================
# AnimationPlayer와 Animation을 코드로 생성합니다.
# 에디터가 아닌 코드에서 애니메이션을 동적으로 만드는 방법입니다.

func create_blink_animation() -> AnimationPlayer:
	# TODO: AnimationPlayer를 생성하세요
	# TODO: Animation 리소스를 생성하세요
	# TODO: animation.length를 1.0으로 설정하세요
	# TODO: animation.loop_mode를 Animation.LOOP_LINEAR로 설정하세요
	# TODO: 트랙을 추가하세요:
	#       - animation.add_track(Animation.TYPE_VALUE)로 트랙 추가 (반환값이 트랙 인덱스)
	#       - animation.track_set_path(track_idx, ".:modulate:a")로 경로 설정
	#       - animation.track_insert_key(track_idx, 0.0, 1.0)  (시작: 불투명)
	#       - animation.track_insert_key(track_idx, 0.5, 0.0)  (중간: 투명)
	#       - animation.track_insert_key(track_idx, 1.0, 1.0)  (끝: 불투명)
	# TODO: AnimationLibrary를 생성하고 "blink" 이름으로 애니메이션을 추가하세요
	#       (힌트: var lib = AnimationLibrary.new())
	#       (힌트: lib.add_animation("blink", animation))
	# TODO: player에 라이브러리를 추가하세요
	#       (힌트: player.add_animation_library("", lib))
	# TODO: 생성한 AnimationPlayer를 반환하세요
	var player = null  # 여기를 수정하세요
	return player


# ============================================================
# 연습 5: 애니메이션 상태 전환 함수
# ============================================================
# 캐릭터의 상태에 따라 적절한 애니메이션을 재생합니다.
# AnimationPlayer가 이미 존재한다고 가정하고 전환 로직을 작성합니다.

enum AnimState { IDLE, RUN, JUMP, FALL, ATTACK }

var current_anim_state: AnimState = AnimState.IDLE

func get_animation_name(state: AnimState) -> String:
	# TODO: 각 상태에 맞는 애니메이션 이름 문자열을 반환하세요
	#       - IDLE -> "idle"
	#       - RUN -> "run"
	#       - JUMP -> "jump"
	#       - FALL -> "fall"
	#       - ATTACK -> "attack"
	# TODO: match 문을 사용하세요
	var anim_name = ""  # 여기를 수정하세요
	return anim_name

func transition_animation(player: AnimationPlayer, new_state: AnimState) -> void:
	# TODO: new_state가 current_anim_state와 같으면 아무것도 하지 마세요 (return)
	# TODO: current_anim_state를 new_state로 업데이트하세요
	# TODO: get_animation_name()으로 애니메이션 이름을 구하세요
	# TODO: player가 null이 아닌 경우에만 player.play(anim_name)을 호출하세요
	# TODO: 상태 전환 정보를 출력하세요: "애니메이션 전환: {이전} -> {새로운}"
	pass  # 여기를 수정하세요


# ============================================================
# 연습 6: 화면 흔들기 효과
# ============================================================
# Camera2D를 흔들어 타격감, 폭발 효과를 표현합니다.
# Tween을 활용한 감쇠 진동 패턴입니다.

var shake_tween: Tween = null

func screen_shake(camera: Camera2D, intensity: float, duration: float) -> Tween:
	# TODO: 기존 shake_tween이 유효하면(is_valid) kill()로 중단하세요
	# TODO: create_tween()으로 새 Tween을 생성하세요
	# TODO: shake_tween 변수에 저장하세요
	# TODO: 흔들기 횟수를 계산하세요: var shakes = int(duration / 0.05)
	# TODO: for 루프로 shakes만큼 반복하세요:
	#       - 각 반복에서 감쇠 비율 계산: var decay = 1.0 - (float(i) / shakes)
	#       - 랜덤 오프셋 계산:
	#         var offset = Vector2(
	#             randf_range(-intensity, intensity) * decay,
	#             randf_range(-intensity, intensity) * decay
	#         )
	#       - tween.tween_property(camera, "offset", offset, 0.05)
	# TODO: 마지막에 카메라 offset을 Vector2.ZERO로 복원하세요
	#       tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
	# TODO: 생성한 Tween을 반환하세요
	var tween = null  # 여기를 수정하세요
	return tween


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 8: 애니메이션 ===")
	print("")

	# 테스트용 Sprite2D 생성
	var test_sprite = Sprite2D.new()
	test_sprite.position = Vector2(100, 100)
	add_child(test_sprite)

	# 테스트 1: 페이드 인
	var fade_tween = fade_in(test_sprite, 2.0)
	if fade_tween != null:
		print("결과 1 (페이드 인 Tween 생성):", fade_tween.is_valid())
		print("결과 1 (시작 알파):", test_sprite.modulate.a)
	else:
		print("결과 1: null - Tween을 생성하세요")
	print("")

	# 테스트 2: 체이닝
	var sprite2 = Sprite2D.new()
	sprite2.position = Vector2.ZERO
	add_child(sprite2)
	var chain_tween = move_then_rotate(sprite2, Vector2(300, 200), PI)
	if chain_tween != null:
		print("결과 2 (순차 Tween 생성):", chain_tween.is_valid())
	else:
		print("결과 2: null - 순차 Tween을 생성하세요")
	var parallel_tween = move_and_rotate_parallel(sprite2, Vector2(300, 200), PI)
	if parallel_tween != null:
		print("결과 2 (병렬 Tween 생성):", parallel_tween.is_valid())
	else:
		print("결과 2: null - 병렬 Tween을 생성하세요")
	print("")

	# 테스트 3: 이징 함수
	var sprite3 = Sprite2D.new()
	sprite3.position = Vector2.ZERO
	add_child(sprite3)
	var bounce_tween = bounce_move(sprite3, Vector2(500, 300))
	if bounce_tween != null:
		print("결과 3 (바운스 Tween 생성):", bounce_tween.is_valid())
	else:
		print("결과 3: null - 바운스 Tween을 생성하세요")
	var elastic_tween = elastic_scale(sprite3, Vector2(2.0, 2.0))
	if elastic_tween != null:
		print("결과 3 (탄성 Tween 생성):", elastic_tween.is_valid())
	else:
		print("결과 3: null - 탄성 Tween을 생성하세요")
	print("")

	# 테스트 4: AnimationPlayer 생성
	var anim_player = create_blink_animation()
	if anim_player != null:
		print("결과 4 (AnimationPlayer 생성):", anim_player is AnimationPlayer)
		print("결과 4 (blink 애니메이션 존재):", anim_player.has_animation("blink"))
		add_child(anim_player)
	else:
		print("결과 4: null - AnimationPlayer를 생성하세요")
	print("")

	# 테스트 5: 애니메이션 상태 전환
	var anim_name_idle = get_animation_name(AnimState.IDLE)
	var anim_name_run = get_animation_name(AnimState.RUN)
	var anim_name_attack = get_animation_name(AnimState.ATTACK)
	print("결과 5 (IDLE 이름):", anim_name_idle)
	print("결과 5 (RUN 이름):", anim_name_run)
	print("결과 5 (ATTACK 이름):", anim_name_attack)
	current_anim_state = AnimState.IDLE
	transition_animation(null, AnimState.RUN)
	print("결과 5 (현재 상태):", current_anim_state)
	transition_animation(null, AnimState.RUN)  # 같은 상태 전환 시도 (무시되어야 함)
	print("")

	# 테스트 6: 화면 흔들기
	var camera = Camera2D.new()
	add_child(camera)
	var shake_result = screen_shake(camera, 10.0, 0.3)
	if shake_result != null:
		print("결과 6 (화면 흔들기 Tween 생성):", shake_result.is_valid())
	else:
		print("결과 6: null - 화면 흔들기를 구현하세요")
	print("")

	print("=== 챕터 8 완료 ===")
