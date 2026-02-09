# 챕터 15: 3D 캐릭터 컨트롤러
#
# 이 챕터에서는 다음을 학습합니다:
# - 마우스 캡처 및 해제 처리
# - 마우스 이동으로 카메라 회전 (FPS 룩)
# - WASD 키 입력 기반 3D 이동
# - 중력 적용과 점프 메카닉
# - 스프린트(달리기) 시스템
# - 3인칭(TPS) 카메라 설정

extends Node3D


# ============================================================
# 캐릭터 상수
# ============================================================
const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 9.0
const JUMP_VELOCITY: float = 6.0
const GRAVITY: float = 9.8
const MOUSE_SENSITIVITY: float = 0.002
const CAMERA_CLAMP_MIN: float = -89.0
const CAMERA_CLAMP_MAX: float = 89.0


# ============================================================
# 연습 1: 마우스 캡처 시스템
# ============================================================
# FPS/TPS 게임에서 마우스 커서를 숨기고 게임 화면에 고정합니다.
# ESC 키로 커서를 다시 표시하여 메뉴 등을 사용할 수 있게 합니다.

var is_mouse_captured: bool = false

func get_mouse_mode_info() -> Dictionary:
	# TODO: Godot의 마우스 모드 상수와 설명을 Dictionary로 반환하세요
	# {
	#   "MOUSE_MODE_VISIBLE": {
	#     "value": "Input.MOUSE_MODE_VISIBLE",
	#     "description": "커서가 보이고 자유롭게 이동 (기본값)"
	#   },
	#   "MOUSE_MODE_HIDDEN": {
	#     "value": "Input.MOUSE_MODE_HIDDEN",
	#     "description": "커서가 숨겨지지만 여전히 이동 가능"
	#   },
	#   "MOUSE_MODE_CAPTURED": {
	#     "value": "Input.MOUSE_MODE_CAPTURED",
	#     "description": "커서가 숨겨지고 화면 중앙에 고정 (FPS용)"
	#   },
	#   "MOUSE_MODE_CONFINED": {
	#     "value": "Input.MOUSE_MODE_CONFINED",
	#     "description": "커서가 보이지만 창 밖으로 나갈 수 없음"
	#   },
	#   "MOUSE_MODE_CONFINED_HIDDEN": {
	#     "value": "Input.MOUSE_MODE_CONFINED_HIDDEN",
	#     "description": "커서가 숨겨지고 창 밖으로 나갈 수 없음"
	#   }
	# }
	var info = {}  # 여기를 수정하세요
	return info

func toggle_mouse_capture() -> Dictionary:
	# TODO: 마우스 캡처 상태를 토글하고 결과를 반환하세요
	# is_mouse_captured가 true이면 false로, false이면 true로 변경
	#
	# 반환 형식:
	# {
	#   "is_captured": 변경 후 상태,
	#   "mouse_mode": 적용할 모드 문자열
	#     (캡처: "MOUSE_MODE_CAPTURED", 해제: "MOUSE_MODE_VISIBLE"),
	#   "instruction": 사용자에게 보여줄 안내 문자열
	#     (캡처: "ESC를 눌러 커서를 해제하세요",
	#      해제: "클릭하여 게임에 집중하세요")
	# }
	#
	# TODO: is_mouse_captured 변수도 업데이트하세요
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 2: 마우스 룩 회전
# ============================================================
# 마우스 이동(InputEventMouseMotion)을 카메라 회전으로 변환합니다.
# X축 이동 -> 수평 회전 (yaw), Y축 이동 -> 수직 회전 (pitch)

var camera_rotation_x: float = 0.0  # pitch (상하), 단위: 도(degree)
var camera_rotation_y: float = 0.0  # yaw (좌우), 단위: 도(degree)

