# Chapter 08 - Animation
# 04-state-machine.gd - 애니메이션 상태 머신
#
# 이 파일에서 배울 내용:
# - 상태 머신(State Machine) 패턴의 개념
# - idle, run, jump, fall 상태와 전환 조건
# - 코드 기반 상태 머신 구현
# - AnimationTree와 StateMachine 노드
# - 실전 캐릭터 애니메이션 제어
#
# 상태 머신은 캐릭터의 현재 상태를 관리하고,
# 상태 간 전환 규칙을 정의하는 디자인 패턴입니다.

extends CharacterBody2D

# ============================================
# 1. 상태 머신 개념
# ============================================
# 상태 머신 = 유한 상태 기계 (Finite State Machine, FSM)
#
# 구성 요소:
# - 상태 (State): IDLE, RUN, JUMP, FALL, ATTACK ...
# - 전환 (Transition): 상태 A -> 상태 B로 변경되는 조건
# - 현재 상태: 한 번에 하나의 상태만 활성
#
# 상태 전환 다이어그램:
#
#    IDLE <---> RUN
#     |          |
#     v          v
#    JUMP       JUMP
#     |          |
#     v          v
#    FALL       FALL
#     |          |
#     +-> IDLE <-+
#     +-> RUN  <-+

# ============================================
# 2. 상태 정의
# ============================================

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	HURT,
	DEATH,
	WALL_SLIDE,
	DASH,
}

# 현재 상태
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# 물리 상수
const SPEED = 200.0
const JUMP_FORCE = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
const WALL_SLIDE_GRAVITY = 100.0

# 상태 타이머
var state_timer: float = 0.0
var can_dash: bool = true
var attack_combo: int = 0
var is_invincible: bool = false

# 시그널
signal state_changed(old_state: State, new_state: State)

# 노드 참조 (실제 씬에서는 @onready)
var anim_player: AnimationPlayer

func _ready():
	print("=== Chapter 08-4: 애니메이션 상태 머신 ===\n")

	_setup_animation_player()
	_explain_state_machine()
	_show_state_transitions()
	_show_full_implementation()
	_show_animation_tree_approach()
	_simulate_gameplay()

# ============================================
# 3. AnimationPlayer 설정
# ============================================

func _setup_animation_player():
	print("--- 3. AnimationPlayer 설정 ---")

	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)

	# 각 상태에 대응하는 애니메이션 생성 (데모용 간단 버전)
	var library = AnimationLibrary.new()

	var states = ["idle", "run", "jump", "fall", "attack", "hurt", "death"]
	for state_name in states:
		var anim = Animation.new()
		anim.length = 0.5 if state_name != "death" else 1.5
		if state_name in ["idle", "run"]:
			anim.loop_mode = Animation.LOOP_LINEAR
		else:
			anim.loop_mode = Animation.LOOP_NONE

		library.add_animation(state_name, anim)

	anim_player.add_animation_library("", library)

	# 시그널 연결
	anim_player.animation_finished.connect(_on_animation_finished)
	state_changed.connect(_on_state_changed)

	print("  애니메이션 등록: idle, run, jump, fall, attack, hurt, death")
	print()

# ============================================
# 4. 상태 머신 설명
# ============================================

func _explain_state_machine():
	print("--- 4. 상태 머신 구조 ---")

	print("[각 상태의 역할]")
	print("  IDLE:       가만히 서있음. 이동/점프/공격 가능")
	print("  RUN:        달리기. 정지/점프/공격 가능")
	print("  JUMP:       점프 상승 중. 공중 공격 가능")
	print("  FALL:       낙하 중. 착지 시 IDLE/RUN으로 전환")
	print("  ATTACK:     공격 중. 콤보 입력 대기")
	print("  HURT:       피격 중. 경직 후 IDLE로 복귀")
	print("  DEATH:      사망. 모든 입력 무시")
	print("  WALL_SLIDE: 벽 슬라이드. 벽 점프 가능")
	print("  DASH:       대시 중. 무적, 짧은 시간")

	print("\n[상태 전환 규칙]")
	print("  IDLE -> RUN:    이동 입력")
	print("  IDLE -> JUMP:   점프 입력")
	print("  IDLE -> ATTACK: 공격 입력")
	print("  RUN -> IDLE:    이동 입력 해제")
	print("  RUN -> JUMP:    점프 입력")
	print("  RUN -> FALL:    바닥 없음 (절벽)")
	print("  JUMP -> FALL:   상승 속도가 0 이하")
	print("  FALL -> IDLE:   바닥에 착지 (정지)")
	print("  FALL -> RUN:    바닥에 착지 (이동 중)")
	print("  ATTACK -> IDLE: 공격 애니메이션 완료")
	print("  ANY -> HURT:    피격 시 (DEATH/DASH 제외)")
	print("  ANY -> DEATH:   체력 0")

	print()

