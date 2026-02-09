# Chapter 14 - 3D Physics
# 04-3d-item-pickup.gd - 3D 아이템 수집 시스템
#
# 이 파일에서 배울 내용:
# - Area3D 기반 아이템 수집
# - 자석(Magnet) 효과로 아이템 끌어오기
# - 아이템 데이터 구조와 인벤토리
# - 아이템 스폰과 드롭

extends Node3D

# ============================================
# 아이템 데이터 정의
# ============================================

# 아이템 종류
enum ItemType {
	COIN,
	HEALTH,
	AMMO,
	KEY,
	GEM,
}

# 아이템 정보
var item_data := {
	ItemType.COIN: {
		"name": "코인",
		"value": 10,
		"color": Color(1.0, 0.85, 0.0),    # 금색
		"mesh_type": "sphere",
		"size": 0.3,
	},
	ItemType.HEALTH: {
		"name": "체력 포션",
		"value": 25,
		"color": Color(1.0, 0.2, 0.2),     # 빨강
		"mesh_type": "capsule",
		"size": 0.3,
	},
	ItemType.AMMO: {
		"name": "탄약",
		"value": 15,
		"color": Color(0.4, 0.4, 0.4),     # 회색
		"mesh_type": "box",
		"size": 0.25,
	},
	ItemType.KEY: {
		"name": "열쇠",
		"value": 1,
		"color": Color(0.8, 0.7, 0.0),     # 금색
		"mesh_type": "cylinder",
		"size": 0.2,
	},
	ItemType.GEM: {
		"name": "보석",
		"value": 50,
		"color": Color(0.3, 0.5, 1.0),     # 파랑
		"mesh_type": "sphere",
		"size": 0.25,
	},
}

# 플레이어 인벤토리
var inventory := {
	"coins": 0,
	"health_potions": 0,
	"ammo": 0,
	"keys": 0,
	"gems": 0,
	"total_value": 0,
}

# 자석 효과 설정
var magnet_enabled := true
var magnet_range := 5.0         # 자석 감지 범위
var magnet_pull_speed := 8.0    # 끌어오는 속도
var magnet_min_distance := 0.5  # 이 거리 이내면 수집

# 아이템 애니메이션 설정
var item_bob_speed := 3.0       # 위아래 흔들림 속도
var item_bob_height := 0.2      # 위아래 흔들림 높이
var item_rotate_speed := 2.0    # 회전 속도

# 시뮬레이션용 플레이어 위치
var player_position := Vector3(0, 0, 0)

# 자석 영역 참조
var magnet_area: Area3D

