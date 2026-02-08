# 챕터 11: 리소스와 데이터 관리
#
# 이 챕터에서는 다음을 학습합니다:
# - 커스텀 Resource 클래스로 재사용 가능한 데이터 정의
# - JSON 파일을 통한 데이터 저장/불러오기
# - ConfigFile을 활용한 설정 관리
# - 게임 상태 관리 싱글톤 패턴
# - 다중 세이브 슬롯 시스템

extends Node

# ============================================================
# 연습 1: 커스텀 Resource 클래스 작성
# ============================================================
# Resource를 상속하여 아이템 데이터 클래스를 정의합니다.
# 에디터에서 .tres 파일로 저장하고, 코드에서 인스턴스로 사용할 수 있습니다.
# 참고: 실제로는 별도 파일(item_data.gd)에 class_name으로 정의하지만,
# 여기서는 내부 클래스로 연습합니다.

# TODO: ItemData 내부 클래스를 아래에 정의하세요
# class ItemData:
#     extends Resource
#     @export var item_name: String = ""
#     @export var description: String = ""
#     @export var icon_path: String = ""
#     @export_enum("weapon", "armor", "potion", "key") var item_type: String = "potion"
#     @export var value: int = 0
#     @export var stackable: bool = true
#     @export var max_stack: int = 99

# 여기를 수정하세요 - 위의 ItemData 클래스를 작성하세요

func create_item(item_name: String, item_type: String, value: int) -> Resource:
	# TODO: ItemData 인스턴스를 생성하세요 (위에서 클래스를 정의한 경우)
	#       클래스를 정의하지 않은 경우 Resource를 대신 사용하세요
	# TODO: item_name, item_type, value를 설정하세요
	# TODO: item_type이 "potion"이면 stackable = true, max_stack = 20
	# TODO: item_type이 "weapon"이나 "armor"이면 stackable = false, max_stack = 1
	# TODO: 생성한 리소스를 반환하세요
	var item = null  # 여기를 수정하세요
	return item

func item_to_dict(item: Resource) -> Dictionary:
	# TODO: Resource의 속성들을 Dictionary로 변환하여 반환하세요
	# TODO: 포함할 키: "item_name", "item_type", "value", "stackable", "max_stack"
	#       (힌트: item.get("item_name") 또는 직접 프로퍼티 접근)
	var dict = {}  # 여기를 수정하세요
	return dict


# ============================================================
# 연습 2: JSON 저장 함수
# ============================================================
# Dictionary 데이터를 JSON 파일로 저장합니다.
# 세이브 데이터, 설정, 레벨 데이터 등을 파일로 보관할 때 사용합니다.

func save_json(file_path: String, data: Dictionary) -> bool:
	# TODO: JSON.stringify(data, "\t")로 JSON 문자열을 생성하세요
	#       ("\t"는 보기 좋게 들여쓰기)
	# TODO: FileAccess.open(file_path, FileAccess.WRITE)로 파일을 여세요
	# TODO: 파일 열기에 실패하면 (file == null) 에러를 출력하고 false를 반환하세요
	# TODO: file.store_string(json_string)으로 내용을 저장하세요
	# TODO: "JSON 저장 완료: {file_path}"를 출력하세요
	# TODO: true를 반환하세요
	var success = false  # 여기를 수정하세요
	return success


# ============================================================
# 연습 3: JSON 불러오기 함수
# ============================================================
# JSON 파일을 읽어 Dictionary로 변환합니다.

func load_json(file_path: String) -> Dictionary:
	# TODO: FileAccess.file_exists(file_path)로 파일 존재 여부를 확인하세요
	#       존재하지 않으면 빈 Dictionary를 반환하세요
	# TODO: FileAccess.open(file_path, FileAccess.READ)로 파일을 여세요
	# TODO: 파일 열기에 실패하면 빈 Dictionary를 반환하세요
	# TODO: file.get_as_text()로 전체 텍스트를 읽으세요
	# TODO: JSON.new()를 생성하고 json.parse(text)로 파싱하세요
	# TODO: 파싱 결과가 OK가 아니면 에러를 출력하고 빈 Dictionary를 반환하세요
	#       (힌트: var error = json.parse(text), error != OK이면 실패)
	# TODO: json.data를 반환하세요 (파싱된 Dictionary)
	# TODO: "JSON 불러오기 완료: {file_path}"를 출력하세요
	var data = {}  # 여기를 수정하세요
	return data

func save_and_verify(file_path: String, data: Dictionary) -> bool:
	# TODO: save_json으로 데이터를 저장하세요
	# TODO: load_json으로 데이터를 다시 불러오세요
	# TODO: 원본과 불러온 데이터를 비교하세요 (str(data) == str(loaded))
	# TODO: 비교 결과를 출력하고 일치 여부(bool)를 반환하세요
	var verified = false  # 여기를 수정하세요
	return verified