# ============================================
# 5. 상태 전환 시스템
# ============================================

func _show_state_transitions():
	print("--- 5. 상태 전환 함수 ---")
	print("""
  # 상태 전환 함수
  func change_state(new_state: State):
      if new_state == current_state:
          return

      # 이전 상태 종료 처리
      _exit_state(current_state)

      previous_state = current_state
      current_state = new_state
      state_timer = 0.0

      # 새 상태 진입 처리
      _enter_state(new_state)

      state_changed.emit(previous_state, new_state)

  # 상태 진입 시 처리
  func _enter_state(state: State):
      match state:
          State.IDLE:
              anim_player.play("idle", 0.1)

          State.RUN:
              anim_player.play("run", 0.1)

          State.JUMP:
              anim_player.play("jump")
              velocity.y = JUMP_FORCE
              # AudioManager.play("jump_sfx")

          State.FALL:
              anim_player.play("fall", 0.2)

          State.ATTACK:
              anim_player.play("attack")
              velocity.x = 0  # 공격 중 이동 정지
              attack_combo += 1

          State.HURT:
              anim_player.play("hurt")
              is_invincible = true
              velocity = Vector2(-sign(velocity.x) * 100, -200)  # 넉백

          State.DEATH:
              anim_player.play("death")
              velocity = Vector2.ZERO
              set_physics_process(false)  # 물리 처리 중단

          State.WALL_SLIDE:
              anim_player.play("wall_slide")

          State.DASH:
              anim_player.play("dash")
              is_invincible = true
              can_dash = false

  # 상태 종료 시 처리
  func _exit_state(state: State):
      match state:
          State.ATTACK:
              pass  # 콤보 타이머 시작
          State.HURT:
              is_invincible = false
          State.DASH:
              is_invincible = false
	""")
	print()

# ============================================
# 6. 전체 구현 코드
# ============================================

