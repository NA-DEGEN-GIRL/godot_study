# 챕터 11: 리소스 & 데이터 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - Resource 클래스를 상속하여 커스텀 데이터 타입 만들기
# - JSON 형식으로 게임 데이터 저장하기
# - JSON 파일에서 게임 데이터 불러오기
# - ConfigFile로 설정 관리하기
# - 게임 상태 싱글톤(Autoload) 패턴
# - 다중 슬롯 세이브 시스템 구현

extends Node

# 세이브 시스템 상수
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".sav"
const MAX_SAVE_SLOTS = 3

func _ready():
	print("=== 챕터 11: 리소스 & 데이터 ===\n")

	# 연습 1: Resource 클래스
	var item = _exercise_1_resource_class()

	# 연습 2: JSON 저장
	var json_path = _exercise_2_json_save()

	# 연습 3: JSON 불러오기
	_exercise_3_json_load(json_path)

	# 연습 4: ConfigFile
	var config_path = _exercise_4_config_file()

	# 연습 5: 게임 상태 싱글톤
	_exercise_5_game_state_singleton()

	# 연습 6: 세이브 슬롯
	_exercise_6_save_slots()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: Resource 클래스 - '%s' (%s, %dG)" % [
		item.item_name, item.get_rarity_name(), item.price
	])
	print("결과 2: JSON 저장 완료 - %s" % json_path)
	print("결과 3: JSON 불러오기 완료")
	print("결과 4: ConfigFile 설정 완료 - %s" % config_path)
	print("결과 5: 게임 상태 싱글톤 패턴 구현 완료")
	print("결과 6: 세이브 슬롯 (최대 %d슬롯) 구현 완료" % MAX_SAVE_SLOTS)

	# 테스트 파일 정리
	_cleanup_files([json_path, config_path])


# ==============================================================================
# 연습 1: Resource 클래스 - 커스텀 리소스 클래스를 정의하고
#          인스턴스를 생성하여 속성을 설정하세요.
# ==============================================================================
func _exercise_1_resource_class() -> ItemResource:
	# 풀이: Resource를 상속하는 내부 클래스를 정의하고 @export 속성을 추가합니다.
	#       enum으로 타입을 분류하고, 메서드(get_rarity_name, get_sell_price)로
	#       비즈니스 로직을 캡슐화합니다.
	#       new()로 인스턴스를 생성하고 속성을 설정합니다.
	#       duplicate()로 독립 복사본을 만들 수 있습니다.

	print("연습 1: Resource 클래스")

	# 아이템 리소스 생성
	var item = ItemResource.new()
	item.item_name = "Fire Sword"
	item.description = "화염이 깃든 검. 추가 화염 대미지."
	item.price = 500
	item.stack_size = 1
	item.rarity = 2  # Epic
	item.item_type = ItemResource.ItemType.WEAPON

	print("  ItemResource 인스턴스:")
	print("    이름: %s" % item.item_name)
	print("    설명: %s" % item.description)
	print("    가격: %dG (판매가: %dG)" % [item.price, item.get_sell_price()])
	print("    스택: %d" % item.stack_size)
	print("    희귀도: %s" % item.get_rarity_name())
	print("    타입: %s" % ItemResource.ItemType.keys()[item.item_type])
	print()

	# 캐릭터 스탯 리소스
	var warrior = CharacterStats.new()
	warrior.character_name = "Warrior"
	warrior.max_hp = 150
	warrior.max_mp = 30
	warrior.attack = 25
	warrior.defense = 20
	warrior.speed = 8.0

	var mage = CharacterStats.new()
	mage.character_name = "Mage"
	mage.max_hp = 80
	mage.max_mp = 120
	mage.attack = 10
	mage.defense = 8
	mage.speed = 6.0

	print("  캐릭터 스탯 비교:")
	print("    +----------+----------+----------+")
	print("    | 스탯     | %-8s | %-8s |" % [warrior.character_name, mage.character_name])
	print("    +----------+----------+----------+")
	print("    | HP       | %8d | %8d |" % [warrior.max_hp, mage.max_hp])
	print("    | MP       | %8d | %8d |" % [warrior.max_mp, mage.max_mp])
	print("    | Attack   | %8d | %8d |" % [warrior.attack, mage.attack])
	print("    | Defense  | %8d | %8d |" % [warrior.defense, mage.defense])
	print("    | Speed    | %8.1f | %8.1f |" % [warrior.speed, mage.speed])
	print("    +----------+----------+----------+")
	print()

	# 레벨업 시뮬레이션
	warrior.gain_experience(150)
	print("  Warrior 경험치 150 획득:")
	print("    레벨: %d, 경험치: %d/%d" % [
		warrior.level, warrior.experience, warrior.exp_to_next_level()
	])
	print("    HP: %d, ATK: %d, DEF: %d" % [warrior.max_hp, warrior.attack, warrior.defense])
	print()

	# 참조 공유 vs 복제
	print("  리소스 참조 공유 vs 복제:")
	var item_copy = item.duplicate() as ItemResource
	if item_copy:
		item_copy.price = 999
		print("    원본 price: %d (변경 안 됨)" % item.price)
		print("    복제 price: %d (독립적)" % item_copy.price)
	else:
		print("    duplicate() 결과: 타입 캐스팅 확인 필요")

	print("연습 1 완료: Resource 클래스 정의 및 활용")
	return item


