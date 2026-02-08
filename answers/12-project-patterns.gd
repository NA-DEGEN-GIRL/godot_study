# 챕터 12: 프로젝트 패턴 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - enum 기반 상태 머신(FSM)으로 캐릭터 상태 관리
# - 상태 전환 함수로 유효한 전이만 허용하기
# - 오브젝트 풀링으로 메모리 효율적인 객체 관리
# - HealthComponent 컴포넌트 패턴 구현
# - 이벤트 버스로 시스템 간 느슨한 결합 통신
# - Time.get_ticks_usec()로 성능 벤치마크 측정
# - 내보내기/최적화 체크리스트 점검

extends Node

func _ready():
	print("=== 챕터 12: 프로젝트 패턴 ===\n")

	# 연습 1: 상태 머신 enum
	_exercise_1_state_machine_enum()

	# 연습 2: 상태 전환 함수
	_exercise_2_state_transition()

	# 연습 3: 오브젝트 풀
	_exercise_3_object_pool()

	# 연습 4: HealthComponent
	_exercise_4_health_component()

	# 연습 5: 이벤트 버스
	_exercise_5_event_bus()

	# 연습 6: 성능 측정
	_exercise_6_performance_benchmark()

	# 연습 7: 내보내기 체크리스트
	_exercise_7_export_checklist()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: enum 기반 상태 머신 구현 완료 (IDLE, RUN, JUMP, ATTACK, HURT)")
	print("결과 2: 상태 전환 테이블 및 유효성 검사 구현 완료")
	print("결과 3: 오브젝트 풀 (가져오기/반환/자동확장) 구현 완료")
	print("결과 4: HealthComponent (대미지/회복/무적/사망) 구현 완료")
	print("결과 5: 이벤트 버스 (발행/구독/해제) 구현 완료")
	print("결과 6: 성능 벤치마크 (캐싱/타입/거리) 측정 완료")
	print("결과 7: 내보내기 체크리스트 (코드/렌더링/물리/프로젝트) 출력 완료")


# ==============================================================================
# 연습 1: 상태 머신 enum - enum과 match를 사용하여 캐릭터 상태를
#          관리하는 간단한 상태 머신을 구현하세요.
# ==============================================================================
func _exercise_1_state_machine_enum():
	# 풀이: enum으로 가능한 상태를 정의하고, current 변수로 현재 상태를 추적합니다.
	#       handle_input(action) 함수에서 match current로 상태를 분기하고,
	#       각 상태에서 허용되는 action에 대해서만 상태를 전환합니다.
	#       get_state_name()은 enum의 keys()를 사용하여 이름을 반환합니다.

	print("연습 1: 상태 머신 enum")

	var fsm = SimpleStateMachine.new()
	print("  초기 상태: %s" % fsm.get_state_name())

	# 상태 전이 시뮬레이션
	var actions = [
		"move_right", "jump", "land", "attack",
		"attack_end", "stop", "take_damage", "recover"
	]
	var expected = [
		"RUN", "JUMP", "IDLE", "ATTACK",
		"IDLE", "IDLE", "HURT", "IDLE"
	]

	print()
	print("  상태 전이 시뮬레이션:")
	for i in range(actions.size()):
		fsm.handle_input(actions[i])
		var state_name = fsm.get_state_name()
		print("    %s -> %s" % [actions[i], state_name])
	print()

	# 잘못된 전이 테스트
	print("  무효한 전이 테스트:")
	fsm = SimpleStateMachine.new()
	fsm.handle_input("jump")   # IDLE -> JUMP
	print("    IDLE에서 jump: %s" % fsm.get_state_name())

	fsm.handle_input("attack") # JUMP에서 attack은 무효
	print("    JUMP에서 attack: %s (변화 없음)" % fsm.get_state_name())

	fsm.handle_input("land")   # JUMP -> IDLE
	print("    JUMP에서 land: %s" % fsm.get_state_name())
	print()

	# 상태별 설명
	print("  상태 목록:")
	print("    IDLE   - 대기 상태 (이동, 점프, 공격 가능)")
	print("    RUN    - 달리기 (정지, 점프, 공격 가능)")
	print("    JUMP   - 공중 (착지, 피격만 가능)")
	print("    ATTACK - 공격 (공격 종료, 피격만 가능)")
	print("    HURT   - 피격 (회복만 가능)")

	print("연습 1 완료: 상태 머신 enum\n")


