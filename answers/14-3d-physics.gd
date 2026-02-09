# 챕터 14: 3D 물리 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - CollisionShape3D와 다양한 충돌 형태 (Box, Sphere, Capsule 등)
# - RigidBody3D에 힘과 충격 적용
# - CharacterBody3D로 3D 캐릭터 이동 구현
# - Area3D로 영역 감지 (트리거 존)
# - RayCast3D로 광선 충돌 검사
# - 충돌 레이어/마스크 시스템 (3D)

extends Node3D


func _ready():
	print("=== 챕터 14: 3D 물리 ===\n")

	# 연습 1: CollisionShape3D 충돌 형태
	_exercise_1_collision_shapes()

	# 연습 2: RigidBody3D 힘 적용
	_exercise_2_rigidbody_forces()

	# 연습 3: CharacterBody3D 이동
	_exercise_3_character_body_movement()

	# 연습 4: Area3D 영역 감지
	_exercise_4_area3d_detection()

	# 연습 5: RayCast3D 광선 검사
	_exercise_5_raycast3d()

	# 연습 6: 충돌 레이어/마스크 설정
	_exercise_6_collision_layers()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: CollisionShape3D 6종 (Box, Sphere, Capsule, Cylinder, Convex, Concave) 설명 완료")
	print("결과 2: RigidBody3D 힘/충격/토크 적용 구현 완료")
	print("결과 3: CharacterBody3D 3D 이동 (velocity + move_and_slide) 구현 완료")
	print("결과 4: Area3D 영역 감지 (진입/퇴장 시그널) 구현 완료")
	print("결과 5: RayCast3D 광선 충돌 검사 구현 완료")
	print("결과 6: 충돌 레이어/마스크 3D 설정 완료")


