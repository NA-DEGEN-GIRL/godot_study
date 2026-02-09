# 챕터 14: 3D 물리
#
# 이 챕터에서는 다음을 학습합니다:
# - CollisionShape3D 설정과 도형 유형
# - RigidBody3D에 힘과 충격(impulse) 적용
# - CharacterBody3D를 이용한 캐릭터 이동
# - Area3D로 영역 감지 (트리거)
# - RayCast3D를 이용한 광선 검사
# - 충돌 레이어와 마스크 설정

extends Node3D


# ============================================================
# 물리 상수
# ============================================================
const GRAVITY_3D: float = 9.8
const MOVE_SPEED: float = 5.0
const JUMP_IMPULSE: float = 7.0


# ============================================================
# 연습 1: CollisionShape3D 설정
# ============================================================
# CollisionShape3D는 물리 연산에 사용되는 충돌 도형을 정의합니다.
# 렌더링 메시와는 별개로, 물리 엔진이 사용하는 단순화된 도형입니다.

func create_collision_shape_config(shape_type: String, params: Dictionary) -> Dictionary:
	# TODO: 충돌 도형 유형별 설정을 Dictionary로 반환하세요
	# shape_type: "box", "sphere", "capsule", "cylinder", "ray", "convex"
	#
	# 반환 형식:
	# {
	#   "node_type": "CollisionShape3D",
	#   "shape_class": 도형 클래스명,
	#   "shape_type": shape_type,
	#   "properties": 도형별 속성 Dictionary
	# }
	#
	# 도형별 속성 (params에서 값을 가져오고, 없으면 기본값 사용):
	# - "box":
	#   shape_class: "BoxShape3D"
	#   properties: {"size": params.get("size", Vector3(1, 1, 1))}
	#
	# - "sphere":
	#   shape_class: "SphereShape3D"
	#   properties: {"radius": params.get("radius", 0.5)}
	#
	# - "capsule":
	#   shape_class: "CapsuleShape3D"
	#   properties: {"radius": params.get("radius", 0.5), "height": params.get("height", 2.0)}
	#
	# - "cylinder":
	#   shape_class: "CylinderShape3D"
	#   properties: {"radius": params.get("radius", 0.5), "height": params.get("height", 1.0)}
	#
	# - "ray":
	#   shape_class: "SeparationRayShape3D"
	#   properties: {"length": params.get("length", 1.0)}
	#
	# - "convex":
	#   shape_class: "ConvexPolygonShape3D"
	#   properties: {"points": params.get("points", [])}
	#
	# - 그 외: shape_class를 "Unknown"으로, properties를 빈 Dictionary로
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 2: RigidBody3D 힘 적용
# ============================================================
# RigidBody3D는 물리 엔진이 제어하는 오브젝트입니다.
# 힘(force), 충격(impulse), 토크(torque)를 적용할 수 있습니다.

func simulate_rigidbody_force(mass: float, force: Vector3, delta: float) -> Dictionary:
	# TODO: 뉴턴 역학에 따른 힘 적용 결과를 계산하세요
	# F = ma -> a = F / m
	# velocity += acceleration * delta
	# position += velocity * delta
	#
	# 초기 상태: velocity = Vector3.ZERO, position = Vector3.ZERO
	#
	# 반환 형식:
	# {
	#   "mass": mass,
	#   "force": force,
	#   "acceleration": force / mass,
	#   "velocity_after": (force / mass) * delta,
	#   "position_after": ((force / mass) * delta) * delta,
	#   "kinetic_energy": 0.5 * mass * velocity_after.length_squared()
	# }
	#
	# 주의: mass가 0 이하이면 기본값 반환 (acceleration = Vector3.ZERO 등)
	var result = {}  # 여기를 수정하세요
	return result

func get_rigidbody_methods() -> Dictionary:
	# TODO: RigidBody3D의 주요 힘 적용 메서드를 Dictionary로 반환하세요
	# {
	#   "apply_force": "지속적인 힘 적용 (매 프레임 누적, 단위: N)",
	#   "apply_central_force": "중심에 지속적인 힘 적용 (토크 없음)",
	#   "apply_impulse": "즉각적인 충격 적용 (한 번, 단위: N*s)",
	#   "apply_central_impulse": "중심에 즉각적인 충격 (토크 없음)",
	#   "apply_torque": "회전력 적용 (지속적)",
	#   "apply_torque_impulse": "즉각적인 회전 충격"
	# }
	var methods = {}  # 여기를 수정하세요
	return methods


