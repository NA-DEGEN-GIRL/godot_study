# Chapter 11 - Resources & Data Management
# 04-save-system.gd - 완성형 세이브 시스템
#
# 이 파일에서 배울 내용:
# - "persist" 그룹을 활용한 저장 대상 관리
# - 노드 상태 직렬화(serialize) / 역직렬화(deserialize)
# - JSON + 암호화 세이브 파일
# - 다중 슬롯 세이브 시스템
# - 자동 저장(Auto-save) 구현

extends Node

# =============================================================================
# 세이브 시스템 설정
# =============================================================================

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".sav"
const MAX_SAVE_SLOTS = 5
const AUTO_SAVE_SLOT = 0
const ENCRYPTION_KEY = "my_game_secret_key_2024"  # 실제 프로젝트에서는 더 안전하게
const SAVE_VERSION = 2  # 세이브 포맷 버전 (마이그레이션용)

# 세이브 데이터 구조
var _current_save: Dictionary = {}

# 시그널
signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)


func _ready():
	print("=== Chapter 11-4: 완성형 세이브 시스템 ===\n")

	# 세이브 디렉토리 생성
	_ensure_save_directory()

	# -----------------------------------------------------------------
	# 1) 세이브 시스템 설계 원리
	# -----------------------------------------------------------------
	print("--- 1. 세이브 시스템 설계 ---")

	print("  세이브 가능한 노드의 조건:")
	print("    1. 'persist' 그룹에 추가됨")
	print("    2. save_data() 메서드 구현 -> Dictionary 반환")
	print("    3. load_data(data) 메서드 구현 -> 상태 복원")
	print("    4. scene_file_path가 설정됨 (또는 별도 저장)")
	print()

	print("  세이브 파일 구조:")
	print("    {")
	print("      \"meta\": { version, timestamp, play_time },")
	print("      \"game_state\": { score, level, ... },")
	print("      \"nodes\": [ { 노드별 데이터 }, ... ],")
	print("      \"checksum\": \"무결성 해시\"")
	print("    }")
	print()

	# -----------------------------------------------------------------
	# 2) persist 그룹 패턴
	# -----------------------------------------------------------------
	print("--- 2. persist 그룹 패턴 ---")

	print("  # 저장할 노드에 추가하는 코드:")
	print("  func _ready():")
	print("      add_to_group(\"persist\")")
	print()
	print("  # 또는 에디터에서 노드 > 그룹 탭에서 'persist' 추가")
	print()

	print("  # 플레이어 예시:")
	print("  # player.gd")
	print("  extends CharacterBody2D")
	print()
	print("  func _ready():")
	print("      add_to_group(\"persist\")")
	print()
	print("  func save_data() -> Dictionary:")
	print("      return {")
	print("          \"scene_path\": scene_file_path,")
	print("          \"position_x\": position.x,")
	print("          \"position_y\": position.y,")
	print("          \"hp\": hp,")
	print("          \"inventory\": inventory.duplicate(),")
	print("      }")
	print()
	print("  func load_data(data: Dictionary) -> void:")
	print("      position.x = data[\"position_x\"]")
	print("      position.y = data[\"position_y\"]")
	print("      hp = data[\"hp\"]")
	print("      inventory = data[\"inventory\"]")
	print()

	# -----------------------------------------------------------------
	# 3) persist 노드 시뮬레이션
	# -----------------------------------------------------------------
	print("--- 3. 저장 가능 노드 시뮬레이션 ---")

	# 테스트용 노드 생성
	var player = PersistNode.new("Player", "res://scenes/player.tscn")
	player.custom_data = {
		"position_x": 150.5,
		"position_y": 320.0,
		"hp": 85,
		"max_hp": 100,
		"mp": 30,
		"inventory": ["sword", "shield", "potion", "potion"],
		"equipped": {"weapon": "sword", "armor": "shield"},
	}
	add_child(player)

	var enemy1 = PersistNode.new("Goblin_01", "res://scenes/goblin.tscn")
	enemy1.custom_data = {
		"position_x": 500.0,
		"position_y": 300.0,
		"hp": 30,
		"patrol_path": [Vector2(400, 300), Vector2(600, 300)],
		"is_alerted": false,
	}
	add_child(enemy1)

	var chest = PersistNode.new("Chest_03", "res://scenes/chest.tscn")
	chest.custom_data = {
		"position_x": 800.0,
		"position_y": 250.0,
		"opened": true,
		"contents": [],
	}
	add_child(chest)

	print("  생성된 persist 노드:")
	for node in get_tree().get_nodes_in_group("persist"):
		if node is PersistNode:
			print("    - %s (%s)" % [node.node_id, node.scene_path])
	print()

	# -----------------------------------------------------------------
	# 4) 직렬화 (게임 상태 -> Dictionary)
	# -----------------------------------------------------------------
	print("--- 4. 게임 상태 직렬화 ---")

	var game_state = {
		"score": 12500,
		"coins": 47,
		"current_level": "res://levels/forest.tscn",
		"difficulty": "normal",
		"play_time_seconds": 1847.5,
		"quests_completed": ["intro", "find_sword", "rescue_cat"],
		"flags": {"bridge_repaired": true, "boss_defeated": false},
	}

	var save_data = _serialize_save(game_state)
	print("  직렬화된 세이브 데이터:")
	print("    meta.version: ", save_data["meta"]["version"])
	print("    meta.timestamp: ", save_data["meta"]["timestamp"])
	print("    game_state.score: ", save_data["game_state"]["score"])
	print("    game_state.level: ", save_data["game_state"]["current_level"])
	print("    nodes 수: ", save_data["nodes"].size())
	for nd in save_data["nodes"]:
		print("      - %s: %s" % [nd["node_id"], nd.keys()])
	print("    checksum: ", save_data["checksum"].substr(0, 16), "...")
	print()

	# -----------------------------------------------------------------
	# 5) 세이브 파일 쓰기
	# -----------------------------------------------------------------
	print("--- 5. 세이브 파일 저장 ---")

	# 슬롯 1에 저장
	var save_result = save_game(1, game_state)
	print("  슬롯 1 저장: ", "성공" if save_result else "실패")

	# 슬롯 2에 저장 (암호화)
	save_result = save_game(2, game_state, true)
	print("  슬롯 2 저장 (암호화): ", "성공" if save_result else "실패")

	# 자동 저장
	save_result = save_game(AUTO_SAVE_SLOT, game_state)
	print("  자동 저장 (슬롯 0): ", "성공" if save_result else "실패")
	print()

	# -----------------------------------------------------------------
	# 6) 세이브 파일 목록과 메타 정보
	# -----------------------------------------------------------------
	print("--- 6. 세이브 슬롯 목록 ---")

	var slots = get_save_slots_info()
	for slot in slots:
		if slot["exists"]:
			print("  슬롯 %d: %s | 플레이 시간: %s | 레벨: %s" % [
				slot["slot"],
				slot["timestamp"],
				_format_play_time(slot.get("play_time", 0)),
				slot.get("level", "???")
			])
		else:
			print("  슬롯 %d: (비어있음)" % slot["slot"])
	print()

	# -----------------------------------------------------------------
	# 7) 세이브 파일 불러오기
	# -----------------------------------------------------------------
	print("--- 7. 세이브 파일 불러오기 ---")

	# 슬롯 1 불러오기
	var loaded = load_game(1)
	if loaded:
		print("  슬롯 1 불러오기 성공:")
		print("    버전: ", loaded["meta"]["version"])
		print("    점수: ", loaded["game_state"]["score"])
		print("    코인: ", loaded["game_state"]["coins"])
		print("    노드 수: ", loaded["nodes"].size())

		# 노드 데이터 복원
		print("    노드 복원:")
		for node_data in loaded["nodes"]:
			print("      %s -> 위치(%s, %s)" % [
				node_data["node_id"],
				node_data["data"].get("position_x", "?"),
				node_data["data"].get("position_y", "?")
			])

		# 무결성 확인
		var valid = _verify_checksum(loaded)
		print("    무결성 확인: ", "통과" if valid else "실패!")
	else:
		print("  슬롯 1 불러오기 실패")
	print()

	# 암호화된 슬롯 2 불러오기
	var loaded_encrypted = load_game(2, true)
	if loaded_encrypted:
		print("  슬롯 2 (암호화) 불러오기 성공:")
		print("    점수: ", loaded_encrypted["game_state"]["score"])
	print()

	# -----------------------------------------------------------------
	# 8) 역직렬화 (세이브 데이터 -> 게임 복원)
	# -----------------------------------------------------------------
	print("--- 8. 게임 상태 복원 ---")

	print("  전체 복원 프로세스:")
	print("    1. 세이브 파일 읽기")
	print("    2. 무결성 검증")
	print("    3. 버전 마이그레이션 (필요 시)")
	print("    4. 레벨 씬 로드")
	print("    5. 기존 persist 노드 제거")
	print("    6. 저장된 노드 인스턴스화 및 데이터 복원")
	print("    7. 게임 상태 복원")
	print()

	print("  복원 코드 패턴:")
	print("    func apply_save_data(save: Dictionary):")
	print("        var game = save[\"game_state\"]")
	print("        ")
	print("        # 게임 상태 복원")
	print("        GameManager.score = game[\"score\"]")
	print("        GameManager.coins = game[\"coins\"]")
	print("        ")
	print("        # 레벨 전환")
	print("        get_tree().change_scene_to_file(game[\"current_level\"])")
	print("        await get_tree().process_frame")
	print("        ")
	print("        # 기존 persist 노드 제거")
	print("        for node in get_tree().get_nodes_in_group(\"persist\"):")
	print("            node.queue_free()")
	print("        await get_tree().process_frame")
	print("        ")
	print("        # 노드 복원")
	print("        for node_data in save[\"nodes\"]:")
	print("            var scene = load(node_data[\"scene_path\"])")
	print("            var instance = scene.instantiate()")
	print("            instance.load_data(node_data[\"data\"])")
	print("            get_tree().current_scene.add_child(instance)")
	print()

	# -----------------------------------------------------------------
	# 9) 세이브 데이터 마이그레이션
	# -----------------------------------------------------------------
	print("--- 9. 세이브 데이터 마이그레이션 ---")

	print("  게임 업데이트 시 세이브 포맷이 변경될 수 있음")
	print("  버전 번호로 마이그레이션 관리:")
	print()

	# 마이그레이션 예시
	var old_save_v1 = {
		"meta": {"version": 1},
		"game_state": {
			"score": 5000,
			"player_hp": 80,  # v1에서는 game_state에 HP 저장
		},
		"nodes": []
	}

	print("  v1 세이브 데이터:")
	print("    ", old_save_v1["game_state"])

	var migrated = _migrate_save_data(old_save_v1)
	print("  v2로 마이그레이션 후:")
	print("    ", migrated["game_state"])
	print("    버전: ", migrated["meta"]["version"])
	print()

	print("  마이그레이션 코드 패턴:")
	print("    func _migrate_save_data(data):")
	print("        var version = data[\"meta\"][\"version\"]")
	print("        if version < 2:")
	print("            # v1 -> v2: player_hp를 별도 구조로 이동")
	print("            data[\"game_state\"][\"player\"] = {")
	print("                \"hp\": data[\"game_state\"].get(\"player_hp\", 100)")
	print("            }")
	print("            data[\"game_state\"].erase(\"player_hp\")")
	print("            data[\"meta\"][\"version\"] = 2")
	print("        # if version < 3: ...")
	print("        return data")
	print()

	# -----------------------------------------------------------------
	# 10) 자동 저장 시스템
	# -----------------------------------------------------------------
	print("--- 10. 자동 저장 시스템 ---")

	print("  Timer 기반 자동 저장:")
	print("    var _auto_save_timer: Timer")
	print("    var auto_save_interval: float = 300.0  # 5분")
	print()
	print("    func _ready():")
	print("        _auto_save_timer = Timer.new()")
	print("        _auto_save_timer.wait_time = auto_save_interval")
	print("        _auto_save_timer.timeout.connect(_on_auto_save)")
	print("        add_child(_auto_save_timer)")
	print("        _auto_save_timer.start()")
	print()
	print("    func _on_auto_save():")
	print("        save_game(AUTO_SAVE_SLOT, _collect_game_state())")
	print("        print(\"자동 저장 완료\")")
	print()
	print("  이벤트 기반 자동 저장:")
	print("    - 체크포인트 통과 시")
	print("    - 레벨 전환 시")
	print("    - 중요 아이템 획득 시")
	print("    - 앱이 백그라운드로 전환 시 (모바일)")
	print()

	# -----------------------------------------------------------------
	# 11) 세이브 파일 관리
	# -----------------------------------------------------------------
	print("--- 11. 세이브 파일 관리 ---")

	# 세이브 삭제
	print("  세이브 삭제:")
	for slot in [0, 1, 2]:
		var deleted = delete_save(slot)
		print("    슬롯 %d 삭제: %s" % [slot, "성공" if deleted else "없음"])
	print()

	# 확인
	var remaining_slots = get_save_slots_info()
	var any_exists = false
	for s in remaining_slots:
		if s["exists"]:
			any_exists = true
			break
	print("  남은 세이브: %s" % ("있음" if any_exists else "없음"))
	print()

	# 테스트 노드 정리
	player.queue_free()
	enemy1.queue_free()
	chest.queue_free()

	# -----------------------------------------------------------------
	# 12) 전체 API 요약
	# -----------------------------------------------------------------
	print("--- 12. SaveSystem API 요약 ---")

	print("  저장/불러오기:")
	print("    save_game(slot, game_state, encrypted) -> bool")
	print("    load_game(slot, encrypted) -> Dictionary")
	print("    delete_save(slot) -> bool")
	print()
	print("  조회:")
	print("    get_save_slots_info() -> Array[Dictionary]")
	print("    has_save(slot) -> bool")
	print()
	print("  노드 규약:")
	print("    add_to_group(\"persist\")  # _ready()에서 호출")
	print("    save_data() -> Dictionary  # 상태 반환")
	print("    load_data(data: Dictionary) # 상태 복원")
	print()

	print("=== 04-save-system.gd 완료 ===")