# ==============================================================================
# 연습 1: CollisionShape3D - 다양한 3D 충돌 형태를 생성하고
#          각 형태의 특성을 이해하세요.
# ==============================================================================
func _exercise_1_collision_shapes():
	# 풀이: CollisionShape3D는 물리 바디(RigidBody3D, CharacterBody3D 등)의
	#       자식으로 배치하여 충돌 영역을 정의합니다.
	#       shape 속성에 Shape3D 리소스를 할당합니다.
	#       간단한 형태일수록 물리 연산이 빠릅니다 (Sphere > Box > Capsule > Convex > Concave).

	print("연습 1: CollisionShape3D 충돌 형태")

	# 1) BoxShape3D - 직육면체
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(2.0, 1.0, 1.5)
	print("  1) BoxShape3D:")
	print("    size: %s" % box_shape.size)
	print("    용도: 상자, 벽, 블록, 바닥")
	print()

	# 2) SphereShape3D - 구
	# 풀이: 가장 빠른 충돌 검사. 모든 방향에서 균일한 충돌 범위.
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.5
	print("  2) SphereShape3D:")
	print("    radius: %.1f" % sphere_shape.radius)
	print("    용도: 구슬, 폭탄, 간단한 감지 범위 (가장 빠름)")
	print()

	# 3) CapsuleShape3D - 캡슐
	# 풀이: 캐릭터 충돌에 가장 적합. 모서리가 둥글어 경사면에서 자연스럽게 슬라이딩.
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.4
	capsule_shape.height = 1.8
	print("  3) CapsuleShape3D:")
	print("    radius: %.1f, height: %.1f" % [capsule_shape.radius, capsule_shape.height])
	print("    용도: 캐릭터 컨트롤러 (경사면 슬라이딩에 유리)")
	print()

	# 4) CylinderShape3D - 원통
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = 0.5
	cylinder_shape.height = 2.0
	print("  4) CylinderShape3D:")
	print("    radius: %.1f, height: %.1f" % [cylinder_shape.radius, cylinder_shape.height])
	print("    용도: 기둥, 나무 줄기, 원통형 장애물")
	print()

	# 5) ConvexPolygonShape3D - 볼록 다면체
	# 풀이: MeshInstance3D의 메시에서 자동 생성 가능. 오목한 부분은 표현 불가.
	var convex_shape := ConvexPolygonShape3D.new()
	convex_shape.points = PackedVector3Array([
		Vector3(0, 1, 0), Vector3(-1, 0, -1), Vector3(1, 0, -1),
		Vector3(1, 0, 1), Vector3(-1, 0, 1)
	])
	print("  5) ConvexPolygonShape3D:")
	print("    points: %d개의 정점" % convex_shape.points.size())
	print("    용도: 불규칙 볼록 형태 (메시에서 자동 생성)")
	print()

	# 6) ConcavePolygonShape3D - 오목 다면체
	# 풀이: 정적(static) 오브젝트에만 사용 가능. 성능 비용이 가장 높음.
	var concave_shape := ConcavePolygonShape3D.new()
	concave_shape.set_faces(PackedVector3Array([
		Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0.5, 1, 0),
		Vector3(0, 0, 0), Vector3(0.5, 1, 0), Vector3(0, 0, 1),
	]))
	print("  6) ConcavePolygonShape3D:")
	print("    faces: %d개의 정점 (삼각형)" % concave_shape.get_faces().size())
	print("    용도: 복잡한 지형 (StaticBody3D 전용, 가장 느림)")
	print()

	# CollisionShape3D 노드로 조합
	# 풀이: 물리 바디에 여러 CollisionShape3D를 자식으로 추가하여
	#       복합 충돌 형태를 만들 수 있습니다.
	var static_body := StaticBody3D.new()
	static_body.name = "CompoundBody"
	add_child(static_body)

	var col_shape_1 := CollisionShape3D.new()
	col_shape_1.shape = box_shape
	static_body.add_child(col_shape_1)

	var col_shape_2 := CollisionShape3D.new()
	col_shape_2.shape = sphere_shape
	col_shape_2.position = Vector3(0, 1.0, 0)
	static_body.add_child(col_shape_2)

	print("  복합 충돌 형태:")
	print("    StaticBody3D")
	print("    +-- CollisionShape3D (BoxShape3D) - 몸통")
	print("    +-- CollisionShape3D (SphereShape3D) - 머리")
	print()

	# 성능 순위
	print("  충돌 형태 성능 순위 (빠름 -> 느림):")
	print("    1. SphereShape3D (가장 빠름)")
	print("    2. BoxShape3D")
	print("    3. CapsuleShape3D")
	print("    4. CylinderShape3D")
	print("    5. ConvexPolygonShape3D")
	print("    6. ConcavePolygonShape3D (가장 느림, 정적만)")

	print("연습 1 완료: CollisionShape3D 충돌 형태\n")