func apply_mouse_look(mouse_delta: Vector2) -> Dictionary:
	# TODO: 마우스 이동량을 카메라 회전에 적용하세요
	# mouse_delta: 마우스 이동량 (pixels)
	#
	# 계산:
	# 1. yaw(좌우 회전): camera_rotation_y -= mouse_delta.x * MOUSE_SENSITIVITY * (180/PI)
	#    (라디안을 도로 변환하여 저장)
	# 2. pitch(상하 회전): camera_rotation_x -= mouse_delta.y * MOUSE_SENSITIVITY * (180/PI)
	# 3. pitch 클램프: camera_rotation_x를 CAMERA_CLAMP_MIN ~ CAMERA_CLAMP_MAX 범위로 제한
	#    (힌트: clamp(camera_rotation_x, CAMERA_CLAMP_MIN, CAMERA_CLAMP_MAX))
	#
	# TODO: camera_rotation_x, camera_rotation_y 변수를 업데이트하세요
	#
	# 반환 형식:
	# {
	#   "rotation_x": camera_rotation_x,  (pitch, 도)
	#   "rotation_y": camera_rotation_y,  (yaw, 도)
	#   "rotation_degrees": Vector3(camera_rotation_x, camera_rotation_y, 0),
	#   "is_looking_up": camera_rotation_x > 0,
	#   "is_looking_down": camera_rotation_x < 0
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 3: WASD 이동 구현
# ============================================================
# 카메라의 방향을 기준으로 WASD 이동 벡터를 계산합니다.
# 카메라가 바라보는 방향이 "앞"이 됩니다.

func calculate_wasd_movement(
	input_dir: Vector2,  # x: 좌우(A/D), y: 전후(W/S) -- W=-1, S=1
	camera_yaw_degrees: float,
	speed: float
) -> Dictionary:
	# TODO: 카메라 방향 기준의 이동 벡터를 계산하세요
	#
	# 1. 카메라 yaw를 라디안으로 변환: yaw_rad = deg_to_rad(camera_yaw_degrees)
	# 2. 카메라의 전방(forward) 벡터: Vector3(sin(yaw_rad), 0, cos(yaw_rad))
	#    (Godot에서 yaw 0도는 -Z 방향이므로 주의)
	#    간소화: forward = Vector3(-sin(yaw_rad), 0, -cos(yaw_rad))
	# 3. 카메라의 우측(right) 벡터: Vector3(cos(yaw_rad), 0, -sin(yaw_rad))
	# 4. 이동 방향: forward * (-input_dir.y) + right * input_dir.x
	#    (input_dir.y가 -1이면 W 키 = 앞으로)
	# 5. 이동 방향이 0이 아니면 정규화 후 speed 적용
	#
	# 반환 형식:
	# {
	#   "direction": 정규화된 이동 방향 Vector3 (y=0),
	#   "velocity": direction * speed,
	#   "forward": 카메라 전방 벡터,
	#   "right": 카메라 우측 벡터,
	#   "is_moving": 이동 중인지 여부
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 4: 중력과 점프
# ============================================================
# 3D에서의 중력 적용과 점프 구현입니다.
# Y축이 상하 방향이며, 중력은 매 프레임 속도에 누적됩니다.

var vertical_velocity: float = 0.0
var is_jumping: bool = false
var jump_count: int = 0
const MAX_JUMPS: int = 2  # 더블 점프 허용

func apply_gravity_and_jump(
	is_on_floor: bool,
	wants_jump: bool,
	delta: float
) -> Dictionary:
	# TODO: 중력과 점프를 적용하여 수직 속도를 계산하세요
	#
	# 1. 바닥에 있을 때:
	#    - vertical_velocity를 0으로 리셋
	#    - jump_count를 0으로 리셋
	#    - is_jumping을 false로 설정
	#
	# 2. 점프 입력 처리 (wants_jump이 true):
	#    - jump_count < MAX_JUMPS이면 점프 가능
	#    - vertical_velocity = JUMP_VELOCITY
	#    - jump_count += 1
	#    - is_jumping = true
	#
	# 3. 공중에 있을 때 (바닥 아님):
	#    - vertical_velocity -= GRAVITY * delta
	#
	# TODO: vertical_velocity, is_jumping, jump_count를 업데이트하세요
	#
	# 반환 형식:
	# {
	#   "vertical_velocity": vertical_velocity,
	#   "is_jumping": is_jumping,
	#   "jump_count": jump_count,
	#   "is_on_floor": is_on_floor,
	#   "is_falling": vertical_velocity < 0 and !is_on_floor,
	#   "can_jump": jump_count < MAX_JUMPS
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 5: 스프린트 시스템
# ============================================================
# Shift 키를 누르면 이동 속도가 증가하는 스프린트 기능입니다.
# 스태미나(stamina) 시스템으로 무한 스프린트를 방지합니다.

