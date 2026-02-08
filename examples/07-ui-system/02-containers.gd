# Chapter 07 - UI System
# 02-containers.gd - 컨테이너와 레이아웃 시스템
#
# 이 파일에서 배울 내용:
# - VBoxContainer, HBoxContainer 수직/수평 배치
# - GridContainer 그리드 레이아웃
# - MarginContainer 여백 설정
# - size_flags로 크기 제어
# - CenterContainer, PanelContainer, ScrollContainer
#
# 컨테이너는 자식 Control 노드의 위치와 크기를 자동으로 관리합니다.
# 수동 배치 대신 컨테이너를 사용하면 반응형 UI를 쉽게 만들 수 있습니다.

extends Control

# ============================================
# 1. 컨테이너 종류 개요
# ============================================
# Container (기본, 직접 사용 안 함)
#   +-- BoxContainer
#   |     +-- VBoxContainer (수직 배치)
#   |     +-- HBoxContainer (수평 배치)
#   +-- GridContainer (격자 배치)
#   +-- CenterContainer (중앙 정렬)
#   +-- MarginContainer (여백)
#   +-- PanelContainer (배경 패널 + 여백)
#   +-- ScrollContainer (스크롤 영역)
#   +-- TabContainer (탭 전환)
#   +-- SplitContainer
#   |     +-- HSplitContainer (수평 분할)
#   |     +-- VSplitContainer (수직 분할)
#   +-- FlowContainer (자동 줄바꿈)
#   +-- AspectRatioContainer (비율 유지)

func _ready():
	print("=== Chapter 07-2: 컨테이너와 레이아웃 ===\n")

	_demonstrate_vbox()
	_demonstrate_hbox()
	_demonstrate_grid()
	_demonstrate_margin()
	_demonstrate_size_flags()
	_demonstrate_center_container()
	_demonstrate_scroll_container()
	_demonstrate_nested_layout()
	_practical_menu_layout()

# ============================================
# 2. VBoxContainer - 수직(세로) 배치
# ============================================

func _demonstrate_vbox():
	print("--- 2. VBoxContainer (수직 배치) ---")

	var vbox = VBoxContainer.new()
	vbox.name = "MenuVBox"
	vbox.position = Vector2(20, 20)
	vbox.custom_minimum_size = Vector2(150, 0)
	add_child(vbox)

	# 자식 추가 - 위에서 아래로 순서대로 배치됨
	var items = ["새 게임", "불러오기", "설정", "종료"]
	for item_text in items:
		var btn = Button.new()
		btn.text = item_text
		btn.custom_minimum_size = Vector2(150, 40)
		vbox.add_child(btn)

	print("  VBoxContainer에 버튼 4개 수직 배치")

	# separation (간격)
	vbox.add_theme_constant_override("separation", 8)
	print("  separation = 8px (버튼 사이 간격)")

	# alignment (정렬)
	# vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	print("\n  [alignment 옵션]")
	print("  ALIGNMENT_BEGIN   - 시작 (위쪽)")
	print("  ALIGNMENT_CENTER  - 중앙")
	print("  ALIGNMENT_END     - 끝 (아래쪽)")

	print()

# ============================================
# 3. HBoxContainer - 수평(가로) 배치
# ============================================

func _demonstrate_hbox():
	print("--- 3. HBoxContainer (수평 배치) ---")

	var hbox = HBoxContainer.new()
	hbox.name = "ToolbarHBox"
	hbox.position = Vector2(200, 20)
	hbox.add_theme_constant_override("separation", 5)
	add_child(hbox)

	# 도구 버튼들 가로 배치
	var tools = ["Pen", "Brush", "Eraser", "Fill", "Select"]
	for tool_name in tools:
		var btn = Button.new()
		btn.text = tool_name
		btn.custom_minimum_size = Vector2(60, 35)
		hbox.add_child(btn)

	print("  HBoxContainer에 5개 버튼 수평 배치")
	print("  separation = 5px")

	# 구분선(Separator) 추가
	print("\n  [구분선 추가]")
	print("  HSeparator - 수평선 (VBox에서 사용)")
	print("  VSeparator - 수직선 (HBox에서 사용)")
	print("""  var sep = VSeparator.new()
  hbox.add_child(sep)  # 버튼 사이에 세로 구분선""")

	print()

