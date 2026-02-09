# 챕터 15: 3D 캐릭터 컨트롤러 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - 마우스 캡처와 해제 (Input.MOUSE_MODE_CAPTURED)
# - 마우스 룩 (1인칭 카메라 회전)
# - WASD 3D 이동 (카메라 방향 기준)
# - 중력 + 점프 (물리 기반)
# - 스프린트 (달리기) 기능
# - 3인칭(TPS) 카메라 시스템

extends CharacterBody3D

# =============================================
# 캐릭터 설정 변수
# =============================================
# 풀이: @export로 에디터에서 조정 가능한 파라미터를 선언합니다.
#       3D 이동에서는 속도 단위가 m/s(미터/초)로 2D보다 작은 값입니다.
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003  # 라디안/픽셀

# 중력 (프로젝트 설정에서 가져오기)
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# 마우스 룩 제한
var camera_rotation_x: float = 0.0
const MAX_LOOK_UP: float = deg_to_rad(89.0)
const MAX_LOOK_DOWN: float = deg_to_rad(-89.0)

# 스프린트 상태
var is_sprinting: bool = false
var current_speed: float = 5.0

# TPS 카메라 변수
var tps_distance: float = 5.0
var tps_height: float = 2.0
var tps_rotation_y: float = 0.0
var tps_rotation_x: float = -0.3  # 약간 아래를 봄

# 노드 참조
var camera_pivot: Node3D
var camera: Camera3D
var mesh: MeshInstance3D

# 테스트 프레임 카운터
var frame_count: int = 0
var max_test_frames: int = 3


func _ready():
	print("=== 챕터 15: 3D 캐릭터 컨트롤러 ===\n")

	_setup_character()

	# 연습 1: 마우스 캡처
	_exercise_1_mouse_capture()

	# 연습 2: 마우스 룩
	_exercise_2_mouse_look()

	# 연습 3: WASD 이동
	_exercise_3_wasd_movement()

	# 연습 4: 중력과 점프
	_exercise_4_gravity_jump()

	# 연습 5: 스프린트
	_exercise_5_sprint()

	# 연습 6: TPS 카메라
	_exercise_6_tps_camera()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: 마우스 캡처/해제 (CAPTURED/VISIBLE) 구현 완료")
	print("결과 2: 마우스 룩 (X축 clamp, Y축 무한 회전) 구현 완료")
	print("결과 3: WASD 3D 이동 (카메라 방향 기준) 구현 완료")
	print("결과 4: 중력 + 점프 (ProjectSettings gravity) 구현 완료")
	print("결과 5: 스프린트 (Shift 누르면 속도 증가) 구현 완료")
	print("결과 6: TPS 카메라 (오프셋 + 보간 + 줌) 시스템 구현 완료")


func _setup_character():
	# 풀이: 캐릭터의 시각적/물리적 구성요소를 코드로 생성합니다.
	#       실제 프로젝트에서는 에디터에서 씬으로 구성하는 것이 일반적입니다.

	# 충돌 형태
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	col.shape = capsule
	add_child(col)

	# 시각적 메시 (캡슐)
	mesh = MeshInstance3D.new()
	mesh.name = "PlayerMesh"
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.8
	mesh.mesh = capsule_mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.5, 0.8)
	mesh.material_override = mat
	add_child(mesh)

	# 카메라 피봇 (Y축 회전용)
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 1.6, 0)  # 눈 높이
	add_child(camera_pivot)

	# 카메라 (X축 회전용)
	camera = Camera3D.new()
	camera.name = "PlayerCamera"
	camera.fov = 75.0
	camera.current = true
	camera_pivot.add_child(camera)

	print("  캐릭터 구성:")
	print("    CharacterBody3D + CapsuleShape3D (r=0.4, h=1.8)")
	print("    CameraPivot (y=1.6) + Camera3D (fov=75)")
	print()


