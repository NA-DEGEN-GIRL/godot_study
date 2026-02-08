# 챕터 7: UI 시스템 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - Label 노드 생성과 텍스트 표시
# - Button 시그널 연결과 이벤트 처리
# - VBoxContainer를 이용한 수직 레이아웃
# - ProgressBar로 체력/진행률 표시
# - StyleBoxFlat으로 커스텀 UI 스타일링
# - HUD(Heads-Up Display) 전체 구성

extends Control

# 게임 상태 변수 (연습 6에서 사용)
var player_hp: float = 100.0
var max_hp: float = 100.0
var score: int = 0
var ammo: int = 30
var max_ammo: int = 30

# UI 노드 참조
var hp_bar: ProgressBar
var hp_label: Label
var score_label: Label
var ammo_label: Label

func _ready():
	print("=== 챕터 7: UI 시스템 ===\n")

	# 연습 1: Label 생성
	var label = _exercise_1_create_label()

	# 연습 2: Button 시그널 연결
	var button = _exercise_2_button_signal()

	# 연습 3: VBoxContainer 레이아웃
	var vbox = _exercise_3_vbox_container()

	# 연습 4: ProgressBar 구현
	var bar = _exercise_4_progress_bar()

	# 연습 5: StyleBoxFlat 커스텀 스타일
	var panel = _exercise_5_stylebox_flat()

	# 연습 6: HUD 전체 구성
	_exercise_6_hud_layout()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: Label 텍스트 = '%s'" % label.text)
	print("결과 2: Button 텍스트 = '%s'" % button.text)
	print("결과 3: VBoxContainer 자식 수 = %d" % vbox.get_child_count())
	print("결과 4: ProgressBar 값 = %.0f/%.0f" % [bar.value, bar.max_value])
	print("결과 5: Panel 스타일 적용 완료")
	print("결과 6: HUD 구성 완료 - HP: %.0f, Score: %d, Ammo: %d/%d" % [
		player_hp, score, ammo, max_ammo
	])


# ==============================================================================
# 연습 1: Label 생성 - 텍스트를 화면에 표시하는 Label 노드를 코드로 생성하세요.
# ==============================================================================
func _exercise_1_create_label() -> Label:
	# 풀이: Label.new()로 인스턴스를 생성하고, text 속성에 문자열을 대입합니다.
	#       add_theme_font_size_override로 폰트 크기를, add_theme_color_override로
	#       폰트 색상을 변경합니다. horizontal_alignment로 정렬을 설정합니다.

	var label = Label.new()
	label.name = "TitleLabel"
	label.text = "Godot 4 UI 시스템 학습"
	label.position = Vector2(20, 10)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.GOLD)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(label)

	# 멀티라인 Label 추가
	var desc_label = Label.new()
	desc_label.text = "이 예제에서는 코드로 UI를 구성하는 방법을 학습합니다."
	desc_label.position = Vector2(20, 50)
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size = Vector2(400, 0)
	add_child(desc_label)

	print("연습 1 완료: Label 생성 - '%s'" % label.text)
	return label


# ==============================================================================
# 연습 2: Button 시그널 - 버튼을 생성하고 pressed 시그널을 연결하세요.
# ==============================================================================
func _exercise_2_button_signal() -> Button:
	# 풀이: Button.new()로 버튼을 생성하고, pressed 시그널에 람다 함수를
	#       connect합니다. toggle_mode를 true로 설정하면 토글 버튼이 됩니다.
	#       toggled 시그널로 ON/OFF 상태를 감지할 수 있습니다.

	var btn = Button.new()
	btn.name = "ActionButton"
	btn.text = "점수 추가 (+100)"
	btn.position = Vector2(20, 90)
	btn.custom_minimum_size = Vector2(150, 40)
	add_child(btn)

	# pressed 시그널 연결 - 클릭할 때마다 점수 증가
	btn.pressed.connect(func():
		score += 100
		if score_label:
			score_label.text = "Score: %d" % score
		print("  >> 버튼 클릭! 점수: %d" % score)
	)

	# 토글 버튼 생성
	var toggle_btn = Button.new()
	toggle_btn.text = "사운드 ON"
	toggle_btn.toggle_mode = true
	toggle_btn.button_pressed = true
	toggle_btn.position = Vector2(180, 90)
	toggle_btn.custom_minimum_size = Vector2(120, 40)
	add_child(toggle_btn)

	toggle_btn.toggled.connect(func(pressed: bool):
		toggle_btn.text = "사운드 %s" % ("ON" if pressed else "OFF")
		print("  >> 사운드 토글: %s" % ("ON" if pressed else "OFF"))
	)

	print("연습 2 완료: Button 시그널 연결")
	return btn