# ============================================================
# 연습 4: ConfigFile 사용
# ============================================================
# ConfigFile로 게임 설정을 저장/불러옵니다.
# INI 형식으로 섹션별로 정리된 설정 파일을 관리합니다.

func save_settings(file_path: String, settings: Dictionary) -> bool:
	# TODO: ConfigFile을 생성하세요
	# TODO: settings Dictionary를 순회하며 ConfigFile에 값을 설정하세요
	#       settings 형식 예시:
	#       {
	#           "audio": {"master_volume": 80, "bgm_volume": 70, "sfx_volume": 90},
	#           "display": {"fullscreen": false, "vsync": true, "resolution": "1920x1080"},
	#           "controls": {"jump": "space", "attack": "z"}
	#       }
	# TODO: 각 최상위 키는 섹션, 내부 키-값은 설정값입니다
	#       (힌트: config.set_value(section, key, value))
	# TODO: config.save(file_path)로 저장하세요
	# TODO: 저장 결과가 OK이면 true, 아니면 false를 반환하세요
	var success = false  # 여기를 수정하세요
	return success

func load_settings(file_path: String) -> Dictionary:
	# TODO: ConfigFile을 생성하세요
	# TODO: config.load(file_path)로 파일을 불러오세요
	# TODO: 불러오기에 실패하면 빈 Dictionary를 반환하세요
	# TODO: config.get_sections()으로 모든 섹션을 가져오세요
	# TODO: 각 섹션에 대해 config.get_section_keys(section)으로 키를 가져오세요
	# TODO: config.get_value(section, key)로 값을 읽어 Dictionary에 저장하세요
	# TODO: 복원된 Dictionary를 반환하세요
	var settings = {}  # 여기를 수정하세요
	return settings


# ============================================================
# 연습 5: 게임 상태 싱글톤 설계
# ============================================================
# 게임 전체에서 공유되는 상태를 관리하는 싱글톤 패턴입니다.
# 실제로는 자동로드(AutoLoad)로 등록하여 사용합니다.
# 여기서는 클래스 설계만 연습합니다.

var game_state: Dictionary = {}

func init_game_state() -> Dictionary:
	# TODO: 게임 상태를 초기화하는 Dictionary를 생성하세요
	# TODO: 포함할 키:
	#       - "player_name": ""
	#       - "current_level": 1
	#       - "score": 0
	#       - "lives": 3
	#       - "inventory": []  (빈 배열)
	#       - "unlocked_levels": [1]  (첫 번째 레벨만 해금)
	#       - "play_time": 0.0
	#       - "settings": {"volume": 100, "difficulty": "normal"}
	# TODO: game_state 변수에 저장하세요
	# TODO: game_state를 반환하세요
	var state = {}  # 여기를 수정하세요
	return state

func update_game_state(key: String, value: Variant) -> void:
	# TODO: game_state[key]를 value로 업데이트하세요
	# TODO: "게임 상태 업데이트: {key} = {value}"를 출력하세요
	pass  # 여기를 수정하세요

func get_game_state(key: String, default_value: Variant = null) -> Variant:
	# TODO: game_state에서 key에 해당하는 값을 반환하세요
	# TODO: 키가 존재하지 않으면 default_value를 반환하세요
	#       (힌트: game_state.get(key, default_value))
	var value = null  # 여기를 수정하세요
	return value


# ============================================================
# 연습 6: 세이브 슬롯 관리
# ============================================================
# 여러 개의 세이브 슬롯을 관리하는 시스템입니다.
# 각 슬롯은 독립적인 세이브 파일로 저장됩니다.

const SAVE_DIR = "user://saves/"
const MAX_SLOTS = 3

func get_save_path(slot: int) -> String:
	# TODO: 슬롯 번호에 해당하는 세이브 파일 경로를 반환하세요
	# TODO: 형식: "user://saves/save_slot_N.json" (N은 슬롯 번호)
	# TODO: slot이 1 ~ MAX_SLOTS 범위를 벗어나면 빈 문자열을 반환하세요
	var path = ""  # 여기를 수정하세요
	return path

func save_to_slot(slot: int, data: Dictionary) -> bool:
	# TODO: get_save_path로 저장 경로를 구하세요
	# TODO: 경로가 비어있으면 false를 반환하세요
	# TODO: SAVE_DIR 디렉토리가 없으면 생성하세요
	#       (힌트: DirAccess.make_dir_recursive_absolute(SAVE_DIR))
	# TODO: data에 메타데이터를 추가하세요:
	#       - "save_slot": slot
	#       - "save_date": Time.get_datetime_string_from_system()
	# TODO: save_json 함수를 호출하여 저장하세요
	# TODO: 저장 결과를 반환하세요
	var success = false  # 여기를 수정하세요
	return success