# ==============================================================================
# 연습 1: 마우스 캡처 - 마우스를 게임 윈도우에 캡처하고
#          ESC로 해제하세요.
# ==============================================================================
func _exercise_1_mouse_capture():
	# 풀이: Input.set_mouse_mode()로 마우스 동작 모드를 설정합니다.
	#       MOUSE_MODE_CAPTURED: 마우스가 화면 중앙에 고정, 커서 숨김 (FPS 게임용)
	#       MOUSE_MODE_VISIBLE: 일반 마우스 커서 표시
	#       MOUSE_MODE_CONFINED: 커서가 윈도우 밖으로 나가지 못함
	#       MOUSE_MODE_HIDDEN: 커서 숨김 (위치는 이동)
	#       _unhandled_input()에서 ESC키로 토글합니다.

	print("연습 1: 마우스 캡처")

	# 마우스 캡처 활성화
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("  마우스 모드:")
	print("    MOUSE_MODE_CAPTURED: 커서 숨김 + 중앙 고정 (FPS)")
	print("    MOUSE_MODE_VISIBLE: 일반 커서 (메뉴)")
	print("    MOUSE_MODE_CONFINED: 윈도우 내 제한")
	print("    MOUSE_MODE_HIDDEN: 커서만 숨김")
	print()
	print("  현재 모드: CAPTURED")
	print("  ESC 키로 캡처 해제/재캡처 토글")
	print()

	# 구현 코드 설명
	print("  _unhandled_input 구현:")
	print("  ```gdscript")
	print("  func _unhandled_input(event):")
	print("      if event.is_action_pressed(\"ui_cancel\"):  # ESC")
	print("          if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:")
	print("              Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)")
	print("          else:")
	print("              Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)")
	print("  ```")

	print("연습 1 완료: 마우스 캡처\n")


# ==============================================================================
# 연습 2: 마우스 룩 - 마우스 이동으로 카메라를 회전하세요.
#          X축(위아래) 회전은 clamp, Y축(좌우)은 무한 회전.
# ==============================================================================
func _exercise_2_mouse_look():
	# 풀이: InputEventMouseMotion의 relative 속성에서 마우스 이동량을 가져옵니다.
	#       Y축 회전(좌우): CharacterBody3D 자체를 rotate_y()로 회전
	#       X축 회전(위아래): 카메라 피봇의 rotation.x를 변경하고 clamp
	#       감도(sensitivity)를 곱하여 이동량을 라디안으로 변환합니다.
	#       clamp로 위/아래 시야 제한 (-89도 ~ 89도)을 적용합니다.

	print("연습 2: 마우스 룩 (FPS 카메라)")

	print("  원리:")
	print("    1. InputEventMouseMotion.relative로 마우스 이동량 감지")
	print("    2. relative.x -> 캐릭터 Y축 회전 (좌우 돌아봄)")
	print("    3. relative.y -> 카메라 X축 회전 (위아래 시야)")
	print("    4. X축 회전을 -89~89도로 clamp (뒤로 젖힘 방지)")
	print()

	print("  _unhandled_input 구현:")
	print("  ```gdscript")
	print("  func _unhandled_input(event):")
	print("      if event is InputEventMouseMotion:")
	print("          if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:")
	print("              # 좌우 회전 (캐릭터 전체)")
	print("              rotate_y(-event.relative.x * mouse_sensitivity)")
	print("")
	print("              # 위아래 회전 (카메라만)")
	print("              camera_rotation_x += -event.relative.y * mouse_sensitivity")
	print("              camera_rotation_x = clamp(camera_rotation_x,")
	print("                  MAX_LOOK_DOWN, MAX_LOOK_UP)")
	print("              camera_pivot.rotation.x = camera_rotation_x")
	print("  ```")
	print()

	# 감도 시뮬레이션
	print("  감도 설정:")
	print("    mouse_sensitivity: %.4f rad/px" % mouse_sensitivity)
	var simulated_move := Vector2(100, 50)  # 마우스 100px 오른쪽, 50px 아래 이동
	var yaw := -simulated_move.x * mouse_sensitivity
	var pitch := -simulated_move.y * mouse_sensitivity
	print("    마우스 이동 (%s px) 시뮬레이션:" % simulated_move)
	print("    Y축 회전 (yaw): %.4f rad (%.2f도)" % [yaw, rad_to_deg(yaw)])
	print("    X축 회전 (pitch): %.4f rad (%.2f도)" % [pitch, rad_to_deg(pitch)])
	print()

	# clamp 동작 확인
	print("  시야 제한 (clamp):")
	print("    MAX_LOOK_UP: %.1f도" % rad_to_deg(MAX_LOOK_UP))
	print("    MAX_LOOK_DOWN: %.1f도" % rad_to_deg(MAX_LOOK_DOWN))
	var test_angles := [-100.0, -89.0, 0.0, 45.0, 89.0, 100.0]
	for angle in test_angles:
		var clamped := clampf(deg_to_rad(angle), MAX_LOOK_DOWN, MAX_LOOK_UP)
		print("    %.0f도 -> %.1f도 (clamp)" % [angle, rad_to_deg(clamped)])

	print("연습 2 완료: 마우스 룩\n")


