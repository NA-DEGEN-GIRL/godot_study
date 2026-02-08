# Chapter 11 - Resources & Data Management
# 03-autoload-singleton.gd - 오토로드(Autoload) 싱글톤 패턴
#
# 이 파일에서 배울 내용:
# - Autoload 등록 방법과 동작 원리
# - 전역 상태(Global State) 관리
# - 시그널 기반 상태 변경 알림
# - 일반적인 Autoload 설계 패턴
# - 여러 Autoload 간 의존성 관리

extends Node

# =============================================================================
# Autoload 기본 개념
# =============================================================================
#
# Autoload = 게임 시작 시 자동으로 로드되어 항상 존재하는 노드
# - 씬 전환 시에도 유지됨
# - 어디서든 이름으로 접근 가능 (예: GameManager.score)
# - 프로젝트 설정 > Autoload 에서 등록
#
# 등록 방법:
#   프로젝트 > 프로젝트 설정 > Autoload 탭
#   경로: res://scripts/game_manager.gd
#   이름: GameManager (대문자 시작 권장)
# =============================================================================

func _ready():
	print("=== Chapter 11-3: Autoload 싱글톤 패턴 ===\n")

	# -----------------------------------------------------------------
	# 1) Autoload 기본 구조
	# -----------------------------------------------------------------
	print("--- 1. Autoload 기본 구조 ---")

	print("  Autoload 노드는 씬 트리의 루트에 추가됩니다:")
	print("    root (Viewport)")
	print("    +-- GameManager  (Autoload)")
	print("    +-- AudioManager (Autoload)")
	print("    +-- SaveManager  (Autoload)")
	print("    +-- CurrentScene (change_scene으로 전환)")
	print()

	print("  접근 방법:")
	print("    # 다른 스크립트에서")
	print("    GameManager.score += 10")
	print("    AudioManager.play_sfx(\"hit\")")
	print("    SaveManager.save_game()")
	print()

	# -----------------------------------------------------------------
	# 2) 전역 게임 상태 관리
	# -----------------------------------------------------------------
	print("--- 2. GameManager 패턴 ---")

	var gm = GameManagerExample.new()

	print("  초기 상태:")
	gm.print_status("    ")
	print()

	# 상태 변경
	gm.add_score(100)
	gm.add_score(250)
	gm.collect_coin()
	gm.collect_coin()
	gm.collect_coin()
	gm.take_damage(30)

	print("  게임 진행 후 상태:")
	gm.print_status("    ")
	print()

	# 게임 오버
	gm.take_damage(200)
	print("  대미지 200 후:")
	gm.print_status("    ")
	print()

	# 리셋
	gm.reset_game()
	print("  리셋 후:")
	gm.print_status("    ")
	print()

	# -----------------------------------------------------------------
	# 3) 시그널 기반 상태 알림
	# -----------------------------------------------------------------
	print("--- 3. 시그널 기반 상태 알림 ---")

	print("  Autoload에서 시그널을 정의하면 전역 이벤트 버스 역할:")
	print()

	# 시그널 연결
	gm.score_changed.connect(func(new_score):
		print("    [시그널] 점수 변경: %d" % new_score)
	)
	gm.hp_changed.connect(func(new_hp):
		print("    [시그널] HP 변경: %d" % new_hp)
	)
	gm.game_over_triggered.connect(func():
		print("    [시그널] 게임 오버!")
	)
	gm.coin_collected.connect(func(total):
		print("    [시그널] 코인 수집! 총 %d개" % total)
	)

	print("  시그널 연결 완료. 상태 변경 테스트:")
	gm.add_score(500)
	gm.collect_coin()
	gm.take_damage(50)
	gm.take_damage(100)  # 게임 오버
	print()

	# -----------------------------------------------------------------
	# 4) 설정 관리 Autoload
	# -----------------------------------------------------------------
	print("--- 4. SettingsManager 패턴 ---")

	var settings = SettingsManagerExample.new()

	print("  기본 설정:")
	settings.print_all("    ")
	print()

	# 설정 변경
	settings.set_setting("audio", "master_volume", 75)
	settings.set_setting("display", "fullscreen", true)
	settings.set_setting("gameplay", "language", "ko")

	print("  변경 후 설정:")
	settings.print_all("    ")
	print()

	# 특정 설정 조회
	var vol = settings.get_setting("audio", "master_volume", 100)
	print("  마스터 볼륨: ", vol)
	var nonexistent = settings.get_setting("audio", "no_such_key", "기본값")
	print("  없는 키 조회: ", nonexistent)
	print()

	# -----------------------------------------------------------------
	# 5) 오디오 매니저 Autoload
	# -----------------------------------------------------------------
	print("--- 5. AudioManager 패턴 ---")

	print("  # AudioManager.gd (Autoload)")
	print("  extends Node")
	print()
	print("  var _bgm_player: AudioStreamPlayer")
	print("  var _sfx_players: Array[AudioStreamPlayer]")
	print("  var _sfx_pool_size: int = 8")
	print("  var _current_bgm: String = \"\"")
	print()
	print("  # 미리 로드된 효과음 캐시")
	print("  var _sfx_cache: Dictionary = {")
	print("      \"jump\": preload(\"res://audio/sfx/jump.wav\"),")
	print("      \"hit\": preload(\"res://audio/sfx/hit.wav\"),")
	print("      \"coin\": preload(\"res://audio/sfx/coin.wav\"),")
	print("  }")
	print()
	print("  func play_bgm(name: String, fade_duration: float = 1.0):")
	print("      # 크로스페이드 BGM 전환")
	print("      pass")
	print()
	print("  func play_sfx(name: String, volume_db: float = 0.0):")
	print("      # 풀에서 사용 가능한 플레이어로 재생")
	print("      if name in _sfx_cache:")
	print("          var player = _get_available_sfx_player()")
	print("          player.stream = _sfx_cache[name]")
	print("          player.volume_db = volume_db")
	print("          player.play()")
	print()

	# -----------------------------------------------------------------
	# 6) Autoload 간 의존성 관리
	# -----------------------------------------------------------------
	print("--- 6. Autoload 간 의존성 관리 ---")

	print("  로드 순서:")
	print("    Autoload는 등록 순서대로 초기화됩니다.")
	print("    프로젝트 설정에서 순서를 드래그로 변경 가능")
	print()

	print("  권장 순서:")
	print("    1. EventBus    (다른 모든 것이 구독)")
	print("    2. GameManager (핵심 게임 상태)")
	print("    3. SaveManager (GameManager에 의존)")
	print("    4. AudioManager (독립적)")
	print("    5. SceneManager (다른 매니저에 의존 가능)")
	print()

	print("  의존성 해결 방법:")
	print("    방법 1: _ready()에서 참조 (가장 일반적)")
	print("      func _ready():")
	print("          # 다른 Autoload가 이미 존재함을 가정")
	print("          GameManager.score_changed.connect(_on_score_changed)")
	print()
	print("    방법 2: call_deferred로 지연 초기화")
	print("      func _ready():")
	print("          call_deferred(\"_deferred_init\")")
	print("      func _deferred_init():")
	print("          # 모든 Autoload가 _ready() 완료 후 실행")
	print()

	# -----------------------------------------------------------------
	# 7) Autoload로 씬 전환 관리
	# -----------------------------------------------------------------
	print("--- 7. Autoload 씬 전환 관리 ---")

	print("  씬 전환 시 Autoload가 유용한 이유:")
	print("    - 씬이 바뀌어도 상태 유지 (점수, HP 등)")
	print("    - 씬 간 데이터 전달 매개체 역할")
	print("    - 페이드 전환 등 UI 효과 관리")
	print()

	print("  패턴: Autoload에 임시 데이터 저장")
	print("    # SceneManager.gd")
	print("    var transition_data: Dictionary = {}")
	print()
	print("    func goto_scene(path: String, data: Dictionary = {}):")
	print("        transition_data = data")
	print("        # 페이드 아웃")
	print("        await _fade_out()")
	print("        get_tree().change_scene_to_file(path)")
	print("        await get_tree().process_frame")
	print("        # 페이드 인")
	print("        await _fade_in()")
	print()
	print("    # 새 씬에서")
	print("    func _ready():")
	print("        var data = SceneManager.transition_data")
	print("        if data.has(\"player_name\"):")
	print("            setup_player(data[\"player_name\"])")
	print()

	# -----------------------------------------------------------------
	# 8) Autoload vs static 변수
	# -----------------------------------------------------------------
	print("--- 8. Autoload vs static 변수 ---")

	print("  Godot 4에서 static 변수도 전역 상태로 사용 가능:")
	print()
	print("  # Static 변수 방식")
	print("  class_name GlobalData")
	print("  static var score: int = 0")
	print("  static var player_name: String = \"\"")
	print()
	print("  # 사용: GlobalData.score += 10")
	print()

	print("  비교:")
	print("  +------------------+------------------+------------------+")
	print("  | 특성             | Autoload         | static 변수      |")
	print("  +------------------+------------------+------------------+")
	print("  | 노드 기능        | O (process 등)   | X                |")
	print("  | 시그널 발생      | O                | X (직접 불가)    |")
	print("  | 씬 트리 접근     | O                | X                |")
	print("  | 에디터 표시      | O (씬 트리)      | X                |")
	print("  | 초기화 시점      | 자동 (_ready)    | 첫 참조 시       |")
	print("  | 적합한 용도      | 복잡한 매니저    | 단순 데이터      |")
	print("  +------------------+------------------+------------------+")
	print()

	# -----------------------------------------------------------------
	# 9) Autoload 주의사항
	# -----------------------------------------------------------------
	print("--- 9. Autoload 주의사항 ---")

	print("  1. 너무 많은 Autoload는 피하세요")
	print("     - 3~5개 정도가 적당")
	print("     - 모든 것을 전역으로 만들면 결합도 증가")
	print()
	print("  2. 순환 참조 주의")
	print("     - A가 B를 참조하고, B가 A를 참조하면 문제")
	print("     - EventBus 패턴으로 간접 통신 권장")
	print()
	print("  3. 메모리 관리")
	print("     - Autoload는 게임 내내 메모리에 존재")
	print("     - 큰 데이터는 필요할 때만 로드")
	print()
	print("  4. 테스트 어려움")
	print("     - 전역 상태는 단위 테스트를 어렵게 함")
	print("     - 가능하면 의존성 주입 패턴 고려")
	print()

	# -----------------------------------------------------------------
	# 10) 정리: 일반적인 Autoload 구성
	# -----------------------------------------------------------------
	print("--- 10. 일반적인 프로젝트 Autoload 구성 ---")

	print("  소규모 프로젝트:")
	print("    GameManager  - 게임 상태 + 오디오 + 저장")
	print()
	print("  중규모 프로젝트:")
	print("    GameManager   - 핵심 게임 상태")
	print("    AudioManager  - 오디오 재생")
	print("    SaveManager   - 저장/불러오기")
	print("    SceneManager  - 씬 전환 + 페이드")
	print()
	print("  대규모 프로젝트:")
	print("    EventBus      - 전역 시그널")
	print("    GameManager   - 게임 상태")
	print("    AudioManager  - 오디오")
	print("    SaveManager   - 저장")
	print("    SceneManager  - 씬 전환")
	print("    UIManager     - UI 레이어 관리")
	print("    NetworkManager - 멀티플레이어")
	print()

	print("=== 03-autoload-singleton.gd 완료 ===")


