# Chapter 07 - UI System
# 03-theme-system.gd - 테마(Theme) 시스템
#
# 이 파일에서 배울 내용:
# - Theme 리소스의 구조와 적용 방법
# - StyleBoxFlat으로 커스텀 UI 스타일
# - 테마 색상, 폰트, 상수 오버라이드
# - 코드로 테마 생성 및 적용
# - 다크/라이트 모드 전환 패턴
#
# 테마는 UI의 시각적 스타일을 일괄 관리하는 시스템입니다.
# CSS처럼 한 곳에서 전체 UI 스타일을 제어할 수 있습니다.

extends Control

# ============================================
# 1. Theme 시스템 개요
# ============================================
# Theme = CSS와 비슷한 역할
# - 색상 (Color)
# - 폰트 (Font)
# - 폰트 크기 (Font Size)
# - 아이콘 (Icon/Texture)
# - 상수 (Constant - 여백, 간격 등)
# - 스타일박스 (StyleBox - 배경, 테두리 등)
#
# 적용 우선순위 (높은 것이 우선):
# 1. 노드 개별 오버라이드 (add_theme_*_override)
# 2. 노드의 theme 속성
# 3. 부모 노드의 theme (상속)
# 4. 프로젝트 기본 테마 (Project Settings)
# 5. Godot 기본 테마

var current_theme: Theme
var is_dark_mode: bool = true

func _ready():
	print("=== Chapter 07-3: 테마(Theme) 시스템 ===\n")

	_demonstrate_individual_override()
	_demonstrate_stylebox_flat()
	_demonstrate_create_theme()
	_demonstrate_apply_theme()
	_demonstrate_button_states()
	_demonstrate_theme_inheritance()
	_practical_dark_light_theme()
	_practical_game_theme()

# ============================================
# 2. 개별 오버라이드 (가장 간단한 방법)
# ============================================

func _demonstrate_individual_override():
	print("--- 2. 개별 오버라이드 ---")

	var label = Label.new()
	label.text = "스타일 오버라이드 테스트"
	label.position = Vector2(20, 20)
	add_child(label)

	# 색상 오버라이드
	print("[add_theme_color_override]")
	label.add_theme_color_override("font_color", Color.CYAN)
	print("  font_color -> CYAN")

	# 폰트 크기 오버라이드
	print("\n[add_theme_font_size_override]")
	label.add_theme_font_size_override("font_size", 20)
	print("  font_size -> 20")

	# 상수 오버라이드
	print("\n[add_theme_constant_override]")
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	print("  outline_size -> 2, outline_color -> BLACK")

	# 오버라이드 제거
	print("\n[remove_theme_*_override]")
	print("  label.remove_theme_color_override('font_color')")
	print("  -> 오버라이드 제거하면 부모/테마 값으로 복원")

	# 오버라이드 확인
	print("\n[has_theme_*_override]")
	print("  label.has_theme_color_override('font_color'): %s" %
		str(label.has_theme_color_override("font_color")))

	# 현재 테마값 가져오기
	print("\n[get_theme_*]")
	print("  get_theme_color('font_color', 'Label')")
	print("  get_theme_font_size('font_size', 'Label')")

	# 각 노드 타입별 사용 가능한 오버라이드
	print("\n[노드별 주요 오버라이드 키]")
	print("  Label:")
	print("    color: font_color, font_shadow_color, font_outline_color")
	print("    int: font_size, outline_size, shadow_offset_x/y")
	print("  Button:")
	print("    color: font_color, font_hover_color, font_pressed_color")
	print("    stylebox: normal, hover, pressed, disabled, focus")
	print("  ProgressBar:")
	print("    stylebox: fill, background")
	print("  Panel:")
	print("    stylebox: panel")

	print()

# ============================================
# 3. StyleBoxFlat - 배경/테두리 스타일
# ============================================