# ==============================================================================
# 연습 2: 상태 전환 함수 - 전이 테이블을 사용하여 유효한 상태 전환만
#          허용하는 함수를 구현하세요.
# ==============================================================================
func _exercise_2_state_transition():
	# 풀이: Dictionary로 전이 테이블을 정의합니다. 각 키는 현재 상태이고,
	#       값은 해당 상태에서 전이 가능한 상태의 배열입니다.
	#       transition_to() 함수에서 전이 테이블을 확인하여 유효하면 전이하고,
	#       무효하면 경고를 출력합니다. 상태 히스토리를 배열로 기록합니다.

	print("연습 2: 상태 전환 함수")

	var sm = ValidatedStateMachine.new()
	print("  초기 상태: %s" % sm.get_state_name())
	print()

	# 전이 테이블 출력
	print("  전이 테이블:")
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

	# 유효한 전이 테스트
	print("  유효한 전이 테스트:")
	sm.transition_to("run")     # IDLE -> RUN (허용)
	sm.transition_to("jump")    # RUN -> JUMP (허용)
	sm.transition_to("idle")    # JUMP -> IDLE (착지, 허용)
	sm.transition_to("attack")  # IDLE -> ATTACK (허용)
	sm.transition_to("idle")    # ATTACK -> IDLE (공격 종료, 허용)
	print()

	# 무효한 전이 테스트
	print("  무효한 전이 테스트:")
	sm.transition_to("jump")    # IDLE -> JUMP (허용)
	sm.transition_to("attack")  # JUMP -> ATTACK (거부!)
	sm.transition_to("run")     # JUMP -> RUN (거부!)
	sm.transition_to("idle")    # JUMP -> IDLE (허용)
	print()

	# 상태 히스토리
	print("  상태 히스토리: %s" % sm.get_history())
	print()

	# 피격은 어디서든 가능
	print("  피격 전이 테스트 (어디서든 가능):")
	sm.transition_to("run")
	sm.transition_to("hurt")    # RUN -> HURT (허용)
	print("    현재: %s" % sm.get_state_name())
	sm.transition_to("idle")    # HURT -> IDLE (허용)
	print("    회복: %s" % sm.get_state_name())

	print("연습 2 완료: 상태 전환 함수\n")


# ==============================================================================
# 연습 3: 오브젝트 풀 - 미리 생성해둔 객체를 재사용하는
#          오브젝트 풀을 구현하세요.
# ==============================================================================
func _exercise_3_object_pool():
	# 풀이: 초기화 시 initial_size만큼 객체를 미리 생성하여 _available 배열에 넣습니다.
	#       get_object()는 _available에서 꺼내 _active로 옮기고 활성화합니다.
	#       return_object()는 _active에서 제거하고 상태를 초기화한 뒤 _available로 돌립니다.
	#       풀이 고갈되면 null을 반환하거나, AutoExpandPool처럼 자동 확장합니다.

	print("연습 3: 오브젝트 풀")

	# 기본 풀 생성
	var pool = ObjectPool.new(10)
	print("  풀 생성: 크기 = %d" % pool.pool_size())
	print("  사용 가능: %d, 사용 중: %d" % [pool.available_count(), pool.active_count()])
	print()

	# 객체 가져오기
	print("  객체 가져오기:")
	var objects: Array = []
	for i in range(5):
		var obj = pool.get_object()
		if obj:
			objects.append(obj)
			print("    가져옴: %s (사용 가능: %d)" % [obj.id, pool.available_count()])
	print()

	# 객체 반환
	print("  객체 반환:")
	for i in range(3):
		var obj = objects.pop_back()
		pool.return_object(obj)
		print("    반환: %s (사용 가능: %d)" % [obj.id, pool.available_count()])
	print()

	# 나머지 반환
	for obj in objects:
		pool.return_object(obj)

	# 풀 고갈 테스트
	print("  풀 고갈 테스트:")
	var temp_objs: Array = []
	for i in range(12):
		var obj = pool.get_object()
		if obj:
			temp_objs.append(obj)
		else:
			print("    #%d 풀 고갈! (null 반환)" % i)

	print("  사용 가능: %d, 사용 중: %d" % [pool.available_count(), pool.active_count()])
	print()

	# 모두 반환
	for obj in temp_objs:
		pool.return_object(obj)
	print("  모두 반환 후 사용 가능: %d" % pool.available_count())
	print()

	# 자동 확장 풀
	print("  자동 확장 풀:")
	var auto_pool = AutoExpandPool.new(3)
	print("    초기 크기: %d" % auto_pool.pool_size())

	var auto_objs: Array = []
	for i in range(7):
		var obj = auto_pool.get_object()
		auto_objs.append(obj)
		print("    #%d: %s (풀 크기: %d, 사용 가능: %d)" % [
			i, obj.id, auto_pool.pool_size(), auto_pool.available_count()
		])
	print()

	for obj in auto_objs:
		auto_pool.return_object(obj)
	print("    모두 반환 후 풀 크기: %d (확장 유지)" % auto_pool.pool_size())

	print("연습 3 완료: 오브젝트 풀\n")


