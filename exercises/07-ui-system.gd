# 챕터 7: UI 시스템
#
# 이 챕터에서는 다음을 학습합니다:
# - Control 노드와 UI 위젯 (Label, Button, ProgressBar)
# - 컨테이너를 활용한 자동 레이아웃
# - UI 시그널 연결과 이벤트 처리
# - StyleBox를 통한 UI 스타일링
# - HUD(Head-Up Display) 구성 패턴

extends Node

# ============================================================
# 연습 1: Label 생성 및 텍스트 설정
# ============================================================
# Label 노드를 코드로 생성하고 텍스트, 폰트 크기, 색상을 설정합니다.
# 실제 게임에서 점수, 이름, 대화 텍스트 등을 표시할 때 사용합니다.

func create_score_label() -> Label:
	# TODO: Label 노드를 생성하세요
	# TODO: text를 "Score: 0"으로 설정하세요
	# TODO: add_theme_font_size_override("font_size", 24)로 크기를 설정하세요
	# TODO: add_theme_color_override("font_color", Color.YELLOW)로 색상을 설정하세요
	# TODO: horizontal_alignment를 HORIZONTAL_ALIGNMENT_CENTER로 설정하세요
	# TODO: 생성한 Label을 반환하세요
	var label = null  # 여기를 수정하세요
	return label


# ============================================================
# 연습 2: Button 생성 및 시그널 연결
# ============================================================
# Button을 생성하고 pressed 시그널을 연결합니다.
# UI 버튼 클릭 처리는 Godot의 시그널 시스템을 활용합니다.

var button_press_count: int = 0

func create_start_button() -> Button:
	# TODO: Button 노드를 생성하세요
	# TODO: text를 "게임 시작"으로 설정하세요
	# TODO: custom_minimum_size를 Vector2(200, 50)으로 설정하세요
	# TODO: pressed 시그널을 _on_start_button_pressed 메서드에 연결하세요
	#       (힌트: button.pressed.connect(_on_start_button_pressed))
	# TODO: 생성한 Button을 반환하세요
	var button = null  # 여기를 수정하세요
	return button

func _on_start_button_pressed():
	# TODO: button_press_count를 1 증가시키세요
	# TODO: "게임 시작 버튼이 눌렸습니다! (N번째)"를 출력하세요
	pass  # 여기를 수정하세요


# ============================================================
# 연습 3: VBoxContainer에 자식 추가
# ============================================================
# VBoxContainer를 만들어 여러 UI 요소를 세로로 정렬합니다.
# 메뉴 화면, 설정 목록 등에서 자주 사용되는 레이아웃입니다.

func create_menu_layout() -> VBoxContainer:
	# TODO: VBoxContainer를 생성하세요
	# TODO: add_theme_constant_override("separation", 10)으로 간격을 설정하세요
	# TODO: 다음 3개의 버튼을 자식으로 추가하세요:
	#       - "새 게임" 버튼
	#       - "이어하기" 버튼
	#       - "설정" 버튼
	#       (힌트: 각 Button을 생성하고 text를 설정한 뒤 vbox.add_child(btn)로 추가)
	# TODO: 생성한 VBoxContainer를 반환하세요
	var vbox = null  # 여기를 수정하세요
	return vbox


# ============================================================
# 연습 4: ProgressBar 생성 및 값 설정
# ============================================================
# ProgressBar로 HP바, 경험치 바, 로딩 진행률 등을 표현합니다.
# min_value, max_value, value 속성을 설정하는 법을 배웁니다.

func create_health_bar(current_hp: float, max_hp: float) -> ProgressBar:
	# TODO: ProgressBar를 생성하세요
	# TODO: min_value를 0으로 설정하세요
	# TODO: max_value를 max_hp로 설정하세요
	# TODO: value를 current_hp로 설정하세요
	# TODO: custom_minimum_size를 Vector2(200, 20)으로 설정하세요
	# TODO: show_percentage를 false로 설정하세요
	# TODO: 생성한 ProgressBar를 반환하세요
	var bar = null  # 여기를 수정하세요
	return bar

func update_health_bar(bar: ProgressBar, new_hp: float) -> void:
	# TODO: bar의 value를 new_hp로 업데이트하세요
	# TODO: HP 비율에 따라 색상을 변경하세요:
	#       - 50% 초과: Color.GREEN
	#       - 20% 초과: Color.YELLOW
	#       - 20% 이하: Color.RED
	#       (힌트: bar.value / bar.max_value로 비율 계산)
	#       (힌트: bar.add_theme_stylebox_override("fill", stylebox)로 색상 변경)
	pass  # 여기를 수정하세요


# ============================================================
# 연습 5: StyleBoxFlat 커스터마이징
# ============================================================
# StyleBoxFlat으로 UI 요소의 배경, 테두리, 모서리를 꾸밉니다.
# 깔끔한 게임 UI를 만들기 위한 기본 스타일링 기법입니다.