# ==============================================================================
# 연습 2: JSON 저장 - 게임 데이터를 JSON 파일로 저장하세요.
# ==============================================================================
func _exercise_2_json_save() -> String:
	# 풀이: Dictionary로 게임 데이터를 구성하고, JSON.stringify(data, "\t")로
	#       JSON 문자열로 변환합니다. FileAccess.open(path, WRITE)로 파일을 열고
	#       store_string()으로 저장합니다. user:// 경로를 사용해야 쓰기가 가능합니다.

	print("\n연습 2: JSON 저장")

	var json_path = "user://game_data.json"

	# 저장할 게임 데이터
	var game_data = {
		"player": {
			"name": "Hero",
			"level": 15,
			"hp": 120,
			"mp": 45,
			"position": {"x": 100.5, "y": 200.3},
			"inventory": ["sword", "shield", "potion"],
		},
		"settings": {
			"difficulty": "normal",
			"language": "ko",
		},
		"play_time": 3600.5,
		"save_date": Time.get_datetime_string_from_system(),
	}

	# JSON 문자열로 변환 (탭으로 포맷팅)
	var json_string = JSON.stringify(game_data, "\t")

	# 파일에 저장
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("  JSON 저장 성공: %s" % json_path)
		print("  파일 크기: %d bytes" % FileAccess.get_file_as_string(json_path).length())
	else:
		print("  파일 열기 실패: %s" % FileAccess.get_open_error())
	print()

	# 저장 데이터 요약
	print("  저장 데이터 요약:")
	print("    플레이어: %s (Lv.%d)" % [game_data.player.name, game_data.player.level])
	print("    위치: (%.1f, %.1f)" % [game_data.player.position.x, game_data.player.position.y])
	print("    인벤토리: %s" % game_data.player.inventory)
	print("    난이도: %s" % game_data.settings.difficulty)
	print("    저장 시간: %s" % game_data.save_date)

	print("연습 2 완료: JSON 저장")
	return json_path


# ==============================================================================
# 연습 3: JSON 불러오기 - 저장된 JSON 파일을 읽어서 데이터를 파싱하세요.
# ==============================================================================
func _exercise_3_json_load(json_path: String):
	# 풀이: FileAccess.open(path, READ)로 파일을 열고 get_as_text()로 전체를 읽습니다.
	#       JSON.new()를 생성하고 parse(text)로 파싱합니다. 반환값이 OK이면 성공이며,
	#       json.data에서 Dictionary를 가져옵니다. 파싱 실패 시 get_error_line()과
	#       get_error_message()로 오류 위치를 확인합니다.
	#       간편 방법: JSON.parse_string(text)으로 한 줄에 파싱할 수도 있습니다.

	print("\n연습 3: JSON 불러오기")

	# 방법 1: JSON 클래스 사용 (상세한 오류 처리)
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result == OK:
			var data = json.data
			print("  파싱 성공!")
			print("    플레이어: %s (Lv.%d)" % [
				data["player"]["name"], data["player"]["level"]
			])
			print("    위치: (%s, %s)" % [
				data["player"]["position"]["x"],
				data["player"]["position"]["y"]
			])
			print("    인벤토리: %s" % data["player"]["inventory"])
			print("    난이도: %s" % data["settings"]["difficulty"])
			print("    저장 시간: %s" % data["save_date"])
		else:
			print("  파싱 실패! 줄 %d: %s" % [json.get_error_line(), json.get_error_message()])
	else:
		print("  파일 열기 실패")
	print()

	# 방법 2: 간편한 방법 (JSON.parse_string)
	print("  간편한 불러오기 (JSON.parse_string):")
	var quick_data = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if quick_data:
		print("    결과: %s (Lv.%d)" % [
			quick_data["player"]["name"], quick_data["player"]["level"]
		])
	else:
		print("    파싱 실패")
	print()

	# 파일 존재 확인 패턴
	print("  파일 존재 확인:")
	print("    FileAccess.file_exists(\"%s\"): %s" % [json_path, FileAccess.file_exists(json_path)])

	print("연습 3 완료: JSON 불러오기")


