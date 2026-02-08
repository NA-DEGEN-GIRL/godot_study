# Chapter 04 - 2D Basics
# 01-input-handling.gd - Input Handling in Godot
#
# 이 파일에서 배울 내용:
# - Input.is_action_pressed()와 is_action_just_pressed() 차이
# - Input.get_axis()와 Input.get_vector()로 방향 입력 받기
# - InputEvent를 통한 이벤트 기반 입력 처리
# - Input Map 설정과 커스텀 액션

extends Node

# ============================================
# 1. Input Map 설정 (에디터에서 설정 필요)
# ============================================

# Project > Project Settings > Input Map 에서 액션을 정의합니다.
# 기본으로 제공되는 액션들:
#   ui_accept  -> Enter, Space
#   ui_cancel  -> Escape
#   ui_left    -> Left Arrow, A
#   ui_right   -> Right Arrow, D
#   ui_up      -> Up Arrow, W
#   ui_down    -> Down Arrow, S

# 커스텀 액션 예시 (Input Map에서 추가):
#   move_left  -> A, Left Arrow
#   move_right -> D, Right Arrow
#   move_up    -> W, Up Arrow
#   move_down  -> S, Down Arrow
#   jump       -> Space
#   attack     -> Left Mouse Button, Z
#   sprint     -> Shift

# 코드로 Input Map에 액션을 추가할 수도 있습니다
func setup_input_actions():
	# 이미 있는 액션은 건너뜀
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var event_a := InputEventKey.new()
		event_a.keycode = KEY_A
		InputMap.action_add_event("move_left", event_a)
		var event_left := InputEventKey.new()
		event_left.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", event_left)

	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var event_d := InputEventKey.new()
		event_d.keycode = KEY_D
		InputMap.action_add_event("move_right", event_d)
		var event_right := InputEventKey.new()
		event_right.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", event_right)

	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var event_w := InputEventKey.new()
		event_w.keycode = KEY_W
		InputMap.action_add_event("move_up", event_w)
		var event_up := InputEventKey.new()
		event_up.keycode = KEY_UP
		InputMap.action_add_event("move_up", event_up)

	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var event_s := InputEventKey.new()
		event_s.keycode = KEY_S
		InputMap.action_add_event("move_down", event_s)
		var event_down := InputEventKey.new()
		event_down.keycode = KEY_DOWN
		InputMap.action_add_event("move_down", event_down)

	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var event_space := InputEventKey.new()
		event_space.keycode = KEY_SPACE
		InputMap.action_add_event("jump", event_space)

	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
		var event_z := InputEventKey.new()
		event_z.keycode = KEY_Z
		InputMap.action_add_event("attack", event_z)
		var event_click := InputEventMouseButton.new()
		event_click.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("attack", event_click)

	if not InputMap.has_action("sprint"):
		InputMap.add_action("sprint")
		var event_shift := InputEventKey.new()
		event_shift.keycode = KEY_SHIFT
		InputMap.action_add_event("sprint", event_shift)


