# Chapter 08 - Animation
# 02-tween-basics.gd - Tween 기초와 활용
#
# 이 파일에서 배울 내용:
# - create_tween()으로 Tween 생성
# - tween_property()로 속성 애니메이션
# - tween_callback()으로 콜백 호출
# - tween_method()로 커스텀 보간
# - 체이닝(순차 실행)과 parallel(동시 실행)
# - 반복(loop), 지연(delay), 속도 제어
#
# Tween은 코드 기반 애니메이션 시스템입니다.
# AnimationPlayer보다 간단하고 일회성 효과에 적합합니다.

extends Node2D

# ============================================
# 1. Tween vs AnimationPlayer
# ============================================
# AnimationPlayer:
#   - 에디터에서 시각적으로 작업
#   - 복잡한/긴 애니메이션
#   - 반복 사용하는 애니메이션 (idle, walk, run)
#   - 여러 트랙을 동시에 관리
#
# Tween:
#   - 코드로 간단하게 생성
#   - 일회성/동적 애니메이션
#   - UI 효과 (페이드, 슬라이드, 팝)
#   - 런타임에 값이 결정되는 애니메이션
#   - 메서드 체이닝으로 직관적인 코드

var demo_sprite: Sprite2D
var demo_label: Label
var demo_panel: Panel

func _ready():
	print("=== Chapter 08-2: Tween 기초 ===\n")

	_setup_demo_nodes()
	_demonstrate_create_tween()
	_demonstrate_tween_property()
	_demonstrate_tween_callback()
	_demonstrate_tween_method()
	_demonstrate_chaining()
	_demonstrate_parallel()
	_demonstrate_loops()
	_demonstrate_tween_control()
	_practical_ui_effects()

# ============================================
# 2. 데모 노드 설정
# ============================================

func _setup_demo_nodes():
	demo_sprite = Sprite2D.new()
	demo_sprite.name = "DemoSprite"
	demo_sprite.position = Vector2(100, 200)
	add_child(demo_sprite)

	demo_label = Label.new()
	demo_label.name = "DemoLabel"
	demo_label.text = "Tween Test"
	demo_label.position = Vector2(100, 50)
	demo_label.add_theme_font_size_override("font_size", 20)
	add_child(demo_label)

	demo_panel = Panel.new()
	demo_panel.name = "DemoPanel"
	demo_panel.position = Vector2(300, 100)
	demo_panel.size = Vector2(200, 100)
	add_child(demo_panel)

	print("  데모 노드 생성 완료\n")

# ============================================
# 3. create_tween() - Tween 생성
# ============================================

func _demonstrate_create_tween():
	print("--- 3. Tween 생성 ---")

	# Tween 생성 (Godot 4 방식)
	print("[create_tween()]")
	print("  var tween = create_tween()")
	print("  - 노드에 바인딩된 Tween 생성")
	print("  - 노드가 삭제되면 Tween도 자동 삭제")
	print("  - 노드가 pause되면 Tween도 pause")

	# SceneTree에서 Tween 생성 (노드 독립)
	print("\n[get_tree().create_tween()]")
	print("  var tween = get_tree().create_tween()")
	print("  - SceneTree에 바인딩 (특정 노드에 종속되지 않음)")
	print("  - 노드가 삭제되어도 Tween 계속 실행")

	# Tween 설정
	print("\n[Tween 설정 메서드]")
	print("  tween.set_trans(Tween.TRANS_QUAD)     # 전환 유형")
	print("  tween.set_ease(Tween.EASE_IN_OUT)     # 이징 유형")
	print("  tween.set_parallel(true)              # 동시 실행 모드")
	print("  tween.set_loops(3)                    # 3회 반복")
	print("  tween.set_loops()                     # 무한 반복")
	print("  tween.set_speed_scale(2.0)            # 2배속")
	print("  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)")

	# 주의: Tween은 일회용!
	print("\n[주의사항]")
	print("  - Tween은 한 번 생성하면 재사용 불가")
	print("  - 새 애니메이션은 새 Tween 생성 필요")
	print("  - 이전 Tween은 자동으로 정리됨")
	print("  - 같은 속성에 여러 Tween이 동시에 동작하면 충돌!")

	# 이전 Tween 중지 패턴
	print("\n[이전 Tween 중지 패턴]")
	print("""  var current_tween: Tween

  func animate():
      if current_tween:
          current_tween.kill()  # 이전 Tween 중지
      current_tween = create_tween()
      current_tween.tween_property(...)""")

	print()

