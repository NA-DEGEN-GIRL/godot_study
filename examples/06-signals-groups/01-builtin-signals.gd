# Chapter 06 - Signals & Groups
# 01-builtin-signals.gd - Godot 내장 시그널 활용
#
# 이 파일에서 배울 내용:
# - 시그널(Signal)의 개념과 옵저버 패턴
# - connect()로 시그널 연결하는 방법
# - Button, Timer, Area2D 등의 내장 시그널
# - 람다(Lambda) 함수를 활용한 간결한 연결
# - 시그널 연결 해제 (disconnect)와 관리
#
# 시그널은 Godot의 핵심 통신 방법입니다.
# 노드 간의 느슨한 결합(loose coupling)을 가능하게 합니다.

extends Node

# ============================================
# 1. 시그널이란?
# ============================================
# 시그널 = 이벤트 알림 시스템
#
# 전통적 방식 (강결합):
#   button._on_pressed() -> parent.do_something()
#   -> Button이 부모를 직접 알아야 함 (의존성 발생)
#
# 시그널 방식 (느슨한 결합):
#   button.pressed 시그널 -> 연결된 모든 함수 호출
#   -> Button은 누가 듣고 있는지 몰라도 됨
#
# 비유: 라디오 방송
#   방송국(시그널 발신) -> 라디오(시그널 수신)
#   방송국은 누가 듣는지 모름, 라디오만 주파수 맞추면 됨

func _ready():
	print("=== Chapter 06-1: 내장 시그널 활용 ===\n")

	_demonstrate_button_signals()
	_demonstrate_timer_signals()
	_demonstrate_node_signals()
	_demonstrate_lambda_connections()
	_demonstrate_connection_flags()
	_demonstrate_disconnect()
	_demonstrate_callable_methods()
	_common_builtin_signals()

# ============================================
# 2. Button 시그널
# ============================================

func _demonstrate_button_signals():
	print("--- 2. Button 시그널 ---")

	# Button 생성
	var button = Button.new()
	button.text = "클릭하세요"
	button.name = "TestButton"
	add_child(button)

	# 방법 1: 함수 참조로 연결
	print("[방법 1] 함수 참조 연결:")
	print("  button.pressed.connect(_on_button_pressed)")
	button.pressed.connect(_on_button_pressed)

	# 방법 2: 람다로 연결
	print("\n[방법 2] 람다 함수 연결:")
	print("  button.pressed.connect(func(): print('클릭됨!'))")

	# Button의 주요 시그널 목록
	print("\n[Button 주요 시그널]")
	print("  pressed          - 버튼이 눌렸을 때 (가장 많이 사용)")
	print("  button_down      - 버튼을 누르는 순간")
	print("  button_up        - 버튼에서 손을 떼는 순간")
	print("  toggled(toggled_on: bool) - 토글 버튼 상태 변경 시")
	print("  mouse_entered    - 마우스 커서가 버튼 위에 올라갔을 때")
	print("  mouse_exited     - 마우스 커서가 버튼에서 벗어났을 때")

	# 토글 버튼 예시
	var toggle_btn = CheckButton.new()
	toggle_btn.text = "음소거"
	toggle_btn.toggled.connect(func(on: bool):
		print("  음소거: %s" % ("ON" if on else "OFF"))
	)
	add_child(toggle_btn)
	print("\n  CheckButton 토글 시그널 연결 완료")

	# 시그널을 코드로 발생시키기 (테스트용)
	print("\n[pressed 시그널 수동 발생 (emit)]")
	button.pressed.emit()

	print()

func _on_button_pressed():
	print("  -> _on_button_pressed() 호출됨!")

# ============================================
# 3. Timer 시그널
# ============================================

