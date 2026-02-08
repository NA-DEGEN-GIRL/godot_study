# Chapter 06 - Signals & Groups
# 04-signal-bus.gd - 글로벌 이벤트 버스 (Autoload 패턴)
#
# 이 파일에서 배울 내용:
# - EventBus(Signal Bus) 패턴의 개념과 필요성
# - Autoload를 활용한 글로벌 시그널 허브
# - 씬 간 통신 문제와 해결
# - 실전 EventBus 구현과 활용 예시
# - 이벤트 버스의 장단점과 주의사항
#
# EventBus는 서로 모르는 노드/씬 간의 통신을 중개합니다.
# Autoload로 등록하여 어디서든 접근 가능한 시그널 허브입니다.

extends Node

# ============================================
# 1. EventBus가 필요한 이유
# ============================================
# 문제: 씬 A와 씬 B가 서로 통신하고 싶다
#
# 직접 참조 방식 (나쁜 예):
#   적이 죽으면 -> 적이 HUD를 직접 찾아서 -> 점수 업데이트
#   var hud = get_node("/root/Game/UI/HUD")  # 경로 하드코딩!
#   hud.update_score(10)
#   -> 씬 구조가 바뀌면 코드가 깨짐 (강결합)
#
# EventBus 방식 (좋은 예):
#   적이 죽으면 -> EventBus.enemy_defeated 시그널 발신
#   HUD는 -> EventBus.enemy_defeated에 미리 연결
#   -> 적과 HUD는 서로의 존재를 모름 (느슨한 결합)

func _ready():
	print("=== Chapter 06-4: 글로벌 이벤트 버스 ===\n")

	_show_eventbus_setup()
	_show_eventbus_implementation()
	_show_connection_examples()
	_show_emit_examples()
	_practical_game_events()
	_practical_ui_events()
	_demonstrate_eventbus()
	_show_advanced_patterns()
	_show_pros_cons()

# ============================================
# 2. EventBus Autoload 설정 방법
# ============================================

func _show_eventbus_setup():
	print("--- 2. EventBus Autoload 설정 ---")

	print("[Step 1] event_bus.gd 파일 생성:")
	print("  res://autoload/event_bus.gd")

	print("\n[Step 2] Autoload에 등록:")
	print("  프로젝트 > 프로젝트 설정 > Autoload 탭")
	print("  경로: res://autoload/event_bus.gd")
	print("  이름: EventBus")
	print("  활성화: 체크")

	print("\n[Step 3] 어디서든 사용:")
	print("  EventBus.enemy_defeated.connect(my_callback)")
	print("  EventBus.enemy_defeated.emit(enemy_data)")

	print("\n[Autoload 특징]")
	print("  - 씬 전환 시에도 유지됨 (영구 존재)")
	print("  - 어디서든 이름으로 접근 가능 (전역)")
	print("  - 가장 먼저 로드되고, 가장 나중에 해제됨")
	print("  - /root/EventBus 경로에 존재")

	print()

# ============================================
# 3. EventBus 전체 구현
# ============================================

func _show_eventbus_implementation():
	print("--- 3. EventBus 전체 구현 ---")
	print("""
  # autoload/event_bus.gd
  # 프로젝트 설정 > Autoload에 "EventBus"로 등록
  extends Node

  # ==================
  # 게임 진행 이벤트
  # ==================
  signal game_started
  signal game_paused
  signal game_resumed
  signal game_over(is_victory: bool)
  signal level_started(level_id: int)
  signal level_completed(level_id: int, stars: int)

  # ==================
  # 플레이어 이벤트
  # ==================
  signal player_spawned(player: Node2D)
  signal player_died
  signal player_respawned
  signal player_health_changed(current: int, maximum: int)
  signal player_mana_changed(current: int, maximum: int)

  # ==================
  # 전투 이벤트
  # ==================
  signal damage_dealt(target: Node2D, amount: int, source: Node2D)
  signal enemy_defeated(enemy_data: Dictionary)
  signal boss_defeated(boss_name: String)
  signal combo_updated(combo_count: int)

  # ==================
  # 아이템/경제 이벤트
  # ==================
  signal item_collected(item_type: String, amount: int)
  signal coin_collected(value: int)
  signal score_changed(new_score: int)
  signal currency_changed(currency_type: String, new_amount: int)

  # ==================
  # UI 이벤트
  # ==================
  signal show_message(text: String, duration: float)
  signal show_dialog(dialog_id: String)
  signal dialog_finished(dialog_id: String)
  signal screen_shake(intensity: float, duration: float)
  signal flash_screen(color: Color, duration: float)

  # ==================
  # 오디오 이벤트
  # ==================
  signal play_sfx(sfx_name: String)
  signal play_music(music_name: String)
  signal stop_music
  signal set_volume(bus_name: String, volume: float)

  # ==================
  # 세이브/로드 이벤트
  # ==================
  signal save_requested(slot: int)
  signal load_requested(slot: int)
  signal save_completed(slot: int)
  signal load_completed(slot: int)
	""")
	print()