# ============================================================
# 연습 3: CharacterBody3D 이동 구현
# ============================================================
# CharacterBody3D는 코드로 직접 이동을 제어하는 물리 바디입니다.
# move_and_slide()로 이동하며 충돌 처리를 자동으로 합니다.

func calculate_character_velocity(
	current_velocity: Vector3,
	input_direction: Vector2,  # x: 좌우, y: 전후 (WASD)
	is_on_floor: bool,
	wants_jump: bool,
	delta: float
) -> Dictionary:
	# TODO: CharacterBody3D의 velocity를 계산하세요
	#
	# 1. 중력 적용: 바닥에 있지 않으면 velocity.y -= GRAVITY_3D * delta
	# 2. 점프: 바닥에 있고 wants_jump이면 velocity.y = JUMP_IMPULSE
	# 3. 수평 이동:
	#    - input_direction을 3D 벡터로 변환: Vector3(input_direction.x, 0, input_direction.y)
	#    - 입력이 있으면 정규화 후 MOVE_SPEED 적용
	#    - 입력이 없으면 수평 속도를 0으로 (velocity.x = 0, velocity.z = 0)
	#
	# 반환 형식:
	# {
	#   "velocity": 계산된 최종 속도 Vector3,
	#   "is_moving": 수평 입력이 있는지 (input_direction.length() > 0),
	#   "is_falling": velocity.y < 0,
	#   "is_jumping": velocity.y > 0 and !is_on_floor,
	#   "speed": 수평 속도의 크기 (Vector2(velocity.x, velocity.z).length())
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 4: Area3D 감지
# ============================================================
# Area3D는 물리적 충돌 없이 영역 진입/퇴장을 감지합니다.
# 트리거 존, 아이템 수집 범위, 데미지 영역 등에 사용됩니다.

func create_area3d_config(area_type: String, size: float) -> Dictionary:
	# TODO: Area3D 유형별 설정을 Dictionary로 반환하세요
	# area_type: "trigger", "pickup", "damage", "detection"
	#
	# 공통 속성:
	# - "node_type": "Area3D"
	# - "area_type": area_type
	# - "collision_shape": "SphereShape3D"
	# - "radius": size
	# - "monitorable": true (다른 Area에 의해 감지됨)
	# - "monitoring": true (다른 물체를 감지함)
	#
	# 유형별 추가 속성:
	# - "trigger":
	#   "signals": ["body_entered", "body_exited"]
	#   "one_shot": false
	#
	# - "pickup":
	#   "signals": ["body_entered"]
	#   "one_shot": true  (한 번 수집되면 사라짐)
	#   "auto_free": true
	#
	# - "damage":
	#   "signals": ["body_entered", "body_exited"]
	#   "damage_per_second": 10.0
	#   "one_shot": false
	#
	# - "detection":
	#   "signals": ["body_entered", "body_exited"]
	#   "detection_range": size
	#   "alert_on_enter": true
	var config = {}  # 여기를 수정하세요
	return config

func simulate_area3d_overlap(
	area_position: Vector3,
	area_radius: float,
	bodies: Array  # [{"name": "Player", "position": Vector3(...), "type": "character"}, ...]
) -> Dictionary:
	# TODO: 영역 안에 있는 바디를 감지하세요
	# 각 body의 position과 area_position 사이 거리가 area_radius 이하이면 감지됨
	#
	# 반환 형식:
	# {
	#   "overlapping_bodies": [감지된 body들의 name 배열],
	#   "count": 감지된 수,
	#   "closest": 가장 가까운 body의 name (없으면 ""),
	#   "closest_distance": 가장 가까운 거리 (없으면 -1.0)
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 5: RayCast3D 사용
# ============================================================
# RayCast3D는 직선 광선을 쏘아 충돌체를 감지합니다.
# 바닥 감지, 시선 차단 체크, 사격 판정 등에 사용됩니다.