# ==============================================================================
# 연습 2: RigidBody3D 힘 적용 - 물리 시뮬레이션 오브젝트를 만들고
#          힘(force), 충격(impulse), 토크(torque)를 적용하세요.
# ==============================================================================
func _exercise_2_rigidbody_forces():
	# 풀이: RigidBody3D는 Godot 물리 엔진이 이동과 회전을 제어하는 노드입니다.
	#       apply_force(): 지속적인 힘 (매 프레임 호출)
	#       apply_impulse(): 순간적 충격 (한 번 호출)
	#       apply_torque(): 지속적 회전력
	#       apply_torque_impulse(): 순간적 회전 충격
	#       mass(질량), gravity_scale(중력 배율), linear_damp(감속)를 설정합니다.

	print("연습 2: RigidBody3D 힘 적용")

	# 물리 상자 생성
	var rigid_box := RigidBody3D.new()
	rigid_box.name = "PhysicsBox"
	rigid_box.mass = 2.0                    # 2kg
	rigid_box.gravity_scale = 1.0           # 기본 중력
	rigid_box.linear_damp = 0.1             # 공기 저항
	rigid_box.angular_damp = 0.5            # 회전 감쇠
	rigid_box.position = Vector3(0, 5, 0)

	# 충돌 형태 추가
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	col.shape = box_shape
	rigid_box.add_child(col)

	# 시각적 메시
	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)
	mesh_inst.mesh = box_mesh
	rigid_box.add_child(mesh_inst)

	add_child(rigid_box)

	print("  물리 상자 생성:")
	print("    mass: %.1f kg" % rigid_box.mass)
	print("    gravity_scale: %.1f" % rigid_box.gravity_scale)
	print("    linear_damp: %.1f" % rigid_box.linear_damp)
	print("    angular_damp: %.1f" % rigid_box.angular_damp)
	print("    position: %s" % rigid_box.position)
	print()

	# 힘(Force) 적용 - 지속적인 밀기
	# 풀이: apply_force(force, position)에서 position은 로컬 좌표의 적용점입니다.
	#       위치를 지정하면 토크(회전)도 함께 발생합니다.
	rigid_box.apply_force(Vector3(0, 50, 0))  # 위쪽으로 밀기
	print("  apply_force(Vector3(0, 50, 0)):")
	print("    위쪽으로 지속적인 힘 50N 적용")
	print()

	# 충격(Impulse) 적용 - 순간적 충격
	# 풀이: apply_impulse(impulse, position)는 즉시 속도를 변경합니다.
	#       점프, 폭발, 타격 등 순간적 효과에 적합합니다.
	rigid_box.apply_impulse(Vector3(5, 10, 0))  # 오른쪽+위로 점프
	print("  apply_impulse(Vector3(5, 10, 0)):")
	print("    오른쪽 + 위쪽 순간 충격 적용")
	print()

	# 중심에서 벗어난 충격 (회전 유발)
	rigid_box.apply_impulse(Vector3(3, 0, 0), Vector3(0, 0.5, 0))
	print("  apply_impulse(force, offset_pos):")
	print("    중심 위쪽에 힘 적용 -> 회전 발생")
	print()

	# 토크(Torque) - 회전력
	# 풀이: apply_torque()는 각 축을 중심으로 회전력을 적용합니다.
	rigid_box.apply_torque(Vector3(0, 10, 0))  # Y축 회전
	print("  apply_torque(Vector3(0, 10, 0)):")
	print("    Y축 기준 지속적 회전력")
	print()

	# 순간 회전 충격
	rigid_box.apply_torque_impulse(Vector3(5, 0, 0))  # X축 회전
	print("  apply_torque_impulse(Vector3(5, 0, 0)):")
	print("    X축 기준 순간 회전 충격")
	print()

	# 물리 구 생성 (다른 특성)
	var rigid_sphere := RigidBody3D.new()
	rigid_sphere.name = "PhysicsBall"
	rigid_sphere.mass = 0.5
	rigid_sphere.gravity_scale = 1.5        # 무거워 보이게
	rigid_sphere.physics_material_override = PhysicsMaterial.new()
	rigid_sphere.physics_material_override.bounce = 0.8   # 높은 반발력
	rigid_sphere.physics_material_override.friction = 0.3
	rigid_sphere.position = Vector3(3, 3, 0)

	var sphere_col := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.5
	sphere_col.shape = sphere_shape
	rigid_sphere.add_child(sphere_col)
	add_child(rigid_sphere)

	print("  물리 공 생성 (PhysicsMaterial):")
	print("    mass: %.1f, gravity_scale: %.1f" % [rigid_sphere.mass, rigid_sphere.gravity_scale])
	print("    bounce: %.1f (반발력)" % rigid_sphere.physics_material_override.bounce)
	print("    friction: %.1f (마찰)" % rigid_sphere.physics_material_override.friction)
	print()

	# Force vs Impulse 비교
	print("  Force vs Impulse 비교:")
	print("    +----------------+-------------------+-------------------+")
	print("    | 속성           | Force (힘)        | Impulse (충격)    |")
	print("    +----------------+-------------------+-------------------+")
	print("    | 적용 방식      | 매 프레임 누적    | 한 번에 즉시      |")
	print("    | 호출 위치      | _physics_process  | 이벤트/시그널     |")
	print("    | 용도           | 엔진, 바람, 자석  | 점프, 폭발, 타격  |")
	print("    | delta 필요     | 자동 적용         | 불필요            |")
	print("    +----------------+-------------------+-------------------+")

	print("연습 2 완료: RigidBody3D 힘 적용\n")


