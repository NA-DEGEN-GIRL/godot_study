# Chapter 15 - 3D Character Controller
# 03-tps-controller.gd - TPS (Third Person Shooter) 컨트롤러
#
# 이 파일에서 배울 내용:
# - SpringArm3D로 3인칭 카메라 구현
# - 카메라 기준 이동 방향 계산
# - 캐릭터가 이동 방향으로 자연스럽게 회전
# - 카메라와 캐릭터 회전 분리

extends CharacterBody3D

# ============================================
# 이동 설정
# ============================================

@export_group("Movement")
@export var walk_speed := 4.0
@export var run_speed := 7.0
@export var rotation_speed := 10.0  # 캐릭터 회전 보간 속도
@export var acceleration := 8.0
@export var deceleration := 10.0

@export_group("Jump")
@export var jump_velocity := 5.5
@export var gravity_multiplier := 1.0

@export_group("Camera")
@export var mouse_sensitivity := 0.003
@export var camera_distance := 4.0      # 카메라 거리
@export var camera_height := 1.5        # 카메라 높이
@export var pitch_min := -40.0          # 최소 각도 (아래)
@export var pitch_max := 60.0           # 최대 각도 (위)

# ============================================
# 내부 변수
# ============================================

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_running := false

# 노드 참조
var camera_pivot: Node3D
var spring_arm: SpringArm3D
var camera: Camera3D
var mesh_root: Node3D  # 캐릭터 메시 루트 (회전 대상)