func _demonstrate_timer_signals():
	print("--- 3. Timer 시그널 ---")

	# Timer 생성 및 설정
	var timer = Timer.new()
	timer.name = "CooldownTimer"
	timer.wait_time = 2.0           # 2초 대기
	timer.one_shot = true           # 한 번만 실행
	timer.autostart = false         # 자동 시작 안 함
	add_child(timer)

	# timeout 시그널 연결
	print("[Timer timeout 시그널]")
	print("  timer.timeout.connect(_on_timer_timeout)")
	timer.timeout.connect(_on_timer_timeout)

	# 람다로 연결
	print("  timer.timeout.connect(func(): print('타이머 완료!'))")

	# Timer 주요 속성
	print("\n[Timer 주요 속성]")
	print("  wait_time: float   - 대기 시간 (초)")
	print("  one_shot: bool     - true: 한 번만, false: 반복")
	print("  autostart: bool    - 씬 시작 시 자동 시작")
	print("  paused: bool       - 일시정지 여부")

	# Timer 제어 메서드
	print("\n[Timer 제어 메서드]")
	print("  timer.start()       - 타이머 시작")
	print("  timer.start(3.0)    - 3초로 설정하고 시작")
	print("  timer.stop()        - 타이머 정지 (초기화)")
	print("  timer.is_stopped()  - 정지 상태 확인")
	print("  timer.time_left     - 남은 시간 (읽기 전용)")

	# SceneTree 타이머 (노드 생성 없이 간단하게)
	print("\n[get_tree().create_timer() - 간편 타이머]")
	print("  # 노드를 만들지 않는 일회성 타이머")
	print("  await get_tree().create_timer(1.0).timeout")
	print("  print('1초 후 실행')")

	# 반복 타이머 패턴
	print("\n[반복 타이머 패턴]")
	print("""  var spawn_timer = Timer.new()
  spawn_timer.wait_time = 0.5
  spawn_timer.one_shot = false  # 반복!
  spawn_timer.timeout.connect(_spawn_enemy)
  add_child(spawn_timer)
  spawn_timer.start()""")

	print()

func _on_timer_timeout():
	print("  -> 타이머 완료!")

# ============================================
# 4. Node 생명주기 시그널
# ============================================

func _demonstrate_node_signals():
	print("--- 4. Node 생명주기 시그널 ---")

	# 자식 노드 생성
	var child = Node.new()
	child.name = "TestChild"

	# Node의 주요 시그널
	print("[Node 기본 시그널]")
	print("  ready               - 노드와 자식이 모두 준비됨")
	print("  tree_entered        - 씬 트리에 추가됨")
	print("  tree_exiting        - 씬 트리에서 제거 시작")
	print("  tree_exited         - 씬 트리에서 완전히 제거됨")
	print("  child_entered_tree  - 자식 노드가 추가됨")
	print("  child_exiting_tree  - 자식 노드가 제거 시작")
	print("  renamed             - 노드 이름이 변경됨")

	# 시그널 연결
	child.tree_entered.connect(func():
		print("  -> '%s' 씬 트리에 추가됨" % child.name)
	)
	child.tree_exited.connect(func():
		print("  -> '%s' 씬 트리에서 제거됨" % child.name)
	)

	# 부모의 child 시그널
	child_entered_tree.connect(func(node: Node):
		print("  -> 자식 '%s' 추가 감지" % node.name)
	)

	# 자식 추가/제거 실행
	print("\n[자식 노드 추가]")
	add_child(child)

	print("\n[자식 노드 제거]")
	child.queue_free()

	# CanvasItem 시그널
	print("\n[CanvasItem 시그널 (2D 노드)]")
	print("  visibility_changed  - 가시성 변경")
	print("  hidden              - 숨겨짐")
	print("  draw                - 그리기 요청 (_draw 호출)")

	print()

# ============================================
# 5. 람다(Lambda) 연결 패턴
# ============================================