func _ready():
	print("=== 3D 아이템 수집 시스템 ===\n")

	# 기본 씬 구성
	_create_scene()

	# ============================================
	# 1. 기본 아이템 구조 설명
	# ============================================
	print("--- 1. 아이템 노드 구조 ---\n")

	print("아이템 노드 트리:")
	print("  Area3D (ItemPickup)")
	print("    +-- CollisionShape3D  <- 수집 감지 범위")
	print("    +-- MeshInstance3D    <- 시각적 표현")
	print("    +-- AudioStreamPlayer3D  <- 수집 효과음 (선택)")
	print("")

	print("Area3D를 사용하는 이유:")
	print("  - 물리적 충돌 없이 '겹침'만 감지")
	print("  - 플레이어가 아이템을 밀어내지 않음")
	print("  - 가볍고 효율적")
	print("")

	print("아이템 코드 구조:")
	print("""  extends Area3D
  class_name ItemPickup3D

  @export var item_type: ItemType = ItemType.COIN
  @export var amount: int = 1
  var base_y: float  # 기본 높이 (흔들림 기준)

  func _ready():
      base_y = position.y
      body_entered.connect(_on_body_entered)

  func _on_body_entered(body: Node3D):
      if body.is_in_group("player"):
          collect(body)

  func collect(player: Node3D):
      if player.has_method("add_item"):
          player.add_item(item_type, amount)
      # 효과음 재생, 파티클 등
      queue_free()""")

	# ============================================
	# 2. 아이템 생성 함수
	# ============================================
	print("\n--- 2. 아이템 생성 ---\n")

	# 다양한 아이템 생성
	var spawn_positions := [
		{"type": ItemType.COIN, "pos": Vector3(-3, 0.5, -2)},
		{"type": ItemType.COIN, "pos": Vector3(-1, 0.5, -3)},
		{"type": ItemType.COIN, "pos": Vector3(1, 0.5, -2)},
		{"type": ItemType.HEALTH, "pos": Vector3(4, 0.5, -1)},
		{"type": ItemType.AMMO, "pos": Vector3(-4, 0.5, 1)},
		{"type": ItemType.GEM, "pos": Vector3(3, 0.5, 3)},
		{"type": ItemType.KEY, "pos": Vector3(0, 0.5, 4)},
	]

	for info in spawn_positions:
		var item := _create_item(info["type"], info["pos"])
		if item:
			print("  %s 생성 at %s" % [
				item_data[info["type"]]["name"],
				str(info["pos"])
			])

	print("\n총 %d개 아이템 생성 완료" % spawn_positions.size())

	# ============================================
	# 3. 자석 효과 시스템
	# ============================================
	print("\n--- 3. 자석 효과 시스템 ---\n")

	print("자석 효과 원리:")
	print("  1. 플레이어에 큰 범위의 Area3D 추가 (자석 영역)")
	print("  2. 아이템이 자석 영역에 들어오면 감지")
	print("  3. 아이템을 플레이어 쪽으로 lerp/이동")
	print("  4. 충분히 가까우면 수집 처리")
	print("")

	# 자석 영역 생성
	magnet_area = Area3D.new()
	magnet_area.name = "MagnetZone"

	var magnet_col := CollisionShape3D.new()
	var magnet_shape := SphereShape3D.new()
	magnet_shape.radius = magnet_range
	magnet_col.shape = magnet_shape
	magnet_area.add_child(magnet_col)

	# 자석은 아이템 레이어(5)만 감지
	magnet_area.set_collision_layer_value(1, false)
	magnet_area.set_collision_mask_value(1, false)
	magnet_area.set_collision_mask_value(5, true)  # 아이템 레이어

	add_child(magnet_area)

	print("자석 Area3D 생성:")
	print("  범위: %.1fm (SphereShape3D)" % magnet_range)
	print("  끌어오는 속도: %.1f m/s" % magnet_pull_speed)
	print("  수집 거리: %.1fm" % magnet_min_distance)
	print("")

	print("자석 효과 코드 (플레이어에 추가):")
	print("""  extends CharacterBody3D

  @export var magnet_range: float = 5.0
  @export var magnet_speed: float = 8.0
  @export var collect_distance: float = 0.5

  func _physics_process(delta):
      # 자석 영역 내의 아이템들
      for item in $MagnetZone.get_overlapping_areas():
          if not item.is_in_group("item"):
              continue

          var dir = global_position - item.global_position
          var dist = dir.length()

          if dist < collect_distance:
              # 수집!
              _collect_item(item)
          else:
              # 끌어오기 (가까울수록 빠르게)
              var pull_strength = 1.0 - (dist / magnet_range)
              pull_strength = pow(pull_strength, 0.5)  # 가까울수록 급격히
              item.global_position += dir.normalized() * magnet_speed * pull_strength * delta""")

	# ============================================
	# 4. 자석 효과 변형들
	# ============================================
	print("\n--- 4. 자석 효과 변형 ---\n")

	print("1) 선형 자석 (일정 속도):")
	print("  item.position = item.position.move_toward(player_pos, speed * delta)")
	print("")

	print("2) 가속 자석 (점점 빠르게):")
	print("""  var distance = item.global_position.distance_to(player_pos)
  var speed = max_speed * (1.0 - distance / magnet_range)
  item.global_position = item.global_position.move_toward(
      player_pos, speed * delta)""")
	print("")

	print("3) 포물선 자석 (곡선 경로):")
	print("""  # 아이템이 위로 솟았다가 플레이어에게 내려옴
  var t = item.magnet_timer / magnet_duration  # 0~1
  var arc_height = 2.0 * sin(t * PI)
  var base_pos = item.start_pos.lerp(player_pos, t)
  item.global_position = base_pos + Vector3(0, arc_height, 0)""")
	print("")

	print("4) 딜레이 자석 (잠시 후 수집):")
	print("""  # 아이템 드롭 후 일정 시간 지나야 수집 가능
  var pickup_delay: float = 0.5  # 0.5초 대기
  var time_since_drop: float = 0.0

  func _process(delta):
      time_since_drop += delta
      if time_since_drop < pickup_delay:
          return  # 아직 수집 불가
      # 자석 효과 시작...""")

	# ============================================
	# 5. 아이템 애니메이션
	# ============================================
	print("\n--- 5. 아이템 애니메이션 ---\n")

	print("떠다니는 아이템 (Bob + Rotate):")
	print("""  extends Area3D

  var base_position: Vector3
  var bob_speed: float = 3.0
  var bob_height: float = 0.2
  var rotate_speed: float = 2.0
  var time_offset: float  # 아이템마다 다른 타이밍

  func _ready():
      base_position = position
      time_offset = randf() * TAU  # 랜덤 오프셋

  func _process(delta):
      # 위아래 흔들림 (사인파)
      var bob = sin(Time.get_ticks_msec() * 0.001 * bob_speed + time_offset)
      position.y = base_position.y + bob * bob_height

      # Y축 회전
      rotate_y(rotate_speed * delta)""")
	print("")

	print("수집 시 연출:")
	print("""  func collect_with_effect(player_pos: Vector3):
      # 반짝이는 효과
      var tween = create_tween()
      tween.set_parallel(true)

      # 크기가 줄면서
      tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
      # 플레이어 쪽으로 날아감
      tween.tween_property(self, "global_position", player_pos, 0.3)
      # 위로 살짝 솟으면서
      tween.tween_property(self, "global_position:y",
          global_position.y + 1.0, 0.15)

      tween.chain().tween_callback(queue_free)""")

	# ============================================
	# 6. 인벤토리 시스템 연동
	# ============================================
	print("\n--- 6. 인벤토리 연동 ---\n")

	# 수집 시뮬레이션
	_simulate_collect(ItemType.COIN, 3)
	_simulate_collect(ItemType.HEALTH, 1)
	_simulate_collect(ItemType.AMMO, 2)
	_simulate_collect(ItemType.GEM, 1)
	_simulate_collect(ItemType.KEY, 1)

	print("")
	print("현재 인벤토리:")
	print("  코인: %d (가치: %d)" % [inventory["coins"], inventory["coins"] * 10])
	print("  체력 포션: %d개" % inventory["health_potions"])
	print("  탄약: %d발" % inventory["ammo"])
	print("  보석: %d개" % inventory["gems"])
	print("  열쇠: %d개" % inventory["keys"])
	print("  총 가치: %d" % inventory["total_value"])
	print("")

	print("인벤토리 코드 패턴:")
	print("""  # 플레이어 스크립트
  func add_item(type: ItemType, amount: int = 1):
      match type:
          ItemType.COIN:
              coins += amount * item_data[type]["value"]
              emit_signal("coins_changed", coins)
          ItemType.HEALTH:
              health = min(health + 25, max_health)
              emit_signal("health_changed", health)
          ItemType.KEY:
              keys.append(true)
              emit_signal("key_collected")

      # UI 업데이트 시그널
      emit_signal("inventory_changed")""")

	# ============================================
	# 7. 아이템 드롭 시스템
	# ============================================
	print("\n--- 7. 아이템 드롭 ---\n")

	print("적 처치 시 아이템 드롭:")
	print("""  func drop_loot(drop_position: Vector3):
      # 드롭 테이블
      var loot_table = [
          {"type": ItemType.COIN, "chance": 0.8, "min": 1, "max": 5},
          {"type": ItemType.HEALTH, "chance": 0.3, "min": 1, "max": 1},
          {"type": ItemType.AMMO, "chance": 0.5, "min": 1, "max": 3},
          {"type": ItemType.GEM, "chance": 0.05, "min": 1, "max": 1},
      ]

      for loot in loot_table:
          if randf() < loot["chance"]:
              var count = randi_range(loot["min"], loot["max"])
              for i in range(count):
                  var item = create_item(loot["type"])
                  item.global_position = drop_position

                  # 사방으로 튕기는 효과
                  var angle = randf() * TAU
                  var force = randf_range(3.0, 6.0)
                  var launch_dir = Vector3(
                      cos(angle) * force,
                      randf_range(4.0, 7.0),
                      sin(angle) * force
                  )
                  item.launch(launch_dir)""")
	print("")

	print("아이템 발사 + 착지:")
	print("""  # 아이템 스크립트에 추가
  var launch_velocity: Vector3 = Vector3.ZERO
  var gravity: float = 20.0
  var is_launched: bool = false
  var ground_y: float = 0.5  # 바닥 높이

  func launch(velocity: Vector3):
      launch_velocity = velocity
      is_launched = true

  func _process(delta):
      if is_launched:
          launch_velocity.y -= gravity * delta
          position += launch_velocity * delta

          # 바닥에 닿으면 멈춤
          if position.y <= ground_y:
              position.y = ground_y
              is_launched = false
              launch_velocity = Vector3.ZERO
              # 이제 수집 가능!""")

	# ============================================
	# 8. 아이템 스포너
	# ============================================
	print("\n--- 8. 아이템 스포너 ---\n")

	print("시간 기반 아이템 리스폰:")
	print("""  extends Node3D
  class_name ItemSpawner3D

  @export var item_type: ItemType = ItemType.COIN
  @export var respawn_time: float = 10.0
  @export var spawn_radius: float = 0.5

  var current_item: Area3D = null
  var respawn_timer: float = 0.0

  func _process(delta):
      if current_item == null or not is_instance_valid(current_item):
          respawn_timer += delta
          if respawn_timer >= respawn_time:
              spawn_item()
              respawn_timer = 0.0

  func spawn_item():
      current_item = create_item(item_type)
      var offset = Vector3(
          randf_range(-spawn_radius, spawn_radius),
          0,
          randf_range(-spawn_radius, spawn_radius)
      )
      current_item.global_position = global_position + offset
      get_parent().add_child(current_item)""")

	# ============================================
	# 9. 최적화 팁
	# ============================================
	print("\n--- 9. 최적화 팁 ---\n")

	print("아이템 최적화:")
	print("  1. 먼 아이템 비활성화 (VisibleOnScreenNotifier3D)")
	print("     -> 화면 밖이면 _process 건너뜀")
	print("")
	print("  2. 아이템 풀링 (Object Pool)")
	print("     -> queue_free() 대신 재사용")
	print("     -> 대량 생성/삭제 시 GC 부하 감소")
	print("")
	print("  3. LOD (Level of Detail)")
	print("     -> 멀리 있는 아이템은 단순한 메시 사용")
	print("     -> 또는 빌보드(항상 카메라 향함)로 대체")
	print("")
	print("  4. 배칭 (Batching)")
	print("     -> 같은 종류 아이템은 MultiMeshInstance3D")
	print("     -> 수천 개도 한 번에 렌더링!")
	print("")
	print("  5. 자석 감지 주기 제한")
	print("     -> 매 프레임 대신 0.1초마다 체크")
	print("""     var check_timer: float = 0.0
     func _process(delta):
         check_timer += delta
         if check_timer >= 0.1:
             check_timer = 0.0
             _check_magnet_items()""")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Area3D: 아이템 감지에 최적 (물리 충돌 없음)")
	print("2. body_entered: 플레이어 접근 시 수집")
	print("3. 자석 효과: 큰 Area3D + lerp/move_toward")
	print("4. 아이템 애니메이션: sin() 흔들림 + rotate_y()")
	print("5. 드롭 시스템: 확률 테이블 + 발사 효과")
	print("6. 인벤토리 연동: 시그널로 UI 업데이트")
	print("7. 최적화: 풀링, LOD, MultiMesh, 주기 제한")