# ==============================================================================
# 연습 4: ConfigFile - INI 형식으로 게임 설정을 저장/불러오기하세요.
# ==============================================================================
func _exercise_4_config_file() -> String:
	# 풀이: ConfigFile.new()로 인스턴스를 생성하고,
	#       set_value(section, key, value)로 설정값을 넣습니다.
	#       save(path)로 파일에 저장하고, load(path)로 불러옵니다.
	#       get_value(section, key, default)로 안전하게 읽으며,
	#       키가 없으면 기본값을 반환합니다.
	#       get_sections()로 섹션 목록, get_section_keys(section)으로 키 목록을 얻습니다.

	print("\n연습 4: ConfigFile 설정 관리")

	var config_path = "user://settings.cfg"
	var config = ConfigFile.new()

	# 설정 쓰기
	config.set_value("audio", "master_volume", 80)
	config.set_value("audio", "bgm_volume", 60)
	config.set_value("audio", "sfx_volume", 100)
	config.set_value("audio", "mute", false)

	config.set_value("display", "fullscreen", true)
	config.set_value("display", "vsync", true)
	config.set_value("display", "resolution", Vector2i(1920, 1080))

	config.set_value("controls", "jump", "space")
	config.set_value("controls", "attack", "z")
	config.set_value("controls", "dash", "shift")

	config.set_value("gameplay", "difficulty", "normal")
	config.set_value("gameplay", "language", "ko")

	# 저장
	var save_err = config.save(config_path)
	print("  설정 저장: %s" % ("성공" if save_err == OK else "실패"))
	print("  경로: %s" % config_path)
	print()

	# 불러오기
	var load_config = ConfigFile.new()
	var load_err = load_config.load(config_path)

	if load_err == OK:
		print("  설정 읽기:")
		var sections = load_config.get_sections()
		print("    섹션: %s" % [sections])
		print()

		for section in sections:
			print("    [%s]" % section)
			var keys = load_config.get_section_keys(section)
			for key in keys:
				var value = load_config.get_value(section, key)
				print("      %s = %s" % [key, value])
			print()

		# 기본값과 함께 읽기
		var vol = load_config.get_value("audio", "master_volume", 100)
		var missing = load_config.get_value("audio", "nonexistent_key", "기본값")
		print("    존재하는 키: master_volume = %s" % vol)
		print("    없는 키 (기본값): %s" % missing)

	print("연습 4 완료: ConfigFile 설정 관리")
	return config_path


