# Chapter 05 - Physics & Collision
# 04-item-pickup.gd - 실전: 아이템 수집 시스템
#
# 이 파일에서 배울 내용:
# - Area2D 기반 아이템 수집 구현
# - 코인, 하트, 파워업 등 다양한 아이템 타입
# - 점수 추적 및 UI 업데이트 패턴
# - Tween을 활용한 수집 피드백 애니메이션
# - 자석 효과 (아이템이 플레이어에게 끌려오기)
#
# 실전에서 가장 많이 사용되는 충돌 감지 패턴입니다.

extends Node2D

# ============================================
# 1. 게임 상태 관리
# ============================================

var score: int = 0
var coins: int = 0
var health: int = 100
var max_health: int = 100
var has_shield: bool = false
var speed_multiplier: float = 1.0
var magnet_range: float = 0.0  # 0이면 자석 효과 없음

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)
signal health_changed(new_health: int)
signal item_collected(item_type: String)

func _ready():
	print("=== Chapter 05-4: 아이템 수집 시스템 ===\n")

	_show_item_base_class()
	_show_coin_item()
	_show_health_item()
	_show_powerup_item()
	_show_pickup_feedback()
	_show_magnet_effect()
	_show_item_spawner()
	_show_score_manager()
	_demonstrate_collection()

# ============================================
# 2. 아이템 베이스 클래스
# ============================================

func _show_item_base_class():
	print("--- 2. 아이템 베이스 클래스 ---")
	print("""
  # item_base.gd - 모든 아이템의 부모 클래스
  class_name ItemBase
  extends Area2D

  # 아이템 타입 열거형
  enum ItemType { COIN, HEART, SHIELD, SPEED_BOOST, MAGNET }

  @export var item_type: ItemType = ItemType.COIN
  @export var value: int = 1
  @export var despawn_time: float = 0.0  # 0이면 영구 지속

  # 수집 가능 여부
  var is_collectible: bool = true
  # 수집 처리 중인지 (중복 수집 방지)
  var is_being_collected: bool = false

  func _ready():
      # 시그널 연결
      body_entered.connect(_on_body_entered)

      # 충돌 설정: 아이템 레이어(4), 플레이어(2) 감지
      collision_layer = 0
      set_collision_layer_value(4, true)   # 아이템 레이어
      collision_mask = 0
      set_collision_mask_value(2, true)    # 플레이어만 감지

      # 자동 소멸 타이머
      if despawn_time > 0:
          _start_despawn_timer()

      # 등장 애니메이션
      _play_spawn_animation()

  func _on_body_entered(body: Node2D):
      if not is_collectible or is_being_collected:
          return

      if body.is_in_group("player") and body.has_method("collect_item"):
          is_being_collected = true
          # 충돌 비활성화 (중복 수집 방지)
          set_deferred("monitoring", false)
          # 아이템 효과 적용
          _apply_effect(body)
          # 수집 애니메이션 후 제거
          _play_collect_animation()

  # 서브클래스에서 오버라이드
  func _apply_effect(player: Node2D):
      pass  # 서브클래스에서 구현

  func _play_spawn_animation():
      # 아래에서 위로 튀어오르며 등장
      var target_y = position.y
      position.y += 20
      modulate.a = 0.0

      var tween = create_tween()
      tween.set_parallel(true)
      tween.tween_property(self, "position:y", target_y, 0.3) \\
          .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
      tween.tween_property(self, "modulate:a", 1.0, 0.2)

  func _play_collect_animation():
      var tween = create_tween()
      tween.set_parallel(true)
      # 위로 떠오르며 사라짐
      tween.tween_property(self, "position:y", position.y - 30, 0.3) \\
          .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
      tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
      tween.tween_property(self, "modulate:a", 0.0, 0.3)
      # 애니메이션 완료 후 제거
      tween.chain().tween_callback(queue_free)

  func _start_despawn_timer():
      # 소멸 전 깜빡임 경고
      await get_tree().create_timer(despawn_time - 2.0).timeout
      _play_despawn_warning()
      await get_tree().create_timer(2.0).timeout
      if not is_being_collected:
          queue_free()

  func _play_despawn_warning():
      # 깜빡임 효과
      var tween = create_tween().set_loops(4)
      tween.tween_property(self, "modulate:a", 0.3, 0.25)
      tween.tween_property(self, "modulate:a", 1.0, 0.25)
	""")
	print()

