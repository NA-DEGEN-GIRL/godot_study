# Chapter 12 - Project Patterns
# 01-state-pattern.gd - 상태 머신(State Machine) 패턴
#
# 이 파일에서 배울 내용:
# - 유한 상태 머신(FSM) 개념과 필요성
# - 기본 State 클래스 설계
# - StateMachine 관리 클래스
# - 캐릭터 상태 머신 실전 예시 (Idle, Run, Jump, Attack, Hurt)
# - 상태 전이 조건과 애니메이션 연동

extends Node

func _ready():
	print("=== Chapter 12-1: 상태 머신(State Machine) 패턴 ===\n")

	# -----------------------------------------------------------------
	# 1) 왜 상태 머신이 필요한가?
	# -----------------------------------------------------------------
	print("--- 1. 상태 머신의 필요성 ---")

	print("  나쁜 예시 (플래그 지옥):")
	print("    var is_jumping = false")
	print("    var is_attacking = false")
	print("    var is_hurt = false")
	print("    var is_dashing = false")
	print()
	print("    func _physics_process(delta):")
	print("        if is_jumping and not is_attacking and not is_hurt:")
	print("            # 점프 처리...")
	print("        elif is_attacking and not is_jumping:")
	print("            # 공격 처리...")
	print("        # 조건이 기하급수적으로 복잡해짐!")
	print()

	print("  좋은 예시 (상태 머신):")
	print("    enum State { IDLE, RUN, JUMP, ATTACK, HURT }")
	print("    var current_state = State.IDLE")
	print()
	print("    # 각 상태가 독립적으로 처리됨")
	print("    # 전이 조건이 명확함")
	print()

	# -----------------------------------------------------------------
	# 2) 간단한 enum 기반 상태 머신
	# -----------------------------------------------------------------
	print("--- 2. 간단한 enum 기반 상태 머신 ---")

	var simple_fsm = SimpleStateMachine.new()
	print("  초기 상태: ", simple_fsm.get_state_name())

	# 상태 전이 시뮬레이션
	simple_fsm.handle_input("move_right")
	print("  move_right -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("jump")
	print("  jump -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("land")
	print("  land -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("attack")
	print("  attack -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("attack_end")
	print("  attack_end -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("stop")
	print("  stop -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("take_damage")
	print("  take_damage -> ", simple_fsm.get_state_name())

	simple_fsm.handle_input("recover")
	print("  recover -> ", simple_fsm.get_state_name())
	print()

	# -----------------------------------------------------------------
	# 3) 클래스 기반 상태 머신 구조
	# -----------------------------------------------------------------
	print("--- 3. 클래스 기반 상태 머신 ---")

	print("  구조:")
	print("    StateMachine (관리자)")
	print("    +-- State (기본 클래스)")
	print("        +-- IdleState")
	print("        +-- RunState")
	print("        +-- JumpState")
	print("        +-- AttackState")
	print("        +-- HurtState")
	print()

	print("  State 기본 클래스 인터페이스:")
	print("    enter()                  - 상태 진입 시 호출")
	print("    exit()                   - 상태 퇴장 시 호출")
	print("    update(delta)            - 매 프레임 호출 (_process)")
	print("    physics_update(delta)    - 물리 프레임 호출 (_physics_process)")
	print("    handle_input(event)      - 입력 처리 (_unhandled_input)")
	print()

	# -----------------------------------------------------------------
	# 4) 클래스 기반 상태 머신 실행
	# -----------------------------------------------------------------
	print("--- 4. 클래스 기반 상태 머신 실행 ---")

	var state_machine = ClassStateMachine.new()

	# 상태 등록
	var idle_state = IdleState.new("idle")
	var run_state = RunState.new("run")
	var jump_state = JumpState.new("jump")
	var attack_state = AttackState.new("attack")
	var hurt_state = HurtState.new("hurt")

	state_machine.add_state(idle_state)
	state_machine.add_state(run_state)
	state_machine.add_state(jump_state)
	state_machine.add_state(attack_state)
	state_machine.add_state(hurt_state)

	# 초기 상태 설정
	state_machine.set_initial_state("idle")
	print("  등록된 상태: ", state_machine.get_state_names())
	print("  현재 상태: ", state_machine.current_state_name)
	print()

	# 상태 전이 시뮬레이션
	print("  [상태 전이 시뮬레이션]")
	state_machine.transition_to("run")
	state_machine.transition_to("jump")
	state_machine.transition_to("idle")   # 착지
	state_machine.transition_to("attack")
	state_machine.transition_to("idle")   # 공격 완료
	state_machine.transition_to("hurt")
	state_machine.transition_to("idle")   # 회복
	print()

	# update 시뮬레이션
	print("  [프레임 업데이트 시뮬레이션]")
	state_machine.transition_to("run")
	for i in range(3):
		state_machine.update(0.016)  # ~60fps
	print()

	# -----------------------------------------------------------------
	# 5) 상태 전이 테이블
	# -----------------------------------------------------------------
	print("--- 5. 상태 전이 테이블 ---")

	print("  각 상태에서 가능한 전이:")
	print("  +----------+------+------+------+--------+------+")
	print("  | From\\To  | Idle | Run  | Jump | Attack | Hurt |")
	print("  +----------+------+------+------+--------+------+")
	print("  | Idle     |  -   |  O   |  O   |   O    |  O   |")
	print("  | Run      |  O   |  -   |  O   |   O    |  O   |")
	print("  | Jump     |  O   |  X   |  -   |   X    |  O   |")
	print("  | Attack   |  O   |  X   |  X   |   -    |  O   |")
	print("  | Hurt     |  O   |  X   |  X   |   X    |  -   |")
	print("  +----------+------+------+------+--------+------+")
	print("  O = 전이 가능, X = 전이 불가")
	print()

	# 전이 유효성 검사 시뮬레이션
	var transition_table = {
		"idle":   ["run", "jump", "attack", "hurt"],
		"run":    ["idle", "jump", "attack", "hurt"],
		"jump":   ["idle", "hurt"],
		"attack": ["idle", "hurt"],
		"hurt":   ["idle"],
	}

	print("  전이 유효성 테스트:")
	var test_transitions = [
		["idle", "run"],      # 가능
		["idle", "jump"],     # 가능
		["jump", "attack"],   # 불가
		["attack", "run"],    # 불가
		["hurt", "idle"],     # 가능
	]

	for t in test_transitions:
		var from_state = t[0]
		var to_state = t[1]
		var allowed = to_state in transition_table.get(from_state, [])
		print("    %s -> %s: %s" % [from_state, to_state,
			"허용" if allowed else "거부"])
	print()

	# -----------------------------------------------------------------
	# 6) 노드 기반 상태 머신 (Godot 권장 패턴)
	# -----------------------------------------------------------------
	print("--- 6. 노드 기반 상태 머신 (Godot 권장) ---")

	print("  씬 트리 구조:")
	print("    Player (CharacterBody2D)")
	print("    +-- StateMachine (Node)")
	print("    |   +-- Idle (Node)  <- State 스크립트 첨부")
	print("    |   +-- Run (Node)")
	print("    |   +-- Jump (Node)")
	print("    |   +-- Attack (Node)")
	print("    |   +-- Hurt (Node)")
	print("    +-- AnimationPlayer")
	print("    +-- Sprite2D")
	print()

	print("  장점:")
	print("    - 에디터에서 시각적으로 확인 가능")
	print("    - 각 상태가 독립된 스크립트 파일")
	print("    - @export로 상태별 매개변수 설정")
	print("    - 디버깅이 쉬움 (노드 선택하여 변수 확인)")
	print()

	print("  # state.gd (기본 클래스)")
	print("  class_name State")
	print("  extends Node")
	print()
	print("  @export var animation_name: String = \"\"")
	print("  var state_machine: StateMachineNode = null")
	print("  var character: CharacterBody2D = null")
	print()
	print("  func enter() -> void: pass")
	print("  func exit() -> void: pass")
	print("  func update(_delta: float) -> void: pass")
	print("  func physics_update(_delta: float) -> void: pass")
	print()
	print("  func transition(new_state_name: String):")
	print("      state_machine.transition_to(new_state_name)")
	print()

	# -----------------------------------------------------------------
	# 7) 실전 예시: 적 AI 상태 머신
	# -----------------------------------------------------------------
	print("--- 7. 적 AI 상태 머신 ---")

	var enemy_ai = EnemyAI.new()

	print("  적 AI 상태:")
	print("    PATROL  - 정해진 경로 순찰")
	print("    CHASE   - 플레이어 추적")
	print("    ATTACK  - 공격 범위 내 공격")
	print("    RETREAT - 체력 낮으면 후퇴")
	print("    DEAD    - 사망")
	print()

	# AI 시뮬레이션
	print("  [AI 시뮬레이션]")
	print("  초기: ", enemy_ai.get_state_name())

	enemy_ai.player_distance = 200  # 감지 범위 밖
	enemy_ai.update_ai(0.1)
	print("  거리 200 (순찰 중): ", enemy_ai.get_state_name())

	enemy_ai.player_distance = 80   # 감지 범위 안
	enemy_ai.update_ai(0.1)
	print("  거리 80 (추격 시작): ", enemy_ai.get_state_name())

	enemy_ai.player_distance = 25   # 공격 범위 안
	enemy_ai.update_ai(0.1)
	print("  거리 25 (공격!): ", enemy_ai.get_state_name())

	enemy_ai.hp = 15                # 체력 감소
	enemy_ai.update_ai(0.1)
	print("  HP 15 (후퇴): ", enemy_ai.get_state_name())

	enemy_ai.hp = 0
	enemy_ai.update_ai(0.1)
	print("  HP 0 (사망): ", enemy_ai.get_state_name())
	print()

	# -----------------------------------------------------------------
	# 8) 상태 머신 디버깅 팁
	# -----------------------------------------------------------------
	print("--- 8. 디버깅 팁 ---")

	print("  1. 상태 전이 로깅:")
	print("     func transition_to(new_state):")
	print("         print(\"[FSM] %s -> %s\" % [current, new_state])")
	print()
	print("  2. 에디터에서 현재 상태 표시:")
	print("     @export var debug_current_state: String  # 읽기 전용")
	print()
	print("  3. 상태 히스토리 기록:")
	print("     var _state_history: Array[String] = []")
	print("     func transition_to(new_state):")
	print("         _state_history.append(new_state)")
	print("         if _state_history.size() > 20:")
	print("             _state_history.pop_front()")
	print()
	print("  4. 유효하지 않은 전이 감지:")
	print("     func transition_to(new_state):")
	print("         if new_state not in allowed_transitions[current]:")
	print("             push_warning(\"Invalid: %s -> %s\" % [current, new_state])")
	print("             return")
	print()

	# -----------------------------------------------------------------
	# 9) 계층적 상태 머신 (HFSM)
	# -----------------------------------------------------------------
	print("--- 9. 계층적 상태 머신 (HFSM) ---")

	print("  상위 상태가 하위 상태를 포함:")
	print()
	print("    Alive (상위 상태)")
	print("    +-- Grounded (하위)")
	print("    |   +-- Idle")
	print("    |   +-- Run")
	print("    |   +-- Crouch")
	print("    +-- Airborne (하위)")
	print("    |   +-- Jump")
	print("    |   +-- Fall")
	print("    |   +-- WallSlide")
	print("    Dead (상위 상태)")
	print()

	print("  장점: 공통 로직을 상위 상태에서 처리")
	print("  예: Alive 상태에서 공통으로 대미지 처리")
	print("      Grounded 상태에서 공통으로 이동 처리")
	print()

	print("=== 01-state-pattern.gd 완료 ===")


# =============================================================================
# 간단한 enum 기반 상태 머신
# =============================================================================

class SimpleStateMachine:
	enum State { IDLE, RUN, JUMP, ATTACK, HURT }

	var current: State = State.IDLE

	func get_state_name() -> String:
		return State.keys()[current]

	func handle_input(action: String):
		match current:
			State.IDLE:
				match action:
					"move_right", "move_left": current = State.RUN
					"jump": current = State.JUMP
					"attack": current = State.ATTACK
					"take_damage": current = State.HURT

			State.RUN:
				match action:
					"stop": current = State.IDLE
					"jump": current = State.JUMP
					"attack": current = State.ATTACK
					"take_damage": current = State.HURT

			State.JUMP:
				match action:
					"land": current = State.IDLE
					"take_damage": current = State.HURT

			State.ATTACK:
				match action:
					"attack_end": current = State.IDLE
					"take_damage": current = State.HURT

			State.HURT:
				match action:
					"recover": current = State.IDLE


# =============================================================================
# 클래스 기반 상태 머신
# =============================================================================

class BaseState:
	var state_name: String

	func _init(p_name: String):
		state_name = p_name

	func enter():
		print("    [%s] enter" % state_name)

	func exit():
		print("    [%s] exit" % state_name)

	func update(delta: float):
		pass

	func physics_update(delta: float):
		pass


class IdleState extends BaseState:
	func update(delta: float):
		print("      [idle] 대기 중... (delta=%.3f)" % delta)

class RunState extends BaseState:
	var _run_time: float = 0.0

	func enter():
		super.enter()
		_run_time = 0.0

	func update(delta: float):
		_run_time += delta
		print("      [run] 달리는 중... (%.2f초)" % _run_time)

class JumpState extends BaseState:
	func enter():
		super.enter()
		print("      [jump] 점프! velocity.y = -400")

class AttackState extends BaseState:
	func enter():
		super.enter()
		print("      [attack] 공격 시작! (0.4초 후 종료)")

class HurtState extends BaseState:
	func enter():
		super.enter()
		print("      [hurt] 피격! (0.3초 무적)")


class ClassStateMachine:
	var _states: Dictionary = {}  # name -> State
	var _current_state: BaseState = null
	var current_state_name: String = ""

	func add_state(state: BaseState):
		_states[state.state_name] = state

	func set_initial_state(name: String):
		if _states.has(name):
			_current_state = _states[name]
			current_state_name = name
			_current_state.enter()

	func transition_to(new_state_name: String):
		if not _states.has(new_state_name):
			push_warning("상태 없음: %s" % new_state_name)
			return
		if new_state_name == current_state_name:
			return

		if _current_state:
			_current_state.exit()

		_current_state = _states[new_state_name]
		current_state_name = new_state_name
		_current_state.enter()

	func update(delta: float):
		if _current_state:
			_current_state.update(delta)

	func get_state_names() -> Array:
		return _states.keys()


# =============================================================================
# 적 AI 상태 머신
# =============================================================================

class EnemyAI:
	enum AIState { PATROL, CHASE, ATTACK, RETREAT, DEAD }

	var current: AIState = AIState.PATROL
	var hp: int = 100
	var max_hp: int = 100
	var player_distance: float = 999.0
	var detect_range: float = 150.0
	var attack_range: float = 40.0
	var retreat_hp_threshold: float = 0.2

	func get_state_name() -> String:
		return AIState.keys()[current]

	func update_ai(delta: float):
		if hp <= 0 and current != AIState.DEAD:
			current = AIState.DEAD
			return

		match current:
			AIState.PATROL:
				if player_distance < detect_range:
					current = AIState.CHASE

			AIState.CHASE:
				if player_distance < attack_range:
					current = AIState.ATTACK
				elif player_distance > detect_range * 1.5:
					current = AIState.PATROL
				if float(hp) / max_hp < retreat_hp_threshold:
					current = AIState.RETREAT

			AIState.ATTACK:
				if player_distance > attack_range * 1.5:
					current = AIState.CHASE
				if float(hp) / max_hp < retreat_hp_threshold:
					current = AIState.RETREAT

			AIState.RETREAT:
				if float(hp) / max_hp > retreat_hp_threshold * 2:
					current = AIState.PATROL

			AIState.DEAD:
				pass  # 상태 변경 불가