# ============================================
# 4. 시그널 연결 예시 (각 씬에서)
# ============================================

func _show_connection_examples():
	print("--- 4. EventBus 시그널 연결 (수신 측) ---")
	print("""
  # hud.gd - HUD가 EventBus 시그널에 연결
  extends CanvasLayer

  func _ready():
      EventBus.score_changed.connect(_on_score_changed)
      EventBus.player_health_changed.connect(_on_health_changed)
      EventBus.combo_updated.connect(_on_combo_updated)
      EventBus.show_message.connect(_on_show_message)
      EventBus.coin_collected.connect(_on_coin_collected)

  func _on_score_changed(new_score: int):
      $ScoreLabel.text = "Score: %d" % new_score

  func _on_health_changed(current: int, maximum: int):
      $HealthBar.value = current
      $HealthBar.max_value = maximum

  func _on_coin_collected(value: int):
      # 코인 수집 애니메이션
      var popup = $CoinPopup.duplicate()
      popup.text = "+%d" % value
      add_child(popup)
	""")

	print("""
  # camera.gd - 카메라가 화면 흔들림에 연결
  extends Camera2D

  func _ready():
      EventBus.screen_shake.connect(_on_screen_shake)
      EventBus.boss_defeated.connect(func(_name):
          _on_screen_shake(5.0, 1.0)  # 보스 처치 시 강한 흔들림
      )

  func _on_screen_shake(intensity: float, duration: float):
      var tween = create_tween()
      for i in range(int(duration * 20)):
          var offset = Vector2(
              randf_range(-intensity, intensity),
              randf_range(-intensity, intensity)
          )
          tween.tween_property(self, "offset", offset, 0.05)
      tween.tween_property(self, "offset", Vector2.ZERO, 0.05)
	""")

	print("""
  # audio_manager.gd - 오디오가 EventBus에 연결
  extends Node

  func _ready():
      EventBus.play_sfx.connect(_on_play_sfx)
      EventBus.play_music.connect(_on_play_music)
      EventBus.coin_collected.connect(func(_v):
          _on_play_sfx("coin_pickup")
      )
      EventBus.enemy_defeated.connect(func(_d):
          _on_play_sfx("enemy_death")
      )

  func _on_play_sfx(sfx_name: String):
      var player = AudioStreamPlayer.new()
      player.stream = load("res://audio/sfx/%s.wav" % sfx_name)
      add_child(player)
      player.play()
      player.finished.connect(player.queue_free)
	""")
	print()

# ============================================
# 5. 시그널 발신 예시 (각 씬에서)
# ============================================

func _show_emit_examples():
	print("--- 5. EventBus 시그널 발신 (발신 측) ---")
	print("""
  # enemy.gd - 적이 죽을 때 EventBus로 알림
  extends CharacterBody2D

  func die():
      EventBus.enemy_defeated.emit({
          "name": enemy_name,
          "position": global_position,
          "exp": experience_value,
          "drops": drop_table
      })
      EventBus.screen_shake.emit(2.0, 0.3)
      EventBus.play_sfx.emit("enemy_death")
      queue_free()
	""")

	print("""
  # coin.gd - 코인 수집 시
  extends Area2D

  @export var value: int = 1

  func _on_body_entered(body):
      if body.is_in_group("player"):
          EventBus.coin_collected.emit(value)
          EventBus.play_sfx.emit("coin")
          queue_free()
	""")

	print("""
  # player.gd - 플레이어 상태 변화 시
  extends CharacterBody2D

  var health: int = 100:
      set(value):
          health = clampi(value, 0, max_health)
          EventBus.player_health_changed.emit(health, max_health)
          if health <= 0:
              EventBus.player_died.emit()

  func take_damage(amount: int, source: Node2D):
      health -= amount
      EventBus.damage_dealt.emit(self, amount, source)
      EventBus.screen_shake.emit(1.0, 0.2)
	""")
	print()

# ============================================
# 6. 실전: 게임 이벤트 흐름
# ============================================

