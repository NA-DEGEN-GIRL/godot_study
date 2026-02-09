# 챕터 18: 3D 애니메이션
#
# 이 챕터에서는 다음을 학습합니다:
# - AnimationPlayer를 이용한 애니메이션 재생 제어
# - AnimationTree 설정과 상태 머신
# - BlendSpace로 부드러운 애니메이션 전환
# - Tween을 이용한 3D 보간 애니메이션
# - 절차적(Procedural) 애니메이션 기법

extends Node3D


# ============================================================
# 애니메이션 상수
# ============================================================
const BLEND_TIME: float = 0.2
const ANIMATION_SPEED: float = 1.0


# ============================================================
# 연습 1: 애니메이션 재생 제어
# ============================================================
# AnimationPlayer는 키프레임 기반 애니메이션을 재생합니다.
# 애니메이션 전환, 속도 조절, 큐 등 다양한 제어가 가능합니다.

var current_animation: String = "idle"
var animation_speed: float = 1.0
var animation_playing: bool = false
var animation_queue: Array = []

func play_animation(anim_name: String, blend_time: float = BLEND_TIME) -> Dictionary:
	# TODO: 애니메이션 재생 명령을 시뮬레이션하세요
	#
	# 1. 같은 애니메이션이 이미 재생 중이면 무시
	#    반환: {"changed": false, "reason": "이미 재생 중"}
	#
	# 2. 애니메이션 변경:
	#    - previous_animation에 현재 애니메이션 저장
	#    - current_animation을 anim_name으로 변경
	#    - animation_playing을 true로 설정
	#
	# 반환 형식:
	# {
	#   "changed": true,
	#   "previous": 이전 애니메이션명,
	#   "current": 현재 애니메이션명,
	#   "blend_time": blend_time,
	#   "speed": animation_speed,
	#   "code_example": "animation_player.play(\"anim_name\", blend_time)"
	# }
	var result = {}  # 여기를 수정하세요
	return result

func queue_animation(anim_name: String) -> Dictionary:
	# TODO: 애니메이션 큐에 추가하세요
	# 큐에 있는 애니메이션은 현재 애니메이션이 끝나면 순서대로 재생됩니다
	#
	# 1. animation_queue에 anim_name 추가
	#
	# 반환 형식:
	# {
	#   "queued": anim_name,
	#   "queue_size": 큐에 있는 애니메이션 수,
	#   "queue_list": 큐 전체 목록 (복사본),
	#   "code_example": "animation_player.queue(\"anim_name\")"
	# }
	var result = {}  # 여기를 수정하세요
	return result

func set_animation_speed(speed: float) -> Dictionary:
	# TODO: 애니메이션 재생 속도를 설정하세요
	# speed: 0.0이면 일시정지, 음수면 역재생, 양수면 정방향
	#
	# animation_speed를 업데이트하세요
	#
	# 반환 형식:
	# {
	#   "speed": speed,
	#   "is_paused": speed == 0.0,
	#   "is_reversed": speed < 0.0,
	#   "description": 속도 설명 문자열
	#     (0.0: "일시정지", 음수: "역재생 x{abs(speed)}", 1.0: "정상 속도",
	#      그 외 양수: "빠른 재생 x{speed}" 또는 "느린 재생 x{speed}")
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 2: AnimationTree 설정
# ============================================================
# AnimationTree는 복잡한 애니메이션 전환과 블렌딩을 관리합니다.
# StateMachine, BlendTree 등의 루트 노드를 사용합니다.

