# 챕터 6: 시그널과 그룹 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - connect()로 시그널 연결하기
# - 커스텀 시그널(signal) 선언
# - emit_signal() / signal.emit()으로 시그널 발송
# - 람다(Lambda) 함수로 시그널 연결
# - 그룹(Group)으로 노드 분류
# - call_group()으로 그룹 일괄 호출
# - 시그널 버스(Signal Bus) 패턴

extends Node


# =============================================
# 연습 2: 커스텀 시그널 선언
# =============================================
# 풀이: signal 키워드로 커스텀 시그널을 선언합니다.
# 매개변수를 지정하면 emit 시 해당 데이터를 전달할 수 있습니다.
# 시그널은 옵저버 패턴을 구현하는 Godot의 핵심 메커니즘입니다.
# 추가 설명: 시그널명은 과거형 동사(예: health_changed, item_collected)로
# 짓는 것이 Godot의 관례입니다.
signal health_changed(old_value: int, new_value: int)
signal player_died
signal item_collected(item_name: String, item_value: int)
signal score_updated(new_score: int)
signal game_event(event_name: String, event_data: Dictionary)

# 상태 변수
var health: int = 100
var max_health: int = 100
var score: int = 0
var event_log: Array = []


func _ready():
	print("\n=== 챕터 6: 시그널과 그룹 ===")

	# =============================================
	# 연습 1: connect()로 내장 시그널 연결
	# =============================================
	# 풀이: 모든 노드는 내장 시그널을 가지고 있습니다.
	# 시그널을 연결하는 방법:
	# 1) signal.connect(callable) - Godot 4.x 방식 (권장)
	# 2) connect("signal_name", callable) - 문자열 기반 방식
	#
	# 주요 내장 시그널:
	# - tree_entered: 씬 트리에 추가될 때
	# - tree_exiting: 씬 트리에서 제거되기 직전
	# - ready: _ready() 호출 시
	# - child_entered_tree: 자식 노드가 추가될 때
	# - child_exiting_tree: 자식 노드가 제거되기 직전
	# 추가 설명: 시그널 연결은 "발신자.시그널.connect(수신자의_메서드)" 형태입니다.
	print("--- 연습 1: connect()로 시그널 연결 ---")

	# 자식 노드 추가/제거 시그널 연결
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)

	# 테스트: 자식 노드를 추가하여 시그널 발동 확인
	var test_node = Node.new()
	test_node.name = "TestChild"
	add_child(test_node)  # child_entered_tree 시그널 발동

	print("결과 1-1: child_entered_tree 시그널 연결 완료")
	print("결과 1-2: child_exiting_tree 시그널 연결 완료")

	# =============================================
	# 연습 2: 커스텀 시그널 연결
	# =============================================
	# 풀이: 위에서 선언한 커스텀 시그널을 connect()로 연결합니다.
	# 시그널을 연결해야 emit 시 콜백 함수가 호출됩니다.
	print("--- 연습 2: 커스텀 시그널 연결 ---")

	health_changed.connect(_on_health_changed)
	player_died.connect(_on_player_died)
	item_collected.connect(_on_item_collected)
	score_updated.connect(_on_score_updated)
	game_event.connect(_on_game_event)

	print("결과 2-1: health_changed 시그널 연결됨")
	print("결과 2-2: player_died 시그널 연결됨")
	print("결과 2-3: item_collected 시그널 연결됨")
	print("결과 2-4: score_updated 시그널 연결됨")
	print("결과 2-5: game_event 시그널 연결됨")

	# =============================================
	# 연습 3: emit으로 시그널 발송
	# =============================================
	# 풀이: 시그널을 발송(emit)하면 연결된 모든 콜백 함수가 호출됩니다.
	# Godot 4.x에서는 signal.emit(args...) 방식을 사용합니다.
	# (구버전의 emit_signal("name", args...) 방식도 동작합니다)
	# 추가 설명: 시그널은 동기적으로 실행됩니다.
	# emit() 호출 시 연결된 모든 콜백이 즉시 실행된 후 다음 줄로 넘어갑니다.
	print("--- 연습 3: emit으로 시그널 발송 ---")

	# 체력 변경 시그널 발송
	var old_hp = health
	health = 75
	health_changed.emit(old_hp, health)  # _on_health_changed(100, 75) 호출됨

	# 아이템 수집 시그널 발송
	item_collected.emit("마법 검", 50)  # _on_item_collected("마법 검", 50) 호출됨
	item_collected.emit("회복 물약", 25)

	# 점수 업데이트 시그널 발송
	score_updated.emit(score)

	# 게임 이벤트 시그널 발송 (딕셔너리로 유연한 데이터 전달)
	game_event.emit("level_up", {"level": 5, "class": "전사"})

	# 체력을 0으로 만들어 사망 시그널 발송
	old_hp = health
	health = 0
	health_changed.emit(old_hp, health)
	player_died.emit()

	print("결과 3: 모든 시그널 발송 완료")
	print("  이벤트 로그: ", event_log)

	# =============================================
	# 연습 4: 람다(Lambda) 함수로 시그널 연결
	# =============================================
	# 풀이: 간단한 콜백은 람다(익명 함수)로 인라인 연결할 수 있습니다.
	# func(매개변수): 본문 형태로 작성합니다.
	# 별도의 콜백 함수를 정의하지 않아도 되어 코드가 간결해집니다.
	# 추가 설명: 람다는 외부 변수를 캡처(capture)할 수 있습니다.
	# 단, 너무 복잡한 로직은 별도 함수로 분리하는 것이 가독성에 좋습니다.
	print("--- 연습 4: 람다 시그널 연결 ---")

	# 새로운 시그널 테스트를 위해 기존 연결 해제 후 람다로 재연결
	# (같은 시그널에 여러 콜백을 연결할 수 있음)

	# 람다로 시그널 연결
	var lambda_log: Array = []

	# 간단한 람다 연결
	var test_signal_node = Node.new()
	test_signal_node.name = "LambdaTest"
	test_signal_node.tree_entered.connect(func():
		lambda_log.append("tree_entered 람다 호출됨!")
		print("  [람다] tree_entered 발동!")
	)
	add_child(test_signal_node)

	# 매개변수가 있는 람다
	var extra_health_handler = func(old_val: int, new_val: int):
		var diff = new_val - old_val
		lambda_log.append("체력 변화: %d -> %d (차이: %d)" % [old_val, new_val, diff])
		print("  [람다] 체력 변화: %d -> %d" % [old_val, new_val])

	health_changed.connect(extra_health_handler)

	# 람다 연결 테스트
	health = 50
	health_changed.emit(0, 50)

	print("결과 4-1 (람다 로그): ", lambda_log)

	# 연결 해제 (disconnect)
	health_changed.disconnect(extra_health_handler)
	print("결과 4-2: 람다 핸들러 연결 해제됨")

	# =============================================
	# 연습 5: 그룹으로 노드 관리
	# =============================================
	# 풀이: 그룹은 노드에 태그를 붙이는 시스템입니다.
	# 같은 종류의 노드를 묶어서 일괄 처리할 때 유용합니다.
	# - add_to_group("name"): 그룹에 추가
	# - is_in_group("name"): 그룹 소속 확인
	# - get_tree().get_nodes_in_group("name"): 그룹 노드 전체 조회
	# 추가 설명: 하나의 노드가 여러 그룹에 동시에 속할 수 있습니다.
	print("--- 연습 5: 그룹 관리 ---")

	# 적 노드 생성 및 그룹 추가
	var enemies: Array = []
	for i in range(5):
		var enemy = Node2D.new()
		enemy.name = "Enemy_%02d" % i
		enemy.add_to_group("enemies")
		enemy.add_to_group("damageable")
		enemy.set_meta("hp", 100)
		enemy.set_meta("damage", 10 + i * 5)
		add_child(enemy)
		enemies.append(enemy)

	# NPC 노드 생성 및 그룹 추가
	var npc = Node2D.new()
	npc.name = "FriendlyNPC"
	npc.add_to_group("npcs")
	npc.add_to_group("damageable")
	add_child(npc)

	# 그룹별 노드 조회
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	var all_damageable = get_tree().get_nodes_in_group("damageable")
	var all_npcs = get_tree().get_nodes_in_group("npcs")

	print("결과 5-1 (enemies 그룹 수): ", all_enemies.size())
	print("결과 5-2 (damageable 그룹 수): ", all_damageable.size())
	print("결과 5-3 (npcs 그룹 수): ", all_npcs.size())

	# 그룹 내 노드 이름 출력
	print("결과 5-4 (enemies 목록):")
	for enemy in all_enemies:
		print("  - ", enemy.name, " (공격력: ", enemy.get_meta("damage"), ")")

	# =============================================
	# 연습 6: call_group()으로 그룹 일괄 호출
	# =============================================
	# 풀이: call_group()은 그룹에 속한 모든 노드의 메서드를 일괄 호출합니다.
	# get_tree().call_group("group_name", "method_name", args...)
	# 변형 메서드:
	# - call_group(): 일반 호출
	# - call_group_flags(): 플래그로 호출 순서/방식 제어
	# - notify_group(): 알림 전송
	# - set_group(): 속성값 일괄 설정
	# 추가 설명: call_group은 다음 유휴 프레임에 실행됩니다(지연 호출).
	# 즉시 실행하려면 call_group_flags에 GROUP_CALL_REALTIME 플래그를 사용합니다.
	print("--- 연습 6: call_group 일괄 호출 ---")

	# set_group으로 속성 일괄 설정
	# 모든 적의 visible 속성을 false로 설정
	get_tree().set_group("enemies", "visible", false)
	print("결과 6-1: enemies 그룹 visible = false 설정됨")

	# call_group으로 메서드 일괄 호출
	# 모든 적을 "hidden" 그룹에 추가
	get_tree().call_group("enemies", "add_to_group", "hidden")
	print("결과 6-2: enemies 그룹에 'hidden' 그룹 추가됨")

	# 확인
	var hidden_nodes = get_tree().get_nodes_in_group("hidden")
	print("결과 6-3 (hidden 그룹 수): ", hidden_nodes.size())

	# notify_group 사용 (NOTIFICATION 상수 전달)
	# 예: get_tree().notify_group("enemies", NOTIFICATION_PAUSED)
	print("결과 6-4: notify_group은 NOTIFICATION 상수를 전달합니다")

	# call_group_flags 사용
	# SceneTree.GROUP_CALL_DEFERRED (1): 지연 호출
	# SceneTree.GROUP_CALL_REALTIME (0) 은 Godot 4에서 기본값입니다
	get_tree().call_group_flags(0, "enemies", "set_meta", "status", "alert")
	print("결과 6-5: call_group_flags로 즉시 메타데이터 설정됨")

	# =============================================
	# 연습 7: 시그널 버스(Signal Bus) 패턴
	# =============================================
	# 풀이: 시그널 버스는 전역 시그널을 관리하는 자동 로드(AutoLoad) 싱글톤 패턴입니다.
	# 노드 간 직접 참조 없이 이벤트를 주고받을 수 있어 결합도를 낮춥니다.
	#
	# 구현 방법:
	# 1) EventBus.gd 스크립트 파일 생성 (시그널만 선언)
	# 2) 프로젝트 설정 > AutoLoad에 등록
	# 3) 어디서든 EventBus.signal_name.emit() / .connect() 사용
	#
	# 추가 설명: 시그널 버스를 남용하면 디버깅이 어려워질 수 있습니다.
	# 직접적인 부모-자식 관계에서는 일반 시그널을 사용하고,
	# 서로 관련 없는 먼 노드 간 통신에만 시그널 버스를 사용하세요.
	print("--- 연습 7: 시그널 버스 패턴 ---")

	# 시그널 버스 시뮬레이션 (실제로는 AutoLoad 스크립트로 분리)
	# EventBus.gd 파일 내용 예시:
	print("결과 7-1: 시그널 버스 패턴 (EventBus.gd 예시):")
	print("  # event_bus.gd")
	print("  extends Node")
	print("  ")
	print("  signal player_health_changed(old_hp, new_hp)")
	print("  signal enemy_defeated(enemy_name, reward)")
	print("  signal level_completed(level_number)")
	print("  signal game_paused(is_paused)")
	print("  signal ui_notification(message, type)")

	# 시그널 버스 사용 예시 시뮬레이션
	# 이 스크립트 자체를 간이 시그널 버스로 활용
	var signal_bus_demo = Node.new()
	signal_bus_demo.name = "EventBusDemo"
	signal_bus_demo.set_script(null)
	add_child(signal_bus_demo)

	# 실제 사용 패턴 설명
	print("결과 7-2: 사용 패턴:")
	print("  # 발신측 (예: 적 스크립트)")
	print("  EventBus.enemy_defeated.emit(self.name, 100)")
	print("  ")
	print("  # 수신측 (예: UI 스크립트)")
	print("  func _ready():")
	print("    EventBus.enemy_defeated.connect(_on_enemy_defeated)")

	# 시그널 버스 장단점
	print("결과 7-3: 시그널 버스 장점:")
	print("  - 노드 간 직접 참조 불필요 (느슨한 결합)")
	print("  - 어디서든 접근 가능 (AutoLoad)")
	print("  - 새로운 리스너 추가가 쉬움")
	print("결과 7-4: 시그널 버스 주의점:")
	print("  - 남용 시 코드 흐름 추적이 어려움")
	print("  - 메모리 누수 방지를 위해 해제(disconnect) 관리 필요")
	print("  - 부모-자식 관계에서는 일반 시그널이 더 적합")

	# 최종 이벤트 로그 출력
	print("\n--- 전체 이벤트 로그 ---")
	for i in range(event_log.size()):
		print("  [%d] %s" % [i, event_log[i]])

	print("=== 완료 ===\n")


