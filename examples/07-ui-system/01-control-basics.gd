# Chapter 07 - UI System
# 01-control-basics.gd - Control 노드 기초
#
# 이 파일에서 배울 내용:
# - Label, Button, ProgressBar 등 기본 UI 노드
# - 코드로 UI 요소 생성 및 조작
# - 텍스트 표시, 버튼 이벤트, 진행률 표시
# - TextureRect, TextEdit, LineEdit 사용법
# - Control 노드 공통 속성 (size, position, anchors)
#
# Godot의 UI 시스템은 Control 노드를 기반으로 합니다.
# 모든 UI 요소는 Control을 상속합니다.

extends Control

# ============================================
# 1. Control 노드 계층 구조
# ============================================
# Control (모든 UI의 기본)
#   +-- Label (텍스트 표시)
#   +-- Button (클릭 버튼)
#   +-- LineEdit (한 줄 입력)
#   +-- TextEdit (여러 줄 입력)
#   +-- ProgressBar (진행률 표시)
#   +-- TextureRect (이미지 표시)
#   +-- Panel (배경 패널)
#   +-- CheckBox, CheckButton (체크박스)
#   +-- OptionButton (드롭다운)
#   +-- SpinBox (숫자 입력)
#   +-- HSlider, VSlider (슬라이더)
#   +-- ColorPickerButton (색상 선택)
#   +-- RichTextLabel (서식 텍스트)
#   +-- Container류 (레이아웃 관리)

func _ready():
	print("=== Chapter 07-1: Control 노드 기초 ===\n")

	_demonstrate_label()
	_demonstrate_button()
	_demonstrate_progressbar()
	_demonstrate_line_edit()
	_demonstrate_rich_text_label()
	_demonstrate_option_button()
	_demonstrate_slider()
	_demonstrate_control_properties()
	_demonstrate_anchors()

# ============================================
# 2. Label - 텍스트 표시
# ============================================

func _demonstrate_label():
	print("--- 2. Label (텍스트 표시) ---")

	# 기본 Label
	var label = Label.new()
	label.text = "안녕하세요, Godot!"
	label.name = "BasicLabel"
	label.position = Vector2(20, 20)
	add_child(label)
	print("  Label 생성: '%s'" % label.text)

	# 텍스트 속성
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  # 가로 정렬
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER      # 세로 정렬
	print("  정렬: 가로/세로 CENTER")

	# 폰트 크기 변경
	label.add_theme_font_size_override("font_size", 24)
	print("  폰트 크기: 24px")

	# 폰트 색상 변경
	label.add_theme_color_override("font_color", Color.YELLOW)
	print("  폰트 색상: YELLOW")

	# 그림자 효과
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	print("  텍스트 그림자 추가")

	# 자동 줄바꿈
	var multiline_label = Label.new()
	multiline_label.text = "이것은 매우 긴 텍스트입니다. autowrap_mode를 설정하면 자동으로 줄바꿈됩니다."
	multiline_label.autowrap_mode = TextServer.AUTOWRAP_WORD  # 단어 단위 줄바꿈
	multiline_label.custom_minimum_size = Vector2(200, 0)     # 최소 너비 200
	multiline_label.position = Vector2(20, 60)
	add_child(multiline_label)
	print("  Multiline Label: autowrap_mode = WORD")

	# Label 속성 정리
	print("\n  [Label 주요 속성]")
	print("  text: String          - 표시할 텍스트")
	print("  horizontal_alignment  - LEFT, CENTER, RIGHT, FILL")
	print("  vertical_alignment    - TOP, CENTER, BOTTOM")
	print("  autowrap_mode         - OFF, ARBITRARY, WORD, WORD_SMART")
	print("  clip_text: bool       - 영역 넘으면 자르기")
	print("  uppercase: bool       - 대문자 강제")

	print()

# ============================================
# 3. Button - 클릭 버튼
# ============================================

