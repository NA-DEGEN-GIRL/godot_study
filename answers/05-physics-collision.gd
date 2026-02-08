# 챕터 5: 물리와 충돌 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - 충돌 레이어(Layer)와 마스크(Mask) 시스템
# - Area2D 충돌 시그널 핸들러
# - RayCast2D로 바닥 감지
# - 아이템 수집 시스템
# - 충돌 정보(KinematicCollision2D) 활용
# - 단방향(One-way) 충돌 플랫폼

extends CharacterBody2D

# =============================================
# 물리 관련 변수
# =============================================
@export var move_speed: float = 300.0
@export var gravity_force: float = 980.0
@export var jump_force: float = -500.0

# 아이템 수집 추적
var collected_items: Array = []
var score: int = 0
var coin_count: int = 0

# 충돌 정보 로그
var collision_log: Array = []

# 테스트용 프레임 제한
var frame_count: int = 0
var max_test_frames: int = 3


func _ready():
	print("\n=== 챕터 5: 물리와 충돌 ===")

	# =============================================
	# 연습 1: 충돌 레이어와 마스크 설정
	# =============================================
	# 풀이: Godot의 물리 시스템은 레이어(Layer)와 마스크(Mask)로 충돌 관계를 제어합니다.
	# - Layer (레이어): "이 노드가 존재하는 물리 레이어" (자신의 위치)
	# - Mask (마스크): "이 노드가 감지할 물리 레이어" (감지 대상)
	#
	# 예: 플레이어가 레이어 1에 있고, 마스크가 2이면
	#     플레이어는 레이어 2에 있는 오브젝트와만 충돌합니다.
	#
	# 레이어 구성 예시:
	#   Layer 1: 플레이어
	#   Layer 2: 적(Enemy)
	#   Layer 3: 벽/지형
	#   Layer 4: 아이템
	#   Layer 5: 총알/투사체
	# 추가 설명: set_collision_layer_value(n, bool)로 특정 레이어를 켜고 끌 수 있고,
	# 비트 연산으로 여러 레이어를 한 번에 설정할 수도 있습니다.
	print("--- 연습 1: 충돌 레이어/마스크 ---")

	# 플레이어 레이어 설정 (Layer 1에 존재)
	collision_layer = 0  # 모든 레이어 초기화
	set_collision_layer_value(1, true)  # Layer 1 활성화

	# 플레이어 마스크 설정 (Layer 2, 3, 4를 감지)
	collision_mask = 0  # 모든 마스크 초기화
	set_collision_mask_value(2, true)   # 적과 충돌 감지
	set_collision_mask_value(3, true)   # 벽/지형과 충돌 감지
	set_collision_mask_value(4, true)   # 아이템과 충돌 감지

	print("결과 1-1 (collision_layer): ", collision_layer)
	print("결과 1-2 (collision_mask): ", collision_mask)
	print("결과 1-3 (Layer 1 활성?): ", get_collision_layer_value(1))
	print("결과 1-4 (Mask 2 활성?): ", get_collision_mask_value(2))
	print("결과 1-5 (Mask 3 활성?): ", get_collision_mask_value(3))
	print("결과 1-6 (Mask 4 활성?): ", get_collision_mask_value(4))
	print("결과 1-7 (Mask 5 활성?): ", get_collision_mask_value(5))

	# =============================================
	# 연습 2: Area2D 충돌 핸들러 설정
	# =============================================
	# 풀이: Area2D는 충돌을 감지하지만 물리적으로 막지 않는 노드입니다.
	# 아이템 수집, 데미지 영역, 트리거 등에 사용합니다.
	# 시그널:
	# - body_entered(body): PhysicsBody2D가 영역에 진입
	# - body_exited(body): PhysicsBody2D가 영역에서 퇴장
	# - area_entered(area): 다른 Area2D가 영역에 진입
	# - area_exited(area): 다른 Area2D가 영역에서 퇴장
	# 추가 설명: Area2D에 CollisionShape2D 자식을 반드시 추가해야 합니다.
	print("--- 연습 2: Area2D 핸들러 ---")

	# 아이템 수집 영역 생성
	var pickup_area = Area2D.new()
	pickup_area.name = "PickupArea"

	# CollisionShape2D 추가 (원형 감지 범위)
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 30.0
	collision_shape.shape = circle_shape
	pickup_area.add_child(collision_shape)

	# Area2D를 플레이어 자식으로 추가
	add_child(pickup_area)

	# 시그널 연결
	# 풀이: body_entered 시그널은 PhysicsBody2D(CharacterBody2D, RigidBody2D 등)가
	# Area2D에 진입할 때 발생합니다. 콜백 함수에서 충돌한 노드를 처리합니다.
	pickup_area.body_entered.connect(_on_pickup_area_body_entered)
	pickup_area.body_exited.connect(_on_pickup_area_body_exited)
	pickup_area.area_entered.connect(_on_pickup_area_area_entered)

	print("결과 2-1 (PickupArea 생성): ", pickup_area.name)
	print("결과 2-2 (감지 반경): ", circle_shape.radius, "px")
	print("결과 2-3 (시그널 연결 완료): true")

	# =============================================
	# 연습 3: RayCast2D 바닥 감지
	# =============================================
	# 풀이: RayCast2D는 특정 방향으로 "광선"을 쏘아 충돌을 감지하는 노드입니다.
	# 바닥 감지, 시야 판단(Line of Sight), 벽 감지 등에 사용합니다.
	# - target_position: 광선의 끝 지점 (로컬 좌표)
	# - is_colliding(): 현재 무언가와 충돌 중인지
	# - get_collider(): 충돌한 오브젝트 반환
	# - get_collision_point(): 충돌 지점 (글로벌 좌표)
	# - get_collision_normal(): 충돌 표면의 법선 벡터
	# 추가 설명: RayCast2D는 enabled = true여야 동작합니다.
	# 여러 개의 RayCast2D를 사용하면 더 정밀한 감지가 가능합니다.
	print("--- 연습 3: RayCast2D 바닥 감지 ---")

	# 아래 방향 레이캐스트 생성
	var floor_ray = RayCast2D.new()
	floor_ray.name = "FloorDetector"
	floor_ray.target_position = Vector2(0, 50)  # 아래로 50px
	floor_ray.enabled = true
	add_child(floor_ray)

	# 왼쪽 아래 레이캐스트 (경사면 감지용)
	var left_ray = RayCast2D.new()
	left_ray.name = "LeftFloorDetector"
	left_ray.target_position = Vector2(-20, 50)
	left_ray.enabled = true
	add_child(left_ray)

	# 오른쪽 아래 레이캐스트 (경사면 감지용)
	var right_ray = RayCast2D.new()
	right_ray.name = "RightFloorDetector"
	right_ray.target_position = Vector2(20, 50)
	right_ray.enabled = true
	add_child(right_ray)

	print("결과 3-1 (FloorDetector 방향): ", floor_ray.target_position)
	print("결과 3-2 (LeftFloor 방향): ", left_ray.target_position)
	print("결과 3-3 (RightFloor 방향): ", right_ray.target_position)
	print("결과 3-4 (활성 상태): ", floor_ray.enabled)

	# =============================================
	# 연습 4: 아이템 수집 시스템
	# =============================================
	# 풀이: 아이템 수집은 Area2D 시그널과 그룹을 조합하여 구현합니다.
	# 1) 아이템 노드를 "items" 그룹에 추가
	# 2) Area2D.body_entered 또는 area_entered에서 그룹 확인
	# 3) 아이템 효과 적용 (점수 증가, 체력 회복 등)
	# 4) 아이템 노드 제거 (queue_free)
	# 추가 설명: queue_free()는 현재 프레임이 끝난 후 안전하게 노드를 삭제합니다.
	# 즉시 삭제하는 free()보다 안전합니다.
	print("--- 연습 4: 아이템 수집 시스템 ---")

	# 테스트용 아이템 생성
	var coin = Area2D.new()
	coin.name = "Coin_01"
	coin.add_to_group("items")
	coin.add_to_group("coins")
	coin.set_meta("item_type", "coin")
	coin.set_meta("value", 10)

	var health_potion = Area2D.new()
	health_potion.name = "HealthPotion_01"
	health_potion.add_to_group("items")
	health_potion.add_to_group("potions")
	health_potion.set_meta("item_type", "potion")
	health_potion.set_meta("value", 25)

	# 아이템에 CollisionShape2D 추가 (실제 동작에 필요)
	for item in [coin, health_potion]:
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(16, 16)
		shape.shape = rect
		item.add_child(shape)

	add_child(coin)
	add_child(health_potion)

	# 수집 시뮬레이션
	_collect_item(coin)
	_collect_item(health_potion)

	print("결과 4-1 (수집된 아이템): ", collected_items)
	print("결과 4-2 (현재 점수): ", score)
	print("결과 4-3 (코인 수): ", coin_count)

	# =============================================
	# 연습 5: 충돌 정보(KinematicCollision2D) 활용
	# =============================================
	# 풀이: move_and_slide() 호출 후 get_slide_collision_count()와
	# get_slide_collision(index)로 충돌 정보를 얻을 수 있습니다.
	# KinematicCollision2D 객체는 다음 정보를 제공합니다:
	# - get_collider(): 충돌한 오브젝트
	# - get_collider_velocity(): 충돌 오브젝트의 속도
	# - get_normal(): 충돌 표면의 법선 벡터
	# - get_position(): 충돌 지점
	# - get_travel(): 충돌 전까지 이동한 거리
	# - get_remainder(): 충돌 후 남은 이동 거리
	# 추가 설명: 법선 벡터(normal)가 Vector2(0, -1)이면 바닥과의 충돌,
	# Vector2(1, 0)이면 왼쪽 벽과의 충돌을 의미합니다.
	print("--- 연습 5: 충돌 정보 활용 ---")

	# 충돌 정보는 _physics_process에서 move_and_slide() 후에 확인합니다.
	# 여기서는 API 설명과 사용 패턴을 출력합니다.
	print("결과 5-1: move_and_slide() 후 충돌 정보 확인 방법:")
	print("  var count = get_slide_collision_count()")
	print("  for i in range(count):")
	print("    var col = get_slide_collision(i)")
	print("    var collider = col.get_collider()     # 충돌 대상")
	print("    var normal = col.get_normal()          # 법선 벡터")
	print("    var position = col.get_position()      # 충돌 지점")

	# =============================================
	# 연습 6: 단방향(One-way) 충돌 플랫폼
	# =============================================
	# 풀이: One-way collision은 한 방향에서만 충돌하는 플랫폼입니다.
	# 플랫포머 게임에서 아래에서 뛰어올라 위에 착지하는 플랫폼에 사용합니다.
	# StaticBody2D의 CollisionShape2D에서 one_way_collision = true로 설정합니다.
	# 추가 설명: one_way_collision_margin으로 감지 두께를 조절합니다.
	# 아래 키를 누르면서 점프하면 통과하는 기능도 구현할 수 있습니다.
	print("--- 연습 6: One-way 충돌 ---")

	# 단방향 플랫폼 생성
	var platform = StaticBody2D.new()
	platform.name = "OneWayPlatform"
	platform.position = Vector2(200, 400)

	var platform_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(200, 10)  # 가로 200, 세로 10의 얇은 플랫폼
	platform_shape.shape = rect_shape

	# one-way collision 활성화
	platform_shape.one_way_collision = true
	platform_shape.one_way_collision_margin = 4.0  # 감지 마진 (기본: 1.0)

	platform.add_child(platform_shape)
	get_parent().add_child.call_deferred(platform) if get_parent() else add_child(platform)

	print("결과 6-1 (플랫폼 위치): ", platform.position)
	print("결과 6-2 (플랫폼 크기): ", rect_shape.size)
	print("결과 6-3 (one_way_collision): ", platform_shape.one_way_collision)
	print("결과 6-4 (one_way_margin): ", platform_shape.one_way_collision_margin)

	print("=== 완료 ===\n")


