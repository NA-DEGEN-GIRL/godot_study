# Chapter 15 - 3D Character Controller
# 04-advanced-movement.gd - 고급 이동 메커니즘
#
# 이 파일에서 배울 내용:
# - 웅크리기 (Crouch) 시스템
# - 계단 오르기 (Stair Stepping)
# - 벽 슬라이딩과 벽 점프
# - 슬라이딩과 대시

extends CharacterBody3D

# ============================================
# 기본 이동 설정
# ============================================

@export_group("Movement")
@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var crouch_speed := 2.5
@export var acceleration := 10.0
@export var deceleration := 12.0

@export_group("Jump")
@export var jump_velocity := 5.5
@export var wall_jump_velocity := Vector3(5, 5, 0)  # 벽 점프

@export_group("Crouch")
@export var stand_height := 1.8     # 서있을 때 높이
@export var crouch_height := 1.0    # 웅크릴 때 높이
@export var crouch_transition := 8.0  # 전환 속도

@export_group("Stair")
@export var max_stair_height := 0.5  # 올라갈 수 있는 최대 계단 높이

@export_group("Wall")
@export var wall_slide_speed := 2.0   # 벽 슬라이딩 속도
@export var wall_slide_gravity := 3.0 # 벽 슬라이딩 중력

@export_group("Slide")
@export var slide_speed := 10.0       # 슬라이딩 속도
@export var slide_duration := 0.8     # 슬라이딩 지속 시간
@export var slide_friction := 8.0     # 슬라이딩 마찰

@export_group("Dash")
@export var dash_speed := 15.0        # 대시 속도
@export var dash_duration := 0.2      # 대시 지속 시간
@export var dash_cooldown := 1.0      # 대시 쿨다운

# ============================================
# 내부 변수
# ============================================

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# 상태
var is_crouching := false
var is_wall_sliding := false
var is_sliding := false
var is_dashing := false
var can_dash := true

# 타이머
var slide_timer := 0.0
var dash_timer := 0.0
var dash_cooldown_timer := 0.0

# 벽 슬라이딩
var wall_normal := Vector3.ZERO

# 계단
var snap_vector := Vector3.DOWN * 0.5

# 노드 참조
var camera_pivot: Node3D
var camera: Camera3D
var standing_collision: CollisionShape3D
var crouching_collision: CollisionShape3D
var stair_raycast_low: RayCast3D
var stair_raycast_high: RayCast3D
var wall_raycast: RayCast3D
var ceiling_check: RayCast3D