# ==============================================================================
# 연습 4: HealthComponent - 시그널로 상태 변경을 알리는
#          HealthComponent를 구현하세요.
# ==============================================================================
func _exercise_4_health_component():
	# 풀이: HealthComponent 클래스에 damaged, healed, died, invincibility_changed
	#       시그널을 정의합니다. take_damage()는 무적/사망 상태를 확인 후 대미지를 적용하고
	#       damaged 시그널을 emit합니다. HP가 0이 되면 died를 emit합니다.
	#       heal()은 max_hp를 초과하지 않도록 clamp합니다.
	#       set_invincible()로 무적 상태를 토글합니다.

	print("연습 4: HealthComponent")

	var health = HealthComp.new(100, 100)
	print("  생성: HP %d/%d" % [health.current_hp, health.max_hp])
	print()

	# 시그널 연결
	health.damaged.connect(func(amount, current):
		print("    [시그널] %d 대미지! 현재 HP: %d" % [amount, current])
	)
	health.healed.connect(func(amount, current):
		print("    [시그널] %d 회복! 현재 HP: %d" % [amount, current])
	)
	health.died.connect(func():
		print("    [시그널] 사망!")
	)
	health.invincibility_changed.connect(func(is_invincible):
		print("    [시그널] 무적: %s" % is_invincible)
	)

	# 대미지 테스트
	print("  대미지 테스트:")
	health.take_damage(30)
	print("    HP: %d/%d (%.0f%%)" % [health.current_hp, health.max_hp, health.hp_percent()])
	print()

	# 무적 상태
	print("  무적 상태 테스트:")
	health.set_invincible(true)
	health.take_damage(50)
	print("    무적 중 대미지: HP %d (변화 없음)" % health.current_hp)
	health.set_invincible(false)
	print()

	# 회복 테스트
	print("  회복 테스트:")
	health.heal(20)
	print("    HP: %d" % health.current_hp)
	health.heal(999)
	print("    과다 회복: HP %d (최대치 제한)" % health.current_hp)
	print()

	# 사망 테스트
	print("  사망 테스트:")
	health.take_damage(999)
	print("    HP: %d, alive: %s" % [health.current_hp, health.is_alive()])
	print()

	# 사망 후 회복 불가
	health.heal(50)
	print("    사망 후 회복 시도: HP %d (회복 불가)" % health.current_hp)
	print()

	# 리셋
	health.reset()
	print("  리셋 후: HP %d/%d, alive: %s" % [health.current_hp, health.max_hp, health.is_alive()])
	print()

	# 전투 시뮬레이션
	print("  전투 시뮬레이션:")
	var player_hp = HealthComp.new(100, 100)
	var enemy_hp = HealthComp.new(50, 50)

	player_hp.died.connect(func(): print("    플레이어 사망!"))
	enemy_hp.died.connect(func(): print("    적 사망!"))

	print("    플레이어 HP: %d, 적 HP: %d" % [player_hp.current_hp, enemy_hp.current_hp])
	enemy_hp.take_damage(25)  # 플레이어가 공격
	enemy_hp.take_damage(25)  # 플레이어가 공격
	player_hp.take_damage(15) # 적이 공격
	print("    결과 - 플레이어 HP: %d, 적 alive: %s" % [player_hp.current_hp, enemy_hp.is_alive()])

	print("연습 4 완료: HealthComponent\n")


