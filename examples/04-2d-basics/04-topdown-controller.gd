# Chapter 04 - 2D Basics
# 04-topdown-controller.gd - Top-Down 8-Direction Controller with Sprint
#
# 이 파일에서 배울 내용:
# - 탑다운 8방향 이동 컨트롤러 구현
# - 달리기(Sprint) 기능 추가
# - 마우스를 향한 회전 처리
# - 대시(Dash) 기능 구현
#
# 사용법: CharacterBody2D 노드에 붙여서 사용합니다.
# 단독 실행 시에는 시뮬레이션과 코드 설명을 출력합니다.

extends Node

# ============================================
# 1. 이동 파라미터
# ============================================

# --- 기본 이동 ---
const WALK_SPEED: float = 150.0
const RUN_SPEED: float = 280.0
const ACCELERATION: float = 1500.0
const FRICTION: float = 1200.0

# --- 대시 ---
const DASH_SPEED: float = 500.0
const DASH_DURATION: float = 0.15    # 대시 지속 시간
const DASH_COOLDOWN: float = 0.8     # 대시 쿨타임

# --- 시뮬레이션 변수 ---
var sim_position := Vector2(400, 300)
var sim_velocity := Vector2.ZERO
var is_sprinting := false
var is_dashing := false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction := Vector2.ZERO
var facing_angle: float = 0.0

