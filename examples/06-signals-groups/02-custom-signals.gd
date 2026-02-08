# Chapter 06 - Signals & Groups
# 02-custom-signals.gd - 커스텀 시그널 정의와 활용
#
# 이 파일에서 배울 내용:
# - signal 키워드로 커스텀 시그널 선언
# - emit()으로 시그널 발신
# - 매개변수가 있는 시그널
# - await signal 패턴 (비동기 대기)
# - 시그널과 타입 안전성
#
# 커스텀 시그널은 게임 로직의 이벤트를 정의할 때 사용합니다.
# "체력이 변경되었다", "적이 죽었다", "레벨업!" 등

extends Node

# ============================================
# 1. 시그널 선언
# ============================================

# 매개변수 없는 시그널
signal game_started
signal game_paused
signal game_over

# 매개변수가 있는 시그널 (타입 힌트 권장)
signal health_changed(new_health: int, max_health: int)
signal damage_taken(amount: int, source: String)
signal item_collected(item_name: String, item_value: int)
signal level_up(new_level: int)
signal score_updated(old_score: int, new_score: int)

# 복잡한 데이터를 전달하는 시그널
signal enemy_defeated(enemy_data: Dictionary)
signal quest_completed(quest_id: String, rewards: Array)
signal player_moved(new_position: Vector2)

# 게임 상태 변수
var _health: int = 100
var _max_health: int = 100
var _score: int = 0
var _level: int = 1
var _experience: int = 0
var _exp_to_next: int = 100

func _ready():
	print("=== Chapter 06-2: 커스텀 시그널 ===\n")

	_demonstrate_basic_signal()
	_demonstrate_parameterized_signal()
	_demonstrate_property_pattern()
	_demonstrate_await_signal()
	_demonstrate_signal_chaining()
	_demonstrate_signal_forwarding()
	_practical_health_system()
	_practical_experience_system()

# ============================================
# 2. 기본 시그널 사용
# ============================================

func _demonstrate_basic_signal():
	print("--- 2. 기본 시그널: 선언 -> 연결 -> 발신 ---")

	# Step 1: 시그널 선언 (클래스 상단에)
	print("[Step 1] 선언: signal game_started")

	# Step 2: 시그널 연결
	print("[Step 2] 연결: game_started.connect(_on_game_started)")
	game_started.connect(_on_game_started)

	# 여러 함수를 같은 시그널에 연결 (1:N 관계)
	game_started.connect(func(): print("  -> 음악 시작!"))
	game_started.connect(func(): print("  -> UI 표시!"))
	game_started.connect(func(): print("  -> 타이머 시작!"))

	# Step 3: 시그널 발신
	print("[Step 3] 발신: game_started.emit()")
	game_started.emit()

	print()

func _on_game_started():
	print("  -> 게임이 시작되었습니다!")

# ============================================
# 3. 매개변수 있는 시그널
# ============================================

func _demonstrate_parameterized_signal():
	print("--- 3. 매개변수 시그널 ---")

	# 시그널 선언 (상단에 이미 선언됨):
	# signal health_changed(new_health: int, max_health: int)
	# signal damage_taken(amount: int, source: String)

	# 연결 - 콜백 함수의 매개변수가 시그널과 일치해야 함
	health_changed.connect(_on_health_changed)
	damage_taken.connect(_on_damage_taken)
	item_collected.connect(_on_item_collected)

	# 발신 - emit()에 매개변수 전달
	print("[매개변수와 함께 emit]")
	health_changed.emit(75, 100)
	damage_taken.emit(25, "고블린")
	item_collected.emit("마법의 검", 500)

	# Dictionary로 복잡한 데이터 전달
	print("\n[Dictionary 데이터 전달]")
	enemy_defeated.connect(func(data: Dictionary):
		print("  -> 적 처치! 이름: %s, 경험치: %d, 드롭: %s" % [
			data.name, data.exp, str(data.drops)
		])
	)
	enemy_defeated.emit({
		"name": "드래곤",
		"exp": 500,
		"drops": ["용의 비늘", "금화 x100"],
		"position": Vector2(100, 200)
	})

	print()

