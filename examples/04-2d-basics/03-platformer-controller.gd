# Chapter 04 - 2D Basics
# 03-platformer-controller.gd - Complete Platformer Character Controller
#
# 이 파일에서 배울 내용:
# - 중력(gravity)과 점프(jump) 구현
# - Coyote Time (절벽 후 잠깐 점프 허용)
# - Jump Buffering (착지 직전 점프 입력 저장)
# - 카메라 추적과 스무딩
#
# 사용법: CharacterBody2D 노드에 붙여서 사용합니다.
# CollisionShape2D, Sprite2D (또는 AnimatedSprite2D)가 필요합니다.
# 단독 실행 시에는 시뮬레이션 결과를 출력합니다.

extends Node

# ============================================
# 1. 물리 상수 정의
# ============================================

# --- 이동 ---
const SPEED: float = 200.0             # 이동 속도 (px/s)
const ACCELERATION: float = 1200.0     # 지상 가속도
const AIR_ACCELERATION: float = 800.0  # 공중 가속도 (지상보다 느림)
const FRICTION: float = 1000.0         # 지상 마찰력
const AIR_FRICTION: float = 200.0      # 공중 마찰력 (적은 감속)

# --- 점프/중력 ---
const JUMP_VELOCITY: float = -350.0    # 점프 초기 속도 (음수 = 위)
const GRAVITY_SCALE: float = 1.0       # 중력 배율
const FALL_GRAVITY_MULTIPLIER: float = 1.5  # 하강 시 중력 증가 (쾌적한 느낌)
const MAX_FALL_SPEED: float = 500.0    # 최대 낙하 속도
const JUMP_CUT_MULTIPLIER: float = 0.5 # 점프 버튼 뗄 때 속도 감소

# --- Coyote Time & Jump Buffer ---
const COYOTE_TIME: float = 0.12        # 절벽 후 점프 허용 시간 (초)
const JUMP_BUFFER_TIME: float = 0.1    # 착지 전 점프 입력 저장 시간 (초)

# --- 상태 변수 ---
var velocity := Vector2.ZERO
var is_on_floor_flag := false
var was_on_floor := false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_jumping := false
var facing_right := true