func _demonstrate_stylebox_flat():
	print("--- 3. StyleBoxFlat (배경/테두리) ---")

	# StyleBoxFlat = CSS의 background + border + border-radius + padding
	var style = StyleBoxFlat.new()

	# 배경색
	style.bg_color = Color(0.15, 0.15, 0.25, 1.0)
	print("  bg_color: 어두운 남색")

	# 테두리
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.8, 1.0)
	print("  border: 2px solid 보라색")

	# 모서리 둥글기 (border-radius)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	print("  border-radius: 8px (모서리 둥글게)")

	# 내부 여백 (padding)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	print("  padding: 12px 8px")

	# 그림자
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	print("  box-shadow: 4px 블러, 오프셋(2,2)")

	# 적용
	var panel = Panel.new()
	panel.position = Vector2(20, 80)
	panel.custom_minimum_size = Vector2(200, 80)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var panel_label = Label.new()
	panel_label.text = "StyleBoxFlat 패널"
	panel_label.set_anchors_preset(Control.PRESET_CENTER)
	panel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(panel_label)

	print("  Panel에 StyleBoxFlat 적용 완료")

	# StyleBoxFlat 전체 속성
	print("\n  [StyleBoxFlat 주요 속성]")
	print("  bg_color              - 배경색")
	print("  border_color          - 테두리 색")
	print("  border_width_*        - 각 방향 테두리 두께")
	print("  corner_radius_*       - 각 모서리 둥글기")
	print("  content_margin_*      - 내부 여백")
	print("  shadow_color          - 그림자 색")
	print("  shadow_size           - 그림자 블러 크기")
	print("  shadow_offset         - 그림자 오프셋")
	print("  expand_margin_*       - 외부 확장 (테두리 밖)")
	print("  anti_aliasing         - 안티앨리어싱")
	print("  anti_aliasing_size    - AA 크기")
	print("  draw_center           - 중앙 채우기 여부")
	print("  skew                  - 기울기 (Vector2)")

	# 다른 StyleBox 종류
	print("\n  [StyleBox 종류]")
	print("  StyleBoxFlat    - 단색 배경 + 테두리 (가장 많이 사용)")
	print("  StyleBoxTexture - 텍스처 기반 (9-patch)")
	print("  StyleBoxLine    - 선")
	print("  StyleBoxEmpty   - 빈 스타일 (투명)")

	print()

# ============================================
# 4. Theme 리소스 생성
# ============================================

func _demonstrate_create_theme():
	print("--- 4. 코드로 Theme 생성 ---")

	current_theme = Theme.new()

	# 색상 설정
	print("[Theme 색상 설정]")
	current_theme.set_color("font_color", "Label", Color.WHITE)
	current_theme.set_color("font_color", "Button", Color.WHITE)
	current_theme.set_color("font_hover_color", "Button", Color.YELLOW)
	current_theme.set_color("font_pressed_color", "Button", Color.GRAY)
	print("  Label font_color: WHITE")
	print("  Button font_color: WHITE")
	print("  Button font_hover_color: YELLOW")

	# 폰트 크기 설정
	print("\n[Theme 폰트 크기 설정]")
	current_theme.set_font_size("font_size", "Label", 16)
	current_theme.set_font_size("font_size", "Button", 14)
	print("  Label font_size: 16")
	print("  Button font_size: 14")

	# 상수 설정
	print("\n[Theme 상수 설정]")
	current_theme.set_constant("separation", "VBoxContainer", 8)
	current_theme.set_constant("separation", "HBoxContainer", 8)
	current_theme.set_constant("h_separation", "GridContainer", 4)
	current_theme.set_constant("v_separation", "GridContainer", 4)
	print("  VBox/HBox separation: 8")
	print("  Grid h/v_separation: 4")

	# 스타일박스 설정
	print("\n[Theme 스타일박스 설정]")

	# Button normal 상태
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.2, 0.2, 0.35)
	btn_normal.corner_radius_top_left = 6
	btn_normal.corner_radius_top_right = 6
	btn_normal.corner_radius_bottom_left = 6
	btn_normal.corner_radius_bottom_right = 6
	btn_normal.content_margin_left = 16
	btn_normal.content_margin_right = 16
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8
	current_theme.set_stylebox("normal", "Button", btn_normal)

	# Button hover 상태
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.3, 0.3, 0.5)
	btn_hover.border_width_bottom = 2
	btn_hover.border_color = Color.CORNFLOWER_BLUE
	current_theme.set_stylebox("hover", "Button", btn_hover)

	# Button pressed 상태
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.15, 0.15, 0.25)
	current_theme.set_stylebox("pressed", "Button", btn_pressed)

	# Panel 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.18, 0.95)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.border_width_bottom = 1
	panel_style.border_width_top = 1
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_color = Color(0.3, 0.3, 0.4)
	current_theme.set_stylebox("panel", "Panel", panel_style)
	current_theme.set_stylebox("panel", "PanelContainer", panel_style)

	print("  Button: normal / hover / pressed 스타일 설정")
	print("  Panel: 어두운 반투명 배경 + 테두리")

	print()

