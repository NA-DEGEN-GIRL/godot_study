# 챕터 12: 프로젝트 패턴과 마무리
#
# 이 챕터에서는 다음을 학습합니다:
# - 상태 머신(State Machine) 패턴
# - 오브젝트 풀(Object Pool) 패턴
# - 컴포넌트 패턴으로 기능 분리
# - 이벤트 버스를 통한 느슨한 결합
# - 성능 측정과 디버깅 유틸리티
# - 내보내기(Export) 전 체크리스트

extends Node

# ============================================================
# 연습 1: 상태 머신 열거형 정의
# ============================================================
# 게임 캐릭터나 UI의 상태를 열거형으로 정의합니다.
# 상태 머신은 게임 로직을 명확하게 구조화하는 핵심 패턴입니다.

# TODO: 게임 전체 상태를 나타내는 열거형을 정의하세요
# enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER, LOADING, CUTSCENE }
# 여기를 수정하세요

# TODO: 플레이어 상태를 나타내는 열거형을 정의하세요
# enum PlayerState { IDLE, RUNNING, JUMPING, FALLING, ATTACKING, DASHING, HURT, DEAD }
# 여기를 수정하세요

var current_game_state = null   # 여기를 수정하세요 (GameState.MAIN_MENU)
var current_player_state = null # 여기를 수정하세요 (PlayerState.IDLE)
var previous_game_state = null
var previous_player_state = null

func get_state_name(state) -> String:
	# TODO: 주어진 상태 열거값에 대해 읽기 좋은 이름을 반환하세요
	# TODO: GameState와 PlayerState 모두 처리하세요
	# TODO: match 문을 사용하여 각 상태에 맞는 문자열을 반환하세요
	#       예: GameState.MAIN_MENU -> "메인 메뉴"
	#           GameState.PLAYING -> "플레이 중"
	#           GameState.PAUSED -> "일시 정지"
	#           GameState.GAME_OVER -> "게임 오버"
	#           PlayerState.IDLE -> "대기"
	#           PlayerState.RUNNING -> "달리기"
	#           PlayerState.JUMPING -> "점프"
	#           PlayerState.ATTACKING -> "공격"
	#           등...
	# TODO: 매칭되지 않으면 "알 수 없음"을 반환하세요
	var name = "알 수 없음"  # 여기를 수정하세요
	return name


# ============================================================
# 연습 2: 상태 전환 함수
# ============================================================
# 상태 전환 시 유효성 검사와 진입/퇴장 로직을 처리합니다.
# 잘못된 전환을 방지하고 상태 변경을 추적합니다.

# 허용되는 게임 상태 전환 테이블
# 형식: { 현재상태: [전환 가능한 상태들] }
var game_state_transitions: Dictionary = {}  # 여기를 수정하세요
# TODO: 아래 전환 규칙을 Dictionary로 정의하세요
# MAIN_MENU -> [PLAYING, LOADING]
# PLAYING -> [PAUSED, GAME_OVER, CUTSCENE, LOADING]
# PAUSED -> [PLAYING, MAIN_MENU]
# GAME_OVER -> [MAIN_MENU, LOADING]
# LOADING -> [PLAYING, MAIN_MENU]
# CUTSCENE -> [PLAYING]

func can_transition_game_state(from_state, to_state) -> bool:
	# TODO: game_state_transitions에서 from_state의 허용 목록을 가져오세요
	# TODO: to_state가 허용 목록에 있으면 true, 없으면 false를 반환하세요
	# TODO: from_state가 테이블에 없으면 false를 반환하세요
	var allowed = false  # 여기를 수정하세요
	return allowed