# ============================================
# 3. 코인 아이템
# ============================================

func _show_coin_item():
	print("--- 3. 코인 아이템 ---")
	print("""
  # coin.gd
  class_name CoinItem
  extends ItemBase  # 위의 item_base.gd 상속

  enum CoinType { BRONZE, SILVER, GOLD }

  @export var coin_type: CoinType = CoinType.BRONZE

  # 코인 타입별 가치
  var coin_values = {
      CoinType.BRONZE: 1,
      CoinType.SILVER: 5,
      CoinType.GOLD: 10,
  }

  func _ready():
      super._ready()  # 부모 _ready 호출
      item_type = ItemType.COIN
      value = coin_values[coin_type]

      # 동전 회전 애니메이션 (좌우로 찌그러지며 회전하는 느낌)
      _start_idle_animation()

  func _apply_effect(player: Node2D):
      # 플레이어의 점수/코인에 반영
      player.collect_item({
          "type": "coin",
          "value": value,
          "coin_type": CoinType.keys()[coin_type]
      })
      # 효과음 재생
      # AudioManager.play_sfx("coin_collect")

  func _start_idle_animation():
      # 위아래로 살짝 떠다니는 효과
      var tween = create_tween().set_loops()
      tween.tween_property(self, "position:y", position.y - 4, 0.6) \\
          .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
      tween.tween_property(self, "position:y", position.y + 4, 0.6) \\
          .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	""")
	print()

# ============================================
# 4. 회복 아이템
# ============================================

func _show_health_item():
	print("--- 4. 회복 아이템 (하트) ---")
	print("""
  # health_pickup.gd
  class_name HealthPickup
  extends ItemBase

  @export var heal_amount: int = 25

  func _ready():
      super._ready()
      item_type = ItemType.HEART
      value = heal_amount

  func _apply_effect(player: Node2D):
      # 이미 최대 체력이면 수집 불가
      if player.health >= player.max_health:
          is_being_collected = false
          monitoring = true  # 다시 감지 활성화
          return

      # 체력 회복
      var actual_heal = mini(heal_amount, player.max_health - player.health)
      player.collect_item({
          "type": "health",
          "value": actual_heal
      })

      # 회복 이펙트
      _show_heal_effect(actual_heal)

  func _show_heal_effect(amount: int):
      # 회복량 텍스트 팝업
      var label = Label.new()
      label.text = "+%d HP" % amount
      label.add_theme_color_override("font_color", Color.GREEN)
      label.position = Vector2(-20, -40)
      add_child(label)

      var tween = create_tween()
      tween.set_parallel(true)
      tween.tween_property(label, "position:y", label.position.y - 30, 0.8)
      tween.tween_property(label, "modulate:a", 0.0, 0.8)
	""")
	print()

# ============================================
# 5. 파워업 아이템
# ============================================

