# Chapter 05 - Physics & Collision
# 02-area2d-detection.gd - Area2D를 활용한 충돌 감지
#
# 이 파일에서 배울 내용:
# - Area2D의 역할과 시그널 시스템
# - body_entered / body_exited 시그널
# - area_entered / area_exited 시그널
# - monitoring과 monitorable 속성
# - overlap 감지와 실전 활용 패턴
#
# Area2D는 물리적 충돌 없이 영역 겹침만 감지합니다.
# 트리거 존, 아이템 수집, 데미지 영역 등에 활용됩니다.

extends Area2D

# ============================================
# 1. Area2D 기본 구조
# ============================================
# Area2D 노드 구조:
#   Area2D (이 스크립트)
#     +-- CollisionShape2D (감지 영역 정의)
#
# Area2D가 감지할 수 있는 대상:
# - PhysicsBody2D (StaticBody2D, RigidBody2D, CharacterBody2D)
#   -> body_entered / body_exited 시그널
# - 다른 Area2D
#   -> area_entered / area_exited 시그널

# ============================================
# 2. 시그널 선언 (커스텀)
# ============================================
signal player_detected(player_node)
signal player_lost()
signal damage_dealt(amount: int)

# 감지 상태 추적 변수
var bodies_in_area: Array = []
var areas_in_area: Array = []
var is_player_inside: bool = false

func _ready():
	print("=== Chapter 05-2: Area2D 충돌 감지 ===\n")

	_setup_area2d_properties()
	_connect_signals_by_code()
	_explain_signal_types()
	_show_overlap_detection()
	_practical_examples()
	_monitoring_explanation()

# ============================================
# 3. Area2D 속성 설정
# ============================================

func _setup_area2d_properties():
	print("--- 3. Area2D 속성 설정 ---")

	# monitoring: 이 Area2D가 다른 객체를 감지할지 여부
	monitoring = true
	print("monitoring = true (다른 객체 감지 활성화)")

	# monitorable: 다른 Area2D가 이 Area2D를 감지할 수 있는지 여부
	monitorable = true
	print("monitorable = true (다른 Area2D에 의해 감지 가능)")

	# priority: 겹치는 Area2D의 물리 처리 우선순위
	priority = 0
	print("priority = 0 (기본 우선순위)")

	# 충돌 레이어 설정
	collision_layer = 0
	set_collision_layer_value(7, true)  # 트리거 영역 레이어
	collision_mask = 0
	set_collision_mask_value(2, true)   # 플레이어 감지
	print("layer: 7 (트리거), mask: 2 (플레이어)")

	# gravity 관련 (Area2D는 중력 영역으로도 사용 가능)
	gravity_space_override = Area2D.SPACE_OVERRIDE_DISABLED
	print("gravity_space_override: DISABLED (중력 영역 미사용)")

	print()

# ============================================
# 4. 시그널 코드 연결 (connect)
# ============================================

func _connect_signals_by_code():
	print("--- 4. 시그널 코드 연결 방법 ---")

	# 방법 1: 일반 함수 연결
	print("[방법 1] 일반 함수 연결:")
	print("  body_entered.connect(_on_body_entered)")
	print("  body_exited.connect(_on_body_exited)")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 방법 2: 람다(Lambda) 연결
	print("\n[방법 2] 람다 함수 연결:")
	print("  area_entered.connect(func(area): print('감지: ', area.name))")
	area_entered.connect(func(area):
		areas_in_area.append(area)
		print("  [Area 진입] %s" % area.name)
	)
	area_exited.connect(func(area):
		areas_in_area.erase(area)
		print("  [Area 이탈] %s" % area.name)
	)

	# 방법 3: bind로 추가 인자 전달
	print("\n[방법 3] bind()로 추가 데이터 전달:")
	print("  body_entered.connect(_on_damage_area_entered.bind(25))")
	print("  -> 진입 시 데미지 25 전달")

	# 방법 4: 일회성 연결 (CONNECT_ONE_SHOT)
	print("\n[방법 4] 일회성 연결 (한 번만 실행):")
	print("  body_entered.connect(_on_first_entry, CONNECT_ONE_SHOT)")

	# 방법 5: 지연 연결 (CONNECT_DEFERRED)
	print("\n[방법 5] 지연 연결 (프레임 끝에 실행):")
	print("  body_entered.connect(_on_body_entered, CONNECT_DEFERRED)")
	print("  -> 물리 처리 중 노드 제거 시 안전하게 처리")

	print()