# ============================================
# 5. Theme 적용
# ============================================

func _demonstrate_apply_theme():
	print("--- 5. Theme 적용 ---")

	# 방법 1: 특정 노드에 적용 (자식에게 상속됨)
	print("[방법 1] 노드에 직접 적용")
	print("  node.theme = my_theme")
	print("  -> 이 노드와 모든 자식에게 적용")

	# 테마가 적용된 패널 생성
	var themed_panel = PanelContainer.new()
	themed_panel.theme = current_theme
	themed_panel.position = Vector2(250, 20)
	themed_panel.custom_minimum_size = Vector2(250, 0)
	add_child(themed_panel)

	var vbox = VBoxContainer.new()
	themed_panel.add_child(vbox)

	var title = Label.new()
	title.text = "테마 적용 예시"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	for text in ["시작", "설정", "종료"]:
		var btn = Button.new()
		btn.text = text
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(btn)

	print("  PanelContainer에 테마 적용 -> 자식 모두 적용")

	# 방법 2: 프로젝트 전체 적용
	print("\n[방법 2] 프로젝트 전역 테마")
	print("  프로젝트 설정 > GUI > Theme > Custom")
	print("  res://themes/main_theme.tres 지정")
	print("  -> 모든 씬의 모든 UI에 적용")

	# 방법 3: 코드로 프로젝트 테마 변경
	print("\n[방법 3] 코드로 프로젝트 테마 변경")
	print("  # 런타임에 전체 테마 교체")
	print("  var theme = load('res://themes/dark_theme.tres')")
	print("  get_tree().root.theme = theme")

	print()

# ============================================
# 6. Button 상태별 스타일
# ============================================

func _demonstrate_button_states():
	print("--- 6. Button 상태별 스타일 ---")

	print("[Button StyleBox 키 (상태별)]")
	print("  'normal'     - 기본 상태")
	print("  'hover'      - 마우스 올림")
	print("  'pressed'    - 눌린 상태")
	print("  'disabled'   - 비활성화 상태")
	print("  'focus'      - 키보드 포커스")

	print("\n[Button Color 키 (상태별)]")
	print("  'font_color'          - 기본 텍스트 색")
	print("  'font_hover_color'    - 호버 시 텍스트 색")
	print("  'font_pressed_color'  - 눌림 시 텍스트 색")
	print("  'font_disabled_color' - 비활성 텍스트 색")
	print("  'font_focus_color'    - 포커스 텍스트 색")
	print("  'icon_normal_color'   - 기본 아이콘 색")
	print("  'icon_hover_color'    - 호버 아이콘 색")

	# 실전: 위험 버튼
	print("\n[실전: 위험(Delete) 버튼 스타일]")
	var danger_btn = Button.new()
	danger_btn.text = "Delete"
	danger_btn.position = Vector2(250, 220)
	danger_btn.custom_minimum_size = Vector2(120, 40)
	add_child(danger_btn)

	# 빨간 위험 스타일
	var danger_normal = StyleBoxFlat.new()
	danger_normal.bg_color = Color(0.7, 0.1, 0.1)
	danger_normal.corner_radius_top_left = 6
	danger_normal.corner_radius_top_right = 6
	danger_normal.corner_radius_bottom_left = 6
	danger_normal.corner_radius_bottom_right = 6
	danger_normal.content_margin_left = 16
	danger_normal.content_margin_right = 16
	danger_normal.content_margin_top = 8
	danger_normal.content_margin_bottom = 8
	danger_btn.add_theme_stylebox_override("normal", danger_normal)

	var danger_hover = danger_normal.duplicate()
	danger_hover.bg_color = Color(0.9, 0.15, 0.15)
	danger_btn.add_theme_stylebox_override("hover", danger_hover)

	var danger_pressed = danger_normal.duplicate()
	danger_pressed.bg_color = Color(0.5, 0.05, 0.05)
	danger_btn.add_theme_stylebox_override("pressed", danger_pressed)

	danger_btn.add_theme_color_override("font_color", Color.WHITE)
	print("  위험 버튼 스타일 적용: red normal/hover/pressed")

	print()

