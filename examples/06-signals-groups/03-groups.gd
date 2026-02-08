# Chapter 06 - Signals & Groups
# 03-groups.gd - 그룹(Groups) 시스템
#
# 이 파일에서 배울 내용:
# - add_to_group()으로 그룹에 추가
# - is_in_group()으로 그룹 멤버십 확인
# - get_tree().call_group()으로 그룹 전체에 함수 호출
# - get_tree().get_nodes_in_group()으로 그룹 노드 목록
# - 실전 활용: 적 관리, 상태 효과, 일괄 처리
#
# 그룹은 노드를 태그(tag)처럼 분류하는 시스템입니다.
# 하나의 노드가 여러 그룹에 속할 수 있습니다.

extends Node

# ============================================
# 1. 그룹(Group) 개념
# ============================================
# 그룹 = 노드의 태그/카테고리
#
# 예시:
#   "player"  - 플레이어 캐릭터
#   "enemies" - 모든 적
#   "coins"   - 모든 코인
#   "damageable" - 데미지를 받을 수 있는 모든 것
#   "saveable" - 저장해야 하는 노드들
#   "pausable" - 일시정지 영향을 받는 노드들
#
# 하나의 노드가 여러 그룹에 속할 수 있음:
#   Enemy -> "enemies", "damageable", "saveable", "pausable"

func _ready():
	print("=== Chapter 06-3: 그룹(Groups) 시스템 ===\n")

	_demonstrate_add_remove()
	_demonstrate_is_in_group()
	_demonstrate_call_group()
	_demonstrate_get_nodes_in_group()
	_demonstrate_notify_group()
	_practical_enemy_management()
	_practical_save_system()
	_practical_buff_system()
	_group_naming_conventions()

# ============================================
# 2. 그룹 추가/제거
# ============================================

func _demonstrate_add_remove():
	print("--- 2. 그룹 추가/제거 ---")

	# 테스트용 노드 생성
	var player = Node2D.new()
	player.name = "Player"
	add_child(player)

	var enemy1 = Node2D.new()
	enemy1.name = "Goblin"
	add_child(enemy1)

	var enemy2 = Node2D.new()
	enemy2.name = "Orc"
	add_child(enemy2)

	# 코드로 그룹 추가
	print("[add_to_group(group_name)]")
	player.add_to_group("player")
	player.add_to_group("damageable")
	player.add_to_group("saveable")
	print("  Player -> 'player', 'damageable', 'saveable'")

	enemy1.add_to_group("enemies")
	enemy1.add_to_group("damageable")
	print("  Goblin -> 'enemies', 'damageable'")

	enemy2.add_to_group("enemies")
	enemy2.add_to_group("damageable")
	enemy2.add_to_group("boss")
	print("  Orc -> 'enemies', 'damageable', 'boss'")

	# 그룹 확인
	print("\n[get_groups() - 노드가 속한 그룹 목록]")
	print("  Player 그룹: %s" % str(player.get_groups()))
	print("  Goblin 그룹: %s" % str(enemy1.get_groups()))
	print("  Orc 그룹: %s" % str(enemy2.get_groups()))

	# 그룹 제거
	print("\n[remove_from_group(group_name)]")
	enemy2.remove_from_group("boss")
	print("  Orc에서 'boss' 그룹 제거")
	print("  Orc 그룹: %s" % str(enemy2.get_groups()))

	# persistent 그룹 (에디터에서 추가한 그룹)
	print("\n[add_to_group(name, persistent)]")
	print("  add_to_group('enemies', true)  # 에디터에서 보임")
	print("  add_to_group('temp_buff', false)  # 코드에서만 (기본)")

	print()

# ============================================
# 3. is_in_group() - 그룹 확인
# ============================================

