# Chapter 15 - 3D Character Controller
# 02-fps-controller.gd - 완전한 FPS 컨트롤러
#
# 이 파일에서 배울 내용:
# - WASD 이동 + 마우스 룩 통합
# - 중력과 점프 구현
# - 스프린트 (달리기)
# - 부드러운 가감속 (관성)

extends CharacterBody3D

# ============================================
# 이동 설정
# ============================================

# 기본 이동
@export_group("Movement")
@export var walk_speed := 5.0       # 걷기 속도 (m/s)
@export var sprint_speed := 8.5     # 달리기 속도 (m/s)
@export var acceleration := 10.0    # 가속도 (부드러운 시작)
@export var deceleration := 12.0    # 감속도 (부드러운 정지)
@export var air_control := 0.3      # 공중 조작력 (0=없음, 1=지상과 동일)

# 점프
@export_group("Jump")
@export var jump_velocity := 5.0    # 점프 속도 (m/s)
@export var gravity_multiplier := 1.0  # 중력 배율
@export var coyote_time := 0.15     # 코요테 타임 (초)
@export var jump_buffer_time := 0.1 # 점프 버퍼 시간 (초)

# 마우스
@export_group("Mouse")
@export var mouse_sensitivity := 0.002
@export var invert_y := false

# ============================================
# 내부 변수
# ============================================

var current_speed := 0.0
var is_sprinting := false
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false

# 중력
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# 노드 참조 (코드로 생성하므로 변수에 저장)
var camera_pivot: Node3D
var camera: Camera3D