# ============================================
# 헬퍼 함수들
# ============================================

func _create_item(type: ItemType, pos: Vector3) -> Area3D:
	var data = item_data[type]
	var item := Area3D.new()
	item.name = "%s_%d" % [data["name"], randi() % 1000]
	item.position = pos
	item.add_to_group("item")

	# 충돌 형태
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = data["size"] * 1.5  # 수집 범위는 좀 더 넓게
	col.shape = shape
	item.add_child(col)

	# 메시
	var mi := MeshInstance3D.new()
	var mesh: Mesh
	match data["mesh_type"]:
		"sphere":
			var s := SphereMesh.new()
			s.radius = data["size"]
			s.height = data["size"] * 2
			mesh = s
		"box":
			var b := BoxMesh.new()
			b.size = Vector3.ONE * data["size"]
			mesh = b
		"capsule":
			var c := CapsuleMesh.new()
			c.radius = data["size"] * 0.5
			c.height = data["size"] * 2
			mesh = c
		"cylinder":
			var cy := CylinderMesh.new()
			cy.top_radius = data["size"] * 0.3
			cy.bottom_radius = data["size"] * 0.5
			cy.height = data["size"] * 1.5
			mesh = cy

	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = data["color"]
	mat.metallic = 0.6
	mat.roughness = 0.3
	mat.emission_enabled = true
	mat.emission = data["color"] * 0.3
	mat.emission_energy_multiplier = 0.5
	mi.material_override = mat
	item.add_child(mi)

	# 레이어 설정 (아이템 레이어 5)
	item.set_collision_layer_value(1, false)
	item.set_collision_layer_value(5, true)
	item.set_collision_mask_value(1, true)  # 플레이어와 겹침 감지

	add_child(item)
	return item


func _simulate_collect(type: ItemType, count: int):
	var data = item_data[type]
	for i in range(count):
		match type:
			ItemType.COIN:
				inventory["coins"] += 1
			ItemType.HEALTH:
				inventory["health_potions"] += 1
			ItemType.AMMO:
				inventory["ammo"] += data["value"]
			ItemType.GEM:
				inventory["gems"] += 1
			ItemType.KEY:
				inventory["keys"] += 1
		inventory["total_value"] += data["value"]
	print("  [수집] %s x%d (가치: %d)" % [data["name"], count, data["value"] * count])


func _create_scene():
	# 바닥
	var floor := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_col.shape = floor_shape
	floor.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var fmesh := BoxMesh.new()
	fmesh.size = Vector3(20, 0.1, 20)
	floor_mi.mesh = fmesh
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.3, 0.4, 0.3)
	floor_mi.material_override = fmat
	floor.add_child(floor_mi)
	add_child(floor)

	# 조명
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.light_energy = 1.0
	add_child(light)

	# 카메라
	var cam := Camera3D.new()
	cam.position = Vector3(0, 8, 8)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	add_child(cam)