func _demonstrate_button():
	print("--- 3. Button (클릭 버튼) ---")

	# 기본 Button
	var btn = Button.new()
	btn.text = "클릭!"
	btn.name = "BasicButton"
	btn.position = Vector2(20, 130)
	btn.custom_minimum_size = Vector2(120, 40)
	add_child(btn)

	# pressed 시그널 연결
	btn.pressed.connect(func():
		print("  >> 버튼 클릭됨!")
	)
	print("  Button 생성: '%s' (120x40)" % btn.text)

	# 토글 버튼
	var toggle_btn = Button.new()
	toggle_btn.text = "토글 버튼"
	toggle_btn.toggle_mode = true  # 토글 모드 활성화
	toggle_btn.position = Vector2(160, 130)
	toggle_btn.custom_minimum_size = Vector2(120, 40)
	add_child(toggle_btn)

	toggle_btn.toggled.connect(func(pressed: bool):
		print("  >> 토글: %s" % ("ON" if pressed else "OFF"))
	)
	print("  Toggle Button 생성: toggle_mode = true")

	# 아이콘 버튼
	print("\n  [아이콘 설정]")
	print("  btn.icon = preload('res://icon.svg')")
	print("  btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT")
	print("  btn.expand_icon = true")

	# 비활성화
	print("\n  [버튼 비활성화]")
	print("  btn.disabled = true  # 클릭 불가, 흐리게 표시")

	# Button 변형들
	print("\n  [Button 변형 노드들]")
	print("  Button       - 기본 텍스트/아이콘 버튼")
	print("  CheckBox     - 체크박스 (사각형 체크)")
	print("  CheckButton  - 토글 스위치 (ON/OFF)")
	print("  MenuButton   - 드롭다운 메뉴 버튼")
	print("  OptionButton - 드롭다운 선택 목록")
	print("  LinkButton   - 하이퍼링크 스타일")

	# CheckBox 예시
	var checkbox = CheckBox.new()
	checkbox.text = "사운드 켜기"
	checkbox.button_pressed = true  # 기본 체크됨
	checkbox.position = Vector2(20, 180)
	add_child(checkbox)

	checkbox.toggled.connect(func(checked: bool):
		print("  >> 사운드: %s" % ("ON" if checked else "OFF"))
	)
	print("\n  CheckBox 생성: '사운드 켜기' (기본 체크됨)")

	print()

# ============================================
# 4. ProgressBar - 진행률 표시
# ============================================

func _demonstrate_progressbar():
	print("--- 4. ProgressBar (진행률 표시) ---")

	# 기본 ProgressBar
	var bar = ProgressBar.new()
	bar.name = "HealthBar"
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 75
	bar.position = Vector2(20, 220)
	bar.custom_minimum_size = Vector2(200, 25)
	bar.show_percentage = true  # 퍼센트 텍스트 표시
	add_child(bar)

	print("  ProgressBar: %d/%d (%.0f%%)" % [bar.value, bar.max_value,
		bar.value / bar.max_value * 100])

	# 값 변경
	bar.value = 50
	print("  값 변경: %d -> 50" % 75)

	# 퍼센트 숨기기
	bar.show_percentage = false
	print("  show_percentage = false (텍스트 숨김)")

	# 색상 커스터마이즈
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.RED
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", fill_style)
	print("  fill 색상: RED (모서리 둥글게)")

	# 배경 스타일
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("background", bg_style)
	print("  배경 색상: Dark Gray")

	# Tween으로 부드러운 변화
	print("\n  [Tween으로 부드러운 값 변화]")
	print("""  var tween = create_tween()
  tween.tween_property(bar, "value", 30.0, 0.5)
  # 0.5초에 걸쳐 현재값 -> 30으로 부드럽게""")

	var tween = create_tween()
	tween.tween_property(bar, "value", 30.0, 0.5)

	# ProgressBar 속성
	print("\n  [ProgressBar 주요 속성 (Range 상속)]")
	print("  min_value: float     - 최솟값 (기본 0)")
	print("  max_value: float     - 최댓값 (기본 100)")
	print("  value: float         - 현재 값")
	print("  step: float          - 변화 단위 (0.01)")
	print("  ratio: float         - 0~1 비율 (읽기/쓰기)")
	print("  show_percentage      - 퍼센트 텍스트 표시")
	print("  fill_mode            - 채우기 방향")

	print()

# ============================================
# 5. LineEdit - 한 줄 텍스트 입력
# ============================================

func _demonstrate_line_edit():
	print("--- 5. LineEdit (한 줄 텍스트 입력) ---")

	# 기본 LineEdit
	var input = LineEdit.new()
	input.name = "NameInput"
	input.placeholder_text = "이름을 입력하세요..."  # 플레이스홀더
	input.position = Vector2(20, 260)
	input.custom_minimum_size = Vector2(200, 35)
	add_child(input)
	print("  LineEdit 생성: placeholder='이름을 입력하세요...'")

	# 시그널 연결
	input.text_submitted.connect(func(new_text: String):
		print("  >> 입력 완료 (Enter): '%s'" % new_text)
	)
	input.text_changed.connect(func(new_text: String):
		print("  >> 텍스트 변경: '%s'" % new_text)
	)

	# 비밀번호 입력
	var password_input = LineEdit.new()
	password_input.placeholder_text = "비밀번호"
	password_input.secret = true           # 비밀번호 모드 (****)
	password_input.secret_character = "*"  # 마스킹 문자
	password_input.position = Vector2(20, 305)
	password_input.custom_minimum_size = Vector2(200, 35)
	add_child(password_input)
	print("  Password LineEdit: secret = true")

	# 숫자 전용
	print("\n  [입력 제한]")
	print("  input.max_length = 20        # 최대 20자")
	print("  input.editable = false       # 읽기 전용")

	# LineEdit 주요 속성
	print("\n  [LineEdit 주요 속성]")
	print("  text: String         - 현재 텍스트")
	print("  placeholder_text     - 빈칸일 때 안내 텍스트")
	print("  max_length: int      - 최대 글자 수 (0=무제한)")
	print("  editable: bool       - 편집 가능 여부")
	print("  secret: bool         - 비밀번호 모드")
	print("  clear_button_enabled - 지우기 버튼 표시")
	print("  alignment            - 텍스트 정렬")

	# 주요 시그널
	print("\n  [LineEdit 주요 시그널]")
	print("  text_changed(new_text)   - 텍스트가 변경될 때")
	print("  text_submitted(text)     - Enter 키를 눌렀을 때")

	print()