func simulate_raycast3d(
	origin: Vector3,
	direction: Vector3,
	max_distance: float,
	obstacles: Array  # [{"name": "Wall", "position": Vector3(...), "radius": 1.0}, ...]
) -> Dictionary:
	# TODO: 간단한 레이캐스트를 시뮬레이션하세요
	# 광선의 시작점(origin)에서 방향(direction)으로 max_distance만큼 쏩니다
	# 각 obstacle과의 거리가 radius 이하이면 충돌로 판정합니다
	# (간단한 구 충돌 테스트: 광선과 구 중심의 최단 거리)
	#
	# 간소화된 충돌 판정:
	# - 광선 위의 가장 가까운 점 계산: 각 obstacle에 대해
	#   obstacle까지의 벡터를 direction에 투영하여 거리(t) 계산
	#   t = (obstacle.position - origin).dot(direction.normalized())
	#   가장 가까운 점: origin + direction.normalized() * clamp(t, 0, max_distance)
	#   구 중심과 이 점의 거리가 radius 이하이면 충돌
	#
	# 반환 형식:
	# {
	#   "is_colliding": 충돌 여부,
	#   "collider_name": 가장 가까운 충돌체 이름 (없으면 ""),
	#   "collision_point": 충돌 지점 Vector3 (없으면 origin + direction.normalized() * max_distance),
	#   "collision_distance": 충돌 거리 (없으면 max_distance),
	#   "collision_normal": 충돌 법선 (간소화: (collision_point - obstacle.position).normalized())
	# }
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 6: 충돌 레이어 설정
# ============================================================
# Godot은 32개의 물리 레이어를 지원합니다.
# Layer: 자신이 속한 레이어, Mask: 충돌을 감지할 대상 레이어
# 비트 연산으로 여러 레이어를 조합합니다.

func setup_3d_collision_layers() -> Dictionary:
	# TODO: 3D 게임의 충돌 레이어 구성을 Dictionary로 반환하세요
	#
	# 레이어 정의:
	# Layer 1 = 환경(Environment) - 벽, 바닥
	# Layer 2 = 플레이어(Player)
	# Layer 3 = 적(Enemy)
	# Layer 4 = 플레이어 투사체(Player Projectile)
	# Layer 5 = 적 투사체(Enemy Projectile)
	# Layer 6 = 아이템(Item)
	# Layer 7 = 트리거(Trigger Zone)
	#
	# 반환 형식:
	# {
	#   "layer_names": {1: "Environment", 2: "Player", ...},
	#   "configurations": {
	#     "player": {
	#       "layer": [2],
	#       "mask": [1, 3, 5, 6, 7],
	#       "description": "환경, 적, 적 투사체, 아이템, 트리거와 충돌"
	#     },
	#     "enemy": {
	#       "layer": [3],
	#       "mask": [1, 2, 4],
	#       "description": "환경, 플레이어, 플레이어 투사체와 충돌"
	#     },
	#     "player_projectile": {
	#       "layer": [4],
	#       "mask": [1, 3],
	#       "description": "환경, 적과 충돌"
	#     },
	#     "enemy_projectile": {
	#       "layer": [5],
	#       "mask": [1, 2],
	#       "description": "환경, 플레이어와 충돌"
	#     },
	#     "item": {
	#       "layer": [6],
	#       "mask": [2],
	#       "description": "플레이어만 감지"
	#     },
	#     "trigger": {
	#       "layer": [7],
	#       "mask": [2],
	#       "description": "플레이어만 감지"
	#     }
	#   }
	# }
	var config = {}  # 여기를 수정하세요
	return config