func _ready():
	print("=== TPS 컨트롤러 ===\n")

	_create_scene()
	_setup_input_actions()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# ============================================
	# 1. TPS 카메라 구조
	# ============================================
	print("--- 1. TPS 카메라 구조 ---\n")

	print("FPS vs TPS 차이:")
	print("  FPS: 카메라 = 캐릭터 눈 (1인칭)")
	print("  TPS: 카메라 = 캐릭터 뒤+위 (3인칭)")
	print("  -> TPS에서는 캐릭터와 카메라 회전이 별도!")
	print("")

	print("노드 트리:")
	print("  CharacterBody3D")
	print("    +-- CollisionShape3D")
	print("    +-- MeshRoot (Node3D)      <- 캐릭터 메시 회전용")
	print("         +-- MeshInstance3D")
	print("    +-- CameraPivot (Node3D)   <- 카메라 회전 중심")
	print("         +-- SpringArm3D       <- 충돌 방지, 거리 유지")
	print("              +-- Camera3D")
	print("")

	print("왜 MeshRoot가 별도로 필요한가?")
	print("  카메라: 마우스로 자유롭게 회전")
	print("  캐릭터 메시: 이동 방향으로만 회전")
	print("  -> 캐릭터 루트는 회전하지 않고, MeshRoot만 회전!")

	# ============================================
	# 2. SpringArm3D
	# ============================================
	print("\n--- 2. SpringArm3D ---\n")

	print("SpringArm3D란?")
	print("  카메라가 벽을 뚫지 않도록 자동 거리 조절")
	print("  벽이 있으면 가까워지고, 없으면 원래 거리 유지")
	print("")

	print("주요 속성:")
	print("  spring_length = %.1f  (기본 거리)" % spring_arm.spring_length)
	print("  margin = 0.01        (벽과의 최소 거리)")
	print("  collision_mask       (어떤 레이어와 충돌할지)")
	print("")

	print("SpringArm3D 작동 원리:")
	print("  1. 피봇에서 spring_length 만큼 뒤로 레이 발사")
	print("  2. 벽에 부딪히면 카메라를 벽 앞으로 이동")
	print("  3. 벽이 없으면 원래 거리 유지")
	print("  -> 실내에서 카메라가 벽을 뚫는 문제 해결!")
	print("")

	print("코드로 SpringArm3D 생성:")
	print("""  var spring_arm = SpringArm3D.new()
  spring_arm.spring_length = 4.0
  spring_arm.collision_mask = 0b0100  # 환경 레이어만
  spring_arm.add_excluded_object(self)  # 자기 자신 제외

  var camera = Camera3D.new()
  spring_arm.add_child(camera)
  camera_pivot.add_child(spring_arm)""")

	# ============================================
	# 3. 카메라 기준 이동
	# ============================================
	print("\n--- 3. 카메라 기준 이동 ---\n")

	print("TPS 이동의 핵심:")
	print("  W를 누르면 '카메라가 보는 방향'으로 이동")
	print("  캐릭터의 현재 회전과 무관!")
	print("")

	print("방향 계산:")
	print("""  # 카메라 피봇의 Y축 회전(yaw)만 사용
  # (pitch는 카메라 상하 각도, 이동에 영향 X)
  var cam_yaw = camera_pivot.global_rotation.y

  # 입력을 카메라 기준 방향으로 변환
  var input_dir = Input.get_vector("move_left", "move_right",
                                    "move_forward", "move_backward")
  var direction = Vector3.ZERO
  direction += Vector3.FORWARD.rotated(Vector3.UP, cam_yaw) * -input_dir.y
  direction += Vector3.RIGHT.rotated(Vector3.UP, cam_yaw) * input_dir.x
  direction = direction.normalized()""")
	print("")

	print("또 다른 방법 (Basis 사용):")
	print("""  # 카메라 피봇의 basis에서 수평 방향만 추출
  var forward = -camera_pivot.global_transform.basis.z
  forward.y = 0
  forward = forward.normalized()
  var right = camera_pivot.global_transform.basis.x
  right.y = 0
  right = right.normalized()

  var direction = forward * -input_dir.y + right * input_dir.x""")

	# ============================================
	# 4. 캐릭터 회전 (이동 방향으로)
	# ============================================
	print("\n--- 4. 캐릭터 회전 ---\n")

	print("캐릭터가 이동 방향을 바라봄:")
	print("""  if direction.length() > 0.1:
      # 목표 회전 각도 계산
      var target_angle = atan2(direction.x, direction.z)

      # 부드러운 회전 보간
      mesh_root.rotation.y = lerp_angle(
          mesh_root.rotation.y,
          target_angle,
          rotation_speed * delta
      )""")
	print("")

	print("lerp_angle이 필요한 이유:")
	print("  일반 lerp: 350도 -> 10도 시 거꾸로 340도 회전!")
	print("  lerp_angle: 350도 -> 10도 시 최단 경로 20도 회전!")
	print("  -> 회전 보간에는 항상 lerp_angle 사용!")
	print("")

	print("look_at 방식 (즉시 회전):")
	print("""  if direction.length() > 0.1:
      var look_pos = mesh_root.global_position + direction
      mesh_root.look_at(look_pos, Vector3.UP)
      # 주의: 즉시 회전이므로 부드럽지 않음""")

	# ============================================
	# 5. 전투 모드 (Strafe)
	# ============================================
	print("\n--- 5. 전투 모드 (Strafe) ---\n")

	print("일반 모드 vs 전투 모드:")
	print("  일반: 캐릭터가 이동 방향을 바라봄")
	print("  전투: 캐릭터가 항상 카메라 방향(또는 적)을 바라봄")
	print("       -> 옆걸음(strafe), 뒷걸음질 가능")
	print("")

	print("전투 모드 코드:")
	print("""  var combat_mode: bool = false

  func _physics_process(delta):
      # ... 이동 계산 ...

      if combat_mode:
          # 캐릭터는 항상 카메라 방향을 바라봄
          mesh_root.rotation.y = lerp_angle(
              mesh_root.rotation.y,
              camera_pivot.rotation.y,
              rotation_speed * delta
          )
      else:
          # 캐릭터는 이동 방향을 바라봄
          if direction.length() > 0.1:
              var target_angle = atan2(direction.x, direction.z)
              mesh_root.rotation.y = lerp_angle(
                  mesh_root.rotation.y, target_angle,
                  rotation_speed * delta)""")
	print("")

	print("조준(Aim) 시 전투 모드 전환:")
	print("  if Input.is_action_pressed('aim'):")
	print("      combat_mode = true")
	print("      # 카메라 줌인")
	print("      spring_arm.spring_length = lerp(spring_arm.spring_length, 2.0, ...)")
	print("  else:")
	print("      combat_mode = false")
	print("      spring_arm.spring_length = lerp(spring_arm.spring_length, 4.0, ...)")

	# ============================================
	# 6. 카메라 부드러운 추적
	# ============================================
	print("\n--- 6. 카메라 추적 ---\n")

	print("기본 방식 (자식 노드):")
	print("  CameraPivot이 CharacterBody3D의 자식")
	print("  -> 자동으로 캐릭터를 따라감")
	print("  -> 약간 딱딱한 느낌")
	print("")

	print("부드러운 추적 (별도 노드):")
	print("""  # CameraPivot을 캐릭터 밖에 두고 lerp로 추적
  extends Node3D  # CameraPivot 스크립트

  @export var target: CharacterBody3D
  @export var follow_speed: float = 8.0
  @export var height_offset: float = 1.5

  func _process(delta):
      if target:
          var target_pos = target.global_position + Vector3(0, height_offset, 0)
          global_position = global_position.lerp(target_pos, follow_speed * delta)""")
	print("")

	print("카메라 충돌 처리 팁:")
	print("  1. SpringArm3D가 기본 충돌 방지")
	print("  2. 추가로 카메라와 캐릭터 사이 장애물 체크")
	print("  3. 캐릭터가 안 보이면 카메라 가까이")
	print("  4. 좁은 공간에서 자동 1인칭 전환 고려")

	# ============================================
	# 7. 경사면 이동
	# ============================================
	print("\n--- 7. 경사면 이동 ---\n")

	print("CharacterBody3D 경사면 설정:")
	print("  floor_max_angle = deg_to_rad(45)  # 걸을 수 있는 최대 경사")
	print("  floor_snap_length = 0.1  # 바닥에 붙는 거리")
	print("  floor_stop_on_slope = true  # 경사에서 멈춤")
	print("  floor_block_on_wall = true  # 벽에서 미끄러짐 방지")
	print("")

	print("경사면에서 속도 보정:")
	print("""  # 경사면에서 속도가 변하지 않도록
  func get_floor_velocity_correction() -> float:
      if is_on_floor():
          var floor_normal = get_floor_normal()
          var slope_angle = floor_normal.angle_to(Vector3.UP)
          # 경사면에서 속도 보정 (올라갈 때 느려지지 않도록)
          return 1.0 / cos(slope_angle)
      return 1.0""")

	# ============================================
	# 8. 완전한 코드 요약
	# ============================================
	print("\n--- 8. 완전한 코드 요약 ---\n")

	print("TPS 컨트롤러 핵심 단계:")
	print("  1. 마우스로 CameraPivot 회전 (Y=좌우, X=상하)")
	print("  2. Input.get_vector()로 입력 방향 얻기")
	print("  3. 카메라 피봇의 yaw로 입력 방향 회전")
	print("  4. velocity에 방향 * 속도 적용")
	print("  5. 캐릭터 메시를 이동 방향으로 lerp_angle 회전")
	print("  6. move_and_slide() 호출")
	print("  7. SpringArm3D가 카메라 충돌 자동 처리")

	# ============================================
	# 9. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. SpringArm3D: 카메라 충돌 자동 방지")
	print("2. CameraPivot: 카메라 회전 중심 (캐릭터와 독립)")
	print("3. MeshRoot: 캐릭터 메시 회전 (이동 방향)")
	print("4. 카메라 기준 이동: 카메라 yaw로 입력 방향 회전")
	print("5. lerp_angle(): 최단 경로 회전 보간")
	print("6. 전투 모드: 캐릭터가 카메라 방향 고정 (strafe)")
	print("7. 부드러운 추적: lerp로 카메라 위치 보간")

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
			# 좌우 회전 (카메라 피봇)
			camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
			# 위아래 회전 (스프링암 또는 피봇)
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			camera_pivot.rotation.x = clamp(
				camera_pivot.rotation.x,
				deg_to_rad(pitch_min),
				deg_to_rad(pitch_max)
			)


