# Chapter 14 - 3D Physics
# 03-area3d-raycast.gd - Area3D와 레이캐스트
#
# 이 파일에서 배울 내용:
# - Area3D로 영역 감지 (트리거 존)
# - RayCast3D로 직선 충돌 감지
# - ShapeCast3D로 형태 기반 충돌 감지
# - 코드로 물리 쿼리 (PhysicsDirectSpaceState3D)

extends Node3D

func _ready():
	print("=== Area3D와 레이캐스트 ===\n")

	# ============================================
	# 1. Area3D 개요
	# ============================================
	print("--- 1. Area3D 개요 ---\n")

	print("Area3D란?")
	print("  물리적 충돌 없이 '영역 감지'만 하는 노드")
	print("  다른 물체가 들어오고 나가는 것을 감지")
	print("  물리적으로 밀어내지 않음!")
	print("")

	print("활용 예시:")
	print("  - 데미지 영역 (용암, 독가스)")
	print("  - 아이템 수집 범위")
	print("  - 트리거 존 (문 열기, 이벤트 시작)")
	print("  - NPC 대화 범위")
	print("  - 물리 속성 변경 (중력, 바람)")
	print("")

	print("구조:")
	print("  Area3D")
	print("    +-- CollisionShape3D  <- 반드시 필요!")

	# ============================================
	# 2. Area3D 코드 생성
	# ============================================
	print("\n--- 2. Area3D 코드 생성 ---\n")

	# 트리거 영역 생성
	var trigger_area := Area3D.new()
	trigger_area.name = "DamageZone"
	trigger_area.position = Vector3(0, 1, 0)

	var area_col := CollisionShape3D.new()
	var area_shape := BoxShape3D.new()
	area_shape.size = Vector3(4, 2, 4)
	area_col.shape = area_shape
	trigger_area.add_child(area_col)

	# 시각적 표시 (반투명)
	var area_mesh := MeshInstance3D.new()
	var area_mesh_res := BoxMesh.new()
	area_mesh_res.size = Vector3(4, 2, 4)
	area_mesh.mesh = area_mesh_res
	var area_mat := StandardMaterial3D.new()
	area_mat.albedo_color = Color(1, 0, 0, 0.3)
	area_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	area_mesh.material_override = area_mat
	trigger_area.add_child(area_mesh)

	# 레이어/마스크 설정
	trigger_area.set_collision_layer_value(1, false)
	trigger_area.set_collision_layer_value(6, true)  # 트리거 레이어
	trigger_area.set_collision_mask_value(1, true)    # 플레이어 감지

	add_child(trigger_area)

	print("DamageZone Area3D 생성:")
	print("  크기: 4x2x4, 위치: (0, 1, 0)")
	print("  layer: 6 (Trigger)")
	print("  mask: 1 (Player)")

	# ============================================
	# 3. Area3D 시그널
	# ============================================
	print("\n--- 3. Area3D 시그널 ---\n")

	print("바디 감지 시그널:")
	print("  body_entered(body: Node3D)")
	print("    -> PhysicsBody3D가 영역에 들어올 때")
	print("  body_exited(body: Node3D)")
	print("    -> PhysicsBody3D가 영역에서 나갈 때")
	print("")

	print("Area 감지 시그널:")
	print("  area_entered(area: Area3D)")
	print("    -> 다른 Area3D와 겹칠 때")
	print("  area_exited(area: Area3D)")
	print("    -> 다른 Area3D와 분리될 때")
	print("")

	print("시그널 연결 예시:")
	print("""  func _ready():
      $DamageZone.body_entered.connect(_on_damage_zone_entered)
      $DamageZone.body_exited.connect(_on_damage_zone_exited)

  func _on_damage_zone_entered(body: Node3D):
      if body.is_in_group("player"):
          print("플레이어가 데미지 영역에 진입!")
          body.start_taking_damage(10)  # 초당 10 데미지

  func _on_damage_zone_exited(body: Node3D):
      if body.is_in_group("player"):
          print("플레이어가 데미지 영역에서 탈출!")
          body.stop_taking_damage()""")

	# ============================================
	# 4. Area3D 현재 겹치는 오브젝트
	# ============================================
	print("\n--- 4. 겹치는 오브젝트 조회 ---\n")

	print("현재 영역 내의 오브젝트:")
	print("  area.get_overlapping_bodies()  -> Array[Node3D]")
	print("  area.get_overlapping_areas()   -> Array[Area3D]")
	print("")
	print("  area.has_overlapping_bodies()  -> bool")
	print("  area.has_overlapping_areas()   -> bool")
	print("")

	print("활용 예시 (폭발 데미지):")
	print("""  func explode():
      var area = $ExplosionArea
      # 영역 내의 모든 바디에 데미지
      for body in area.get_overlapping_bodies():
          if body.has_method("take_damage"):
              var distance = global_position.distance_to(body.global_position)
              var damage = max_damage * (1.0 - distance / explosion_radius)
              body.take_damage(damage)""")
	print("")

	# monitoring / monitorable
	print("monitoring / monitorable:")
	print("  area.monitoring = true     -> 다른 물체를 감지함")
	print("  area.monitorable = true    -> 다른 Area에 감지됨")
	print("  -> 성능: 감지 필요 없으면 false로!")

	# ============================================
	# 5. Area3D 물리 오버라이드
	# ============================================
	print("\n--- 5. Area3D 물리 오버라이드 ---\n")

	# 중력 변경 영역
	var low_gravity_area := Area3D.new()
	low_gravity_area.name = "LowGravityZone"
	low_gravity_area.position = Vector3(5, 3, 0)

	# 중력 오버라이드 설정
	low_gravity_area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	low_gravity_area.gravity = 2.0          # 기본은 9.8
	low_gravity_area.gravity_direction = Vector3.DOWN

	var lg_col := CollisionShape3D.new()
	var lg_shape := SphereShape3D.new()
	lg_shape.radius = 3.0
	lg_col.shape = lg_shape
	low_gravity_area.add_child(lg_col)

	add_child(low_gravity_area)

	print("물리 오버라이드 (중력, 감쇠):")
	print("  gravity_space_override:")
	print("    SPACE_OVERRIDE_DISABLED  -> 오버라이드 안 함")
	print("    SPACE_OVERRIDE_COMBINE   -> 기존 값과 합산")
	print("    SPACE_OVERRIDE_REPLACE   -> 완전히 대체")
	print("")
	print("  gravity = %.1f (기본 9.8)" % low_gravity_area.gravity)
	print("  gravity_direction = %s" % str(low_gravity_area.gravity_direction))
	print("  gravity_point = false -> true면 중심 방향으로 끌림")
	print("")

	print("  linear_damp_space_override -> 선형 감쇠 오버라이드")
	print("  linear_damp = 0.0 -> 수중 효과 (값 높이면 느려짐)")
	print("  angular_damp_space_override -> 회전 감쇠 오버라이드")
	print("")

	print("활용:")
	print("  물속 (gravity=2.0, linear_damp=5.0)")
	print("  우주 (gravity=0.0)")
	print("  바람 (gravity_direction=Vector3(1,0,0), gravity=3.0)")

	# ============================================
	# 6. RayCast3D (레이캐스트)
	# ============================================
	print("\n--- 6. RayCast3D ---\n")

	# RayCast3D 생성
	var raycast := RayCast3D.new()
	raycast.name = "InteractionRay"
	raycast.position = Vector3(0, 1.5, 0)
	raycast.target_position = Vector3(0, 0, -5)  # 앞쪽으로 5m
	raycast.enabled = true

	# 레이어 마스크 설정
	raycast.collision_mask = 0  # 초기화
	raycast.set_collision_mask_value(3, true)  # 환경만
	raycast.set_collision_mask_value(7, true)  # 상호작용 가능 오브젝트

	add_child(raycast)

	print("RayCast3D:")
	print("  시작점에서 끝점까지 직선을 쏘아 충돌 감지")
	print("  -> 총알 히트 판정, 바닥 감지, 상호작용 등")
	print("")

	print("주요 속성:")
	print("  target_position = %s (로컬 끝점)" % str(raycast.target_position))
	print("  enabled = true       (활성화)")
	print("  collision_mask       (감지할 레이어)")
	print("  collide_with_areas = false (Area3D 감지 여부)")
	print("  collide_with_bodies = true (Body 감지 여부)")
	print("  hit_from_inside = false (내부에서 시작 시 감지)")
	print("  hit_back_faces = true (뒷면 감지)")
	print("")

	print("충돌 결과 확인:")
	print("""  func _physics_process(delta):
      if raycast.is_colliding():
          var collider = raycast.get_collider()       # 충돌한 오브젝트
          var point = raycast.get_collision_point()    # 충돌 위치 (월드)
          var normal = raycast.get_collision_normal()  # 충돌 법선
          var shape = raycast.get_collider_shape()     # 충돌한 shape index

          print("충돌: %s at %s" % [collider.name, point])""")
	print("")

	# 예외 설정
	print("예외 설정 (자기 자신 무시 등):")
	print("  raycast.add_exception(self)        # 특정 오브젝트 무시")
	print("  raycast.remove_exception(node)     # 무시 해제")
	print("  raycast.clear_exceptions()         # 모든 예외 제거")
	print("  raycast.exclude_parent = true      # 부모 자동 무시 (기본)")

	# ============================================
	# 7. RayCast3D 실전 활용
	# ============================================
	print("\n--- 7. RayCast3D 실전 활용 ---\n")

	# 바닥 감지
	print("1) 바닥 감지 레이:")
	print("""  var ground_ray = RayCast3D.new()
  ground_ray.target_position = Vector3(0, -1.2, 0)  # 아래로
  ground_ray.set_collision_mask_value(3, true)  # 환경 레이어

  # 바닥 경사면 확인
  if ground_ray.is_colliding():
      var floor_normal = ground_ray.get_collision_normal()
      var slope_angle = rad_to_deg(floor_normal.angle_to(Vector3.UP))
      print("경사각: ", slope_angle, "도")""")
	print("")

	# 상호작용 레이
	print("2) 상호작용 시스템:")
	print("""  # 카메라 앞으로 3m 레이
  var interact_ray = RayCast3D.new()
  interact_ray.target_position = Vector3(0, 0, -3)

  func _physics_process(delta):
      if interact_ray.is_colliding():
          var obj = interact_ray.get_collider()
          if obj.has_method("get_interaction_text"):
              show_prompt(obj.get_interaction_text())

              if Input.is_action_just_pressed("interact"):
                  obj.interact()""")
	print("")

	# 총알 히트스캔
	print("3) 히트스캔 무기:")
	print("""  func shoot():
      # 카메라 중앙에서 발사
      var space_state = get_world_3d().direct_space_state
      var from = camera.global_position
      var to = from + -camera.global_transform.basis.z * 100.0

      var query = PhysicsRayQueryParameters3D.create(from, to)
      query.collision_mask = 0b0110  # 적 + 환경
      query.exclude = [self]

      var result = space_state.intersect_ray(query)
      if result:
          print("Hit: ", result.collider.name)
          print("Position: ", result.position)
          print("Normal: ", result.normal)""")

	# ============================================
	# 8. ShapeCast3D
	# ============================================
	print("\n--- 8. ShapeCast3D ---\n")

	var shape_cast := ShapeCast3D.new()
	shape_cast.name = "GroundCheck"
	shape_cast.position = Vector3(0, 1, 0)

	# 구 형태로 캐스트
	var cast_shape := SphereShape3D.new()
	cast_shape.radius = 0.4
	shape_cast.shape = cast_shape
	shape_cast.target_position = Vector3(0, -0.5, 0)
	shape_cast.max_results = 4

	add_child(shape_cast)

	print("ShapeCast3D:")
	print("  RayCast3D의 확장판 - 형태를 가진 레이")
	print("  '두꺼운 레이캐스트'처럼 동작")
	print("  -> 캐릭터 바닥 감지, 벽 감지 등에 유용")
	print("")

	print("주요 속성:")
	print("  shape = SphereShape3D (사용할 형태)")
	print("  target_position = %s (캐스트 방향과 거리)" % str(shape_cast.target_position))
	print("  max_results = %d (최대 결과 수)" % shape_cast.max_results)
	print("  margin = 0.0 (여유 거리)")
	print("")

	print("결과 확인:")
	print("""  if shape_cast.is_colliding():
      var count = shape_cast.get_collision_count()
      for i in range(count):
          var collider = shape_cast.get_collider(i)
          var point = shape_cast.get_collision_point(i)
          var normal = shape_cast.get_collision_normal(i)""")
	print("")

	print("RayCast3D vs ShapeCast3D:")
	print("  RayCast3D:   점 -> 점 (가늘음, 놓칠 수 있음)")
	print("  ShapeCast3D: 형태 -> 형태 (넓음, 안정적)")
	print("  -> 바닥 감지에 ShapeCast3D가 더 안정적!")

	# ============================================
	# 9. PhysicsDirectSpaceState3D (코드 쿼리)
	# ============================================
	print("\n--- 9. 코드로 물리 쿼리 ---\n")

	print("PhysicsDirectSpaceState3D:")
	print("  _physics_process()에서 직접 물리 쿼리 수행")
	print("  노드 추가 없이 일회성 쿼리 가능!")
	print("")

	print("레이 쿼리:")
	print("""  func _physics_process(delta):
      var space = get_world_3d().direct_space_state

      # 레이 쿼리
      var query = PhysicsRayQueryParameters3D.create(
          global_position,                    # from
          global_position + Vector3(0, -10, 0) # to
      )
      query.collision_mask = 0b0100  # 환경만
      query.collide_with_areas = false

      var result = space.intersect_ray(query)
      if result:
          # result = { position, normal, collider, collider_id,
          #            rid, shape, face_index }
          print("바닥 높이: ", result.position.y)""")
	print("")

	print("Shape 쿼리 (영역 내 오브젝트 검색):")
	print("""  var query = PhysicsShapeQueryParameters3D.new()
  query.shape = SphereShape3D.new()
  query.shape.radius = 5.0
  query.transform = Transform3D(Basis(), global_position)
  query.collision_mask = 0b0010  # 적만

  var results = space.intersect_shape(query, 32)  # 최대 32개
  for result in results:
      var enemy = result.collider
      print("범위 내 적: ", enemy.name)""")
	print("")

	print("Point 쿼리 (특정 점에서 겹치는 오브젝트):")
	print("""  var query = PhysicsPointQueryParameters3D.new()
  query.position = global_position
  query.collision_mask = 0b11111111

  var results = space.intersect_point(query, 16)
  for result in results:
      print("이 위치의 오브젝트: ", result.collider.name)""")

	# ============================================
	# 10. 여러 레이캐스트 패턴
	# ============================================
	print("\n--- 10. 레이캐스트 패턴 ---\n")

	# 부채꼴 레이캐스트 (시야각)
	print("부채꼴 레이캐스트 (시야각 체크):")
	print("""  var fov_rays: int = 12
  var fov_angle: float = 90.0  # 시야각
  var fov_distance: float = 10.0

  func check_fov():
      var space = get_world_3d().direct_space_state
      var start_angle = -fov_angle / 2.0

      for i in range(fov_rays):
          var angle = deg_to_rad(start_angle + (fov_angle / fov_rays) * i)
          var dir = -global_transform.basis.z.rotated(Vector3.UP, angle)
          var end = global_position + dir * fov_distance

          var query = PhysicsRayQueryParameters3D.create(
              global_position, end)
          var result = space.intersect_ray(query)
          if result and result.collider.is_in_group("enemy"):
              print("적 발견!")""")

	# ============================================
	# 11. 테스트 씬 구성
	# ============================================

	# 바닥
	var floor := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_col.shape = floor_shape
	floor.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(20, 0.1, 20)
	floor_mi.mesh = floor_mesh
	floor.add_child(floor_mi)
	add_child(floor)

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 8, 10)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	add_child(cam)

	# ============================================
	# 12. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Area3D: 영역 감지 (트리거), 물리적 충돌 없음")
	print("2. body_entered/exited: 바디 진입/퇴장 감지")
	print("3. get_overlapping_bodies(): 현재 영역 내 오브젝트")
	print("4. 물리 오버라이드: 중력, 감쇠 변경 (물속, 우주)")
	print("5. RayCast3D: 직선 충돌 감지 (총, 상호작용)")
	print("6. ShapeCast3D: 형태 기반 캐스트 (넓은 감지)")
	print("7. PhysicsDirectSpaceState3D: 코드로 일회성 쿼리")
	print("8. intersect_ray/shape/point: 3가지 쿼리 방식")
