# 챕터 5: 물리와 충돌
#
# 이 챕터에서는 다음을 학습합니다:
# - 충돌 레이어(Layer)와 마스크(Mask)의 개념
# - Area2D의 body_entered 시그널 처리
# - RayCast2D를 이용한 바닥 감지
# - 아이템 수집(pickup) 패턴
# - KinematicCollision2D에서 충돌 정보 읽기
# - One-Way Platform (단방향 플랫폼) 통과 로직

extends Node


# =============================================
# 게임 상수 및 상태 변수
# =============================================
const LAYER_PLAYER: int = 1
const LAYER_ENEMY: int = 2
const LAYER_ITEM: int = 4
const LAYER_PLATFORM: int = 8

var player_health: int = 100
var collected_items: Array = []
var score: int = 0


func _ready():
	# =============================================
	# 연습 1: 충돌 레이어/마스크 설정
	# =============================================
	# TODO: setup_collision_layers() 함수를 완성하세요
	# Godot의 충돌 레이어 시스템을 이해하고 설정값을 반환합니다
	# - Layer: 이 오브젝트가 존재하는 물리 레이어 (자신이 무엇인지)
	# - Mask: 이 오브젝트가 감지할 물리 레이어 (무엇과 충돌할지)
	#
	# 시나리오:
	# 레이어 1 = Player, 레이어 2 = Enemy, 레이어 3 = Item, 레이어 4 = Platform
	# - 플레이어: 레이어1에 존재, 적/아이템/플랫폼과 충돌 (마스크 2,3,4)
	# - 적: 레이어2에 존재, 플레이어/플랫폼과 충돌 (마스크 1,4)
	# - 아이템: 레이어3에 존재, 플레이어만 감지 (마스크 1)
	var collision_config = setup_collision_layers()

	# =============================================
	# 연습 2: Area2D body_entered 핸들러
	# =============================================
	# TODO: on_body_entered() 함수를 완성하세요
	# Area2D에 물체가 들어왔을 때 호출되는 시그널 핸들러입니다
	# body의 타입에 따라 다른 처리를 합니다
	# 테스트용 시뮬레이션 데이터로 확인합니다
	var enemy_data = {"name": "Slime", "type": "enemy", "damage": 10}
	var item_data = {"name": "Coin", "type": "item", "value": 50}
	var neutral_data = {"name": "Rock", "type": "obstacle", "damage": 0}

	player_health = 100
	score = 0
	collected_items = []

	var result_enemy = on_body_entered(enemy_data)
	var result_item = on_body_entered(item_data)
	var result_neutral = on_body_entered(neutral_data)

	# =============================================
	# 연습 3: RayCast2D 바닥 감지
	# =============================================
	# TODO: check_ground_raycast() 함수를 완성하세요
	# RayCast2D 설정값과 바닥 감지 로직을 구현합니다
	# 실제 RayCast2D 노드 없이 로직만 구현합니다
	var raycast_config = check_ground_raycast()

	# =============================================
	# 연습 4: 아이템 수집 함수
	# =============================================
	# TODO: collect_item() 함수를 완성하세요
	# 아이템 데이터를 받아 인벤토리에 추가하고 점수를 갱신합니다
	collected_items = []
	score = 0
	var coin = {"name": "Gold Coin", "value": 100, "type": "coin"}
	var potion = {"name": "Health Potion", "value": 50, "type": "potion", "heal": 30}
	var gem = {"name": "Ruby", "value": 500, "type": "gem"}

	collect_item(coin)
	collect_item(potion)
	collect_item(gem)

	var total_score = score
	var total_items = collected_items.size()

	# =============================================
	# 연습 5: 충돌 정보 읽기
	# =============================================
	# TODO: read_collision_info() 함수를 완성하세요
	# KinematicCollision2D에서 읽을 수 있는 충돌 정보를 시뮬레이션합니다
	# 실제 충돌 데이터를 딕셔너리로 표현하여 처리합니다
	var collision_data = {
		"position": Vector2(100, 200),
		"normal": Vector2(0, -1),
		"collider_name": "Floor",
		"collider_velocity": Vector2.ZERO,
		"travel": Vector2(5, 0),
		"remainder": Vector2(0, 3)
	}
	var collision_result = read_collision_info(collision_data)

	# =============================================
	# 연습 6: one-way platform 통과 로직
	# =============================================
	# TODO: check_one_way_platform() 함수를 완성하세요
	# 단방향 플랫폼은 아래에서 위로 통과 가능하지만 위에서는 착지합니다
	# velocity_y가 양수(아래로 떨어지는 중)이고 플레이어가 플랫폼 위에 있을 때만 충돌
	var case1 = check_one_way_platform(100.0, 180.0, 200.0)  # 위에서 떨어짐 -> 충돌
	var case2 = check_one_way_platform(-200.0, 220.0, 200.0) # 아래에서 올라감 -> 통과
	var case3 = check_one_way_platform(50.0, 220.0, 200.0)   # 아래에서 떨어짐 -> 통과
	var case4 = check_one_way_platform(100.0, 195.0, 200.0)  # 위에서 떨어짐 -> 충돌

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 5: 물리와 충돌 ===")

	print("--- 연습 1: 충돌 레이어/마스크 ---")
	print("결과 1 (충돌 설정): ", collision_config)

	print("--- 연습 2: body_entered 핸들러 ---")
	print("결과 2-1 (적 충돌): ", result_enemy)
	print("결과 2-2 (아이템 충돌): ", result_item)
	print("결과 2-3 (중립 충돌): ", result_neutral)
	print("결과 2 (체력): ", player_health, " (기대값: 90)")
	print("결과 2 (점수): ", score, " (기대값: 50)")

	print("--- 연습 3: RayCast2D 바닥 감지 ---")
	print("결과 3 (레이캐스트 설정): ", raycast_config)

	print("--- 연습 4: 아이템 수집 ---")
	print("결과 4-1 (총 점수): ", total_score, " (기대값: 650)")
	print("결과 4-2 (아이템 수): ", total_items, " (기대값: 3)")
	print("결과 4-3 (수집 목록): ", collected_items)

	print("--- 연습 5: 충돌 정보 읽기 ---")
	print("결과 5 (충돌 분석): ", collision_result)

	print("--- 연습 6: one-way platform ---")
	print("결과 6-1 (위에서 떨어짐): ", case1, " (기대값: true/충돌)")
	print("결과 6-2 (아래에서 올라감): ", case2, " (기대값: false/통과)")
	print("결과 6-3 (아래에서 떨어짐): ", case3, " (기대값: false/통과)")
	print("결과 6-4 (위에서 떨어짐): ", case4, " (기대값: true/충돌)")
	print("=== 완료 ===\n")