# ============================================
# 4. tween_property() - 속성 애니메이션
# ============================================

func _demonstrate_tween_property():
	print("--- 4. tween_property() ---")

	# 기본 구문
	print("[기본 구문]")
	print("  tween.tween_property(object, property, final_value, duration)")
	print("  - object: 대상 노드")
	print("  - property: 속성 경로 (NodePath)")
	print("  - final_value: 최종 값")
	print("  - duration: 소요 시간 (초)")

	# 위치 이동
	print("\n[예시: 위치 이동]")
	var tween1 = create_tween()
	tween1.tween_property(demo_sprite, "position", Vector2(400, 200), 1.0)
	print("  position -> (400, 200) in 1.0s")

	# 하위 속성 접근 (position:x만 변경)
	print("\n[하위 속성 접근 - 콜론(:)]")
	print("  tween.tween_property(node, 'position:x', 400.0, 1.0)")
	print("  tween.tween_property(node, 'position:y', 200.0, 1.0)")
	print("  tween.tween_property(node, 'modulate:a', 0.5, 0.5)")
	print("  -> position의 x만, modulate의 alpha만 변경")

	# from() - 시작값 지정
	print("\n[.from(value) - 시작값 지정]")
	print("""  tween.tween_property(node, "position", Vector2(400, 200), 1.0) \\
      .from(Vector2(0, 0))  # (0,0)에서 시작""")

	# from_current() - 현재 값에서 시작
	print("\n[.from_current() - 현재 값에서 시작 (기본 동작)]")
	print("  # from_current()는 기본이므로 보통 생략")

	# as_relative() - 상대값
	print("\n[.as_relative() - 상대적 변화]")
	print("""  # 현재 위치에서 오른쪽으로 100 이동
  tween.tween_property(node, "position:x", 100.0, 1.0).as_relative()
  # 절대 좌표가 아닌 '현재값 + 100'""")

	# set_delay() - 지연
	print("\n[.set_delay(seconds) - 시작 지연]")
	print("  tween.tween_property(node, 'modulate:a', 0.0, 0.5).set_delay(1.0)")
	print("  # 1초 후에 페이드 아웃 시작")

	# 전환/이징 개별 설정
	print("\n[.set_trans() / .set_ease() - 개별 이징]")
	print("""  tween.tween_property(node, "position", target, 1.0) \\
      .set_trans(Tween.TRANS_BACK) \\
      .set_ease(Tween.EASE_OUT)""")

	print()

# ============================================
# 5. tween_callback() - 콜백 호출
# ============================================

func _demonstrate_tween_callback():
	print("--- 5. tween_callback() ---")

	print("[특정 시점에 함수 호출]")
	print("  체이닝 중간에 함수를 실행")

	var tween = create_tween()
	tween.tween_callback(func(): print("  1. 시작!"))
	tween.tween_property(demo_label, "modulate:a", 0.5, 0.3)
	tween.tween_callback(func(): print("  2. 반투명!"))
	tween.tween_property(demo_label, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func(): print("  3. 완료!"))

	print("  콜백 3개 삽입: 시작, 중간, 완료")

	# set_delay와 함께
	print("\n[지연 콜백]")
	print("""  tween.tween_callback(func(): print("1초 후!")).set_delay(1.0)""")

	# 실전: queue_free
	print("\n[실전: 페이드 아웃 후 제거]")
	print("""  var tween = create_tween()
  tween.tween_property(self, "modulate:a", 0.0, 0.5)
  tween.tween_callback(queue_free)  # 페이드 완료 후 노드 삭제""")

	# tween_interval - 대기
	print("\n[tween_interval(seconds) - 대기 시간]")
	print("  tween.tween_interval(0.5)  # 0.5초 대기")
	print("  -> tween_callback과 set_delay의 단축형")

	print()