func _ready():
	print("=== 고급 이동 메커니즘 ===\n")

	_create_scene()
	_setup_input_actions()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# ============================================
	# 1. 웅크리기 (Crouch) 시스템
	# ============================================
	print("--- 1. 웅크리기 (Crouch) ---\n")

	print("웅크리기 구현 요소:")
	print("  1. 충돌 형태 변경 (높이 축소)")
	print("  2. 카메라 높이 변경")
	print("  3. 이동 속도 감소")
	print("  4. 일어설 때 천장 체크!")
	print("")

	print("방법 1: 두 개의 CollisionShape3D 토글:")
	print("""  # 서있는 콜리전과 웅크린 콜리전을 미리 준비
  @onready var stand_col = $StandCollision    # height=1.8
  @onready var crouch_col = $CrouchCollision  # height=1.0

  func set_crouch(crouch: bool):
      if crouch and not is_crouching:
          stand_col.disabled = true
          crouch_col.disabled = false
          is_crouching = true
      elif not crouch and is_crouching:
          # 천장 체크! 일어설 수 있는지 확인
          if not ceiling_check.is_colliding():
              stand_col.disabled = false
              crouch_col.disabled = true
              is_crouching = false""")
	print("")

	print("방법 2: CapsuleShape3D 높이 직접 변경:")
	print("""  func set_crouch(crouch: bool):
      var target_height = crouch_height if crouch else stand_height
      var capsule = collision_shape.shape as CapsuleShape3D
      capsule.height = lerp(capsule.height, target_height, crouch_transition * delta)

      # 콜리전 위치도 조정 (중심이 위에 있도록)
      collision_shape.position.y = target_height / 2.0""")
	print("")

	print("천장 체크 (RayCast3D):")
	print("  천장 아래에서 웅크리기 -> 일어서면 끼임!")
	print("  RayCast3D로 위쪽을 체크하여 공간 확인")
	print("""  var ceiling_ray = RayCast3D.new()
  ceiling_ray.target_position = Vector3(0, stand_height, 0)

  func can_stand_up() -> bool:
      return not ceiling_ray.is_colliding()""")

	# ============================================
	# 2. 웅크리기 + 슬라이딩
	# ============================================
	print("\n--- 2. 슬라이딩 (Slide) ---\n")

	print("달리기 중 웅크리기 = 슬라이딩!")
	print("  스프린트 중 Ctrl -> 슬라이딩 시작")
	print("  높은 초기 속도로 미끄러지면서 감속")
	print("")

	print("슬라이딩 코드:")
	print("""  func start_slide():
      if not is_on_floor() or is_sliding:
          return
      if velocity.length() < walk_speed:
          return  # 충분한 속도가 아니면 그냥 웅크림

      is_sliding = true
      slide_timer = slide_duration
      set_crouch(true)

      # 현재 이동 방향으로 슬라이딩
      var slide_dir = Vector3(velocity.x, 0, velocity.z).normalized()
      velocity.x = slide_dir.x * slide_speed
      velocity.z = slide_dir.z * slide_speed

  func update_slide(delta):
      if not is_sliding:
          return

      slide_timer -= delta

      # 마찰으로 감속
      velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
      velocity.z = move_toward(velocity.z, 0, slide_friction * delta)

      # 타이머 끝 또는 속도가 너무 느리면 슬라이딩 종료
      if slide_timer <= 0 or Vector2(velocity.x, velocity.z).length() < crouch_speed:
          end_slide()

  func end_slide():
      is_sliding = false
      if not Input.is_action_pressed("crouch"):
          set_crouch(false)""")

	# ============================================
	# 3. 계단 오르기 (Stair Stepping)
	# ============================================
	print("\n--- 3. 계단 오르기 ---\n")

	print("계단 문제:")
	print("  CharacterBody3D는 경사면은 올라가지만")
	print("  직각 계단(세로 면)에는 막힘!")
	print("  -> 계단 감지 + 위치 보정 필요")
	print("")

	print("방법 1: 레이캐스트 기반 계단 감지:")
	print("""  # 두 개의 레이캐스트 사용
  # low_ray: 앞쪽 아래 (계단 앞면 감지)
  # high_ray: 앞쪽 위 (계단 위 공간 확인)

  func stair_step(delta):
      if not is_on_floor():
          return

      var motion = Vector3(velocity.x, 0, velocity.z).normalized()
      if motion.length() < 0.1:
          return

      # 1. 앞쪽 아래에 벽이 있는지 (계단 앞면)
      var low_ray_pos = global_position + Vector3(0, 0.1, 0)
      var low_result = _cast_ray(low_ray_pos, motion * 0.5)

      if not low_result:
          return  # 앞에 아무것도 없음

      # 2. 계단 위에서 앞쪽이 비어있는지
      var high_ray_pos = global_position + Vector3(0, max_stair_height + 0.1, 0)
      var high_result = _cast_ray(high_ray_pos, motion * 0.5)

      if high_result:
          return  # 위도 막혀 있음 (벽이지 계단이 아님)

      # 3. 계단 높이에서 아래로 레이 (계단 윗면 찾기)
      var step_pos = high_ray_pos + motion * 0.5
      var down_result = _cast_ray(step_pos, Vector3.DOWN * max_stair_height)

      if down_result:
          # 계단 높이로 순간이동!
          global_position.y = down_result.position.y""")
	print("")

	print("방법 2: 간단한 snap 방식:")
	print("""  # move_and_slide 전에 위로 올리고, 후에 아래로 snap
  func stair_step_simple(delta):
      var was_on_floor = is_on_floor()

      # 위로 올림
      position.y += max_stair_height
      move_and_slide()

      # 아래로 snap
      if was_on_floor and not is_on_floor():
          position.y -= max_stair_height  # 원래로

      # floor_snap으로 바닥에 붙기
      apply_floor_snap()""")

	# ============================================
	# 4. 벽 슬라이딩
	# ============================================
	print("\n--- 4. 벽 슬라이딩 ---\n")

	print("벽 슬라이딩 조건:")
	print("  1. 공중에 있음 (is_on_floor() == false)")
	print("  2. 벽에 닿아 있음 (is_on_wall() == true)")
	print("  3. 이동 입력이 벽 방향 (벽에 달라붙으려는 의도)")
	print("  4. 아래로 떨어지고 있음 (velocity.y < 0)")
	print("")

	print("벽 슬라이딩 코드:")
	print("""  func update_wall_slide(delta):
      is_wall_sliding = false

      if is_on_floor() or is_dashing:
          return

      if not is_on_wall_only():
          return

      # 벽 법선 가져오기
      wall_normal = get_wall_normal()

      # 벽 방향으로 입력하고 있는지 확인
      var input_dir = Input.get_vector("move_left", "move_right",
                                        "move_forward", "move_backward")
      var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
      var wall_dot = move_dir.dot(-wall_normal)

      if wall_dot > 0.5 and velocity.y < 0:
          is_wall_sliding = true
          # 느린 하강
          velocity.y = max(velocity.y, -wall_slide_speed)""")
	print("")

	print("벽 점프:")
	print("""  func wall_jump():
      if not is_wall_sliding:
          return

      # 벽 반대 방향 + 위로 점프
      velocity = wall_normal * wall_jump_velocity.x + Vector3.UP * wall_jump_velocity.y
      is_wall_sliding = false

      # 잠시 벽에서 떨어지도록 (바로 다시 붙는 거 방지)
      # 입력 무시 시간 추가
      wall_jump_disable_timer = 0.2""")

	# ============================================
	# 5. 대시 (Dash)
	# ============================================
	print("\n--- 5. 대시 (Dash) ---\n")

	print("대시 시스템:")
	print("""  func start_dash():
      if not can_dash or is_dashing:
          return

      is_dashing = true
      can_dash = false
      dash_timer = dash_duration
      dash_cooldown_timer = dash_cooldown

      # 대시 방향 결정
      var input_dir = Input.get_vector("move_left", "move_right",
                                        "move_forward", "move_backward")
      var dash_dir: Vector3
      if input_dir.length() > 0.1:
          # 입력 방향으로 대시
          dash_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
      else:
          # 앞 방향으로 대시
          dash_dir = -transform.basis.z

      velocity = dash_dir * dash_speed
      velocity.y = 0  # 수평 대시

  func update_dash(delta):
      if is_dashing:
          dash_timer -= delta
          if dash_timer <= 0:
              is_dashing = false

      # 쿨다운
      if not can_dash:
          dash_cooldown_timer -= delta
          if dash_cooldown_timer <= 0:
              can_dash = true

  func _physics_process(delta):
      if is_dashing:
          # 대시 중에는 중력 무시
          move_and_slide()
          update_dash(delta)
          return
      # ... 일반 이동 ...""")
	print("")

	print("대시 연출:")
	print("  - 카메라 FOV 순간 확대")
	print("  - 모션 블러 효과")
	print("  - 고스트(잔상) 이펙트")
	print("  - 무적 프레임 (i-frames)")

	# ============================================
	# 6. 상태 머신 통합
	# ============================================
	print("\n--- 6. 상태 머신 통합 ---\n")

	print("이동 상태 (State Machine):")
	print("""  enum MoveState {
      IDLE,
      WALKING,
      RUNNING,
      JUMPING,
      FALLING,
      CROUCHING,
      SLIDING,
      WALL_SLIDING,
      DASHING,
  }

  var current_state: MoveState = MoveState.IDLE

  func update_state():
      match current_state:
          MoveState.IDLE:
              if not is_on_floor():
                  current_state = MoveState.FALLING
              elif input_dir.length() > 0:
                  if is_running:
                      current_state = MoveState.RUNNING
                  else:
                      current_state = MoveState.WALKING

          MoveState.WALKING, MoveState.RUNNING:
              if not is_on_floor():
                  current_state = MoveState.FALLING
              elif Input.is_action_just_pressed("crouch"):
                  if is_running:
                      current_state = MoveState.SLIDING
                  else:
                      current_state = MoveState.CROUCHING
              elif input_dir.length() < 0.1:
                  current_state = MoveState.IDLE

          MoveState.FALLING:
              if is_on_floor():
                  current_state = MoveState.IDLE
              elif is_on_wall_only():
                  current_state = MoveState.WALL_SLIDING
          # ... 나머지 상태 ...""")
	print("")

	print("상태별 애니메이션:")
	print("  IDLE:         'idle' 애니메이션")
	print("  WALKING:      'walk' 애니메이션")
	print("  RUNNING:      'run' 애니메이션")
	print("  JUMPING:      'jump' 애니메이션")
	print("  FALLING:      'fall' 애니메이션")
	print("  CROUCHING:    'crouch_idle' / 'crouch_walk'")
	print("  SLIDING:      'slide' 애니메이션")
	print("  WALL_SLIDING: 'wall_slide' 애니메이션")
	print("  DASHING:      'dash' 애니메이션")

	# ============================================
	# 7. 성능 팁
	# ============================================
	print("\n--- 7. 성능 팁 ---\n")

	print("충돌 형태 변경 시 주의:")
	print("  1. set_deferred('disabled', true)로 안전하게")
	print("  2. 물리 프레임 중 직접 변경하면 오류 가능")
	print("")

	print("레이캐스트 최적화:")
	print("  - 계단/벽 레이캐스트: 이동 중에만 활성화")
	print("  - 천장 체크: 웅크리기 중에만 활성화")
	print("  - collision_mask로 필요한 레이어만 검사")
	print("")

	print("상태 전환 디버깅:")
	print("  print('[State] %s -> %s' % [old_state, new_state])")
	print("  -> 의도치 않은 상태 전환을 잡을 수 있음!")

	# ============================================
	# 8. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. 웅크리기: CollisionShape 전환 + 천장 체크 필수")
	print("2. 슬라이딩: 스프린트 중 웅크림 -> 높은 속도 감속")
	print("3. 계단: 낮은 레이(벽) + 높은 레이(빈 공간) 2단 체크")
	print("4. 벽 슬라이딩: is_on_wall() + 입력 방향 + 느린 하강")
	print("5. 벽 점프: wall_normal 방향 + 위쪽 임펄스")
	print("6. 대시: 일정 시간 고속 이동, 중력 무시, 쿨다운")
	print("7. 상태 머신: 모든 이동을 enum으로 관리")
	print("8. set_deferred: 물리 중 콜리전 변경 시 필수")

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# ============================================
# 마우스 룩
# ============================================

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.002)
			camera_pivot.rotate_x(-event.relative.y * 0.002)
			camera_pivot.rotation.x = clamp(
				camera_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))


