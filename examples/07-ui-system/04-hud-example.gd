# Chapter 07 - UI System
# 04-hud-example.gd - 실전: 게임 HUD 구현
#
# 이 파일에서 배울 내용:
# - 체력 바(Health Bar) 구현과 애니메이션
# - 점수 표시와 카운트업 효과
# - 탄약/아이템 카운터 표시
# - 보스 체력 바
# - 미니맵 영역 배치
# - HUD 전체 레이아웃 구성
#
# HUD(Heads-Up Display)는 게임 중 항상 표시되는 UI입니다.
# CanvasLayer에 배치하여 카메라 이동에 영향받지 않게 합니다.

extends CanvasLayer

# ============================================
# 1. HUD 구조 설계
# ============================================
# CanvasLayer (카메라와 독립)
#   +-- Control (Full Rect - 앵커 기준)
#       +-- TopBar (HBox - 상단)
#       |   +-- HealthSection (HBox)
#       |   |   +-- HeartIcon
#       |   |   +-- HealthBar
#       |   |   +-- HealthLabel
#       |   +-- Spacer (중앙 빈 공간)
#       |   +-- ScoreSection (HBox)
#       |       +-- CoinIcon
#       |       +-- ScoreLabel
#       |
#       +-- BottomBar (HBox - 하단)
#       |   +-- AmmoSection
#       |   +-- SkillSlots (HBox)
#       |   +-- MinimapFrame
#       |
#       +-- BossHealthBar (상단 중앙, 기본 숨김)
#       +-- MessageLabel (중앙, 기본 숨김)

# 게임 상태
var player_health: float = 100.0
var player_max_health: float = 100.0
var display_health: float = 100.0  # 표시용 (부드러운 변화)
var score: int = 0
var display_score: int = 0  # 표시용 (카운트업)
var coins: int = 0
var ammo: int = 30
var max_ammo: int = 30
var boss_health: float = 0.0
var boss_max_health: float = 0.0

# UI 노드 참조
var health_bar: ProgressBar
var health_damage_bar: ProgressBar  # 데미지 표시용 (빨간 바)
var health_label: Label
var score_label: Label
var coin_label: Label
var ammo_label: Label
var boss_bar: ProgressBar
var boss_bar_container: Control
var message_label: Label

func _ready():
	print("=== Chapter 07-4: 게임 HUD 구현 ===\n")

	_build_hud()
	_demonstrate_health_bar()
	_demonstrate_score_display()
	_demonstrate_ammo_counter()
	_demonstrate_boss_bar()
	_demonstrate_message_system()
	_show_damage_number_system()
	_show_full_hud_code()

# ============================================
# 2. HUD 빌드 (코드로 구성)
# ============================================

