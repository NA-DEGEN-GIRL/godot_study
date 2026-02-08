# Chapter 08 - Animation
# 01-animation-player.gd - AnimationPlayer 사용법
#
# 이 파일에서 배울 내용:
# - AnimationPlayer 노드의 역할과 구조
# - 코드로 Animation 리소스 생성
# - 트랙(Track) 추가: 속성, 메서드, 오디오
# - play(), queue(), stop() 제어
# - animation_finished 시그널 활용
# - 애니메이션 블렌드와 속도 제어
#
# AnimationPlayer는 Godot의 핵심 애니메이션 시스템입니다.
# 거의 모든 속성을 시간에 따라 변화시킬 수 있습니다.

extends Node2D

# ============================================
# 1. AnimationPlayer 개요
# ============================================
# AnimationPlayer가 애니메이션할 수 있는 것:
# - 위치, 회전, 스케일 (Transform)
# - 색상, 투명도 (Modulate)
# - 텍스처/스프라이트 프레임 (SpriteFrames)
# - UI 값 (ProgressBar.value, Label.text)
# - 가시성 (visible)
# - 메서드 호출 (특정 시점에 함수 실행)
# - 오디오 재생
# - 셰이더 파라미터
# - 사실상 노드의 모든 속성!

var anim_player: AnimationPlayer
var sprite: Sprite2D
var label: Label

func _ready():
	print("=== Chapter 08-1: AnimationPlayer ===\n")

	_setup_nodes()
	_create_basic_animation()
	_create_complex_animation()
	_demonstrate_playback_control()
	_demonstrate_signals()
	_demonstrate_animation_library()
	_show_common_patterns()

# ============================================
# 2. 테스트 노드 설정
# ============================================

func _setup_nodes():
	print("--- 2. 테스트 노드 설정 ---")

	# 스프라이트 (애니메이션 대상)
	sprite = Sprite2D.new()
	sprite.name = "AnimSprite"
	sprite.position = Vector2(200, 200)
	# 텍스처가 없으면 빈 노드지만 속성 애니메이션은 가능
	add_child(sprite)

	# 라벨 (UI 애니메이션 대상)
	label = Label.new()
	label.name = "AnimLabel"
	label.text = "Hello!"
	label.position = Vector2(200, 50)
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)

	# AnimationPlayer 생성
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)

	print("  Sprite2D, Label, AnimationPlayer 생성 완료")
	print()

# ============================================
# 3. 기본 애니메이션 생성 (코드)
# ============================================

func _create_basic_animation():
	print("--- 3. 기본 애니메이션 생성 ---")

	# Animation 리소스 생성
	var anim = Animation.new()
	anim.length = 1.0              # 애니메이션 길이 (초)
	anim.loop_mode = Animation.LOOP_LINEAR  # 반복 모드

	print("[Animation 속성]")
	print("  length: %.1f초" % anim.length)
	print("  loop_mode: LOOP_LINEAR (반복)")

	# 트랙 1: 위치 이동
	print("\n[트랙 추가: 위치 이동]")
	var pos_track = anim.add_track(Animation.TYPE_VALUE)  # 값 트랙
	anim.track_set_path(pos_track, "AnimSprite:position")  # 대상 속성
	anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC)

	# 키프레임 삽입
	anim.track_insert_key(pos_track, 0.0, Vector2(200, 200))    # 시작
	anim.track_insert_key(pos_track, 0.5, Vector2(400, 150))    # 중간
	anim.track_insert_key(pos_track, 1.0, Vector2(200, 200))    # 끝 (루프)

	print("  트랙: AnimSprite:position")
	print("  키프레임: 0.0s (200,200) -> 0.5s (400,150) -> 1.0s (200,200)")

	# 트랙 2: 투명도 변화
	print("\n[트랙 추가: 투명도]")
	var alpha_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(alpha_track, "AnimSprite:modulate")

	anim.track_insert_key(alpha_track, 0.0, Color(1, 1, 1, 1))   # 불투명
	anim.track_insert_key(alpha_track, 0.5, Color(1, 1, 1, 0.3)) # 반투명
	anim.track_insert_key(alpha_track, 1.0, Color(1, 1, 1, 1))   # 불투명

	print("  트랙: AnimSprite:modulate")
	print("  키프레임: 불투명 -> 반투명 -> 불투명")

	# 트랙 3: 스케일 변화
	print("\n[트랙 추가: 스케일]")
	var scale_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(scale_track, "AnimSprite:scale")

	anim.track_insert_key(scale_track, 0.0, Vector2(1, 1))
	anim.track_insert_key(scale_track, 0.25, Vector2(1.5, 0.7))  # 찌그러짐
	anim.track_insert_key(scale_track, 0.5, Vector2(0.7, 1.5))   # 늘어남
	anim.track_insert_key(scale_track, 1.0, Vector2(1, 1))

	print("  트랙: AnimSprite:scale")
	print("  키프레임: 정상 -> 찌그러짐 -> 늘어남 -> 정상")

	# AnimationLibrary에 추가
	var library = AnimationLibrary.new()
	library.add_animation("bounce", anim)
	anim_player.add_animation_library("", library)

	print("\n  'bounce' 애니메이션 등록 완료")
	print()

