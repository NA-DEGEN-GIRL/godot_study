# Chapter 12 - Project Patterns
# 03-component-pattern.gd - 컴포넌트(Component) 패턴
#
# 이 파일에서 배울 내용:
# - 컴포넌트 패턴의 개념과 장점
# - HealthComponent: HP 관리, 대미지, 회복, 무적
# - HitboxComponent / HurtboxComponent: 전투 시스템
# - 컴포넌트 간 통신 (시그널 기반)
# - 컴포넌트 조합으로 다양한 엔티티 생성

extends Node

func _ready():
	print("=== Chapter 12-3: 컴포넌트(Component) 패턴 ===\n")

	# -----------------------------------------------------------------
	# 1) 컴포넌트 패턴이란?
	# -----------------------------------------------------------------
	print("--- 1. 컴포넌트 패턴 개념 ---")

	print("  상속(Inheritance) 방식의 문제:")
	print("    Character")
	print("    +-- Player (이동 + 공격 + HP)")
	print("    +-- Enemy (이동 + 공격 + HP + AI)")
	print("    +-- NPC (이동 + 대화)")
	print("    +-- Destructible (HP만 필요)")
	print("    -> 공통 기능을 어디에 둘 것인가? 다중 상속 불가!")
	print()

	print("  컴포넌트(Composition) 방식:")
	print("    엔티티는 빈 껍데기, 기능은 컴포넌트로 추가")
	print("    Player = Entity + HealthComp + MoveComp + AttackComp")
	print("    Enemy  = Entity + HealthComp + MoveComp + AttackComp + AIComp")
	print("    NPC    = Entity + MoveComp + DialogComp")
	print("    Box    = Entity + HealthComp")
	print("    -> 조합의 자유!")
	print()

	print("  Godot에서의 구현:")
	print("    Player (CharacterBody2D)")
	print("    +-- HealthComponent (Node)")
	print("    +-- HitboxComponent (Area2D)")
	print("    +-- HurtboxComponent (Area2D)")
	print("    +-- Sprite2D")
	print("    +-- CollisionShape2D")
	print()

	# -----------------------------------------------------------------
	# 2) HealthComponent 구현
	# -----------------------------------------------------------------
	print("--- 2. HealthComponent ---")

	var health = HealthComponent.new(100, 100)
	print("  생성: HP %d/%d" % [health.current_hp, health.max_hp])

	# 시그널 연결
	health.damaged.connect(func(amount, current):
		print("    [시그널] %d 대미지! HP: %d" % [amount, current])
	)
	health.healed.connect(func(amount, current):
		print("    [시그널] %d 회복! HP: %d" % [amount, current])
	)
	health.died.connect(func():
		print("    [시그널] 사망!")
	)
	health.invincibility_started.connect(func():
		print("    [시그널] 무적 시작")
	)
	health.invincibility_ended.connect(func():
		print("    [시그널] 무적 종료")
	)

	# 대미지
	print()
	print("  대미지 테스트:")
	health.take_damage(30)
	print("    HP: %d/%d (%.0f%%)" % [health.current_hp, health.max_hp, health.hp_percent()])

	# 무적 상태에서 대미지
	health.set_invincible(true)
	health.take_damage(50)
	print("    무적 중 대미지: HP %d (변화 없음)" % health.current_hp)
	health.set_invincible(false)

	# 회복
	health.heal(20)
	print("    회복 후: HP %d" % health.current_hp)

	# 과다 회복 (최대 HP 초과 불가)
	health.heal(999)
	print("    과다 회복: HP %d (최대치 제한)" % health.current_hp)

	# 치명적 대미지
	health.take_damage(999)
	print("    치명적 대미지: HP %d, alive=%s" % [health.current_hp, health.is_alive()])
	print()

	# 리셋
	health.reset()
	print("  리셋 후: HP %d/%d" % [health.current_hp, health.max_hp])
	print()

	# -----------------------------------------------------------------
	# 3) HitboxComponent / HurtboxComponent
	# -----------------------------------------------------------------
	print("--- 3. Hitbox / Hurtbox 시스템 ---")

	print("  용어 정의:")
	print("    Hitbox  = 공격 판정 영역 (대미지를 '주는' 쪽)")
	print("    Hurtbox = 피격 판정 영역 (대미지를 '받는' 쪽)")
	print()

	print("  상호작용:")
	print("    공격자의 Hitbox가 피격자의 Hurtbox와 겹치면")
	print("    -> 피격자의 HealthComponent에 대미지 전달")
	print()

	print("  Godot 구현 (Area2D 기반):")
	print("    # hitbox_component.gd")
	print("    extends Area2D")
	print("    @export var damage: float = 10.0")
	print("    @export var knockback_force: float = 200.0")
	print()
	print("    # hurtbox_component.gd")
	print("    extends Area2D")
	print("    signal hit_received(hitbox: Area2D)")
	print("    var health_component: HealthComponent")
	print()
	print("    func _ready():")
	print("        area_entered.connect(_on_area_entered)")
	print()
	print("    func _on_area_entered(hitbox: Area2D):")
	print("        if hitbox.is_in_group(\"hitbox\"):")
	print("            var damage = hitbox.damage")
	print("            health_component.take_damage(damage)")
	print("            hit_received.emit(hitbox)")
	print()

	# 전투 시뮬레이션
	print("  [전투 시뮬레이션]")
	var player_health = HealthComponent.new(100, 100)
	var enemy_health = HealthComponent.new(50, 50)

	var player_hitbox = HitboxData.new("player_sword", 25, 150.0)
	var enemy_hitbox = HitboxData.new("enemy_claw", 15, 80.0)

	print("    플레이어: HP %d, 공격력 %d" % [player_health.current_hp, player_hitbox.damage])
	print("    적: HP %d, 공격력 %d" % [enemy_health.current_hp, enemy_hitbox.damage])
	print()

	# 플레이어가 적을 공격
	_simulate_hit(player_hitbox, enemy_health, "플레이어 -> 적")
	_simulate_hit(player_hitbox, enemy_health, "플레이어 -> 적")
	print("    적 HP: %d" % enemy_health.current_hp)

	# 적이 플레이어를 공격
	_simulate_hit(enemy_hitbox, player_health, "적 -> 플레이어")
	print("    플레이어 HP: %d" % player_health.current_hp)

	# 마무리
	_simulate_hit(player_hitbox, enemy_health, "플레이어 -> 적")
	print("    적 alive: %s" % enemy_health.is_alive())
	print()

	# -----------------------------------------------------------------
	# 4) 충돌 레이어 설정
	# -----------------------------------------------------------------
	print("--- 4. 충돌 레이어 설정 ---")

	print("  권장 레이어 구성:")
	print("    Layer 1: 월드 (벽, 바닥)")
	print("    Layer 2: 플레이어 본체")
	print("    Layer 3: 적 본체")
	print("    Layer 4: 플레이어 Hitbox")
	print("    Layer 5: 플레이어 Hurtbox")
	print("    Layer 6: 적 Hitbox")
	print("    Layer 7: 적 Hurtbox")
	print("    Layer 8: 아이템")
	print()

	print("  마스크 설정 예시:")
	print("    플레이어 Hitbox: Layer=4, Mask=7 (적 Hurtbox 감지)")
	print("    적 Hitbox:       Layer=6, Mask=5 (플레이어 Hurtbox 감지)")
	print("    플레이어 본체:   Layer=2, Mask=1,8 (월드+아이템)")
	print()

	# -----------------------------------------------------------------
	# 5) 추가 컴포넌트들
	# -----------------------------------------------------------------
	print("--- 5. 추가 컴포넌트 예시 ---")

	# MovementComponent
	print("  a) MovementComponent:")
	var mover = MovementComponent.new(200.0, 800.0, 0.3)
	print("    속도: %.0f, 가속: %.0f, 마찰: %.1f" % [
		mover.max_speed, mover.acceleration, mover.friction
	])

	mover.apply_input(Vector2(1, 0), 0.016)
	mover.apply_input(Vector2(1, 0), 0.016)
	mover.apply_input(Vector2(1, 0), 0.016)
	print("    3프레임 오른쪽 이동 후 속도: %s" % mover.velocity)

	mover.apply_input(Vector2.ZERO, 0.016)
	print("    입력 없음 (마찰): %s" % mover.velocity)
	print()

	# KnockbackComponent
	print("  b) KnockbackComponent:")
	var knockback = KnockbackComponent.new()
	knockback.apply_knockback(Vector2(1, -0.5).normalized(), 300.0)
	print("    넉백 적용: %s" % knockback.velocity)

	for i in range(5):
		knockback.update(0.016)
	print("    5프레임 후: %s (감쇠)" % knockback.velocity)
	print()

	# -----------------------------------------------------------------
	# 6) 컴포넌트 조합 예시
	# -----------------------------------------------------------------
	print("--- 6. 컴포넌트 조합으로 엔티티 구성 ---")

	print("  Entity 구성 예시:")
	print()

	# 플레이어
	var player_entity = EntityBuilder.new("Player")
	player_entity.add_component("health", {"max_hp": 100})
	player_entity.add_component("movement", {"speed": 200})
	player_entity.add_component("hitbox", {"damage": 25})
	player_entity.add_component("hurtbox", {})
	player_entity.add_component("inventory", {"slots": 20})
	print("  %s: %s" % [player_entity.name, player_entity.get_component_names()])

	# 적
	var enemy_entity = EntityBuilder.new("Goblin")
	enemy_entity.add_component("health", {"max_hp": 50})
	enemy_entity.add_component("movement", {"speed": 120})
	enemy_entity.add_component("hitbox", {"damage": 10})
	enemy_entity.add_component("hurtbox", {})
	enemy_entity.add_component("ai", {"type": "patrol"})
	enemy_entity.add_component("loot_table", {"drops": ["gold", "potion"]})
	print("  %s: %s" % [enemy_entity.name, enemy_entity.get_component_names()])

	# NPC
	var npc_entity = EntityBuilder.new("Merchant")
	npc_entity.add_component("movement", {"speed": 50})
	npc_entity.add_component("dialog", {"dialog_id": "merchant_01"})
	npc_entity.add_component("shop", {"items": ["potion", "sword"]})
	print("  %s: %s" % [npc_entity.name, npc_entity.get_component_names()])

	# 파괴 가능 오브젝트
	var crate_entity = EntityBuilder.new("Crate")
	crate_entity.add_component("health", {"max_hp": 20})
	crate_entity.add_component("hurtbox", {})
	crate_entity.add_component("loot_table", {"drops": ["coin"]})
	print("  %s: %s" % [crate_entity.name, crate_entity.get_component_names()])
	print()

	# -----------------------------------------------------------------
	# 7) 컴포넌트 간 통신 패턴
	# -----------------------------------------------------------------
	print("--- 7. 컴포넌트 간 통신 ---")

	print("  방법 1: 시그널 (권장, 느슨한 결합)")
	print("    # hurtbox -> health")
	print("    hurtbox.hit_received.connect(health.take_damage)")
	print()
	print("    # health -> 여러 컴포넌트")
	print("    health.died.connect(loot_table.drop_items)")
	print("    health.died.connect(sprite.play_death_animation)")
	print("    health.died.connect(collision.set_disabled.bind(true))")
	print()

	print("  방법 2: 부모 노드를 통한 접근")
	print("    # 컴포넌트에서 같은 엔티티의 다른 컴포넌트 접근")
	print("    var health = get_parent().get_node(\"HealthComponent\")")
	print("    # 또는")
	print("    var health = owner.get_node(\"HealthComponent\")")
	print()

	print("  방법 3: 컴포넌트 레지스트리")
	print("    # 엔티티가 컴포넌트 딕셔너리 관리")
	print("    var components: Dictionary = {}")
	print("    func get_component(type: String) -> Node:")
	print("        return components.get(type, null)")
	print()

	# -----------------------------------------------------------------
	# 8) 실전: DamageNumber 컴포넌트
	# -----------------------------------------------------------------
	print("--- 8. DamageNumber 컴포넌트 ---")

	print("  대미지 숫자 팝업 컴포넌트:")
	print("    # damage_number.gd")
	print("    extends Node2D")
	print()
	print("    func spawn_number(value: int, pos: Vector2, is_crit: bool):")
	print("        var label = Label.new()")
	print("        label.text = str(value)")
	print("        label.position = pos")
	print()
	print("        if is_crit:")
	print("            label.add_theme_color_override(\"font_color\", Color.RED)")
	print("            label.add_theme_font_size_override(\"font_size\", 24)")
	print("        else:")
	print("            label.add_theme_color_override(\"font_color\", Color.WHITE)")
	print()
	print("        add_child(label)")
	print()
	print("        # 위로 떠오르며 사라지는 애니메이션")
	print("        var tween = create_tween()")
	print("        tween.set_parallel(true)")
	print("        tween.tween_property(label, \"position:y\",")
	print("            pos.y - 50, 0.8).set_ease(Tween.EASE_OUT)")
	print("        tween.tween_property(label, \"modulate:a\",")
	print("            0.0, 0.8).set_delay(0.3)")
	print("        tween.chain().tween_callback(label.queue_free)")
	print()

	# -----------------------------------------------------------------
	# 9) 컴포넌트 패턴 주의사항
	# -----------------------------------------------------------------
	print("--- 9. 주의사항 ---")

	print("  1. 너무 잘게 쪼개지 마세요")
	print("     - PositionComponent, RotationComponent처럼 과도한 분리는 역효과")
	print("     - 논리적으로 관련된 기능은 하나의 컴포넌트로")
	print()
	print("  2. 컴포넌트 간 의존성 최소화")
	print("     - 시그널로 느슨한 결합 유지")
	print("     - 직접 참조보다 이벤트 기반 통신")
	print()
	print("  3. 성능 고려")
	print("     - 노드 수가 많아지면 오버헤드 발생")
	print("     - 단순한 데이터는 Resource로")
	print("     - 많은 엔티티 -> ECS 고려 (Godex 등)")
	print()
	print("  4. Godot의 장점 활용")
	print("     - 노드 기반 컴포넌트 = 에디터에서 시각적 관리")
	print("     - @export로 컴포넌트 매개변수 인스펙터 편집")
	print("     - 씬 상속으로 변형 엔티티 쉽게 생성")
	print()

	print("=== 03-component-pattern.gd 완료 ===")