func load_from_slot(slot: int) -> Dictionary:
	# TODO: get_save_path로 저장 경로를 구하세요
	# TODO: 경로가 비어있으면 빈 Dictionary를 반환하세요
	# TODO: load_json 함수를 호출하여 데이터를 불러오세요
	# TODO: 불러온 데이터를 반환하세요
	var data = {}  # 여기를 수정하세요
	return data

func get_all_slot_info() -> Array:
	# TODO: 모든 슬롯(1 ~ MAX_SLOTS)의 정보를 배열로 반환하세요
	# TODO: 각 슬롯의 정보는 Dictionary:
	#       - "slot": 슬롯 번호
	#       - "exists": 세이브 파일 존재 여부 (FileAccess.file_exists)
	#       - "data": 파일이 있으면 load_from_slot, 없으면 빈 Dictionary
	# TODO: 배열을 반환하세요
	var slots = []  # 여기를 수정하세요
	return slots

func delete_slot(slot: int) -> bool:
	# TODO: get_save_path로 저장 경로를 구하세요
	# TODO: 파일이 존재하면 DirAccess.remove_absolute(path)로 삭제하세요
	# TODO: 삭제 성공이면 true, 파일이 없거나 실패하면 false를 반환하세요
	# TODO: "슬롯 {slot} 삭제 완료"를 출력하세요
	var success = false  # 여기를 수정하세요
	return success


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 11: 리소스와 데이터 관리 ===")
	print("")

	# 테스트 1: 커스텀 Resource
	var sword = create_item("용의 검", "weapon", 500)
	if sword != null:
		print("결과 1 (아이템 생성):", sword is Resource)
		var sword_dict = item_to_dict(sword)
		print("결과 1 (아이템 데이터):", sword_dict)
	else:
		print("결과 1: null - create_item을 구현하세요")
	var potion = create_item("회복 물약", "potion", 50)
	if potion != null:
		var potion_dict = item_to_dict(potion)
		print("결과 1 (물약 데이터):", potion_dict)
	print("")

	# 테스트 2: JSON 저장
	var test_data = {
		"player": "Hero",
		"level": 5,
		"items": ["sword", "shield"],
		"stats": {"hp": 100, "mp": 50}
	}
	var save_result = save_json("user://test_save.json", test_data)
	print("결과 2 (JSON 저장):", save_result)
	print("")

	# 테스트 3: JSON 불러오기
	var loaded_data = load_json("user://test_save.json")
	print("결과 3 (JSON 불러오기):", loaded_data)
	var verified = save_and_verify("user://test_verify.json", test_data)
	print("결과 3 (저장/검증):", verified)
	print("")

	# 테스트 4: ConfigFile
	var test_settings = {
		"audio": {"master_volume": 80, "bgm_volume": 70, "sfx_volume": 90},
		"display": {"fullscreen": false, "vsync": true},
		"controls": {"jump": "space", "attack": "z"}
	}
	var settings_saved = save_settings("user://test_settings.cfg", test_settings)
	print("결과 4 (설정 저장):", settings_saved)
	var loaded_settings = load_settings("user://test_settings.cfg")
	print("결과 4 (설정 불러오기):", loaded_settings)
	print("")

	# 테스트 5: 게임 상태 싱글톤
	var state = init_game_state()
	print("결과 5 (초기 상태):", state)
	update_game_state("score", 1000)
	update_game_state("current_level", 3)
	print("결과 5 (업데이트 후 점수):", get_game_state("score"))
	print("결과 5 (업데이트 후 레벨):", get_game_state("current_level"))
	print("결과 5 (없는 키 기본값):", get_game_state("nonexistent", "기본"))
	print("")

	# 테스트 6: 세이브 슬롯
	var slot_path = get_save_path(1)
	print("결과 6 (슬롯 1 경로):", slot_path)
	print("결과 6 (유효하지 않은 슬롯):", get_save_path(0))
	print("결과 6 (유효하지 않은 슬롯):", get_save_path(5))
	var slot_save = save_to_slot(1, {"player": "Hero", "level": 5})
	print("결과 6 (슬롯 1 저장):", slot_save)
	var slot_load = load_from_slot(1)
	print("결과 6 (슬롯 1 불러오기):", slot_load)
	var all_slots = get_all_slot_info()
	print("결과 6 (전체 슬롯 정보):", all_slots)
	var deleted = delete_slot(1)
	print("결과 6 (슬롯 1 삭제):", deleted)
	print("")

	print("=== 챕터 11 완료 ===")