# ==============================================================================
# 연습 5: 이벤트 버스 - 발행/구독 패턴의 이벤트 버스를 구현하세요.
#          subscribe, publish, unsubscribe를 포함합니다.
# ==============================================================================
func _exercise_5_event_bus():
	# 풀이: Dictionary로 이벤트 이름 -> 콜백 배열을 관리합니다.
	#       subscribe(event, callback)는 배열에 콜백을 추가합니다.
	#       publish(event, data)는 해당 이벤트의 모든 콜백을 호출합니다.
	#       unsubscribe(event, callback)는 특정 콜백을 제거합니다.
	#       unsubscribe_all(event)는 이벤트의 모든 구독을 제거합니다.
	#       이벤트 카운터를 추가하여 발행 횟수를 추적합니다.

	print("연습 5: 이벤트 버스")

	var bus = SimpleEventBus.new()

	# 구독 등록
	print("  구독 등록:")

	bus.subscribe("enemy_killed", func(data):
		print("    [HUD] 적 처치! 타입: %s" % data.get("type", "unknown"))
	)
	bus.subscribe("enemy_killed", func(data):
		print("    [Audio] 처치 효과음 재생")
	)
	bus.subscribe("enemy_killed", func(data):
		print("    [Quest] 처치 퀘스트 진행: %s" % data.get("type", ""))
	)

	bus.subscribe("coin_collected", func(data):
		print("    [HUD] 코인 +%d" % data.get("amount", 0))
	)
	bus.subscribe("coin_collected", func(data):
		print("    [Audio] 코인 효과음")
	)

	bus.subscribe("player_died", func(data):
		print("    [HUD] 게임 오버 화면 표시")
	)
	bus.subscribe("player_died", func(data):
		print("    [Audio] 사망 사운드, BGM 정지")
	)

	print("    enemy_killed: %d 구독자" % bus.subscriber_count("enemy_killed"))
	print("    coin_collected: %d 구독자" % bus.subscriber_count("coin_collected"))
	print("    player_died: %d 구독자" % bus.subscriber_count("player_died"))
	print()

	# 이벤트 발행
	print("  이벤트 발행:")
	print("  [적 처치 이벤트]")
	bus.publish("enemy_killed", {"type": "Goblin", "position": Vector2(300, 200)})
	print()

	print("  [코인 수집 이벤트]")
	bus.publish("coin_collected", {"amount": 5})
	print()

	print("  [존재하지 않는 이벤트]")
	bus.publish("nonexistent_event", {})
	print("    (구독자 없음 - 무시됨)")
	print()

	# 구독 해제
	print("  구독 해제:")
	bus.unsubscribe_all("coin_collected")
	print("    coin_collected 전체 해제")
	bus.publish("coin_collected", {"amount": 10})
	print("    coin_collected 발행 -> 반응 없음")
	print()

	# 이벤트 통계
	print("  이벤트 통계:")
	bus.print_stats("    ")

	print("연습 5 완료: 이벤트 버스\n")