func _build_hud():
	print("--- 2. HUD 구성 ---")

	# 루트 Control (Full Rect)
	var root = Control.new()
	root.name = "HUDRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 마우스 통과
	add_child(root)

	# === 상단 바 ===
	var top_margin = MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.custom_minimum_size.y = 50
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 16)
	top_margin.add_theme_constant_override("margin_top", 8)
	root.add_child(top_margin)

	var top_bar = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 10)
	top_margin.add_child(top_bar)

	# -- 체력 섹션 --
	var health_section = HBoxContainer.new()
	health_section.add_theme_constant_override("separation", 8)
	top_bar.add_child(health_section)

	# 하트 아이콘 (텍스트로 대체)
	var heart_icon = Label.new()
	heart_icon.text = "HP"
	heart_icon.add_theme_color_override("font_color", Color.RED)
	heart_icon.add_theme_font_size_override("font_size", 18)
	health_section.add_child(heart_icon)

	# 체력 바 컨테이너 (이중 바)
	var bar_container = Control.new()
	bar_container.custom_minimum_size = Vector2(200, 24)
	health_section.add_child(bar_container)

	# 데미지 바 (뒤에, 빨간색 - 느리게 줄어듦)
	health_damage_bar = ProgressBar.new()
	health_damage_bar.max_value = player_max_health
	health_damage_bar.value = player_health
	health_damage_bar.show_percentage = false
	health_damage_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dmg_fill = StyleBoxFlat.new()
	dmg_fill.bg_color = Color(0.8, 0.2, 0.1)
	dmg_fill.corner_radius_top_left = 4
	dmg_fill.corner_radius_top_right = 4
	dmg_fill.corner_radius_bottom_left = 4
	dmg_fill.corner_radius_bottom_right = 4
	health_damage_bar.add_theme_stylebox_override("fill", dmg_fill)
	var dmg_bg = StyleBoxFlat.new()
	dmg_bg.bg_color = Color(0.1, 0.1, 0.15)
	dmg_bg.corner_radius_top_left = 4
	dmg_bg.corner_radius_top_right = 4
	dmg_bg.corner_radius_bottom_left = 4
	dmg_bg.corner_radius_bottom_right = 4
	health_damage_bar.add_theme_stylebox_override("background", dmg_bg)
	bar_container.add_child(health_damage_bar)

	# 실제 체력 바 (앞에, 초록색 - 즉시 변화)
	health_bar = ProgressBar.new()
	health_bar.max_value = player_max_health
	health_bar.value = player_health
	health_bar.show_percentage = false
	health_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	var hp_fill = StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.2, 0.8, 0.3)
	hp_fill.corner_radius_top_left = 4
	hp_fill.corner_radius_top_right = 4
	hp_fill.corner_radius_bottom_left = 4
	hp_fill.corner_radius_bottom_right = 4
	health_bar.add_theme_stylebox_override("fill", hp_fill)
	var hp_bg = StyleBoxEmpty.new()
	health_bar.add_theme_stylebox_override("background", hp_bg)
	bar_container.add_child(health_bar)

	# 체력 텍스트
	health_label = Label.new()
	health_label.text = "%d/%d" % [int(player_health), int(player_max_health)]
	health_label.add_theme_font_size_override("font_size", 14)
	health_section.add_child(health_label)

	# -- 중앙 공간 --
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	# -- 점수/코인 섹션 --
	var score_section = HBoxContainer.new()
	score_section.add_theme_constant_override("separation", 16)
	top_bar.add_child(score_section)

	coin_label = Label.new()
	coin_label.text = "Coin: 0"
	coin_label.add_theme_color_override("font_color", Color.GOLD)
	coin_label.add_theme_font_size_override("font_size", 16)
	score_section.add_child(coin_label)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 18)
	score_section.add_child(score_label)

	# === 하단: 탄약 ===
	var bottom_margin = MarginContainer.new()
	bottom_margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_margin.custom_minimum_size.y = 40
	bottom_margin.add_theme_constant_override("margin_left", 16)
	bottom_margin.add_theme_constant_override("margin_bottom", 8)
	root.add_child(bottom_margin)

	ammo_label = Label.new()
	ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]
	ammo_label.add_theme_font_size_override("font_size", 16)
	bottom_margin.add_child(ammo_label)

	# === 보스 체력 바 (기본 숨김) ===
	boss_bar_container = Control.new()
	boss_bar_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_bar_container.position.y = 60
	boss_bar_container.custom_minimum_size.y = 30
	boss_bar_container.visible = false
	root.add_child(boss_bar_container)

	boss_bar = ProgressBar.new()
	boss_bar.set_anchors_preset(Control.PRESET_CENTER)
	boss_bar.custom_minimum_size = Vector2(400, 20)
	boss_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	boss_bar.show_percentage = false
	var boss_fill = StyleBoxFlat.new()
	boss_fill.bg_color = Color(0.8, 0.1, 0.1)
	boss_fill.corner_radius_top_left = 3
	boss_fill.corner_radius_top_right = 3
	boss_fill.corner_radius_bottom_left = 3
	boss_fill.corner_radius_bottom_right = 3
	boss_bar.add_theme_stylebox_override("fill", boss_fill)
	boss_bar_container.add_child(boss_bar)

	# === 메시지 라벨 (중앙, 기본 숨김) ===
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER)
	message_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.visible = false
	root.add_child(message_label)

	print("  HUD 빌드 완료:")
	print("    상단: HP 바 + 이중 바 + 코인 + 점수")
	print("    하단: 탄약 카운터")
	print("    보스 바 (숨김), 메시지 (숨김)")

	print()

# ============================================
# 3. 체력 바 애니메이션
# ============================================

func _demonstrate_health_bar():
	print("--- 3. 체력 바 (이중 바 + 애니메이션) ---")

	print("[이중 바 시스템]")
	print("  뒤: 데미지 바 (빨간색) - 느리게 줄어듦")
	print("  앞: 실제 체력 바 (초록색) - 즉시 반영")
	print("  -> 데미지 시각화 효과!")

	# 데미지 시뮬레이션
	print("\n[데미지 시뮬레이션]")
	_take_damage(30)
	_take_damage(20)
	_heal(10)

	print("\n[체력 바 색상 변화 코드]")
	print("""
  func update_health_bar_color():
      var ratio = player_health / player_max_health
      var fill = health_bar.get_theme_stylebox("fill") as StyleBoxFlat

      if ratio > 0.6:
          fill.bg_color = Color.GREEN       # 60% 이상: 초록
      elif ratio > 0.3:
          fill.bg_color = Color.YELLOW      # 30~60%: 노랑
      else:
          fill.bg_color = Color.RED         # 30% 미만: 빨강
          # 위험할 때 깜빡임
          _pulse_health_bar()

  func _pulse_health_bar():
      var tween = create_tween().set_loops(3)
      tween.tween_property(health_bar, "modulate:a", 0.5, 0.15)
      tween.tween_property(health_bar, "modulate:a", 1.0, 0.15)
	""")

	print()