# ============================================
# 4. 복합 애니메이션 (메서드 호출 포함)
# ============================================

func _create_complex_animation():
	print("--- 4. 복합 애니메이션 (메서드 호출 트랙) ---")

	var anim = Animation.new()
	anim.length = 2.0
	anim.loop_mode = Animation.LOOP_NONE  # 반복 안 함

	# 메서드 호출 트랙
	print("[메서드 호출 트랙 (TYPE_METHOD)]")
	var method_track = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(method_track, ".")  # 현재 노드 (이 스크립트)

	# 특정 시점에 메서드 호출
	anim.track_insert_key(method_track, 0.0, {
		"method": "_on_anim_event",
		"args": ["시작"]
	})
	anim.track_insert_key(method_track, 1.0, {
		"method": "_on_anim_event",
		"args": ["중간"]
	})
	anim.track_insert_key(method_track, 2.0, {
		"method": "_on_anim_event",
		"args": ["끝"]
	})

	print("  0.0s: _on_anim_event('시작')")
	print("  1.0s: _on_anim_event('중간')")
	print("  2.0s: _on_anim_event('끝')")

	# 라벨 텍스트 변경 트랙 (Discrete)
	print("\n[불연속(Discrete) 값 트랙]")
	var text_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(text_track, "AnimLabel:text")
	anim.value_track_set_update_mode(text_track, Animation.UPDATE_DISCRETE)

	anim.track_insert_key(text_track, 0.0, "Ready...")
	anim.track_insert_key(text_track, 0.5, "Set...")
	anim.track_insert_key(text_track, 1.0, "GO!")
	anim.track_insert_key(text_track, 1.5, "Running!")

	print("  UPDATE_DISCRETE: 텍스트는 보간 없이 즉시 변경")
	print("  0.0s 'Ready...' -> 0.5s 'Set...' -> 1.0s 'GO!'")

	# 가시성 트랙
	print("\n[가시성 트랙]")
	var vis_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(vis_track, "AnimLabel:visible")
	anim.value_track_set_update_mode(vis_track, Animation.UPDATE_DISCRETE)

	anim.track_insert_key(vis_track, 0.0, true)
	anim.track_insert_key(vis_track, 1.5, false)  # 1.5초에 숨김
	anim.track_insert_key(vis_track, 1.7, true)   # 1.7초에 다시 표시

	print("  0s: 표시 -> 1.5s: 숨김 -> 1.7s: 다시 표시")

	# 라이브러리에 추가
	var lib = anim_player.get_animation_library("")
	lib.add_animation("countdown", anim)

	print("\n  'countdown' 애니메이션 등록 완료")
	print()

# 메서드 호출 트랙에서 호출되는 함수
func _on_anim_event(message: String):
	print("  [AnimEvent] %s" % message)

# ============================================
# 5. 재생 제어 (Playback Control)
# ============================================