func create_panel_style(bg_color: Color, border_color: Color, corner_radius: int) -> StyleBoxFlat:
	# TODO: StyleBoxFlat을 생성하세요
	# TODO: bg_color를 배경색으로 설정하세요
	# TODO: border_width_bottom, border_width_top,
	#       border_width_left, border_width_right를 모두 2로 설정하세요
	# TODO: border_color를 테두리 색상으로 설정하세요
	# TODO: corner_radius_top_left, corner_radius_top_right,
	#       corner_radius_bottom_left, corner_radius_bottom_right를
	#       모두 corner_radius로 설정하세요
	# TODO: content_margin_left, content_margin_right,
	#       content_margin_top, content_margin_bottom을 모두 8로 설정하세요
	# TODO: 생성한 StyleBoxFlat을 반환하세요
	var style = null  # 여기를 수정하세요
	return style

func apply_panel_style(panel: PanelContainer, style: StyleBoxFlat) -> void:
	# TODO: panel에 스타일을 적용하세요
	#       (힌트: panel.add_theme_stylebox_override("panel", style))
	pass  # 여기를 수정하세요


# ============================================================
# 연습 6: 간단한 HUD 구성
# ============================================================
# 여러 UI 요소를 조합하여 게임 HUD를 구성합니다.
# MarginContainer, HBoxContainer 등을 활용한 실전 레이아웃입니다.

func create_game_hud() -> CanvasLayer:
	# TODO: CanvasLayer를 생성하세요 (HUD는 항상 화면 위에 표시)
	# TODO: MarginContainer를 생성하고 CanvasLayer의 자식으로 추가하세요
	# TODO: MarginContainer의 anchor를 전체 화면으로 설정하세요:
	#       - anchor_right = 1.0
	#       - anchor_bottom = 1.0
	# TODO: MarginContainer에 여백을 설정하세요:
	#       - add_theme_constant_override("margin_left", 20)
	#       - add_theme_constant_override("margin_top", 10)
	#       - add_theme_constant_override("margin_right", 20)
	# TODO: HBoxContainer를 생성하여 MarginContainer의 자식으로 추가하세요
	# TODO: HBoxContainer 안에 다음을 추가하세요:
	#       - HP Label ("HP:")
	#       - ProgressBar (create_health_bar(80, 100) 활용)
	#       - Score Label ("Score: 0") - size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# TODO: 생성한 CanvasLayer를 반환하세요
	var hud = null  # 여기를 수정하세요
	return hud


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 7: UI 시스템 ===")
	print("")

	# 테스트 1: Label 생성
	var label = create_score_label()
	if label != null:
		print("결과 1 (Label 텍스트):", label.text)
		print("결과 1 (Label 정렬):", label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER)
		add_child(label)
	else:
		print("결과 1: null - Label을 생성하세요")
	print("")

	# 테스트 2: Button 생성 및 시그널
	var button = create_start_button()
	if button != null:
		print("결과 2 (Button 텍스트):", button.text)
		print("결과 2 (시그널 연결됨):", button.pressed.is_connected(_on_start_button_pressed))
		print("결과 2 (최소 크기):", button.custom_minimum_size)
		add_child(button)
	else:
		print("결과 2: null - Button을 생성하세요")
	print("")

	# 테스트 3: VBoxContainer 메뉴
	var menu = create_menu_layout()
	if menu != null:
		print("결과 3 (자식 수):", menu.get_child_count())
		for i in range(menu.get_child_count()):
			var child = menu.get_child(i)
			if child is Button:
				print("  메뉴 항목 %d: %s" % [i + 1, child.text])
		add_child(menu)
	else:
		print("결과 3: null - VBoxContainer를 생성하세요")
	print("")

	# 테스트 4: ProgressBar
	var hp_bar = create_health_bar(75.0, 100.0)
	if hp_bar != null:
		print("결과 4 (HP 값):", hp_bar.value)
		print("결과 4 (최대 HP):", hp_bar.max_value)
		print("결과 4 (비율):", hp_bar.value / hp_bar.max_value * 100, "%")
		update_health_bar(hp_bar, 15.0)
		print("결과 4 (업데이트 후 HP):", hp_bar.value)
		add_child(hp_bar)
	else:
		print("결과 4: null - ProgressBar를 생성하세요")
	print("")

	# 테스트 5: StyleBoxFlat
	var style = create_panel_style(Color(0.1, 0.1, 0.2, 0.9), Color.CYAN, 8)
	if style != null:
		print("결과 5 (배경색):", style.bg_color)
		print("결과 5 (모서리 반경):", style.corner_radius_top_left)
		print("결과 5 (테두리 너비):", style.border_width_top)
		var panel = PanelContainer.new()
		apply_panel_style(panel, style)
		add_child(panel)
	else:
		print("결과 5: null - StyleBoxFlat을 생성하세요")
	print("")

	# 테스트 6: HUD 구성
	var hud = create_game_hud()
	if hud != null:
		print("결과 6 (HUD 타입):", hud.get_class())
		print("결과 6 (자식 존재):", hud.get_child_count() > 0)
		add_child(hud)
	else:
		print("결과 6: null - HUD를 구성하세요")
	print("")

	print("=== 챕터 7 완료 ===")
