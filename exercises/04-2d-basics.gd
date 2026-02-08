# 챕터 4: 2D 게임 기초
#
# 이 챕터에서는 다음을 학습합니다:
# - Input 시스템과 액션 매핑
# - 8방향 이동 벡터 계산
# - 중력 시뮬레이션
# - 점프 메카닉 구현
# - Camera2D 설정
# - delta time을 활용한 프레임 독립적 이동

extends Node


# =============================================
# 게임 상수 (연습에서 사용)
# =============================================
const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0
const GRAVITY: float = 980.0
const CAMERA_ZOOM: float = 2.0
const CAMERA_SMOOTHING: float = 5.0


func _ready():
	# =============================================
	# 연습 1: Input 액션 체크 함수
	# =============================================
	# TODO: check_input_actions() 함수를 완성하세요
	# Godot의 Input 시스템에서 사용하는 주요 함수들의 차이를 설명합니다
	# 반환값: 각 함수의 설명을 담은 딕셔너리
	var input_info = check_input_actions()

	# =============================================
	# 연습 2: 8방향 이동 벡터 계산
	# =============================================
	# TODO: calculate_movement() 함수를 완성하세요
	# 입력 방향에 따라 정규화된 이동 벡터를 반환합니다
	# 대각선 이동 시에도 속도가 일정하도록 normalize()를 적용합니다
	var move_right = calculate_movement(1, 0)         # 오른쪽: Vector2(1, 0)
	var move_up_right = calculate_movement(1, -1)     # 오른쪽 위 대각선 (정규화됨)
	var move_none = calculate_movement(0, 0)          # 정지: Vector2(0, 0)
	var move_left_down = calculate_movement(-1, 1)    # 왼쪽 아래 대각선 (정규화됨)

	# =============================================
	# 연습 3: 중력 적용 로직
	# =============================================
	# TODO: apply_gravity() 함수를 완성하세요
	# 현재 y속도에 중력을 delta time만큼 적용합니다
	# velocity.y += GRAVITY * delta
	# 바닥에 있으면 중력을 적용하지 않습니다
	var vel1 = apply_gravity(0.0, false, 0.016)      # 공중: 0 + 980 * 0.016
	var vel2 = apply_gravity(100.0, false, 0.016)    # 공중: 100 + 980 * 0.016
	var vel3 = apply_gravity(100.0, true, 0.016)     # 바닥: 중력 무시 -> 0.0

	# =============================================
	# 연습 4: 점프 구현
	# =============================================
	# TODO: try_jump() 함수를 완성하세요
	# 조건: 바닥에 있을 때(is_on_floor)만 점프 가능
	# 점프 시 y속도를 JUMP_VELOCITY로 설정 (음수 = 위로)
	# 반환값: 점프 후의 y속도
	var jump1 = try_jump(0.0, true, true)       # 바닥 + 점프 입력 -> JUMP_VELOCITY
	var jump2 = try_jump(0.0, false, true)      # 공중 + 점프 입력 -> 0.0 (점프 불가)
	var jump3 = try_jump(0.0, true, false)      # 바닥 + 입력 없음 -> 0.0 (점프 안함)

	# =============================================
	# 연습 5: Camera2D 설정 함수
	# =============================================
	# TODO: get_camera_config() 함수를 완성하세요
	# Camera2D에 적용할 설정값을 딕셔너리로 반환합니다
	# 실제 Camera2D 노드는 없으므로 설정 데이터만 구성합니다
	var camera_config = get_camera_config()

	# =============================================
	# 연습 6: delta time 적용
	# =============================================
	# TODO: move_with_delta() 함수를 완성하세요
	# position += velocity * delta 공식을 적용합니다
	# delta time을 사용해야 프레임 속도와 관계없이 일정한 속도로 이동합니다
	var pos1 = move_with_delta(Vector2(0, 0), Vector2(200, 0), 0.016)     # 60fps
	var pos2 = move_with_delta(Vector2(0, 0), Vector2(200, 0), 0.033)     # 30fps
	var pos3 = move_with_delta(Vector2(100, 50), Vector2(-100, 200), 0.016)

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 4: 2D 게임 기초 ===")

	print("--- 연습 1: Input 액션 체크 ---")
	print("결과 1 (Input 함수 설명): ", input_info)

	print("--- 연습 2: 8방향 이동 벡터 ---")
	print("결과 2-1 (오른쪽): ", move_right, " (기대값: (1, 0))")
	print("결과 2-2 (오른쪽 위): ", move_up_right, " (기대값: ~(0.707, -0.707))")
	print("결과 2-3 (정지): ", move_none, " (기대값: (0, 0))")
	print("결과 2-4 (왼쪽 아래): ", move_left_down, " (기대값: ~(-0.707, 0.707))")

	print("--- 연습 3: 중력 적용 ---")
	print("결과 3-1 (공중, 초기속도 0): ", vel1, " (기대값: ~15.68)")
	print("결과 3-2 (공중, 초기속도 100): ", vel2, " (기대값: ~115.68)")
	print("결과 3-3 (바닥): ", vel3, " (기대값: 0.0)")

	print("--- 연습 4: 점프 ---")
	print("결과 4-1 (바닥+점프): ", jump1, " (기대값: ", JUMP_VELOCITY, ")")
	print("결과 4-2 (공중+점프): ", jump2, " (기대값: 0.0)")
	print("결과 4-3 (바닥+입력없음): ", jump3, " (기대값: 0.0)")

	print("--- 연습 5: Camera2D 설정 ---")
	print("결과 5 (카메라 설정): ", camera_config)

	print("--- 연습 6: delta time 적용 ---")
	print("결과 6-1 (60fps 이동): ", pos1, " (기대값: ~(3.2, 0))")
	print("결과 6-2 (30fps 이동): ", pos2, " (기대값: ~(6.6, 0))")
	print("결과 6-3 (복합 이동): ", pos3, " (기대값: ~(98.4, 53.2))")
	print("=== 완료 ===\n")