func _demonstrate_is_in_group():
	print("--- 3. is_in_group() - 그룹 멤버십 확인 ---")

	# 충돌 콜백에서 가장 많이 사용
	print("[충돌 시 그룹으로 대상 식별]")
	print("""
  # Area2D 충돌 콜백에서
  func _on_body_entered(body: Node2D):
      if body.is_in_group("player"):
          # 플레이어와 충돌
          apply_damage_to_player(body)

      elif body.is_in_group("enemies"):
          # 적과 충돌
          apply_damage_to_enemy(body)

      elif body.is_in_group("items"):
          # 아이템과 충돌
          collect_item(body)
	""")

	# 실전 예시: 총알이 타겟 확인
	print("[총알의 충돌 판정]")
	print("""
  # bullet.gd
  var shooter_group: String = "player"  # 누가 쐈는지

  func _on_body_entered(body: Node2D):
      # 자기 팀은 무시
      if body.is_in_group(shooter_group):
          return

      # damageable 그룹이면 데미지
      if body.is_in_group("damageable"):
          if body.has_method("take_damage"):
              body.take_damage(damage)

      # 어떤 것이든 충돌하면 총알 제거
      queue_free()
	""")

	# 여러 그룹 조합 확인
	print("[여러 그룹 조합 확인]")
	print("""
  # 보스 + 적 그룹 모두 확인
  if body.is_in_group("enemies") and body.is_in_group("boss"):
      show_boss_health_bar(body)

  # damageable이면서 무적이 아닌 경우
  if body.is_in_group("damageable") and not body.is_in_group("invincible"):
      body.take_damage(10)
	""")

	print()

# ============================================
# 4. call_group() - 그룹 전체에 함수 호출
# ============================================

func _demonstrate_call_group():
	print("--- 4. call_group() - 그룹 일괄 함수 호출 ---")

	# 테스트용 노드 생성 (메서드를 가진)
	_create_test_enemies()

	# call_group: 그룹의 모든 노드에서 함수 호출
	print("[get_tree().call_group(group, method, ...args)]")
	print("  모든 적에게 함수 호출:")

	# 직접 call_group 사용
	print("\n  get_tree().call_group('test_enemies', 'alert')")
	print("  -> 모든 적이 경계 상태로 전환")

	print("\n  get_tree().call_group('test_enemies', 'take_damage', 25)")
	print("  -> 모든 적에게 25 데미지")

	# call_group 실제 실행
	get_tree().call_group("test_enemies", "receive_alert")

	# call_group_flags: 실행 순서/조건 제어
	print("\n[call_group_flags - 플래그 옵션]")
	print("  SceneTree.GROUP_CALL_DEFAULT  - 기본 (즉시 호출)")
	print("  SceneTree.GROUP_CALL_DEFERRED - 프레임 끝에 호출")
	print("  SceneTree.GROUP_CALL_UNIQUE   - 중복 호출 방지")

	print("""
  # 지연 호출 (물리 처리 중 안전하게)
  get_tree().call_group_flags(
      SceneTree.GROUP_CALL_DEFERRED,
      "enemies",
      "die"
  )
	""")

	# 실전 활용
	print("[실전 활용 예시]")
	print("""
  # 모든 적 일시정지
  get_tree().call_group("enemies", "set_process", false)

  # 모든 적 제거
  get_tree().call_group("enemies", "queue_free")

  # 모든 코인 자석 효과
  get_tree().call_group("coins", "attract_to", player.position)

  # 모든 저장 가능한 노드에서 데이터 수집
  get_tree().call_group("saveable", "save_data")
	""")

	print()

# 테스트용 적 노드 생성
func _create_test_enemies():
	for i in range(3):
		var enemy = Node.new()
		enemy.name = "TestEnemy_%d" % i
		enemy.set_script(_create_enemy_script())
		enemy.add_to_group("test_enemies")
		add_child(enemy)

func _create_enemy_script() -> GDScript:
	var script = GDScript.new()
	script.source_code = """
extends Node

func receive_alert():
	print("  [%s] 경계 상태 전환!" % name)
"""
	script.reload()
	return script