func _on_health_changed(new_health: int, max_health: int):
	var percent = float(new_health) / max_health * 100
	print("  -> 체력 변경: %d/%d (%.0f%%)" % [new_health, max_health, percent])

func _on_damage_taken(amount: int, source: String):
	print("  -> %s에게 %d 데미지 받음!" % [source, amount])

func _on_item_collected(item_name: String, item_value: int):
	print("  -> 아이템 수집: %s (가치: %d)" % [item_name, item_value])

# ============================================
# 4. 프로퍼티 + 시그널 패턴 (Setter)
# ============================================

func _demonstrate_property_pattern():
	print("--- 4. 프로퍼티 + 시그널 패턴 ---")

	print("[set 함수에서 자동으로 시그널 발신]")
	print("  값이 변경될 때만 시그널을 발신하는 안전한 패턴")
	print("""
  # 프로퍼티 패턴 예시
  var health: int = 100:
      set(value):
          var old_health = health
          health = clampi(value, 0, max_health)
          if health != old_health:
              health_changed.emit(health, max_health)
          if health <= 0:
              died.emit()

  var score: int = 0:
      set(value):
          var old = score
          score = value
          score_updated.emit(old, score)
	""")

	# 실제 시뮬레이션
	print("[실전 시뮬레이션]")
	# 기존 연결 해제 후 새로 연결
	for conn in health_changed.get_connections():
		health_changed.disconnect(conn.callable)

	health_changed.connect(func(hp: int, max_hp: int):
		print("  체력: %d/%d %s" % [hp, max_hp, _health_bar(hp, max_hp)])
	)

	# setter를 시뮬레이션
	_set_health(100)
	_set_health(75)
	_set_health(50)
	_set_health(25)
	_set_health(0)
	_set_health(100)  # 부활!

	print()

func _set_health(value: int):
	var old = _health
	_health = clampi(value, 0, _max_health)
	if _health != old:
		health_changed.emit(_health, _max_health)

func _health_bar(current: int, maximum: int) -> String:
	var filled = int(float(current) / maximum * 10)
	var empty = 10 - filled
	return "[" + "#".repeat(filled) + "-".repeat(empty) + "]"

# ============================================
# 5. await signal - 비동기 대기
# ============================================

func _demonstrate_await_signal():
	print("--- 5. await signal - 시그널 대기 ---")

	# await는 시그널이 발생할 때까지 함수 실행을 일시 중지합니다
	print("[await 기본 사용법]")
	print("""
  # 시그널이 발생할 때까지 대기
  func show_intro():
      $AnimationPlayer.play("intro")
      await $AnimationPlayer.animation_finished
      print("인트로 끝! 게임 시작!")

  # 타이머 대기
  func cooldown():
      can_shoot = false
      await get_tree().create_timer(0.5).timeout
      can_shoot = true

  # 사용자 입력 대기
  func wait_for_continue():
      $ContinueLabel.visible = true
      await $ContinueButton.pressed
      $ContinueLabel.visible = false
      next_dialogue()
	""")

	# 실제 await 예시
	print("[실제 await 실행]")
	_run_await_demo()