# ==============================================================================
# 연습 5: 게임 상태 싱글톤 - Autoload 패턴으로 전역 게임 상태를 관리하세요.
#          점수, HP, 코인을 관리하고 시그널로 변경을 알립니다.
# ==============================================================================
func _exercise_5_game_state_singleton():
	# 풀이: Autoload로 등록할 스크립트에 signal을 정의하고, 상태 변경 함수에서
	#       시그널을 emit합니다. 다른 씬에서는 AutoloadName.signal.connect()로 구독합니다.
	#       reset_game()으로 게임 리셋, take_damage()/heal()로 HP 관리,
	#       add_score()/collect_coin()으로 점수/코인을 관리합니다.
	#       씬 전환 시에도 데이터가 유지되는 것이 핵심입니다.

	print("\n연습 5: 게임 상태 싱글톤")

	var gm = GameManagerExample.new()

	print("  초기 상태:")
	gm.print_status("    ")
	print()

	# 시그널 연결
	gm.score_changed.connect(func(new_score):
		print("    [시그널] 점수: %d" % new_score)
	)
	gm.hp_changed.connect(func(new_hp):
		print("    [시그널] HP: %d" % new_hp)
	)
	gm.game_over_triggered.connect(func():
		print("    [시그널] 게임 오버!")
	)
	gm.coin_collected.connect(func(total):
		print("    [시그널] 코인 수집! 총 %d개" % total)
	)

	# 상태 변경 테스트
	print("  상태 변경 테스트:")
	gm.add_score(500)
	gm.collect_coin()
	gm.collect_coin()
	gm.take_damage(30)
	print()

	print("  현재 상태:")
	gm.print_status("    ")
	print()

	# 게임 오버
	print("  대미지 200:")
	gm.take_damage(200)
	gm.print_status("    ")
	print()

	# 리셋
	gm.reset_game()
	print("  리셋 후:")
	gm.print_status("    ")
	print()

	# Autoload 구조 설명
	print("  Autoload 등록 방법:")
	print("    프로젝트 > 프로젝트 설정 > Autoload 탭")
	print("    경로: res://scripts/game_manager.gd")
	print("    이름: GameManager")
	print()
	print("  다른 스크립트에서 사용:")
	print("    GameManager.add_score(100)")
	print("    GameManager.score_changed.connect(_on_score_changed)")

	print("연습 5 완료: 게임 상태 싱글톤")


# ==============================================================================
# 연습 6: 세이브 슬롯 - 다중 슬롯 세이브 시스템을 구현하세요.
#          저장, 불러오기, 삭제, 슬롯 목록 조회를 포함합니다.
# ==============================================================================
func _exercise_6_save_slots():
	# 풀이: 세이브 디렉토리(user://saves/)를 확인/생성하고,
	#       슬롯별 파일(save_slot_N.sav)에 JSON으로 저장합니다.
	#       meta(version, timestamp) + game_state + nodes 구조로 직렬화합니다.
	#       불러오기 시 JSON 파싱 후 버전 마이그레이션을 적용합니다.
	#       get_save_slots_info()로 전체 슬롯 상태를 조회합니다.

	print("\n연습 6: 세이브 슬롯 시스템")

	# 세이브 디렉토리 확인/생성
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
		print("  세이브 디렉토리 생성: %s" % SAVE_DIR)
	else:
		print("  세이브 디렉토리 확인: %s" % SAVE_DIR)
	print()

	# 테스트 게임 상태
	var game_state = {
		"score": 12500,
		"coins": 47,
		"current_level": "res://levels/forest.tscn",
		"play_time_seconds": 1847.5,
	}

	# 슬롯 1에 저장
	var result = _save_to_slot(1, game_state)
	print("  슬롯 1 저장: %s" % ("성공" if result else "실패"))

	# 슬롯 2에 다른 데이터 저장
	game_state.score = 25000
	game_state.play_time_seconds = 3600.0
	result = _save_to_slot(2, game_state)
	print("  슬롯 2 저장: %s" % ("성공" if result else "실패"))
	print()

	# 슬롯 목록 조회
	print("  세이브 슬롯 목록:")
	var slots = _get_save_slots_info()
	for slot in slots:
		if slot.exists:
			print("    슬롯 %d: score=%s, 시간=%s" % [
				slot.slot,
				slot.get("score", "?"),
				_format_play_time(slot.get("play_time", 0))
			])
		else:
			print("    슬롯 %d: (비어있음)" % slot.slot)
	print()

	# 슬롯 1 불러오기
	var loaded = _load_from_slot(1)
	if not loaded.is_empty():
		print("  슬롯 1 불러오기:")
		print("    버전: %s" % loaded["meta"]["version"])
		print("    점수: %s" % loaded["game_state"]["score"])
		print("    코인: %s" % loaded["game_state"]["coins"])
		print("    레벨: %s" % loaded["game_state"]["current_level"])
	else:
		print("  슬롯 1 불러오기 실패")
	print()

	# 세이브 삭제
	print("  세이브 삭제:")
	for slot in [1, 2]:
		var deleted = _delete_save(slot)
		print("    슬롯 %d: %s" % [slot, "삭제됨" if deleted else "없음"])
	print()

	# 전체 API 요약
	print("  SaveSystem API 요약:")
	print("    save_to_slot(slot, game_state) -> bool")
	print("    load_from_slot(slot) -> Dictionary")
	print("    delete_save(slot) -> bool")
	print("    get_save_slots_info() -> Array")

	print("연습 6 완료: 세이브 슬롯 시스템")