# ============================================
# 5. get_nodes_in_group() - 그룹 노드 목록
# ============================================

func _demonstrate_get_nodes_in_group():
	print("--- 5. get_nodes_in_group() - 그룹 노드 목록 ---")

	# 그룹의 모든 노드 가져오기
	print("[get_tree().get_nodes_in_group(group)]")
	var test_enemies = get_tree().get_nodes_in_group("test_enemies")
	print("  'test_enemies' 그룹: %d개 노드" % test_enemies.size())
	for enemy in test_enemies:
		print("    - %s" % enemy.name)

	# 실전 패턴: 가장 가까운 적 찾기
	print("\n[패턴: 가장 가까운 적 찾기]")
	print("""
  func find_nearest_enemy(from_pos: Vector2) -> Node2D:
      var enemies = get_tree().get_nodes_in_group("enemies")
      var nearest: Node2D = null
      var min_dist: float = INF

      for enemy in enemies:
          if not is_instance_valid(enemy):
              continue
          var dist = from_pos.distance_to(enemy.global_position)
          if dist < min_dist:
              min_dist = dist
              nearest = enemy

      return nearest
	""")

	# 실전 패턴: 범위 내 적 찾기
	print("[패턴: 범위 내 적 찾기]")
	print("""
  func get_enemies_in_range(center: Vector2, radius: float) -> Array:
      var result: Array[Node2D] = []
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if not is_instance_valid(enemy):
              continue
          if center.distance_to(enemy.global_position) <= radius:
              result.append(enemy)
      return result
	""")

	# 실전 패턴: 적 수 카운트
	print("[패턴: 남은 적 수 확인]")
	print("""
  func get_remaining_enemies() -> int:
      return get_tree().get_nodes_in_group("enemies").size()

  func check_wave_complete() -> bool:
      return get_remaining_enemies() == 0
	""")

	print()

# ============================================
# 6. notify_group() - 그룹 노티피케이션
# ============================================

func _demonstrate_notify_group():
	print("--- 6. notify_group() ---")

	print("[get_tree().notify_group(group, notification)]")
	print("  그룹의 모든 노드에 노티피케이션 전송")
	print("")
	print("  # 유용한 노티피케이션:")
	print("  NOTIFICATION_PAUSED            - 일시정지됨")
	print("  NOTIFICATION_UNPAUSED          - 일시정지 해제")
	print("  NOTIFICATION_VISIBILITY_CHANGED - 가시성 변경")
	print("  NOTIFICATION_WM_CLOSE_REQUEST  - 창 닫기 요청")

	print("\n[커스텀 노티피케이션과 함께 사용]")
	print("""
  # 노드에서 _notification 처리
  func _notification(what):
      match what:
          1000:  # 커스텀 번호
              print("커스텀 알림 받음!")

  # 그룹에 커스텀 노티피케이션
  get_tree().notify_group("enemies", 1000)
	""")

	print()

# ============================================
# 7. 실전: 적 관리 시스템
# ============================================