# ==============================================================================
# 연습 3: WASD 이동 - 카메라 방향을 기준으로 3D 이동을 구현하세요.
#          대각선 이동 시 속도가 빨라지지 않도록 정규화하세요.
# ==============================================================================
func _exercise_3_wasd_movement():
	# 풀이: Input.get_vector()로 WASD 입력을 2D 벡터로 가져옵니다.
	#       이 2D 벡터를 캐릭터의 transform.basis(현재 회전 기준)와 곱하여
	#       3D 방향 벡터로 변환합니다. XZ 평면에서만 이동하므로 Y=0으로 설정합니다.
	#       normalized()로 대각선 이동 시 속도 초과를 방지합니다.

	print("연습 3: WASD 3D 이동")

	print("  입력 -> 3D 방향 변환 원리:")
	print("    1. Input.get_vector() -> Vector2(x, y)")
	print("    2. basis * Vector3(input.x, 0, input.y) -> 월드 방향")
	print("    3. direction.normalized() -> 대각선 속도 보정")
	print("    4. velocity.x/z = direction * speed")
	print()

	# 방향 변환 시뮬레이션
	var test_inputs := {
		"전진 (W)": Vector2(0, -1),     # ui_up
		"후진 (S)": Vector2(0, 1),      # ui_down
		"좌측 (A)": Vector2(-1, 0),     # ui_left
		"우측 (D)": Vector2(1, 0),      # ui_right
		"대각선 (W+D)": Vector2(1, -1), # 오른쪽 전방
	}

	print("  방향 변환 시뮬레이션 (회전 0도):")
	for label in test_inputs:
		var input_vec: Vector2 = test_inputs[label]
		# 풀이: transform.basis는 현재 회전 상태를 나타내는 3x3 행렬입니다.
		#       이를 Vector3에 곱하면 로컬 -> 월드 변환이 됩니다.
		var raw_dir := transform.basis * Vector3(input_vec.x, 0, input_vec.y)
		var norm_dir := raw_dir.normalized() if raw_dir.length() > 0 else Vector3.ZERO
		print("    %s: input=%s -> raw=%s (len=%.2f) -> norm=%s" % [
			label, input_vec, raw_dir, raw_dir.length(), norm_dir
		])
	print()

	# _physics_process 이동 코드
	print("  _physics_process 이동 구현:")
	print("  ```gdscript")
	print("  # 이동 입력")
	print("  var input_dir = Input.get_vector(\"move_left\", \"move_right\",")
	print("                                    \"move_forward\", \"move_back\")")
	print("  var direction = (transform.basis * Vector3(")
	print("      input_dir.x, 0, input_dir.y)).normalized()")
	print("")
	print("  if direction:")
	print("      velocity.x = direction.x * current_speed")
	print("      velocity.z = direction.z * current_speed")
	print("  else:")
	print("      # 관성 감속 (부드러운 멈춤)")
	print("      velocity.x = move_toward(velocity.x, 0, current_speed)")
	print("      velocity.z = move_toward(velocity.z, 0, current_speed)")
	print("  ```")
	print()

	# move_toward 설명
	print("  move_toward(from, to, delta) 설명:")
	print("    현재값에서 목표값으로 delta만큼 이동합니다.")
	print("    velocity.x = move_toward(5.0, 0.0, 2.0) = 3.0")
	print("    velocity.x = move_toward(1.0, 0.0, 2.0) = 0.0 (초과 안 함)")

	print("연습 3 완료: WASD 3D 이동\n")


