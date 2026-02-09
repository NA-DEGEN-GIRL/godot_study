# Chapter 14 - 3D Physics
# 01-physics-bodies.gd - 3D 물리 바디 종류와 생성
#
# 이 파일에서 배울 내용:
# - StaticBody3D (정적 바디): 움직이지 않는 벽, 바닥
# - RigidBody3D (강체): 물리 시뮬레이션 오브젝트
# - CharacterBody3D (캐릭터 바디): 직접 제어하는 캐릭터
# - AnimatableBody3D: 애니메이션으로 움직이는 물리체

extends Node3D

func _ready():
	print("=== 3D 물리 바디 (Physics Bodies) ===\n")

	# ============================================
	# 1. 물리 바디 개요
	# ============================================
	print("--- 1. 물리 바디 개요 ---\n")

	print("Godot 3D 물리 바디 종류:")
	print("  StaticBody3D      -> 움직이지 않는 물체 (벽, 바닥, 지형)")
	print("  RigidBody3D       -> 물리 엔진이 제어 (상자, 공, 파편)")
	print("  CharacterBody3D   -> 코드로 직접 제어 (플레이어, NPC)")
	print("  AnimatableBody3D  -> 애니메이션으로 이동 (엘리베이터, 플랫폼)")
	print("")

	print("필수 구조: PhysicsBody3D + CollisionShape3D")
	print("  모든 물리 바디에는 CollisionShape3D 자식이 필요!")
	print("  CollisionShape3D가 없으면 충돌 감지 불가!")
	print("")

	print("노드 트리 구조:")
	print("  StaticBody3D (또는 RigidBody3D 등)")
	print("    +-- CollisionShape3D   <- 충돌 형태")
	print("    +-- MeshInstance3D     <- 시각적 형태 (선택)")

	# ============================================
	# 2. StaticBody3D (정적 바디)
	# ============================================
	print("\n--- 2. StaticBody3D ---\n")

	# 코드로 StaticBody3D 생성 (바닥)
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"

	# CollisionShape3D 추가
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.2, 20)  # 넓고 얇은 상자
	floor_collision.shape = floor_shape
	floor_body.add_child(floor_collision)

	# MeshInstance3D 추가 (시각적)
	var floor_mesh_instance := MeshInstance3D.new()
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(20, 0.2, 20)
	floor_mesh_instance.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.4, 0.6, 0.4)
	floor_mesh_instance.material_override = floor_mat
	floor_body.add_child(floor_mesh_instance)

	floor_body.position = Vector3(0, -0.1, 0)
	add_child(floor_body)

	print("StaticBody3D (정적 바디):")
	print("  - 물리 엔진이 움직이지 않는 오브젝트")
	print("  - 다른 물체가 충돌하면 튕겨냄")
	print("  - 벽, 바닥, 지형, 건물 등에 사용")
	print("  - CPU 비용이 가장 적음 (움직임 계산 없음)")
	print("")

	print("StaticBody3D 주요 속성:")
	print("  physics_material_override -> 마찰/반발력 설정")
	print("  constant_linear_velocity  -> 일정 속도로 이동하는 것처럼")
	print("  constant_angular_velocity -> 일정 각속도로 회전하는 것처럼")
	print("  -> 컨베이어 벨트 구현에 유용!")
	print("")

	# 컨베이어 벨트 예시
	var conveyor := StaticBody3D.new()
	conveyor.name = "Conveyor"
	conveyor.constant_linear_velocity = Vector3(3, 0, 0)  # X 방향으로 밀어냄

	var conveyor_col := CollisionShape3D.new()
	var conveyor_shape := BoxShape3D.new()
	conveyor_shape.size = Vector3(10, 0.2, 2)
	conveyor_col.shape = conveyor_shape
	conveyor.add_child(conveyor_col)
	conveyor.position = Vector3(0, 0.3, 5)
	add_child(conveyor)

	print("컨베이어 벨트 예시:")
	print("  conveyor.constant_linear_velocity = Vector3(3, 0, 0)")
	print("  -> 위의 RigidBody3D를 X축 방향으로 밀어냄")

	# ============================================
	# 3. RigidBody3D (강체)
	# ============================================
	print("\n--- 3. RigidBody3D ---\n")

	# 코드로 RigidBody3D 생성 (떨어지는 상자)
	var box_body := RigidBody3D.new()
	box_body.name = "FallingBox"
	box_body.mass = 2.0
	box_body.position = Vector3(0, 5, 0)

	var box_collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	box_collision.shape = box_shape
	box_body.add_child(box_collision)

	var box_mesh := MeshInstance3D.new()
	var box_mesh_res := BoxMesh.new()
	box_mesh_res.size = Vector3(1, 1, 1)
	box_mesh.mesh = box_mesh_res
	var box_mat := StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.8, 0.3, 0.2)
	box_mesh.material_override = box_mat
	box_body.add_child(box_mesh)

	add_child(box_body)

	print("RigidBody3D (강체):")
	print("  - 물리 엔진이 이동과 회전을 제어")
	print("  - 중력, 충돌, 반발력 자동 계산")
	print("  - 상자, 공, 파편, 아이템 등에 사용")
	print("")

	print("RigidBody3D 주요 속성:")
	print("  mass = %.1f           -> 질량 (kg)" % box_body.mass)
	print("  gravity_scale = %.1f   -> 중력 배율 (0=무중력)" % box_body.gravity_scale)
	print("  linear_damp = %.1f     -> 선형 감쇠 (공기 저항)" % box_body.linear_damp)
	print("  angular_damp = %.1f    -> 회전 감쇠" % box_body.angular_damp)
	print("  freeze = false        -> true면 물리 일시정지")
	print("")

	# 속도 직접 설정
	print("속도 설정:")
	print("  body.linear_velocity = Vector3(5, 10, 0)  # 선속도")
	print("  body.angular_velocity = Vector3(0, 3, 0)  # 각속도")
	print("")

	# 힘과 임펄스
	print("힘과 임펄스:")
	print("  # 지속적인 힘 (매 프레임, _physics_process에서)")
	print("  body.apply_force(Vector3(0, 100, 0))          # 힘 적용")
	print("  body.apply_force(force, local_offset)         # 특정 위치에 힘")
	print("  body.apply_torque(Vector3(0, 10, 0))          # 토크 (회전력)")
	print("")
	print("  # 순간적인 충격 (한 번)")
	print("  body.apply_impulse(Vector3(0, 10, 0))         # 임펄스")
	print("  body.apply_impulse(impulse, local_offset)     # 특정 위치에 임펄스")
	print("  body.apply_torque_impulse(Vector3(0, 5, 0))   # 토크 임펄스")
	print("")

	print("힘 vs 임펄스:")
	print("  힘(Force):      지속적 (로켓 추진, 바람)")
	print("  임펄스(Impulse): 순간적 (총알 충격, 점프, 폭발)")

	# ============================================
	# 4. RigidBody3D freeze 모드
	# ============================================
	print("\n--- 4. RigidBody3D 모드 ---\n")

	print("freeze 모드:")
	print("  body.freeze = true  -> 물리 시뮬레이션 중지")
	print("")
	print("  freeze_mode:")
	print("  FREEZE_MODE_STATIC    -> StaticBody3D처럼 동작")
	print("  FREEZE_MODE_KINEMATIC -> AnimatableBody3D처럼 동작")
	print("")

	print("continuous_cd (연속 충돌 감지):")
	print("  body.continuous_cd = true")
	print("  -> 빠른 오브젝트가 벽을 뚫는 것 방지")
	print("  -> 총알, 빠른 공 등에 사용")
	print("  -> 성능 비용 있음, 필요할 때만!")
	print("")

	print("can_sleep:")
	print("  body.can_sleep = true  (기본)")
	print("  -> 오랫동안 안 움직이면 자동 슬립 (성능 최적화)")
	print("  -> 접촉/충격 시 자동으로 깨어남")

	# ============================================
	# 5. RigidBody3D 시그널
	# ============================================
	print("\n--- 5. RigidBody3D 시그널 ---\n")

	print("주요 시그널:")
	print("  body_entered(body: Node)    -> 다른 물리체와 처음 충돌")
	print("  body_exited(body: Node)     -> 충돌 끝남")
	print("  body_shape_entered(...)     -> 특정 shape와 충돌")
	print("  body_shape_exited(...)      -> 특정 shape 충돌 끝")
	print("")
	print("  ** contact_monitor = true 필요! **")
	print("  ** max_contacts_reported > 0 필요! **")
	print("")

	# contact_monitor 설정
	box_body.contact_monitor = true
	box_body.max_contacts_reported = 4

	print("충돌 감지 활성화:")
	print("  body.contact_monitor = true")
	print("  body.max_contacts_reported = 4")
	print("")

	print("시그널 연결 코드:")
	print("""  func _ready():
      body.body_entered.connect(_on_body_entered)

  func _on_body_entered(other_body: Node):
      print("충돌! ", other_body.name)
      if other_body.is_in_group("breakable"):
          other_body.queue_free()""")

	# ============================================
	# 6. PhysicsMaterial (물리 머티리얼)
	# ============================================
	print("\n--- 6. PhysicsMaterial ---\n")

	# 물리 머티리얼 생성
	var physics_mat := PhysicsMaterial.new()
	physics_mat.friction = 0.8       # 마찰력 (0=미끄러움, 1=거침)
	physics_mat.bounce = 0.5         # 반발력 (0=안 튕김, 1=완전 탄성)
	physics_mat.rough = false        # true면 항상 거친 쪽 마찰 사용
	physics_mat.absorbent = false    # true면 항상 흡수 쪽 반발 사용

	box_body.physics_material_override = physics_mat

	print("PhysicsMaterial:")
	print("  friction = %.1f  (마찰력: 0=얼음, 1=고무)" % physics_mat.friction)
	print("  bounce = %.1f    (반발력: 0=진흙, 1=슈퍼볼)" % physics_mat.bounce)
	print("  rough = false    (true: 거친 쪽 우선)")
	print("  absorbent = false (true: 흡수 쪽 우선)")
	print("")

	print("재질별 예시:")
	print("  얼음:  friction=0.05, bounce=0.0")
	print("  나무:  friction=0.5,  bounce=0.2")
	print("  고무:  friction=0.9,  bounce=0.8")
	print("  금속:  friction=0.3,  bounce=0.3")
	print("  공:    friction=0.6,  bounce=0.9")

	# ============================================
	# 7. CharacterBody3D (캐릭터 바디)
	# ============================================
	print("\n--- 7. CharacterBody3D ---\n")

	print("CharacterBody3D:")
	print("  - 코드로 직접 이동을 제어")
	print("  - move_and_slide()로 충돌 처리")
	print("  - 중력, 이동 속도 등을 직접 계산")
	print("  - 플레이어 캐릭터, NPC에 사용")
	print("")

	print("CharacterBody3D 주요 속성:")
	print("  velocity: Vector3         -> 현재 속도 벡터")
	print("  motion_mode:")
	print("    MOTION_MODE_GROUNDED    -> 바닥 기반 (FPS, TPS)")
	print("    MOTION_MODE_FLOATING    -> 부유 (우주, 수중)")
	print("")
	print("  up_direction = Vector3.UP -> '위' 방향 (경사면 기준)")
	print("  floor_max_angle = 45도    -> 걸을 수 있는 최대 경사")
	print("  floor_snap_length = 0.1   -> 바닥에 붙는 거리")
	print("  floor_stop_on_slope = true -> 경사에서 미끄러지지 않음")
	print("")

	# move_and_slide 기본 패턴
	print("move_and_slide() 기본 패턴:")
	print("""  extends CharacterBody3D

  var speed = 5.0
  var gravity = 9.8

  func _physics_process(delta):
      # 중력 적용
      if not is_on_floor():
          velocity.y -= gravity * delta

      # 입력으로 이동 방향 계산
      var input_dir = Input.get_vector("left", "right", "up", "down")
      var direction = Vector3(input_dir.x, 0, input_dir.y)
      velocity.x = direction.x * speed
      velocity.z = direction.z * speed

      # 이동 + 충돌 처리
      move_and_slide()""")
	print("")

	print("is_on_floor() / is_on_wall() / is_on_ceiling():")
	print("  move_and_slide() 후에 사용 가능!")
	print("  is_on_floor()   -> 바닥에 서 있는지")
	print("  is_on_wall()    -> 벽에 닿아 있는지")
	print("  is_on_ceiling() -> 천장에 닿아 있는지")

	# ============================================
	# 8. CharacterBody3D 충돌 정보
	# ============================================
	print("\n--- 8. CharacterBody3D 충돌 정보 ---\n")

	print("move_and_slide() 후 충돌 정보:")
	print("""  move_and_slide()

  # 충돌 횟수
  var collision_count = get_slide_collision_count()

  for i in range(collision_count):
      var collision = get_slide_collision(i)
      print("충돌 대상: ", collision.get_collider().name)
      print("충돌 위치: ", collision.get_position())
      print("충돌 법선: ", collision.get_normal())
      print("충돌 깊이: ", collision.get_depth())""")
	print("")

	print("get_last_slide_collision():")
	print("  마지막 충돌 정보만 빠르게 가져오기")
	print("  충돌이 없으면 null 반환")

	# ============================================
	# 9. AnimatableBody3D (이동 플랫폼)
	# ============================================
	print("\n--- 9. AnimatableBody3D ---\n")

	print("AnimatableBody3D:")
	print("  - 코드나 애니메이션으로 이동하는 물리체")
	print("  - 위의 캐릭터를 함께 밀어줌 (이동 플랫폼)")
	print("  - StaticBody3D처럼 동작하지만 이동 가능")
	print("")

	print("이동 플랫폼 예시:")
	print("""  extends AnimatableBody3D

  var speed = 2.0
  var distance = 5.0
  var start_pos: Vector3

  func _ready():
      start_pos = position

  func _physics_process(delta):
      var t = sin(Time.get_ticks_msec() * 0.001 * speed) * 0.5 + 0.5
      position = start_pos.lerp(start_pos + Vector3(0, distance, 0), t)""")
	print("")

	print("sync_to_physics:")
	print("  animatable_body.sync_to_physics = true")
	print("  -> 물리 프레임과 동기화 (더 정확한 상호작용)")

	# ============================================
	# 10. 여러 물리체를 한 번에 생성
	# ============================================
	print("\n--- 10. 여러 물리체 생성 ---\n")

	# 여러 RigidBody3D 상자 생성
	var box_count := 5
	for i in range(box_count):
		var rigid := RigidBody3D.new()
		rigid.name = "Box_%d" % i
		rigid.mass = 1.0 + i * 0.5
		rigid.position = Vector3(
			(i - box_count / 2.0) * 1.5,
			3.0 + i * 1.5,
			0
		)

		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3.ONE
		col.shape = shape
		rigid.add_child(col)

		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3.ONE
		mi.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(
			float(i) / box_count,
			0.5,
			1.0 - float(i) / box_count
		)
		mi.material_override = mat
		rigid.add_child(mi)

		add_child(rigid)

	print("상자 %d개 생성 완료!" % box_count)
	print("  각각 다른 높이에서 떨어져 바닥에 쌓임")
	print("  질량: 1.0 ~ 3.0 kg")
	print("")

	# 구도 추가
	var sphere_body := RigidBody3D.new()
	sphere_body.name = "BouncyBall"
	sphere_body.mass = 0.5
	sphere_body.position = Vector3(3, 8, 0)

	var sphere_col := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.5
	sphere_col.shape = sphere_shape
	sphere_body.add_child(sphere_col)

	var sphere_mi := MeshInstance3D.new()
	sphere_mi.mesh = SphereMesh.new()
	sphere_body.add_child(sphere_mi)

	# 탄성 있는 물리 머티리얼
	var bouncy_mat := PhysicsMaterial.new()
	bouncy_mat.bounce = 0.9
	sphere_body.physics_material_override = bouncy_mat

	add_child(sphere_body)
	print("탄성 공 생성! (bounce = 0.9)")

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 5, 12)
	cam.look_at(Vector3(0, 2, 0))
	cam.make_current()
	add_child(cam)

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. StaticBody3D: 안 움직임 (벽, 바닥) - 가장 저렴")
	print("2. RigidBody3D: 물리 시뮬레이션 (상자, 공) - apply_force/impulse")
	print("3. CharacterBody3D: 코드 제어 (플레이어) - move_and_slide()")
	print("4. AnimatableBody3D: 이동 플랫폼 - 캐릭터를 함께 이동")
	print("5. 반드시 CollisionShape3D 자식이 필요!")
	print("6. PhysicsMaterial: 마찰(friction)과 반발(bounce) 설정")
	print("7. contact_monitor + max_contacts_reported: RigidBody3D 충돌 감지")
	print("8. continuous_cd: 빠른 물체의 벽 관통 방지")
