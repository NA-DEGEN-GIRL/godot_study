# Chapter 02 - GDScript Basics
# 05-classes-enums.gd - Classes, Enums, and Inheritance
#
# 이 파일에서 배울 내용:
# - class_name으로 전역 클래스 등록
# - 내부 클래스 (Inner Class) 정의
# - enum으로 열거형 상수 만들기
# - extends와 상속(Inheritance) 기초

extends Node

# ============================================
# 1. enum (열거형)
# ============================================

# 이름 없는 enum (상수처럼 사용)
enum { NORTH, SOUTH, EAST, WEST }  # 0, 1, 2, 3

# 이름 있는 enum (네임스페이스처럼 사용)
enum Direction {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
}

enum State {
	IDLE,      # 0
	WALKING,   # 1
	RUNNING,   # 2
	JUMPING,   # 3
	FALLING,   # 4
	ATTACKING, # 5
	DEAD,      # 6
}

# 값을 직접 지정하는 enum
enum Element {
	FIRE = 10,
	WATER = 20,
	EARTH = 30,
	WIND = 40,
}

# 비트 플래그용 enum
enum StatusEffect {
	NONE = 0,
	POISON = 1 << 0,    # 1
	BURN = 1 << 1,      # 2
	FREEZE = 1 << 2,    # 4
	STUN = 1 << 3,      # 8
	SLOW = 1 << 4,      # 16
}

# ============================================
# 2. 내부 클래스 (Inner Class)
# ============================================

# 내부 클래스는 파일 안에서 정의하는 클래스입니다
# class_name 없이 파일 내부에서만 사용 가능합니다

class Item:
	var item_name: String
	var description: String
	var price: int
	var stackable: bool

	func _init(p_name: String, p_desc: String = "", p_price: int = 0, p_stackable: bool = true):
		item_name = p_name
		description = p_desc
		price = p_price
		stackable = p_stackable

	func get_info() -> String:
		return "%s (%d골드) - %s" % [item_name, price, description]

	func _to_string() -> String:
		return "[Item: %s]" % item_name


class Weapon:
	extends Item  # Item을 상속하는 내부 클래스

	var damage: int
	var attack_speed: float

	func _init(p_name: String, p_damage: int, p_speed: float, p_price: int = 0):
		super._init(p_name, "무기", p_price, false)  # 부모 _init 호출
		damage = p_damage
		attack_speed = p_speed

	# 메서드 오버라이드
	func get_info() -> String:
		return "%s (공격력:%d, 속도:%.1f) - %d골드" % [item_name, damage, attack_speed, price]

	func calculate_dps() -> float:
		return damage * attack_speed


class Armor:
	extends Item

	var defense: int
	var weight: float
	var slot: String  # "head", "body", "legs", "feet"

	func _init(p_name: String, p_defense: int, p_weight: float, p_slot: String, p_price: int = 0):
		super._init(p_name, "방어구", p_price, false)
		defense = p_defense
		weight = p_weight
		slot = p_slot

	func get_info() -> String:
		return "%s [%s] (방어력:%d, 무게:%.1f) - %d골드" % [item_name, slot, defense, weight, price]


# ============================================
# 3. 인벤토리 클래스 (컴포지션 예제)
# ============================================

class Inventory:
	var items: Array = []
	var max_slots: int

	func _init(p_max_slots: int = 20):
		max_slots = p_max_slots

	func add_item(item: Item) -> bool:
		if items.size() >= max_slots:
			print("  인벤토리가 가득 찼습니다!")
			return false
		items.append(item)
		print("  '%s' 추가됨" % item.item_name)
		return true

	func remove_item(item_name: String) -> bool:
		for i in range(items.size()):
			if items[i].item_name == item_name:
				items.remove_at(i)
				print("  '%s' 제거됨" % item_name)
				return true
		print("  '%s'을(를) 찾을 수 없습니다" % item_name)
		return false

	func find_item(item_name: String) -> Item:
		for item in items:
			if item.item_name == item_name:
				return item
		return null

	func get_total_value() -> int:
		var total := 0
		for item in items:
			total += item.price
		return total

	func list_items() -> void:
		if items.is_empty():
			print("  (비어있음)")
			return
		for i in range(items.size()):
			print("  [%d] %s" % [i, items[i].get_info()])


# ============================================
# 4. 캐릭터 클래스 (종합 예제)
# ============================================