# ============================================
# 5. 시그널 종류와 콜백 함수
# ============================================

func _explain_signal_types():
	print("--- 5. Area2D 시그널 종류 ---")

	print("[PhysicsBody2D 관련 시그널]")
	print("  body_entered(body: Node2D)")
	print("    -> CharacterBody2D, RigidBody2D, StaticBody2D 진입 시")
	print("  body_exited(body: Node2D)")
	print("    -> CharacterBody2D, RigidBody2D, StaticBody2D 이탈 시")

	print("\n[다른 Area2D 관련 시그널]")
	print("  area_entered(area: Area2D)")
	print("    -> 다른 Area2D가 이 영역에 진입 시")
	print("  area_exited(area: Area2D)")
	print("    -> 다른 Area2D가 이 영역에서 이탈 시")

	print("\n[body_shape 시그널 - 세밀한 충돌 정보]")
	print("  body_shape_entered(body_rid, body, body_shape_idx, local_shape_idx)")
	print("    -> 어떤 CollisionShape끼리 겹쳤는지 상세 정보")
	print("  body_shape_exited(body_rid, body, body_shape_idx, local_shape_idx)")

	print()

# ============================================
# 6. 콜백 함수 구현
# ============================================

# PhysicsBody2D가 진입했을 때
func _on_body_entered(body: Node2D):
	bodies_in_area.append(body)
	print("  [Body 진입] %s (총 %d개 body)" % [body.name, bodies_in_area.size()])

	# 플레이어인지 확인 - 그룹 활용
	if body.is_in_group("player"):
		is_player_inside = true
		player_detected.emit(body)
		print("    -> 플레이어 감지!")

	# 적인지 확인
	if body.is_in_group("enemy"):
		print("    -> 적 감지! 이름: %s" % body.name)

# PhysicsBody2D가 이탈했을 때
func _on_body_exited(body: Node2D):
	bodies_in_area.erase(body)
	print("  [Body 이탈] %s (남은 %d개 body)" % [body.name, bodies_in_area.size()])

	if body.is_in_group("player"):
		is_player_inside = false
		player_lost.emit()
		print("    -> 플레이어 영역 이탈")

# bind로 추가 데이터를 받는 콜백
func _on_damage_area_entered(body: Node2D, damage_amount: int):
	print("  [데미지 영역] %s에게 %d 데미지!" % [body.name, damage_amount])
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
	damage_dealt.emit(damage_amount)

# ============================================
# 7. 현재 겹침 상태 확인
# ============================================

func _show_overlap_detection():
	print("--- 7. Overlap 감지 (현재 겹친 객체 조회) ---")

	# get_overlapping_bodies() - 현재 겹쳐있는 PhysicsBody2D 목록
	print("[get_overlapping_bodies()]")
	print("  현재 영역 내 PhysicsBody2D 목록을 반환")
	print("  var bodies = get_overlapping_bodies()")
	print("  for body in bodies:")
	print("      print(body.name)")

	var overlapping_bodies = get_overlapping_bodies()
	print("  현재 겹친 body 수: %d" % overlapping_bodies.size())

	# get_overlapping_areas() - 현재 겹쳐있는 Area2D 목록
	print("\n[get_overlapping_areas()]")
	print("  현재 영역 내 다른 Area2D 목록을 반환")
	print("  var areas = get_overlapping_areas()")

	var overlapping_areas = get_overlapping_areas()
	print("  현재 겹친 area 수: %d" % overlapping_areas.size())

	# has_overlapping_bodies / has_overlapping_areas
	print("\n[bool 확인 메서드]")
	print("  has_overlapping_bodies(): %s" % str(has_overlapping_bodies()))
	print("  has_overlapping_areas(): %s" % str(has_overlapping_areas()))

	print()