# ============================================
# 4. GridContainer - 그리드(격자) 배치
# ============================================

func _demonstrate_grid():
	print("--- 4. GridContainer (격자 배치) ---")

	var grid = GridContainer.new()
	grid.name = "InventoryGrid"
	grid.columns = 4                  # 열(가로) 개수
	grid.position = Vector2(200, 80)
	grid.add_theme_constant_override("h_separation", 4)  # 가로 간격
	grid.add_theme_constant_override("v_separation", 4)  # 세로 간격
	add_child(grid)

	# 4x4 인벤토리 슬롯 생성
	for i in range(16):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(50, 50)

		# 배경 스타일
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.3, 1.0)
		style.border_width_bottom = 1
		style.border_width_top = 1
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_color = Color(0.4, 0.4, 0.5)
		slot.add_theme_stylebox_override("panel", style)

		# 슬롯 번호 라벨
		var label = Label.new()
		label.text = str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot.add_child(label)

		grid.add_child(slot)

	print("  GridContainer: 4열 x 4행 인벤토리 슬롯")
	print("  columns = 4 (자동으로 4개마다 줄바꿈)")
	print("  h_separation = 4px, v_separation = 4px")

	# GridContainer 특성
	print("\n  [GridContainer 특성]")
	print("  - columns 속성으로 열 수 지정")
	print("  - 행(row)은 자식 수에 따라 자동 결정")
	print("  - 자식 추가 순서: 왼쪽->오른쪽, 위->아래")
	print("  - 인벤토리, 스킬 트리, 퍼즐 등에 적합")

	print()

# ============================================
# 5. MarginContainer - 여백 컨테이너
# ============================================

func _demonstrate_margin():
	print("--- 5. MarginContainer (여백) ---")

	var margin = MarginContainer.new()
	margin.name = "ContentMargin"
	margin.position = Vector2(200, 310)
	margin.custom_minimum_size = Vector2(200, 80)

	# 여백 설정
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	# 배경 추가를 위해 Panel을 먼저 넣기
	var content = Label.new()
	content.text = "여백 안의 콘텐츠"
	content.autowrap_mode = TextServer.AUTOWRAP_WORD
	margin.add_child(content)

	print("  MarginContainer: 좌/우 20px, 상/하 10px")
	print("  자식 노드 주변에 여백을 추가")

	print("\n  [PanelContainer - 배경 있는 마진]")
	print("  PanelContainer = Panel 배경 + 자동 여백")
	print("""  var panel_container = PanelContainer.new()
  # 내부 여백은 Theme의 StyleBox로 제어
  var label = Label.new()
  label.text = "패널 안의 텍스트"
  panel_container.add_child(label)""")

	var pc = PanelContainer.new()
	pc.position = Vector2(420, 310)
	var pc_label = Label.new()
	pc_label.text = "PanelContainer"
	pc.add_child(pc_label)
	add_child(pc)

	print()

# ============================================
# 6. size_flags - 크기 제어 플래그
# ============================================