# ============================================
# 6. tween_method() - 커스텀 보간
# ============================================

func _demonstrate_tween_method():
	print("--- 6. tween_method() ---")

	print("[커스텀 보간 함수 호출]")
	print("  tween.tween_method(callable, from, to, duration)")
	print("  - from부터 to까지 보간하며 매 프레임 callable 호출")

	# 예시: 카운트다운
	print("\n[예시: 숫자 카운트업]")
	var tween = create_tween()
	tween.tween_method(
		func(value: float):
			demo_label.text = "Count: %d" % int(value),
		0.0,    # from
		100.0,  # to
		1.0     # duration
	)
	print("  0에서 100까지 1초간 카운트업")

	# 예시: 색상 보간
	print("\n[예시: 색상 그라데이션]")
	print("""  tween.tween_method(
      func(color: Color):
          sprite.modulate = color,
      Color.RED,     # from
      Color.BLUE,    # to
      2.0            # duration
  )""")

	# 예시: ProgressBar 부드러운 변화
	print("\n[예시: ProgressBar 부드러운 값 변화]")
	print("""  func smooth_set_health(new_value: float):
      var tween = create_tween()
      tween.tween_method(
          func(val: float):
              health_bar.value = val
              health_label.text = "%d%%" % int(val),
          health_bar.value,   # 현재값
          new_value,           # 목표값
          0.5                  # 0.5초
      ).set_trans(Tween.TRANS_QUAD)""")

	# 예시: 카메라 줌
	print("\n[예시: 카메라 줌]")
	print("""  func zoom_camera(target_zoom: float, duration: float):
      var tween = create_tween()
      tween.tween_method(
          func(zoom: float):
              camera.zoom = Vector2(zoom, zoom),
          camera.zoom.x,
          target_zoom,
          duration
      ).set_trans(Tween.TRANS_SINE)""")

	print()

# ============================================
# 7. 체이닝 (순차 실행)
# ============================================

func _demonstrate_chaining():
	print("--- 7. 체이닝 - 순차 실행 ---")

	print("[기본 체이닝: 순서대로 실행]")
	print("  Tween은 기본적으로 순차 실행 (하나 끝나면 다음)")

	var tween = create_tween()
	# Step 1: 오른쪽으로 이동
	tween.tween_property(demo_sprite, "position:x", 400.0, 0.5)
	# Step 2: 아래로 이동
	tween.tween_property(demo_sprite, "position:y", 400.0, 0.5)
	# Step 3: 원위치
	tween.tween_property(demo_sprite, "position", Vector2(100, 200), 0.5)

	print("  1. 오른쪽 이동 (0.5s)")
	print("  2. 아래로 이동 (0.5s)")
	print("  3. 원위치 (0.5s)")
	print("  총 1.5초")

	# chain() 메서드 - parallel 후 순차로 전환
	print("\n[.chain() - parallel 이후 순차 전환]")
	print("""  var tween = create_tween().set_parallel(true)
  tween.tween_property(node, "position:x", 400, 0.5)
  tween.tween_property(node, "position:y", 300, 0.5)
  # 여기까지 동시 실행

  tween.chain().tween_property(node, "modulate:a", 0.0, 0.3)
  # chain() 이후는 위의 두 개가 모두 끝난 후 순차 실행""")

	print()

# ============================================
# 8. parallel() - 동시 실행
# ============================================