func _take_damage(amount: float):
	var old_health = player_health
	player_health = maxf(0, player_health - amount)

	# 즉시: 실제 체력 바 반영
	health_bar.value = player_health
	health_label.text = "%d/%d" % [int(player_health), int(player_max_health)]

	# 지연: 데미지 바 (느리게 줄어듦)
	var tween = create_tween()
	tween.tween_property(health_damage_bar, "value", player_health, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 체력 바 색상 변경
	var ratio = player_health / player_max_health
	var fill = health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill:
		if ratio > 0.6:
			fill.bg_color = Color(0.2, 0.8, 0.3)
		elif ratio > 0.3:
			fill.bg_color = Color(0.9, 0.8, 0.1)
		else:
			fill.bg_color = Color(0.9, 0.2, 0.1)

	print("  데미지! -%d HP (%.0f -> %.0f) %s" % [
		amount, old_health, player_health,
		_bar_visual(player_health, player_max_health)
	])

func _heal(amount: float):
	var old_health = player_health
	player_health = minf(player_max_health, player_health + amount)

	health_bar.value = player_health
	health_damage_bar.value = player_health  # 회복은 즉시 반영
	health_label.text = "%d/%d" % [int(player_health), int(player_max_health)]

	print("  회복! +%d HP (%.0f -> %.0f) %s" % [
		amount, old_health, player_health,
		_bar_visual(player_health, player_max_health)
	])

func _bar_visual(current: float, maximum: float) -> String:
	var filled = int(current / maximum * 20)
	var empty = 20 - filled
	return "[" + "#".repeat(filled) + "-".repeat(empty) + "]"

# ============================================
# 4. 점수 카운트업 효과
# ============================================

func _demonstrate_score_display():
	print("--- 4. 점수 카운트업 효과 ---")

	print("[점수 추가 + 카운트업 애니메이션]")

	# 점수 추가 시뮬레이션
	_add_score(100)
	_add_score(250)
	_add_score(1000)

	print("\n[카운트업 구현 코드]")
	print("""
  var display_score: int = 0  # 표시용 점수 (천천히 올라감)
  var actual_score: int = 0   # 실제 점수

  func add_score(amount: int):
      actual_score += amount

      # 카운트업 Tween
      var tween = create_tween()
      tween.tween_method(
          func(val: float):
              display_score = int(val)
              score_label.text = "Score: %d" % display_score,
          float(display_score),     # from
          float(actual_score),      # to
          0.5                       # duration
      ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

      # 팝 효과 (커졌다 원래 크기)
      var pop_tween = create_tween()
      pop_tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
      pop_tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2) \\
          .set_trans(Tween.TRANS_BACK)
	""")

	print()

func _add_score(amount: int):
	var old_score = score
	score += amount
	display_score = score  # 즉시 반영 (데모에서)
	score_label.text = "Score: %d" % score

	# 팝 효과
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.15) \
		.set_trans(Tween.TRANS_BACK)

	print("  +%d점! (총 %d)" % [amount, score])

# ============================================
# 5. 탄약 카운터
# ============================================

func _demonstrate_ammo_counter():
	print("--- 5. 탄약 카운터 ---")

	# 탄약 소모 시뮬레이션
	for i in range(5):
		_use_ammo()
	_reload()

	print("\n[탄약 UI 코드]")
	print("""
  func update_ammo_display():
      ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]

      # 탄약 부족 시 빨간색
      if ammo <= 5:
          ammo_label.add_theme_color_override("font_color", Color.RED)
          # 깜빡임 효과
          if ammo == 0:
              var tween = create_tween().set_loops()
              tween.tween_property(ammo_label, "modulate:a", 0.3, 0.3)
              tween.tween_property(ammo_label, "modulate:a", 1.0, 0.3)
      elif ammo <= 10:
          ammo_label.add_theme_color_override("font_color", Color.YELLOW)
      else:
          ammo_label.add_theme_color_override("font_color", Color.WHITE)

  func reload():
      ammo = max_ammo
      update_ammo_display()
      # 재장전 애니메이션
      var tween = create_tween()
      tween.tween_property(ammo_label, "modulate", Color.CYAN, 0.1)
      tween.tween_property(ammo_label, "modulate", Color.WHITE, 0.3)
	""")

	print()