# =============================================
# 연습 1: Input 액션 체크 함수
# =============================================
# TODO: Godot Input 시스템의 주요 함수 4가지의 설명을 딕셔너리로 반환하세요
# 키: 함수명, 값: 설명 문자열
# 함수 목록:
#   - "is_action_pressed": 액션이 눌려있는 동안 계속 true
#   - "is_action_just_pressed": 액션이 처음 눌린 프레임에만 true
#   - "is_action_just_released": 액션을 뗀 프레임에만 true
#   - "get_action_strength": 액션의 강도를 0.0~1.0 float로 반환
func check_input_actions() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 2: 8방향 이동 벡터 계산 함수
# =============================================
# TODO: 입력 방향(input_x, input_y)을 받아 정규화된 이동 벡터를 반환하세요
# input_x: -1(왼쪽), 0(없음), 1(오른쪽)
# input_y: -1(위), 0(없음), 1(아래) -- Godot은 y축 아래가 양수
# 벡터가 (0,0)이면 그대로 반환, 그 외에는 normalized() 적용
# 힌트:
#   var direction = Vector2(input_x, input_y)
#   if direction.length() > 0:
#       direction = direction.normalized()
func calculate_movement(input_x: float, input_y: float) -> Vector2:
	return Vector2.ZERO  # 여기를 수정하세요


# =============================================
# 연습 3: 중력 적용 함수
# =============================================
# TODO: 현재 y속도에 중력을 적용하여 새로운 y속도를 반환하세요
# - is_on_floor가 true이면 y속도를 0으로 리셋
# - is_on_floor가 false이면 velocity_y += GRAVITY * delta
# 매개변수:
#   velocity_y: 현재 y축 속도
#   is_on_floor: 바닥에 있는지 여부
#   delta: 프레임 간 시간차
func apply_gravity(velocity_y: float, is_on_floor: bool, delta: float) -> float:
	return 0.0  # 여기를 수정하세요


# =============================================
# 연습 4: 점프 구현 함수
# =============================================
# TODO: 점프 조건을 확인하고 점프 후의 y속도를 반환하세요
# 조건: is_on_floor == true AND jump_pressed == true
# 점프 시: JUMP_VELOCITY 반환 (음수값 = 위로 이동)
# 그 외: 현재 velocity_y를 그대로 반환
# 매개변수:
#   velocity_y: 현재 y축 속도
#   is_on_floor: 바닥에 있는지 여부
#   jump_pressed: 점프 버튼이 눌렸는지 여부
func try_jump(velocity_y: float, is_on_floor: bool, jump_pressed: bool) -> float:
	return 0.0  # 여기를 수정하세요


# =============================================
# 연습 5: Camera2D 설정 함수
# =============================================
# TODO: Camera2D 설정값을 딕셔너리로 반환하세요
# 반환 형식:
# {
#   "zoom": Vector2(CAMERA_ZOOM, CAMERA_ZOOM),
#   "position_smoothing_enabled": true,
#   "position_smoothing_speed": CAMERA_SMOOTHING,
#   "limit_left": 0,
#   "limit_top": 0,
#   "limit_right": 1920,
#   "limit_bottom": 1080,
#   "drag_horizontal_enabled": true,
#   "drag_vertical_enabled": true
# }
func get_camera_config() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 6: delta time 적용 이동 함수
# =============================================
# TODO: 현재 위치에 속도 * delta를 적용한 새 위치를 반환하세요
# 공식: new_position = current_position + velocity * delta
# 매개변수:
#   current_pos: 현재 위치 (Vector2)
#   velocity: 속도 벡터 (Vector2)
#   delta: 프레임 간 시간차 (float)
func move_with_delta(current_pos: Vector2, velocity: Vector2, delta: float) -> Vector2:
	return Vector2.ZERO  # 여기를 수정하세요