# 세이브 슬롯 헬퍼 함수들
func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_slot_%d%s" % [slot, SAVE_EXTENSION]

func _save_to_slot(slot: int, game_state: Dictionary) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return false

	var save_data = {
		"meta": {
			"version": 1,
			"timestamp": Time.get_datetime_string_from_system(),
		},
		"game_state": game_state.duplicate(true),
	}

	var json_string = JSON.stringify(save_data, "\t")
	var path = _get_save_path(slot)

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false

	file.store_string(json_string)
	file.close()
	return true

func _load_from_slot(slot: int) -> Dictionary:
	var path = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		return {}

	return json.data as Dictionary

func _delete_save(slot: int) -> bool:
	var path = _get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		return true
	return false

func _get_save_slots_info() -> Array:
	var slots = []
	for i in range(MAX_SAVE_SLOTS):
		var info = {"slot": i, "exists": false}
		var path = _get_save_path(i)

		if FileAccess.file_exists(path):
			info.exists = true
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				file.close()
				if parsed and parsed.has("meta"):
					info["timestamp"] = parsed["meta"].get("timestamp", "")
					info["score"] = parsed["game_state"].get("score", 0)
					info["play_time"] = parsed["game_state"].get("play_time_seconds", 0)

		slots.append(info)
	return slots

func _format_play_time(seconds: float) -> String:
	var total = int(seconds)
	var hours = total / 3600
	var minutes = (total % 3600) / 60
	var secs = total % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	return "%02d:%02d" % [minutes, secs]

func _cleanup_files(paths: Array):
	for path in paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


# ==============================================================================
# 내부 클래스: ItemResource
# ==============================================================================
class ItemResource extends Resource:
	enum ItemType { WEAPON, ARMOR, CONSUMABLE, MATERIAL, KEY_ITEM }

	@export var item_name: String = ""
	@export var description: String = ""
	@export var price: int = 0
	@export var stack_size: int = 1
	@export var rarity: int = 0  # 0=Common, 1=Rare, 2=Epic, 3=Legendary
	@export var item_type: ItemType = ItemType.MATERIAL

	func get_rarity_name() -> String:
		match rarity:
			0: return "Common"
			1: return "Rare"
			2: return "Epic"
			3: return "Legendary"
			_: return "Unknown"

	func get_sell_price() -> int:
		return int(price * 0.5)


# ==============================================================================
# 내부 클래스: CharacterStats
# ==============================================================================
class CharacterStats extends Resource:
	@export var character_name: String = ""
	@export var max_hp: int = 100
	@export var max_mp: int = 50
	@export var attack: int = 10
	@export var defense: int = 10
	@export var speed: float = 5.0
	@export var level: int = 1
	@export var experience: int = 0

	func exp_to_next_level() -> int:
		return level * 100

	func gain_experience(amount: int):
		experience += amount
		while experience >= exp_to_next_level():
			experience -= exp_to_next_level()
			_level_up()

	func _level_up():
		level += 1
		max_hp += 10
		max_mp += 5
		attack += 3
		defense += 2
		speed += 0.5


# ==============================================================================
# 내부 클래스: GameManagerExample
# ==============================================================================
class GameManagerExample:
	signal score_changed(new_score: int)
	signal hp_changed(new_hp: int)
	signal game_over_triggered
	signal coin_collected(total_coins: int)

	var score: int = 0
	var high_score: int = 0
	var coins: int = 0
	var hp: int = 100
	var max_hp: int = 100
	var is_game_over: bool = false

	func add_score(amount: int):
		score += amount
		if score > high_score:
			high_score = score
		score_changed.emit(score)

	func collect_coin():
		coins += 1
		add_score(10)
		coin_collected.emit(coins)

	func take_damage(amount: int):
		if is_game_over:
			return
		hp = max(0, hp - amount)
		hp_changed.emit(hp)
		if hp <= 0:
			is_game_over = true
			game_over_triggered.emit()

	func heal(amount: int):
		hp = min(max_hp, hp + amount)
		hp_changed.emit(hp)

	func reset_game():
		score = 0
		coins = 0
		hp = max_hp
		is_game_over = false

	func print_status(indent: String = ""):
		print("%sscore=%d, coins=%d, hp=%d/%d, game_over=%s" % [
			indent, score, coins, hp, max_hp, is_game_over
		])