func _demonstrate_size_flags():
	print("--- 6. size_flags (크기 제어) ---")

	print("[size_flags_horizontal / size_flags_vertical]")
	print("  컨테이너 안에서 자식 노드의 크기 동작을 제어")

	print("\n  [SIZE_SHRINK_BEGIN] (기본)")
	print("  최소 크기만 차지, 시작 쪽에 위치")

	print("\n  [SIZE_FILL]")
	print("  가능한 공간을 채움 (늘어남)")

	print("\n  [SIZE_EXPAND]")
	print("  남은 공간을 차지하려고 확장")

	print("\n  [SIZE_EXPAND_FILL] (가장 많이 사용)")
	print("  SIZE_EXPAND | SIZE_FILL = 남은 공간을 채우며 확장")

	print("\n  [SIZE_SHRINK_CENTER]")
	print("  최소 크기, 중앙에 위치")

	print("\n  [SIZE_SHRINK_END]")
	print("  최소 크기, 끝 쪽에 위치")

	# 실전 예시: 상단 바
	print("\n[실전 예시: 상단 바 레이아웃]")

	var topbar = HBoxContainer.new()
	topbar.name = "TopBar"
	topbar.position = Vector2(20, 250)
	topbar.custom_minimum_size = Vector2(500, 35)
	topbar.add_theme_constant_override("separation", 10)
	add_child(topbar)

	# 왼쪽: 뒤로가기 버튼 (고정 크기)
	var back_btn = Button.new()
	back_btn.text = "< Back"
	back_btn.custom_minimum_size = Vector2(70, 30)
	# SIZE_SHRINK_BEGIN이 기본이라 고정 크기
	topbar.add_child(back_btn)

	# 중앙: 타이틀 (남은 공간 채우기)
	var title = Label.new()
	title.text = "Game Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # 핵심!
	topbar.add_child(title)

	# 오른쪽: 설정 버튼 (고정 크기)
	var settings_btn = Button.new()
	settings_btn.text = "Settings"
	settings_btn.custom_minimum_size = Vector2(80, 30)
	topbar.add_child(settings_btn)

	print("  [< Back] [ --- Game Title --- ] [Settings]")
	print("  Back/Settings = 고정, Title = EXPAND_FILL")

	# stretch_ratio (확장 비율)
	print("\n[stretch_ratio - 확장 비율 제어]")
	print("  여러 EXPAND_FILL 자식의 비율을 조정")
	print("""  # 3:1 비율로 공간 분배
  left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  left_panel.size_flags_stretch_ratio = 3.0
  right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  right_panel.size_flags_stretch_ratio = 1.0
  # 결과: |--- left 75% ---|-- right 25% --|""")

	print()

# ============================================
# 7. CenterContainer - 중앙 정렬
# ============================================

func _demonstrate_center_container():
	print("--- 7. CenterContainer (중앙 정렬) ---")

	print("  자식 노드를 정확히 중앙에 배치")
	print("  팝업, 모달, 로딩 화면에 유용")
	print("""
  var center = CenterContainer.new()
  center.set_anchors_preset(Control.PRESET_FULL_RECT)

  var popup = PanelContainer.new()
  popup.custom_minimum_size = Vector2(300, 200)
  center.add_child(popup)
  # -> 화면 정중앙에 300x200 패널
	""")

	print("[use_top_left]")
	print("  true: 자식의 position을 중앙 좌표로 설정")
	print("  false: 자식의 앵커/오프셋으로 중앙 배치 (기본)")

	print()

# ============================================
# 8. ScrollContainer - 스크롤 영역
# ============================================

func _demonstrate_scroll_container():
	print("--- 8. ScrollContainer (스크롤 영역) ---")

	var scroll = ScrollContainer.new()
	scroll.name = "LogScroll"
	scroll.position = Vector2(420, 80)
	scroll.custom_minimum_size = Vector2(180, 200)
	add_child(scroll)

	# 스크롤 안에 VBox 넣기
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# 많은 항목 추가 (스크롤 필요)
	for i in range(20):
		var label = Label.new()
		label.text = "로그 항목 #%02d - 이벤트 기록" % (i + 1)
		vbox.add_child(label)

	print("  ScrollContainer: 180x200 영역에 20개 항목")
	print("  자동으로 스크롤바 표시")

	print("\n  [ScrollContainer 속성]")
	print("  horizontal_scroll_mode - 수평 스크롤 모드")
	print("  vertical_scroll_mode   - 수직 스크롤 모드")
	print("    SCROLL_MODE_DISABLED  - 스크롤 비활성")
	print("    SCROLL_MODE_AUTO      - 필요시 자동 표시")
	print("    SCROLL_MODE_SHOW_ALWAYS - 항상 표시")
	print("    SCROLL_MODE_SHOW_NEVER  - 항상 숨김 (스와이프만)")

	print("\n  [코드로 스크롤 제어]")
	print("  scroll.scroll_vertical = 100   # 세로 위치 설정")
	print("  scroll.ensure_control_visible(node)  # 특정 노드까지 스크롤")

	print()