class Character:
	var char_name: String
	var level: int
	var hp: int
	var max_hp: int
	var mp: int
	var max_mp: int
	var state: State
	var element: Element
	var status_effects: int  # 비트 플래그
	var inventory: Inventory

	func _init(p_name: String, p_level: int = 1, p_element: Element = Element.FIRE):
		char_name = p_name
		level = p_level
		max_hp = 100 + (level - 1) * 20
		hp = max_hp
		max_mp = 50 + (level - 1) * 10
		mp = max_mp
		state = State.IDLE
		element = p_element
		status_effects = StatusEffect.NONE
		inventory = Inventory.new(10)

	func take_damage(amount: int) -> void:
		hp -= amount
		if hp <= 0:
			hp = 0
			state = State.DEAD
			print("  %s이(가) 쓰러졌습니다!" % char_name)
		else:
			print("  %s이(가) %d 데미지를 받았습니다! (HP: %d/%d)" % [char_name, amount, hp, max_hp])

	func heal(amount: int) -> void:
		if state == State.DEAD:
			print("  %s은(는) 이미 쓰러졌습니다!" % char_name)
			return
		hp = mini(hp + amount, max_hp)
		print("  %s이(가) %d 회복! (HP: %d/%d)" % [char_name, amount, hp, max_hp])

	func add_status(effect: StatusEffect) -> void:
		status_effects |= effect
		print("  %s에게 상태이상 적용! (flags: %d)" % [char_name, status_effects])

	func remove_status(effect: StatusEffect) -> void:
		status_effects &= ~effect

	func has_status(effect: StatusEffect) -> bool:
		return (status_effects & effect) != 0

	func get_element_name() -> String:
		match element:
			Element.FIRE: return "불"
			Element.WATER: return "물"
			Element.EARTH: return "땅"
			Element.WIND: return "바람"
			_: return "없음"

	func get_state_name() -> String:
		match state:
			State.IDLE: return "대기"
			State.WALKING: return "걷기"
			State.RUNNING: return "달리기"
			State.JUMPING: return "점프"
			State.FALLING: return "낙하"
			State.ATTACKING: return "공격"
			State.DEAD: return "사망"
			_: return "알 수 없음"

	func print_status() -> void:
		print("  === %s (Lv.%d) ===" % [char_name, level])
		print("  HP: %d/%d | MP: %d/%d" % [hp, max_hp, mp, max_mp])
		print("  속성: %s | 상태: %s" % [get_element_name(), get_state_name()])
		if has_status(StatusEffect.POISON):
			print("  [독]", )
		if has_status(StatusEffect.BURN):
			print("  [화상]")
		if has_status(StatusEffect.FREEZE):
			print("  [빙결]")


# ============================================
# _ready() - 실행 예제
# ============================================