func _demonstrate_lambda_connections():
	print("--- 5. 람다 함수 연결 패턴 ---")

	# 패턴 1: 기본 람다
	print("[패턴 1] 기본 람다")
	print("  signal.connect(func(): print('간단!'))")

	# 패턴 2: 매개변수가 있는 람다
	print("\n[패턴 2] 매개변수 받기")
	print("  area.body_entered.connect(func(body):")
	print("      print('진입: ', body.name))")

	# 패턴 3: 여러 줄 람다
	print("\n[패턴 3] 여러 줄 람다")
	print("""  button.pressed.connect(func():
      score += 10
      update_score_display()
      play_sound("click")
  )""")

	# 패턴 4: bind()로 추가 데이터 전달
	print("\n[패턴 4] bind()로 추가 데이터 전달")
	var buttons_data = ["공격", "방어", "마법"]
	for i in range(buttons_data.size()):
		var btn = Button.new()
		btn.text = buttons_data[i]
		# bind로 인덱스와 이름을 전달
		btn.pressed.connect(_on_action_button.bind(i, buttons_data[i]))
		add_child(btn)
	print("  버튼 3개 생성, 각각 bind로 데이터 연결")
	print("  btn.pressed.connect(_on_action.bind(0, '공격'))")
	print("  btn.pressed.connect(_on_action.bind(1, '방어'))")
	print("  btn.pressed.connect(_on_action.bind(2, '마법'))")

	# 패턴 5: 클로저(Closure) 활용
	print("\n[패턴 5] 클로저 - 외부 변수 캡처")
	var counter = 0
	var count_btn = Button.new()
	count_btn.text = "카운트"
	count_btn.pressed.connect(func():
		counter += 1
		print("  카운트: %d" % counter)
	)
	add_child(count_btn)
	print("  람다가 외부 변수 'counter'를 캡처하여 사용")

	# 수동으로 시그널 발생시켜 테스트
	count_btn.pressed.emit()
	count_btn.pressed.emit()
	count_btn.pressed.emit()

	print()

func _on_action_button(index: int, action_name: String):
	print("  -> 액션 %d: %s 실행!" % [index, action_name])

# ============================================
# 6. 연결 플래그 (Connection Flags)
# ============================================

func _demonstrate_connection_flags():
	print("--- 6. 연결 플래그 ---")

	var btn = Button.new()
	btn.name = "FlagTestBtn"
	add_child(btn)

	# CONNECT_ONE_SHOT: 한 번만 실행
	print("[CONNECT_ONE_SHOT] - 한 번만 실행 후 자동 연결 해제")
	print("  signal.connect(callback, CONNECT_ONE_SHOT)")
	print("  용도: 한 번만 발동하는 트리거, 첫 클릭 이벤트")

	var one_shot_count = 0
	btn.pressed.connect(func():
		one_shot_count += 1
		print("  ONE_SHOT 실행: %d번째 (이후 실행 안 됨)" % one_shot_count)
	, CONNECT_ONE_SHOT)

	print("  emit 3회 호출:")
	btn.pressed.emit()  # 실행됨
	btn.pressed.emit()  # 실행 안 됨 (이미 해제)
	btn.pressed.emit()  # 실행 안 됨

	# CONNECT_DEFERRED: 프레임 끝에 실행
	print("\n[CONNECT_DEFERRED] - 현재 프레임 끝에 지연 실행")
	print("  signal.connect(callback, CONNECT_DEFERRED)")
	print("  용도: 물리 처리 중 노드 제거, 씬 전환")
	print("  주의: queue_free() 호출 시 안전하게 처리")

	# CONNECT_REFERENCE_COUNTED: 참조 카운트 기반
	print("\n[CONNECT_REFERENCE_COUNTED] - 참조 카운트 기반 연결")
	print("  같은 Callable을 여러 번 connect해도 한 번만 연결")

	# 플래그 조합
	print("\n[플래그 조합]")
	print("  signal.connect(callback, CONNECT_ONE_SHOT | CONNECT_DEFERRED)")
	print("  -> 한 번만, 지연 실행")

	btn.queue_free()
	print()

# ============================================
# 7. 시그널 연결 해제 (disconnect)
# ============================================

