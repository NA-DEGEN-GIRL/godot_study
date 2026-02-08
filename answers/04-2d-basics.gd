# 챕터 4: 2D 게임 기초 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - Input 시스템으로 키 입력 감지
# - Vector2로 8방향 이동 구현
# - 중력(Gravity) 적용
# - 점프 구현
# - Camera2D 설정
# - delta time으로 프레임 독립적 이동

extends CharacterBody2D

# =============================================
# 연습 1에서 사용할 변수
# =============================================
# 풀이: 게임에서 자주 사용하는 상수/변수를 클래스 상단에 선언합니다.
# @export로 에디터에서 조정 가능하게 만들면 밸런싱이 편합니다.
@export var move_speed: float = 300.0
@export var jump_force: float = -500.0
@export var gravity_force: float = 980.0

# 상태 추적 변수
var input_log: Array = []
var direction: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var total_time: float = 0.0
var frame_count: int = 0
var max_test_frames: int = 5


func _ready():
	print("\n=== 챕터 4: 2D 게임 기초 ===")

	# =============================================
	# 연습 1: Input 시스템 이해
	# =============================================
	# 풀이: Godot의 Input 시스템은 여러 방식으로 입력을 감지합니다.
	# - Input.is_action_pressed("action"): 키를 누르고 있는 동안 true
	# - Input.is_action_just_pressed("action"): 키를 누른 순간만 true (한 프레임)
	# - Input.is_action_just_released("action"): 키를 뗀 순간만 true
	# - Input.get_axis("neg", "pos"): -1.0 ~ 1.0 사이 값 반환
	# - Input.get_vector("left", "right", "up", "down"): Vector2 반환
	# 추가 설명: 입력 액션은 프로젝트 설정 > 입력 맵에서 정의합니다.
	# Godot 4.x는 기본 액션 "ui_left", "ui_right", "ui_up", "ui_down"을 제공합니다.
	print("--- 연습 1: Input 시스템 ---")

	# Input 시스템 API 요약 출력
	var input_methods: Dictionary = {
		"is_action_pressed": "키를 누르고 있는 동안 true 반환",
		"is_action_just_pressed": "키를 누른 순간(1프레임)만 true 반환",
		"is_action_just_released": "키를 뗀 순간(1프레임)만 true 반환",
		"get_axis": "두 액션의 차이를 -1.0~1.0으로 반환",
		"get_vector": "4방향 액션을 Vector2로 반환"
	}

	for method in input_methods:
		print("  Input.", method, "(): ", input_methods[method])

	# =============================================
	# 연습 5: Camera2D 설정 (개념)
	# =============================================
	# 풀이: Camera2D는 2D 게임의 시점(뷰포트)을 제어합니다.
	# 플레이어의 자식으로 배치하면 자동으로 플레이어를 따라갑니다.
	# 주요 속성:
	# - zoom: 확대/축소 (Vector2(2,2)면 2배 확대)
	# - limit_left/right/top/bottom: 카메라 이동 범위 제한
	# - position_smoothing_enabled: 부드러운 추적
	# - position_smoothing_speed: 추적 속도 (낮을수록 느린 추적)
	# - drag_horizontal/vertical_enabled: 드래그 마진 사용
	# 추가 설명: 하나의 씬에서 활성(enabled) Camera2D는 하나만 가능합니다.
	print("--- 연습 5: Camera2D 설정 ---")

	var camera = Camera2D.new()
	camera.name = "PlayerCamera"

	# 카메라 기본 설정
	camera.zoom = Vector2(1.5, 1.5)           # 1.5배 확대
	camera.position_smoothing_enabled = true    # 부드러운 추적 활성화
	camera.position_smoothing_speed = 5.0       # 추적 속도
	camera.limit_left = 0                       # 왼쪽 제한
	camera.limit_top = 0                        # 위쪽 제한
	camera.limit_right = 1920                   # 오른쪽 제한 (예: 맵 너비)
	camera.limit_bottom = 1080                  # 아래쪽 제한 (예: 맵 높이)

	add_child(camera)

	print("결과 5-1 (카메라 줌): ", camera.zoom)
	print("결과 5-2 (스무딩 활성): ", camera.position_smoothing_enabled)
	print("결과 5-3 (스무딩 속도): ", camera.position_smoothing_speed)
	print("결과 5-4 (제한 left): ", camera.limit_left)
	print("결과 5-5 (제한 right): ", camera.limit_right)

	# =============================================
	# 연습 6: delta time 개념
	# =============================================
	# 풀이: delta(델타)는 이전 프레임부터 현재 프레임까지의 경과 시간(초)입니다.
	# 프레임 속도(FPS)에 관계없이 일정한 이동 속도를 보장합니다.
	# 60FPS: delta ~= 0.0167초, 30FPS: delta ~= 0.0333초
	# speed * delta를 곱하면 FPS에 상관없이 1초에 speed만큼 이동합니다.
	# 추가 설명: delta를 사용하지 않으면 고성능 PC에서 더 빠르게 이동하는
	# 문제가 발생합니다.
	print("--- 연습 6: delta time ---")

	# delta time 시뮬레이션
	var simulated_speed: float = 200.0

	# 60FPS 환경
	var delta_60fps: float = 1.0 / 60.0
	var movement_60fps: float = simulated_speed * delta_60fps

	# 30FPS 환경
	var delta_30fps: float = 1.0 / 30.0
	var movement_30fps: float = simulated_speed * delta_30fps

	print("결과 6-1 (속도): ", simulated_speed, " px/sec")
	print("결과 6-2 (60FPS delta): %.4f초" % delta_60fps)
	print("결과 6-3 (60FPS 프레임당 이동): %.2fpx" % movement_60fps)
	print("결과 6-4 (30FPS delta): %.4f초" % delta_30fps)
	print("결과 6-5 (30FPS 프레임당 이동): %.2fpx" % movement_30fps)
	print("결과 6-6 (1초간 총 이동 60FPS): %.1fpx" % (movement_60fps * 60))
	print("결과 6-7 (1초간 총 이동 30FPS): %.1fpx" % (movement_30fps * 30))
	print("  -> 두 환경 모두 1초에 ", simulated_speed, "px 이동! (프레임 독립적)")

	print("=== 완료 ===\n")