func _show_full_implementation():
	print("--- 6. 전체 상태 머신 구현 ---")
	print("""
  # player_state_machine.gd
  extends CharacterBody2D

  enum State { IDLE, RUN, JUMP, FALL, ATTACK, HURT, DEATH, DASH }

  var current_state: State = State.IDLE
  @onready var anim = $AnimationPlayer

  func _physics_process(delta):
      # 1. 중력 적용 (대부분의 상태에서)
      if current_state not in [State.DASH, State.DEATH]:
          if not is_on_floor():
              velocity.y += GRAVITY * delta

      # 2. 현재 상태에 따른 처리
      match current_state:
          State.IDLE:
              _state_idle(delta)
          State.RUN:
              _state_run(delta)
          State.JUMP:
              _state_jump(delta)
          State.FALL:
              _state_fall(delta)
          State.ATTACK:
              _state_attack(delta)
          State.HURT:
              _state_hurt(delta)
          State.DASH:
              _state_dash(delta)

      # 3. 이동 적용
      move_and_slide()

  # ==================
  # 각 상태별 처리
  # ==================

  func _state_idle(delta):
      velocity.x = move_toward(velocity.x, 0, SPEED)

      # 전환 조건 확인
      var direction = Input.get_axis("move_left", "move_right")
      if direction != 0:
          change_state(State.RUN)
      elif Input.is_action_just_pressed("jump") and is_on_floor():
          change_state(State.JUMP)
      elif Input.is_action_just_pressed("attack"):
          change_state(State.ATTACK)
      elif Input.is_action_just_pressed("dash") and can_dash:
          change_state(State.DASH)
      elif not is_on_floor():
          change_state(State.FALL)

  func _state_run(delta):
      var direction = Input.get_axis("move_left", "move_right")
      velocity.x = direction * SPEED

      # 스프라이트 방향 전환
      if direction != 0:
          $Sprite2D.flip_h = direction < 0

      # 전환 조건
      if direction == 0:
          change_state(State.IDLE)
      elif Input.is_action_just_pressed("jump") and is_on_floor():
          change_state(State.JUMP)
      elif Input.is_action_just_pressed("attack"):
          change_state(State.ATTACK)
      elif Input.is_action_just_pressed("dash") and can_dash:
          change_state(State.DASH)
      elif not is_on_floor():
          change_state(State.FALL)

  func _state_jump(delta):
      # 공중 이동 (약간 느리게)
      var direction = Input.get_axis("move_left", "move_right")
      velocity.x = direction * SPEED * 0.8

      # 점프 키를 떼면 빠르게 하강 (가변 높이 점프)
      if Input.is_action_just_released("jump") and velocity.y < 0:
          velocity.y *= 0.5

      # 전환 조건
      if velocity.y >= 0:
          change_state(State.FALL)

  func _state_fall(delta):
      var direction = Input.get_axis("move_left", "move_right")
      velocity.x = direction * SPEED * 0.8

      # 전환 조건
      if is_on_floor():
          if abs(velocity.x) > 10:
              change_state(State.RUN)
          else:
              change_state(State.IDLE)
          # 착지 이펙트
          # spawn_dust_particles()

  func _state_attack(delta):
      state_timer += delta
      velocity.x = move_toward(velocity.x, 0, SPEED * 2)

      # 콤보 입력 감지 (애니메이션 후반부에)
      if state_timer > 0.3 and Input.is_action_just_pressed("attack"):
          if attack_combo < 3:
              change_state(State.ATTACK)  # 콤보 연속

      # 애니메이션 완료 시 자동 전환 (_on_animation_finished에서)

  func _state_hurt(delta):
      state_timer += delta
      if state_timer > 0.5:  # 0.5초 경직
          change_state(State.IDLE)

  func _state_dash(delta):
      state_timer += delta
      var direction = 1 if not $Sprite2D.flip_h else -1
      velocity = Vector2(direction * DASH_SPEED, 0)

      if state_timer > DASH_DURATION:
          change_state(State.IDLE if is_on_floor() else State.FALL)
          # 대시 쿨다운
          await get_tree().create_timer(0.5).timeout
          can_dash = true

  # ==================
  # 외부 호출 함수
  # ==================

  func take_damage(amount: int, source: Node2D = null):
      if is_invincible or current_state == State.DEATH:
          return

      health -= amount
      if health <= 0:
          change_state(State.DEATH)
      else:
          change_state(State.HURT)
	""")
	print()

# ============================================
# 7. AnimationTree 접근법
# ============================================

func _show_animation_tree_approach():
	print("--- 7. AnimationTree + StateMachine (노드 기반) ---")

	print("[AnimationTree란?]")
	print("  코드 대신 에디터에서 시각적으로 상태 머신을 구성")
	print("  AnimationNodeStateMachine을 사용")
	print("")
	print("  노드 구조:")
	print("  CharacterBody2D")
	print("    +-- Sprite2D")
	print("    +-- AnimationPlayer (애니메이션 보유)")
	print("    +-- AnimationTree (상태 전환 관리)")

	print("\n[AnimationTree 설정]")
	print("""
  # AnimationTree 속성 설정 (에디터 또는 코드)
  @onready var anim_tree = $AnimationTree
  @onready var state_machine = anim_tree.get(
      "parameters/playback") as AnimationNodeStateMachinePlayback

  func _ready():
      anim_tree.active = true

  # 상태 전환
  func change_anim_state(state_name: String):
      state_machine.travel(state_name)
      # travel: 조건에 맞는 경로로 자연스럽게 전환
      # start: 즉시 강제 전환 (중간 상태 무시)

  # 사용 예시
  func _physics_process(delta):
      if is_on_floor():
          if velocity.length() > 10:
              change_anim_state("run")
          else:
              change_anim_state("idle")
      else:
          if velocity.y < 0:
              change_anim_state("jump")
          else:
              change_anim_state("fall")

  # 현재 상태 확인
  func get_current_anim_state() -> String:
      return state_machine.get_current_node()
	""")

	print("[AnimationTree 장점]")
	print("  - 에디터에서 시각적으로 전환 조건 설정")
	print("  - 블렌딩 자동 처리")
	print("  - BlendTree와 조합 가능 (idle <-> run 블렌드)")
	print("  - Advance 조건으로 자동 전환")

	print("\n[코드 vs AnimationTree]")
	print("  코드 상태 머신:")
	print("    장점: 완전한 제어, 복잡한 로직 가능")
	print("    단점: 상태가 많아지면 코드가 복잡해짐")
	print("  AnimationTree:")
	print("    장점: 시각적, 블렌딩 자동, 설정 간편")
	print("    단점: 복잡한 로직은 여전히 코드 필요")
	print("  추천: AnimationTree + 코드 상태 머신 조합")

	print()