func _practical_game_events():
	print("--- 6. 실전: 게임 이벤트 흐름 ---")

	print("[적 처치 이벤트 체인]")
	print("  1. Enemy.die() 호출")
	print("  2. EventBus.enemy_defeated.emit(data)")
	print("  3. 여러 시스템이 동시에 반응:")
	print("     - ScoreManager: 점수 추가")
	print("     - ExpManager: 경험치 추가")
	print("     - HUD: 점수 표시 업데이트")
	print("     - Camera: 화면 흔들림")
	print("     - AudioManager: 효과음 재생")
	print("     - ParticleManager: 이펙트 생성")
	print("     - QuestManager: 퀘스트 진행도 확인")
	print("     - AchievementManager: 업적 확인")

	print("\n[레벨 완료 이벤트 체인]")
	print("  1. 마지막 적 처치")
	print("  2. EnemyManager: 적 수 0 확인")
	print("  3. EventBus.level_completed.emit(level_id, stars)")
	print("  4. 반응:")
	print("     - SaveManager: 자동 저장")
	print("     - UIManager: 결과 화면 표시")
	print("     - AudioManager: 승리 음악")
	print("     - AnalyticsManager: 통계 기록")

	print()

# ============================================
# 7. 실전: UI 이벤트 분리
# ============================================

func _practical_ui_events():
	print("--- 7. 실전: UI 이벤트 분리 ---")
	print("""
  # UI 관련 이벤트를 EventBus로 분리하면
  # 게임 로직과 UI가 완전히 독립됩니다.

  # 게임 코드 (UI를 전혀 모름):
  func complete_quest(quest_id: String):
      var rewards = calculate_rewards(quest_id)
      EventBus.quest_completed.emit(quest_id, rewards)
      EventBus.show_message.emit("퀘스트 완료!", 3.0)

  # UI 코드 (게임 로직을 전혀 모름):
  func _ready():
      EventBus.quest_completed.connect(_show_quest_popup)
      EventBus.show_message.connect(_display_message)

  func _show_quest_popup(quest_id: String, rewards: Array):
      var popup = quest_popup_scene.instantiate()
      popup.setup(quest_id, rewards)
      add_child(popup)

  func _display_message(text: String, duration: float):
      $MessageLabel.text = text
      $MessageLabel.visible = true
      await get_tree().create_timer(duration).timeout
      $MessageLabel.visible = false
	""")
	print()

# ============================================
# 8. EventBus 데모 (실행 가능)
# ============================================

# 로컬 EventBus 시뮬레이션 (Autoload 없이 테스트)
signal _bus_enemy_defeated(data: Dictionary)
signal _bus_score_changed(new_score: int)
signal _bus_screen_shake(intensity: float, duration: float)
signal _bus_play_sfx(sfx_name: String)
signal _bus_show_message(text: String, duration: float)

func _demonstrate_eventbus():
	print("--- 8. EventBus 동작 데모 ---\n")

	var demo_score = 0

	# 수신 측 등록 (여러 시스템이 연결)
	_bus_enemy_defeated.connect(func(data: Dictionary):
		print("  [ScoreManager] +%d점 (적 처치: %s)" % [data.exp * 10, data.name])
		demo_score += data.exp * 10
		_bus_score_changed.emit(demo_score)
	)

	_bus_enemy_defeated.connect(func(data: Dictionary):
		print("  [ExpManager] +%d EXP" % data.exp)
	)

	_bus_score_changed.connect(func(new_score: int):
		print("  [HUD] 점수 업데이트: %d" % new_score)
	)

	_bus_screen_shake.connect(func(intensity: float, duration: float):
		print("  [Camera] 화면 흔들림! (강도: %.1f, 시간: %.1fs)" % [intensity, duration])
	)

	_bus_play_sfx.connect(func(sfx_name: String):
		print("  [AudioManager] 효과음 재생: %s" % sfx_name)
	)

	_bus_show_message.connect(func(text: String, _duration: float):
		print("  [UIManager] 메시지: '%s'" % text)
	)

	# 발신: 적 처치!
	print("[이벤트 발생: 고블린 처치]")
	_bus_enemy_defeated.emit({
		"name": "고블린",
		"exp": 30,
		"position": Vector2(100, 200)
	})
	_bus_screen_shake.emit(2.0, 0.3)
	_bus_play_sfx.emit("enemy_death")

	print("\n[이벤트 발생: 드래곤 처치]")
	_bus_enemy_defeated.emit({
		"name": "드래곤",
		"exp": 500,
		"position": Vector2(400, 300)
	})
	_bus_screen_shake.emit(8.0, 1.0)
	_bus_play_sfx.emit("boss_death")
	_bus_show_message.emit("보스 처치! 축하합니다!", 5.0)

	print()