func _physics_process(delta: float):
	# =============================================
	# 연습 2: 8방향 이동 벡터
	# =============================================
	# 풀이: Input.get_vector()는 4개의 액션을 받아 Vector2를 반환합니다.
	# 반환값은 자동으로 정규화(normalize)되어 대각선 이동 시에도
	# 속도가 일정합니다 (길이가 1.0을 넘지 않음).
	# 추가 설명: get_vector()를 사용하지 않고 직접 구현할 수도 있지만,
	# get_vector()가 더 간결하고 정규화를 자동으로 처리합니다.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 수동으로 8방향 벡터를 구하는 방법 (참고용)
	# var manual_dir = Vector2.ZERO
	# if Input.is_action_pressed("ui_left"):
	#     manual_dir.x -= 1
	# if Input.is_action_pressed("ui_right"):
	#     manual_dir.x += 1
	# if Input.is_action_pressed("ui_up"):
	#     manual_dir.y -= 1
	# if Input.is_action_pressed("ui_down"):
	#     manual_dir.y += 1
	# manual_dir = manual_dir.normalized()  # 수동 정규화 필요!

	# 수평 이동 속도 적용
	velocity.x = direction.x * move_speed

	# =============================================
	# 연습 3: 중력 적용
	# =============================================
	# 풀이: 중력은 매 프레임 velocity.y에 가속도를 더해 구현합니다.
	# is_on_floor()는 CharacterBody2D가 바닥과 접촉 중인지 확인합니다.
	# 바닥에 있지 않을 때만 중력을 적용해야 합니다.
	# 추가 설명: 실제 물리에서 중력 가속도는 9.8m/s^2이지만,
	# 게임에서는 기분 좋은 조작감을 위해 더 큰 값을 사용합니다.
	if not is_on_floor():
		velocity.y += gravity_force * delta

	# =============================================
	# 연습 4: 점프 구현
	# =============================================
	# 풀이: 점프는 velocity.y에 음수값(위쪽)을 설정하여 구현합니다.
	# Godot 2D에서 Y축 아래가 양수이므로, 위로 가려면 음수를 사용합니다.
	# is_action_just_pressed를 사용해야 한 번만 점프합니다.
	# is_on_floor() 체크로 공중에서 연속 점프를 방지합니다.
	# 추가 설명: 더 나은 점프 조작감을 위해 다음을 추가로 구현할 수 있습니다:
	# - 점프 버튼을 떼면 상승 속도를 줄이기 (가변 점프 높이)
	# - 코요테 타임 (바닥을 떠난 직후 짧은 시간 동안 점프 허용)
	# - 점프 버퍼 (착지 직전에 누른 점프를 착지 후 실행)
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force
		is_jumping = true

	# 착지 감지
	if is_on_floor() and is_jumping:
		is_jumping = false

	# CharacterBody2D 이동 실행
	# 풀이: move_and_slide()는 velocity를 기반으로 노드를 이동하고,
	# 충돌 시 자동으로 슬라이딩 처리합니다.
	# 내부적으로 delta를 적용하므로 별도로 곱할 필요 없습니다.
	move_and_slide()

	# 디버그 출력 (처음 몇 프레임만)
	if frame_count < max_test_frames:
		frame_count += 1
		total_time += delta
		if frame_count == 1:
			print("--- 연습 2,3,4: 이동/중력/점프 (_physics_process) ---")
		print("  프레임 #%d: pos=%s, vel=%s, on_floor=%s, delta=%.4f" % [
			frame_count, str(global_position), str(velocity),
			str(is_on_floor()), delta
		])