func create_animation_tree_config(character_type: String) -> Dictionary:
	# TODO: 캐릭터 유형별 AnimationTree 상태 머신을 설계하세요
	# character_type: "humanoid", "creature", "vehicle"
	#
	# 반환 형식:
	# {
	#   "character_type": character_type,
	#   "tree_root": "AnimationNodeStateMachine",
	#   "states": 상태 목록 배열,
	#   "transitions": 전환 규칙 배열 [{"from": ..., "to": ..., "condition": ...}, ...],
	#   "default_state": 기본 상태,
	#   "blend_times": {"기본": BLEND_TIME}
	# }
	#
	# "humanoid" 상태/전환:
	#   states: ["idle", "walk", "run", "jump_start", "jump_loop", "jump_land", "attack", "hurt", "death"]
	#   transitions:
	#     idle <-> walk (조건: speed > 0 / speed == 0)
	#     walk <-> run (조건: speed > 5 / speed <= 5)
	#     idle/walk/run -> jump_start (조건: is_jumping)
	#     jump_start -> jump_loop (조건: auto, 애니메이션 끝)
	#     jump_loop -> jump_land (조건: is_on_floor)
	#     jump_land -> idle (조건: auto, 애니메이션 끝)
	#     any -> hurt (조건: is_hurt)
	#     hurt -> idle (조건: auto)
	#     any -> death (조건: is_dead)
	#   default_state: "idle"
	#
	# "creature" 상태/전환:
	#   states: ["idle", "move", "attack", "special", "hurt", "death"]
	#   transitions:
	#     idle <-> move (조건: speed > 0 / speed == 0)
	#     idle/move -> attack (조건: is_attacking)
	#     attack -> idle (조건: auto)
	#     idle/move -> special (조건: is_special)
	#     special -> idle (조건: auto)
	#     any -> hurt (조건: is_hurt)
	#     hurt -> idle (조건: auto)
	#     any -> death (조건: is_dead)
	#   default_state: "idle"
	#
	# "vehicle" 상태/전환:
	#   states: ["parked", "idle_engine", "accelerate", "cruise", "brake", "reverse"]
	#   transitions:
	#     parked <-> idle_engine (조건: engine_on / engine_off)
	#     idle_engine -> accelerate (조건: throttle > 0)
	#     accelerate -> cruise (조건: speed > 10)
	#     cruise -> brake (조건: brake_input)
	#     brake -> idle_engine (조건: speed == 0)
	#     idle_engine -> reverse (조건: reverse_input)
	#     reverse -> idle_engine (조건: speed == 0)
	#   default_state: "parked"
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 3: BlendSpace 파라미터
# ============================================================
# BlendSpace는 파라미터 값에 따라 여러 애니메이션을 자연스럽게 섞습니다.
# 1D: 한 축(예: 속도), 2D: 두 축(예: 속도+방향)

func create_blend_space_config(dimensions: int) -> Dictionary:
	# TODO: BlendSpace 설정을 Dictionary로 반환하세요
	# dimensions: 1 (1D) 또는 2 (2D)
	#
	# 1D BlendSpace (dimensions == 1):
	# {
	#   "type": "AnimationNodeBlendSpace1D",
	#   "dimensions": 1,
	#   "parameter": "speed",
	#   "min_value": 0.0,
	#   "max_value": 10.0,
	#   "blend_points": [
	#     {"position": 0.0, "animation": "idle"},
	#     {"position": 2.0, "animation": "walk"},
	#     {"position": 5.0, "animation": "jog"},
	#     {"position": 10.0, "animation": "run"}
	#   ],
	#   "snap": 0.1,
	#   "code_example": "anim_tree.set(\"parameters/BlendSpace1D/blend_position\", speed)"
	# }
	#
	# 2D BlendSpace (dimensions == 2):
	# {
	#   "type": "AnimationNodeBlendSpace2D",
	#   "dimensions": 2,
	#   "parameter_x": "move_x",
	#   "parameter_y": "move_y",
	#   "min_space": Vector2(-1, -1),
	#   "max_space": Vector2(1, 1),
	#   "blend_points": [
	#     {"position": Vector2(0, 0), "animation": "idle"},
	#     {"position": Vector2(0, -1), "animation": "walk_forward"},
	#     {"position": Vector2(0, 1), "animation": "walk_backward"},
	#     {"position": Vector2(-1, 0), "animation": "walk_left"},
	#     {"position": Vector2(1, 0), "animation": "walk_right"},
	#     {"position": Vector2(-1, -1), "animation": "walk_forward_left"},
	#     {"position": Vector2(1, -1), "animation": "walk_forward_right"},
	#     {"position": Vector2(-1, 1), "animation": "walk_backward_left"},
	#     {"position": Vector2(1, 1), "animation": "walk_backward_right"}
	#   ],
	#   "blend_mode": "interpolated",
	#   "code_example": "anim_tree.set(\"parameters/BlendSpace2D/blend_position\", Vector2(x, y))"
	# }
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 4: Tween 3D 애니메이션
# ============================================================
# Tween은 코드로 간단한 보간 애니메이션을 만듭니다.
# 3D에서 위치, 회전, 스케일 등을 부드럽게 변환합니다.