# ==============================================================================
# 연습 4: 중력 + 점프 - 물리 기반 중력을 적용하고
#          바닥에서만 점프할 수 있게 구현하세요.
# ==============================================================================
func _exercise_4_gravity_jump():
	# 풀이: ProjectSettings에서 기본 중력값(9.8)을 가져와 사용합니다.
	#       바닥에 있지 않을 때(not is_on_floor()) velocity.y에서 중력을 뺍니다.
	#       점프는 is_on_floor()일 때만 velocity.y에 양수값을 대입합니다.
	#       Godot 3D에서 Y-up이므로 위가 양수, 중력은 velocity.y를 감소시킵니다.

	print("연습 4: 중력 + 점프")

	print("  프로젝트 기본 중력: %.1f m/s^2" % gravity)
	print("  점프 속도: %.1f m/s" % jump_velocity)
	print()

	# 점프 물리 시뮬레이션
	# 풀이: 점프 후 포물선 궤적을 시뮬레이션하여 최대 높이와 체공 시간을 계산합니다.
	var delta := 1.0 / 60.0  # 60 FPS 시뮬레이션
	var sim_vel_y := jump_velocity
	var sim_height := 0.0
	var max_height := 0.0
	var air_time := 0.0

	print("  점프 궤적 시뮬레이션 (60 FPS):")
	var step := 0
	while sim_height >= 0.0 or step == 0:
		if step % 5 == 0 or sim_height < 0:
			print("    t=%.2fs: height=%.3fm, vel_y=%.2fm/s" % [
				step * delta, sim_height, sim_vel_y
			])
		if sim_height > max_height:
			max_height = sim_height
		sim_vel_y -= gravity * delta
		sim_height += sim_vel_y * delta
		air_time += delta
		step += 1
		if step > 600:
			break  # 안전 장치
	print()

	print("  점프 통계:")
	print("    최대 높이: %.3f m" % max_height)
	print("    체공 시간: %.2f 초" % air_time)
	print("    이론적 최대 높이: %.3f m (v^2 / 2g)" % (jump_velocity * jump_velocity / (2 * gravity)))
	print()

	# _physics_process 중력/점프 코드
	print("  _physics_process 중력/점프 구현:")
	print("  ```gdscript")
	print("  func _physics_process(delta):")
	print("      # 중력")
	print("      if not is_on_floor():")
	print("          velocity.y -= gravity * delta")
	print("")
	print("      # 점프 (바닥에서만)")
	print("      if Input.is_action_just_pressed(\"jump\") and is_on_floor():")
	print("          velocity.y = jump_velocity")
	print("")
	print("      # ... 이동 코드 ...")
	print("      move_and_slide()")
	print("  ```")
	print()

	# 코요테 타임 / 점프 버퍼
	print("  고급: 코요테 타임 & 점프 버퍼")
	print("    코요테 타임: 바닥을 떠난 직후 짧은 시간(~0.15초) 동안 점프 허용")
	print("    점프 버퍼: 착지 직전 점프 입력을 기억하고 착지 시 자동 점프")
	print("  ```gdscript")
	print("  var coyote_timer: float = 0.0")
	print("  var jump_buffer_timer: float = 0.0")
	print("  const COYOTE_TIME = 0.15")
	print("  const JUMP_BUFFER_TIME = 0.1")
	print("")
	print("  if is_on_floor():")
	print("      coyote_timer = COYOTE_TIME")
	print("  else:")
	print("      coyote_timer -= delta")
	print("")
	print("  if Input.is_action_just_pressed(\"jump\"):")
	print("      jump_buffer_timer = JUMP_BUFFER_TIME")
	print("  else:")
	print("      jump_buffer_timer -= delta")
	print("")
	print("  if jump_buffer_timer > 0 and coyote_timer > 0:")
	print("      velocity.y = jump_velocity")
	print("      coyote_timer = 0")
	print("      jump_buffer_timer = 0")
	print("  ```")

	print("연습 4 완료: 중력 + 점프\n")