var stamina: float = 100.0
const MAX_STAMINA: float = 100.0
const STAMINA_DRAIN_RATE: float = 20.0   # 초당 소모량
const STAMINA_REGEN_RATE: float = 15.0   # 초당 회복량
const STAMINA_REGEN_DELAY: float = 1.0   # 회복 시작 지연 (초)
var stamina_regen_timer: float = 0.0

func update_sprint(
	wants_sprint: bool,
	is_moving: bool,
	delta: float
) -> Dictionary:
	# TODO: 스프린트 상태를 업데이트하고 현재 속도를 반환하세요
	#
	# 1. 스프린트 조건: wants_sprint AND is_moving AND stamina > 0
	# 2. 스프린트 중:
	#    - stamina -= STAMINA_DRAIN_RATE * delta
	#    - stamina = max(stamina, 0)  (0 미만 방지)
	#    - stamina_regen_timer = STAMINA_REGEN_DELAY  (회복 지연 리셋)
	#    - 현재 속도 = SPRINT_SPEED
	#
	# 3. 스프린트 아닐 때:
	#    - stamina_regen_timer -= delta
	#    - stamina_regen_timer가 0 이하이고 stamina < MAX_STAMINA이면:
	#      stamina += STAMINA_REGEN_RATE * delta
	#      stamina = min(stamina, MAX_STAMINA)
	#    - 현재 속도 = WALK_SPEED
	#
	# TODO: stamina, stamina_regen_timer를 업데이트하세요
	#
	# 반환 형식:
	# {
	#   "is_sprinting": 실제로 스프린트 중인지,
	#   "current_speed": 적용할 이동 속도,
	#   "stamina": 현재 스태미나,
	#   "stamina_percent": (stamina / MAX_STAMINA) * 100.0,
	#   "is_exhausted": stamina <= 0
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 6: 3인칭(TPS) 카메라 설정
# ============================================================
# 3인칭 카메라는 캐릭터 뒤에서 따라가는 카메라입니다.
# SpringArm3D 노드를 사용하여 벽 관통을 방지합니다.