func _ready():
	print("=== FPS 컨트롤러 ===\n")

	# 씬 구성
	_create_scene()
	_setup_input_actions()

	# 마우스 캡처
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# ============================================
	# 1. FPS 컨트롤러 구조
	# ============================================
	print("--- 1. FPS 컨트롤러 구조 ---\n")

	print("노드 트리:")
	print("  CharacterBody3D (이 스크립트)")
	print("    +-- CollisionShape3D (CapsuleShape3D)")
	print("    +-- CameraPivot (Node3D)")
	print("         +-- Camera3D")
	print("")

	print("이동 설정:")
	print("  걷기 속도: %.1f m/s" % walk_speed)
	print("  달리기 속도: %.1f m/s" % sprint_speed)
	print("  가속도: %.1f" % acceleration)
	print("  감속도: %.1f" % deceleration)
	print("  공중 조작력: %.1f" % air_control)
	print("")

	print("점프 설정:")
	print("  점프 속도: %.1f m/s" % jump_velocity)
	print("  중력: %.1f m/s^2" % gravity)
	print("  코요테 타임: %.2f초" % coyote_time)
	print("  점프 버퍼: %.2f초" % jump_buffer_time)

	# ============================================
	# 2. 이동 메커니즘 설명
	# ============================================
	print("\n--- 2. 이동 메커니즘 ---\n")

	print("이동 방향 계산:")
	print("  1. Input.get_vector()로 2D 입력 방향 얻기")
	print("  2. 캐릭터의 회전(basis)을 기준으로 3D 방향 변환")
	print("  3. 방향 * 속도 = 목표 속도")
	print("  4. lerp로 현재 속도를 목표에 보간 (부드러운 가감속)")
	print("")

	print("핵심: 카메라가 보는 방향으로 이동!")
	print("  var forward = -transform.basis.z  # 앞 방향")
	print("  var right = transform.basis.x      # 오른쪽 방향")
	print("  var direction = forward * input.y + right * input.x")
	print("  -> W 누르면 카메라 앞으로, A 누르면 왼쪽으로")

	# ============================================
	# 3. 중력과 점프
	# ============================================
	print("\n--- 3. 중력과 점프 ---\n")

	print("중력 적용:")
	print("  velocity.y -= gravity * delta")
	print("  -> 매 물리 프레임마다 아래로 가속")
	print("")

	print("점프:")
	print("  if is_on_floor() and jump_pressed:")
	print("      velocity.y = jump_velocity")
	print("  -> 바닥에 있을 때만 점프 가능")
	print("")

	print("코요테 타임 (Coyote Time):")
	print("  바닥에서 떨어진 직후 짧은 시간 동안 점프 허용")
	print("  -> 절벽 끝에서 점프해도 성공 (관대한 조작감)")
	print("")

	print("점프 버퍼 (Jump Buffer):")
	print("  착지 직전에 점프를 눌러도 착지 시 점프")
	print("  -> 타이밍이 약간 빨라도 점프 성공")

	# ============================================
	# 4. 가감속 (부드러운 이동)
	# ============================================
	print("\n--- 4. 가감속 ---\n")

	print("왜 가감속이 필요한가?")
	print("  즉시 최대 속도 -> 로봇 같은 느낌")
	print("  점진적 가속 -> 자연스러운 관성")
	print("")

	print("구현 방법:")
	print("  # 이동 중: 가속")
	print("  velocity.x = move_toward(velocity.x, target.x, accel * delta)")
	print("  velocity.z = move_toward(velocity.z, target.z, accel * delta)")
	print("")
	print("  # 정지 시: 감속")
	print("  velocity.x = move_toward(velocity.x, 0, decel * delta)")
	print("  velocity.z = move_toward(velocity.z, 0, decel * delta)")
	print("")

	print("lerp vs move_toward:")
	print("  lerp: 비율 기반 (가까울수록 느려짐, 부드러움)")
	print("  move_toward: 일정 속도 감소 (예측 가능, 정확)")
	print("  -> FPS에서는 move_toward가 더 반응적!")

	# ============================================
	# 5. 스프린트 (달리기)
	# ============================================
	print("\n--- 5. 스프린트 ---\n")

	print("스프린트 구현:")
	print("  Shift 키를 누르면 속도 증가")
	print("  is_sprinting = Input.is_action_pressed('sprint')")
	print("  current_speed = sprint_speed if is_sprinting else walk_speed")
	print("")

	print("확장 가능한 스프린트:")
	print("""  # 스태미나 시스템
  var max_stamina: float = 100.0
  var stamina: float = 100.0
  var stamina_drain: float = 20.0  # 초당 소모
  var stamina_regen: float = 15.0  # 초당 회복
  var can_sprint: bool = true

  func update_stamina(delta):
      if is_sprinting and is_moving:
          stamina -= stamina_drain * delta
          if stamina <= 0:
              stamina = 0
              can_sprint = false
      else:
          stamina += stamina_regen * delta
          stamina = min(stamina, max_stamina)
          if stamina > 20.0:  # 20%% 이상 회복되면 다시 달리기 가능
              can_sprint = true""")

	# ============================================
	# 6. 전체 _physics_process 코드
	# ============================================
	print("\n--- 6. 전체 물리 처리 코드 ---\n")

	print("""  func _physics_process(delta):
      # 1. 중력
      if not is_on_floor():
          velocity.y -= gravity * gravity_multiplier * delta

      # 2. 코요테 타임 관리
      if is_on_floor():
          coyote_timer = coyote_time
      else:
          coyote_timer -= delta

      # 3. 점프 버퍼 관리
      if Input.is_action_just_pressed("jump"):
          jump_buffer_timer = jump_buffer_time
      else:
          jump_buffer_timer -= delta

      # 4. 점프 실행
      if jump_buffer_timer > 0 and coyote_timer > 0:
          velocity.y = jump_velocity
          coyote_timer = 0  # 이중 점프 방지
          jump_buffer_timer = 0

      # 5. 이동 방향 계산
      var input_dir = Input.get_vector("move_left", "move_right",
                                        "move_forward", "move_backward")
      var direction = (transform.basis * Vector3(input_dir.x, 0,
                                                  input_dir.y)).normalized()

      # 6. 스프린트
      is_sprinting = Input.is_action_pressed("sprint") and is_on_floor()
      var target_speed = sprint_speed if is_sprinting else walk_speed

      # 7. 가감속
      var accel = acceleration if direction else deceleration
      if not is_on_floor():
          accel *= air_control  # 공중에서 조작력 감소

      velocity.x = move_toward(velocity.x,
                                direction.x * target_speed, accel * delta)
      velocity.z = move_toward(velocity.z,
                                direction.z * target_speed, accel * delta)

      # 8. 이동 실행
      move_and_slide()""")

	# ============================================
	# 7. 추가 기능
	# ============================================
	print("\n--- 7. 추가 기능 ---\n")

	print("달리기 시 FOV 변화:")
	print("""  var default_fov: float = 75.0
  var sprint_fov: float = 85.0

  func _process(delta):
      var target_fov = sprint_fov if is_sprinting else default_fov
      camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)""")
	print("")

	print("착지 시 카메라 흔들림:")
	print("""  var fall_velocity: float = 0.0

  func _physics_process(delta):
      if not is_on_floor():
          fall_velocity = velocity.y

      if is_on_floor() and not was_on_floor:
          # 방금 착지함!
          var impact = abs(fall_velocity)
          if impact > 5.0:
              # 강한 착지: 카메라 살짝 아래로
              var tween = create_tween()
              var dip = clamp(impact * 0.01, 0.05, 0.3)
              tween.tween_property(camera, "position:y", -dip, 0.1)
              tween.tween_property(camera, "position:y", 0.0, 0.2)

      was_on_floor = is_on_floor()""")

	# ============================================
	# 8. 디버그 정보
	# ============================================
	print("\n--- 8. 디버그 정보 ---\n")

	print("디버그 UI 표시:")
	print("""  func _process(delta):
      if OS.is_debug_build():
          var debug_text = ""
          debug_text += "FPS: %d\\n" % Engine.get_frames_per_second()
          debug_text += "Speed: %.1f m/s\\n" % Vector2(velocity.x, velocity.z).length()
          debug_text += "Y Velocity: %.1f\\n" % velocity.y
          debug_text += "On Floor: %s\\n" % str(is_on_floor())
          debug_text += "Sprinting: %s\\n" % str(is_sprinting)
          debug_text += "Position: %s\\n" % str(global_position)
          $UI/DebugLabel.text = debug_text""")

	# ============================================
	# 9. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. transform.basis로 카메라 방향 기준 이동")
	print("2. move_toward(): 부드러운 가감속 (관성)")
	print("3. 코요테 타임: 바닥 이탈 직후 점프 허용")
	print("4. 점프 버퍼: 착지 전 점프 입력 저장")
	print("5. air_control: 공중 이동력 별도 설정")
	print("6. 스프린트: Shift + 스태미나 시스템")
	print("7. FOV 변화: 달리기 시 시야각 증가로 속도감")
	print("8. 착지 효과: fall_velocity로 충격 강도 계산")

	# 마우스 해제 (에디터 테스트용)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# ============================================