func _show_powerup_item():
	print("--- 5. 파워업 아이템 ---")
	print("""
  # powerup.gd
  class_name PowerupItem
  extends ItemBase

  enum PowerupType { SHIELD, SPEED_BOOST, MAGNET, DOUBLE_SCORE }

  @export var powerup_type: PowerupType = PowerupType.SHIELD
  @export var duration: float = 10.0  # 지속 시간 (초)

  func _ready():
      super._ready()
      match powerup_type:
          PowerupType.SHIELD:
              item_type = ItemType.SHIELD
          PowerupType.SPEED_BOOST:
              item_type = ItemType.SPEED_BOOST
          PowerupType.MAGNET:
              item_type = ItemType.MAGNET

  func _apply_effect(player: Node2D):
      player.collect_item({
          "type": "powerup",
          "powerup": PowerupType.keys()[powerup_type],
          "duration": duration
      })

  # 플레이어 측 파워업 처리:
  # func apply_powerup(data: Dictionary):
  #     match data.powerup:
  #         "SHIELD":
  #             has_shield = true
  #             $ShieldSprite.visible = true
  #             await get_tree().create_timer(data.duration).timeout
  #             has_shield = false
  #             $ShieldSprite.visible = false
  #
  #         "SPEED_BOOST":
  #             speed_multiplier = 1.5
  #             $SpeedParticles.emitting = true
  #             await get_tree().create_timer(data.duration).timeout
  #             speed_multiplier = 1.0
  #             $SpeedParticles.emitting = false
  #
  #         "MAGNET":
  #             magnet_range = 150.0
  #             await get_tree().create_timer(data.duration).timeout
  #             magnet_range = 0.0
	""")
	print()

# ============================================
# 6. 수집 피드백 애니메이션
# ============================================

func _show_pickup_feedback():
	print("--- 6. 수집 피드백 애니메이션 (Tween) ---")

	# 실제로 실행 가능한 Tween 예시
	print("[수집 시 팝업 텍스트 - 실행 데모]")
	_demo_score_popup()

	print("\n[다양한 수집 이펙트 패턴]")
	print("""
  # 1. 흡수 효과 (아이템이 플레이어 쪽으로 빨려감)
  func collect_with_absorb(item: Node2D, player: Node2D):
      var tween = create_tween()
      tween.tween_property(item, "global_position",
          player.global_position, 0.2) \\
          .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
      tween.parallel().tween_property(item, "scale",
          Vector2.ZERO, 0.2)
      tween.tween_callback(item.queue_free)

  # 2. 폭발 효과 (수집 시 파편 튀기기)
  func collect_with_burst(item: Node2D):
      # 파티클 여러 개 생성
      for i in range(6):
          var particle = Sprite2D.new()  # 또는 미리 만든 씬
          particle.texture = item_texture
          particle.scale = Vector2(0.3, 0.3)
          particle.global_position = item.global_position
          get_parent().add_child(particle)

          # 랜덤 방향으로 튕기기
          var angle = randf() * TAU
          var distance = randf_range(30, 60)
          var target_pos = particle.global_position + Vector2(
              cos(angle) * distance,
              sin(angle) * distance
          )

          var tween = create_tween()
          tween.set_parallel(true)
          tween.tween_property(particle, "global_position",
              target_pos, 0.4).set_trans(Tween.TRANS_QUAD)
          tween.tween_property(particle, "modulate:a", 0.0, 0.4)
          tween.chain().tween_callback(particle.queue_free)

      item.queue_free()

  # 3. 스케일 펄스 효과 (수집 순간 커졌다 사라짐)
  func collect_with_pulse(item: Node2D):
      var tween = create_tween()
      tween.tween_property(item, "scale",
          Vector2(2.0, 2.0), 0.1).set_trans(Tween.TRANS_BACK)
      tween.parallel().tween_property(item, "modulate:a", 0.0, 0.2)
      tween.tween_callback(item.queue_free)
	""")
	print()