func _demonstrate_playback_control():
	print("--- 5. 재생 제어 ---")

	# 기본 재생
	print("[play(name)]")
	print("  anim_player.play('bounce')  # 재생 시작")
	anim_player.play("bounce")

	# 주요 제어 메서드
	print("\n[재생 제어 메서드]")
	print("  play(name, blend, speed, from_end)")
	print("    name: 애니메이션 이름")
	print("    blend: 블렌딩 시간 (-1 = 기본)")
	print("    speed: 재생 속도 (1.0 = 기본)")
	print("    from_end: true면 끝에서 역재생")

	print("\n  play_backwards('bounce')   # 역재생")
	print("  pause()                    # 일시정지")
	print("  stop()                     # 정지 (처음으로)")
	print("  stop(false)                # 정지 (현재 위치 유지)")

	# 재생 큐 (Queue)
	print("\n[queue(name) - 재생 큐]")
	print("  현재 애니메이션 끝나면 다음 재생")
	print("  anim_player.play('countdown')")
	print("  anim_player.queue('bounce')  # countdown 끝나면 bounce")

	# 속도 제어
	print("\n[speed_scale - 재생 속도]")
	print("  anim_player.speed_scale = 2.0   # 2배속")
	print("  anim_player.speed_scale = 0.5   # 0.5배속")
	print("  anim_player.speed_scale = -1.0  # 역재생")
	anim_player.speed_scale = 1.0

	# 현재 재생 위치
	print("\n[seek(time) - 특정 시점으로 이동]")
	print("  anim_player.seek(0.5)  # 0.5초 지점으로 점프")
	print("  anim_player.seek(0.0)  # 처음으로")

	# 현재 상태 확인
	print("\n[상태 확인 속성/메서드]")
	print("  is_playing(): %s" % str(anim_player.is_playing()))
	print("  current_animation: '%s'" % anim_player.current_animation)
	print("  current_animation_position: %.2f" % anim_player.current_animation_position)
	print("  current_animation_length: %.2f" % anim_player.current_animation_length)

	# 블렌딩
	print("\n[애니메이션 블렌딩]")
	print("  play('run', 0.3)  # 0.3초에 걸쳐 현재->run 전환")
	print("  # 이전 애니메이션에서 부드럽게 전환됨")

	# 정지
	anim_player.stop()

	print()

# ============================================
# 6. 시그널 활용
# ============================================

func _demonstrate_signals():
	print("--- 6. AnimationPlayer 시그널 ---")

	print("[animation_finished(anim_name: StringName)]")
	print("  애니메이션 재생이 끝났을 때")
	anim_player.animation_finished.connect(_on_animation_finished)

	print("\n[animation_started(anim_name: StringName)]")
	print("  애니메이션 재생이 시작되었을 때")
	anim_player.animation_started.connect(func(anim_name):
		print("  -> 시작: %s" % anim_name)
	)

	print("\n[animation_changed(old_name, new_name)]")
	print("  현재 재생 중인 애니메이션이 변경되었을 때")

	# 시그널 활용 패턴
	print("\n[실전 패턴: 애니메이션 체이닝]")
	print("""
  func play_attack():
      anim_player.play("attack_windup")
      await anim_player.animation_finished
      anim_player.play("attack_strike")
      await anim_player.animation_finished
      anim_player.play("attack_recovery")
      await anim_player.animation_finished
      anim_player.play("idle")
	""")

	print("[실전 패턴: 죽음 애니메이션 후 제거]")
	print("""
  func die():
      anim_player.play("death")
      anim_player.animation_finished.connect(
          func(_name): queue_free(),
          CONNECT_ONE_SHOT
      )
	""")

	# 실제 재생 테스트
	print("\n[countdown 재생 테스트]")
	anim_player.play("countdown")

	print()

func _on_animation_finished(anim_name: StringName):
	print("  -> 완료: %s" % anim_name)

# ============================================
# 7. AnimationLibrary 관리
# ============================================