func _use_ammo():
	if ammo > 0:
		ammo -= 1
		ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]
		# 색상 변화
		if ammo <= 5:
			ammo_label.add_theme_color_override("font_color", Color.RED)
		elif ammo <= 10:
			ammo_label.add_theme_color_override("font_color", Color.YELLOW)
		print("  발사! 잔탄: %d/%d" % [ammo, max_ammo])

func _reload():
	ammo = max_ammo
	ammo_label.text = "AMMO: %d / %d" % [ammo, max_ammo]
	ammo_label.add_theme_color_override("font_color", Color.WHITE)
	print("  재장전! %d/%d" % [ammo, max_ammo])

# ============================================
# 6. 보스 체력 바
# ============================================

func _demonstrate_boss_bar():
	print("--- 6. 보스 체력 바 ---")

	print("[보스 등장 시 체력 바 표시]")
	_show_boss("Dark Dragon", 5000)

	# 데미지
	_damage_boss(1500)
	_damage_boss(2000)
	_damage_boss(1500)

	print("\n[보스 바 코드]")
	print("""
  func show_boss_health(boss_name: String, max_hp: float):
      boss_max_health = max_hp
      boss_health = max_hp
      boss_bar.max_value = max_hp
      boss_bar.value = max_hp
      $BossNameLabel.text = boss_name
      boss_bar_container.visible = true

      # 등장 애니메이션: 위에서 슬라이드
      boss_bar_container.modulate.a = 0
      boss_bar_container.position.y = -30
      var tween = create_tween().set_parallel(true)
      tween.tween_property(boss_bar_container, "modulate:a", 1.0, 0.5)
      tween.tween_property(boss_bar_container, "position:y", 60.0, 0.5) \\
          .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

  func hide_boss_health():
      var tween = create_tween()
      tween.tween_property(boss_bar_container, "modulate:a", 0.0, 0.5)
      tween.tween_callback(func(): boss_bar_container.visible = false)
	""")

	print()

func _show_boss(boss_name: String, max_hp: float):
	boss_max_health = max_hp
	boss_health = max_hp
	boss_bar.max_value = max_hp
	boss_bar.value = max_hp
	boss_bar_container.visible = true
	print("  [BOSS] %s 등장! HP: %d" % [boss_name, int(max_hp)])

func _damage_boss(amount: float):
	boss_health = maxf(0, boss_health - amount)
	var tween = create_tween()
	tween.tween_property(boss_bar, "value", boss_health, 0.3)

	print("  [BOSS] -%d HP (잔여: %d/%d) %s" % [
		int(amount), int(boss_health), int(boss_max_health),
		_bar_visual(boss_health, boss_max_health)
	])

	if boss_health <= 0:
		print("  [BOSS] 처치!")
		boss_bar_container.visible = false

# ============================================
# 7. 메시지 시스템
# ============================================

func _demonstrate_message_system():
	print("--- 7. 화면 메시지 시스템 ---")

	_show_message("STAGE 1 - START!", 1.5)

	print("\n[메시지 시스템 코드]")
	print("""
  func show_message(text: String, duration: float = 2.0):
      message_label.text = text
      message_label.visible = true
      message_label.modulate.a = 0

      var tween = create_tween()
      # 페이드 인
      tween.tween_property(message_label, "modulate:a", 1.0, 0.3)
      # 유지
      tween.tween_interval(duration)
      # 페이드 아웃
      tween.tween_property(message_label, "modulate:a", 0.0, 0.5)
      tween.tween_callback(func(): message_label.visible = false)

  # 사용 예시
  show_message("STAGE CLEAR!", 3.0)
  show_message("GAME OVER", 5.0)
  show_message("NEW HIGH SCORE!", 2.0)
	""")

	print()

func _show_message(text: String, duration: float):
	message_label.text = text
	message_label.visible = true
	message_label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): message_label.visible = false)

	print("  [MESSAGE] '%s' (%.1f초)" % [text, duration])

# ============================================
# 8. 데미지 넘버 시스템
# ============================================