func create_tps_camera_config(
	target_position: Vector3,
	camera_distance: float,
	camera_height: float,
	camera_yaw: float,
	camera_pitch: float
) -> Dictionary:
	# TODO: TPS 카메라의 설정을 계산하여 Dictionary로 반환하세요
	#
	# 1. SpringArm3D 설정:
	#    - "spring_length": camera_distance (캐릭터와 카메라 사이 거리)
	#    - "margin": 0.2  (벽과의 여유 거리)
	#    - "collision_mask": 1  (환경 레이어)
	#
	# 2. 카메라 위치 계산 (구면 좌표 -> 직교 좌표):
	#    pitch_rad = deg_to_rad(camera_pitch)
	#    yaw_rad = deg_to_rad(camera_yaw)
	#    offset_x = camera_distance * cos(pitch_rad) * sin(yaw_rad)
	#    offset_y = camera_distance * sin(pitch_rad) + camera_height
	#    offset_z = camera_distance * cos(pitch_rad) * cos(yaw_rad)
	#    camera_position = target_position + Vector3(offset_x, offset_y, offset_z)
	#
	# 3. 카메라가 바라볼 지점:
	#    look_target = target_position + Vector3(0, camera_height * 0.5, 0)
	#    (캐릭터의 상체 부분을 바라봄)
	#
	# 반환 형식:
	# {
	#   "spring_arm": {
	#     "spring_length": camera_distance,
	#     "margin": 0.2,
	#     "collision_mask": 1
	#   },
	#   "camera_position": 계산된 카메라 위치,
	#   "look_target": 카메라가 바라볼 지점,
	#   "target_position": 캐릭터 위치,
	#   "rotation": Vector3(camera_pitch, camera_yaw, 0)
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 15: 3D 캐릭터 컨트롤러 ===")
	print("")

	# 테스트 1: 마우스 캡처
	print("--- 연습 1: 마우스 캡처 ---")
	var mouse_modes = get_mouse_mode_info()
	print("결과 1-1 (마우스 모드 목록):", mouse_modes)
	is_mouse_captured = false
	var capture1 = toggle_mouse_capture()
	print("결과 1-2 (캡처 토글):", capture1)
	print("  캡처 상태:", is_mouse_captured, " (기대값: true)")
	var capture2 = toggle_mouse_capture()
	print("결과 1-3 (해제 토글):", capture2)
	print("  캡처 상태:", is_mouse_captured, " (기대값: false)")
	print("")

	# 테스트 2: 마우스 룩
	print("--- 연습 2: 마우스 룩 ---")
	camera_rotation_x = 0.0
	camera_rotation_y = 0.0
	var look1 = apply_mouse_look(Vector2(100, 0))
	print("결과 2-1 (수평 회전):", look1)
	camera_rotation_x = 0.0
	camera_rotation_y = 0.0
	var look2 = apply_mouse_look(Vector2(0, -500))
	print("결과 2-2 (위로 크게 회전):", look2)
	if look2.has("rotation_x"):
		print("  pitch:", look2["rotation_x"], " (클램프:", CAMERA_CLAMP_MAX, ")")
	print("")

	# 테스트 3: WASD 이동
	print("--- 연습 3: WASD 이동 ---")
	var wasd1 = calculate_wasd_movement(Vector2(0, -1), 0.0, WALK_SPEED)
	var wasd2 = calculate_wasd_movement(Vector2(1, 0), 0.0, WALK_SPEED)
	var wasd3 = calculate_wasd_movement(Vector2(0, -1), 90.0, WALK_SPEED)
	var wasd4 = calculate_wasd_movement(Vector2.ZERO, 0.0, WALK_SPEED)
	print("결과 3-1 (W키, yaw=0):", wasd1)
	print("결과 3-2 (D키, yaw=0):", wasd2)
	print("결과 3-3 (W키, yaw=90):", wasd3)
	print("결과 3-4 (입력 없음):", wasd4)
	print("")

	# 테스트 4: 중력과 점프
	print("--- 연습 4: 중력과 점프 ---")
	vertical_velocity = 0.0
	jump_count = 0
	is_jumping = false
	var grav1 = apply_gravity_and_jump(true, false, 0.016)
	print("결과 4-1 (바닥, 점프 안함):", grav1)
	var grav2 = apply_gravity_and_jump(true, true, 0.016)
	print("결과 4-2 (바닥, 첫 점프):", grav2)
	var grav3 = apply_gravity_and_jump(false, false, 0.016)
	print("결과 4-3 (공중, 중력 적용):", grav3)
	var grav4 = apply_gravity_and_jump(false, true, 0.016)
	print("결과 4-4 (공중, 더블 점프):", grav4)
	var grav5 = apply_gravity_and_jump(false, true, 0.016)
	print("결과 4-5 (공중, 점프 불가):", grav5)
	print("")

	# 테스트 5: 스프린트
	print("--- 연습 5: 스프린트 ---")
	stamina = MAX_STAMINA
	stamina_regen_timer = 0.0
	var sprint1 = update_sprint(true, true, 0.5)
	print("결과 5-1 (스프린트 0.5초):", sprint1)
	var sprint2 = update_sprint(false, true, 0.5)
	print("결과 5-2 (걷기 0.5초):", sprint2)
	stamina = 0.0
	var sprint3 = update_sprint(true, true, 0.016)
	print("결과 5-3 (스태미나 고갈 스프린트):", sprint3)
	print("")

	# 테스트 6: TPS 카메라
	print("--- 연습 6: TPS 카메라 ---")
	var tps1 = create_tps_camera_config(Vector3.ZERO, 5.0, 2.0, 0.0, -20.0)
	var tps2 = create_tps_camera_config(Vector3(10, 0, 5), 8.0, 3.0, 45.0, -15.0)
	print("결과 6-1 (기본 TPS):", tps1)
	print("결과 6-2 (이동 중 TPS):", tps2)
	print("")

	print("=== 챕터 15 완료 ===")