func transition_game_state(new_state) -> bool:
	# TODO: new_state가 current_game_state와 같으면 false를 반환하세요
	# TODO: can_transition_game_state로 전환 가능 여부를 확인하세요
	# TODO: 전환 불가능하면 경고 메시지를 출력하고 false를 반환하세요
	#       "잘못된 상태 전환: {현재} -> {새로운}"
	# TODO: previous_game_state에 current_game_state를 저장하세요
	# TODO: current_game_state를 new_state로 변경하세요
	# TODO: _on_game_state_entered(new_state)를 호출하세요
	# TODO: "게임 상태 전환: {이전} -> {새로운}"을 출력하세요
	# TODO: true를 반환하세요
	var success = false  # 여기를 수정하세요
	return success

func _on_game_state_entered(state) -> void:
	# TODO: 각 상태 진입 시 초기화 로직을 작성하세요 (match 문 사용)
	# TODO: PLAYING: "게임 시작!" 출력
	# TODO: PAUSED: "게임 일시 정지" 출력, get_tree().paused = true
	# TODO: GAME_OVER: "게임 오버!" 출력
	# TODO: MAIN_MENU: "메인 메뉴" 출력, get_tree().paused = false
	# TODO: 그 외: 상태 이름만 출력
	pass  # 여기를 수정하세요


# ============================================================
# 연습 3: 오브젝트 풀 클래스
# ============================================================
# 자주 생성/제거되는 오브젝트(총알, 파티클 등)를 미리 만들어두고
# 재사용하여 성능을 최적화합니다.

var pool: Array = []
var active_objects: Array = []
var pool_scene: PackedScene = null

func init_pool(scene: PackedScene, pool_size: int) -> void:
	# TODO: pool_scene을 scene으로 설정하세요
	# TODO: pool과 active_objects를 빈 배열로 초기화하세요
	# TODO: pool_size만큼 오브젝트를 미리 생성하세요:
	#       - scene.instantiate()로 인스턴스 생성
	#       - 생성 실패하면 continue
	#       - instance.set_meta("pool_active", false)로 비활성 표시
	#       - instance가 Node이면 instance.process_mode = Node.PROCESS_MODE_DISABLED
	#       - pool 배열에 추가
	# TODO: "오브젝트 풀 초기화: {pool_size}개"를 출력하세요
	pass  # 여기를 수정하세요

func get_from_pool() -> Node:
	# TODO: pool 배열에서 비활성 오브젝트를 찾아 반환하세요
	#       (힌트: obj.get_meta("pool_active") == false인 것)
	# TODO: 찾은 오브젝트의 "pool_active" 메타를 true로 설정하세요
	# TODO: process_mode를 Node.PROCESS_MODE_INHERIT로 복원하세요
	# TODO: active_objects에 추가하세요
	# TODO: 비활성 오브젝트가 없으면 null을 반환하세요 (풀 고갈)
	#       "오브젝트 풀 고갈!"을 출력하세요
	var obj = null  # 여기를 수정하세요
	return obj

func return_to_pool(obj: Node) -> void:
	# TODO: obj가 null이면 return하세요
	# TODO: obj.set_meta("pool_active", false)로 비활성 표시
	# TODO: obj.process_mode = Node.PROCESS_MODE_DISABLED로 비활성화
	# TODO: active_objects에서 obj를 제거하세요 (erase)
	# TODO: obj가 Node2D이면 position을 Vector2(-9999, -9999)로 이동 (화면 밖)
	pass  # 여기를 수정하세요

func get_pool_stats() -> Dictionary:
	# TODO: 풀 상태를 Dictionary로 반환하세요:
	#       - "total": pool 전체 크기
	#       - "active": 활성 오브젝트 수
	#       - "available": 사용 가능한 오브젝트 수 (total - active)
	var stats = {}  # 여기를 수정하세요
	return stats


# ============================================================
# 연습 4: 컴포넌트 패턴 (HealthComponent)
# ============================================================
# 체력 관리 기능을 독립적인 컴포넌트로 분리합니다.
# 적, 플레이어, 오브젝트 등 체력이 필요한 모든 노드에 붙여 사용합니다.

var health_components: Dictionary = {}  # entity_id -> 체력 데이터