# =============================================================================
# 세이브 시스템 핵심 함수들
# =============================================================================

func _ensure_save_directory():
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_slot_%d%s" % [slot, SAVE_EXTENSION]


func save_game(slot: int, game_state: Dictionary, encrypted: bool = false) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("유효하지 않은 슬롯: %d" % slot)
		return false

	var save_data = _serialize_save(game_state)
	var json_string = JSON.stringify(save_data, "\t")
	var path = _get_save_path(slot)

	var file: FileAccess
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, ENCRYPTION_KEY)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)

	if not file:
		push_error("세이브 파일 열기 실패: %s" % path)
		save_completed.emit(slot, false)
		return false

	file.store_string(json_string)
	file.close()

	save_completed.emit(slot, true)
	return true


func load_game(slot: int, encrypted: bool = false) -> Dictionary:
	var path = _get_save_path(slot)

	if not FileAccess.file_exists(path):
		push_warning("세이브 파일 없음: %s" % path)
		load_completed.emit(slot, false)
		return {}

	var file: FileAccess
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, ENCRYPTION_KEY)
	else:
		file = FileAccess.open(path, FileAccess.READ)

	if not file:
		push_error("세이브 파일 읽기 실패: %s" % path)
		load_completed.emit(slot, false)
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("JSON 파싱 실패: %s" % json.get_error_message())
		load_completed.emit(slot, false)
		return {}

	var data = json.data as Dictionary

	# 버전 마이그레이션
	data = _migrate_save_data(data)

	load_completed.emit(slot, true)
	return data