# ============================================
# 6. RichTextLabel - 서식 텍스트
# ============================================

func _demonstrate_rich_text_label():
	print("--- 6. RichTextLabel (서식 텍스트) ---")

	var rtl = RichTextLabel.new()
	rtl.name = "RichText"
	rtl.bbcode_enabled = true  # BBCode 활성화
	rtl.position = Vector2(250, 20)
	rtl.custom_minimum_size = Vector2(300, 120)
	rtl.fit_content = true

	# BBCode로 서식 텍스트 작성
	rtl.text = "[b]굵은 글씨[/b]와 [i]기울임[/i]
[color=red]빨간색[/color], [color=#00ff00]초록색[/color]
[font_size=20]큰 글씨[/font_size]
[wave amp=30 freq=5]물결 효과[/wave]
[rainbow freq=0.5]무지개 텍스트[/rainbow]"

	add_child(rtl)
	print("  RichTextLabel 생성 (BBCode 활성)")

	# BBCode 태그 목록
	print("\n  [주요 BBCode 태그]")
	print("  [b]굵게[/b]              - 볼드")
	print("  [i]기울임[/i]            - 이탤릭")
	print("  [u]밑줄[/u]              - 언더라인")
	print("  [s]취소선[/s]            - 스트라이크")
	print("  [color=red]색상[/color]  - 텍스트 색상")
	print("  [font_size=20]크기[/font_size] - 폰트 크기")
	print("  [center]중앙[/center]    - 중앙 정렬")
	print("  [url=http://...]링크[/url] - 하이퍼링크")
	print("  [img]res://icon.svg[/img]  - 인라인 이미지")
	print("  [wave]물결[/wave]        - 물결 애니메이션")
	print("  [rainbow]무지개[/rainbow] - 무지개 애니메이션")
	print("  [shake]흔들림[/shake]    - 흔들림 효과")

	# 코드로 텍스트 추가
	print("\n  [코드로 서식 추가]")
	print("  rtl.push_color(Color.RED)")
	print("  rtl.add_text('빨간 텍스트')")
	print("  rtl.pop()  # 색상 되돌리기")

	print()

# ============================================
# 7. OptionButton - 드롭다운 선택
# ============================================

func _demonstrate_option_button():
	print("--- 7. OptionButton (드롭다운 선택) ---")

	var option = OptionButton.new()
	option.name = "DifficultySelect"
	option.position = Vector2(250, 160)
	option.custom_minimum_size = Vector2(150, 35)

	# 항목 추가
	option.add_item("쉬움", 0)
	option.add_item("보통", 1)
	option.add_item("어려움", 2)
	option.add_item("지옥", 3)

	option.selected = 1  # "보통" 선택
	add_child(option)

	# 선택 변경 시그널
	option.item_selected.connect(func(index: int):
		print("  >> 난이도 선택: %s (인덱스 %d)" % [option.get_item_text(index), index])
	)
	print("  OptionButton 생성: 4개 항목, 기본='보통'")

	# 주요 메서드
	print("\n  [OptionButton 메서드]")
	print("  add_item(text, id)      - 항목 추가")
	print("  remove_item(index)      - 항목 제거")
	print("  get_item_text(index)    - 항목 텍스트")
	print("  get_selected_id()       - 선택된 항목 ID")
	print("  selected                - 선택된 인덱스")

	print()

# ============================================
# 8. HSlider/VSlider - 슬라이더
# ============================================

func _demonstrate_slider():
	print("--- 8. Slider (슬라이더) ---")

	# 가로 슬라이더
	var slider = HSlider.new()
	slider.name = "VolumeSlider"
	slider.min_value = 0
	slider.max_value = 100
	slider.value = 80
	slider.step = 1          # 1 단위로 변화
	slider.position = Vector2(250, 210)
	slider.custom_minimum_size = Vector2(150, 20)
	add_child(slider)

	# 슬라이더 라벨
	var slider_label = Label.new()
	slider_label.text = "볼륨: 80"
	slider_label.position = Vector2(410, 208)
	add_child(slider_label)

	# 값 변경 시그널
	slider.value_changed.connect(func(new_value: float):
		slider_label.text = "볼륨: %d" % int(new_value)
		print("  >> 볼륨: %d%%" % int(new_value))
	)
	print("  HSlider 생성: 0-100, step=1, 기본=80")

	print("\n  [Slider 속성 (Range 상속)]")
	print("  min_value, max_value, value, step")
	print("  editable: bool    - 사용자 조작 가능 여부")
	print("  scrollable: bool  - 마우스 휠로 조작")

	print()

# ============================================
# 9. Control 공통 속성
# ============================================

func _demonstrate_control_properties():
	print("--- 9. Control 공통 속성 ---")

	print("[위치와 크기]")
	print("  position: Vector2       - 부모 기준 위치")
	print("  global_position: Vector2 - 화면 절대 위치")
	print("  size: Vector2           - 크기")
	print("  custom_minimum_size     - 최소 크기 (컨테이너용)")
	print("  rotation: float         - 회전 (라디안)")
	print("  scale: Vector2          - 스케일")
	print("  pivot_offset: Vector2   - 회전/스케일 중심점")

	print("\n[가시성]")
	print("  visible: bool    - 표시 여부")
	print("  modulate: Color  - 색상 조정 (알파=투명도)")
	print("  self_modulate    - 자식에 영향 안 주는 색상")

	print("\n[마우스]")
	print("  mouse_filter:")
	print("    MOUSE_FILTER_STOP    - 마우스 이벤트 소비 (기본)")
	print("    MOUSE_FILTER_PASS    - 이벤트를 자식 + 부모에 전달")
	print("    MOUSE_FILTER_IGNORE  - 마우스 이벤트 무시 (투명)")
	print("  mouse_default_cursor_shape - 커서 모양")
	print("  tooltip_text: String   - 마우스 호버 시 툴팁")

	print("\n[포커스]")
	print("  focus_mode:")
	print("    FOCUS_NONE  - 포커스 불가")
	print("    FOCUS_CLICK - 클릭으로 포커스")
	print("    FOCUS_ALL   - 클릭 + Tab키로 포커스")

	print()

# ============================================
# 10. Anchor와 Margin 시스템
# ============================================

func _demonstrate_anchors():
	print("--- 10. Anchor 시스템 (반응형 UI) ---")

	print("[Anchor란?]")
	print("  부모 Control의 크기가 변할 때 자식의 위치를 조정하는 기준점")
	print("  anchor_left, anchor_top, anchor_right, anchor_bottom")
	print("  값 범위: 0.0 ~ 1.0 (부모의 비율)")

	print("\n[프리셋 (Anchor Preset)]")
	print("  PRESET_TOP_LEFT      - 좌상단 (기본)")
	print("  PRESET_TOP_RIGHT     - 우상단")
	print("  PRESET_BOTTOM_LEFT   - 좌하단")
	print("  PRESET_BOTTOM_RIGHT  - 우하단")
	print("  PRESET_CENTER        - 중앙")
	print("  PRESET_FULL_RECT     - 부모 전체 채우기")
	print("  PRESET_TOP_WIDE      - 상단 전체 너비")
	print("  PRESET_BOTTOM_WIDE   - 하단 전체 너비")
	print("  PRESET_LEFT_WIDE     - 좌측 전체 높이")
	print("  PRESET_RIGHT_WIDE    - 우측 전체 높이")

	# 코드로 앵커 설정 예시
	print("\n[코드로 앵커 설정]")
	print("""  # 중앙 정렬
  var panel = Panel.new()
  panel.set_anchors_preset(Control.PRESET_CENTER)
  panel.size = Vector2(200, 100)

  # 전체 화면 채우기
  var bg = ColorRect.new()
  bg.set_anchors_preset(Control.PRESET_FULL_RECT)

  # 우하단에 미니맵
  var minimap = TextureRect.new()
  minimap.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
  minimap.offset_left = -150
  minimap.offset_top = -150
  minimap.size = Vector2(150, 150)

  # 상단 전체 너비 (HP바 등)
  var top_bar = ProgressBar.new()
  top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
  top_bar.custom_minimum_size.y = 30""")

	# 실제 적용
	var center_label = Label.new()
	center_label.text = "GAME OVER"
	center_label.add_theme_font_size_override("font_size", 32)
	center_label.add_theme_color_override("font_color", Color.RED)
	center_label.set_anchors_preset(Control.PRESET_CENTER)
	center_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	center_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_label.visible = false  # 숨겨둠
	add_child(center_label)
	print("\n  중앙 'GAME OVER' 라벨 생성 (숨김 상태)")

	print("\n=== Control 노드 기초 학습 완료 ===")