func create_health_component(entity_id: String, max_hp: float, defense: float) -> Dictionary:
	# TODO: 체력 컴포넌트 데이터를 Dictionary로 생성하세요:
	#       - "entity_id": entity_id
	#       - "max_hp": max_hp
	#       - "current_hp": max_hp  (처음엔 가득)
	#       - "defense": defense
	#       - "is_alive": true
	#       - "is_invincible": false
	#       - "invincible_timer": 0.0
	# TODO: health_components[entity_id]에 저장하세요
	# TODO: 생성된 Dictionary를 반환하세요
	var component = {}  # 여기를 수정하세요
	return component

func take_damage(entity_id: String, raw_damage: float) -> Dictionary:
	# TODO: health_components에서 entity_id를 찾으세요
	# TODO: 존재하지 않거나 is_alive가 false이면 빈 Dictionary를 반환하세요
	# TODO: is_invincible가 true이면 {"damage_dealt": 0, "blocked": true}를 반환하세요
	# TODO: 실제 데미지를 계산하세요: max(raw_damage - defense, 1.0)
	#       (최소 1의 데미지는 항상 들어감)
	# TODO: current_hp에서 실제 데미지를 빼세요
	# TODO: current_hp가 0 이하이면:
	#       - current_hp를 0으로 설정
	#       - is_alive를 false로 설정
	# TODO: 결과를 Dictionary로 반환하세요:
	#       - "damage_dealt": 실제 데미지
	#       - "current_hp": 남은 체력
	#       - "is_alive": 생존 여부
	#       - "blocked": false
	var result = {}  # 여기를 수정하세요
	return result

func heal(entity_id: String, amount: float) -> Dictionary:
	# TODO: health_components에서 entity_id를 찾으세요
	# TODO: 존재하지 않거나 is_alive가 false이면 빈 Dictionary를 반환하세요
	# TODO: current_hp에 amount를 추가하되, max_hp를 초과하지 않게 하세요
	#       (힌트: min(current_hp + amount, max_hp))
	# TODO: 실제 회복량을 계산하세요: 새 HP - 이전 HP
	# TODO: 결과를 Dictionary로 반환하세요:
	#       - "healed": 실제 회복량
	#       - "current_hp": 현재 체력
	#       - "max_hp": 최대 체력
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 5: 이벤트 버스 시그널 선언
# ============================================================
# 전역 이벤트 버스를 통해 노드 간 느슨한 결합을 구현합니다.
# 실제로는 AutoLoad 싱글톤으로 등록하여 어디서든 접근합니다.

# TODO: 아래 시그널들을 선언하세요
# signal player_died(player_id: String)
# signal score_changed(new_score: int)
# signal item_collected(item_name: String, item_value: int)
# signal level_completed(level_id: int, time: float, stars: int)
# signal enemy_spawned(enemy_type: String, position: Vector2)
# signal game_event(event_name: String, event_data: Dictionary)
# 여기를 수정하세요

var event_log: Array = []

func emit_game_event(event_name: String, event_data: Dictionary) -> void:
	# TODO: event_log에 이벤트를 기록하세요:
	#       {"name": event_name, "data": event_data, "time": Time.get_ticks_msec()}
	# TODO: game_event 시그널을 emit하세요 (시그널을 정의한 경우)
	#       (힌트: game_event.emit(event_name, event_data))
	# TODO: "이벤트 발생: {event_name}"을 출력하세요
	pass  # 여기를 수정하세요

func get_event_log(filter_name: String = "") -> Array:
	# TODO: filter_name이 비어있으면 전체 event_log를 반환하세요
	# TODO: filter_name이 지정되면 해당 이름의 이벤트만 필터링하여 반환하세요
	#       (힌트: event_log.filter(func(e): return e["name"] == filter_name))
	var filtered = []  # 여기를 수정하세요
	return filtered

func clear_event_log() -> void:
	# TODO: event_log를 비우세요
	pass  # 여기를 수정하세요