func _ready():
	print("=== 플랫포머 컨트롤러 ===\n")

	# ============================================
	# 2. 중력 시스템
	# ============================================
	print("--- 중력 시스템 ---\n")

	# Godot의 기본 중력 값 가져오기
	# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var gravity: float = 980.0  # 기본값 시뮬레이션

	print("중력 기본값: %.0f px/s^2" % gravity)
	print("중력은 매 물리 프레임마다 velocity.y에 더해집니다")
	print("")
	print("기본 중력 적용 코드:")
	print("  func _physics_process(delta):")
	print("    if not is_on_floor():")
	print("      velocity.y += gravity * delta")

	# 중력 시뮬레이션
	print("\n낙하 시뮬레이션 (1초간):")
	var sim_vel_y := 0.0
	var sim_pos_y := 0.0
	var dt := 1.0 / 60.0  # 60fps

	for frame in range(60):
		sim_vel_y += gravity * dt
		sim_vel_y = minf(sim_vel_y, MAX_FALL_SPEED)  # 최대 속도 제한
		sim_pos_y += sim_vel_y * dt

		# 10프레임마다 출력
		if (frame + 1) % 10 == 0:
			print("  프레임 %2d: velocity.y = %6.1f, 이동 거리 = %6.1f px" % [
				frame + 1, sim_vel_y, sim_pos_y
			])

	# 가변 중력 (하강 시 더 강한 중력)
	print("\n가변 중력 시스템:")
	print("  상승 중: 기본 중력 (가볍게 뜨는 느낌)")
	print("  하강 중: 중력 x %.1f (빠르게 착지)" % FALL_GRAVITY_MULTIPLIER)
	print("  -> 마리오 같은 쾌적한 점프감을 만듦")

	# ============================================
	# 3. 점프 시스템
	# ============================================
	print("\n--- 점프 시스템 ---\n")

	print("기본 점프:")
	print("  velocity.y = JUMP_VELOCITY  # %.0f (음수 = 위)" % JUMP_VELOCITY)

	# 점프 높이 계산
	# h = v^2 / (2 * g)
	var jump_height := (JUMP_VELOCITY * JUMP_VELOCITY) / (2.0 * gravity)
	var jump_time := absf(JUMP_VELOCITY) / gravity
	print("  예상 최대 높이: %.1f px" % jump_height)
	print("  정점 도달 시간: %.2f초" % jump_time)

	# 점프 시뮬레이션
	print("\n점프 시뮬레이션:")
	sim_vel_y = JUMP_VELOCITY
	sim_pos_y = 0.0
	var max_height := 0.0
	var frame_at_peak := 0

	for frame in range(120):
		# 가변 중력 적용
		var current_gravity: float
		if sim_vel_y < 0:
			current_gravity = gravity * GRAVITY_SCALE
		else:
			current_gravity = gravity * GRAVITY_SCALE * FALL_GRAVITY_MULTIPLIER

		sim_vel_y += current_gravity * dt
		sim_vel_y = minf(sim_vel_y, MAX_FALL_SPEED)
		sim_pos_y += sim_vel_y * dt

		if sim_pos_y < max_height:
			max_height = sim_pos_y
			frame_at_peak = frame + 1

		# 바닥에 도착 (원래 위치 아래로)
		if sim_pos_y > 0 and frame > 0:
			print("  정점: %.1f px (프레임 %d, %.2f초)" % [absf(max_height), frame_at_peak, frame_at_peak * dt])
			print("  착지: 프레임 %d (%.2f초, 체공시간)" % [frame + 1, (frame + 1) * dt])
			break

	# ============================================
	# 4. Coyote Time (코요테 타임)
	# ============================================
	print("\n--- Coyote Time ---\n")

	print("코요테 타임이란?")
	print("  절벽에서 떨어진 직후에도 잠시 동안 점프를 허용하는 기능")
	print("  이름 유래: 만화에서 코요테가 절벽 밖에서 잠시 떠있는 장면")
	print("")
	print("왜 필요한가?")
	print("  - 플레이어는 화면을 보고 점프 타이밍을 결정합니다")
	print("  - 실제로는 절벽 끝을 약간 지나서 점프 키를 누르는 경우가 많습니다")
	print("  - 코요테 타임 없이는 '분명히 눌렀는데 점프가 안 됨!' 이라고 느낍니다")
	print("  - %.0fms의 코요테 타임으로 조작감이 크게 개선됩니다" % (COYOTE_TIME * 1000))

	print("\n구현 로직:")
	print("  1. 바닥에 있으면 coyote_timer = COYOTE_TIME")
	print("  2. 바닥을 벗어나면 타이머 감소 시작")
	print("  3. coyote_timer > 0이면 아직 점프 가능")
	print("  4. 점프를 수행하면 타이머를 0으로 리셋")

	# ============================================
	# 5. Jump Buffering (점프 버퍼링)
	# ============================================
	print("\n--- Jump Buffering ---\n")

	print("점프 버퍼링이란?")
	print("  착지 직전에 점프 키를 눌러도 착지 후 즉시 점프하는 기능")
	print("  입력을 '버퍼(저장)'해두었다가 조건이 맞으면 실행")
	print("")
	print("왜 필요한가?")
	print("  - 빠른 연속 점프 시 타이밍이 빡빡하면 답답함")
	print("  - %.0fms 버퍼로 자연스러운 연속 점프 가능" % (JUMP_BUFFER_TIME * 1000))

	print("\n구현 로직:")
	print("  1. 점프 버튼을 누르면 jump_buffer_timer = BUFFER_TIME")
	print("  2. 매 프레임 타이머 감소")
	print("  3. 바닥에 닿았을 때 jump_buffer_timer > 0이면 점프 실행")
	print("  4. 점프 후 타이머 리셋")

	# ============================================
	# 6. Variable Jump Height (가변 점프 높이)
	# ============================================
	print("\n--- Variable Jump Height ---\n")

	print("점프 버튼을 짧게/길게 눌러서 높이를 조절:")
	print("  - 버튼을 길게 누르면: 높은 점프")
	print("  - 버튼을 짧게 누르면: 낮은 점프")
	print("")
	print("구현:")
	print("  if Input.is_action_just_released('jump') and velocity.y < 0:")
	print("    velocity.y *= JUMP_CUT_MULTIPLIER  # %.1f" % JUMP_CUT_MULTIPLIER)
	print("    -> 상승 중 버튼을 떼면 속도를 줄여 빨리 떨어지게")

	# ============================================
	# 7. 전체 코드 (CharacterBody2D용)
	# ============================================
	print("\n--- 전체 플랫포머 코드 ---\n")

	print("""extends CharacterBody2D

# --- 이동 ---
@export var speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0
@export var air_acceleration: float = 800.0
@export var air_friction: float = 200.0

# --- 점프/중력 ---
@export var jump_velocity: float = -350.0
@export var fall_gravity_multiplier: float = 1.5
@export var max_fall_speed: float = 500.0
@export var jump_cut_multiplier: float = 0.5

# --- Coyote Time & Buffer ---
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.1

var gravity: float = ProjectSettings.get_setting(
    "physics/2d/default_gravity"
)
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false

func _physics_process(delta: float) -> void:
    # === 중력 ===
    if not is_on_floor():
        var gravity_mult := 1.0
        if velocity.y > 0:
            gravity_mult = fall_gravity_multiplier
        velocity.y += gravity * gravity_mult * delta
        velocity.y = minf(velocity.y, max_fall_speed)

    # === Coyote Time ===
    if is_on_floor():
        coyote_timer = coyote_time
    elif was_on_floor:
        # 방금 바닥을 떠남 (점프가 아닌 낙하)
        pass
    coyote_timer -= delta
    was_on_floor = is_on_floor()

    # === Jump Buffer ===
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time
    jump_buffer_timer -= delta

    # === 점프 실행 ===
    if jump_buffer_timer > 0 and coyote_timer > 0:
        velocity.y = jump_velocity
        jump_buffer_timer = 0.0
        coyote_timer = 0.0

    # === Variable Jump Height ===
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= jump_cut_multiplier

    # === 좌우 이동 ===
    var direction := Input.get_axis("move_left", "move_right")
    var accel := acceleration if is_on_floor() else air_acceleration
    var fric := friction if is_on_floor() else air_friction

    if direction != 0:
        velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, fric * delta)

    move_and_slide()""")

	# ============================================
	# 8. 카메라 추적
	# ============================================
	print("\n--- 카메라 추적 ---\n")

	print("Camera2D를 CharacterBody2D의 자식으로 추가합니다:\n")
	print("""# Player 씬 구조:
# CharacterBody2D (Player)
#   ├── Sprite2D
#   ├── CollisionShape2D
#   └── Camera2D
#         position_smoothing_enabled = true
#         position_smoothing_speed = 5.0
#         drag_horizontal_enabled = true
#         drag_vertical_enabled = true""")

	print("\nCamera2D 주요 속성:")
	print("  zoom: 확대/축소 (Vector2(2,2) = 2배 확대)")
	print("  offset: 카메라 오프셋 (살짝 앞을 보이게)")
	print("  limit_*: 카메라 이동 범위 제한")
	print("  position_smoothing: 부드러운 카메라 추적")
	print("  drag_*: 데드존 (캐릭터가 조금 움직여도 안 따라감)")

	print("\n고급 카메라 (코드로 제어):\n")
	print("""# advanced_camera.gd
extends Camera2D

@export var look_ahead_factor: float = 50.0

func _process(delta):
    # 플레이어가 향하는 방향으로 카메라를 앞으로
    var player = get_parent()
    if player.velocity.x > 0:
        offset.x = lerp(offset.x, look_ahead_factor, 2.0 * delta)
    elif player.velocity.x < 0:
        offset.x = lerp(offset.x, -look_ahead_factor, 2.0 * delta)""")

	# ============================================
	# 9. 애니메이션 연동
	# ============================================
	print("\n--- 애니메이션 연동 ---\n")

	print("""# 스프라이트 방향 전환 + 애니메이션
func update_animation():
    var sprite = $AnimatedSprite2D

    # 방향 전환
    if velocity.x > 0:
        sprite.flip_h = false
    elif velocity.x < 0:
        sprite.flip_h = true

    # 상태별 애니메이션
    if not is_on_floor():
        if velocity.y < 0:
            sprite.play("jump")
        else:
            sprite.play("fall")
    elif abs(velocity.x) > 10:
        sprite.play("run")
    else:
        sprite.play("idle")""")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("플랫포머 필수 요소:")
	print("  1. 중력: velocity.y += gravity * delta")
	print("  2. 점프: velocity.y = jump_velocity (is_on_floor 시)")
	print("  3. Coyote Time: 절벽 후 점프 유예 (%.0fms)" % (COYOTE_TIME * 1000))
	print("  4. Jump Buffer: 착지 전 입력 저장 (%.0fms)" % (JUMP_BUFFER_TIME * 1000))
	print("  5. Variable Jump: 버튼 떼면 점프 높이 감소")
	print("  6. 가변 중력: 하강 시 더 빠르게 (x%.1f)" % FALL_GRAVITY_MULTIPLIER)
	print("  7. Max Fall Speed: 낙하 속도 제한 (%.0f)" % MAX_FALL_SPEED)
	print("  8. Camera2D: 부드러운 추적, 데드존, look-ahead")