# ==============================================================================
# 연습 6: 성능 측정 - Time.get_ticks_usec()를 사용하여
#          다양한 최적화 기법의 성능을 측정하세요.
# ==============================================================================
func _exercise_6_performance_benchmark():
	# 풀이: Time.get_ticks_usec()로 시작 시간을 기록하고, 측정 대상 코드를
	#       반복 실행한 뒤 경과 시간을 계산합니다. 비교 항목:
	#       1) 노드 참조 캐싱 vs get_node() 매번 호출
	#       2) 타입 지정 변수 vs Variant 변수 연산
	#       3) distance_squared_to vs distance_to 거리 비교
	#       결과를 us(마이크로초) 단위로 출력하여 비교합니다.

	print("연습 6: 성능 측정")

	var iterations = 10000

	# 워밍업
	var _warmup_val = 0
	for i in range(1000):
		_warmup_val += i

	# --- 벤치마크 1: 노드 참조 캐싱 ---
	print("  1) 노드 참조 캐싱 벤치마크 (%d회):" % iterations)

	var test_node = Node.new()
	test_node.name = "BenchChild"
	add_child(test_node)

	# 매번 get_node
	var start = Time.get_ticks_usec()
	for i in range(iterations):
		var _n = get_node("BenchChild")
	var get_node_time = Time.get_ticks_usec() - start

	# 캐싱된 참조
	var cached_ref = test_node
	start = Time.get_ticks_usec()
	for i in range(iterations):
		var _n = cached_ref
	var cached_time = Time.get_ticks_usec() - start

	print("    get_node():  %d us" % get_node_time)
	print("    캐싱 참조:   %d us" % cached_time)
	if cached_time > 0:
		print("    캐싱이 약 %.1f배 빠름" % (float(get_node_time) / cached_time))

	test_node.queue_free()
	print()

	# --- 벤치마크 2: 타입 지정 연산 ---
	print("  2) 타입 지정 변수 벤치마크 (%d회):" % iterations)

	# 타입 없는 변수
	start = Time.get_ticks_usec()
	var a = 0
	var b = 1
	for i in range(iterations):
		a = a + b * 2 - 1
		b = b + 1
	var untyped_time = Time.get_ticks_usec() - start

	# 타입 있는 변수
	start = Time.get_ticks_usec()
	var a2: int = 0
	var b2: int = 1
	for i in range(iterations):
		a2 = a2 + b2 * 2 - 1
		b2 = b2 + 1
	var typed_time = Time.get_ticks_usec() - start

	print("    Variant (untyped): %d us" % untyped_time)
	print("    int (typed):       %d us" % typed_time)
	print()

	# --- 벤치마크 3: 거리 비교 ---
	print("  3) 거리 비교 벤치마크 (%d회):" % iterations)

	var pos_a = Vector2(100, 200)
	var pos_b = Vector2(500, 600)
	var threshold = 300.0
	var threshold_sq = threshold * threshold

	# distance_to (sqrt 포함)
	start = Time.get_ticks_usec()
	for i in range(iterations):
		var _close = pos_a.distance_to(pos_b) < threshold
	var dist_time = Time.get_ticks_usec() - start

	# distance_squared_to (sqrt 생략)
	start = Time.get_ticks_usec()
	for i in range(iterations):
		var _close = pos_a.distance_squared_to(pos_b) < threshold_sq
	var dist_sq_time = Time.get_ticks_usec() - start

	print("    distance_to():         %d us" % dist_time)
	print("    distance_squared_to(): %d us" % dist_sq_time)
	if dist_sq_time > 0:
		print("    squared가 약 %.1f배 빠름" % (float(dist_time) / dist_sq_time))
	print()

	# --- 벤치마크 4: 배열 타입 ---
	print("  4) 배열 타입 벤치마크 (%d 요소):" % iterations)

	# 타입 없는 배열
	var untyped_arr = []
	start = Time.get_ticks_usec()
	for i in range(iterations):
		untyped_arr.append(i)
	var arr_untyped_time = Time.get_ticks_usec() - start

	# 타입 있는 배열
	var typed_arr: Array[int] = []
	start = Time.get_ticks_usec()
	for i in range(iterations):
		typed_arr.append(i)
	var arr_typed_time = Time.get_ticks_usec() - start

	# PackedInt32Array
	var packed_arr = PackedInt32Array()
	start = Time.get_ticks_usec()
	for i in range(iterations):
		packed_arr.append(i)
	var arr_packed_time = Time.get_ticks_usec() - start

	print("    Array (untyped):    %d us" % arr_untyped_time)
	print("    Array[int] (typed): %d us" % arr_typed_time)
	print("    PackedInt32Array:   %d us" % arr_packed_time)
	print()

	# 현재 성능 모니터
	print("  Performance 싱글톤 정보:")
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	print("    FPS: %.0f" % fps)
	print("    Object 수: %.0f" % objects)
	print("    Node 수: %.0f" % nodes)
	print("    정적 메모리: %.2f MB" % (memory / 1048576.0))

	print("연습 6 완료: 성능 측정\n")