# =============================================
# 연습 1: 충돌 레이어/마스크 설정 함수
# =============================================
# TODO: 각 오브젝트 타입의 레이어와 마스크 설정을 딕셔너리로 반환하세요
# 반환 형식:
# {
#   "player": {"layer": [1], "mask": [2, 3, 4]},
#   "enemy": {"layer": [2], "mask": [1, 4]},
#   "item": {"layer": [3], "mask": [1]}
# }
# 힌트: 레이어 번호는 정수 배열로 표현합니다
func setup_collision_layers() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 2: Area2D body_entered 핸들러
# =============================================
# TODO: 들어온 바디 데이터에 따라 적절한 처리를 하고 결과 문자열을 반환하세요
# - type이 "enemy": player_health -= damage, 반환: "데미지 {damage} 받음"
# - type이 "item": score += value, 반환: "{name} 획득! +{value}점"
# - 그 외: 반환: "{name} 접촉"
# 매개변수: body_data(Dictionary) - name, type, damage/value 키를 포함
func on_body_entered(body_data: Dictionary) -> String:
	return ""  # 여기를 수정하세요


# =============================================
# 연습 3: RayCast2D 바닥 감지 함수
# =============================================
# TODO: RayCast2D 설정값과 사용법을 딕셔너리로 반환하세요
# 바닥 감지용 RayCast2D의 설정:
# {
#   "target_position": Vector2(0, 10),   -- 아래 방향으로 10px
#   "enabled": true,
#   "collision_mask": 1,                 -- 충돌 감지 대상 레이어
#   "collide_with_areas": false,
#   "collide_with_bodies": true,
#   "usage_example": "if raycast.is_colliding(): var collider = raycast.get_collider()"
# }
func check_ground_raycast() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 4: 아이템 수집 함수
# =============================================
# TODO: 아이템을 수집하여 collected_items에 추가하고 score에 가산하세요
# - collected_items 배열에 아이템 이름을 추가
# - score에 아이템의 value를 가산
# - type이 "potion"이면 player_health도 heal만큼 회복 (최대 100)
# 매개변수: item(Dictionary) - name, value, type (선택: heal) 키 포함
func collect_item(item: Dictionary) -> void:
	pass  # 여기를 수정하세요


# =============================================
# 연습 5: 충돌 정보 읽기 함수
# =============================================
# TODO: 충돌 데이터 딕셔너리를 분석하여 의미있는 정보를 반환하세요
# 분석 내용:
# - is_floor: normal.y가 -1에 가까우면 바닥 (abs(normal.y + 1) < 0.1)
# - is_wall: normal.x의 절대값이 1에 가까우면 벽 (abs(abs(normal.x) - 1) < 0.1)
# - is_ceiling: normal.y가 1에 가까우면 천장 (abs(normal.y - 1) < 0.1)
# - collider_name: 충돌한 오브젝트 이름
# - slide_direction: 슬라이드 가능한 방향 (normal과 수직)
#
# 반환 형식:
# {
#   "is_floor": true/false,
#   "is_wall": true/false,
#   "is_ceiling": true/false,
#   "collider_name": "Floor",
#   "contact_point": Vector2(100, 200)
# }
func read_collision_info(collision_data: Dictionary) -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 6: one-way platform 통과 로직 함수
# =============================================
# TODO: 단방향 플랫폼과의 충돌 여부를 판단하세요
# 규칙:
# - 플레이어가 플랫폼 위에 있고 (player_y <= platform_y) 아래로 떨어지는 중
#   (velocity_y > 0)이면 충돌 (true)
# - 플레이어가 플랫폼 아래에 있으면 (player_y > platform_y) 통과 (false)
# - 위로 올라가는 중 (velocity_y < 0)이면 항상 통과 (false)
#
# 매개변수:
#   velocity_y: y축 속도 (양수: 아래로, 음수: 위로)
#   player_y: 플레이어의 y 위치 (Godot에서 아래가 양수)
#   platform_y: 플랫폼의 y 위치
# 반환: true(충돌/착지), false(통과)
func check_one_way_platform(velocity_y: float, player_y: float, platform_y: float) -> bool:
	return false  # 여기를 수정하세요