# ============================================
# 8. 게임플레이 시뮬레이션
# ============================================

func _simulate_gameplay():
	print("--- 8. 게임플레이 시뮬레이션 ---\n")

	# 상태 전환 이벤트 로깅
	var log: Array = []

	var sim_state = State.IDLE

	# 시뮬레이션 시나리오
	var events = [
		{"input": "move_right", "desc": "오른쪽 이동"},
		{"input": "jump", "desc": "점프"},
		{"input": "peak", "desc": "최고점 도달"},
		{"input": "land_moving", "desc": "이동 중 착지"},
		{"input": "attack", "desc": "공격"},
		{"input": "attack", "desc": "콤보 공격"},
		{"input": "attack_end", "desc": "공격 종료"},
		{"input": "stop", "desc": "이동 중지"},
		{"input": "dash", "desc": "대시"},
		{"input": "dash_end", "desc": "대시 종료"},
		{"input": "hit", "desc": "피격!"},
		{"input": "recover", "desc": "경직 해제"},
		{"input": "jump", "desc": "점프"},
		{"input": "peak", "desc": "최고점 도달"},
		{"input": "land_still", "desc": "정지 착지"},
	]

	print("  [시뮬레이션 시작: 플레이어 조작 흐름]\n")

	for event in events:
		var old_state = sim_state

		match event.input:
			"move_right":
				if sim_state == State.IDLE:
					sim_state = State.RUN
			"stop":
				if sim_state == State.RUN:
					sim_state = State.IDLE
			"jump":
				if sim_state in [State.IDLE, State.RUN]:
					sim_state = State.JUMP
			"peak":
				if sim_state == State.JUMP:
					sim_state = State.FALL
			"land_moving":
				if sim_state == State.FALL:
					sim_state = State.RUN
			"land_still":
				if sim_state == State.FALL:
					sim_state = State.IDLE
			"attack":
				if sim_state in [State.IDLE, State.RUN, State.ATTACK]:
					sim_state = State.ATTACK
			"attack_end":
				if sim_state == State.ATTACK:
					sim_state = State.IDLE
			"dash":
				if sim_state in [State.IDLE, State.RUN]:
					sim_state = State.DASH
			"dash_end":
				if sim_state == State.DASH:
					sim_state = State.IDLE
			"hit":
				if sim_state != State.DEATH and sim_state != State.DASH:
					sim_state = State.HURT
			"recover":
				if sim_state == State.HURT:
					sim_state = State.IDLE

		var state_names = ["IDLE", "RUN", "JUMP", "FALL", "ATTACK",
			"HURT", "DEATH", "WALL_SLIDE", "DASH"]

		if sim_state != old_state:
			print("  %s -> %s -> %s  (%s)" % [
				state_names[old_state],
				event.desc,
				state_names[sim_state],
				_get_animation_for_state(sim_state)
			])
		else:
			print("  [%s] %s (상태 유지)" % [state_names[sim_state], event.desc])

	print("\n  [시뮬레이션 종료]")
	print("\n=== 애니메이션 상태 머신 학습 완료 ===")

func _get_animation_for_state(state: State) -> String:
	match state:
		State.IDLE: return "anim: idle"
		State.RUN: return "anim: run"
		State.JUMP: return "anim: jump"
		State.FALL: return "anim: fall"
		State.ATTACK: return "anim: attack"
		State.HURT: return "anim: hurt"
		State.DEATH: return "anim: death"
		State.WALL_SLIDE: return "anim: wall_slide"
		State.DASH: return "anim: dash"
	return "anim: unknown"

# ============================================
# 시그널 콜백
# ============================================

func _on_animation_finished(anim_name: StringName):
	match anim_name:
		"attack":
			_change_state(State.IDLE)
		"hurt":
			_change_state(State.IDLE)
		"death":
			print("  [DEATH] 게임 오버 처리...")

func _on_state_changed(old_state: State, new_state: State):
	var state_names = ["IDLE", "RUN", "JUMP", "FALL", "ATTACK",
		"HURT", "DEATH", "WALL_SLIDE", "DASH"]
	# 디버그 로깅에 유용
	pass

func _change_state(new_state: State):
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state
	state_timer = 0.0
	state_changed.emit(previous_state, new_state)