# ==============================================================================
# 연습 7: 내보내기 체크리스트 - 게임 출시 전 최적화 및 품질 확인
#          체크리스트를 출력하세요.
# ==============================================================================
func _exercise_7_export_checklist():
	# 풀이: 게임을 내보내기(export)하기 전에 확인해야 할 항목을 카테고리별로
	#       정리합니다. 코드, 렌더링, 물리, 프로젝트 레벨로 나누고,
	#       각 항목에 체크박스 형식으로 출력합니다.
	#       추가로 일반적인 성능 실수도 목록화합니다.

	print("연습 7: 내보내기 체크리스트")

	print()
	print("  [코드 최적화]")
	print("    [x] 노드 참조 캐싱 (@onready 사용)")
	print("    [x] 타입 지정 변수/배열 사용 (var x: int)")
	print("    [x] _process()에서 불필요한 배열/문자열 할당 제거")
	print("    [x] distance_squared_to() 사용 (거리 비교)")
	print("    [x] 화면 밖 객체 set_process(false)")
	print("    [x] 빈번한 생성/삭제에 오브젝트 풀링 적용")
	print("    [x] 시그널로 느슨한 결합 유지")
	print()

	print("  [렌더링 최적화]")
	print("    [x] 텍스처 아틀라스 사용 (draw call 감소)")
	print("    [x] CanvasGroup으로 배치 렌더링")
	print("    [x] 보이지 않는 노드 visible = false")
	print("    [x] 카메라 밖 자동 컬링 확인")
	print("    [x] Light2D 사용 최소화")
	print("    [x] 텍스처 크기 Power of 2 (256, 512, 1024)")
	print()

	print("  [물리 최적화]")
	print("    [x] 충돌 레이어/마스크 최소화")
	print("    [x] 간단한 충돌 형태 사용 (원 > 사각형 > 다각형)")
	print("    [x] 가능한 곳은 RayCast로 Area2D 대체")
	print("    [x] 정적 객체는 StaticBody2D 사용")
	print()

	print("  [프로젝트 설정]")
	print("    [x] 디버그 print() 제거 또는 비활성화")
	print("    [x] 릴리즈 빌드 (Export Release) 사용")
	print("    [x] 에셋 압축 확인 (텍스처, 오디오)")
	print("    [x] 불필요한 플러그인 비활성화")
	print("    [x] 내보내기 프리셋 올바른 플랫폼 확인")
	print()

	print("  [일반적인 성능 실수]")
	print("    1. _process()에서 매 프레임 배열 생성 -> 멤버 변수 재사용")
	print("    2. 매 프레임 label.text 갱신 -> 값 변경 시에만 갱신")
	print("    3. get_overlapping_areas() 매 프레임 호출 -> 시그널 사용")
	print("    4. 릴리즈 빌드에 print() 남김 -> 조건부 출력 또는 제거")
	print("    5. 불필요한 await/yield -> 필요한 경우에만 비동기")
	print("    6. 매 프레임 get_children() -> 자식 참조 캐싱")
	print()

	print("  [프로파일링 도구]")
	print("    - Debugger > Profiler: 함수별 실행 시간")
	print("    - Debugger > Monitors: FPS, 메모리, 노드 수")
	print("    - Time.get_ticks_usec(): 코드 구간 측정")
	print("    - Performance.get_monitor(): 런타임 모니터링")

	print("연습 7 완료: 내보내기 체크리스트\n")


# ==============================================================================
# 내부 클래스: SimpleStateMachine (enum 기반)
# ==============================================================================
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


# ==============================================================================
# 내부 클래스: ValidatedStateMachine (전이 테이블 기반)
# ==============================================================================
class ValidatedStateMachine:
	var _current_state: String = "idle"
	var _history: Array[String] = ["idle"]

	# 전이 테이블: 각 상태에서 전이 가능한 상태 목록
	var _transition_table: Dictionary = {
		"idle":   ["run", "jump", "attack", "hurt"],
		"run":    ["idle", "jump", "attack", "hurt"],
		"jump":   ["idle", "hurt"],
		"attack": ["idle", "hurt"],
		"hurt":   ["idle"],
	}

	func get_state_name() -> String:
		return _current_state

	func transition_to(new_state: String) -> bool:
		if new_state == _current_state:
			return false

		var allowed = _transition_table.get(_current_state, [])
		if new_state in allowed:
			var old_state = _current_state
			_current_state = new_state
			_history.append(new_state)
			if _history.size() > 20:
				_history.pop_front()
			print("    [FSM] %s -> %s (허용)" % [old_state, new_state])
			return true
		else:
			print("    [FSM] %s -> %s (거부!)" % [_current_state, new_state])
			return false

	func get_history() -> Array[String]:
		return _history