func create_tween_sequence(
	start_pos: Vector3,
	end_pos: Vector3,
	duration: float,
	ease_type: String
) -> Dictionary:
	# TODO: Tween 애니메이션 시퀀스를 Dictionary로 설계하세요
	# ease_type: "linear", "ease_in", "ease_out", "ease_in_out", "bounce", "elastic"
	#
	# 반환 형식:
	# {
	#   "tween_type": "SceneTreeTween",
	#   "start_position": start_pos,
	#   "end_position": end_pos,
	#   "duration": duration,
	#   "ease_type": ease_type,
	#   "transition_constant": Tween 전환 상수명,
	#   "ease_constant": Tween 이징 상수명,
	#   "distance": start_pos.distance_to(end_pos),
	#   "average_speed": distance / duration,
	#   "midpoint": start_pos.lerp(end_pos, 0.5),
	#   "code_example": 코드 문자열
	# }
	#
	# ease_type -> transition_constant/ease_constant 매핑:
	# "linear" -> "TRANS_LINEAR", "EASE_IN_OUT"
	# "ease_in" -> "TRANS_QUAD", "EASE_IN"
	# "ease_out" -> "TRANS_QUAD", "EASE_OUT"
	# "ease_in_out" -> "TRANS_QUAD", "EASE_IN_OUT"
	# "bounce" -> "TRANS_BOUNCE", "EASE_OUT"
	# "elastic" -> "TRANS_ELASTIC", "EASE_OUT"
	#
	# code_example:
	# "var tween = create_tween()\ntween.tween_property(node, \"position\", end_pos, duration).set_trans(Tween.{transition}).set_ease(Tween.{ease})"
	var config = {}  # 여기를 수정하세요
	return config

func calculate_tween_value(t: float, ease_type: String) -> float:
	# TODO: 시간 t (0.0~1.0)에서의 이징 값을 계산하세요
	# t를 0.0~1.0 범위로 클램프한 후 계산합니다
	#
	# ease_type별 공식:
	# "linear": t 그대로 반환
	# "ease_in": t * t (가속)
	# "ease_out": 1.0 - (1.0 - t) * (1.0 - t) (감속)
	# "ease_in_out":
	#   t < 0.5: 2.0 * t * t
	#   t >= 0.5: 1.0 - pow(-2.0 * t + 2.0, 2) / 2.0
	# "bounce":
	#   t2 = 1.0 - t
	#   n1 = 7.5625
	#   if t2 < 1/2.75: 1.0 - n1 * t2 * t2
	#   elif t2 < 2/2.75: t2 -= 1.5/2.75; 1.0 - (n1 * t2 * t2 + 0.75)
	#   elif t2 < 2.5/2.75: t2 -= 2.25/2.75; 1.0 - (n1 * t2 * t2 + 0.9375)
	#   else: t2 -= 2.625/2.75; 1.0 - (n1 * t2 * t2 + 0.984375)
	# 그 외: t 그대로 반환
	var value = 0.0  # 여기를 수정하세요
	return value


# ============================================================
# 연습 5: 절차적 애니메이션
# ============================================================
# 절차적(Procedural) 애니메이션은 코드로 실시간 계산합니다.
# 흔들림, 호흡, 추적 등의 유기적 움직임에 적합합니다.

func calculate_bobbing_motion(time: float, amplitude: float, frequency: float) -> Dictionary:
	# TODO: 걷기 시 카메라 흔들림(bobbing)을 계산하세요
	# FPS 게임의 걷기 효과에 사용됩니다
	#
	# 계산:
	# bob_y = sin(time * frequency) * amplitude
	# bob_x = cos(time * frequency * 0.5) * amplitude * 0.5
	# bob_roll = sin(time * frequency * 0.5) * amplitude * 0.1  (약간의 회전)
	#
	# 반환 형식:
	# {
	#   "offset": Vector3(bob_x, bob_y, 0),
	#   "rotation_roll": bob_roll,
	#   "time": time,
	#   "amplitude": amplitude,
	#   "frequency": frequency,
	#   "phase": fmod(time * frequency, TAU),
	#   "is_step_down": bob_y < -amplitude * 0.5 (발이 착지하는 순간)
	# }
	var result = {}  # 여기를 수정하세요
	return result