# ==============================================================================
# 연습 3: VBoxContainer - 메뉴 버튼을 수직으로 배치하세요.
# ==============================================================================
func _exercise_3_vbox_container() -> VBoxContainer:
	# 풀이: VBoxContainer.new()로 컨테이너를 생성하고 자식 버튼을 추가합니다.
	#       add_theme_constant_override("separation", 값)으로 간격을 조절합니다.
	#       size_flags_horizontal = SIZE_EXPAND_FILL로 버튼이 전체 너비를 채우게 합니다.

	var vbox = VBoxContainer.new()
	vbox.name = "MenuVBox"
	vbox.position = Vector2(450, 10)
	vbox.custom_minimum_size = Vector2(160, 0)
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)

	# 메뉴 타이틀
	var title = Label.new()
	title.text = "MENU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)

	# 구분선
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# 메뉴 버튼들
	var menu_items = ["새 게임", "불러오기", "설정", "종료"]
	for item_text in menu_items:
		var btn = Button.new()
		btn.text = item_text
		btn.custom_minimum_size = Vector2(160, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(): print("  >> 메뉴 선택: %s" % item_text))
		vbox.add_child(btn)

	print("연습 3 완료: VBoxContainer에 %d개 자식 배치" % vbox.get_child_count())
	return vbox


# ==============================================================================
# 연습 4: ProgressBar - 체력 바를 구현하세요. 색상 커스터마이즈 포함.
# ==============================================================================
func _exercise_4_progress_bar() -> ProgressBar:
	# 풀이: ProgressBar.new()로 바를 생성하고 min_value, max_value, value를 설정합니다.
	#       StyleBoxFlat으로 fill과 background 스타일을 각각 오버라이드합니다.
	#       show_percentage를 false로 하고 별도 Label로 값을 표시합니다.

	var bar = ProgressBar.new()
	bar.name = "HealthBar"
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 75
	bar.position = Vector2(20, 145)
	bar.custom_minimum_size = Vector2(200, 22)
	bar.show_percentage = false
	add_child(bar)

	# fill 스타일 (초록 -> 노랑 -> 빨강)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.3)
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill_style)

	# background 스타일
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.2)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("background", bg_style)

	# HP 라벨
	var bar_label = Label.new()
	bar_label.text = "HP: %d/%d" % [int(bar.value), int(bar.max_value)]
	bar_label.position = Vector2(225, 145)
	bar_label.add_theme_font_size_override("font_size", 14)
	add_child(bar_label)

	# 체력에 따른 색상 변경 함수
	var update_color = func():
		var ratio = bar.value / bar.max_value
		if ratio > 0.6:
			fill_style.bg_color = Color(0.2, 0.8, 0.3)  # 초록
		elif ratio > 0.3:
			fill_style.bg_color = Color(0.9, 0.8, 0.1)  # 노랑
		else:
			fill_style.bg_color = Color(0.9, 0.2, 0.1)  # 빨강
		bar_label.text = "HP: %d/%d" % [int(bar.value), int(bar.max_value)]

	bar.value_changed.connect(func(_v): update_color.call())

	# 데미지 시뮬레이션 (Tween)
	var tween = create_tween()
	tween.tween_property(bar, "value", 35.0, 1.5)
	tween.tween_property(bar, "value", 60.0, 0.5)

	print("연습 4 완료: ProgressBar - HP %d/%d" % [int(bar.value), int(bar.max_value)])
	return bar


# ==============================================================================
# 연습 5: StyleBoxFlat - 커스텀 스타일 패널을 만드세요.
# ==============================================================================
func _exercise_5_stylebox_flat() -> Panel:
	# 풀이: StyleBoxFlat.new()로 스타일을 생성하고, bg_color(배경색),
	#       border_width_*(테두리), corner_radius_*(둥근 모서리),
	#       content_margin_*(내부 여백), shadow_*(그림자)를 설정합니다.
	#       Panel에 add_theme_stylebox_override("panel", style)로 적용합니다.

	var panel = Panel.new()
	panel.name = "StyledPanel"
	panel.position = Vector2(20, 180)
	panel.custom_minimum_size = Vector2(280, 80)
	add_child(panel)

	# 커스텀 StyleBoxFlat 생성
	var style = StyleBoxFlat.new()

	# 배경색 (어두운 남색, 약간 투명)
	style.bg_color = Color(0.12, 0.12, 0.22, 0.95)

	# 테두리 (보라빛)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.3, 0.8, 0.8)

	# 둥근 모서리
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	# 내부 여백
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12

	# 그림자
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	style.shadow_offset = Vector2(3, 3)

	# 패널에 적용
	panel.add_theme_stylebox_override("panel", style)

	# 패널 내부 라벨
	var panel_label = Label.new()
	panel_label.text = "StyleBoxFlat 커스텀 패널"
	panel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_label.add_theme_font_size_override("font_size", 16)
	panel_label.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0))
	panel.add_child(panel_label)

	print("연습 5 완료: StyleBoxFlat 스타일 패널 생성")
	return panel