func _ready():
	print("=== 입력 처리 (Input Handling) ===\n")

	# 커스텀 액션 등록
	setup_input_actions()

	# ============================================
	# 2. Input 싱글톤 메서드 설명
	# ============================================
	print("--- Input 메서드 비교 ---\n")

	print("Input.is_action_pressed('action'):")
	print("  - 키를 누르고 있는 동안 매 프레임 true")
	print("  - 이동, 달리기 등 지속적인 입력에 사용")
	print("  - 예: 화살표 키로 캐릭터 이동")

	print("\nInput.is_action_just_pressed('action'):")
	print("  - 키를 누른 첫 프레임에만 true")
	print("  - 점프, 공격 등 일회성 입력에 사용")
	print("  - 예: 스페이스바로 점프")

	print("\nInput.is_action_just_released('action'):")
	print("  - 키를 뗀 첫 프레임에만 true")
	print("  - 차징 공격 해제 등에 사용")
	print("  - 예: 활 시위를 놓아 화살 발사")

	# ============================================
	# 3. get_axis와 get_vector
	# ============================================
	print("\n--- get_axis / get_vector ---\n")

	print("Input.get_axis('negative', 'positive'):")
	print("  - 두 액션을 축(axis)으로 결합")
	print("  - -1.0 ~ 0.0 ~ 1.0 범위의 float 반환")
	print("  - 예: Input.get_axis('move_left', 'move_right')")
	print("  - 왼쪽 누르면 -1, 오른쪽 누르면 1, 안 누르면 0")
	print("  - 게임패드 스틱은 중간값도 반환 (0.5 등)")

	print("\nInput.get_vector('left', 'right', 'up', 'down'):")
	print("  - 4개 액션을 2D 벡터로 결합")
	print("  - Vector2 반환 (자동 정규화됨)")
	print("  - 예: Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')")
	print("  - 대각선 이동 시 자동으로 정규화 (속도 일정)")

	# 수동 vs get_vector 비교
	print("\n수동 방향 계산 vs get_vector:")
	print("  # 수동 (대각선에서 더 빠름 - 버그)")
	print("  var dir = Vector2.ZERO")
	print("  if Input.is_action_pressed('move_left'):  dir.x -= 1")
	print("  if Input.is_action_pressed('move_right'): dir.x += 1")
	print("  if Input.is_action_pressed('move_up'):    dir.y -= 1")
	print("  if Input.is_action_pressed('move_down'):  dir.y += 1")
	print("  dir = dir.normalized()  # 정규화 필요!")
	print("")
	print("  # get_vector (자동 정규화 - 권장!)")
	print("  var dir = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')")

	# 정규화의 중요성
	print("\n정규화(Normalize) 왜 필요한가?")
	var diagonal := Vector2(1, 1)
	print("  Vector2(1, 1).length() = %.3f (1보다 큼!)" % diagonal.length())
	print("  Vector2(1, 1).normalized() = %s" % str(diagonal.normalized()))
	print("  정규화 후 length() = %.3f (정확히 1)" % diagonal.normalized().length())
	print("  -> 대각선 이동 속도가 직선과 동일해짐")

	# ============================================
	# 4. action_strength (아날로그 입력)
	# ============================================
	print("\n--- action_strength (아날로그) ---\n")

	print("Input.get_action_strength('action'):")
	print("  - 0.0 ~ 1.0 범위의 입력 강도")
	print("  - 키보드: 0(안 누름) 또는 1(누름)")
	print("  - 게임패드: 0.0 ~ 1.0 (트리거, 스틱)")
	print("  - 예: 트리거 압력에 따른 가속")

	print("\nInput.get_action_raw_strength('action'):")
	print("  - 데드존(deadzone) 적용 전의 원시 값")
	print("  - 게임패드 스틱 캘리브레이션에 유용")

	# ============================================
	# 5. 마우스 입력
	# ============================================
	print("\n--- 마우스 입력 ---\n")

	print("마우스 위치:")
	print("  get_viewport().get_mouse_position() -> 뷰포트 기준")
	print("  get_global_mouse_position()         -> 월드 기준 (Node2D)")
	print("  get_local_mouse_position()          -> 노드 기준 (Node2D)")

	print("\n마우스 버튼:")
	print("  Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)")
	print("  Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)")
	print("  Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)")

	print("\n마우스 커서 제어:")
	print("  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   -> 표시")
	print("  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)    -> 숨김")
	print("  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  -> 캡처 (FPS)")
	print("  Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)  -> 창 안에 가둠")

	# ============================================
	# 6. InputEvent 이벤트 기반 처리 (개념)
	# ============================================
	print("\n--- InputEvent 이벤트 기반 ---\n")

	print("_input(event) / _unhandled_input(event) 사용:")
	print("")
	print("func _unhandled_input(event: InputEvent):")
	print("  # 키보드 이벤트")
	print("  if event is InputEventKey:")
	print("    if event.pressed and event.keycode == KEY_ESCAPE:")
	print("      get_tree().quit()")
	print("")
	print("  # 마우스 클릭 이벤트")
	print("  if event is InputEventMouseButton:")
	print("    if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:")
	print("      print('클릭 위치: ', event.position)")
	print("")
	print("  # 마우스 이동 이벤트")
	print("  if event is InputEventMouseMotion:")
	print("    print('마우스 이동: ', event.relative)")
	print("")
	print("  # 액션 기반 처리")
	print("  if event.is_action_pressed('jump'):")
	print("    print('점프!')")
	print("    get_viewport().set_input_as_handled()  # 입력 소비")

	# ============================================
	# 7. _input vs _unhandled_input
	# ============================================
	print("\n--- _input vs _unhandled_input ---\n")

	print("입력 전파 순서:")
	print("  1. _input()             -> 모든 입력 (가장 먼저)")
	print("  2. UI 컨트롤 처리       -> Button, LineEdit 등")
	print("  3. _unhandled_input()   -> UI에서 처리 안 된 입력")
	print("")
	print("게임플레이 입력 -> _unhandled_input() 사용 (권장)")
	print("  UI가 입력을 가로채면 게임에 전달되지 않음 (올바른 동작)")
	print("")
	print("모든 입력 감시 -> _input() 사용")
	print("  UI와 무관하게 항상 입력을 받음")

	# ============================================
	# 8. 실전 패턴: 입력 버퍼링
	# ============================================
	print("\n--- 실전 패턴: 입력 버퍼링 ---\n")

	print("점프 입력 버퍼 (coyote time과 함께 사용):\n")
	print("""var jump_buffer_time: float = 0.1  # 100ms 버퍼
var jump_buffer_timer: float = 0.0

func _process(delta):
    # 버퍼 타이머 감소
    if jump_buffer_timer > 0:
        jump_buffer_timer -= delta

    # 점프 버튼을 누르면 버퍼 시작
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time

    # 착지 시 버퍼 확인
    if is_on_floor() and jump_buffer_timer > 0:
        jump()
        jump_buffer_timer = 0.0""")

	# ============================================
	# 9. 실전 패턴: 액션 리매핑
	# ============================================
	print("\n--- 실전 패턴: 키 리매핑 ---\n")

	print("""func remap_action(action: String, new_key: Key):
    # 기존 키 이벤트 제거
    var events = InputMap.action_get_events(action)
    for event in events:
        if event is InputEventKey:
            InputMap.action_erase_event(action, event)

    # 새 키 이벤트 추가
    var new_event = InputEventKey.new()
    new_event.keycode = new_key
    InputMap.action_add_event(action, new_event)
    print("'%s' 키가 변경되었습니다" % action)""")

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. is_action_pressed(): 누르고 있는 동안 (이동)")
	print("2. is_action_just_pressed(): 누른 순간 (점프, 공격)")
	print("3. get_axis(): 1D 축 입력 (-1 ~ 1)")
	print("4. get_vector(): 2D 방향 입력 (자동 정규화)")
	print("5. _unhandled_input(): UI 이후의 게임 입력")
	print("6. _input(): 모든 입력 (UI 포함)")
	print("7. 입력 버퍼링: 반응성 좋은 조작감")
	print("8. InputMap: 코드로 입력 액션 관리")

	print("\n(이 스크립트는 개념 설명용입니다.")
	print(" 실제 입력 테스트는 02-movement-basics.gd를 참고하세요)")