func _run_await_demo():
	# Timer를 사용한 await 데모
	print("  대기 시작...")

	# 짧은 타이머로 await 시연
	var timer = get_tree().create_timer(0.01)  # 매우 짧게
	await timer.timeout
	print("  대기 완료! (await 후 코드 실행)")

	# await로 시그널 반환값 받기
	print("\n[await로 시그널 매개변수 받기]")
	print("""
  # 시그널 매개변수를 변수로 받을 수 있음
  var result = await dialog_finished  # signal dialog_finished(choice: String)
  print("선택: ", result)

  # 여러 매개변수는 배열로 반환
  var data = await quest_completed
  # data[0] = quest_id, data[1] = rewards
	""")

	# 여러 시그널 중 하나 대기 패턴
	print("[여러 시그널 중 하나만 대기하는 패턴]")
	print("""
  # 방법: 별도 시그널로 통합
  signal any_button_pressed(button_name: String)

  func setup():
      $AttackBtn.pressed.connect(func():
          any_button_pressed.emit("attack"))
      $DefendBtn.pressed.connect(func():
          any_button_pressed.emit("defend"))

  func wait_for_choice():
      var choice = await any_button_pressed
      match choice:
          "attack": do_attack()
          "defend": do_defend()
	""")

	print()

# ============================================
# 6. 시그널 체이닝 (Signal Chaining)
# ============================================

func _demonstrate_signal_chaining():
	print("--- 6. 시그널 체이닝 ---")

	# 시그널 A -> 시그널 B로 전달 (relay)
	print("[시그널 체이닝: 한 시그널이 다른 시그널을 발신]")
	print("""
  # 적이 죽으면 -> 경험치 시그널 -> 레벨업 확인
  signal enemy_killed(enemy: Node2D)
  signal experience_gained(amount: int)
  signal leveled_up(new_level: int)

  func _ready():
      enemy_killed.connect(func(enemy):
          var exp = enemy.exp_value
          experience_gained.emit(exp)
      )

      experience_gained.connect(func(amount):
          current_exp += amount
          if current_exp >= exp_to_next_level:
              level += 1
              leveled_up.emit(level)
      )

      leveled_up.connect(func(level):
          print("레벨 업! Lv.", level)
          show_level_up_effect()
      )
	""")

	# 시그널을 다른 노드의 시그널에 직접 연결
	print("[시그널 -> 시그널 직접 연결]")
	print("""
  # 시그널 A를 시그널 B에 직접 연결 (매개변수 호환 시)
  signal local_event(data: String)
  signal global_event(data: String)

  func _ready():
      # local_event가 발생하면 자동으로 global_event도 발생
      local_event.connect(global_event.emit)
	""")

	print()

# ============================================
# 7. 시그널 포워딩 (자식 -> 부모)
# ============================================

func _demonstrate_signal_forwarding():
	print("--- 7. 시그널 포워딩 패턴 ---")

	print("[자식 노드의 시그널을 부모가 중계]")
	print("""
  # player.gd (부모)
  signal player_health_changed(hp: int)

  func _ready():
      # 자식의 시그널을 부모 시그널로 중계
      $HealthComponent.health_changed.connect(
          func(hp, max_hp):
              player_health_changed.emit(hp)
      )

  # 외부에서는 Player의 시그널만 사용
  # player.player_health_changed.connect(update_hud)
	""")

	print("[래퍼(Wrapper) 패턴]")
	print("""
  # 컴포넌트의 시그널을 래핑하여 노출
  class_name Player
  extends CharacterBody2D

  # 외부 공개 시그널
  signal attacked(damage: int)
  signal died

  # 내부 컴포넌트
  @onready var health_comp = $HealthComponent
  @onready var combat_comp = $CombatComponent

  func _ready():
      combat_comp.attack_performed.connect(
          func(dmg): attacked.emit(dmg)
      )
      health_comp.hp_depleted.connect(
          func(): died.emit()
      )
	""")

	print()

# ============================================
# 8. 실전: 체력 시스템
# ============================================