# ============================================
# 물리 처리
# ============================================

func _physics_process(delta: float):
	# 중력
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	# 점프
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 입력 방향 (카메라 기준)
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward")

	# 카메라 기준 방향 계산
	var cam_yaw := camera_pivot.global_rotation.y
	var direction := Vector3.ZERO
	direction += Vector3.FORWARD.rotated(Vector3.UP, cam_yaw) * -input_dir.y
	direction += Vector3.RIGHT.rotated(Vector3.UP, cam_yaw) * input_dir.x
	if direction.length() > 1.0:
		direction = direction.normalized()

	# 달리기
	is_running = Input.is_action_pressed("sprint") and direction.length() > 0
	var target_speed := run_speed if is_running else walk_speed

	# 가감속
	var accel := acceleration if direction.length() > 0.1 else deceleration
	velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)

	# 캐릭터 메시 회전 (이동 방향)
	if direction.length() > 0.1 and mesh_root:
		var target_angle := atan2(direction.x, direction.z)
		mesh_root.rotation.y = lerp_angle(
			mesh_root.rotation.y, target_angle, rotation_speed * delta)

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

	# 캐릭터 메시 (별도 Node3D로 회전)
	mesh_root = Node3D.new()
	mesh_root.name = "MeshRoot"
	add_child(mesh_root)

	# 몸통 (캡슐)
	var body_mi := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.35
	body_mesh.height = 1.4
	body_mi.mesh = body_mesh
	body_mi.position = Vector3(0, 0.9, 0)
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.3, 0.5, 0.8)
	body_mi.material_override = body_mat
	mesh_root.add_child(body_mi)

	# 머리 (구)
	var head_mi := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.25
	head_mi.mesh = head_mesh
	head_mi.position = Vector3(0, 1.85, 0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.8, 0.7, 0.6)
	head_mi.material_override = head_mat
	mesh_root.add_child(head_mi)

	# 앞 방향 표시 (코)
	var nose_mi := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.1, 0.1, 0.2)
	nose_mi.mesh = nose_mesh
	nose_mi.position = Vector3(0, 1.85, -0.3)
	mesh_root.add_child(nose_mi)

	# 카메라 피봇 (캐릭터 중심에 위치)
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, camera_height, 0)
	add_child(camera_pivot)

	# SpringArm3D
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm"
	spring_arm.spring_length = camera_distance
	spring_arm.collision_mask = 1  # 환경 레이어
	spring_arm.add_excluded_object(self)
	camera_pivot.add_child(spring_arm)

	# 카메라 (SpringArm의 자식)
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.fov = 75.0
	spring_arm.add_child(camera)
	camera.make_current()

	# 바닥
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(40, 0.1, 40)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var fmesh := BoxMesh.new()
	fmesh.size = Vector3(40, 0.1, 40)
	floor_mi.mesh = fmesh
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.35, 0.4, 0.35)
	floor_mi.material_override = fmat
	floor_body.add_child(floor_mi)
	get_parent().call_deferred("add_child", floor_body)

	# 장애물들
	var obstacles := [
		{"size": Vector3(2, 3, 2), "pos": Vector3(5, 1.5, -5)},
		{"size": Vector3(4, 1, 4), "pos": Vector3(-6, 0.5, -4)},
		{"size": Vector3(1, 4, 8), "pos": Vector3(8, 2, 2)},
		{"size": Vector3(3, 2, 1), "pos": Vector3(-3, 1, 5)},
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
		mat.albedo_color = Color(0.5, 0.45, 0.4)
		mi.material_override = mat
		body.add_child(mi)
		body.position = obs["pos"]
		get_parent().call_deferred("add_child", body)

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
	}

	for action_name in actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var event := InputEventKey.new()
			event.keycode = actions[action_name]
			InputMap.action_add_event(action_name, event)