func _practical_enemy_management():
	print("--- 7. 실전: 적 관리 시스템 ---")
	print("""
  # enemy_manager.gd
  extends Node

  signal all_enemies_defeated
  signal enemy_count_changed(count: int)

  func get_enemy_count() -> int:
      return get_tree().get_nodes_in_group("enemies").size()

  # 모든 적에게 데미지 (폭탄 등)
  func damage_all_enemies(amount: int):
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if enemy.has_method("take_damage"):
              enemy.take_damage(amount)

  # 모든 적 동결 (시간 정지 스킬)
  func freeze_all_enemies(duration: float):
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if enemy.has_method("freeze"):
              enemy.freeze(duration)
          # 또는 간단하게 프로세스 중지
          enemy.set_process(false)
          enemy.set_physics_process(false)

      await get_tree().create_timer(duration).timeout

      # 해동
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if is_instance_valid(enemy):
              enemy.set_process(true)
              enemy.set_physics_process(true)

  # 화면 밖 적 제거 (최적화)
  func cleanup_offscreen_enemies(screen_rect: Rect2):
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if not screen_rect.has_point(enemy.global_position):
              enemy.queue_free()

  # 난이도 스케일링: 모든 적 스탯 조정
  func scale_enemy_stats(multiplier: float):
      for enemy in get_tree().get_nodes_in_group("enemies"):
          if enemy.has_method("scale_stats"):
              enemy.scale_stats(multiplier)
	""")

	# 시뮬레이션
	print("[적 관리 시뮬레이션]")
	var enemy_names = ["슬라임A", "슬라임B", "고블린", "오크전사", "드래곤"]
	var alive_enemies = enemy_names.duplicate()

	print("  적 수: %d - %s" % [alive_enemies.size(), str(alive_enemies)])

	# 폭탄 사용!
	print("  >> 폭탄 사용! 모든 적에게 30 데미지")
	alive_enemies.erase("슬라임A")  # HP 낮은 적 사망
	alive_enemies.erase("슬라임B")
	print("  사망: 슬라임A, 슬라임B")
	print("  남은 적: %d - %s" % [alive_enemies.size(), str(alive_enemies)])

	# 보스 처치
	alive_enemies.erase("드래곤")
	print("  >> 드래곤 처치!")
	print("  남은 적: %d - %s" % [alive_enemies.size(), str(alive_enemies)])

	print()

# ============================================
# 8. 실전: 세이브 시스템
# ============================================

func _practical_save_system():
	print("--- 8. 실전: 그룹 기반 세이브 시스템 ---")
	print("""
  # 저장 가능한 노드에 "saveable" 그룹과 save/load 메서드 구현

  # saveable_component.gd (저장 가능한 노드에 추가)
  extends Node

  func _ready():
      add_to_group("saveable")

  func get_save_data() -> Dictionary:
      var parent = get_parent()
      return {
          "filename": parent.scene_file_path,
          "node_path": parent.get_path(),
          "position_x": parent.position.x if parent is Node2D else 0,
          "position_y": parent.position.y if parent is Node2D else 0,
          "custom_data": parent.get_save_data() if parent.has_method("get_save_data") else {}
      }

  func load_save_data(data: Dictionary):
      var parent = get_parent()
      if parent is Node2D:
          parent.position = Vector2(data.position_x, data.position_y)
      if parent.has_method("load_save_data"):
          parent.load_save_data(data.custom_data)

  # save_manager.gd (전역)
  func save_game(slot: String):
      var save_data = []
      for node in get_tree().get_nodes_in_group("saveable"):
          save_data.append(node.get_save_data())

      var file = FileAccess.open("user://save_%s.json" % slot, FileAccess.WRITE)
      file.store_string(JSON.stringify(save_data))
      file.close()

  func load_game(slot: String):
      var file = FileAccess.open("user://save_%s.json" % slot, FileAccess.READ)
      var data = JSON.parse_string(file.get_as_text())
      file.close()

      # 기존 saveable 노드 정리
      for node in get_tree().get_nodes_in_group("saveable"):
          node.get_parent().queue_free()

      # 저장된 데이터로 노드 재생성
      for entry in data:
          var scene = load(entry.filename)
          var node = scene.instantiate()
          get_tree().current_scene.add_child(node)
          node.get_node("SaveableComponent").load_save_data(entry)
	""")

	print()

# ============================================
# 9. 실전: 버프/디버프 시스템
# ============================================

