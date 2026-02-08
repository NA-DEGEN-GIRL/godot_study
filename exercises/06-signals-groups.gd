# 챕터 6: 시그널과 그룹
#
# 이 챕터에서는 다음을 학습합니다:
# - 시그널 연결 (connect)
# - 커스텀 시그널 선언 (signal)
# - 시그널 발신 (emit)
# - 람다를 이용한 시그널 연결
# - 노드 그룹 추가/조회
# - call_group으로 일괄 함수 호출
# - 시그널 버스 패턴 (전역 이벤트 시스템)

extends Node


# =============================================
# 연습 2에서 사용할 커스텀 시그널 선언
# =============================================
# TODO: 아래 시그널들을 선언하세요
# - health_changed: 체력 변경 시그널 (new_health: int, max_health: int)
# - item_collected: 아이템 수집 시그널 (item_name: String, item_value: int)
# - game_over: 게임 오버 시그널 (매개변수 없음)
#
# 예: signal health_changed(new_health: int, max_health: int)

# 여기에 시그널을 선언하세요


# =============================================
# 상태 변수 (테스트용)
# =============================================
var health: int = 100
var max_health: int = 100
var inventory: Array = []
var event_log: Array = []
var is_game_over: bool = false


func _ready():
	# =============================================
	# 연습 1: 시그널 연결 (connect)
	# =============================================
	# TODO: connect_signals() 함수를 완성하세요
	# Godot 빌트인 시그널을 연결하는 방법을 딕셔너리로 반환합니다
	# 또한 이 노드의 tree_entered 시그널을 _on_tree_entered에 연결하세요
	var signal_examples = connect_signals()

	# =============================================
	# 연습 2: 커스텀 시그널 확인
	# =============================================
	# TODO: 이 스크립트 상단에 커스텀 시그널 3개를 선언하세요
	# 선언 후 has_signal()로 확인합니다
	var has_health_signal = has_signal("health_changed")
	var has_item_signal = has_signal("item_collected")
	var has_gameover_signal = has_signal("game_over")
	var answer2 = has_health_signal and has_item_signal and has_gameover_signal

	# =============================================
	# 연습 3: 시그널 emit 호출
	# =============================================
	# TODO: 커스텀 시그널을 연결하고 emit하세요
	# 1) health_changed 시그널을 _on_health_changed 함수에 연결
	# 2) item_collected 시그널을 _on_item_collected 함수에 연결
	# 3) game_over 시그널을 _on_game_over 함수에 연결
	# 4) 시그널을 emit하여 테스트
	event_log = []
	setup_and_emit_signals()
	var answer3_log = event_log.duplicate()

	# =============================================
	# 연습 4: 람다 시그널 연결
	# =============================================
	# TODO: connect_lambda_signals() 함수를 완성하세요
	# 람다(익명 함수)를 사용하여 시그널을 연결합니다
	# 시그널을 직접 연결하는 대신 예제 코드 문자열을 반환합니다
	# (실제 시그널 중복 연결 방지를 위해)
	var lambda_examples = connect_lambda_signals()

	# =============================================
	# 연습 5: 그룹 추가/조회
	# =============================================
	# TODO: setup_node_groups() 함수를 완성하세요
	# 자식 노드를 생성하고 그룹에 추가한 뒤 그룹 정보를 반환합니다
	var group_info = setup_node_groups()

	# =============================================
	# 연습 6: call_group 일괄 호출
	# =============================================
	# TODO: demonstrate_call_group() 함수를 완성하세요
	# call_group의 사용법과 예제를 딕셔너리로 반환합니다
	var call_group_info = demonstrate_call_group()

	# =============================================
	# 연습 7: 시그널 버스 이벤트
	# =============================================
	# TODO: create_signal_bus_example() 함수를 완성하세요
	# 전역 시그널 버스 패턴(Autoload)을 설명하는 코드 예제를 반환합니다
	var signal_bus_info = create_signal_bus_example()

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 6: 시그널과 그룹 ===")

	print("--- 연습 1: 시그널 연결 ---")
	print("결과 1 (시그널 연결 예제): ", signal_examples)

	print("--- 연습 2: 커스텀 시그널 ---")
	print("결과 2-1 (health_changed 존재): ", has_health_signal, " (기대값: true)")
	print("결과 2-2 (item_collected 존재): ", has_item_signal, " (기대값: true)")
	print("결과 2-3 (game_over 존재): ", has_gameover_signal, " (기대값: true)")
	print("결과 2 (모든 시그널 선언됨): ", answer2)

	print("--- 연습 3: 시그널 emit ---")
	print("결과 3 (이벤트 로그): ", answer3_log)

	print("--- 연습 4: 람다 시그널 ---")
	print("결과 4 (람다 연결 예제): ", lambda_examples)

	print("--- 연습 5: 그룹 추가/조회 ---")
	print("결과 5 (그룹 정보): ", group_info)

	print("--- 연습 6: call_group ---")
	print("결과 6 (call_group 예제): ", call_group_info)

	print("--- 연습 7: 시그널 버스 ---")
	print("결과 7 (시그널 버스 패턴): ", signal_bus_info)
	print("=== 완료 ===\n")


