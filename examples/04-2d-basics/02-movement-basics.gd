# Chapter 04 - 2D Basics
# 02-movement-basics.gd - Basic 2D Movement
#
# 이 파일에서 배울 내용:
# - velocity(속도 벡터)를 이용한 이동
# - move_and_slide()의 동작 원리
# - delta를 이용한 프레임 독립적 이동
# - 8방향 이동과 정규화(normalized) 처리
#
# 사용법: 이 스크립트를 CharacterBody2D 노드에 붙여서 사용합니다.
# 단독 실행 시에는 개념 설명만 출력됩니다.

extends Node

# ============================================
# 1. 이동에 필요한 변수들
# ============================================

# 실제로는 CharacterBody2D에서 사용하지만,
# 개념 설명을 위해 Node에서 시뮬레이션합니다.

const SPEED: float = 200.0
const ACCELERATION: float = 800.0  # 가속도 (pixels/second^2)
const FRICTION: float = 600.0       # 마찰력 (감속)

var simulated_position := Vector2(400, 300)
var simulated_velocity := Vector2.ZERO

func _ready():
	print("=== 2D 이동 기초 ===\n")

	# ============================================
	# 2. 기본 이동 방식 비교
	# ============================================
	print("--- 이동 방식 비교 ---\n")

	# 방식 1: 직접 위치 변경 (비추천)
	print("방식 1 - 직접 위치 변경 (나쁜 예):")
	print("  func _process(delta):")
	print("    if Input.is_action_pressed('move_right'):")
	print("      position.x += 5  # 프레임 의존적! FPS에 따라 속도가 달라짐")
	print("  문제: 60FPS에서 300px/s, 30FPS에서 150px/s")

	# 방식 2: delta를 곱한 이동 (개선)
	print("\n방식 2 - delta 적용 (개선):")
	print("  func _process(delta):")
	print("    if Input.is_action_pressed('move_right'):")
	print("      position.x += 200 * delta  # 프레임 독립적!")
	print("  결과: FPS와 무관하게 항상 200px/s")

	# 방식 3: velocity + move_and_slide (권장)
	print("\n방식 3 - velocity + move_and_slide (권장):")
	print("  extends CharacterBody2D")
	print("  ")
	print("  var SPEED = 200.0")
	print("  ")
	print("  func _physics_process(delta):")
	print("    var direction = Input.get_vector(")
	print("      'move_left', 'move_right', 'move_up', 'move_down')")
	print("    velocity = direction * SPEED")
	print("    move_and_slide()")
	print("  장점: 충돌 처리 자동, 물리 엔진 통합")

	# ============================================
	# 3. velocity (속도 벡터) 이해
	# ============================================
	print("\n--- velocity 이해 ---\n")

	print("velocity는 방향 + 크기를 가진 2D 벡터입니다:")
	print("")

	# 방향별 velocity 예시
	var directions := {
		"오른쪽": Vector2(SPEED, 0),
		"왼쪽": Vector2(-SPEED, 0),
		"위": Vector2(0, -SPEED),        # Godot에서 Y축은 아래가 양수!
		"아래": Vector2(0, SPEED),
		"오른쪽 위 (대각)": Vector2(SPEED, -SPEED).normalized() * SPEED,
	}

	for dir_name in directions:
		var vel: Vector2 = directions[dir_name]
		print("  %s: velocity = %s (속력: %.1f)" % [dir_name, str(vel), vel.length()])

	# Y축 방향 주의사항
	print("\n주의: Godot의 좌표계")
	print("  - X: 오른쪽이 양수 (+)")
	print("  - Y: 아래쪽이 양수 (+)  <- 일반 수학과 반대!")
	print("  - 위로 이동 = velocity.y를 음수로")
	print("  - 아래로 이동 = velocity.y를 양수로")

	# ============================================
	# 4. move_and_slide() 설명
	# ============================================
	print("\n--- move_and_slide() ---\n")

	print("CharacterBody2D의 핵심 메서드입니다:")
	print("  - velocity 벡터를 기반으로 노드를 이동")
	print("  - 충돌 감지 및 슬라이딩 자동 처리")
	print("  - _physics_process()에서 호출해야 함")
	print("")
	print("동작 원리:")
	print("  1. velocity 방향으로 이동 시도")
	print("  2. 벽에 부딪히면 벽을 따라 미끄러짐 (slide)")
	print("  3. 남은 이동량을 벽 방향으로 분해")
	print("  4. delta는 내부적으로 자동 적용됨!")
	print("")
	print("주요 속성:")
	print("  floor_max_angle: 바닥으로 인식하는 최대 경사 (기본 45도)")
	print("  up_direction: 위 방향 벡터 (기본 Vector2.UP)")
	print("  slide_on_ceiling: 천장에서 미끄러질지 여부")
	print("  max_slides: 최대 슬라이드 횟수 (기본 6)")

	# ============================================
	# 5. 8방향 이동 구현
	# ============================================
	print("\n--- 8방향 이동 구현 ---\n")

	print("방법 1: 개별 키 체크 + 정규화\n")
	print("""extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
    var direction := Vector2.ZERO

    if Input.is_action_pressed("move_left"):
        direction.x -= 1.0
    if Input.is_action_pressed("move_right"):
        direction.x += 1.0
    if Input.is_action_pressed("move_up"):
        direction.y -= 1.0
    if Input.is_action_pressed("move_down"):
        direction.y += 1.0

    # 정규화: 대각선 이동 속도를 동일하게!
    direction = direction.normalized()

    velocity = direction * SPEED
    move_and_slide()""")

	print("\n방법 2: Input.get_vector() 사용 (권장)\n")
	print("""extends CharacterBody2D

const SPEED = 200.0

func _physics_process(delta):
    # get_vector()는 자동으로 정규화됨!
    var direction := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )

    velocity = direction * SPEED
    move_and_slide()""")

	# 정규화 시뮬레이션
	print("\n정규화 효과 시뮬레이션:")
	simulate_movement()

	# ============================================
	# 6. 가속/감속 (부드러운 이동)
	# ============================================
	print("\n--- 가속/감속 (부드러운 이동) ---\n")

	print("즉시 이동 (딱딱한 느낌):")
	print("  velocity = direction * SPEED")
	print("")
	print("가속/감속 (부드러운 느낌):\n")
	print("""extends CharacterBody2D

const SPEED = 200.0
const ACCELERATION = 800.0  # 가속도
const FRICTION = 600.0      # 마찰 (감속)

func _physics_process(delta):
    var direction := Input.get_vector(
        "move_left", "move_right",
        "move_up", "move_down"
    )

    if direction != Vector2.ZERO:
        # 입력이 있으면 가속
        velocity = velocity.move_toward(
            direction * SPEED,
            ACCELERATION * delta
        )
    else:
        # 입력이 없으면 감속 (마찰)
        velocity = velocity.move_toward(
            Vector2.ZERO,
            FRICTION * delta
        )

    move_and_slide()""")

	# move_toward 설명
	print("\nmove_toward() 설명:")
	var v := Vector2(0, 0)
	var target := Vector2(200, 0)
	var step := 50.0

	print("  시작: %s" % str(v))
	for i in range(5):
		v = v.move_toward(target, step)
		print("  step %d: %s (남은 거리: %.1f)" % [i + 1, str(v), v.distance_to(target)])

	# ============================================
	# 7. lerp를 이용한 부드러운 이동
	# ============================================
	print("\n--- lerp (보간) 이동 ---\n")

	print("lerp vs move_toward:")
	print("  move_toward: 일정한 속도로 이동 (선형)")
	print("  lerp: 남은 거리의 비율만큼 이동 (점점 느려짐)")
	print("")
	print("lerp 사용 예:\n")
	print("""func _physics_process(delta):
    var direction := Input.get_vector(...)
    var target_velocity := direction * SPEED

    # lerp로 부드러운 전환 (0.1 = 10%씩 목표에 접근)
    velocity = velocity.lerp(target_velocity, 0.1)

    # delta를 적용한 lerp (프레임 독립적)
    velocity = velocity.lerp(target_velocity, 1.0 - exp(-10.0 * delta))

    move_and_slide()""")

	# lerp 시뮬레이션
	print("lerp 시뮬레이션 (0 -> 100):")
	var lerp_val := 0.0
	for i in range(8):
		lerp_val = lerp(lerp_val, 100.0, 0.3)
		print("  step %d: %.2f" % [i + 1, lerp_val])

	# ============================================
	# 8. 충돌 후 정보 확인
	# ============================================
	print("\n--- 충돌 정보 ---\n")

	print("move_and_slide() 후 충돌 정보 확인:\n")
	print("""func _physics_process(delta):
    velocity = direction * SPEED
    move_and_slide()

    # 바닥에 있는지 확인
    if is_on_floor():
        print("바닥에 있음")

    # 벽에 닿았는지 확인
    if is_on_wall():
        print("벽에 닿음")

    # 천장에 닿았는지 확인
    if is_on_ceiling():
        print("천장에 닿음")

    # 충돌 정보 상세 확인
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        print("충돌 위치: ", collision.get_position())
        print("충돌 법선: ", collision.get_normal())
        print("충돌 객체: ", collision.get_collider().name)""")

	# ============================================
	# 9. 유용한 Vector2 메서드
	# ============================================
	print("\n--- 유용한 Vector2 메서드 ---\n")

	var vec_a := Vector2(3, 4)
	var vec_b := Vector2(10, 0)

	print("Vector2(3, 4) 메서드:")
	print("  length(): %.2f" % vec_a.length())
	print("  normalized(): %s" % str(vec_a.normalized()))
	print("  angle(): %.2f rad (%.1f도)" % [vec_a.angle(), rad_to_deg(vec_a.angle())])
	print("  rotated(PI/2): %s" % str(vec_a.rotated(PI / 2)))
	print("  distance_to((10,0)): %.2f" % vec_a.distance_to(vec_b))
	print("  direction_to((10,0)): %s" % str(vec_a.direction_to(vec_b)))
	print("  dot((10,0)): %.1f" % vec_a.dot(vec_b))
	print("  abs(): %s" % str(Vector2(-3, -4).abs()))
	print("  sign(): %s" % str(Vector2(-3, 4).sign()))
	print("  clamped(3): %s" % str(vec_a.limit_length(3)))
	print("  snapped((10,10)): %s" % str(Vector2(37, 52).snapped(Vector2(10, 10))))

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. velocity = 이동 방향과 속도를 담는 벡터")
	print("2. move_and_slide(): 충돌 처리 포함 이동 (CharacterBody2D)")
	print("3. delta: 프레임 독립적 이동에 필수 (move_and_slide는 자동 적용)")
	print("4. normalized(): 대각선 이동 속도를 동일하게")
	print("5. get_vector(): 4개 액션을 정규화된 방향 벡터로")
	print("6. move_toward(): 일정 속도 가속/감속")
	print("7. lerp(): 비율 기반 부드러운 전환")
	print("8. is_on_floor()/wall()/ceiling(): 충돌 상태 확인")


# ============================================
# Helper: 이동 시뮬레이션
# ============================================

func simulate_movement():
	var speed := 200.0

	# 오른쪽 이동
	var right := Vector2(1, 0) * speed
	print("  오른쪽 이동: velocity=%s, 속력=%.1f" % [str(right), right.length()])

	# 대각선 (정규화 안 함)
	var diag_raw := Vector2(1, -1) * speed
	print("  대각선 (안 정규화): velocity=%s, 속력=%.1f (빠름!)" % [str(diag_raw), diag_raw.length()])

	# 대각선 (정규화 함)
	var diag_norm := Vector2(1, -1).normalized() * speed
	print("  대각선 (정규화): velocity=%s, 속력=%.1f (동일!)" % [str(diag_norm), diag_norm.length()])
