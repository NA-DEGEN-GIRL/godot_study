# Chapter 11 - Resources & Data Management
# 02-file-io.gd - 파일 입출력과 데이터 관리
#
# 이 파일에서 배울 내용:
# - FileAccess를 사용한 텍스트/바이너리 파일 읽기/쓰기
# - JSON 데이터 저장 및 불러오기
# - ConfigFile을 활용한 설정 관리
# - user:// 경로와 res:// 경로 차이
# - DirAccess를 사용한 디렉토리 관리

extends Node

func _ready():
	print("=== Chapter 11-2: 파일 입출력과 데이터 관리 ===\n")

	# -----------------------------------------------------------------
	# 1) Godot 파일 경로 시스템
	# -----------------------------------------------------------------
	print("--- 1. 파일 경로 시스템 ---")

	print("  res:// - 프로젝트 리소스 경로")
	print("    - 프로젝트 폴더의 루트")
	print("    - 내보내기 후에는 읽기 전용")
	print("    - 예: res://scenes/main.tscn")
	print()

	print("  user:// - 사용자 데이터 경로")
	print("    - 쓰기 가능한 영역")
	print("    - 세이브 파일, 설정, 로그 등에 사용")
	print("    - 실제 경로 (OS별):")

	# 실제 user:// 경로 확인
	var user_path = OS.get_user_data_dir()
	print("      현재: ", user_path)
	print("    - Windows: %APPDATA%\\Godot\\app_userdata\\프로젝트이름")
	print("    - macOS: ~/Library/Application Support/Godot/app_userdata/")
	print("    - Linux: ~/.local/share/godot/app_userdata/")
	print()

	# -----------------------------------------------------------------
	# 2) FileAccess - 텍스트 파일 쓰기
	# -----------------------------------------------------------------
	print("--- 2. FileAccess - 텍스트 파일 쓰기 ---")

	var txt_path = "user://test_output.txt"

	# 파일 쓰기
	var file = FileAccess.open(txt_path, FileAccess.WRITE)
	if file:
		file.store_string("Hello, Godot!\n")
		file.store_string("GDScript 파일 입출력 테스트\n")
		file.store_string("라인 3\n")
		file.store_line("store_line은 자동 줄바꿈")
		file.store_csv_line(PackedStringArray(["이름", "레벨", "HP"]))
		file.store_csv_line(PackedStringArray(["전사", "10", "150"]))
		file.store_csv_line(PackedStringArray(["마법사", "8", "80"]))
		file.close()  # Godot 4에서는 scope 벗어나면 자동 close
		print("  텍스트 파일 저장 완료: ", txt_path)
	else:
		print("  파일 열기 실패: ", FileAccess.get_open_error())
	print()

	# -----------------------------------------------------------------
	# 3) FileAccess - 텍스트 파일 읽기
	# -----------------------------------------------------------------
	print("--- 3. FileAccess - 텍스트 파일 읽기 ---")

	# 전체 읽기
	file = FileAccess.open(txt_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		print("  전체 내용:")
		for line in content.split("\n"):
			if line.length() > 0:
				print("    | ", line)
		file.close()
	print()

	# 줄 단위 읽기
	file = FileAccess.open(txt_path, FileAccess.READ)
	if file:
		print("  줄 단위 읽기:")
		var line_num = 1
		while not file.eof_reached():
			var line = file.get_line()
			if line.length() > 0:
				print("    %d: %s" % [line_num, line])
				line_num += 1
		file.close()
	print()

	# CSV 읽기
	file = FileAccess.open(txt_path, FileAccess.READ)
	if file:
		# 앞의 텍스트 줄 건너뛰기
		for i in range(4):
			file.get_line()
		print("  CSV 데이터 읽기:")
		while not file.eof_reached():
			var csv_line = file.get_csv_line()
			if csv_line.size() > 1:
				print("    ", csv_line)
		file.close()
	print()

	# -----------------------------------------------------------------
	# 4) JSON 저장/불러오기
	# -----------------------------------------------------------------
	print("--- 4. JSON 데이터 관리 ---")

	var json_path = "user://game_data.json"

	# 저장할 데이터
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
		"save_date": Time.get_datetime_string_from_system()
	}

	# JSON으로 저장
	var json_string = JSON.stringify(game_data, "\t")  # 탭으로 포맷팅
	file = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("  JSON 저장 완료: ", json_path)
		# 파일 크기 확인
		print("  파일 크기: ", FileAccess.get_file_as_string(json_path).length(), " bytes")
	print()

	# JSON 불러오기
	print("  JSON 불러오기:")
	file = FileAccess.open(json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result == OK:
			var loaded_data = json.data
			print("    파싱 성공!")
			print("    플레이어: %s (Lv.%d)" % [
				loaded_data["player"]["name"],
				loaded_data["player"]["level"]
			])
			print("    위치: (%s, %s)" % [
				loaded_data["player"]["position"]["x"],
				loaded_data["player"]["position"]["y"]
			])
			print("    인벤토리: ", loaded_data["player"]["inventory"])
			print("    난이도: ", loaded_data["settings"]["difficulty"])
			print("    저장 시간: ", loaded_data["save_date"])
		else:
			print("    파싱 실패! 줄 %d: %s" % [json.get_error_line(), json.get_error_message()])
	print()

	# 간편한 JSON 불러오기 (FileAccess.get_file_as_string 활용)
	print("  간편한 JSON 불러오기:")
	print("    var text = FileAccess.get_file_as_string(path)")
	print("    var data = JSON.parse_string(text)  # 바로 Dictionary 반환")
	var quick_data = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if quick_data:
		print("    결과: ", quick_data["player"]["name"])
	print()

	# -----------------------------------------------------------------
	# 5) ConfigFile - INI 스타일 설정
	# -----------------------------------------------------------------
	print("--- 5. ConfigFile 설정 관리 ---")

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
	config.set_value("gameplay", "show_tutorial", true)

	var save_err = config.save(config_path)
	print("  설정 저장: ", "성공" if save_err == OK else "실패")
	print("    경로: ", config_path)
	print()

	# 설정 읽기
	var load_config = ConfigFile.new()
	var load_err = load_config.load(config_path)

	if load_err == OK:
		print("  설정 읽기:")

		# 섹션 목록
		var sections = load_config.get_sections()
		print("    섹션: ", sections)
		print()

		# 각 섹션의 키-값
		for section in sections:
			print("    [%s]" % section)
			var keys = load_config.get_section_keys(section)
			for key in keys:
				var value = load_config.get_value(section, key)
				print("      %s = %s (%s)" % [key, value, typeof(value)])
			print()

		# 기본값과 함께 읽기 (키가 없을 때 안전)
		var vol = load_config.get_value("audio", "master_volume", 100)
		var missing = load_config.get_value("audio", "nonexistent_key", "기본값")
		print("    존재하는 키: master_volume = ", vol)
		print("    없는 키 (기본값): ", missing)
	print()

	# -----------------------------------------------------------------
	# 6) FileAccess - 바이너리 파일
	# -----------------------------------------------------------------
	print("--- 6. 바이너리 파일 읽기/쓰기 ---")

	var bin_path = "user://binary_data.bin"

	# 바이너리 쓰기
	file = FileAccess.open(bin_path, FileAccess.WRITE)
	if file:
		file.store_8(255)           # 1바이트 (0-255)
		file.store_16(65535)        # 2바이트
		file.store_32(12345678)     # 4바이트
		file.store_64(9876543210)   # 8바이트
		file.store_float(3.14)      # 4바이트 float
		file.store_double(2.71828)  # 8바이트 double
		file.store_pascal_string("Hello Binary!")  # 길이 + 문자열
		file.store_var({"key": "value", "num": 42})  # Variant
		file.close()
		print("  바이너리 파일 저장 완료")
	print()

	# 바이너리 읽기
	file = FileAccess.open(bin_path, FileAccess.READ)
	if file:
		print("  바이너리 파일 읽기:")
		print("    8bit:  ", file.get_8())
		print("    16bit: ", file.get_16())
		print("    32bit: ", file.get_32())
		print("    64bit: ", file.get_64())
		print("    float: ", file.get_float())
		print("    double:", file.get_double())
		print("    string:", file.get_pascal_string())
		print("    var:   ", file.get_var())
		file.close()
	print()

	# -----------------------------------------------------------------
	# 7) DirAccess - 디렉토리 관리
	# -----------------------------------------------------------------
	print("--- 7. DirAccess 디렉토리 관리 ---")

	# 디렉토리 생성
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("test_folder"):
			dir.make_dir("test_folder")
			print("  디렉토리 생성: user://test_folder")
		else:
			print("  디렉토리 존재: user://test_folder")

		# 중첩 디렉토리 생성
		dir.make_dir_recursive("test_folder/sub1/sub2")
		print("  중첩 디렉토리 생성: user://test_folder/sub1/sub2")
	print()

	# 디렉토리 내용 나열
	dir = DirAccess.open("user://")
	if dir:
		print("  user:// 디렉토리 내용:")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var is_dir = dir.current_is_dir()
			var type_str = "[DIR]" if is_dir else "[FILE]"
			print("    %s %s" % [type_str, file_name])
			file_name = dir.get_next()
		dir.list_dir_end()
	print()

	# 파일 존재 확인
	print("  파일 존재 확인:")
	print("    FileAccess.file_exists(\"%s\"): %s" % [
		json_path, FileAccess.file_exists(json_path)])
	print("    DirAccess.dir_exists_absolute(\"user://test_folder\"): %s" % [
		DirAccess.dir_exists_absolute("user://test_folder")])
	print()

	# -----------------------------------------------------------------
	# 8) 파일 유틸리티 함수 모음
	# -----------------------------------------------------------------
	print("--- 8. 유용한 파일 유틸리티 ---")

	# MD5 / SHA256 해시
	print("  파일 해시 (무결성 확인):")
	var md5 = FileAccess.get_md5(json_path)
	var sha256 = FileAccess.get_sha256(json_path)
	print("    MD5:    ", md5)
	print("    SHA256: ", sha256.substr(0, 32), "...")
	print()

	# 파일 수정 시간
	print("  파일 수정 시간:")
	var mod_time = FileAccess.get_modified_time(json_path)
	print("    Unix timestamp: ", mod_time)
	var datetime = Time.get_datetime_dict_from_unix_time(mod_time)
	print("    날짜: %d-%02d-%02d %02d:%02d:%02d" % [
		datetime["year"], datetime["month"], datetime["day"],
		datetime["hour"], datetime["minute"], datetime["second"]
	])
	print()

	# -----------------------------------------------------------------
	# 9) 암호화된 파일 접근
	# -----------------------------------------------------------------
	print("--- 9. 암호화된 파일 ---")

	var encrypted_path = "user://encrypted_data.sav"
	var encryption_key = "my_secret_key_12345"

	# 암호화하여 저장
	file = FileAccess.open_encrypted_with_pass(
		encrypted_path, FileAccess.WRITE, encryption_key)
	if file:
		var secret_data = {"coins": 9999, "level": 50, "items": ["legendary_sword"]}
		file.store_string(JSON.stringify(secret_data))
		file.close()
		print("  암호화 저장 완료: ", encrypted_path)
	print()

	# 암호화된 파일 읽기
	file = FileAccess.open_encrypted_with_pass(
		encrypted_path, FileAccess.READ, encryption_key)
	if file:
		var decrypted = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(decrypted)
		print("  복호화 읽기: ", parsed)
	print()

	# 잘못된 키로 시도
	file = FileAccess.open_encrypted_with_pass(
		encrypted_path, FileAccess.READ, "wrong_key")
	if file == null:
		print("  잘못된 키: 파일 열기 실패 (정상)")
	else:
		file.close()
	print()

	# -----------------------------------------------------------------
	# 10) 정리: 테스트 파일 삭제
	# -----------------------------------------------------------------
	print("--- 10. 테스트 파일 정리 ---")

	var files_to_clean = [txt_path, json_path, config_path, bin_path, encrypted_path]
	for f_path in files_to_clean:
		if FileAccess.file_exists(f_path):
			DirAccess.remove_absolute(f_path)
			print("  삭제: ", f_path)

	# 테스트 폴더 삭제
	if DirAccess.dir_exists_absolute("user://test_folder/sub1/sub2"):
		DirAccess.remove_absolute("user://test_folder/sub1/sub2")
	if DirAccess.dir_exists_absolute("user://test_folder/sub1"):
		DirAccess.remove_absolute("user://test_folder/sub1")
	if DirAccess.dir_exists_absolute("user://test_folder"):
		DirAccess.remove_absolute("user://test_folder")
		print("  삭제: user://test_folder (및 하위)")
	print()

	print("=== 02-file-io.gd 완료 ===")