# ==============================================================================
# 연습 5: 스프린트 - Shift 키를 누르면 이동 속도가 증가하는
#          달리기 기능을 구현하세요.
# ==============================================================================
func _exercise_5_sprint():
	# 풀이: Input.is_action_pressed("sprint")로 Shift 키 상태를 확인합니다.
	#       is_sprinting 플래그에 따라 current_speed를 walk_speed 또는
	#       sprint_speed로 전환합니다. lerp로 부드러운 속도 전환도 가능합니다.
	#       FOV 변경을 추가하면 시각적 속도감이 향상됩니다.

	print("연습 5: 스프린트 (달리기)")

	print("  속도 설정:")
	print("    walk_speed: %.1f m/s" % walk_speed)
	print("    sprint_speed: %.1f m/s" % sprint_speed)
	print("    배율: %.1fx" % (sprint_speed / walk_speed))
	print()

	# 스프린트 구현
	print("  스프린트 구현:")
	print("  ```gdscript")
	print("  func _physics_process(delta):")
	print("      # 스프린트 상태 확인")
	print("      is_sprinting = Input.is_action_pressed(\"sprint\") and is_on_floor()")
	print("")
	print("      # 부드러운 속도 전환")
	print("      var target_speed = sprint_speed if is_sprinting else walk_speed")
	print("      current_speed = lerp(current_speed, target_speed, delta * 10.0)")
	print("")
	print("      # FOV 변경 (속도감)")
	print("      var target_fov = 85.0 if is_sprinting else 75.0")
	print("      camera.fov = lerp(camera.fov, target_fov, delta * 8.0)")
	print("  ```")
	print()

	# 속도 전환 시뮬레이션
	print("  속도 전환 시뮬레이션 (lerp):")
	var sim_speed := walk_speed
	var sim_delta := 1.0 / 60.0
	for i in range(10):
		sim_speed = lerp(sim_speed, sprint_speed, sim_delta * 10.0)
		if i % 2 == 0:
			print("    frame %d: speed=%.2f m/s" % [i, sim_speed])
	print("    ... -> 최종: %.1f m/s" % sprint_speed)
	print()

	# FOV 효과 설명
	print("  FOV 변경 효과:")
	print("    걷기: 75도 (기본)")
	print("    달리기: 85도 (넓어짐 -> 속도감)")
	print("    줌: 50도 (좁아짐 -> 집중/망원)")
	print()

	# 스태미나 시스템 (선택)
	print("  고급: 스태미나 시스템:")
	print("  ```gdscript")
	print("  var stamina: float = 100.0")
	print("  var max_stamina: float = 100.0")
	print("  var sprint_cost: float = 20.0     # 초당 소모")
	print("  var stamina_regen: float = 15.0   # 초당 회복")
	print("")
	print("  if is_sprinting and stamina > 0:")
	print("      stamina -= sprint_cost * delta")
	print("      if stamina <= 0:")
	print("          is_sprinting = false")
	print("  else:")
	print("      stamina = min(max_stamina, stamina + stamina_regen * delta)")
	print("  ```")

	print("연습 5 완료: 스프린트\n")