func _demonstrate_parallel():
	print("--- 8. parallel() - 동시 실행 ---")

	# 방법 1: set_parallel(true) - 전체 동시 실행
	print("[방법 1] set_parallel(true) - 전체 동시")
	var tween1 = create_tween().set_parallel(true)
	tween1.tween_property(demo_sprite, "position:x", 300.0, 0.5)
	tween1.tween_property(demo_sprite, "position:y", 100.0, 0.5)
	tween1.tween_property(demo_sprite, "modulate:a", 0.5, 0.5)
	print("  위치 X, Y, 투명도 동시에 변화")

	# 방법 2: .parallel() - 개별 동시 실행
	print("\n[방법 2] .parallel() - 이전 Tweener와 동시")
	print("""  var tween = create_tween()
  tween.tween_property(node, "position:x", 400, 0.5)
  tween.parallel().tween_property(node, "position:y", 300, 0.5)
  # -> X와 Y가 동시에 변화
  tween.tween_property(node, "modulate:a", 0.0, 0.3)
  # -> 위 둘이 끝나면 투명도 변화""")

	# 실전 조합: 동시 + 순차
	print("\n[실전: 동시 + 순차 조합]")
	print("""  var tween = create_tween()

  # Phase 1: 이동 + 회전 동시
  tween.tween_property(node, "position", target, 0.5)
  tween.parallel().tween_property(node, "rotation", PI, 0.5)

  # Phase 2: Phase 1 완료 후 스케일 + 페이드 동시
  tween.tween_property(node, "scale", Vector2(2, 2), 0.3)
  tween.parallel().tween_property(node, "modulate:a", 0.0, 0.3)

  # Phase 3: 정리
  tween.tween_callback(node.queue_free)""")

	print()

# ============================================
# 9. 반복 (Loops)
# ============================================

func _demonstrate_loops():
	print("--- 9. 반복 (Loops) ---")

	# 유한 반복
	print("[유한 반복: set_loops(count)]")
	var tween1 = create_tween().set_loops(3)
	tween1.tween_property(demo_label, "modulate:a", 0.3, 0.2)
	tween1.tween_property(demo_label, "modulate:a", 1.0, 0.2)
	print("  3회 깜빡임: 1.0 -> 0.3 -> 1.0 (x3)")

	# 무한 반복
	print("\n[무한 반복: set_loops() - 인자 없음]")
	print("""  var tween = create_tween().set_loops()
  tween.tween_property(node, "position:y", -10, 0.5).as_relative()
  tween.tween_property(node, "position:y", 10, 0.5).as_relative()
  # 위아래로 영원히 움직임 (idle 떠다니기)""")

	# 핑퐁 (왕복)
	print("\n[핑퐁 효과]")
	print("""  # Tween 자체에 핑퐁은 없지만 반복으로 구현
  var tween = create_tween().set_loops()
  tween.tween_property(node, "rotation", deg_to_rad(15), 0.5)
  tween.tween_property(node, "rotation", deg_to_rad(-15), 0.5)
  # -15도 ~ 15도 반복 (진자 운동)""")

	# loop_finished 시그널
	print("\n[loop_finished 시그널]")
	print("""  tween.loop_finished.connect(func(loop_count: int):
      print("반복 %d회 완료" % loop_count)
  )""")

	print()

# ============================================
# 10. Tween 제어
# ============================================

func _demonstrate_tween_control():
	print("--- 10. Tween 제어 ---")

	print("[Tween 제어 메서드]")
	print("  tween.pause()          # 일시정지")
	print("  tween.play()           # 재개")
	print("  tween.stop()           # 완전 정지 (값 유지)")
	print("  tween.kill()           # Tween 제거")
	print("  tween.custom_step(0.1) # 수동으로 0.1초 진행")

	print("\n[Tween 상태 확인]")
	print("  tween.is_valid()       # Tween이 아직 유효한지")
	print("  tween.is_running()     # 현재 실행 중인지")
	print("  tween.get_total_elapsed_time()  # 경과 시간")

	print("\n[finished 시그널]")
	print("""  var tween = create_tween()
  tween.tween_property(node, "position", target, 1.0)
  tween.finished.connect(func():
      print("Tween 완료!")
  )
  # 또는 await
  await tween.finished
  print("Tween 완료!")""")

	print("\n[speed_scale - 속도 조절]")
	print("  tween.set_speed_scale(2.0)   # 2배속")
	print("  tween.set_speed_scale(0.5)   # 슬로모션")

	print("\n[pause_mode - 일시정지 동작]")
	print("  TWEEN_PAUSE_BOUND   - 바인딩된 노드와 동일 (기본)")
	print("  TWEEN_PAUSE_STOP    - 게임 일시정지 시 멈춤")
	print("  TWEEN_PAUSE_PROCESS - 일시정지 중에도 실행!")
	print("  -> UI 애니메이션은 PROCESS로 설정하면 pause 중에도 동작")

	print()