# ============================================
# 7. Theme 상속 구조
# ============================================

func _demonstrate_theme_inheritance():
	print("--- 7. Theme 상속 ---")

	print("[테마 상속 규칙]")
	print("  1. 노드에 직접 오버라이드가 있으면 그것을 사용")
	print("  2. 없으면 노드의 theme 속성 확인")
	print("  3. 없으면 부모 노드의 theme 확인 (재귀)")
	print("  4. 없으면 프로젝트 기본 테마")
	print("  5. 없으면 Godot 기본 테마")

	print("""
  # 예시 구조:
  Control (theme = game_theme)
    +-- Panel                       # game_theme 사용
    |   +-- Label                   # game_theme 사용
    +-- VBox (theme = menu_theme)
    |   +-- Button                  # menu_theme 사용
    |   +-- Button                  # menu_theme 사용
    |       (font_color override)   # 오버라이드 우선!
    +-- Label                       # game_theme 사용
	""")

	print("[type_variation - 타입 변형]")
	print("  같은 노드 타입(예: Button)에 여러 스타일을 만들 수 있음")
	print("""
  # Theme에서 타입 변형 생성
  theme.set_type_variation("DangerButton", "Button")
  theme.set_stylebox("normal", "DangerButton", red_style)

  # 사용: 노드의 theme_type_variation 속성
  danger_btn.theme_type_variation = "DangerButton"
  # -> DangerButton 스타일 적용, 없는 속성은 Button에서 상속
	""")

	print()

# ============================================
# 8. 실전: 다크/라이트 모드
# ============================================

func _practical_dark_light_theme():
	print("--- 8. 실전: 다크/라이트 모드 전환 ---")

	# 다크 테마 생성
	var dark_theme = _create_dark_theme()
	# 라이트 테마 생성
	var light_theme = _create_light_theme()

	print("[다크 테마]")
	print("  배경: #1a1a2e, 텍스트: #ffffff")
	print("  버튼: #2a2a4a, 강조: #4a9eff")

	print("\n[라이트 테마]")
	print("  배경: #f0f0f0, 텍스트: #333333")
	print("  버튼: #e0e0e0, 강조: #2080cc")

	# 전환 버튼 생성
	var toggle = Button.new()
	toggle.text = "Dark/Light 전환"
	toggle.position = Vector2(250, 280)
	toggle.custom_minimum_size = Vector2(150, 35)
	add_child(toggle)

	toggle.pressed.connect(func():
		is_dark_mode = !is_dark_mode
		# 실제로는: get_tree().root.theme = dark/light_theme
		print("  >> 모드 전환: %s" % ("Dark" if is_dark_mode else "Light"))
	)

	print("\n[전환 코드]")
	print("""
  func toggle_theme():
      is_dark_mode = !is_dark_mode
      if is_dark_mode:
          get_tree().root.theme = dark_theme
      else:
          get_tree().root.theme = light_theme

      # Tween으로 부드러운 전환
      var tween = create_tween()
      tween.tween_property(get_tree().root, "modulate",
          Color.WHITE, 0.3)
	""")

	print()

func _create_dark_theme() -> Theme:
	var theme = Theme.new()
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_color", "Button", Color.WHITE)

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.18)
	theme.set_stylebox("panel", "Panel", bg)

	var btn = StyleBoxFlat.new()
	btn.bg_color = Color(0.17, 0.17, 0.3)
	btn.corner_radius_top_left = 6
	btn.corner_radius_top_right = 6
	btn.corner_radius_bottom_left = 6
	btn.corner_radius_bottom_right = 6
	theme.set_stylebox("normal", "Button", btn)

	return theme