# =============================================================================
# HealthComponent
# =============================================================================

class HealthComponent:
	signal damaged(amount: float, current_hp: float)
	signal healed(amount: float, current_hp: float)
	signal died
	signal invincibility_started
	signal invincibility_ended

	var max_hp: float
	var current_hp: float
	var _invincible: bool = false
	var _alive: bool = true

	func _init(p_max_hp: float, p_current_hp: float = -1):
		max_hp = p_max_hp
		current_hp = p_current_hp if p_current_hp >= 0 else p_max_hp
		_alive = current_hp > 0

	func take_damage(amount: float):
		if not _alive or _invincible or amount <= 0:
			return

		current_hp = maxf(0, current_hp - amount)
		damaged.emit(amount, current_hp)

		if current_hp <= 0:
			_alive = false
			died.emit()

	func heal(amount: float):
		if not _alive or amount <= 0:
			return

		current_hp = minf(max_hp, current_hp + amount)
		healed.emit(amount, current_hp)

	func set_invincible(value: bool):
		_invincible = value
		if value:
			invincibility_started.emit()
		else:
			invincibility_ended.emit()

	func is_alive() -> bool:
		return _alive

	func is_invincible() -> bool:
		return _invincible

	func hp_percent() -> float:
		if max_hp <= 0:
			return 0.0
		return (current_hp / max_hp) * 100.0

	func reset():
		current_hp = max_hp
		_alive = true
		_invincible = false