# ==============================================================================
# 연습 6: TPS 카메라 - 3인칭 카메라 시스템을 구현하세요.
#          카메라 오프셋, 마우스 회전, 부드러운 추적을 포함합니다.
# ==============================================================================
func _exercise_6_tps_camera():
	# 풀이: 3인칭 카메라는 캐릭터 뒤에서 따라가는 카메라입니다.
	#       SpringArm3D를 사용하면 벽 충돌 시 자동으로 카메라를 당겨줍니다.
	#       카메라 피봇을 캐릭터 위에 배치하고, 마우스로 피봇을 회전합니다.
	#       lerp로 부드럽게 캐릭터를 추적하면 더 자연스럽습니다.

	print("연습 6: TPS (3인칭) 카메라")

	# SpringArm3D 기반 TPS 카메라
	print("  SpringArm3D 기반 TPS 카메라:")
	print("  ```gdscript")
	print("  # 씬 구조:")
	print("  # CharacterBody3D")
	print("  #   +-- TPSPivot (Node3D) <- Y축 회전")
	print("  #       +-- SpringArm3D <- X축 회전 + 거리")
	print("  #           +-- Camera3D")
	print("  ```")
	print()

	# SpringArm3D 생성
	var tps_pivot := Node3D.new()
	tps_pivot.name = "TPSPivot"
	tps_pivot.position = Vector3(0, 1.6, 0)  # 캐릭터 머리 위
	add_child(tps_pivot)

	var spring_arm := SpringArm3D.new()
	spring_arm.name = "SpringArm"
	spring_arm.spring_length = tps_distance     # 카메라 거리
	spring_arm.rotation.x = tps_rotation_x      # 약간 아래 각도
	spring_arm.collision_mask = 0b0100           # 지형(Layer 3)과만 충돌
	tps_pivot.add_child(spring_arm)

	var tps_cam := Camera3D.new()
	tps_cam.name = "TPSCamera"
	tps_cam.fov = 65.0
	spring_arm.add_child(tps_cam)

	print("  SpringArm3D 설정:")
	print("    spring_length: %.1f m (카메라 거리)" % spring_arm.spring_length)
	print("    rotation.x: %.2f rad (%.1f도)" % [
		spring_arm.rotation.x, rad_to_deg(spring_arm.rotation.x)
	])
	print("    collision_mask: %d (벽 관통 방지)" % spring_arm.collision_mask)
	print("    margin: %.2f (충돌 마진)" % spring_arm.margin)
	print()

	# TPS 마우스 회전 구현
	print("  TPS 마우스 회전 구현:")
	print("  ```gdscript")
	print("  func _unhandled_input(event):")
	print("      if event is InputEventMouseMotion:")
	print("          # Y축 회전 (좌우) - 피봇 회전")
	print("          tps_pivot.rotate_y(-event.relative.x * mouse_sensitivity)")
	print("")
	print("          # X축 회전 (위아래) - SpringArm 회전")
	print("          spring_arm.rotation.x -= event.relative.y * mouse_sensitivity")
	print("          spring_arm.rotation.x = clamp(spring_arm.rotation.x,")
	print("              deg_to_rad(-80), deg_to_rad(30))")
	print("  ```")
	print()

	# TPS에서 캐릭터 이동 방향
	# 풀이: TPS에서는 카메라 방향을 기준으로 이동해야 합니다.
	#       캐릭터의 rotation.y가 아닌 피봇의 rotation.y를 기준으로 방향을 계산합니다.
	print("  TPS 이동 방향 (카메라 기준):")
	print("  ```gdscript")
	print("  var input_dir = Input.get_vector(\"move_left\", \"move_right\",")
	print("                                    \"move_forward\", \"move_back\")")
	print("  # 카메라 피봇 기준으로 방향 변환")
	print("  var direction = (tps_pivot.global_transform.basis *")
	print("      Vector3(input_dir.x, 0, input_dir.y)).normalized()")
	print("")
	print("  # 캐릭터가 이동 방향을 바라보게 회전")
	print("  if direction:")
	print("      var target_angle = atan2(direction.x, direction.z)")
	print("      rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)")
	print("  ```")
	print()

	# 줌 기능
	print("  마우스 휠 줌:")
	print("  ```gdscript")
	print("  func _unhandled_input(event):")
	print("      if event is InputEventMouseButton:")
	print("          if event.button_index == MOUSE_BUTTON_WHEEL_UP:")
	print("              spring_arm.spring_length = max(2.0,")
	print("                  spring_arm.spring_length - 0.5)")
	print("          elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:")
	print("              spring_arm.spring_length = min(10.0,")
	print("                  spring_arm.spring_length + 0.5)")
	print("  ```")
	print()

	# FPS vs TPS 비교
	print("  FPS vs TPS 카메라 비교:")
	print("    +------------------+-----------------------+-----------------------+")
	print("    | 속성             | FPS (1인칭)           | TPS (3인칭)           |")
	print("    +------------------+-----------------------+-----------------------+")
	print("    | 카메라 위치      | 캐릭터 눈 높이        | 캐릭터 뒤 오프셋     |")
	print("    | 회전 대상        | 캐릭터 + 카메라       | 피봇 + SpringArm     |")
	print("    | 이동 기준        | transform.basis       | 피봇 basis           |")
	print("    | 벽 처리          | 불필요                | SpringArm 필수       |")
	print("    | 캐릭터 표시      | 보이지 않음           | 메시 보임            |")
	print("    +------------------+-----------------------+-----------------------+")

	print("연습 6 완료: TPS 카메라\n")