# =============================================
# 연습 1: 시그널 연결 함수
# =============================================
# TODO: 시그널 연결 방법을 딕셔너리로 반환하세요
# 실제로 tree_entered 시그널을 _on_tree_entered 메서드에 연결하고,
# 다양한 연결 방법의 코드 예제를 문자열로 반환합니다
#
# 반환 형식:
# {
#   "method_connect": "button.pressed.connect(_on_button_pressed)",
#   "with_args": "button.pressed.connect(_on_button_pressed.bind(extra_arg))",
#   "one_shot": "signal.connect(callable, CONNECT_ONE_SHOT)",
#   "deferred": "signal.connect(callable, CONNECT_DEFERRED)"
# }
#
# 추가로: self.tree_entered.connect(_on_tree_entered) 을 실제로 호출하세요
# (이미 연결되어 있을 수 있으므로 is_connected로 확인 후 연결)
func connect_signals() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 시그널 핸들러 (연습 1, 3에서 사용)
# =============================================
func _on_tree_entered():
	event_log.append("tree_entered 시그널 수신")


# =============================================
# 연습 3: 시그널 연결 및 emit 함수
# =============================================
# TODO: 커스텀 시그널을 핸들러에 연결하고 emit하세요
# 1) health_changed.connect(_on_health_changed) -- 이미 연결 안 됐을 때만
# 2) item_collected.connect(_on_item_collected)
# 3) game_over.connect(_on_game_over)
# 4) health_changed.emit(80, 100) 호출
# 5) item_collected.emit("검", 500) 호출
# 6) game_over.emit() 호출
#
# 힌트: 중복 연결을 방지하려면 is_connected()로 확인하세요
# 예: if not health_changed.is_connected(_on_health_changed):
#         health_changed.connect(_on_health_changed)
func setup_and_emit_signals():
	pass  # 여기를 수정하세요


# =============================================
# 커스텀 시그널 핸들러들 (연습 3에서 사용)
# =============================================
# TODO: 각 핸들러가 event_log에 적절한 메시지를 추가하도록 완성하세요

# health_changed 시그널 핸들러
# event_log에 "체력 변경: {new_health}/{max_hp}" 형식으로 추가
func _on_health_changed(new_health: int, max_hp: int):
	pass  # 여기를 수정하세요

# item_collected 시그널 핸들러
# event_log에 "아이템 수집: {item_name} ({item_value})" 형식으로 추가
func _on_item_collected(item_name: String, item_value: int):
	pass  # 여기를 수정하세요

# game_over 시그널 핸들러
# event_log에 "게임 오버!" 추가, is_game_over를 true로 설정
func _on_game_over():
	pass  # 여기를 수정하세요


# =============================================
# 연습 4: 람다 시그널 연결 함수
# =============================================
# TODO: 람다(익명 함수)를 사용한 시그널 연결 예제를 반환하세요
# 반환 형식:
# {
#   "basic_lambda": "signal.connect(func(): print(\"시그널 수신!\"))",
#   "lambda_with_args": "signal.connect(func(value): print(\"값: \", value))",
#   "lambda_with_bind": "signal.connect(func(): handle_event.call(\"extra\"))",
#   "disconnect_note": "람다로 연결하면 disconnect가 어려우므로 주의가 필요합니다"
# }
func connect_lambda_signals() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 5: 그룹 추가/조회 함수
# =============================================
# TODO: 자식 노드를 생성하고 그룹에 할당한 뒤 정보를 반환하세요
# 1) "Enemy1", "Enemy2" 이름의 Node를 생성하여 자식으로 추가
# 2) 두 노드를 "enemies" 그룹에 추가
# 3) "Player1" 이름의 Node를 생성하여 "players" 그룹에 추가
# 4) 각 그룹의 멤버 수와 멤버 이름을 딕셔너리로 반환
#
# 반환 형식:
# {
#   "enemies_count": 2,
#   "enemies_names": ["Enemy1", "Enemy2"],
#   "players_count": 1,
#   "players_names": ["Player1"],
#   "enemy1_groups": ["enemies"]  -- Enemy1이 속한 그룹 목록
# }
#
# 힌트:
#   node.add_to_group("enemies")
#   get_tree().get_nodes_in_group("enemies")
func setup_node_groups() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 6: call_group 일괄 호출 함수
# =============================================
# TODO: call_group 사용법을 설명하는 딕셔너리를 반환하세요
# call_group은 특정 그룹의 모든 노드에서 같은 함수를 호출합니다
#
# 반환 형식:
# {
#   "basic_usage": "get_tree().call_group(\"enemies\", \"take_damage\", 10)",
#   "notify_usage": "get_tree().notify_group(\"enemies\", NOTIFICATION_PAUSED)",
#   "set_usage": "get_tree().set_group(\"enemies\", \"visible\", false)",
#   "call_group_flags": "get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, \"enemies\", \"die\")",
#   "description": "call_group은 그룹 내 모든 노드의 지정된 메서드를 일괄 호출합니다"
# }
func demonstrate_call_group() -> Dictionary:
	return {}  # 여기를 수정하세요


# =============================================
# 연습 7: 시그널 버스 패턴 함수
# =============================================
# TODO: 전역 시그널 버스 패턴의 구현 예제를 반환하세요
# 시그널 버스는 Autoload(자동 로드) 스크립트에 시그널을 모아두고,
# 어디서나 접근할 수 있게 하는 디자인 패턴입니다
#
# 반환 형식:
# {
#   "bus_script": 시그널 버스 스크립트 코드 문자열,
#   "emit_example": 시그널을 발신하는 코드 문자열,
#   "connect_example": 시그널을 수신하는 코드 문자열,
#   "autoload_setup": "프로젝트 설정 > Autoload에서 EventBus.gd를 등록합니다",
#   "advantages": 장점을 설명하는 배열
# }
#
# bus_script 예:
# """
# # EventBus.gd (Autoload)
# extends Node
# signal player_died
# signal score_changed(new_score: int)
# signal level_completed(level_id: int)
# """
func create_signal_bus_example() -> Dictionary:
	return {}  # 여기를 수정하세요