# ============================================
# 11. 실전: UI 효과 모음
# ============================================

func _practical_ui_effects():
	print("--- 11. 실전: UI 효과 모음 ---")

	# 1. 페이드 인/아웃
	print("[1. 페이드 인/아웃]")
	print("""  func fade_in(node: Control, duration: float = 0.3):
      node.modulate.a = 0
      node.visible = true
      var tween = create_tween()
      tween.tween_property(node, "modulate:a", 1.0, duration)

  func fade_out(node: Control, duration: float = 0.3):
      var tween = create_tween()
      tween.tween_property(node, "modulate:a", 0.0, duration)
      tween.tween_callback(func(): node.visible = false)""")

	# 2. 슬라이드 인
	print("\n[2. 슬라이드 인 (아래에서 위로)]")
	print("""  func slide_in(node: Control):
      var target_y = node.position.y
      node.position.y += 50  # 아래에서 시작
      node.modulate.a = 0

      var tween = create_tween().set_parallel(true)
      tween.tween_property(node, "position:y", target_y, 0.4) \\
          .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
      tween.tween_property(node, "modulate:a", 1.0, 0.3)""")

	# 3. 팝(Pop) 효과
	print("\n[3. 팝 효과 (커졌다 원래 크기)]")
	print("""  func pop_effect(node: Control):
      node.pivot_offset = node.size / 2  # 중심 기준!
      node.scale = Vector2.ZERO

      var tween = create_tween()
      tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.15) \\
          .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
      tween.tween_property(node, "scale", Vector2.ONE, 0.1)""")

	# 4. 흔들림 효과
	print("\n[4. 흔들림 (Shake)]")
	print("""  func shake(node: Control, intensity: float = 5.0, duration: float = 0.3):
      var original_pos = node.position
      var tween = create_tween()
      var steps = int(duration / 0.05)

      for i in range(steps):
          var offset = Vector2(
              randf_range(-intensity, intensity),
              randf_range(-intensity, intensity)
          )
          tween.tween_property(node, "position",
              original_pos + offset, 0.05)

      tween.tween_property(node, "position", original_pos, 0.05)""")

	# 5. 펄스 효과
	print("\n[5. 펄스 (Pulse) 효과]")
	print("""  func pulse(node: Control, loops: int = 3):
      node.pivot_offset = node.size / 2
      var tween = create_tween().set_loops(loops)
      tween.tween_property(node, "scale", Vector2(1.1, 1.1), 0.15)
      tween.tween_property(node, "scale", Vector2.ONE, 0.15)""")

	# 6. 타자기 효과
	print("\n[6. 타자기(Typewriter) 효과]")
	print("""  func typewriter(label: Label, text: String, char_delay: float = 0.03):
      label.text = ""
      label.visible_characters = 0
      label.text = text

      var tween = create_tween()
      tween.tween_property(label, "visible_characters",
          text.length(), text.length() * char_delay)""")

	# 실행 데모
	print("\n[타자기 효과 데모 실행]")
	demo_label.text = "Hello, Godot World!"
	demo_label.visible_characters = 0

	var typewriter_tween = create_tween()
	typewriter_tween.tween_property(
		demo_label, "visible_characters",
		demo_label.text.length(), 0.8
	)
	print("  '%s' 타자기 효과 0.8초" % demo_label.text)

	print("\n=== Tween 기초 학습 완료 ===")