# ============================================
# 9. 중첩 레이아웃 (Nested Layout)
# ============================================

func _demonstrate_nested_layout():
	print("--- 9. 중첩 레이아웃 ---")

	print("[게임 화면 레이아웃 구조]")
	print("""
  Control (루트)
  +-- VBoxContainer (전체 수직 배치)
  |   +-- HBoxContainer (상단 바)
  |   |   +-- Label "HP"
  |   |   +-- ProgressBar (체력)
  |   |   +-- Label "Score: 0"
  |   |
  |   +-- Control (게임 영역 - EXPAND_FILL)
  |   |   +-- SubViewportContainer (게임 렌더링)
  |   |
  |   +-- HBoxContainer (하단 바)
  |       +-- Button "Attack"
  |       +-- Button "Defend"
  |       +-- Button "Magic"
  |       +-- Button "Item"
	""")

	print("[설정 화면 레이아웃]")
	print("""
  MarginContainer (전체 여백)
  +-- VBoxContainer
      +-- Label "SETTINGS" (타이틀)
      +-- HSeparator
      +-- GridContainer (columns = 2)
      |   +-- Label "볼륨"
      |   +-- HSlider
      |   +-- Label "밝기"
      |   +-- HSlider
      |   +-- Label "해상도"
      |   +-- OptionButton
      |   +-- Label "전체화면"
      |   +-- CheckButton
      +-- HSeparator
      +-- HBoxContainer (버튼 영역)
          +-- Button "취소"
          +-- Button "적용"
	""")

	print()

# ============================================
# 10. 실전: 메인 메뉴 레이아웃
# ============================================

func _practical_menu_layout():
	print("--- 10. 실전: 메인 메뉴 레이아웃 구현 ---")

	# 전체 래핑: CenterContainer
	var center = CenterContainer.new()
	center.name = "MenuCenter"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 데모에서 겹침 방지
	center.position = Vector2(0, 420)
	center.custom_minimum_size = Vector2(600, 200)
	add_child(center)

	# 메뉴 패널
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 0)
	center.add_child(panel)

	# 패널 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.content_margin_left = 30
	panel_style.content_margin_right = 30
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", panel_style)

	# 내부 VBox
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# 타이틀
	var title_label = Label.new()
	title_label.text = "My Game"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(title_label)

	# 구분선
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# 메뉴 버튼들
	var menu_items = [
		{"text": "New Game", "color": Color(0.2, 0.6, 0.2)},
		{"text": "Continue", "color": Color(0.2, 0.4, 0.7)},
		{"text": "Settings", "color": Color(0.5, 0.4, 0.2)},
		{"text": "Quit", "color": Color(0.6, 0.2, 0.2)},
	]

	for item in menu_items:
		var btn = Button.new()
		btn.text = item.text
		btn.custom_minimum_size = Vector2(0, 40)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# 버튼 스타일
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = item.color
		btn_style.corner_radius_top_left = 5
		btn_style.corner_radius_top_right = 5
		btn_style.corner_radius_bottom_left = 5
		btn_style.corner_radius_bottom_right = 5
		btn.add_theme_stylebox_override("normal", btn_style)

		# 호버 스타일
		var hover_style = btn_style.duplicate()
		hover_style.bg_color = item.color.lightened(0.2)
		btn.add_theme_stylebox_override("hover", hover_style)

		btn.pressed.connect(func(): print("  >> 메뉴 선택: %s" % item.text))
		vbox.add_child(btn)

	print("  메인 메뉴 생성 완료:")
	print("  CenterContainer > PanelContainer > VBoxContainer")
	print("  - Title Label (금색, 28px)")
	print("  - HSeparator")
	print("  - 4개 색상 버튼 (EXPAND_FILL)")

	print("\n=== 컨테이너 레이아웃 학습 완료 ===")