func _create_light_theme() -> Theme:
	var theme = Theme.new()
	theme.set_color("font_color", "Label", Color(0.2, 0.2, 0.2))
	theme.set_color("font_color", "Button", Color(0.2, 0.2, 0.2))

	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.94, 0.94, 0.94)
	theme.set_stylebox("panel", "Panel", bg)

	var btn = StyleBoxFlat.new()
	btn.bg_color = Color(0.88, 0.88, 0.88)
	btn.corner_radius_top_left = 6
	btn.corner_radius_top_right = 6
	btn.corner_radius_bottom_left = 6
	btn.corner_radius_bottom_right = 6
	theme.set_stylebox("normal", "Button", btn)

	return theme

# ============================================
# 9. 실전: 게임 UI 테마
# ============================================

func _practical_game_theme():
	print("--- 9. 실전: 게임 UI 테마 ---")
	print("""
  # game_theme.gd - 게임 테마 매니저
  extends Node

  # 색상 팔레트 정의
  const PALETTE = {
      "bg_dark":     Color("#0a0a1a"),
      "bg_medium":   Color("#1a1a3e"),
      "bg_light":    Color("#2a2a5e"),
      "text_primary": Color("#ffffff"),
      "text_secondary": Color("#a0a0c0"),
      "accent":      Color("#4a9eff"),
      "success":     Color("#4aff7a"),
      "warning":     Color("#ffaa4a"),
      "danger":      Color("#ff4a4a"),
      "gold":        Color("#ffd700"),
  }

  func create_game_theme() -> Theme:
      var theme = Theme.new()

      # === Label 스타일 ===
      theme.set_color("font_color", "Label", PALETTE.text_primary)
      theme.set_font_size("font_size", "Label", 16)

      # === Button 스타일 ===
      _setup_button_style(theme)

      # === ProgressBar 스타일 ===
      _setup_progress_style(theme)

      # === Panel 스타일 ===
      _setup_panel_style(theme)

      return theme

  func _setup_button_style(theme: Theme):
      var base = StyleBoxFlat.new()
      base.bg_color = PALETTE.bg_light
      base.corner_radius_top_left = 8
      base.corner_radius_top_right = 8
      base.corner_radius_bottom_left = 8
      base.corner_radius_bottom_right = 8
      base.content_margin_left = 20
      base.content_margin_right = 20
      base.content_margin_top = 10
      base.content_margin_bottom = 10
      base.border_width_bottom = 3
      base.border_color = PALETTE.accent

      theme.set_stylebox("normal", "Button", base)
      theme.set_color("font_color", "Button", PALETTE.text_primary)

      # 호버: 밝아짐 + 글로우
      var hover = base.duplicate()
      hover.bg_color = PALETTE.bg_light.lightened(0.1)
      hover.shadow_color = Color(PALETTE.accent, 0.3)
      hover.shadow_size = 4
      theme.set_stylebox("hover", "Button", hover)

      # 눌림: 어두워짐 + 테두리 변경
      var pressed = base.duplicate()
      pressed.bg_color = PALETTE.bg_dark
      pressed.border_color = PALETTE.accent.darkened(0.3)
      theme.set_stylebox("pressed", "Button", pressed)

  func _setup_progress_style(theme: Theme):
      # HP 바 배경
      var bg = StyleBoxFlat.new()
      bg.bg_color = PALETTE.bg_dark
      bg.corner_radius_top_left = 4
      bg.corner_radius_top_right = 4
      bg.corner_radius_bottom_left = 4
      bg.corner_radius_bottom_right = 4
      bg.border_width_bottom = 1
      bg.border_width_top = 1
      bg.border_width_left = 1
      bg.border_width_right = 1
      bg.border_color = Color(1, 1, 1, 0.1)
      theme.set_stylebox("background", "ProgressBar", bg)

      # HP 바 채우기
      var fill = StyleBoxFlat.new()
      fill.bg_color = PALETTE.success
      fill.corner_radius_top_left = 4
      fill.corner_radius_top_right = 4
      fill.corner_radius_bottom_left = 4
      fill.corner_radius_bottom_right = 4
      theme.set_stylebox("fill", "ProgressBar", fill)
	""")

	print("[테마 저장/로드]")
	print("  # 테마를 .tres 파일로 저장")
	print("  ResourceSaver.save(theme, 'res://themes/game_theme.tres')")
	print("")
	print("  # 테마 로드")
	print("  var theme = load('res://themes/game_theme.tres') as Theme")

	print("\n=== 테마 시스템 학습 완료 ===")