# =============================================
# 시그널 콜백 함수들
# =============================================

# 연습 1: 내장 시그널 핸들러
func _on_child_entered_tree(node: Node):
	# 풀이: 자식 노드가 씬 트리에 추가되면 호출됩니다.
	var msg = "자식 추가됨: " + node.name
	event_log.append(msg)
	print("  [시그널] ", msg)


func _on_child_exiting_tree(node: Node):
	# 풀이: 자식 노드가 씬 트리에서 제거되기 직전에 호출됩니다.
	var msg = "자식 제거 예정: " + node.name
	event_log.append(msg)
	print("  [시그널] ", msg)


# 연습 2, 3: 커스텀 시그널 핸들러
func _on_health_changed(old_value: int, new_value: int):
	# 풀이: 체력 변경 시 호출됩니다. 변경 전후 값을 비교하여 적절한 처리를 합니다.
	var diff = new_value - old_value
	var direction_text = "회복" if diff > 0 else "피해"
	var msg = "체력 변경: %d -> %d (%s %d)" % [old_value, new_value, direction_text, abs(diff)]
	event_log.append(msg)
	print("  [시그널] ", msg)


func _on_player_died():
	# 풀이: 플레이어 사망 시 호출됩니다. 게임 오버 처리 등을 수행합니다.
	var msg = "플레이어 사망! Game Over"
	event_log.append(msg)
	print("  [시그널] ", msg)


func _on_item_collected(item_name: String, item_value: int):
	# 풀이: 아이템 수집 시 호출됩니다. 점수에 반영합니다.
	score += item_value
	var msg = "아이템 수집: %s (+%d점, 총: %d점)" % [item_name, item_value, score]
	event_log.append(msg)
	print("  [시그널] ", msg)


func _on_score_updated(new_score: int):
	# 풀이: 점수 업데이트 시 UI 갱신 등에 사용합니다.
	var msg = "점수 업데이트: %d점" % new_score
	event_log.append(msg)
	print("  [시그널] ", msg)


func _on_game_event(event_name: String, event_data: Dictionary):
	# 풀이: 범용 게임 이벤트 핸들러입니다.
	# 딕셔너리로 유연한 데이터를 전달받아 이벤트 종류별로 처리합니다.
	var msg = "게임 이벤트 [%s]: %s" % [event_name, str(event_data)]
	event_log.append(msg)
	print("  [시그널] ", msg)