func calculate_layer_bitmask(layers: Array) -> int:
	# TODO: 레이어 번호 배열을 비트마스크 정수로 변환하세요
	# 예: [1, 3] -> 0b0101 -> 5
	# 레이어 N은 비트 (N-1) 위치에 해당합니다
	# 공식: bitmask |= (1 << (layer - 1))
	var bitmask = 0  # 여기를 수정하세요
	return bitmask


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 14: 3D 물리 ===")
	print("")

	# 테스트 1: CollisionShape3D 설정
	print("--- 연습 1: CollisionShape3D 설정 ---")
	var box_shape = create_collision_shape_config("box", {"size": Vector3(2, 1, 3)})
	var sphere_shape = create_collision_shape_config("sphere", {"radius": 1.5})
	var capsule_shape = create_collision_shape_config("capsule", {})
	print("결과 1-1 (박스 도형):", box_shape)
	print("결과 1-2 (구 도형):", sphere_shape)
	print("결과 1-3 (캡슐 기본값):", capsule_shape)
	print("")

	# 테스트 2: RigidBody3D 힘 적용
	print("--- 연습 2: RigidBody3D 힘 적용 ---")
	var force_result = simulate_rigidbody_force(2.0, Vector3(10, 0, 0), 0.016)
	print("결과 2-1 (힘 적용):", force_result)
	if force_result.has("acceleration"):
		print("  가속도:", force_result["acceleration"], " (기대값: (5, 0, 0))")
	var methods = get_rigidbody_methods()
	print("결과 2-2 (메서드 목록):", methods)
	print("")

	# 테스트 3: CharacterBody3D 이동
	print("--- 연습 3: CharacterBody3D 이동 ---")
	var move1 = calculate_character_velocity(Vector3.ZERO, Vector2(0, -1), true, false, 0.016)
	var move2 = calculate_character_velocity(Vector3.ZERO, Vector2.ZERO, false, false, 0.016)
	var move3 = calculate_character_velocity(Vector3.ZERO, Vector2(1, 0), true, true, 0.016)
	print("결과 3-1 (앞으로 이동):", move1)
	print("결과 3-2 (공중 정지, 중력 적용):", move2)
	print("결과 3-3 (오른쪽 이동+점프):", move3)
	print("")

	# 테스트 4: Area3D 감지
	print("--- 연습 4: Area3D 감지 ---")
	var trigger_config = create_area3d_config("trigger", 5.0)
	var pickup_config = create_area3d_config("pickup", 1.5)
	print("결과 4-1 (트리거 설정):", trigger_config)
	print("결과 4-2 (픽업 설정):", pickup_config)

	var test_bodies = [
		{"name": "Player", "position": Vector3(2, 0, 0), "type": "character"},
		{"name": "Enemy1", "position": Vector3(8, 0, 0), "type": "enemy"},
		{"name": "Enemy2", "position": Vector3(3, 1, 0), "type": "enemy"}
	]
	var overlap = simulate_area3d_overlap(Vector3.ZERO, 5.0, test_bodies)
	print("결과 4-3 (영역 감지):", overlap)
	if overlap.has("count"):
		print("  감지 수:", overlap["count"], " (기대값: 2)")
	print("")

	# 테스트 5: RayCast3D 사용
	print("--- 연습 5: RayCast3D 사용 ---")
	var test_obstacles = [
		{"name": "Wall", "position": Vector3(5, 0, 0), "radius": 1.0},
		{"name": "Box", "position": Vector3(10, 0, 0), "radius": 0.5}
	]
	var ray_result = simulate_raycast3d(Vector3.ZERO, Vector3(1, 0, 0), 20.0, test_obstacles)
	print("결과 5 (레이캐스트):", ray_result)
	if ray_result.has("is_colliding"):
		print("  충돌 여부:", ray_result["is_colliding"], " (기대값: true)")
	if ray_result.has("collider_name"):
		print("  충돌체:", ray_result["collider_name"], " (기대값: Wall)")
	print("")

	# 테스트 6: 충돌 레이어 설정
	print("--- 연습 6: 충돌 레이어 ---")
	var layers = setup_3d_collision_layers()
	print("결과 6-1 (레이어 구성):", layers)
	var bitmask1 = calculate_layer_bitmask([1, 3])
	var bitmask2 = calculate_layer_bitmask([2])
	var bitmask3 = calculate_layer_bitmask([1, 2, 3, 4, 5, 6, 7])
	print("결과 6-2 (레이어 [1,3] 비트마스크):", bitmask1, " (기대값: 5)")
	print("결과 6-3 (레이어 [2] 비트마스크):", bitmask2, " (기대값: 2)")
	print("결과 6-4 (레이어 [1-7] 비트마스크):", bitmask3, " (기대값: 127)")
	print("")

	print("=== 챕터 14 완료 ===")