# ============================================================
# 연습 6: 성능 측정 유틸리티
# ============================================================
# 코드의 실행 시간을 측정하여 병목 구간을 찾는 유틸리티입니다.
# 최적화 전후 비교에 활용됩니다.

var perf_timers: Dictionary = {}
var perf_results: Dictionary = {}

func perf_start(label: String) -> void:
	# TODO: Time.get_ticks_usec()로 현재 시간(마이크로초)을 기록하세요
	# TODO: perf_timers[label]에 저장하세요
	pass  # 여기를 수정하세요

func perf_end(label: String) -> float:
	# TODO: perf_timers에 label이 없으면 -1.0을 반환하세요
	# TODO: 경과 시간을 계산하세요: (현재 시간 - 시작 시간) / 1000.0 (밀리초 단위)
	# TODO: perf_results[label]에 저장하세요
	# TODO: perf_timers에서 label을 제거하세요 (erase)
	# TODO: 경과 시간(ms)을 반환하세요
	var elapsed_ms = -1.0  # 여기를 수정하세요
	return elapsed_ms

func perf_measure(label: String, callable: Callable) -> float:
	# TODO: perf_start(label)을 호출하세요
	# TODO: callable.call()로 측정 대상 함수를 실행하세요
	# TODO: perf_end(label)로 시간을 측정하고 반환하세요
	var elapsed_ms = -1.0  # 여기를 수정하세요
	return elapsed_ms

func get_perf_report() -> String:
	# TODO: perf_results의 모든 결과를 문자열로 정리하세요
	# TODO: 형식: "[성능] {label}: {시간}ms" (각 항목을 줄바꿈으로 구분)
	# TODO: 정리된 문자열을 반환하세요
	var report = ""  # 여기를 수정하세요
	return report


# ============================================================
# 연습 7: 내보내기 체크리스트 함수
# ============================================================
# 게임을 내보내기(Export) 전에 확인해야 할 항목을 점검합니다.
# 디버그 코드 제거, 리소스 확인 등 실수를 방지합니다.

func run_export_checklist() -> Dictionary:
	# TODO: 체크리스트 결과를 Dictionary로 구성하세요
	# TODO: 각 항목은 "항목명": {"passed": bool, "message": String} 형태
	# TODO: 다음 항목들을 체크하세요:
	#
	#   1. "debug_mode":
	#      - OS.is_debug_build()로 확인
	#      - 디버그 빌드이면 passed = false, "디버그 모드입니다. 릴리즈로 빌드하세요."
	#      - 릴리즈 빌드이면 passed = true, "릴리즈 빌드 확인"
	#
	#   2. "audio_buses":
	#      - AudioServer.bus_count가 1 이상인지 확인
	#      - passed = (bus_count >= 1), 메시지에 버스 수 포함
	#
	#   3. "viewport_size":
	#      - 뷰포트 크기가 0이 아닌지 확인
	#      - get_viewport()가 있으면 get_viewport().size로 확인
	#      - passed = (width > 0 and height > 0)
	#
	#   4. "memory_usage":
	#      - OS.get_static_memory_usage()로 메모리 사용량을 확인
	#      - MB 단위로 변환 (/ 1048576.0)
	#      - passed = true (정보 제공용), 메시지에 메모리 사용량 포함
	#
	#   5. "scene_tree":
	#      - get_tree()가 유효한지 확인
	#      - passed = (get_tree() != null)
	#
	# TODO: 전체 통과 여부를 "all_passed" 키에 추가하세요
	#       (모든 항목의 passed가 true여야 true)
	# TODO: 결과 Dictionary를 반환하세요
	var checklist = {}  # 여기를 수정하세요
	return checklist

