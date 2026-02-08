# Chapter 01 - Godot Engine Introduction
# 03-project-structure.gd - Project Structure and File Paths
#
# 이 파일에서 배울 내용:
# - res:// 와 user:// 경로 시스템 이해
# - ResourceLoader를 이용한 리소스 로딩
# - preload()와 load()의 차이점과 사용 시기
# - 프로젝트 디렉토리 구조 권장 사항

extends Node

# ============================================
# 1. Godot 경로 시스템
# ============================================

# preload()는 컴파일 시점에 로드됩니다 (상수처럼 동작)
# 실제 프로젝트에서는 존재하는 리소스 경로를 사용해야 합니다.
# 아래는 문법과 개념 설명을 위한 예시입니다.
#
# const MY_SCENE = preload("res://scenes/player.tscn")
# const MY_TEXTURE = preload("res://assets/sprites/hero.png")
# const MY_SCRIPT = preload("res://scripts/utils.gd")

func _ready():
	print("=== Godot 경로 시스템 ===\n")

	# res:// - 프로젝트 루트 디렉토리를 가리킵니다
	# user:// - 사용자 데이터 디렉토리를 가리킵니다
	print("res:// 경로:")
	print("  프로젝트 루트 폴더를 기준으로 한 경로입니다")
	print("  예: res://scenes/main.tscn")
	print("  예: res://assets/sprites/player.png")
	print("  예: res://scripts/player_controller.gd")

	print("\nuser:// 경로:")
	print("  사용자 앱 데이터 디렉토리입니다")
	print("  세이브 파일, 설정 파일 등을 저장할 때 사용합니다")
	print("  예: user://saves/game_save.json")
	print("  예: user://settings.cfg")

	# 실제 user:// 경로 확인
	var user_path := OS.get_user_data_dir()
	print("\n실제 user:// 위치: ", user_path)

	# ============================================
	# 2. preload() vs load()
	# ============================================
	print("\n=== preload() vs load() ===\n")

	# preload() - 컴파일 시점 로딩
	# - 스크립트가 로드될 때 함께 로드됩니다
	# - 경로가 반드시 상수 문자열이어야 합니다 (변수 불가)
	# - 게임 실행 중 지연(lag)이 없습니다
	# - 작은 리소스에 적합합니다
	print("preload() 특징:")
	print("  - 컴파일 시점에 로드 (즉시 사용 가능)")
	print("  - 경로는 반드시 문자열 리터럴")
	print("  - 변수를 경로로 사용할 수 없음")
	print("  - 빠른 접근이 필요한 작은 리소스에 적합")

	# 사용 예시 (주석 - 실제 파일이 필요합니다):
	# const PLAYER_SCENE = preload("res://scenes/player.tscn")
	# const ICON = preload("res://icon.svg")
	# const BULLET = preload("res://scenes/bullet.tscn")

	print("\nload() 특징:")
	print("  - 런타임(실행 중)에 로드")
	print("  - 변수를 경로로 사용할 수 있음")
	print("  - 큰 리소스나 동적 로딩에 적합")
	print("  - 로딩 시 잠깐의 지연이 있을 수 있음")

	# load() 사용 예시
	var resource_path := "res://icon.svg"
	var resource = load(resource_path)  # 변수로 경로 지정 가능
	if resource:
		print("\n리소스 로드 성공: ", resource)
		print("리소스 타입: ", resource.get_class())
	else:
		print("\n리소스를 찾을 수 없습니다: ", resource_path)

	# ============================================
	# 3. ResourceLoader - 고급 리소스 로딩
	# ============================================
	print("\n=== ResourceLoader ===\n")

	# ResourceLoader는 load()의 기반이 되는 클래스입니다
	# 더 세밀한 제어가 가능합니다

	# 리소스 존재 여부 확인
	var test_path := "res://icon.svg"
	var exists := ResourceLoader.exists(test_path)
	print("리소스 존재 여부 (", test_path, "): ", exists)

	# 리소스 타입 확인
	if exists:
		var loaded_res = ResourceLoader.load(test_path)
		print("로드된 리소스: ", loaded_res)

	# 비동기(백그라운드) 로딩 - 큰 리소스에 유용
	# ResourceLoader.load_threaded_request("res://heavy_resource.tres")
	# var status = ResourceLoader.load_threaded_get_status("res://heavy_resource.tres")
	# if status == ResourceLoader.THREAD_LOAD_LOADED:
	#     var res = ResourceLoader.load_threaded_get("res://heavy_resource.tres")
	print("\n비동기 로딩 메서드:")
	print("  load_threaded_request() - 백그라운드 로딩 시작")
	print("  load_threaded_get_status() - 로딩 상태 확인")
	print("  load_threaded_get() - 로드된 리소스 가져오기")

	# ============================================
	# 4. 파일 읽기/쓰기 (FileAccess)
	# ============================================
	print("\n=== FileAccess - 파일 입출력 ===\n")

	# 파일 쓰기
	var save_path := "user://example_save.txt"
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string("Hello from Godot!\n")
		file.store_string("이것은 테스트 파일입니다.\n")
		file.store_var({"score": 100, "level": 5})
		file.close()
		print("파일 저장 완료: ", save_path)
	else:
		var error := FileAccess.get_open_error()
		print("파일 열기 실패: ", error)

	# 파일 읽기
	if FileAccess.file_exists(save_path):
		file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var line1 := file.get_line()
			var line2 := file.get_line()
			print("읽은 내용 1: ", line1)
			print("읽은 내용 2: ", line2)
			var data = file.get_var()
			print("읽은 데이터: ", data)
			file.close()

	# JSON 파일 저장/불러오기
	print("\nJSON 파일 입출력:")
	var game_data := {
		"player_name": "Hero",
		"score": 9999,
		"inventory": ["sword", "shield", "potion"],
		"position": {"x": 100.5, "y": 200.3}
	}

	# JSON으로 저장
	var json_path := "user://save_data.json"
	var json_string := JSON.stringify(game_data, "\t")  # 보기 좋게 탭 들여쓰기
	file = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("JSON 저장 완료: ", json_path)

	# JSON 불러오기
	if FileAccess.file_exists(json_path):
		file = FileAccess.open(json_path, FileAccess.READ)
		if file:
			var content := file.get_as_text()
			file.close()
			var json := JSON.new()
			var parse_result := json.parse(content)
			if parse_result == OK:
				var loaded_data = json.get_data()
				print("JSON 로드 결과: ", loaded_data)
				print("플레이어 이름: ", loaded_data["player_name"])
				print("점수: ", loaded_data["score"])
			else:
				print("JSON 파싱 에러: ", json.get_error_message())

	# ============================================
	# 5. DirAccess - 디렉토리 관리
	# ============================================
	print("\n=== DirAccess - 디렉토리 관리 ===\n")

	# 디렉토리 생성
	var dir := DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
			print("saves 디렉토리 생성")
		else:
			print("saves 디렉토리가 이미 존재합니다")

		# 디렉토리 내 파일 목록
		print("\nuser:// 디렉토리 내용:")
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("  [폴더] ", file_name)
			else:
				print("  [파일] ", file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	# ============================================
	# 6. 권장 프로젝트 구조
	# ============================================
	print("\n=== 권장 프로젝트 구조 ===\n")

	var structure := """프로젝트 루트 (res://)
├── project.godot          # 프로젝트 설정 파일
├── icon.svg               # 프로젝트 아이콘
│
├── scenes/                # 씬 파일들 (.tscn)
│   ├── main.tscn
│   ├── player/
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── enemies/
│   │   ├── enemy_base.tscn
│   │   └── slime.tscn
│   └── ui/
│       ├── hud.tscn
│       └── main_menu.tscn
│
├── scripts/               # 독립 스크립트
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   └── audio_manager.gd
│   └── utils/
│       └── helpers.gd
│
├── assets/                # 에셋 파일들
│   ├── sprites/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   └── shaders/
│
├── resources/             # 리소스 파일들 (.tres)
│   ├── themes/
│   └── materials/
│
└── addons/                # 플러그인"""

	print(structure)

	# ============================================
	# 7. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. res:// : 프로젝트 루트 경로 (읽기 전용 - 빌드 후)")
	print("2. user:// : 사용자 데이터 경로 (읽기/쓰기 가능)")
	print("3. preload() : 컴파일 시점 로딩 (상수 경로만)")
	print("4. load() : 런타임 로딩 (변수 경로 가능)")
	print("5. FileAccess : 파일 읽기/쓰기")
	print("6. DirAccess : 디렉토리 관리")
	print("7. ResourceLoader : 고급 리소스 로딩 (비동기 포함)")