func _show_damage_number_system():
	print("--- 8. 데미지 넘버 팝업 ---")
	print("""
  # damage_number.gd
  # 데미지 숫자가 적 위에 팝업으로 뜨는 시스템

  func spawn_damage_number(position: Vector2, amount: int, is_crit: bool = false):
      var label = Label.new()
      label.text = str(amount)
      label.global_position = position + Vector2(randf_range(-20, 20), -20)
      label.z_index = 100

      if is_crit:
          label.add_theme_font_size_override("font_size", 28)
          label.add_theme_color_override("font_color", Color.YELLOW)
          label.text = str(amount) + "!"
      else:
          label.add_theme_font_size_override("font_size", 18)
          label.add_theme_color_override("font_color", Color.WHITE)

      # 아웃라인
      label.add_theme_constant_override("outline_size", 3)
      label.add_theme_color_override("font_outline_color", Color.BLACK)

      get_tree().current_scene.add_child(label)

      # 애니메이션: 위로 떠오르며 사라짐
      var tween = create_tween().set_parallel(true)

      # 위로 이동 (포물선)
      var target_y = label.position.y - randf_range(40, 70)
      tween.tween_property(label, "position:y", target_y, 0.8) \\
          .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

      # 좌우 약간 이동
      var drift_x = randf_range(-30, 30)
      tween.tween_property(label, "position:x",
          label.position.x + drift_x, 0.8)

      # 크기 변화 (크리티컬: 커졌다 작아짐)
      if is_crit:
          label.scale = Vector2(0.5, 0.5)
          tween.tween_property(label, "scale",
              Vector2(1.2, 1.2), 0.15) \\
              .set_trans(Tween.TRANS_BACK)

      # 페이드 아웃
      tween.tween_property(label, "modulate:a", 0.0, 0.8) \\
          .set_delay(0.3)

      # 정리
      tween.chain().tween_callback(label.queue_free)
	""")

	# 데모
	print("[데미지 넘버 시뮬레이션]")
	var damages = [
		{"amount": 15, "crit": false},
		{"amount": 42, "crit": true},
		{"amount": 8, "crit": false},
		{"amount": 99, "crit": true},
	]
	for d in damages:
		var crit_text = " CRITICAL!" if d.crit else ""
		print("  -%d%s" % [d.amount, crit_text])

	print()

# ============================================
# 9. 전체 HUD 통합 코드
# ============================================

func _show_full_hud_code():
	print("--- 9. HUD 매니저 통합 코드 ---")
	print("""
  # hud_manager.gd - EventBus와 연동하는 HUD
  extends CanvasLayer

  @onready var health_bar = $Root/TopBar/Health/HealthBar
  @onready var health_label = $Root/TopBar/Health/Label
  @onready var score_label = $Root/TopBar/Score/Label
  @onready var ammo_label = $Root/BottomBar/AmmoLabel
  @onready var boss_bar = $Root/BossBar
  @onready var message_label = $Root/MessageLabel

  var display_score: int = 0

  func _ready():
      # EventBus 시그널 연결
      EventBus.player_health_changed.connect(_on_health_changed)
      EventBus.score_changed.connect(_on_score_changed)
      EventBus.coin_collected.connect(_on_coin_collected)
      EventBus.show_message.connect(show_message)
      EventBus.enemy_defeated.connect(_on_enemy_defeated)

  func _on_health_changed(current: int, maximum: int):
      health_bar.max_value = maximum
      # 즉시 체력 바 업데이트
      var tween = create_tween()
      tween.tween_property(health_bar, "value",
          float(current), 0.3)
      health_label.text = "%d/%d" % [current, maximum]

      # 색상 변화
      var ratio = float(current) / maximum
      if ratio > 0.6:
          _set_bar_color(Color.GREEN)
      elif ratio > 0.3:
          _set_bar_color(Color.YELLOW)
      else:
          _set_bar_color(Color.RED)

  func _on_score_changed(new_score: int):
      # 카운트업 애니메이션
      var tween = create_tween()
      tween.tween_method(func(val: float):
          display_score = int(val)
          score_label.text = "Score: %d" % display_score,
          float(display_score), float(new_score), 0.5
      )

  func _on_coin_collected(value: int):
      # +N 팝업 표시
      var popup = Label.new()
      popup.text = "+%d" % value
      popup.add_theme_color_override("font_color", Color.GOLD)
      popup.position = score_label.position + Vector2(0, 20)
      add_child(popup)

      var tween = create_tween().set_parallel(true)
      tween.tween_property(popup, "position:y",
          popup.position.y - 30, 0.6)
      tween.tween_property(popup, "modulate:a", 0.0, 0.6)
      tween.chain().tween_callback(popup.queue_free)
	""")

	print("\n=== 게임 HUD 학습 완료 ===")