# ==============================================================================
# 내부 클래스: PoolableObject
# ==============================================================================
class PoolableObj:
	var id: String
	var active: bool = false
	var position: Vector2 = Vector2.ZERO

	func _init(p_id: String = ""):
		id = p_id

	func activate():
		active = true

	func deactivate():
		active = false
		position = Vector2.ZERO

	func reset():
		position = Vector2.ZERO


# ==============================================================================
# 내부 클래스: ObjectPool (기본 풀)
# ==============================================================================
class ObjectPool:
	var _available: Array = []
	var _active: Array = []
	var _next_id: int = 0

	func _init(initial_size: int):
		for i in range(initial_size):
			var obj = _create_object()
			_available.append(obj)

	func _create_object() -> PoolableObj:
		_next_id += 1
		return PoolableObj.new("obj_%d" % _next_id)

	func get_object() -> PoolableObj:
		if _available.is_empty():
			return null

		var obj = _available.pop_back()
		obj.activate()
		_active.append(obj)
		return obj

	func return_object(obj: PoolableObj):
		if obj in _active:
			_active.erase(obj)
		obj.deactivate()
		obj.reset()
		_available.append(obj)

	func pool_size() -> int:
		return _available.size() + _active.size()

	func available_count() -> int:
		return _available.size()

	func active_count() -> int:
		return _active.size()


# ==============================================================================
# 내부 클래스: AutoExpandPool (자동 확장 풀)
# ==============================================================================
class AutoExpandPool extends ObjectPool:
	var _expand_amount: int = 5

	func get_object() -> PoolableObj:
		if _available.is_empty():
			for i in range(_expand_amount):
				var obj = _create_object()
				_available.append(obj)

		return super.get_object()


# ==============================================================================
# 내부 클래스: HealthComp (HealthComponent)
# ==============================================================================
class HealthComp:
	signal damaged(amount: float, current_hp: float)
	signal healed(amount: float, current_hp: float)
	signal died
	signal invincibility_changed(is_invincible: bool)

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
		invincibility_changed.emit(value)

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


# ==============================================================================
# 내부 클래스: SimpleEventBus (발행/구독 패턴)
# ==============================================================================
class SimpleEventBus:
	var _subscribers: Dictionary = {}  # event_name -> Array[Callable]
	var _event_counts: Dictionary = {} # event_name -> int

	func subscribe(event_name: String, callback: Callable):
		if not _subscribers.has(event_name):
			_subscribers[event_name] = []
		_subscribers[event_name].append(callback)

	func unsubscribe(event_name: String, callback: Callable):
		if _subscribers.has(event_name):
			_subscribers[event_name].erase(callback)

	func unsubscribe_all(event_name: String):
		_subscribers.erase(event_name)

	func publish(event_name: String, data: Dictionary = {}):
		# 발행 횟수 기록
		if not _event_counts.has(event_name):
			_event_counts[event_name] = 0
		_event_counts[event_name] += 1

		# 구독자에게 전달
		if not _subscribers.has(event_name):
			return
		for callback in _subscribers[event_name]:
			callback.call(data)

	func subscriber_count(event_name: String) -> int:
		if _subscribers.has(event_name):
			return _subscribers[event_name].size()
		return 0

	func get_event_names() -> Array:
		return _subscribers.keys()

	func print_stats(indent: String = ""):
		print("%s발행 통계:" % indent)
		for event_name in _event_counts:
			var count = _event_counts[event_name]
			var subs = subscriber_count(event_name)
			print("%s  %s: %d회 발행, %d 구독자" % [indent, event_name, count, subs])