# =============================================================================
# HitboxData (시뮬레이션용)
# =============================================================================

class HitboxData:
	var id: String
	var damage: float
	var knockback_force: float
	var active: bool = true

	func _init(p_id: String, p_damage: float, p_knockback: float = 0.0):
		id = p_id
		damage = p_damage
		knockback_force = p_knockback


# =============================================================================
# MovementComponent
# =============================================================================

class MovementComponent:
	var velocity: Vector2 = Vector2.ZERO
	var max_speed: float
	var acceleration: float
	var friction: float  # 0~1, 마찰 비율

	func _init(p_speed: float, p_accel: float, p_friction: float = 0.2):
		max_speed = p_speed
		acceleration = p_accel
		friction = p_friction

	func apply_input(direction: Vector2, delta: float):
		if direction.length() > 0:
			velocity += direction.normalized() * acceleration * delta
			velocity = velocity.limit_length(max_speed)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)


# =============================================================================
# KnockbackComponent
# =============================================================================

class KnockbackComponent:
	var velocity: Vector2 = Vector2.ZERO
	var decay_rate: float = 0.85  # 프레임당 감쇠 비율

	func apply_knockback(direction: Vector2, force: float):
		velocity = direction.normalized() * force

	func update(delta: float):
		velocity *= decay_rate
		if velocity.length() < 1.0:
			velocity = Vector2.ZERO


# =============================================================================
# EntityBuilder (시뮬레이션용)
# =============================================================================

class EntityBuilder:
	var name: String
	var _components: Dictionary = {}

	func _init(p_name: String):
		name = p_name

	func add_component(comp_name: String, config: Dictionary):
		_components[comp_name] = config

	func get_component_names() -> Array:
		return _components.keys()

	func has_component(comp_name: String) -> bool:
		return _components.has(comp_name)


# =============================================================================
# 헬퍼 함수
# =============================================================================

func _simulate_hit(hitbox: HitboxData, target_health: HealthComponent, label: String):
	if hitbox.active and target_health.is_alive():
		target_health.take_damage(hitbox.damage)
		print("    [%s] %s로 %d 대미지" % [label, hitbox.id, hitbox.damage])
