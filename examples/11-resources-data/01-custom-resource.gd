# Chapter 11 - Resources & Data Management
# 01-custom-resource.gd - 커스텀 리소스 클래스
#
# 이 파일에서 배울 내용:
# - Resource 클래스 상속으로 커스텀 데이터 타입 만들기
# - @export를 활용한 인스펙터 편집
# - ResourceSaver / ResourceLoader로 저장/불러오기
# - .tres (텍스트) vs .res (바이너리) 포맷 차이
# - 실용 예시: 아이템, 캐릭터 스탯 리소스

extends Node

func _ready():
	print("=== Chapter 11-1: 커스텀 리소스(Resource) 클래스 ===\n")

	# -----------------------------------------------------------------
	# 1) Resource란?
	# -----------------------------------------------------------------
	print("--- 1. Resource 기본 개념 ---")

	print("  Resource = Godot의 데이터 컨테이너 클래스")
	print("  특징:")
	print("    - 파일로 저장/불러오기 가능 (.tres, .res)")
	print("    - 인스펙터에서 편집 가능 (@export)")
	print("    - 참조 공유 (여러 노드가 같은 리소스를 참조)")
	print("    - 내장 리소스 예: Texture, Material, AudioStream, Font 등")
	print()

	print("  커스텀 리소스를 만드는 이유:")
	print("    - 게임 데이터를 구조화된 형태로 관리")
	print("    - 에디터에서 직접 편집 가능 (프로그래머 없이)")
	print("    - 데이터와 로직 분리 (Data-Driven Design)")
	print()

	# -----------------------------------------------------------------
	# 2) 커스텀 리소스 정의
	# -----------------------------------------------------------------
	print("--- 2. 커스텀 리소스 정의 ---")

	print("  # item_data.gd")
	print("  class_name ItemData")
	print("  extends Resource")
	print()
	print("  @export var item_name: String = \"\"")
	print("  @export var description: String = \"\"")
	print("  @export var icon: Texture2D")
	print("  @export var price: int = 0")
	print("  @export_range(1, 99) var stack_size: int = 1")
	print("  @export_enum(\"Common\", \"Rare\", \"Epic\", \"Legendary\")")
	print("  var rarity: int = 0")
	print()

	# 내부 클래스로 리소스 시연
	var item = ItemResource.new()
	item.item_name = "Health Potion"
	item.description = "Restores 50 HP"
	item.price = 100
	item.stack_size = 10
	item.rarity = 0  # Common
	item.item_type = ItemResource.ItemType.CONSUMABLE

	print("  ItemResource 인스턴스 생성:")
	print("    이름: ", item.item_name)
	print("    설명: ", item.description)
	print("    가격: ", item.price)
	print("    스택: ", item.stack_size)
	print("    희귀도: ", item.get_rarity_name())
	print("    타입: ", item.item_type)
	print()

	# -----------------------------------------------------------------
	# 3) @export 고급 힌트
	# -----------------------------------------------------------------
	print("--- 3. @export 어노테이션 종류 ---")

	print("  기본 타입:")
	print("    @export var name: String")
	print("    @export var count: int")
	print("    @export var speed: float")
	print("    @export var active: bool")
	print()

	print("  범위 제한:")
	print("    @export_range(0, 100) var hp: int")
	print("    @export_range(0.0, 1.0, 0.05) var ratio: float")
	print("    @export_range(0, 1000, 1, \"suffix:px\") var size: int")
	print()

	print("  열거형:")
	print("    @export_enum(\"A\", \"B\", \"C\") var choice: int")
	print("    @export_enum(\"Walk\", \"Run\", \"Fly\") var mode: String")
	print()

	print("  파일/디렉토리 경로:")
	print("    @export_file(\"*.png,*.jpg\") var image_path: String")
	print("    @export_dir var folder: String")
	print("    @export_global_file var system_file: String")
	print()

	print("  색상/텍스처:")
	print("    @export var color: Color = Color.WHITE")
	print("    @export var texture: Texture2D")
	print("    @export_color_no_alpha var flat_color: Color")
	print()

	print("  컬렉션:")
	print("    @export var items: Array[String]")
	print("    @export var stats: Dictionary")
	print("    @export var positions: PackedVector2Array")
	print()

	print("  그룹/카테고리:")
	print("    @export_group(\"Combat\")")
	print("    @export var attack: int")
	print("    @export var defense: int")
	print("    @export_group(\"Movement\")")
	print("    @export var speed: float")
	print("    @export_subgroup(\"Dash\")")
	print("    @export var dash_speed: float")
	print()

	# -----------------------------------------------------------------
	# 4) 리소스 저장 (ResourceSaver)
	# -----------------------------------------------------------------
	print("--- 4. ResourceSaver로 저장 ---")

	print("  .tres 파일 (텍스트 형식) - 버전 관리에 적합")
	print("  .res 파일 (바이너리 형식) - 용량 작고 빠른 로드")
	print()

	# 실제 저장 시연 (user:// 경로 사용)
	var save_path_tres = "user://test_item.tres"
	var save_path_res = "user://test_item.res"

	var result = ResourceSaver.save(item, save_path_tres)
	print("  .tres 저장 결과: ", _error_to_string(result))
	print("    경로: ", save_path_tres)

	result = ResourceSaver.save(item, save_path_res)
	print("  .res 저장 결과: ", _error_to_string(result))
	print("    경로: ", save_path_res)
	print()

	# ResourceSaver 플래그
	print("  ResourceSaver 플래그:")
	print("    FLAG_RELATIVE_PATHS  - 상대 경로 사용")
	print("    FLAG_BUNDLE_RESOURCES - 하위 리소스 포함")
	print("    FLAG_OMIT_EDITOR_PROPERTIES - 에디터 전용 속성 생략")
	print()

	# -----------------------------------------------------------------
	# 5) 리소스 불러오기 (load / ResourceLoader)
	# -----------------------------------------------------------------
	print("--- 5. 리소스 불러오기 ---")

	# load() 사용
	var loaded_item = load(save_path_tres) as ItemResource
	if loaded_item:
		print("  load() 성공:")
		print("    이름: ", loaded_item.item_name)
		print("    가격: ", loaded_item.price)
		print("    타입: ", loaded_item.item_type)
	else:
		print("  load() 실패 (타입 캐스팅 실패 가능 - 내부 클래스 제한)")
	print()

	# ResourceLoader 사용
	print("  ResourceLoader 사용법:")
	print("    var res = ResourceLoader.load(path, type_hint, cache_mode)")
	print("    # type_hint: 예상 타입 (빈 문자열이면 자동)")
	print("    # cache_mode: 캐시 동작")
	print()

	# ResourceLoader.exists로 존재 확인
	var exists = ResourceLoader.exists(save_path_tres)
	print("  ResourceLoader.exists(\"%s\"): %s" % [save_path_tres, exists])
	print()

	# -----------------------------------------------------------------
	# 6) 리소스 참조 공유와 복제
	# -----------------------------------------------------------------
	print("--- 6. 리소스 참조 공유와 복제 ---")

	# 참조 공유 (같은 객체)
	var item_a = ItemResource.new()
	item_a.item_name = "Sword"
	item_a.price = 500
	var item_b = item_a  # 같은 참조!

	item_b.price = 999
	print("  참조 공유:")
	print("    item_a.price = ", item_a.price, " (item_b 변경이 item_a에 영향)")
	print("    item_b.price = ", item_b.price)
	print("    같은 객체? ", item_a == item_b)
	print()

	# 복제 (독립 복사)
	var item_c = item_a.duplicate() as ItemResource
	if item_c:
		item_c.price = 100
		print("  duplicate() 복제:")
		print("    item_a.price = ", item_a.price, " (변경 안 됨)")
		print("    item_c.price = ", item_c.price, " (독립적)")
		print("    같은 객체? ", item_a == item_c)
	else:
		# 내부 클래스 제한으로 타입 캐스팅 실패할 수 있음
		var item_c_raw = item_a.duplicate()
		print("  duplicate() 결과: ", item_c_raw.get("item_name"))
	print()

	print("  주의: 여러 노드가 같은 리소스를 참조하면")
	print("  하나를 수정 시 모두에게 영향!")
	print("  독립적으로 사용하려면 duplicate() 또는")
	print("  resource_local_to_scene = true 설정")
	print()

	# -----------------------------------------------------------------
	# 7) 실용 예시: 캐릭터 스탯 리소스
	# -----------------------------------------------------------------
	print("--- 7. 실용 예시: 캐릭터 스탯 ---")

	var warrior_stats = CharacterStats.new()
	warrior_stats.character_name = "Warrior"
	warrior_stats.max_hp = 150
	warrior_stats.max_mp = 30
	warrior_stats.attack = 25
	warrior_stats.defense = 20
	warrior_stats.speed = 8.0
	warrior_stats.level = 1
	warrior_stats.experience = 0

	var mage_stats = CharacterStats.new()
	mage_stats.character_name = "Mage"
	mage_stats.max_hp = 80
	mage_stats.max_mp = 120
	mage_stats.attack = 10
	mage_stats.defense = 8
	mage_stats.speed = 6.0
	mage_stats.level = 1
	mage_stats.experience = 0

	print("  캐릭터 스탯 비교:")
	_print_stats_comparison(warrior_stats, mage_stats)
	print()

	# 레벨업 시뮬레이션
	warrior_stats.gain_experience(150)
	print("  Warrior 경험치 150 획득:")
	print("    레벨: %d, 경험치: %d/%d" % [
		warrior_stats.level, warrior_stats.experience,
		warrior_stats.exp_to_next_level()
	])
	print("    HP: %d, ATK: %d, DEF: %d" % [
		warrior_stats.max_hp, warrior_stats.attack, warrior_stats.defense
	])
	print()

	# -----------------------------------------------------------------
	# 8) 실용 예시: 아이템 데이터베이스
	# -----------------------------------------------------------------
	print("--- 8. 아이템 데이터베이스 패턴 ---")

	print("  # item_database.gd (Autoload)")
	print("  # 모든 아이템 리소스를 로드하여 딕셔너리로 관리")
	print()
	print("  var _items: Dictionary = {}  # id -> ItemResource")
	print()
	print("  func _ready():")
	print("      # 폴더의 모든 아이템 리소스 로드")
	print("      var dir = DirAccess.open(\"res://data/items/\")")
	print("      if dir:")
	print("          dir.list_dir_begin()")
	print("          var file = dir.get_next()")
	print("          while file != \"\":")
	print("              if file.ends_with(\".tres\"):")
	print("                  var item = load(\"res://data/items/\" + file)")
	print("                  _items[item.item_id] = item")
	print("              file = dir.get_next()")
	print()
	print("  func get_item(id: String) -> ItemResource:")
	print("      return _items.get(id, null)")
	print()

	# 간단한 데이터베이스 시뮬레이션
	var db: Dictionary = {}
	var potion = ItemResource.new()
	potion.item_name = "Health Potion"
	potion.price = 50
	potion.item_type = ItemResource.ItemType.CONSUMABLE
	db["potion_hp"] = potion

	var sword = ItemResource.new()
	sword.item_name = "Iron Sword"
	sword.price = 300
	sword.item_type = ItemResource.ItemType.WEAPON
	db["sword_iron"] = sword

	print("  시뮬레이션 DB:")
	for id in db:
		var i = db[id] as ItemResource
		print("    [%s] %s - %dG (%s)" % [
			id, i.item_name, i.price,
			ItemResource.ItemType.keys()[i.item_type]
		])
	print()

	# -----------------------------------------------------------------
	# 9) 파일 정리
	# -----------------------------------------------------------------
	print("--- 9. 테스트 파일 정리 ---")

	# 저장한 테스트 파일 삭제
	if FileAccess.file_exists(save_path_tres):
		DirAccess.remove_absolute(save_path_tres)
		print("  삭제: ", save_path_tres)
	if FileAccess.file_exists(save_path_res):
		DirAccess.remove_absolute(save_path_res)
		print("  삭제: ", save_path_res)
	print()

	print("=== 01-custom-resource.gd 완료 ===")


# =============================================================================
# 커스텀 리소스 내부 클래스
# =============================================================================

# 아이템 리소스
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


# 캐릭터 스탯 리소스
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
		return level * 100  # 레벨 * 100 경험치 필요

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


# =============================================================================
# 헬퍼 함수들
# =============================================================================

func _error_to_string(error: Error) -> String:
	if error == OK:
		return "OK (성공)"
	return "Error %d" % error


func _print_stats_comparison(a: CharacterStats, b: CharacterStats):
	print("    +----------+----------+----------+")
	print("    | 스탯     | %-8s | %-8s |" % [a.character_name, b.character_name])
	print("    +----------+----------+----------+")
	print("    | HP       | %8d | %8d |" % [a.max_hp, b.max_hp])
	print("    | MP       | %8d | %8d |" % [a.max_mp, b.max_mp])
	print("    | Attack   | %8d | %8d |" % [a.attack, b.attack])
	print("    | Defense  | %8d | %8d |" % [a.defense, b.defense])
	print("    | Speed    | %8.1f | %8.1f |" % [a.speed, b.speed])
	print("    +----------+----------+----------+")
