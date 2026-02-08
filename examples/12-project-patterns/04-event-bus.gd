# Chapter 12 - Project Patterns
# 04-event-bus.gd - 이벤트 버스(Event Bus) 패턴
#
# 이 파일에서 배울 내용:
# - 이벤트 버스 패턴의 개념과 장점
# - Autoload 기반 전역 시그널 허브
# - 발행(Publish) / 구독(Subscribe) 패턴
# - 이벤트 버스를 활용한 시스템 간 통신
# - 디버깅과 이벤트 로깅

extends Node

func _ready():
	print("=== Chapter 12-4: 이벤트 버스(Event Bus) 패턴 ===\n")

	# -----------------------------------------------------------------
	# 1) 이벤트 버스란?
	# -----------------------------------------------------------------
	print("--- 1. 이벤트 버스 개념 ---")

	print("  문제: 직접 참조의 강한 결합")
	print("    Player -> HUD (HP 바 업데이트)")
	print("    Player -> Enemy (알림)")
	print("    Player -> AudioManager (사운드)")
	print("    Player -> QuestManager (진행)")
	print("    -> Player가 모든 시스템을 알아야 함!")
	print()

	print("  해결: 이벤트 버스 (중간 매개체)")
	print("    Player -> EventBus -> HUD")
	print("                       -> Enemy")
	print("                       -> AudioManager")
	print("                       -> QuestManager")
	print("    -> Player는 EventBus에만 이벤트 발행")
	print("    -> 관심 있는 시스템이 각자 구독")
	print()

	print("  Godot에서의 구현: Autoload + 커스텀 시그널")
	print()

	# -----------------------------------------------------------------
	# 2) 기본 EventBus 구현
	# -----------------------------------------------------------------
	print("--- 2. 기본 EventBus ---")

	var bus = EventBus.new()

	print("  EventBus에 정의된 시그널:")
	print("    player_damaged(amount, current_hp)")
	print("    player_died()")
	print("    player_healed(amount)")
	print("    enemy_killed(enemy_type, position)")
	print("    coin_collected(amount)")
	print("    item_picked_up(item_id)")
	print("    level_completed(level_id, time)")
	print("    score_changed(new_score)")
	print("    game_paused()")
	print("    game_resumed()")
	print()

	# -----------------------------------------------------------------
	# 3) 구독(Subscribe) 패턴
	# -----------------------------------------------------------------
	print("--- 3. 구독 패턴 ---")

	# HUD가 구독
	bus.player_damaged.connect(func(amount, current_hp):
		print("    [HUD] HP 바 업데이트: %d (-%d)" % [current_hp, amount])
	)

	bus.player_died.connect(func():
		print("    [HUD] 게임 오버 화면 표시")
	)

	bus.score_changed.connect(func(new_score):
		print("    [HUD] 점수 업데이트: %d" % new_score)
	)

	bus.coin_collected.connect(func(amount):
		print("    [HUD] 코인 +%d" % amount)
	)

	# AudioManager가 구독
	bus.player_damaged.connect(func(_amount, _hp):
		print("    [Audio] 피격 사운드 재생")
	)

	bus.player_died.connect(func():
		print("    [Audio] 사망 사운드 재생, BGM 정지")
	)

	bus.coin_collected.connect(func(_amount):
		print("    [Audio] 코인 효과음 재생")
	)

	bus.enemy_killed.connect(func(enemy_type, _pos):
		print("    [Audio] %s 처치 사운드 재생" % enemy_type)
	)

	# QuestManager가 구독
	bus.enemy_killed.connect(func(enemy_type, _pos):
		print("    [Quest] 처치 퀘스트 진행: %s" % enemy_type)
	)

	bus.item_picked_up.connect(func(item_id):
		print("    [Quest] 아이템 수집 퀘스트 확인: %s" % item_id)
	)

	# VFX Manager가 구독
	bus.enemy_killed.connect(func(_type, pos):
		print("    [VFX] 처치 이펙트 재생 at %s" % pos)
	)

	print("  4개 시스템이 이벤트 구독 완료")
	print("  (HUD, Audio, Quest, VFX)")
	print()

	# -----------------------------------------------------------------
	# 4) 발행(Publish) 패턴
	# -----------------------------------------------------------------
	print("--- 4. 발행 패턴 ---")

	print("  [이벤트] 플레이어가 적에게 피격:")
	bus.player_damaged.emit(25, 75)
	print()

	print("  [이벤트] 적 처치:")
	bus.enemy_killed.emit("Goblin", Vector2(500, 300))
	print()

	print("  [이벤트] 코인 수집:")
	bus.coin_collected.emit(5)
	bus.score_changed.emit(150)
	print()

	print("  [이벤트] 아이템 획득:")
	bus.item_picked_up.emit("magic_sword")
	print()

	print("  [이벤트] 플레이어 사망:")
	bus.player_died.emit()
	print()

	# -----------------------------------------------------------------
	# 5) 고급 EventBus: 동적 이벤트
	# -----------------------------------------------------------------
	print("--- 5. 동적 이벤트 시스템 ---")

	var dynamic_bus = DynamicEventBus.new()

	# 동적으로 이벤트 구독
	dynamic_bus.subscribe("quest_completed", func(data):
		print("    [구독자A] 퀘스트 완료: %s" % data)
	)

	dynamic_bus.subscribe("quest_completed", func(data):
		print("    [구독자B] 퀘스트 보상 지급: %s" % data)
	)

	dynamic_bus.subscribe("achievement_unlocked", func(data):
		print("    [구독자C] 업적 달성: %s" % data)
	)

	# 이벤트 발행
	print("  동적 이벤트 발행:")
	dynamic_bus.publish("quest_completed", {"id": "find_sword", "reward": 500})
	dynamic_bus.publish("achievement_unlocked", {"name": "First Blood", "icon": "skull"})
	dynamic_bus.publish("nonexistent_event", {})  # 구독자 없음 - 무시됨
	print()

	# 구독 해제
	print("  구독 해제 후:")
	dynamic_bus.unsubscribe_all("quest_completed")
	dynamic_bus.publish("quest_completed", {"id": "test"})  # 아무 반응 없음
	print("    (quest_completed 구독자 없음 - 출력 없음)")
	print()

	# 등록된 이벤트 목록
	print("  등록된 이벤트: ", dynamic_bus.get_event_names())
	print()

	# -----------------------------------------------------------------
	# 6) 이벤트 로깅 (디버그용)
	# -----------------------------------------------------------------
	print("--- 6. 이벤트 로깅 ---")

	var logged_bus = LoggedEventBus.new(true)  # 디버그 모드 활성화

	logged_bus.subscribe("player_move", func(data):
		pass  # 빈 처리
	)
	logged_bus.subscribe("player_jump", func(data):
		pass
	)

	print("  디버그 로깅 활성화:")
	logged_bus.publish("player_move", {"x": 100, "y": 200})
	logged_bus.publish("player_jump", {"force": 400})
	logged_bus.publish("unknown_event", {})
	print()

	# 통계 출력
	logged_bus.print_stats("  ")
	print()

	# -----------------------------------------------------------------
	# 7) EventBus 실전 코드
	# -----------------------------------------------------------------
	print("--- 7. EventBus.gd 실전 코드 ---")

	print("  # event_bus.gd (Autoload로 등록)")
	print("  extends Node")
	print()
	print("  # === 플레이어 이벤트 ===")
	print("  signal player_spawned(player: Node)")
	print("  signal player_damaged(amount: float, current_hp: float)")
	print("  signal player_healed(amount: float)")
	print("  signal player_died")
	print("  signal player_respawned(position: Vector2)")
	print()
	print("  # === 전투 이벤트 ===")
	print("  signal enemy_spawned(enemy: Node)")
	print("  signal enemy_killed(enemy_type: String, pos: Vector2, xp: int)")
	print("  signal damage_dealt(amount: float, target: Node, source: Node)")
	print("  signal boss_phase_changed(phase: int)")
	print()
	print("  # === 아이템/경제 이벤트 ===")
	print("  signal item_picked_up(item_id: String, amount: int)")
	print("  signal item_used(item_id: String)")
	print("  signal coins_changed(new_amount: int)")
	print("  signal shop_opened(shop_id: String)")
	print()
	print("  # === UI 이벤트 ===")
	print("  signal dialog_started(dialog_id: String)")
	print("  signal dialog_ended")
	print("  signal notification_requested(message: String, type: String)")
	print()
	print("  # === 게임 흐름 이벤트 ===")
	print("  signal level_started(level_id: int)")
	print("  signal level_completed(level_id: int, stars: int)")
	print("  signal checkpoint_reached(checkpoint_id: int)")
	print("  signal game_saved(slot: int)")
	print("  signal game_loaded(slot: int)")
	print("  signal game_paused")
	print("  signal game_resumed")
	print()

	# -----------------------------------------------------------------
	# 8) 사용 예시: 시스템 간 통신
	# -----------------------------------------------------------------
	print("--- 8. 시스템 간 통신 예시 ---")

	print("  # player.gd - 이벤트 발행만")
	print("  func take_damage(amount: float):")
	print("      hp -= amount")
	print("      EventBus.player_damaged.emit(amount, hp)")
	print("      if hp <= 0:")
	print("          EventBus.player_died.emit()")
	print()

	print("  # hud.gd - 이벤트 구독만")
	print("  func _ready():")
	print("      EventBus.player_damaged.connect(_on_player_damaged)")
	print("      EventBus.player_died.connect(_on_player_died)")
	print("      EventBus.coins_changed.connect(_on_coins_changed)")
	print()
	print("  func _on_player_damaged(amount, current_hp):")
	print("      hp_bar.value = current_hp")
	print("      damage_flash()")
	print()

	print("  # audio_manager.gd - 이벤트 구독")
	print("  func _ready():")
	print("      EventBus.player_damaged.connect(func(_a, _h): play_sfx(\"hit\"))")
	print("      EventBus.enemy_killed.connect(func(_t, _p, _x): play_sfx(\"kill\"))")
	print("      EventBus.coin_picked_up.connect(func(_a): play_sfx(\"coin\"))")
	print()

	# -----------------------------------------------------------------
	# 9) EventBus 주의사항
	# -----------------------------------------------------------------
	print("--- 9. EventBus 주의사항 ---")

	print("  1. 시그널 이름을 명확하게")
	print("     나쁜 예: signal update, signal changed")
	print("     좋은 예: signal player_hp_changed, signal enemy_spawned")
	print()
	print("  2. 너무 많은 이벤트는 추적 어려움")
	print("     - 카테고리별로 그룹화")
	print("     - 로깅 시스템 활용")
	print("     - 문서화 필수")
	print()
	print("  3. 구독 해제 잊지 않기 (메모리 누수)")
	print("     func _exit_tree():")
	print("         EventBus.player_damaged.disconnect(_on_player_damaged)")
	print("     또는 CONNECT_ONE_SHOT 플래그 사용")
	print()
	print("  4. 순서 의존성 주의")
	print("     - 시그널 연결 순서가 호출 순서를 결정")
	print("     - 순서에 의존하는 로직은 피하기")
	print()
	print("  5. 무거운 처리는 deferred로")
	print("     EventBus.enemy_killed.connect(")
	print("         _heavy_processing, CONNECT_DEFERRED)")
	print()

	# -----------------------------------------------------------------
	# 10) EventBus vs 직접 시그널 비교
	# -----------------------------------------------------------------
	print("--- 10. EventBus vs 직접 시그널 ---")

	print("  +------------------+-----------------+-----------------+")
	print("  | 특성             | EventBus        | 직접 시그널     |")
	print("  +------------------+-----------------+-----------------+")
	print("  | 결합도           | 느슨함          | 강함            |")
	print("  | 참조 필요        | EventBus만      | 대상 노드       |")
	print("  | 디버깅           | 추적 어려움     | 명확함          |")
	print("  | 성능             | 약간 오버헤드   | 직접 호출       |")
	print("  | 적합한 경우      | 시스템 간 통신  | 부모-자식 통신  |")
	print("  +------------------+-----------------+-----------------+")
	print()

	print("  권장 사용 기준:")
	print("    EventBus: 다른 씬/시스템 간의 통신")
	print("    직접 시그널: 같은 씬 내 노드 간의 통신")
	print()

	print("=== 04-event-bus.gd 완료 ===")