func _ready():
	print("=== 탑다운 8방향 컨트롤러 ===\n")

	# ============================================
	# 2. 기본 탑다운 이동
	# ============================================
	print("--- 기본 탑다운 이동 ---\n")

	print("탑다운(Top-Down) 뷰:")
	print("  - 위에서 내려다보는 시점 (젤다, 뱀서라이크 등)")
	print("  - 중력이 없음 (좌우상하 자유 이동)")
	print("  - 플랫포머와 달리 Y축 이동도 직접 조작")

	print("\n기본 코드:\n")
	print("""extends CharacterBody2D

@export var walk_speed: float = 150.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )

    if direction != Vector2.ZERO:
        velocity = velocity.move_toward(
            direction * walk_speed,
            acceleration * delta
        )
    else:
        velocity = velocity.move_toward(
            Vector2.ZERO,
            friction * delta
        )

    move_and_slide()""")

	# 이동 시뮬레이션
	print("\n이동 시뮬레이션 (오른쪽 위 대각선):")
	var direction := Vector2(1, -1).normalized()
	sim_velocity = Vector2.ZERO
	var dt := 1.0 / 60.0

	for frame in range(30):
		sim_velocity = sim_velocity.move_toward(
			direction * WALK_SPEED,
			ACCELERATION * dt
		)
		sim_position += sim_velocity * dt

		if (frame + 1) % 5 == 0:
			print("  프레임 %2d: vel=%s 속력=%.1f pos=%s" % [
				frame + 1,
				str(sim_velocity.snapped(Vector2(0.1, 0.1))),
				sim_velocity.length(),
				str(sim_position.snapped(Vector2(0.1, 0.1)))
			])

	# ============================================
	# 3. 달리기 (Sprint) 기능
	# ============================================
	print("\n--- 달리기 (Sprint) ---\n")

	print("Shift 키를 누르면 달리기 속도로 전환:\n")
	print("""extends CharacterBody2D

@export var walk_speed: float = 150.0
@export var run_speed: float = 280.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )

    # 현재 최대 속도 결정
    var current_speed := run_speed if Input.is_action_pressed("sprint") else walk_speed

    if direction != Vector2.ZERO:
        velocity = velocity.move_toward(
            direction * current_speed,
            acceleration * delta
        )
    else:
        velocity = velocity.move_toward(
            Vector2.ZERO,
            friction * delta
        )

    move_and_slide()""")

	# 스프린트 시뮬레이션 비교
	print("\n걷기 vs 달리기 속도 비교:")
	print("  걷기: %.0f px/s" % WALK_SPEED)
	print("  달리기: %.0f px/s (%.1f배)" % [RUN_SPEED, RUN_SPEED / WALK_SPEED])

	sim_velocity = Vector2.ZERO
	var walk_result := simulate_acceleration(WALK_SPEED, ACCELERATION, dt)
	sim_velocity = Vector2.ZERO
	var run_result := simulate_acceleration(RUN_SPEED, ACCELERATION, dt)

	print("  걷기 최대 속도 도달: 약 %d프레임 (%.2f초)" % [walk_result, walk_result * dt])
	print("  달리기 최대 속도 도달: 약 %d프레임 (%.2f초)" % [run_result, run_result * dt])

	# ============================================
	# 4. 스태미나 시스템 (선택사항)
	# ============================================
	print("\n--- 스태미나 시스템 ---\n")

	print("""# 스태미나가 있는 달리기
@export var max_stamina: float = 100.0
@export var stamina_drain: float = 30.0    # 초당 소비
@export var stamina_regen: float = 20.0    # 초당 회복
@export var stamina_regen_delay: float = 1.0  # 회복 시작 대기

var stamina: float = 100.0
var stamina_regen_timer: float = 0.0
var can_sprint: bool = true

func update_stamina(delta: float, is_sprinting: bool) -> void:
    if is_sprinting and can_sprint:
        stamina -= stamina_drain * delta
        stamina_regen_timer = stamina_regen_delay

        if stamina <= 0:
            stamina = 0
            can_sprint = false  # 완전 소진 시 일시적으로 달리기 불가
    else:
        stamina_regen_timer -= delta
        if stamina_regen_timer <= 0:
            stamina += stamina_regen * delta
            stamina = minf(stamina, max_stamina)

            if stamina > max_stamina * 0.3:  # 30% 이상 회복되면
                can_sprint = true""")

	# 스태미나 시뮬레이션
	print("\n스태미나 시뮬레이션 (3초 달리기 -> 회복):")
	var stamina := 100.0
	var max_stamina := 100.0
	var drain := 30.0
	var regen := 20.0

	for sec in range(8):
		if sec < 3:
			# 달리기 중
			stamina -= drain
			stamina = maxf(stamina, 0)
			print("  %d초: 달리기 중 | 스태미나: %.0f/%.0f" % [sec + 1, stamina, max_stamina])
		else:
			# 회복 중
			if sec >= 4:  # 1초 딜레이 후 회복
				stamina += regen
				stamina = minf(stamina, max_stamina)
			print("  %d초: 회복 중   | 스태미나: %.0f/%.0f" % [sec + 1, stamina, max_stamina])

	# ============================================
	# 5. 마우스를 향한 회전
	# ============================================
	print("\n--- 마우스를 향한 회전 ---\n")

	print("캐릭터가 마우스 방향을 바라보게 하기:\n")
	print("""# 방법 1: 즉시 회전
func _process(delta):
    var mouse_pos = get_global_mouse_position()
    look_at(mouse_pos)

# 방법 2: 부드러운 회전
func _process(delta):
    var mouse_pos = get_global_mouse_position()
    var target_angle = global_position.angle_to_point(mouse_pos)

    # 부드러운 회전 (lerp_angle)
    rotation = lerp_angle(rotation, target_angle, 10.0 * delta)

# 방법 3: 이동 방향을 바라보기
func _physics_process(delta):
    var direction = Input.get_vector(...)
    if direction != Vector2.ZERO:
        var target_angle = direction.angle()
        rotation = lerp_angle(rotation, target_angle, 10.0 * delta)""")

	# 각도 계산 예시
	print("\n각도 계산 예시:")
	var positions := [
		Vector2(100, 0),   # 오른쪽
		Vector2(0, -100),  # 위
		Vector2(-100, 0),  # 왼쪽
		Vector2(0, 100),   # 아래
		Vector2(100, -100), # 오른쪽 위
	]
	var origin := Vector2.ZERO

	for target_pos in positions:
		var angle := origin.angle_to_point(target_pos)
		print("  (0,0) -> %s: %.1f도 (%.2f rad)" % [
			str(target_pos), rad_to_deg(angle), angle
		])

	# ============================================
	# 6. 대시 (Dash) 기능
	# ============================================
	print("\n--- 대시 (Dash) ---\n")

	print("짧은 시간 동안 빠르게 이동하는 회피 기능:\n")
	print("""extends CharacterBody2D

@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.8

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    # 쿨타임 감소
    dash_cooldown_timer -= delta

    # 대시 입력 확인
    if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
        start_dash()

    if is_dashing:
        # 대시 중 이동
        dash_timer -= delta
        velocity = dash_direction * dash_speed

        if dash_timer <= 0:
            is_dashing = false
    else:
        # 일반 이동
        var direction = Input.get_vector(...)
        velocity = velocity.move_toward(direction * speed, acceleration * delta)

    move_and_slide()

func start_dash() -> void:
    var direction = Input.get_vector(
        "move_left", "move_right", "move_up", "move_down"
    )

    # 입력이 없으면 현재 바라보는 방향으로 대시
    if direction == Vector2.ZERO:
        direction = Vector2.RIGHT.rotated(rotation)

    dash_direction = direction.normalized()
    is_dashing = true
    dash_timer = dash_duration
    dash_cooldown_timer = dash_cooldown

    # 선택: 대시 중 무적
    # set_collision_layer_value(1, false)
    # await get_tree().create_timer(dash_duration).timeout
    # set_collision_layer_value(1, true)""")

	# 대시 시뮬레이션
	print("\n대시 시뮬레이션:")
	var dash_frames := int(DASH_DURATION / dt)
	var dash_distance := DASH_SPEED * DASH_DURATION
	print("  대시 속도: %.0f px/s" % DASH_SPEED)
	print("  대시 지속: %.0f ms (%d프레임)" % [DASH_DURATION * 1000, dash_frames])
	print("  대시 거리: %.1f px" % dash_distance)
	print("  대시 쿨타임: %.1f초" % DASH_COOLDOWN)
	print("  일반 걷기 대비: %.1f배 속도" % (DASH_SPEED / WALK_SPEED))

	# ============================================
	# 7. 전체 통합 코드
	# ============================================
	print("\n--- 전체 탑다운 컨트롤러 ---\n")

	print("""extends CharacterBody2D

# === 이동 ===
@export_group("Movement")
@export var walk_speed: float = 150.0
@export var run_speed: float = 280.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# === 대시 ===
@export_group("Dash")
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.8

# === 상태 변수 ===
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
    update_dash(delta)

    if not is_dashing:
        update_movement(delta)

    move_and_slide()
    update_animation()

func update_movement(delta: float) -> void:
    var direction := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )

    if direction != Vector2.ZERO:
        last_direction = direction
        var speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
        velocity = velocity.move_toward(
            direction * speed, acceleration * delta
        )
    else:
        velocity = velocity.move_toward(
            Vector2.ZERO, friction * delta
        )

func update_dash(delta: float) -> void:
    dash_cooldown_timer -= delta

    if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
        var dir = Input.get_vector(
            "move_left", "move_right",
            "move_up", "move_down"
        )
        if dir == Vector2.ZERO:
            dir = last_direction
        dash_direction = dir.normalized()
        is_dashing = true
        dash_timer = dash_duration
        dash_cooldown_timer = dash_cooldown

    if is_dashing:
        velocity = dash_direction * dash_speed
        dash_timer -= delta
        if dash_timer <= 0:
            is_dashing = false

func update_animation() -> void:
    var sprite = $AnimatedSprite2D

    # 대시 중
    if is_dashing:
        sprite.play("dash")
        return

    # 이동 중
    if velocity.length() > 10:
        if velocity.length() > walk_speed + 10:
            sprite.play("run")
        else:
            sprite.play("walk")

        # 4방향 또는 8방향 스프라이트 방향
        if abs(velocity.x) > abs(velocity.y):
            sprite.flip_h = velocity.x < 0
        # 상하 애니메이션이 있다면 추가 처리
    else:
        sprite.play("idle")""")

	# ============================================
	# 8. 부드러운 움직임 팁
	# ============================================
	print("\n--- 부드러운 움직임 팁 ---\n")

	print("1. move_toward vs lerp:")
	print("   move_toward: 일정 속도 전환 (선형, 예측 가능)")
	print("   lerp: 비율 전환 (처음 빠르고 점점 느려짐)")
	print("   권장: 이동에는 move_toward, 카메라에는 lerp")

	print("\n2. 프레임 독립적 lerp:")
	print("   잘못된 방법: velocity.lerp(target, 0.1)")
	print("   올바른 방법: velocity.lerp(target, 1.0 - exp(-speed * delta))")
	print("   -> FPS와 무관하게 동일한 결과")

	print("\n3. 반응성 좋은 파라미터 가이드:")
	print("   캐주얼/RPG: 낮은 속도(100-150), 낮은 가속(500-800)")
	print("   액션: 중간 속도(200-300), 높은 가속(1500-2000)")
	print("   트위치: 높은 속도(300+), 즉시 가속(9999)")

	# ============================================
	# 9. 씬 구조
	# ============================================
	print("\n--- 권장 씬 구조 ---\n")

	print("""CharacterBody2D (Player)
  ├── AnimatedSprite2D     # 캐릭터 스프라이트
  │   └── 애니메이션: idle, walk, run, dash
  ├── CollisionShape2D     # 충돌 영역
  │   └── CircleShape2D (반지름 8-12px)
  ├── Camera2D             # 카메라 추적
  │   ├── position_smoothing = true
  │   └── position_smoothing_speed = 5.0
  ├── HitboxArea (Area2D)  # 공격 범위
  │   └── CollisionShape2D
  └── HurtboxArea (Area2D) # 피격 범위
      └── CollisionShape2D""")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("탑다운 컨트롤러 핵심:")
	print("  1. get_vector(): 8방향 자동 정규화 입력")
	print("  2. move_toward(): 부드러운 가속/감속")
	print("  3. Sprint: Shift로 속도 전환 (%.0f -> %.0f)" % [WALK_SPEED, RUN_SPEED])
	print("  4. Dash: 짧은 순간 이동 (%.0f px/s, %.0fms)" % [DASH_SPEED, DASH_DURATION * 1000])
	print("  5. 스태미나: 달리기 자원 관리")
	print("  6. 회전: look_at() 또는 lerp_angle()")
	print("  7. 애니메이션: 상태에 따른 스프라이트 전환")
	print("  8. 씬 구조: Body + Sprite + Collision + Camera")


# ============================================
# Helper: 가속 시뮬레이션
# ============================================

func simulate_acceleration(target_speed: float, accel: float, dt: float) -> int:
	var vel := 0.0
	var frames := 0
	while vel < target_speed * 0.99:
		vel = move_toward(vel, target_speed, accel * dt)
		frames += 1
		if frames > 600:
			break
	return frames