func delete_save(slot: int) -> bool:
	var path = _get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		return true
	return false


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))


func get_save_slots_info() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for i in range(MAX_SAVE_SLOTS):
		var info: Dictionary = {"slot": i, "exists": false}
		var path = _get_save_path(i)

		if FileAccess.file_exists(path):
			info["exists"] = true

			# 메타 정보만 빠르게 읽기
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var text = file.get_as_text()
				file.close()
				var parsed = JSON.parse_string(text)
				if parsed and parsed.has("meta"):
					info["timestamp"] = parsed["meta"].get("timestamp", "")
					info["play_time"] = parsed["game_state"].get("play_time_seconds", 0)
					info["level"] = parsed["game_state"].get("current_level", "")
					info["score"] = parsed["game_state"].get("score", 0)

		slots.append(info)
	return slots


# =============================================================================
# 직렬화 / 역직렬화
# =============================================================================

func _serialize_save(game_state: Dictionary) -> Dictionary:
	# persist 그룹의 노드 데이터 수집
	var nodes_data: Array[Dictionary] = []
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("save_data"):
			var nd = node.save_data()
			nodes_data.append(nd)
		elif node is PersistNode:
			nodes_data.append(node.save_data())

	var save = {
		"meta": {
			"version": SAVE_VERSION,
			"timestamp": Time.get_datetime_string_from_system(),
			"engine_version": Engine.get_version_info()["string"],
		},
		"game_state": game_state.duplicate(true),
		"nodes": nodes_data,
		"checksum": "",
	}

	# 체크섬 생성 (무결성 확인용)
	save["checksum"] = _generate_checksum(save)

	return save