# ============================================
# 8. 실전 활용 예시
# ============================================

func _practical_examples():
	print("--- 8. Area2D 실전 활용 패턴 ---")

	# 패턴 1: 감지 영역 (Detection Zone)
	print("[패턴 1] 적 감지 영역 (적이 플레이어를 발견)")
	print("""
  # enemy_detection_zone.gd
  extends Area2D

  var target: CharacterBody2D = null

  func _on_body_entered(body):
      if body.is_in_group("player"):
          target = body
          get_parent().start_chase(target)

  func _on_body_exited(body):
      if body == target:
          target = null
          get_parent().stop_chase()
	""")

	# 패턴 2: 데미지 영역
	print("[패턴 2] 데미지 영역 (용암, 가시 등)")
	print("""
  # damage_zone.gd
  extends Area2D

  @export var damage_per_second: float = 10.0
  var bodies_inside: Array[CharacterBody2D] = []

  func _on_body_entered(body):
      if body.has_method("take_damage"):
          bodies_inside.append(body)

  func _on_body_exited(body):
      bodies_inside.erase(body)

  func _physics_process(delta):
      for body in bodies_inside:
          if is_instance_valid(body):
              body.take_damage(damage_per_second * delta)
	""")

	# 패턴 3: 세이프 존 (회복 영역)
	print("[패턴 3] 회복 영역 (캠프파이어 근처)")
	print("""
  # healing_zone.gd
  extends Area2D

  @export var heal_rate: float = 5.0

  func _on_body_entered(body):
      if body.is_in_group("player"):
          body.start_healing(heal_rate)
          # 파티클 이펙트 활성화
          $HealParticles.emitting = true

  func _on_body_exited(body):
      if body.is_in_group("player"):
          body.stop_healing()
          $HealParticles.emitting = false
	""")

	# 패턴 4: 트리거 영역 (이벤트 발동)
	print("[패턴 4] 컷신 트리거")
	print("""
  # cutscene_trigger.gd
  extends Area2D

  @export var cutscene_id: String = "intro"
  var triggered: bool = false

  func _on_body_entered(body):
      if body.is_in_group("player") and not triggered:
          triggered = true
          CutsceneManager.play(cutscene_id)
          # 한 번만 실행하도록 비활성화
          monitoring = false
	""")

	print()

# ============================================
# 9. monitoring / monitorable 제어
# ============================================

func _monitoring_explanation():
	print("--- 9. monitoring / monitorable 속성 ---")

	print("[monitoring]")
	print("  true:  이 Area2D가 다른 객체의 진입/이탈을 감지")
	print("  false: 감지를 중단 (시그널이 발생하지 않음)")
	print("  용도: 일시적으로 감지를 끄고 싶을 때")
	print("  예: 아이템 수집 후, 컷신 트리거 후")

	print("\n[monitorable]")
	print("  true:  다른 Area2D가 이 Area2D를 감지할 수 있음")
	print("  false: 다른 Area2D에 의해 감지되지 않음")
	print("  용도: 특정 영역을 투명하게 만들고 싶을 때")

	print("\n[실전 예시: 쿨다운이 있는 데미지 영역]")
	print("""
  func deal_damage():
      # 데미지 처리...
      monitoring = false  # 감지 일시 해제 (쿨다운)
      await get_tree().create_timer(1.0).timeout
      monitoring = true   # 다시 감지 활성화
	""")

	print("\n[주의사항]")
	print("  - monitoring을 false로 바꾸면 현재 겹친 body에 대해")
	print("    body_exited 시그널이 발생합니다.")
	print("  - 다시 true로 바꾸면 여전히 겹쳐있는 body에 대해")
	print("    body_entered 시그널이 발생합니다.")
	print("  - _physics_process에서 매 프레임 overlap 체크하는 것보다")
	print("    시그널 기반이 훨씬 효율적입니다.")

	print("\n=== Area2D 감지 학습 완료 ===")