func _demo_score_popup():
	# 간단한 점수 팝업 시뮬레이션
	var popup = Label.new()
	popup.text = "+10"
	popup.position = Vector2(100, 100)
	add_child(popup)

	print("  팝업 라벨 생성: '+10' at (100, 100)")

	var tween = create_tween()
	tween.set_parallel(true)
	# 위로 떠오르기
	tween.tween_property(popup, "position:y", 70.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 페이드 아웃
	tween.tween_property(popup, "modulate:a", 0.0, 0.8) \
		.set_delay(0.3)
	# 완료 후 제거
	tween.chain().tween_callback(popup.queue_free)

	print("  Tween 설정: 0.8초간 위로 이동 + 페이드 아웃")

# ============================================
# 7. 자석 효과 (Magnet)
# ============================================

func _show_magnet_effect():
	print("--- 7. 자석 효과 (아이템이 플레이어에게 끌려옴) ---")
	print("""
  # player.gd 에 추가
  @export var magnet_range: float = 0.0  # 0이면 비활성
  @export var magnet_speed: float = 300.0

  func _physics_process(delta):
      if magnet_range > 0:
          _attract_nearby_items(delta)

  func _attract_nearby_items(delta: float):
      # "items" 그룹의 모든 아이템 확인
      var items = get_tree().get_nodes_in_group("items")

      for item in items:
          if not is_instance_valid(item):
              continue
          if not item is Area2D:
              continue

          var distance = global_position.distance_to(item.global_position)

          if distance < magnet_range:
              # 거리에 반비례하는 흡인력 (가까울수록 강하게)
              var pull_strength = 1.0 - (distance / magnet_range)
              pull_strength = pow(pull_strength, 2)  # 비선형 (가까울수록 급격히)

              # 플레이어 방향으로 이동
              var direction = (global_position - item.global_position).normalized()
              item.position += direction * magnet_speed * pull_strength * delta

  # 대안: Area2D를 이용한 자석 범위
  # MagnetArea (Area2D) - 큰 원형 CollisionShape2D
  # func _on_magnet_area_body_entered(body):
  #     -> body가 아이템이면 끌어당기기 시작
	""")
	print()

# ============================================
# 8. 아이템 스포너
# ============================================

func _show_item_spawner():
	print("--- 8. 아이템 스포너 ---")
	print("""
  # item_spawner.gd
  extends Node2D

  @export var coin_scene: PackedScene
  @export var heart_scene: PackedScene
  @export var powerup_scene: PackedScene

  @export var spawn_interval: float = 3.0
  @export var max_items: int = 20
  @export var spawn_area: Rect2 = Rect2(0, 0, 800, 400)

  var current_items: int = 0
  var spawn_timer: Timer

  # 아이템 드롭 확률 테이블
  var drop_table = [
      {"scene": "coin",    "weight": 70},  # 70% 확률
      {"scene": "heart",   "weight": 20},  # 20% 확률
      {"scene": "powerup", "weight": 10},  # 10% 확률
  ]

  func _ready():
      spawn_timer = Timer.new()
      spawn_timer.wait_time = spawn_interval
      spawn_timer.timeout.connect(_on_spawn_timer)
      spawn_timer.autostart = true
      add_child(spawn_timer)

  func _on_spawn_timer():
      if current_items >= max_items:
          return
      spawn_random_item()

  func spawn_random_item():
      # 가중치 기반 랜덤 선택
      var total_weight = 0
      for entry in drop_table:
          total_weight += entry.weight

      var roll = randi() % total_weight
      var cumulative = 0
      var selected_type = "coin"

      for entry in drop_table:
          cumulative += entry.weight
          if roll < cumulative:
              selected_type = entry.scene
              break

      # 랜덤 위치에 스폰
      var spawn_pos = Vector2(
          randf_range(spawn_area.position.x, spawn_area.end.x),
          randf_range(spawn_area.position.y, spawn_area.end.y)
      )

      var item_scene: PackedScene
      match selected_type:
          "coin": item_scene = coin_scene
          "heart": item_scene = heart_scene
          "powerup": item_scene = powerup_scene

      if item_scene:
          var item = item_scene.instantiate()
          item.position = spawn_pos
          item.add_to_group("items")
          item.tree_exited.connect(func(): current_items -= 1)
          add_child(item)
          current_items += 1

  # 적 처치 시 아이템 드롭
  func drop_loot(enemy_position: Vector2):
      var roll = randf()
      if roll < 0.3:  # 30% 확률로 코인 드롭
          var coin = coin_scene.instantiate()
          coin.position = enemy_position
          # 위로 튀어오르는 효과
          var tween = create_tween()
          coin.position.y -= 20
          tween.tween_property(coin, "position:y",
              enemy_position.y, 0.5) \\
              .set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
          add_child(coin)
	""")
	print()

# ============================================
# 9. 점수 관리 시스템
# ============================================

func _show_score_manager():
	print("--- 9. 점수 관리 시스템 ---")
	print("""
  # score_manager.gd (Autoload 추천)
  extends Node

  signal score_updated(new_score: int)
  signal coins_updated(new_coins: int)
  signal combo_changed(combo: int)
  signal high_score_beaten(new_high: int)

  var score: int = 0
  var coins: int = 0
  var combo: int = 0
  var combo_timer: float = 0.0
  var combo_timeout: float = 2.0  # 콤보 유지 시간
  var high_score: int = 0
  var score_multiplier: float = 1.0

  func _process(delta):
      # 콤보 타이머 감소
      if combo > 0:
          combo_timer -= delta
          if combo_timer <= 0:
              reset_combo()

  func add_score(base_points: int):
      # 콤보 보너스 적용
      combo += 1
      combo_timer = combo_timeout

      var combo_bonus = 1.0 + (combo - 1) * 0.1  # 콤보당 10% 추가
      var final_points = int(base_points * combo_bonus * score_multiplier)

      score += final_points
      score_updated.emit(score)
      combo_changed.emit(combo)

      # 하이스코어 갱신 확인
      if score > high_score:
          high_score = score
          high_score_beaten.emit(high_score)

      return final_points  # 실제 획득 점수 반환 (UI 표시용)

  func add_coins(amount: int):
      coins += amount
      coins_updated.emit(coins)

  func reset_combo():
      combo = 0
      combo_changed.emit(combo)

  func reset():
      score = 0
      coins = 0
      combo = 0
      score_multiplier = 1.0
      score_updated.emit(score)
      coins_updated.emit(coins)
	""")
	print()

# ============================================
# 10. 통합 데모: 아이템 수집 흐름
# ============================================

func _demonstrate_collection():
	print("--- 10. 통합 데모: 아이템 수집 시뮬레이션 ---\n")

	# 점수 시뮬레이션
	print("[코인 수집 시뮬레이션]")

	var combo = 0
	var total_score = 0
	var total_coins = 0

	# 코인 여러 개 연속 수집
	var items = [
		{"type": "coin", "value": 1, "name": "동전"},
		{"type": "coin", "value": 5, "name": "은화"},
		{"type": "coin", "value": 10, "name": "금화"},
		{"type": "health", "value": 25, "name": "하트"},
		{"type": "coin", "value": 1, "name": "동전"},
		{"type": "powerup", "value": 0, "name": "실드"},
	]

	for item in items:
		match item.type:
			"coin":
				combo += 1
				var combo_bonus = 1.0 + (combo - 1) * 0.1
				var points = int(item.value * 10 * combo_bonus)
				total_score += points
				total_coins += item.value
				print("  %s 수집! +%d점 (콤보 x%d, 보너스 %.1f배) | 총점: %d, 코인: %d" % [
					item.name, points, combo, combo_bonus, total_score, total_coins
				])
			"health":
				var healed = mini(item.value, max_health - health)
				health += healed
				print("  %s 수집! +%d HP (현재 체력: %d/%d)" % [
					item.name, healed, health, max_health
				])
			"powerup":
				print("  %s 획득! 10초간 보호막 활성화" % item.name)
				has_shield = true

	print("\n[최종 결과]")
	print("  총 점수: %d" % total_score)
	print("  총 코인: %d" % total_coins)
	print("  체력: %d/%d" % [health, max_health])
	print("  보호막: %s" % ("활성" if has_shield else "비활성"))
	print("  최대 콤보: %d" % combo)

	print("\n=== 아이템 수집 시스템 학습 완료 ===")