# ==============================================================================
# 연습 6: HUD 구성 - 게임 HUD 전체를 코드로 구성하세요.
#          (HP바, 점수, 탄약 카운터를 포함하는 상단/하단 바)
# ==============================================================================
func _exercise_6_hud_layout():
	# 풀이: CanvasLayer 위에 MarginContainer > HBoxContainer 구조로
	#       상단 바(HP + 점수)와 하단 바(탄약)를 배치합니다.
	#       Spacer(Control + SIZE_EXPAND_FILL)로 좌우를 분리합니다.
	#       각 요소를 변수에 캐싱하여 나중에 업데이트할 수 있게 합니다.

	# 상단 HUD 바 (마진 컨테이너)
	var top_margin = MarginContainer.new()
	top_margin.name = "HUDTop"
	top_margin.position = Vector2(0, 280)
	top_margin.custom_minimum_size = Vector2(620, 45)
	top_margin.add_theme_constant_override("margin_left", 12)
	top_margin.add_theme_constant_override("margin_right", 12)
	top_margin.add_theme_constant_override("margin_top", 6)
	add_child(top_margin)

	var top_bar = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 10)
	top_margin.add_child(top_bar)

	# --- HP 섹션 ---
	var hp_section = HBoxContainer.new()
	hp_section.add_theme_constant_override("separation", 6)
	top_bar.add_child(hp_section)

	var hp_icon = Label.new()
	hp_icon.text = "HP"
	hp_icon.add_theme_color_override("font_color", Color.RED)
	hp_icon.add_theme_font_size_override("font_size", 16)
	hp_section.add_child(hp_icon)

	hp_bar = ProgressBar.new()
	hp_bar.max_value = max_hp
	hp_bar.value = player_hp
	hp_bar.custom_minimum_size = Vector2(160, 20)
	hp_bar.show_percentage = false
	hp_section.add_child(hp_bar)

	# HP바 스타일 적용
	var hp_fill = StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.2, 0.8, 0.3)
	hp_fill.corner_radius_top_left = 3
	hp_fill.corner_radius_top_right = 3
	hp_fill.corner_radius_bottom_left = 3
	hp_fill.corner_radius_bottom_right = 3
	hp_bar.add_theme_stylebox_override("fill", hp_fill)

	var hp_bg = StyleBoxFlat.new()
	hp_bg.bg_color = Color(0.12, 0.12, 0.18)
	hp_bg.corner_radius_top_left = 3
	hp_bg.corner_radius_top_right = 3
	hp_bg.corner_radius_bottom_left = 3
	hp_bg.corner_radius_bottom_right = 3
	hp_bar.add_theme_stylebox_override("background", hp_bg)

	hp_label = Label.new()
	hp_label.text = "%d/%d" % [int(player_hp), int(max_hp)]
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_section.add_child(hp_label)

	# --- 중앙 공간 ---
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	# --- 점수 섹션 ---
	score_label = Label.new()
	score_label.text = "Score: %d" % score
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	top_bar.add_child(score_label)

	# 하단 HUD 바 (탄약)
	var bottom_margin = MarginContainer.new()
	bottom_margin.name = "HUDBottom"
	bottom_margin.position = Vector2(0, 340)
	bottom_margin.custom_minimum_size = Vector2(620, 35)
	bottom_margin.add_theme_constant_override("margin_left", 12)
	add_child(bottom_margin)

	ammo_label = Label.new()
	ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]
	ammo_label.add_theme_font_size_override("font_size", 15)
	ammo_label.add_theme_color_override("font_color", Color.WHITE)
	bottom_margin.add_child(ammo_label)

	# 데미지 시뮬레이션으로 HUD 업데이트 테스트
	_simulate_hud_update()

	print("연습 6 완료: HUD 구성 - 상단(HP+Score) + 하단(Ammo)")


func _simulate_hud_update():
	# Tween으로 HP 감소 시뮬레이션
	player_hp = 65.0
	hp_bar.value = player_hp
	hp_label.text = "%d/%d" % [int(player_hp), int(max_hp)]

	score = 1500
	score_label.text = "Score: %d" % score

	ammo = 24
	ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]