# ==============================================================================
# 연습 3: CharacterBody3D 이동 - 3D 캐릭터의 기본 이동 로직을
#          velocity와 move_and_slide()로 구현하세요.
# ==============================================================================
func _exercise_3_character_body_movement():
	# 풀이: CharacterBody3D는 개발자가 직접 velocity를 제어하는 물리 바디입니다.
	#       move_and_slide()를 호출하면 velocity 기반으로 이동하며
	#       충돌 시 표면을 따라 슬라이딩합니다.
	#       up_direction(기본 Y-up)을 기준으로 is_on_floor(), is_on_wall()을 판단합니다.
	#       3D에서 이동 방향은 입력을 카메라/캐릭터 기준으로 변환해야 합니다.

	print("연습 3: CharacterBody3D 3D 이동")

	# CharacterBody3D 생성
	var character := CharacterBody3D.new()
	character.name = "Player3D"
	character.position = Vector3(0, 0.9, 0)
	character.up_direction = Vector3.UP     # 바닥 판정 기준

	# 충돌 형태 (캡슐)
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	col.shape = capsule
	character.add_child(col)

	# 시각적 메시
	var mesh_inst := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.8
	mesh_inst.mesh = capsule_mesh
	character.add_child(mesh_inst)

	add_child(character)

	print("  CharacterBody3D 생성:")
	print("    position: %s" % character.position)
	print("    up_direction: %s" % character.up_direction)
	print("    collision: CapsuleShape3D (r=0.4, h=1.8)")
	print()

	# 이동 로직 설명 (실제로는 _physics_process에서 실행)
	print("  3D 이동 로직 (_physics_process에서 사용):")
	print("  ```gdscript")
	print("  const SPEED = 5.0")
	print("  const JUMP_VELOCITY = 4.5")
	print("  var gravity = ProjectSettings.get_setting(\"physics/3d/default_gravity\")")
	print("")
	print("  func _physics_process(delta):")
	print("      # 중력 적용")
	print("      if not is_on_floor():")
	print("          velocity.y -= gravity * delta")
	print("")
	print("      # 점프")
	print("      if Input.is_action_just_pressed(\"ui_accept\") and is_on_floor():")
	print("          velocity.y = JUMP_VELOCITY")
	print("")
	print("      # 이동 입력 -> 방향 벡터")
	print("      var input_dir = Input.get_vector(\"ui_left\", \"ui_right\",")
	print("                                        \"ui_up\", \"ui_down\")")
	print("      var direction = (transform.basis * Vector3(input_dir.x, 0,")
	print("                                                  input_dir.y)).normalized()")
	print("")
	print("      if direction:")
	print("          velocity.x = direction.x * SPEED")
	print("          velocity.z = direction.z * SPEED")
	print("      else:")
	print("          velocity.x = move_toward(velocity.x, 0, SPEED)")
	print("          velocity.z = move_toward(velocity.z, 0, SPEED)")
	print("")
	print("      move_and_slide()")
	print("  ```")
	print()

	# 입력 -> 3D 방향 변환 시뮬레이션
	# 풀이: 2D 입력(WASD)을 3D 방향으로 변환합니다.
	#       transform.basis를 곱하면 캐릭터의 현재 회전을 반영합니다.
	var input_dir := Vector2(1.0, 0.0)  # 오른쪽 입력 시뮬레이션
	var move_direction := (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print("  입력 -> 3D 방향 변환:")
	print("    2D 입력: %s (오른쪽)" % input_dir)
	print("    3D 방향: %s" % move_direction)
	print()

	# move_and_slide 충돌 정보
	print("  move_and_slide() 충돌 정보:")
	print("    is_on_floor(): 바닥에 서 있는지")
	print("    is_on_wall(): 벽에 닿았는지")
	print("    is_on_ceiling(): 천장에 닿았는지")
	print("    get_slide_collision_count(): 충돌 수")
	print("    get_slide_collision(i): KinematicCollision3D 객체")
	print("    get_floor_normal(): 바닥 법선 벡터")
	print("    get_wall_normal(): 벽 법선 벡터")

	print("연습 3 완료: CharacterBody3D 3D 이동\n")


# ==============================================================================
# 연습 4: Area3D 감지 - 트리거 존을 만들어 오브젝트 진입/퇴장을
#          감지하세요.
# ==============================================================================
func _exercise_4_area3d_detection():
	# 풀이: Area3D는 물리적 충돌 없이 영역 겹침만 감지하는 노드입니다.
	#       body_entered/body_exited: PhysicsBody3D(RigidBody3D, CharacterBody3D 등) 감지
	#       area_entered/area_exited: 다른 Area3D 감지
	#       아이템 수집, 데미지 존, 트리거 등에 사용합니다.
	#       monitoring = true로 감지 활성화, monitorable = true로 피감지 활성화.

	print("연습 4: Area3D 영역 감지")

	# 아이템 수집 영역
	var pickup_zone := Area3D.new()
	pickup_zone.name = "CoinPickup"
	pickup_zone.position = Vector3(5, 0.5, 0)
	pickup_zone.monitoring = true       # 다른 노드 감지
	pickup_zone.monitorable = true      # 다른 Area3D에게 감지됨

	var pickup_col := CollisionShape3D.new()
	var pickup_shape := SphereShape3D.new()
	pickup_shape.radius = 1.0
	pickup_col.shape = pickup_shape
	pickup_zone.add_child(pickup_col)

	# 시각적 표현
	var coin_mesh := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = 0.3
	cylinder_mesh.bottom_radius = 0.3
	cylinder_mesh.height = 0.05
	coin_mesh.mesh = cylinder_mesh
	var coin_mat := StandardMaterial3D.new()
	coin_mat.albedo_color = Color.GOLD
	coin_mesh.material_override = coin_mat
	pickup_zone.add_child(coin_mesh)

	add_child(pickup_zone)

	print("  아이템 수집 영역 (CoinPickup):")
	print("    position: %s" % pickup_zone.position)
	print("    감지 범위: SphereShape3D (r=%.1f)" % pickup_shape.radius)
	print("    monitoring: %s" % pickup_zone.monitoring)
	print("    monitorable: %s" % pickup_zone.monitorable)
	print()

	# 시그널 연결
	# 풀이: body_entered는 PhysicsBody3D(플레이어 등)가 영역에 진입할 때 발생합니다.
	pickup_zone.body_entered.connect(_on_coin_body_entered)
	pickup_zone.body_exited.connect(_on_coin_body_exited)
	print("  시그널 연결:")
	print("    body_entered -> _on_coin_body_entered")
	print("    body_exited -> _on_coin_body_exited")
	print()

	# 데미지 존 (Area3D)
	var damage_zone := Area3D.new()
	damage_zone.name = "LavaZone"
	damage_zone.position = Vector3(-5, 0, 0)

	var dmg_col := CollisionShape3D.new()
	var dmg_shape := BoxShape3D.new()
	dmg_shape.size = Vector3(4, 0.5, 4)
	dmg_col.shape = dmg_shape
	damage_zone.add_child(dmg_col)
	add_child(damage_zone)

	# 풀이: body_entered에서 대미지를 적용하고,
	#       체류 중 지속 대미지는 get_overlapping_bodies()로 확인합니다.
	damage_zone.body_entered.connect(func(body: Node3D):
		print("    [LavaZone] %s 진입! 화상 대미지!" % body.name)
		if body.has_method("take_damage"):
			body.take_damage(10)
	)

	print("  데미지 존 (LavaZone):")
	print("    position: %s" % damage_zone.position)
	print("    size: %s" % dmg_shape.size)
	print()

	# 겹침 검사 (수동)
	# 풀이: get_overlapping_bodies()와 get_overlapping_areas()로
	#       현재 영역 안에 있는 노드 목록을 가져올 수 있습니다.
	print("  수동 겹침 검사 API:")
	print("    get_overlapping_bodies(): 영역 내 PhysicsBody3D 목록")
	print("    get_overlapping_areas(): 영역 내 Area3D 목록")
	print("    has_overlapping_bodies(): 하나 이상 존재 여부")
	print("    has_overlapping_areas(): 하나 이상 존재 여부")

	print("연습 4 완료: Area3D 영역 감지\n")


# Area3D 시그널 핸들러
func _on_coin_body_entered(body: Node3D):
	print("    [CoinPickup] %s 진입 -> 코인 수집!" % body.name)

func _on_coin_body_exited(body: Node3D):
	print("    [CoinPickup] %s 퇴장" % body.name)


# ==============================================================================
# 연습 5: RayCast3D - 광선을 쏘아 충돌을 검사하고
#          충돌 정보를 활용하세요.
# ==============================================================================
func _exercise_5_raycast3d():
	# 풀이: RayCast3D는 원점에서 target_position까지 광선을 쏘아
	#       첫 번째 충돌을 감지합니다. 바닥 감지, 시야 확인(Line of Sight),
	#       총알 히트 판정, 인터랙션 가능 오브젝트 감지 등에 사용합니다.
	#       enabled = true여야 동작하며, force_raycast_update()로 즉시 갱신 가능합니다.

	print("연습 5: RayCast3D 광선 충돌 검사")

	# 바닥 감지 레이캐스트
	var floor_ray := RayCast3D.new()
	floor_ray.name = "FloorDetector"
	floor_ray.position = Vector3(0, 1.0, 0)
	floor_ray.target_position = Vector3(0, -2.0, 0)  # 아래로 2m
	floor_ray.enabled = true
	add_child(floor_ray)

	print("  바닥 감지 RayCast3D:")
	print("    position: %s" % floor_ray.position)
	print("    target: %s (아래로 2m)" % floor_ray.target_position)
	print("    enabled: %s" % floor_ray.enabled)
	print()

	# 전방 감지 레이캐스트 (시야/인터랙션)
	var forward_ray := RayCast3D.new()
	forward_ray.name = "InteractionRay"
	forward_ray.position = Vector3(0, 1.5, 0)        # 눈 높이
	forward_ray.target_position = Vector3(0, 0, -3.0) # 전방 3m
	forward_ray.enabled = true
	add_child(forward_ray)

	print("  전방 감지 RayCast3D (인터랙션):")
	print("    position: %s (눈 높이)" % forward_ray.position)
	print("    target: %s (전방 3m)" % forward_ray.target_position)
	print()

	# 충돌 정보 활용
	# 풀이: force_raycast_update()를 호출하면 다음 물리 프레임을 기다리지 않고
	#       즉시 레이캐스트를 갱신합니다.
	floor_ray.force_raycast_update()

	print("  RayCast3D 충돌 정보 API:")
	print("    is_colliding(): %s (충돌 여부)" % floor_ray.is_colliding())
	if floor_ray.is_colliding():
		print("    get_collider(): %s" % floor_ray.get_collider())
		print("    get_collision_point(): %s" % floor_ray.get_collision_point())
		print("    get_collision_normal(): %s" % floor_ray.get_collision_normal())
	else:
		print("    (현재 충돌 없음 - 물리 바디 필요)")
	print()

	# 충돌 제외 설정
	# 풀이: add_exception()으로 특정 노드를 레이캐스트 감지에서 제외합니다.
	#       자기 자신의 충돌체를 제외할 때 유용합니다.
	print("  RayCast3D 설정 옵션:")
	print("    add_exception(node): 특정 노드 제외")
	print("    remove_exception(node): 제외 해제")
	print("    clear_exceptions(): 모든 제외 해제")
	print("    collision_mask: 감지할 레이어 설정")
	print("    collide_with_areas: Area3D도 감지할지 (기본 false)")
	print("    collide_with_bodies: PhysicsBody3D 감지 (기본 true)")
	print()

	# 코드로 레이캐스트 (PhysicsDirectSpaceState3D)
	# 풀이: get_world_3d().direct_space_state로 물리 공간에 직접 접근하여
	#       레이캐스트를 수행할 수 있습니다. 일시적/동적 레이캐스트에 적합합니다.
	print("  코드 레이캐스트 (PhysicsDirectSpaceState3D):")
	print("  ```gdscript")
	print("  var space = get_world_3d().direct_space_state")
	print("  var query = PhysicsRayQueryParameters3D.create(")
	print("      from_pos, to_pos)")
	print("  query.collision_mask = 0b0001  # Layer 1만")
	print("  query.collide_with_areas = true")
	print("  var result = space.intersect_ray(query)")
	print("  if result:")
	print("      var hit_pos = result.position")
	print("      var hit_normal = result.normal")
	print("      var hit_collider = result.collider")
	print("  ```")

	print("연습 5 완료: RayCast3D 광선 충돌 검사\n")


# ==============================================================================
# 연습 6: 충돌 레이어/마스크 - 3D 물리 오브젝트의 충돌 레이어와
#          마스크를 설정하여 선택적 충돌을 구현하세요.
# ==============================================================================
func _exercise_6_collision_layers():
	# 풀이: 3D에서도 2D와 동일한 레이어/마스크 시스템을 사용합니다.
	#       Layer: "이 노드가 존재하는 물리 레이어" (자신의 위치)
	#       Mask: "이 노드가 감지/충돌할 레이어" (감지 대상)
	#       A의 Mask에 B의 Layer가 포함되어야 A가 B와 충돌합니다.
	#       set_collision_layer_value(n, bool)로 개별 레이어를 설정합니다.

	print("연습 6: 충돌 레이어/마스크 (3D)")

	# 레이어 구성 계획
	print("  레이어 구성 계획:")
	print("    Layer 1: 플레이어")
	print("    Layer 2: 적 (Enemy)")
	print("    Layer 3: 환경/지형 (Terrain)")
	print("    Layer 4: 아이템 (Items)")
	print("    Layer 5: 투사체 (Projectiles)")
	print("    Layer 6: NPC")
	print("    Layer 7: 트리거 존 (Triggers)")
	print()

	# 플레이어 설정
	var player := CharacterBody3D.new()
	player.name = "Player"
	player.collision_layer = 0
	player.set_collision_layer_value(1, true)  # Layer 1에 존재
	player.collision_mask = 0
	player.set_collision_mask_value(2, true)   # 적과 충돌
	player.set_collision_mask_value(3, true)   # 지형과 충돌
	player.set_collision_mask_value(4, true)   # 아이템 감지
	player.set_collision_mask_value(5, true)   # 투사체 충돌

	var player_col := CollisionShape3D.new()
	player_col.shape = CapsuleShape3D.new()
	player.add_child(player_col)
	add_child(player)

	print("  플레이어 충돌 설정:")
	print("    Layer: 1 (플레이어)")
	print("    Mask: 2,3,4,5 (적, 지형, 아이템, 투사체)")
	print("    collision_layer: %d" % player.collision_layer)
	print("    collision_mask: %d" % player.collision_mask)
	print()

	# 적 설정
	var enemy := CharacterBody3D.new()
	enemy.name = "Enemy"
	enemy.collision_layer = 0
	enemy.set_collision_layer_value(2, true)   # Layer 2에 존재
	enemy.collision_mask = 0
	enemy.set_collision_mask_value(1, true)    # 플레이어와 충돌
	enemy.set_collision_mask_value(3, true)    # 지형과 충돌
	enemy.set_collision_mask_value(5, true)    # 투사체에 맞음

	var enemy_col := CollisionShape3D.new()
	enemy_col.shape = CapsuleShape3D.new()
	enemy.add_child(enemy_col)
	add_child(enemy)

	print("  적 충돌 설정:")
	print("    Layer: 2 (적)")
	print("    Mask: 1,3,5 (플레이어, 지형, 투사체)")
	print()

	# 투사체 설정 (플레이어 총알)
	var bullet := RigidBody3D.new()
	bullet.name = "PlayerBullet"
	bullet.collision_layer = 0
	bullet.set_collision_layer_value(5, true)  # Layer 5에 존재
	bullet.collision_mask = 0
	bullet.set_collision_mask_value(2, true)   # 적만 맞춤
	bullet.set_collision_mask_value(3, true)   # 벽에 충돌

	var bullet_col := CollisionShape3D.new()
	bullet_col.shape = SphereShape3D.new()
	bullet.add_child(bullet_col)
	add_child(bullet)

	print("  플레이어 투사체 충돌 설정:")
	print("    Layer: 5 (투사체)")
	print("    Mask: 2,3 (적, 지형)")
	print("    -> 플레이어(Layer 1)에는 충돌 안 함 (아군 사격 무시)")
	print()

	# 레이어 확인
	print("  레이어 확인:")
	print("    Player Layer 1: %s" % player.get_collision_layer_value(1))
	print("    Player Mask 3: %s" % player.get_collision_mask_value(3))
	print("    Enemy Layer 2: %s" % enemy.get_collision_layer_value(2))
	print("    Bullet Layer 5: %s" % bullet.get_collision_layer_value(5))
	print("    Bullet Mask 1 (플레이어): %s (false = 자기편 안 맞음)" % bullet.get_collision_mask_value(1))
	print()

	# 비트 연산으로 레이어 설정
	# 풀이: collision_layer/mask는 비트 플래그이므로 비트 연산도 가능합니다.
	#       Layer 1 = 0b0001 = 1, Layer 2 = 0b0010 = 2, Layer 3 = 0b0100 = 4
	print("  비트 연산 예시:")
	print("    Layer 1: 0b0001 = %d" % 0b0001)
	print("    Layer 2: 0b0010 = %d" % 0b0010)
	print("    Layer 3: 0b0100 = %d" % 0b0100)
	print("    Layer 1+3: 0b0101 = %d" % 0b0101)
	print("    Mask 2+3+5: 0b10110 = %d" % 0b10110)
	print()

	# 충돌 매트릭스
	print("  충돌 매트릭스:")
	print("    +-----------+------+------+------+------+------+")
	print("    | From\\To   | L1   | L2   | L3   | L4   | L5   |")
	print("    +-----------+------+------+------+------+------+")
	print("    | Player    | -    | O    | O    | O    | O    |")
	print("    | Enemy     | O    | -    | O    | -    | O    |")
	print("    | Terrain   | -    | -    | -    | -    | -    |")
	print("    | Item      | -    | -    | -    | -    | -    |")
	print("    | Bullet    | -    | O    | O    | -    | -    |")
	print("    +-----------+------+------+------+------+------+")

	print("연습 6 완료: 충돌 레이어/마스크 설정\n")