func _practical_buff_system():
	print("--- 9. 실전: 버프/디버프 시스템 ---")
	print("""
  # 버프를 받은 노드를 그룹으로 관리

  # buff_system.gd
  extends Node

  # 독 데미지 (매초)
  func apply_poison(target: Node2D, duration: float, dps: float):
      target.add_to_group("poisoned")
      var timer = 0.0
      while timer < duration and is_instance_valid(target):
          await get_tree().create_timer(1.0).timeout
          timer += 1.0
          if target.has_method("take_damage"):
              target.take_damage(int(dps))
      if is_instance_valid(target):
          target.remove_from_group("poisoned")

  # 속도 증가 버프
  func apply_speed_buff(target: Node2D, duration: float, multiplier: float):
      target.add_to_group("speed_buffed")
      var original_speed = target.speed
      target.speed *= multiplier

      await get_tree().create_timer(duration).timeout

      if is_instance_valid(target):
          target.speed = original_speed
          target.remove_from_group("speed_buffed")

  # 그룹으로 현재 상태 확인
  func is_poisoned(node: Node) -> bool:
      return node.is_in_group("poisoned")

  func is_speed_buffed(node: Node) -> bool:
      return node.is_in_group("speed_buffed")

  # UI에서 버프 아이콘 표시
  func get_active_buffs(node: Node) -> Array[String]:
      var buffs: Array[String] = []
      if node.is_in_group("poisoned"):
          buffs.append("poison")
      if node.is_in_group("speed_buffed"):
          buffs.append("speed")
      if node.is_in_group("shielded"):
          buffs.append("shield")
      if node.is_in_group("invincible"):
          buffs.append("invincible")
      return buffs
	""")

	# 시뮬레이션
	print("[버프 시뮬레이션]")
	var test_node = Node.new()
	test_node.name = "TestPlayer"
	add_child(test_node)

	print("  버프 적용 전: %s" % str(test_node.get_groups()))

	test_node.add_to_group("speed_buffed")
	test_node.add_to_group("shielded")
	print("  속도 버프 + 실드: %s" % str(test_node.get_groups()))

	print("  poisoned? %s" % str(test_node.is_in_group("poisoned")))
	print("  shielded? %s" % str(test_node.is_in_group("shielded")))

	test_node.remove_from_group("shielded")
	print("  실드 해제 후: %s" % str(test_node.get_groups()))

	test_node.queue_free()
	print()

# ============================================
# 10. 그룹 네이밍 컨벤션
# ============================================

func _group_naming_conventions():
	print("--- 10. 그룹 네이밍 컨벤션 ---")

	print("[엔티티 타입 그룹]")
	print("  'player'          - 플레이어")
	print("  'enemies'         - 적")
	print("  'npcs'            - NPC")
	print("  'items'           - 아이템")
	print("  'projectiles'     - 투사체")
	print("  'obstacles'       - 장애물")

	print("\n[기능/속성 그룹]")
	print("  'damageable'      - 데미지 받을 수 있음")
	print("  'interactable'    - 상호작용 가능")
	print("  'saveable'        - 저장 대상")
	print("  'respawnable'     - 리스폰 가능")
	print("  'destructible'    - 파괴 가능")

	print("\n[상태 그룹 (동적)]")
	print("  'poisoned'        - 독 상태")
	print("  'stunned'         - 기절 상태")
	print("  'invincible'      - 무적 상태")
	print("  'speed_buffed'    - 속도 증가 중")

	print("\n[시스템 그룹]")
	print("  'pausable'        - 일시정지 영향")
	print("  'hud_elements'    - HUD 요소")
	print("  'audio_sources'   - 오디오 소스")
	print("  'camera_targets'  - 카메라 추적 대상")

	print("\n[권장사항]")
	print("  - snake_case 사용 (Godot 컨벤션)")
	print("  - 복수형: enemies, items (목록)")
	print("  - 단수형: player (유일한 존재)")
	print("  - 형용사: damageable, saveable (속성)")
	print("  - 상태: poisoned, stunned (현재 상태)")

	print("\n=== 그룹 시스템 학습 완료 ===")