func print_checklist_report(checklist: Dictionary) -> void:
	# TODO: 체크리스트 결과를 보기 좋게 출력하세요
	# TODO: 형식:
	#       "=== 내보내기 체크리스트 ==="
	#       "[통과] 항목명: 메시지"  또는  "[실패] 항목명: 메시지"
	#       "========================="
	#       "전체 결과: 통과" 또는 "전체 결과: 실패"
	pass  # 여기를 수정하세요


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 12: 프로젝트 패턴과 마무리 ===")
	print("")

	# 테스트 1: 상태 머신 열거형
	print("결과 1 (현재 게임 상태):", current_game_state)
	print("결과 1 (현재 플레이어 상태):", current_player_state)
	if current_game_state != null:
		print("결과 1 (게임 상태 이름):", get_state_name(current_game_state))
	if current_player_state != null:
		print("결과 1 (플레이어 상태 이름):", get_state_name(current_player_state))
	print("")

	# 테스트 2: 상태 전환
	if current_game_state != null:
		print("결과 2 (MAIN_MENU->PLAYING 가능):", can_transition_game_state(current_game_state, 1))  # PLAYING
		var t1 = transition_game_state(1)  # PLAYING
		print("결과 2 (PLAYING 전환 성공):", t1)
		var t2 = transition_game_state(2)  # PAUSED
		print("결과 2 (PAUSED 전환 성공):", t2)
		var t3 = transition_game_state(3)  # GAME_OVER (PAUSED에서는 불가)
		print("결과 2 (GAME_OVER 전환 - 불가):", t3)
		transition_game_state(1)  # PLAYING으로 복귀
		get_tree().paused = false  # 테스트를 위해 일시정지 해제
	else:
		print("결과 2: null - GameState 열거형을 정의하세요")
	print("")

	# 테스트 3: 오브젝트 풀
	print("결과 3 (풀 함수 정의 확인):")
	print("  init_pool 존재:", has_method("init_pool"))
	print("  get_from_pool 존재:", has_method("get_from_pool"))
	print("  return_to_pool 존재:", has_method("return_to_pool"))
	var stats = get_pool_stats()
	print("결과 3 (풀 통계):", stats)
	print("")

	# 테스트 4: HealthComponent
	var hero_hp = create_health_component("hero", 100.0, 5.0)
	print("결과 4 (영웅 체력 생성):", hero_hp)
	var dmg_result = take_damage("hero", 30.0)
	print("결과 4 (30 데미지):", dmg_result)
	var heal_result = heal("hero", 20.0)
	print("결과 4 (20 회복):", heal_result)
	var kill_result = take_damage("hero", 999.0)
	print("결과 4 (치명적 데미지):", kill_result)
	var dead_heal = heal("hero", 50.0)
	print("결과 4 (사망 후 회복 시도):", dead_heal)
	print("")

	# 테스트 5: 이벤트 버스
	emit_game_event("player_jump", {"height": 5.0})
	emit_game_event("enemy_defeated", {"type": "goblin", "xp": 50})
	emit_game_event("player_jump", {"height": 3.0})
	print("결과 5 (전체 이벤트 수):", get_event_log().size())
	print("결과 5 (점프 이벤트 수):", get_event_log("player_jump").size())
	clear_event_log()
	print("결과 5 (초기화 후 이벤트 수):", get_event_log().size())
	print("")

	# 테스트 6: 성능 측정
	perf_start("test_loop")
	var sum = 0
	for i in range(10000):
		sum += i
	var loop_time = perf_end("test_loop")
	print("결과 6 (루프 10000회 시간):", loop_time, "ms")

	var measure_time = perf_measure("lambda_test", func():
		var s = 0
		for j in range(5000):
			s += j
	)
	print("결과 6 (람다 측정):", measure_time, "ms")
	print("결과 6 (성능 리포트):")
	print(get_perf_report())
	print("")

	# 테스트 7: 내보내기 체크리스트
	var checklist = run_export_checklist()
	if checklist.size() > 0:
		print("결과 7 (체크리스트 항목 수):", checklist.size())
		print_checklist_report(checklist)
	else:
		print("결과 7: 빈 체크리스트 - run_export_checklist를 구현하세요")
	print("")

	print("=== 챕터 12 완료 ===")