# ============================================
# 물리 처리
# ============================================

func _physics_process(delta: float):
	# 대시 중
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()
		return

	# 대시 쿨다운
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true

	# 중력
	if not is_on_floor():
		if is_wall_sliding:
			velocity.y = max(velocity.y - wall_slide_gravity * delta, -wall_slide_speed)
		else:
			velocity.y -= gravity * delta

	# 점프
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif is_wall_sliding:
			# 벽 점프
			velocity = wall_normal * wall_jump_velocity.x + Vector3.UP * wall_jump_velocity.y
			is_wall_sliding = false

	# 대시
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash()

	# 웅크리기
	if Input.is_action_just_pressed("crouch"):
		if not is_crouching:
			_set_crouch(true)
		else:
			_try_stand_up()
	elif Input.is_action_just_released("crouch"):
		_try_stand_up()

	# 이동
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var target_speed := walk_speed
	if is_crouching:
		target_speed = crouch_speed
	elif Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	if not is_sliding:
		var accel := acceleration if direction.length() > 0 else deceleration
		velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)
	else:
		# 슬라이딩 감속
		velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
		velocity.z = move_toward(velocity.z, 0, slide_friction * delta)
		slide_timer -= delta
		if slide_timer <= 0 or Vector2(velocity.x, velocity.z).length() < crouch_speed:
			is_sliding = false

	# 벽 슬라이딩 감지
	_update_wall_slide()

	move_and_slide()


