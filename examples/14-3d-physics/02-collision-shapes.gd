# Chapter 14 - 3D Physics
# 02-collision-shapes.gd - 충돌 형태와 레이어/마스크
#
# 이 파일에서 배울 내용:
# - CollisionShape3D와 다양한 Shape3D 종류
# - 복합 충돌 형태 구성
# - 충돌 레이어(Layer)와 마스크(Mask) 시스템
# - CollisionObject3D 입력 이벤트

extends Node3D

func _ready():
	print("=== 충돌 형태와 레이어/마스크 ===\n")

	# ============================================
	# 1. CollisionShape3D 개요
	# ============================================
	print("--- 1. CollisionShape3D 개요 ---\n")

	print("CollisionShape3D:")
	print("  PhysicsBody3D 또는 Area3D의 자식으로 추가")
	print("  shape 속성에 Shape3D 리소스를 할당")
	print("  하나의 바디에 여러 CollisionShape3D 가능!")
	print("")

	print("노드 구조:")
	print("  RigidBody3D")
	print("    +-- CollisionShape3D (머리)")
	print("    +-- CollisionShape3D (몸통)")
	print("    +-- CollisionShape3D (다리)")
	print("    +-- MeshInstance3D")
	print("")

	print("CollisionShape3D 속성:")
	print("  shape: Shape3D     -> 충돌 형태 리소스")
	print("  disabled: bool     -> true면 충돌 비활성화")
	print("  -> 비활성화해도 노드는 유지 (토글 가능)")

	# ============================================
	# 2. 기본 Shape3D 종류
	# ============================================
	print("\n--- 2. 기본 Shape3D 종류 ---\n")

	# BoxShape3D
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(2, 1, 3)
	print("BoxShape3D (직육면체):")
	print("  size = %s (가로, 세로, 깊이)" % str(box_shape.size))
	print("  -> 상자, 벽, 바닥, 건물 등")
	print("")

	# SphereShape3D
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 1.5
	print("SphereShape3D (구):")
	print("  radius = %.1f" % sphere_shape.radius)
	print("  -> 가장 빠른 충돌 검사! 공, 폭발 범위 등")
	print("")

	# CapsuleShape3D
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.5
	capsule_shape.height = 2.0
	print("CapsuleShape3D (캡슐):")
	print("  radius = %.1f" % capsule_shape.radius)
	print("  height = %.1f (반구 포함 전체 높이)" % capsule_shape.height)
	print("  -> 캐릭터 충돌체로 가장 많이 사용!")
	print("  -> 모서리가 없어 계단/턱에 걸리지 않음")
	print("")

	# CylinderShape3D
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = 0.5
	cylinder_shape.height = 2.0
	print("CylinderShape3D (원기둥):")
	print("  radius = %.1f, height = %.1f" % [cylinder_shape.radius, cylinder_shape.height])
	print("  -> 기둥, 나무, 통 등")
	print("  -> CapsuleShape3D보다 약간 비쌈")
	print("")

	# WorldBoundaryShape3D
	print("WorldBoundaryShape3D (무한 평면):")
	print("  plane = Plane(normal, distance)")
	print("  -> 무한히 넓은 바닥/벽")
	print("  -> 씬의 '킬 플레인'에 적합")
	print("  -> RigidBody3D에서는 사용 불가!")
	print("")

	# ConvexPolygonShape3D
	print("ConvexPolygonShape3D (볼록 다각형):")
	print("  points = PackedVector3Array")
	print("  -> 메시에서 자동 생성 가능")
	print("  -> 구멍이 없는 볼록한 형태만 가능")
	print("  -> 프리미티브보다 비싸지만 정확")
	print("")

	# ConcavePolygonShape3D
	print("ConcavePolygonShape3D (오목 다각형):")
	print("  -> 메시의 삼각형을 그대로 사용")
	print("  -> 복잡한 지형, 건물 내부 등")
	print("  -> 가장 비쌈! StaticBody3D에만 권장!")
	print("  -> RigidBody3D에 사용하면 성능 문제!")

	# ============================================
	# 3. 충돌 형태 성능 비교
	# ============================================
	print("\n--- 3. 성능 비교 (빠름 -> 느림) ---\n")

	print("충돌 검사 속도 순위:")
	print("  1. SphereShape3D       -> 가장 빠름 (단순 거리)")
	print("  2. BoxShape3D          -> 매우 빠름 (AABB)")
	print("  3. CapsuleShape3D      -> 빠름 (캐릭터에 최적)")
	print("  4. CylinderShape3D     -> 보통")
	print("  5. ConvexPolygonShape3D -> 느림")
	print("  6. ConcavePolygonShape3D -> 가장 느림 (정적만!)")
	print("")

	print("선택 가이드:")
	print("  캐릭터:     CapsuleShape3D (부드러운 이동)")
	print("  상자/벽:    BoxShape3D (정확한 모서리)")
	print("  공/범위:    SphereShape3D (최고 성능)")
	print("  복잡한 메시: ConvexPolygonShape3D (움직이는 물체)")
	print("  지형/건물:  ConcavePolygonShape3D (정적만!)")

	# ============================================
	# 4. 코드로 충돌 형태 생성
	# ============================================
	print("\n--- 4. 코드로 충돌 형태 생성 ---\n")

	# 캐릭터 충돌체 (캡슐)
	var character_body := StaticBody3D.new()
	character_body.name = "Character"
	character_body.position = Vector3(-4, 1, 0)

	var char_col := CollisionShape3D.new()
	var char_shape := CapsuleShape3D.new()
	char_shape.radius = 0.4
	char_shape.height = 1.8
	char_col.shape = char_shape
	character_body.add_child(char_col)

	# 시각적 표시
	var char_mesh := MeshInstance3D.new()
	var cap_mesh := CapsuleMesh.new()
	cap_mesh.radius = 0.4
	cap_mesh.height = 1.8
	char_mesh.mesh = cap_mesh
	character_body.add_child(char_mesh)

	add_child(character_body)
	print("캐릭터 충돌체: CapsuleShape3D(r=0.4, h=1.8)")
	print("")

	# 복합 충돌체 (여러 Shape)
	var compound_body := StaticBody3D.new()
	compound_body.name = "CompoundShape"
	compound_body.position = Vector3(0, 1, 0)

	# 몸통 (박스)
	var body_col := CollisionShape3D.new()
	var body_shape := BoxShape3D.new()
	body_shape.size = Vector3(1, 1.2, 0.6)
	body_col.shape = body_shape
	body_col.position = Vector3(0, 0, 0)
	compound_body.add_child(body_col)

	# 머리 (구)
	var head_col := CollisionShape3D.new()
	var head_shape := SphereShape3D.new()
	head_shape.radius = 0.35
	head_col.shape = head_shape
	head_col.position = Vector3(0, 0.9, 0)
	compound_body.add_child(head_col)

	add_child(compound_body)
	print("복합 충돌체:")
	print("  몸통: BoxShape3D at (0, 0, 0)")
	print("  머리: SphereShape3D at (0, 0.9, 0)")
	print("  -> 하나의 PhysicsBody에 여러 CollisionShape!")

	# ============================================
	# 5. 메시에서 충돌 형태 생성
	# ============================================
	print("\n--- 5. 메시에서 충돌 형태 자동 생성 ---\n")

	print("에디터에서:")
	print("  MeshInstance3D 선택 > Mesh 메뉴 > Create Collision Shape")
	print("  옵션:")
	print("    - Trimesh (정확, 느림, 정적만)")
	print("    - Convex (볼록, 빠름)")
	print("    - Multiple Convex (분할, 중간)")
	print("    - Simplified Convex (단순화)")
	print("")

	# 코드로 메시에서 콜리전 생성
	print("코드로 자동 생성:")
	print("""  # MeshInstance3D에서 충돌 형태 생성
  var mesh_instance = $MeshInstance3D

  # 방법 1: Trimesh (정확, 정적용)
  mesh_instance.create_trimesh_collision()
  # -> StaticBody3D + CollisionShape3D가 자동 생성됨

  # 방법 2: Convex (볼록, 움직이는 물체용)
  mesh_instance.create_convex_collision()

  # 방법 3: 직접 Shape 생성
  var shape = mesh_instance.mesh.create_trimesh_shape()
  var col = CollisionShape3D.new()
  col.shape = shape""")

	# ============================================
	# 6. 충돌 레이어와 마스크
	# ============================================
	print("\n--- 6. 충돌 레이어와 마스크 ---\n")

	print("충돌 레이어 시스템 (32개 레이어):")
	print("  collision_layer -> '내가 어떤 레이어에 있는가'")
	print("  collision_mask  -> '나는 어떤 레이어와 충돌하는가'")
	print("")

	print("핵심 규칙:")
	print("  A의 mask가 B의 layer를 포함하거나")
	print("  B의 mask가 A의 layer를 포함하면 충돌!")
	print("  -> 양쪽 중 하나만 설정해도 충돌 발생")
	print("")

	# 레이어 이름 규칙 예시
	print("레이어 이름 규칙 예시:")
	print("  Layer 1:  Player       (플레이어)")
	print("  Layer 2:  Enemy        (적)")
	print("  Layer 3:  Environment  (환경/지형)")
	print("  Layer 4:  Projectile   (투사체)")
	print("  Layer 5:  Pickup       (아이템)")
	print("  Layer 6:  Trigger      (트리거 영역)")
	print("  Layer 7:  Interactable (상호작용 가능)")
	print("")

	# 코드로 레이어/마스크 설정
	print("코드로 설정:")

	# 플레이어 설정
	var player := StaticBody3D.new()
	player.name = "Player"

	# 비트 연산으로 설정 (레이어 1)
	player.collision_layer = 1  # 레이어 1 (0b0001)
	# 환경(3) + 적(2) + 아이템(5)과 충돌
	player.collision_mask = (1 << 1) | (1 << 2) | (1 << 4)

	var player_col := CollisionShape3D.new()
	player_col.shape = CapsuleShape3D.new()
	player.add_child(player_col)
	add_child(player)

	print("  # 플레이어: 레이어 1, 마스크 2+3+5")
	print("  player.collision_layer = 1")
	print("  player.collision_mask = (1 << 1) | (1 << 2) | (1 << 4)")
	print("")

	# 더 직관적인 메서드
	print("직관적인 메서드 (권장):")
	print("  # 특정 레이어 값 설정")
	print("  body.set_collision_layer_value(1, true)   # 레이어 1 ON")
	print("  body.set_collision_layer_value(2, false)  # 레이어 2 OFF")
	print("  body.set_collision_mask_value(3, true)    # 마스크 3 ON")
	print("")

	# 적 설정
	var enemy := StaticBody3D.new()
	enemy.name = "Enemy"
	enemy.set_collision_layer_value(1, false)  # 기본 레이어 1 끄기
	enemy.set_collision_layer_value(2, true)   # 레이어 2 (적)
	enemy.set_collision_mask_value(1, true)    # 플레이어와 충돌
	enemy.set_collision_mask_value(3, true)    # 환경과 충돌
	enemy.set_collision_mask_value(4, true)    # 투사체와 충돌

	var enemy_col := CollisionShape3D.new()
	enemy_col.shape = CapsuleShape3D.new()
	enemy.add_child(enemy_col)
	add_child(enemy)

	print("  # 적: 레이어 2, 마스크 1+3+4")
	print("  enemy.set_collision_layer_value(2, true)")
	print("  enemy.set_collision_mask_value(1, true)  # 플레이어")
	print("  enemy.set_collision_mask_value(3, true)  # 환경")
	print("  enemy.set_collision_mask_value(4, true)  # 투사체")

	# ============================================
	# 7. 레이어/마스크 실전 시나리오
	# ============================================
	print("\n--- 7. 레이어/마스크 시나리오 ---\n")

	print("시나리오 1: 아군 총알은 아군을 안 맞춤")
	print("  플레이어 총알: layer=4, mask=2+3 (적+환경)")
	print("  적 총알:       layer=4, mask=1+3 (플레이어+환경)")
	print("  -> 같은 layer 4이지만 mask가 다름!")
	print("")

	print("시나리오 2: 유령은 벽을 통과하지만 바닥은 밟음")
	print("  유령:   layer=2, mask=8 (바닥 레이어만)")
	print("  벽:     layer=3")
	print("  바닥:   layer=3+8")
	print("  -> 바닥에 추가 레이어(8)를 부여!")
	print("")

	print("시나리오 3: 원거리 감지 vs 물리 충돌")
	print("  캐릭터 Body:  layer=1 (물리 충돌)")
	print("  감지 Area3D:  layer=6 (트리거)")
	print("  -> 같은 캐릭터에 다른 레이어의 콜리전 영역")

	# ============================================
	# 8. CollisionShape3D 디버깅
	# ============================================
	print("\n--- 8. 충돌 형태 디버깅 ---\n")

	print("에디터에서:")
	print("  Debug > Visible Collision Shapes (Ctrl+Shift+C?)")
	print("  -> 게임 실행 중 충돌 형태를 반투명으로 표시")
	print("")

	print("코드에서:")
	print("  # 프로젝트 설정에서 디버그 활성화")
	print("  # Project Settings > Debug > Shapes > visible = true")
	print("")

	print("collision_shape.disabled 활용:")
	print("  # 조건에 따라 충돌 형태 켜고 끄기")
	print("  collision_shape.disabled = true   # 비활성화")
	print("  collision_shape.disabled = false  # 활성화")
	print("  # 예: 웅크리면 서있는 콜리전 끄고 웅크린 콜리전 켬")
	print("")

	# set_deferred 중요!
	print("** 중요: 물리 콜백에서 shape 변경 **")
	print("  # _physics_process 중에 직접 변경하면 오류!")
	print("  collision_shape.set_deferred('disabled', true)")
	print("  -> set_deferred로 안전하게 다음 프레임에 적용")

	# ============================================
	# 9. CollisionObject3D 입력 이벤트
	# ============================================
	print("\n--- 9. 입력 이벤트 (마우스 클릭) ---\n")

	print("CollisionObject3D 입력 감지:")
	print("  StaticBody3D, RigidBody3D 등에서 사용 가능")
	print("  input_ray_pickable = true (기본)")
	print("")

	print("시그널:")
	print("  input_event(camera, event, pos, normal, shape_idx)")
	print("  mouse_entered()")
	print("  mouse_exited()")
	print("")

	print("3D 오브젝트 클릭 예시:")
	print("""  extends StaticBody3D

  func _ready():
      input_event.connect(_on_input_event)
      mouse_entered.connect(_on_mouse_entered)
      mouse_exited.connect(_on_mouse_exited)

  func _on_input_event(camera, event, pos, normal, shape_idx):
      if event is InputEventMouseButton:
          if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
              print("클릭됨! 위치: ", pos)

  func _on_mouse_entered():
      # 하이라이트 효과
      $MeshInstance3D.material_override.emission_enabled = true

  func _on_mouse_exited():
      $MeshInstance3D.material_override.emission_enabled = false""")

	# ============================================
	# 10. 카메라 추가 (테스트용)
	# ============================================

	var cam := Camera3D.new()
	cam.position = Vector3(0, 5, 10)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	add_child(cam)

	# 바닥
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(20, 0.1, 20)
	floor_mi.mesh = floor_mesh
	floor_body.add_child(floor_mi)
	add_child(floor_body)

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. CollisionShape3D: PhysicsBody3D/Area3D의 필수 자식")
	print("2. SphereShape3D: 가장 빠름, BoxShape3D: 정확+빠름")
	print("3. CapsuleShape3D: 캐릭터에 최적 (부드러운 이동)")
	print("4. ConcavePolygonShape3D: 정적 오브젝트만! (느림)")
	print("5. collision_layer: 내가 속한 레이어")
	print("6. collision_mask: 내가 충돌할 레이어")
	print("7. set_collision_layer_value(): 직관적인 레이어 설정")
	print("8. set_deferred(): 물리 콜백에서 안전하게 변경")
	print("9. input_ray_pickable: 3D 오브젝트 마우스 클릭")