func calculate_look_at_ik(
	head_position: Vector3,
	target_position: Vector3,
	max_angle_degrees: float,
	smooth_speed: float,
	current_look_direction: Vector3
) -> Dictionary:
	# TODO: 캐릭터 머리가 타겟을 바라보는 IK(Inverse Kinematics)를 계산하세요
	#
	# 1. 목표 방향: (target_position - head_position).normalized()
	# 2. 목표와 현재 방향 사이의 각도 계산:
	#    angle = rad_to_deg(current_look_direction.angle_to(desired_direction))
	# 3. 최대 각도 제한:
	#    angle이 max_angle_degrees를 초과하면 current_look_direction을 유지
	# 4. 부드러운 보간:
	#    new_direction = current_look_direction.lerp(desired_direction, smooth_speed)
	#    new_direction을 정규화
	#
	# 반환 형식:
	# {
	#   "look_direction": 새로운 시선 방향,
	#   "angle_to_target": 타겟까지의 각도(도),
	#   "is_in_range": angle <= max_angle_degrees,
	#   "target_distance": head_position.distance_to(target_position),
	#   "blend_weight": 1.0 - (angle / max_angle_degrees) 범위 [0, 1] 클램프
	# }
	#
	# 주의: 방향 벡터가 0이면 기본 전방(0, 0, -1)을 사용하세요
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 18: 3D 애니메이션 ===")
	print("")

	# 테스트 1: 애니메이션 재생 제어
	print("--- 연습 1: 애니메이션 재생 ---")
	current_animation = "idle"
	animation_playing = false
	animation_queue = []
	var play1 = play_animation("walk")
	print("결과 1-1 (idle->walk):", play1)
	var play2 = play_animation("walk")
	print("결과 1-2 (walk 중복):", play2)
	var play3 = play_animation("run", 0.5)
	print("결과 1-3 (walk->run):", play3)

	var q1 = queue_animation("jump")
	var q2 = queue_animation("land")
	print("결과 1-4 (큐 추가):", q1)
	print("결과 1-5 (큐 추가):", q2)

	var spd1 = set_animation_speed(2.0)
	var spd2 = set_animation_speed(0.0)
	var spd3 = set_animation_speed(-1.0)
	print("결과 1-6 (2배속):", spd1)
	print("결과 1-7 (일시정지):", spd2)
	print("결과 1-8 (역재생):", spd3)
	print("")

	# 테스트 2: AnimationTree
	print("--- 연습 2: AnimationTree ---")
	var tree_human = create_animation_tree_config("humanoid")
	var tree_creature = create_animation_tree_config("creature")
	var tree_vehicle = create_animation_tree_config("vehicle")
	print("결과 2-1 (인간형 상태):", tree_human)
	if tree_human.has("states"):
		print("  상태 수:", tree_human["states"].size(), " (기대값: 9)")
	print("결과 2-2 (크리처):", tree_creature)
	print("결과 2-3 (차량):", tree_vehicle)
	print("")

	# 테스트 3: BlendSpace
	print("--- 연습 3: BlendSpace ---")
	var bs1d = create_blend_space_config(1)
	var bs2d = create_blend_space_config(2)
	print("결과 3-1 (1D BlendSpace):", bs1d)
	if bs1d.has("blend_points"):
		print("  블렌드 포인트 수:", bs1d["blend_points"].size(), " (기대값: 4)")
	print("결과 3-2 (2D BlendSpace):", bs2d)
	if bs2d.has("blend_points"):
		print("  블렌드 포인트 수:", bs2d["blend_points"].size(), " (기대값: 9)")
	print("")

	# 테스트 4: Tween 3D
	print("--- 연습 4: Tween 3D ---")
	var tween1 = create_tween_sequence(
		Vector3.ZERO, Vector3(5, 3, 0), 2.0, "ease_out"
	)
	var tween2 = create_tween_sequence(
		Vector3(0, 10, 0), Vector3(0, 0, 0), 1.0, "bounce"
	)
	print("결과 4-1 (ease_out):", tween1)
	print("결과 4-2 (bounce):", tween2)

	var ease_vals = []
	for ease in ["linear", "ease_in", "ease_out", "ease_in_out", "bounce"]:
		ease_vals.append({"type": ease, "at_0.5": calculate_tween_value(0.5, ease)})
	print("결과 4-3 (이징 t=0.5):", ease_vals)
	print("")

	# 테스트 5: 절차적 애니메이션
	print("--- 연습 5: 절차적 애니메이션 ---")
	var bob1 = calculate_bobbing_motion(0.0, 0.05, 10.0)
	var bob2 = calculate_bobbing_motion(0.5, 0.05, 10.0)
	print("결과 5-1 (t=0 bobbing):", bob1)
	print("결과 5-2 (t=0.5 bobbing):", bob2)

	var ik1 = calculate_look_at_ik(
		Vector3(0, 1.7, 0), Vector3(3, 1.5, -5),
		60.0, 0.1, Vector3(0, 0, -1)
	)
	var ik2 = calculate_look_at_ik(
		Vector3(0, 1.7, 0), Vector3(10, 1.5, 10),
		45.0, 0.1, Vector3(0, 0, -1)
	)
	print("결과 5-3 (IK 전방):", ik1)
	if ik1.has("is_in_range"):
		print("  범위 내:", ik1["is_in_range"])
	print("결과 5-4 (IK 후방):", ik2)
	if ik2.has("is_in_range"):
		print("  범위 내:", ik2["is_in_range"])
	print("")

	print("=== 챕터 18 완료 ===")