# =============================================================================
# 예시 클래스: GameManager
# =============================================================================

class GameManagerExample:
	# 시그널 정의
	signal score_changed(new_score: int)
	signal hp_changed(new_hp: int)
	signal game_over_triggered
	signal coin_collected(total_coins: int)

	# 게임 상태
	var score: int = 0
	var high_score: int = 0
	var coins: int = 0
	var hp: int = 100
	var max_hp: int = 100
	var is_game_over: bool = false
	var current_level: int = 1

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
		current_level = 1

	func print_status(indent: String = ""):
		print("%sscore=%d, coins=%d, hp=%d/%d, game_over=%s" % [
			indent, score, coins, hp, max_hp, is_game_over
		])


# =============================================================================
# 예시 클래스: SettingsManager
# =============================================================================

class SettingsManagerExample:
	var _settings: Dictionary = {}
	var _defaults: Dictionary = {
		"audio": {
			"master_volume": 100,
			"bgm_volume": 80,
			"sfx_volume": 100,
			"mute": false,
		},
		"display": {
			"fullscreen": false,
			"vsync": true,
			"resolution": Vector2i(1280, 720),
		},
		"gameplay": {
			"difficulty": "normal",
			"language": "en",
			"show_tutorial": true,
		}
	}

	func _init():
		# 기본값으로 초기화
		_settings = _defaults.duplicate(true)

	func get_setting(section: String, key: String, default_value = null):
		if _settings.has(section) and _settings[section].has(key):
			return _settings[section][key]
		return default_value

	func set_setting(section: String, key: String, value):
		if not _settings.has(section):
			_settings[section] = {}
		_settings[section][key] = value

	func reset_to_defaults():
		_settings = _defaults.duplicate(true)

	func print_all(indent: String = ""):
		for section in _settings:
			print("%s[%s]" % [indent, section])
			for key in _settings[section]:
				print("%s  %s = %s" % [indent, key, _settings[section][key]])