# =============================================================================
# 기본 EventBus (시그널 기반)
# =============================================================================

class EventBus:
	# 플레이어 이벤트
	signal player_damaged(amount: float, current_hp: float)
	signal player_healed(amount: float)
	signal player_died

	# 전투 이벤트
	signal enemy_killed(enemy_type: String, position: Vector2)

	# 경제 이벤트
	signal coin_collected(amount: int)
	signal item_picked_up(item_id: String)
	signal score_changed(new_score: int)

	# 게임 흐름
	signal level_completed(level_id: int, time: float)
	signal game_paused
	signal game_resumed


# =============================================================================
# 동적 이벤트 버스 (문자열 기반)
# =============================================================================

class DynamicEventBus:
	var _subscribers: Dictionary = {}  # event_name -> Array[Callable]

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
		if not _subscribers.has(event_name):
			return
		for callback in _subscribers[event_name]:
			callback.call(data)

	func get_event_names() -> Array:
		return _subscribers.keys()

	func get_subscriber_count(event_name: String) -> int:
		if _subscribers.has(event_name):
			return _subscribers[event_name].size()
		return 0


# =============================================================================
# 로깅 이벤트 버스 (디버그용)
# =============================================================================

class LoggedEventBus extends DynamicEventBus:
	var _debug_mode: bool = false
	var _event_log: Array[Dictionary] = []
	var _event_counts: Dictionary = {}

	func _init(debug: bool = false):
		_debug_mode = debug

	func publish(event_name: String, data: Dictionary = {}):
		# 카운트 기록
		if not _event_counts.has(event_name):
			_event_counts[event_name] = 0
		_event_counts[event_name] += 1

		# 로그 기록
		if _debug_mode:
			var log_entry = {
				"event": event_name,
				"data": data,
				"subscribers": get_subscriber_count(event_name),
				"time": Time.get_ticks_msec()
			}
			_event_log.append(log_entry)
			print("    [EventLog] '%s' -> %d subscribers, data=%s" % [
				event_name, log_entry["subscribers"], data
			])

		# 실제 발행
		super.publish(event_name, data)

	func print_stats(indent: String = ""):
		print("%s이벤트 통계:" % indent)
		for event_name in _event_counts:
			print("%s  %s: %d회 발행, %d 구독자" % [
				indent, event_name,
				_event_counts[event_name],
				get_subscriber_count(event_name)
			])
		print("%s  총 로그: %d건" % [indent, _event_log.size()])

	func get_log() -> Array[Dictionary]:
		return _event_log

	func clear_log():
		_event_log.clear()