# 마우스 룩
# ============================================

func _unhandled_input(event: InputEvent):
	# ESC로 마우스 모드 토글
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# 마우스 캡처 상태에서만 마우스 룩
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var y_dir := -1.0 if invert_y else 1.0
			# 좌우 회전: 캐릭터 루트
			rotate_y(-event.relative.x * mouse_sensitivity)
			# 위아래 회전: 카메라 피봇
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity * y_dir)
			camera_pivot.rotation.x = clamp(
				camera_pivot.rotation.x,
				deg_to_rad(-89),
				deg_to_rad(89)
			)


# ============================================
# 물리 처리
# ============================================

func _physics_process(delta: float):
	# 중력 적용
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	# 코요테 타임
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	# 점프 버퍼
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# 점프 실행
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0

	# 이동 방향 계산 (카메라 기준)
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# 스프린트
	is_sprinting = Input.is_action_pressed("sprint") and is_on_floor() and direction.length() > 0
	var target_speed := sprint_speed if is_sprinting else walk_speed

	# 가감속 적용
	var accel := acceleration if direction.length() > 0 else deceleration
	if not is_on_floor():
		accel *= air_control

	# 수평 속도 적용
	velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)

	# 이동 실행
	was_on_floor = is_on_floor()
	move_and_slide()


# ============================================
# 씬 구성
# ============================================

func _create_scene():
	# 충돌체
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	add_child(col)

	# 카메라 피봇
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 1.6, 0)  # 눈 높이
	add_child(camera_pivot)

	# 카메라
	camera = Camera3D.new()
	camera.name = "Camera"
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
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.4, 0.45, 0.4)
	floor_mi.material_override = fmat
	floor_body.add_child(floor_mi)
	get_parent().call_deferred("add_child", floor_body)

	# 플랫폼과 벽
	var obstacles := [
		{"size": Vector3(3, 1, 3), "pos": Vector3(5, 0.5, -5)},
		{"size": Vector3(3, 2, 3), "pos": Vector3(-5, 1, -5)},
		{"size": Vector3(1, 3, 10), "pos": Vector3(10, 1.5, 0)},
		{"size": Vector3(6, 0.5, 6), "pos": Vector3(0, 2.5, -8)},
	]

	for obs in obstacles:
		var body := StaticBody3D.new()
		var obs_col := CollisionShape3D.new()
		var obs_shape := BoxShape3D.new()
		obs_shape.size = obs["size"]
		obs_col.shape = obs_shape
		body.add_child(obs_col)
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = obs["size"]
		mi.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.6, 0.5, 0.4)
		mi.material_override = mat
		body.add_child(mi)
		body.position = obs["pos"]
		get_parent().call_deferred("add_child", body)

	# 조명
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.shadow_enabled = true
	get_parent().call_deferred("add_child", light)

	# 시작 위치
	position = Vector3(0, 1, 5)


func _setup_input_actions():
	# 이동 액션 등록
	var actions := {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"sprint": KEY_SHIFT,
	}

	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event := InputEventKey.new()
			event.keycode = actions[action_name]
			InputMap.action_add_event(action_name, event)