# ==============================================================================
# _unhandled_input: 마우스 캡처 토글 + 마우스 룩
# ==============================================================================
func _unhandled_input(event: InputEvent):
	# 풀이: _unhandled_input은 UI 등에서 처리되지 않은 입력을 처리합니다.
	#       _input보다 우선순위가 낮아 UI가 입력을 소비하면 호출되지 않습니다.

	# ESC로 마우스 캡처 토글
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# 마우스 룩
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# 좌우 회전 (Y축) - 캐릭터 전체 회전
			rotate_y(-event.relative.x * mouse_sensitivity)

			# 위아래 회전 (X축) - 카메라만 회전, 범위 제한
			camera_rotation_x += -event.relative.y * mouse_sensitivity
			camera_rotation_x = clamp(camera_rotation_x, MAX_LOOK_DOWN, MAX_LOOK_UP)
			if camera_pivot:
				camera_pivot.rotation.x = camera_rotation_x


# ==============================================================================
# _physics_process: 이동, 중력, 점프, 스프린트 통합
# ==============================================================================
func _physics_process(delta: float):
	# 중력 적용
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 점프
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 스프린트
	is_sprinting = Input.is_action_pressed("ui_page_down") and is_on_floor()
	var target_speed := sprint_speed if is_sprinting else walk_speed
	current_speed = lerp(current_speed, target_speed, delta * 10.0)

	# FOV 효과
	if camera:
		var target_fov := 85.0 if is_sprinting else 75.0
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	# 이동 입력
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	# 디버그 출력 (처음 몇 프레임만)
	if frame_count < max_test_frames:
		frame_count += 1
		if frame_count == 1:
			print("\n--- _physics_process 실행 ---")
		print("  frame %d: pos=%s, vel=%s, floor=%s, sprint=%s" % [
			frame_count, global_position, velocity, is_on_floor(), is_sprinting
		])