# ============================================
# 헬퍼 함수
# ============================================

func _set_crouch(crouch: bool):
	is_crouching = crouch
	if standing_collision and crouching_collision:
		standing_collision.disabled = crouch
		crouching_collision.disabled = not crouch

	# 카메라 높이 조정
	if camera_pivot:
		var target_y := 0.8 if crouch else 1.6
		var tween := create_tween()
		tween.tween_property(camera_pivot, "position:y", target_y, 0.15)


func _try_stand_up():
	if not is_crouching:
		return
	# 천장 체크
	if ceiling_check and ceiling_check.is_colliding():
		return  # 일어설 수 없음!
	_set_crouch(false)
	is_sliding = false


func _start_dash():
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	var dash_dir: Vector3
	if input_dir.length() > 0.1:
		dash_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		dash_dir = -transform.basis.z
	velocity = dash_dir * dash_speed
	velocity.y = 0


func _update_wall_slide():
	is_wall_sliding = false
	if is_on_floor() or is_dashing:
		return
	if not is_on_wall_only():
		return
	if velocity.y >= 0:
		return

	wall_normal = get_wall_normal()
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if move_dir.dot(-wall_normal) > 0.3:
		is_wall_sliding = true


# ============================================
# 씬 구성
# ============================================

func _create_scene():
	# 서있는 충돌체
	standing_collision = CollisionShape3D.new()
	standing_collision.name = "StandCollision"
	var stand_shape := CapsuleShape3D.new()
	stand_shape.radius = 0.4
	stand_shape.height = stand_height
	standing_collision.shape = stand_shape
	standing_collision.position = Vector3(0, stand_height / 2.0, 0)
	add_child(standing_collision)

	# 웅크린 충돌체
	crouching_collision = CollisionShape3D.new()
	crouching_collision.name = "CrouchCollision"
	var crouch_shape := CapsuleShape3D.new()
	crouch_shape.radius = 0.4
	crouch_shape.height = crouch_height
	crouching_collision.shape = crouch_shape
	crouching_collision.position = Vector3(0, crouch_height / 2.0, 0)
	crouching_collision.disabled = true
	add_child(crouching_collision)

	# 천장 체크 레이
	ceiling_check = RayCast3D.new()
	ceiling_check.name = "CeilingCheck"
	ceiling_check.position = Vector3(0, crouch_height, 0)
	ceiling_check.target_position = Vector3(0, stand_height - crouch_height + 0.1, 0)
	add_child(ceiling_check)

	# 카메라
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 1.6, 0)
	add_child(camera_pivot)

	camera = Camera3D.new()
	camera.fov = 75.0
	camera_pivot.add_child(camera)
	camera.make_current()

	# 바닥
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(30, 0.1, 30)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var fmesh := BoxMesh.new()
	fmesh.size = Vector3(30, 0.1, 30)
	floor_mi.mesh = fmesh
	floor_body.add_child(floor_mi)
	get_parent().call_deferred("add_child", floor_body)

	# 벽 (벽 슬라이딩 테스트용)
	var wall := StaticBody3D.new()
	var wall_col := CollisionShape3D.new()
	var wall_shape := BoxShape3D.new()
	wall_shape.size = Vector3(0.5, 8, 10)
	wall_col.shape = wall_shape
	wall.add_child(wall_col)
	var wall_mi := MeshInstance3D.new()
	var wmesh := BoxMesh.new()
	wmesh.size = Vector3(0.5, 8, 10)
	wall_mi.mesh = wmesh
	var wmat := StandardMaterial3D.new()
	wmat.albedo_color = Color(0.5, 0.4, 0.35)
	wall_mi.material_override = wmat
	wall.add_child(wall_mi)
	wall.position = Vector3(8, 4, 0)
	get_parent().call_deferred("add_child", wall)

	# 계단 (계단 오르기 테스트용)
	for i in range(6):
		var step := StaticBody3D.new()
		var step_col := CollisionShape3D.new()
		var step_shape := BoxShape3D.new()
		step_shape.size = Vector3(3, 0.3, 1)
		step_col.shape = step_shape
		step.add_child(step_col)
		var step_mi := MeshInstance3D.new()
		var smesh := BoxMesh.new()
		smesh.size = Vector3(3, 0.3, 1)
		step_mi.mesh = smesh
		var smat := StandardMaterial3D.new()
		smat.albedo_color = Color(0.6, 0.55, 0.5)
		step_mi.material_override = smat
		step.add_child(step_mi)
		step.position = Vector3(-5, 0.15 + i * 0.3, -2 - i)
		get_parent().call_deferred("add_child", step)

	# 낮은 천장 (웅크리기 테스트용)
	var low_ceil := StaticBody3D.new()
	var lc_col := CollisionShape3D.new()
	var lc_shape := BoxShape3D.new()
	lc_shape.size = Vector3(4, 0.2, 4)
	lc_col.shape = lc_shape
	low_ceil.add_child(lc_col)
	var lc_mi := MeshInstance3D.new()
	var lcmesh := BoxMesh.new()
	lcmesh.size = Vector3(4, 0.2, 4)
	lc_mi.mesh = lcmesh
	var lcmat := StandardMaterial3D.new()
	lcmat.albedo_color = Color(0.5, 0.3, 0.3)
	lc_mi.material_override = lcmat
	low_ceil.add_child(lc_mi)
	low_ceil.position = Vector3(4, 1.2, -5)
	get_parent().call_deferred("add_child", low_ceil)

	# 조명
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.shadow_enabled = true
	get_parent().call_deferred("add_child", light)

	position = Vector3(0, 1, 5)


func _setup_input_actions():
	var actions := {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"sprint": KEY_SHIFT,
		"crouch": KEY_CTRL,
		"dash": KEY_E,
	}

	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event := InputEventKey.new()
			event.keycode = actions[action_name]
			InputMap.action_add_event(action_name, event)