func _practical_health_system():
	print("--- 8. 실전: 체력 시스템 ---")
	print("""
  # health_component.gd
  class_name HealthComponent
  extends Node

  signal health_changed(current: int, maximum: int)
  signal damage_received(amount: int, source: Node)
  signal healed(amount: int)
  signal died
  signal revived

  @export var max_health: int = 100
  var current_health: int:
      set(value):
          var old = current_health
          current_health = clampi(value, 0, max_health)
          if current_health != old:
              health_changed.emit(current_health, max_health)
          if current_health <= 0 and old > 0:
              died.emit()

  var is_dead: bool:
      get: return current_health <= 0

  var is_invincible: bool = false

  func _ready():
      current_health = max_health

  func take_damage(amount: int, source: Node = null) -> int:
      if is_dead or is_invincible:
          return 0

      var actual_damage = mini(amount, current_health)
      current_health -= actual_damage
      damage_received.emit(actual_damage, source)
      return actual_damage

  func heal(amount: int) -> int:
      if is_dead:
          return 0

      var actual_heal = mini(amount, max_health - current_health)
      current_health += actual_heal
      if actual_heal > 0:
          healed.emit(actual_heal)
      return actual_heal

  func revive(health_percent: float = 0.5):
      if not is_dead:
          return
      current_health = int(max_health * health_percent)
      revived.emit()
	""")

	# 시뮬레이션
	print("[체력 시스템 시뮬레이션]")
	_health = 100
	_max_health = 100

	var events = [
		{"action": "damage", "amount": 30, "source": "슬라임"},
		{"action": "damage", "amount": 20, "source": "고블린"},
		{"action": "heal", "amount": 15},
		{"action": "damage", "amount": 50, "source": "드래곤"},
		{"action": "heal", "amount": 100},
	]

	for event in events:
		match event.action:
			"damage":
				var actual = mini(event.amount, _health)
				_health -= actual
				_health = maxi(_health, 0)
				print("  %s의 공격! -%d HP | 체력: %d/%d %s" % [
					event.source, actual, _health, _max_health,
					_health_bar(_health, _max_health)
				])
				if _health <= 0:
					print("  >> 사망!")
			"heal":
				var actual = mini(event.amount, _max_health - _health)
				_health += actual
				print("  회복! +%d HP | 체력: %d/%d %s" % [
					actual, _health, _max_health,
					_health_bar(_health, _max_health)
				])

	print()

# ============================================
# 9. 실전: 경험치/레벨업 시스템
# ============================================

func _practical_experience_system():
	print("--- 9. 실전: 경험치 / 레벨업 시스템 ---")

	# 시그널 연결
	for conn in level_up.get_connections():
		level_up.disconnect(conn.callable)

	level_up.connect(func(new_level: int):
		print("  *** LEVEL UP! Lv.%d ***" % new_level)
	)

	score_updated.connect(func(old_score: int, new_score: int):
		print("  점수: %d -> %d (+%d)" % [old_score, new_score, new_score - old_score])
	)

	# 경험치 획득 시뮬레이션
	print("[경험치 획득 시뮬레이션]")
	_level = 1
	_experience = 0
	_exp_to_next = 100

	var enemies_killed = [
		{"name": "슬라임", "exp": 30},
		{"name": "고블린", "exp": 45},
		{"name": "오크", "exp": 60},
		{"name": "트롤", "exp": 80},
		{"name": "드래곤", "exp": 200},
	]

	for enemy in enemies_killed:
		_gain_experience(enemy.name, enemy.exp)

	print("\n[최종 상태]")
	print("  레벨: %d" % _level)
	print("  경험치: %d/%d" % [_experience, _exp_to_next])

	print("\n=== 커스텀 시그널 학습 완료 ===")

func _gain_experience(enemy_name: String, exp: int):
	_experience += exp
	print("  %s 처치! +%d EXP (%d/%d)" % [
		enemy_name, exp, _experience, _exp_to_next
	])

	while _experience >= _exp_to_next:
		_experience -= _exp_to_next
		_level += 1
		_exp_to_next = int(_exp_to_next * 1.5)  # 다음 레벨 요구량 증가
		level_up.emit(_level)
		print("  필요 경험치 증가: %d" % _exp_to_next)