func _demonstrate_animation_library():
	print("--- 7. AnimationLibrary 관리 ---")

	print("[AnimationLibrary 구조]")
	print("  AnimationPlayer")
	print("    +-- AnimationLibrary '' (기본)")
	print("    |     +-- Animation 'idle'")
	print("    |     +-- Animation 'walk'")
	print("    |     +-- Animation 'run'")
	print("    +-- AnimationLibrary 'combat'")
	print("    |     +-- Animation 'attack'")
	print("    |     +-- Animation 'block'")
	print("    +-- AnimationLibrary 'ui'")
	print("          +-- Animation 'fade_in'")
	print("          +-- Animation 'fade_out'")

	print("\n[라이브러리 사용법]")
	print("  # 기본 라이브러리의 애니메이션")
	print("  anim_player.play('idle')")
	print("")
	print("  # 다른 라이브러리의 애니메이션")
	print("  anim_player.play('combat/attack')")
	print("  anim_player.play('ui/fade_in')")

	# 현재 등록된 애니메이션 목록
	print("\n[현재 등록된 애니메이션]")
	for lib_name in anim_player.get_animation_library_list():
		var lib = anim_player.get_animation_library(lib_name)
		var display_name = "'%s'" % lib_name if lib_name != "" else "(기본)"
		print("  라이브러리 %s:" % display_name)
		for anim_name in lib.get_animation_list():
			var anim = lib.get_animation(anim_name)
			print("    - %s (%.1fs, 트랙 %d개)" % [
				anim_name, anim.length, anim.get_track_count()
			])

	print()

# ============================================
# 8. 자주 사용하는 애니메이션 패턴
# ============================================

func _show_common_patterns():
	print("--- 8. 자주 사용하는 패턴 ---")

	print("[패턴 1: RESET 애니메이션]")
	print("  'RESET' 이름의 애니메이션은 특별합니다.")
	print("  모든 속성의 초기값을 저장하는 용도")
	print("  애니메이션이 끝나면 RESET 상태로 돌아감")

	print("\n[패턴 2: 에디터에서 만든 애니메이션 재생]")
	print("""
  # 씬에 AnimationPlayer가 있고 에디터에서 애니메이션을 만든 경우
  @onready var anim = $AnimationPlayer

  func _ready():
      anim.play("idle")  # 시작 시 idle 재생

  func attack():
      anim.play("attack")
      await anim.animation_finished
      anim.play("idle")
	""")

	print("[패턴 3: 조건부 재생]")
	print("""
  func update_animation():
      if not is_on_floor():
          if velocity.y < 0:
              play_anim("jump")
          else:
              play_anim("fall")
      elif velocity.length() > 10:
          play_anim("run")
      else:
          play_anim("idle")

  func play_anim(anim_name: String):
      if anim_player.current_animation != anim_name:
          anim_player.play(anim_name, 0.2)  # 0.2초 블렌드
	""")

	print("[패턴 4: 속도에 따른 애니메이션 속도]")
	print("""
  func _physics_process(delta):
      # 이동 속도에 비례하여 걷기 애니메이션 속도 조절
      if anim_player.current_animation == "walk":
          anim_player.speed_scale = velocity.length() / MAX_SPEED
	""")

	print("\n[트랙 타입 정리]")
	print("  TYPE_VALUE    - 속성 값 변경 (가장 많이 사용)")
	print("  TYPE_METHOD   - 메서드 호출")
	print("  TYPE_BEZIER   - 베지어 곡선 (부드러운 커브)")
	print("  TYPE_AUDIO    - 오디오 재생")
	print("  TYPE_ANIMATION - 다른 AnimationPlayer 제어")

	print("\n[보간 타입]")
	print("  INTERPOLATION_NEAREST - 보간 없음 (즉시 변경)")
	print("  INTERPOLATION_LINEAR  - 선형 보간 (기본)")
	print("  INTERPOLATION_CUBIC   - 큐빅 보간 (부드러운)")

	print("\n[업데이트 모드]")
	print("  UPDATE_CONTINUOUS - 매 프레임 업데이트 (기본)")
	print("  UPDATE_DISCRETE   - 키프레임에서만 변경 (텍스트 등)")

	print("\n=== AnimationPlayer 학습 완료 ===")