# ============================================
# 9. 고급 패턴
# ============================================

func _show_advanced_patterns():
	print("--- 9. 고급 EventBus 패턴 ---")

	# 패턴 1: 연결 해제 관리
	print("[패턴 1] 씬 전환 시 연결 해제")
	print("""
  # 씬이 제거될 때 자동으로 연결 해제
  func _ready():
      EventBus.score_changed.connect(_on_score_changed)

  func _exit_tree():
      # 연결 해제 (메모리 누수 방지)
      if EventBus.score_changed.is_connected(_on_score_changed):
          EventBus.score_changed.disconnect(_on_score_changed)

  # 또는 한 줄로:
  # tree_exiting 시그널 활용
  func _ready():
      EventBus.score_changed.connect(_on_score_changed)
      tree_exiting.connect(func():
          EventBus.score_changed.disconnect(_on_score_changed)
      )
	""")

	# 패턴 2: 타입별 EventBus 분리
	print("[패턴 2] 도메인별 EventBus 분리")
	print("""
  # 큰 프로젝트에서는 EventBus를 여러 개로 분리

  # autoload/combat_events.gd  -> CombatEvents
  signal damage_dealt(...)
  signal enemy_defeated(...)

  # autoload/ui_events.gd  -> UIEvents
  signal show_popup(...)
  signal screen_shake(...)

  # autoload/audio_events.gd  -> AudioEvents
  signal play_sfx(...)
  signal play_music(...)

  # 사용:
  CombatEvents.enemy_defeated.emit(data)
  UIEvents.screen_shake.emit(5.0, 1.0)
  AudioEvents.play_sfx.emit("boom")
	""")

	# 패턴 3: 이벤트 로깅
	print("[패턴 3] 이벤트 로깅 / 디버깅")
	print("""
  # event_bus.gd에 디버깅 기능 추가
  var debug_mode: bool = false

  func log_event(event_name: String, data = null):
      if debug_mode:
          var timestamp = Time.get_ticks_msec()
          print("[%d] Event: %s | Data: %s" % [
              timestamp, event_name, str(data)
          ])

  # 사용:
  func emit_enemy_defeated(data: Dictionary):
      log_event("enemy_defeated", data)
      enemy_defeated.emit(data)
	""")

	print()

# ============================================
# 10. 장단점과 주의사항
# ============================================

func _show_pros_cons():
	print("--- 10. EventBus 장단점과 주의사항 ---")

	print("[장점]")
	print("  1. 느슨한 결합: 발신자와 수신자가 서로를 모름")
	print("  2. 유연성: 새 시스템 추가 시 기존 코드 수정 불필요")
	print("  3. 씬 독립: 씬 구조에 의존하지 않음")
	print("  4. 중앙 관리: 이벤트 목록을 한 곳에서 확인 가능")
	print("  5. 테스트 용이: 이벤트만 발생시키면 테스트 가능")

	print("\n[단점]")
	print("  1. 흐름 추적 어려움: emit만 보고 누가 받는지 알기 어려움")
	print("  2. 메모리 누수: disconnect 안 하면 누수 가능")
	print("  3. 과도한 사용: 모든 통신을 EventBus로 하면 스파게티")
	print("  4. 타입 안전성: 시그널 매개변수 오류를 런타임에 발견")
	print("  5. 실행 순서: 여러 수신자의 실행 순서 보장 안 됨")

	print("\n[EventBus를 쓰면 좋은 경우]")
	print("  - 서로 다른 씬/시스템 간의 통신")
	print("  - 1:N 통신 (하나의 이벤트, 여러 수신자)")
	print("  - 게임 전역 이벤트 (점수, 체력, 레벨업)")
	print("  - UI 업데이트 알림")

	print("\n[EventBus를 안 쓰는 게 좋은 경우]")
	print("  - 부모-자식 간 통신 (직접 시그널이 명확)")
	print("  - 1:1 통신 (직접 참조가 더 간단)")
	print("  - 타이트한 순서가 필요한 로직")
	print("  - 매 프레임 호출되는 로직 (시그널 오버헤드)")

	print("\n[권장 구조]")
	print("  부모<->자식: 직접 시그널")
	print("  형제 노드: 부모를 통한 중계")
	print("  씬 간 통신: EventBus")
	print("  시스템 간 통신: EventBus")

	print("\n=== 글로벌 이벤트 버스 학습 완료 ===")