# =============================================
# Area2D 시그널 핸들러 함수들
# =============================================

# 풀이: body_entered는 PhysicsBody2D(CharacterBody2D, RigidBody2D 등)가
# Area2D에 진입할 때 호출됩니다.
func _on_pickup_area_body_entered(body: Node2D):
	print("  [Area2D] body_entered: ", body.name)

	# 그룹으로 아이템인지 확인
	if body.is_in_group("items"):
		_collect_item(body)

	# 적인지 확인
	if body.is_in_group("enemies"):
		print("  [경고] 적과 접촉: ", body.name)


func _on_pickup_area_body_exited(body: Node2D):
	print("  [Area2D] body_exited: ", body.name)


# 풀이: area_entered는 다른 Area2D가 이 Area2D에 진입할 때 호출됩니다.
# Area2D끼리의 겹침을 감지합니다.
func _on_pickup_area_area_entered(area: Area2D):
	print("  [Area2D] area_entered: ", area.name)

	if area.is_in_group("items"):
		_collect_item(area)


# =============================================
# 아이템 수집 처리 함수
# =============================================
# 풀이: 아이템 수집 로직을 별도 함수로 분리하면 재사용성이 높아집니다.
func _collect_item(item: Node):
	var item_type: String = item.get_meta("item_type") if item.has_meta("item_type") else "unknown"
	var item_value: int = item.get_meta("value") if item.has_meta("value") else 0

	collected_items.append(item.name)

	match item_type:
		"coin":
			score += item_value
			coin_count += 1
			print("  [수집] 코인 획득! +", item_value, "점")
		"potion":
			score += item_value
			print("  [수집] 포션 획득! 회복량: ", item_value)
		_:
			print("  [수집] 알 수 없는 아이템: ", item.name)

	# 실제 게임에서는 아이템 노드를 삭제합니다
	# item.queue_free()


func _physics_process(delta: float):
	# 중력 적용
	if not is_on_floor():
		velocity.y += gravity_force * delta

	# 이동 입력
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * move_speed

	# 점프
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force

	# 이동 실행
	move_and_slide()

	# 충돌 정보 확인 (연습 5 실제 동작)
	if frame_count < max_test_frames:
		frame_count += 1
		var collision_count = get_slide_collision_count()
		if collision_count > 0:
			for i in range(collision_count):
				var col = get_slide_collision(i)
				var collider = col.get_collider()
				var normal = col.get_normal()
				collision_log.append({
					"collider": collider.name if collider else "null",
					"normal": normal
				})
				print("  [충돌] 대상: ", collider.name if collider else "null",
					  ", 법선: ", normal)
