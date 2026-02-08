# Chapter 10 - TileMap & Level Design
# 02-scene-transition.gd - 씬 전환과 페이드 효과
#
# 이 파일에서 배울 내용:
# - SceneTree.change_scene_to_file() 기본 전환
# - SceneTree.change_scene_to_packed() 프리로드 전환
# - ColorRect + Tween으로 페이드 인/아웃 전환
# - 전환 중 데이터 전달 패턴
# - 로딩 화면 구현 원리

extends Node

# =============================================================================
# 씬 전환 매니저 예시
# =============================================================================

# 현재 씬 경로 (테스트용)
var current_scene_path: String = "res://scenes/main_menu.tscn"

func _ready():
	print("=== Chapter 10-2: 씬 전환과 페이드 효과 ===\n")

	# -----------------------------------------------------------------
	# 1) 기본 씬 전환 - change_scene_to_file
	# -----------------------------------------------------------------
	print("--- 1. 기본 씬 전환 ---")

	print("  get_tree().change_scene_to_file(path)")
	print("    - 현재 씬을 제거하고 새 씬을 로드/인스턴스화")
	print("    - 동기 방식 (로딩 중 프리즈 발생 가능)")
	print()

	print("  사용 예시:")
	print("    # 메인 메뉴로 이동")
	print("    get_tree().change_scene_to_file(\"res://scenes/main_menu.tscn\")")
	print()
	print("    # 게임 레벨로 이동")
	print("    get_tree().change_scene_to_file(\"res://scenes/levels/level_01.tscn\")")
	print()

	# 반환값 확인
	print("  반환값: Error 타입")
	print("    OK (0)         - 성공")
	print("    ERR_CANT_OPEN  - 파일을 열 수 없음")
	print("    ERR_CANT_CREATE - 인스턴스화 실패")
	print()

	# -----------------------------------------------------------------
	# 2) 프리로드 씬 전환 - change_scene_to_packed
	# -----------------------------------------------------------------
	print("--- 2. 프리로드 씬 전환 ---")

	print("  var packed_scene = preload(\"res://scenes/level_01.tscn\")")
	print("  get_tree().change_scene_to_packed(packed_scene)")
	print()

	print("  preload vs load:")
	print("    preload() - 컴파일 시 로드 (상수 경로만 가능)")
	print("    load()    - 런타임에 로드 (변수 경로 가능)")
	print()

	print("  활용 패턴:")
	print("    # 자주 사용하는 씬은 미리 로드")
	print("    const MAIN_MENU = preload(\"res://scenes/main_menu.tscn\")")
	print("    const GAME_OVER = preload(\"res://scenes/game_over.tscn\")")
	print()
	print("    func go_to_main_menu():")
	print("        get_tree().change_scene_to_packed(MAIN_MENU)")
	print()

	# -----------------------------------------------------------------
	# 3) 씬 전환 타이밍 이해
	# -----------------------------------------------------------------
	print("--- 3. 씬 전환 타이밍 ---")

	print("  change_scene은 '즉시' 전환되지 않습니다:")
	print("    1. change_scene 호출")
	print("    2. 현재 프레임의 나머지 코드 계속 실행")
	print("    3. 현재 프레임 끝에서 실제 전환 발생")
	print("    4. 이전 씬 queue_free() -> 새 씬 add_child()")
	print()

	print("  주의사항:")
	print("    - change_scene 후 코드가 계속 실행될 수 있음")
	print("    - 전환 직후 return 사용 권장")
	print()

	print("  예시:")
	print("    func _on_start_button_pressed():")
	print("        get_tree().change_scene_to_file(\"res://game.tscn\")")
	print("        return  # 이후 코드 실행 방지")
	print()

	# -----------------------------------------------------------------
	# 4) 수동 씬 전환 (더 세밀한 제어)
	# -----------------------------------------------------------------
	print("--- 4. 수동 씬 전환 ---")

	print("  get_tree().change_scene 대신 직접 제어:")
	print()
	print("  func change_scene_manual(scene_path: String):")
	print("      # 1. 새 씬 로드")
	print("      var new_scene = load(scene_path) as PackedScene")
	print("      if not new_scene:")
	print("          push_error(\"씬 로드 실패: \" + scene_path)")
	print("          return")
	print()
	print("      # 2. 현재 씬 제거")
	print("      var current = get_tree().current_scene")
	print("      current.queue_free()")
	print()
	print("      # 3. 새 씬 인스턴스화")
	print("      var instance = new_scene.instantiate()")
	print()
	print("      # 4. 씬 트리에 추가")
	print("      get_tree().root.add_child(instance)")
	print("      get_tree().current_scene = instance")
	print()

	# -----------------------------------------------------------------
	# 5) 페이드 전환 - ColorRect + Tween
	# -----------------------------------------------------------------
	print("--- 5. 페이드 전환 구현 ---")

	print("  페이드 전환 원리:")
	print("    1. 화면 전체를 덮는 ColorRect (CanvasLayer 위)")
	print("    2. Tween으로 alpha 0 -> 1 (페이드 아웃)")
	print("    3. 씬 전환 실행")
	print("    4. Tween으로 alpha 1 -> 0 (페이드 인)")
	print()

	# 실제 페이드 구조 생성
	var fade_layer = _create_fade_overlay()
	print("  페이드 오버레이 생성 완료")
	print()

	# 페이드 시뮬레이션
	print("  페이드 아웃 시뮬레이션 (0.5초):")
	_simulate_fade("out", 0.5)
	print()

	print("  페이드 인 시뮬레이션 (0.5초):")
	_simulate_fade("in", 0.5)
	print()

	# 전체 코드 표시
	print("  전체 페이드 전환 코드:")
	print("    var fade_rect: ColorRect")
	print()
	print("    func fade_to_scene(scene_path: String, duration: float = 0.5):")
	print("        # 페이드 아웃")
	print("        var tween = create_tween()")
	print("        tween.tween_property(fade_rect, \"color:a\", 1.0, duration)")
	print("        await tween.finished")
	print()
	print("        # 씬 전환")
	print("        get_tree().change_scene_to_file(scene_path)")
	print()
	print("        # 한 프레임 대기 (새 씬 로드 완료)")
	print("        await get_tree().process_frame")
	print()
	print("        # 페이드 인")
	print("        var tween2 = create_tween()")
	print("        tween2.tween_property(fade_rect, \"color:a\", 0.0, duration)")
	print("        await tween2.finished")
	print()

	# -----------------------------------------------------------------
	# 6) 다양한 전환 효과
	# -----------------------------------------------------------------
	print("--- 6. 다양한 전환 효과 ---")

	print("  a) 색상 페이드:")
	print("     검정(Color.BLACK) - 일반적인 씬 전환")
	print("     흰색(Color.WHITE) - 밝은/몽환적 전환")
	print("     사용자 정의 색상 - 분위기에 맞게")
	print()

	print("  b) 슬라이드 전환:")
	print("     func slide_transition(direction: Vector2):")
	print("         var tween = create_tween()")
	print("         # 새 씬을 화면 밖에서 슬라이드 인")
	print("         tween.tween_property(new_scene, \"position\",")
	print("             Vector2.ZERO, 0.5).from(direction * get_viewport().size)")
	print()

	print("  c) 셰이더 기반 전환 (디졸브, 원형 등):")
	print("     ColorRect에 ShaderMaterial 적용")
	print("     uniform float progress : hint_range(0, 1)")
	print("     Tween으로 progress 값 변경")
	print()

	# -----------------------------------------------------------------
	# 7) 씬 간 데이터 전달
	# -----------------------------------------------------------------
	print("--- 7. 씬 간 데이터 전달 ---")

	print("  방법 1: Autoload (싱글톤) 사용 - 가장 일반적")
	print("    # GameData.gd (Autoload 등록)")
	print("    var selected_level: int = 0")
	print("    var player_data: Dictionary = {}")
	print()
	print("    # 전환 전")
	print("    GameData.selected_level = 3")
	print("    get_tree().change_scene_to_file(\"res://game.tscn\")")
	print()
	print("    # 새 씬에서")
	print("    func _ready():")
	print("        var level = GameData.selected_level  # 3")
	print()

	print("  방법 2: 수동 전환 시 직접 전달")
	print("    func change_with_data(path, data):")
	print("        var scene = load(path).instantiate()")
	print("        scene.init_data = data  # 씬의 변수에 직접 설정")
	print("        get_tree().root.add_child(scene)")
	print()

	print("  방법 3: Meta 데이터 활용")
	print("    # 전환 전")
	print("    get_tree().root.set_meta(\"level_data\", {\"id\": 3})")
	print("    # 새 씬에서")
	print("    var data = get_tree().root.get_meta(\"level_data\")")
	print()

	# -----------------------------------------------------------------
	# 8) 비동기 로딩 (ResourceLoader)
	# -----------------------------------------------------------------
	print("--- 8. 비동기 로딩 ---")

	print("  큰 씬은 동기 로딩 시 프리즈 발생")
	print("  ResourceLoader를 사용한 비동기 로딩:")
	print()
	print("  func load_scene_async(path: String):")
	print("      # 1. 로딩 요청")
	print("      ResourceLoader.load_threaded_request(path)")
	print()
	print("      # 2. 로딩 상태 확인 (매 프레임)")
	print("      while true:")
	print("          var progress = []")
	print("          var status = ResourceLoader.load_threaded_get_status(path, progress)")
	print()
	print("          match status:")
	print("              ResourceLoader.THREAD_LOAD_IN_PROGRESS:")
	print("                  update_loading_bar(progress[0])  # 0.0 ~ 1.0")
	print("                  await get_tree().process_frame")
	print("              ResourceLoader.THREAD_LOAD_LOADED:")
	print("                  var scene = ResourceLoader.load_threaded_get(path)")
	print("                  get_tree().change_scene_to_packed(scene)")
	print("                  return")
	print("              ResourceLoader.THREAD_LOAD_FAILED:")
	print("                  push_error(\"로딩 실패\")")
	print("                  return")
	print()

	# -----------------------------------------------------------------
	# 9) 씬 전환 매니저 완성 패턴
	# -----------------------------------------------------------------
	print("--- 9. 씬 전환 매니저 (Autoload 패턴) ---")

	print("  # SceneManager.gd - Autoload로 등록")
	print("  extends CanvasLayer")
	print()
	print("  var _fade_rect: ColorRect")
	print("  var _is_transitioning: bool = false")
	print()
	print("  func _ready():")
	print("      layer = 100  # 최상위 레이어")
	print("      _fade_rect = ColorRect.new()")
	print("      _fade_rect.color = Color(0, 0, 0, 0)")
	print("      _fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)")
	print("      _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE")
	print("      add_child(_fade_rect)")
	print()
	print("  func change_scene(path: String, fade_duration := 0.5):")
	print("      if _is_transitioning: return")
	print("      _is_transitioning = true")
	print()
	print("      # 페이드 아웃")
	print("      var tween = create_tween()")
	print("      tween.tween_property(_fade_rect, \"color:a\", 1.0, fade_duration)")
	print("      await tween.finished")
	print()
	print("      # 전환")
	print("      get_tree().change_scene_to_file(path)")
	print("      await get_tree().process_frame")
	print()
	print("      # 페이드 인")
	print("      var tween2 = create_tween()")
	print("      tween2.tween_property(_fade_rect, \"color:a\", 0.0, fade_duration)")
	print("      await tween2.finished")
	print()
	print("      _is_transitioning = false")
	print()

	# -----------------------------------------------------------------
	# 10) 요약
	# -----------------------------------------------------------------
	print("--- 10. 씬 전환 방법 요약 ---")

	print("  +----------------------------+---------------------------+")
	print("  | 방법                       | 적합한 상황               |")
	print("  +----------------------------+---------------------------+")
	print("  | change_scene_to_file       | 간단한 전환               |")
	print("  | change_scene_to_packed     | 미리 로드된 씬            |")
	print("  | 수동 전환                  | 세밀한 제어 필요          |")
	print("  | 페이드 전환               | 부드러운 연출              |")
	print("  | 비동기 로딩               | 대규모 씬 (로딩 화면)     |")
	print("  +----------------------------+---------------------------+")
	print()

	# 정리
	fade_layer.queue_free()

	print("=== 02-scene-transition.gd 완료 ===")


# =============================================================================
# 헬퍼 함수들
# =============================================================================

# 페이드 오버레이 생성
func _create_fade_overlay() -> CanvasLayer:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # 최상위

	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)  # 검정, 투명
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 클릭 무시

	canvas_layer.add_child(color_rect)
	add_child(canvas_layer)

	return canvas_layer


# 페이드 시뮬레이션
func _simulate_fade(direction: String, duration: float):
	var steps = 5
	for i in range(steps + 1):
		var t = float(i) / steps
		var alpha: float
		if direction == "out":
			alpha = t  # 0 -> 1
		else:
			alpha = 1.0 - t  # 1 -> 0
		var time_at = t * duration
		print("    t=%.2fs: alpha=%.2f %s" % [
			time_at, alpha,
			"(투명)" if alpha < 0.01 else "(불투명)" if alpha > 0.99 else ""
		])