func _generate_checksum(data: Dictionary) -> String:
	# 간단한 체크섬: game_state와 nodes를 문자열로 변환 후 해시
	var check_data = {
		"game_state": data.get("game_state", {}),
		"nodes": data.get("nodes", []),
	}
	var json_str = JSON.stringify(check_data)
	return json_str.md5_text()


func _verify_checksum(data: Dictionary) -> bool:
	var stored_checksum = data.get("checksum", "")
	var check_data = {
		"game_state": data.get("game_state", {}),
		"nodes": data.get("nodes", []),
	}
	var computed = JSON.stringify(check_data).md5_text()
	return stored_checksum == computed


func _migrate_save_data(data: Dictionary) -> Dictionary:
	var version = data.get("meta", {}).get("version", 1)

	if version < 2:
		# v1 -> v2: player_hp를 player 하위 딕셔너리로 이동
		if data.has("game_state") and data["game_state"].has("player_hp"):
			data["game_state"]["player"] = {
				"hp": data["game_state"]["player_hp"]
			}
			data["game_state"].erase("player_hp")
		data["meta"]["version"] = 2

	# 향후 마이그레이션 추가:
	# if version < 3:
	#     ...

	return data


# =============================================================================
# 유틸리티
# =============================================================================

func _format_play_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]


# =============================================================================
# 테스트용 PersistNode 내부 클래스
# =============================================================================

class PersistNode extends Node:
	var node_id: String
	var scene_path: String
	var custom_data: Dictionary = {}

	func _init(p_id: String = "", p_scene_path: String = ""):
		node_id = p_id
		scene_path = p_scene_path

	func _ready():
		add_to_group("persist")

	func save_data() -> Dictionary:
		return {
			"node_id": node_id,
			"scene_path": scene_path,
			"data": custom_data.duplicate(true),
		}

	func load_data(data: Dictionary):
		node_id = data.get("node_id", "")
		scene_path = data.get("scene_path", "")
		custom_data = data.get("data", {})