func _demonstrate_disconnect():
	print("--- 7. 시그널 연결 해제 ---")

	var btn = Button.new()
	add_child(btn)

	# 연결
	var callback = _on_disconnect_test
	btn.pressed.connect(callback)
	print("연결 상태: %s" % str(btn.pressed.is_connected(callback)))

	# 연결 해제
	btn.pressed.disconnect(callback)
	print("해제 후: %s" % str(btn.pressed.is_connected(callback)))

	# is_connected 확인 후 안전하게 해제
	print("\n[안전한 연결 해제 패턴]")
	print("""  if signal.is_connected(callback):
      signal.disconnect(callback)""")

	# 람다의 경우 연결 해제가 어려움
	print("\n[주의: 람다 연결 해제]")
	print("  람다 함수는 변수에 저장해야 disconnect 가능")
	print("""  var my_lambda = func(): print("hello")
  signal.connect(my_lambda)
  # 나중에...
  signal.disconnect(my_lambda)""")

	print("\n  익명 람다는 참조를 잃어서 disconnect 불가!")
	print("  signal.connect(func(): print('hello'))  # 해제 불가!")

	# 모든 연결 가져오기
	print("\n[get_connections() - 모든 연결 정보]")
	btn.pressed.connect(func(): pass)
	btn.pressed.connect(func(): pass)
	var connections = btn.pressed.get_connections()
	print("  연결 수: %d" % connections.size())
	for conn in connections:
		print("  - callable: %s, flags: %d" % [str(conn.callable), conn.flags])

	btn.queue_free()
	print()

func _on_disconnect_test():
	print("  -> disconnect 테스트 콜백")

# ============================================
# 8. Callable 메서드들
# ============================================

func _demonstrate_callable_methods():
	print("--- 8. Callable 관련 메서드 ---")

	# Callable 생성
	var my_callable = Callable(self, "_on_button_pressed")
	print("Callable 생성: Callable(self, '_on_button_pressed')")
	print("  is_valid: %s" % str(my_callable.is_valid()))
	print("  get_method: %s" % str(my_callable.get_method()))
	print("  get_object: %s" % str(my_callable.get_object()))

	# Callable 호출
	print("\n[Callable 직접 호출]")
	print("  my_callable.call()  # 함수 호출")
	my_callable.call()

	# bind로 인자 미리 바인딩
	print("\n[Callable.bind() - 인자 바인딩]")
	var bound = _on_action_button.bind(99, "특수공격")
	print("  bound = func.bind(99, '특수공격')")
	bound.call()

	print()

# ============================================
# 9. 자주 사용하는 내장 시그널 총정리
# ============================================

func _common_builtin_signals():
	print("--- 9. 자주 사용하는 내장 시그널 총정리 ---")

	print("[Node]")
	print("  ready, tree_entered, tree_exited")
	print("  child_entered_tree(node), child_exiting_tree(node)")

	print("\n[BaseButton (Button, CheckBox, CheckButton)]")
	print("  pressed, button_down, button_up")
	print("  toggled(toggled_on: bool)")

	print("\n[Timer]")
	print("  timeout")

	print("\n[Area2D / Area3D]")
	print("  body_entered(body), body_exited(body)")
	print("  area_entered(area), area_exited(area)")

	print("\n[CharacterBody2D]")
	print("  (직접 시그널 없음 - move_and_slide 반환값 사용)")

	print("\n[RigidBody2D]")
	print("  body_entered(body), body_exited(body)")
	print("  sleeping_state_changed()")

	print("\n[AnimationPlayer]")
	print("  animation_finished(anim_name)")
	print("  animation_started(anim_name)")
	print("  animation_changed(old_name, new_name)")

	print("\n[Tween]")
	print("  finished")
	print("  step_finished(idx: int)")
	print("  loop_finished(loop_count: int)")

	print("\n[LineEdit]")
	print("  text_changed(new_text), text_submitted(text)")

	print("\n[TextEdit]")
	print("  text_changed()")

	print("\n[Range (HSlider, VSlider, ProgressBar, SpinBox)]")
	print("  value_changed(value: float)")

	print("\n[OptionButton / ItemList]")
	print("  item_selected(index: int)")

	print("\n[HTTPRequest]")
	print("  request_completed(result, code, headers, body)")

	print("\n=== 내장 시그널 학습 완료 ===")