func _ready():
	print("=== 클래스와 열거형 ===\n")

	# ============================================
	# enum 사용 예제
	# ============================================
	print("--- enum 사용 ---\n")

	# 이름 없는 enum
	print("이름 없는 enum: NORTH=%d, SOUTH=%d, EAST=%d, WEST=%d" % [NORTH, SOUTH, EAST, WEST])

	# 이름 있는 enum
	var dir := Direction.RIGHT
	print("Direction.RIGHT = ", dir)

	match dir:
		Direction.UP: print("위")
		Direction.DOWN: print("아래")
		Direction.LEFT: print("왼쪽")
		Direction.RIGHT: print("오른쪽")

	# enum 값 순회
	print("\nState enum 값들:")
	for state_name in State.keys():
		print("  %s = %d" % [state_name, State[state_name]])

	# Element enum
	print("\nElement enum:")
	for elem_name in Element.keys():
		print("  %s = %d" % [elem_name, Element[elem_name]])

	# 비트 플래그 연산
	print("\n비트 플래그 (StatusEffect):")
	var effects := StatusEffect.POISON | StatusEffect.BURN
	print("  POISON | BURN = ", effects)
	print("  POISON 포함?: ", (effects & StatusEffect.POISON) != 0)
	print("  FREEZE 포함?: ", (effects & StatusEffect.FREEZE) != 0)

	# ============================================
	# 내부 클래스 사용
	# ============================================
	print("\n--- 내부 클래스 ---\n")

	# Item 생성
	var potion := Item.new("체력 포션", "HP를 50 회복", 30)
	var arrow := Item.new("화살", "기본 화살", 5)
	print("아이템: ", potion.get_info())
	print("아이템: ", arrow.get_info())

	# Weapon 생성 (Item 상속)
	var sword := Weapon.new("철검", 25, 1.5, 200)
	var bow := Weapon.new("단궁", 15, 2.0, 150)
	print("\n무기: ", sword.get_info())
	print("무기: ", bow.get_info())
	print("철검 DPS: %.1f" % sword.calculate_dps())
	print("단궁 DPS: %.1f" % bow.calculate_dps())

	# Armor 생성 (Item 상속)
	var helmet := Armor.new("철 투구", 10, 3.0, "head", 80)
	var chestplate := Armor.new("강철 갑옷", 30, 15.0, "body", 500)
	print("\n방어구: ", helmet.get_info())
	print("방어구: ", chestplate.get_info())

	# ============================================
	# 인벤토리 시스템
	# ============================================
	print("\n--- 인벤토리 시스템 ---\n")

	var inv := Inventory.new(5)  # 최대 5칸

	inv.add_item(potion)
	inv.add_item(sword)
	inv.add_item(arrow)
	inv.add_item(helmet)
	inv.add_item(chestplate)

	print("\n인벤토리 목록:")
	inv.list_items()

	print("\n총 가치: %d골드" % inv.get_total_value())

	# 아이템 검색
	var found := inv.find_item("철검")
	if found:
		print("\n검색 결과: ", found.get_info())

	# 아이템 제거
	print("")
	inv.remove_item("화살")
	print("\n인벤토리 (제거 후):")
	inv.list_items()

	# ============================================
	# 캐릭터 시스템 (종합)
	# ============================================
	print("\n--- 캐릭터 시스템 ---\n")

	var hero := Character.new("용사", 5, Element.FIRE)
	hero.print_status()

	print("\n전투 시뮬레이션:")
	hero.take_damage(30)
	hero.add_status(StatusEffect.BURN)
	hero.take_damage(20)
	hero.heal(25)
	hero.add_status(StatusEffect.POISON)

	print("\n전투 후 상태:")
	hero.print_status()

	# 인벤토리에 아이템 추가
	print("\n용사의 인벤토리:")
	hero.inventory.add_item(Item.new("체력 포션", "HP 50 회복", 30))
	hero.inventory.add_item(Weapon.new("불의 검", 40, 1.2, 1000))
	hero.inventory.list_items()

	# ============================================
	# class_name 설명
	# ============================================
	print("\n--- class_name (설명) ---\n")

	# class_name은 파일 최상단에 선언하여
	# 전역으로 접근 가능한 클래스를 만듭니다.
	#
	# 예시 (player.gd 파일):
	# class_name Player
	# extends CharacterBody2D
	#
	# 다른 스크립트에서:
	# var p = Player.new()
	#
	# class_name의 장점:
	# 1. preload() 없이 다른 스크립트에서 바로 사용 가능
	# 2. 에디터에서 커스텀 타입으로 인식
	# 3. @export var enemy: Enemy 처럼 타입 힌트에 사용 가능
	# 4. is 키워드로 타입 체크 가능: if node is Player

	print("class_name은 전역 클래스를 만듭니다")
	print("예: class_name Player -> 어디서든 Player.new() 가능")
	print("주의: 같은 이름의 class_name은 프로젝트에서 유일해야 합니다")

	# ============================================
	# 상속 구조 정리
	# ============================================
	print("\n--- 상속 정리 ---\n")

	print("Godot의 상속 구조:")
	print("  Object")
	print("  └── RefCounted (참조 카운팅 메모리 관리)")
	print("  │   └── Resource (리소스 파일)")
	print("  └── Node (씬 트리 노드)")
	print("      ├── Node2D (2D 노드)")
	print("      │   ├── Sprite2D")
	print("      │   ├── CharacterBody2D")
	print("      │   └── Area2D")
	print("      ├── Node3D (3D 노드)")
	print("      │   ├── MeshInstance3D")
	print("      │   └── CharacterBody3D")
	print("      └── Control (UI 노드)")
	print("          ├── Button")
	print("          ├── Label")
	print("          └── Panel")

	# ============================================
	# 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. enum: 이름이 있는 정수 상수 그룹")
	print("2. enum Flags: 비트 플래그로 여러 상태 조합")
	print("3. class: 내부 클래스 (파일 내에서 사용)")
	print("4. class_name: 전역 클래스 (프로젝트 전체에서 사용)")
	print("5. extends: 상속 (부모 클래스 기능 재사용)")
	print("6. super._init(): 부모 클래스 생성자 호출")
	print("7. 오버라이드: 부모 메서드를 자식에서 재정의")
