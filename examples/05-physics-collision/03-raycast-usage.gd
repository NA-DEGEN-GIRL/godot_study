# Chapter 05 - Physics & Collision
# 03-raycast-usage.gd - RayCast2D와 레이캐스트 사용법
#
# 이 파일에서 배울 내용:
# - RayCast2D 노드 설정과 사용법
# - force_raycast_update()로 즉시 충돌 확인
# - get_collider(), get_collision_point(), get_collision_normal()
# - PhysicsDirectSpaceState2D를 활용한 코드 레이캐스트
# - 실전 활용: 바닥 감지, 시선 감지, 벽 감지
#
# 레이캐스트는 보이지 않는 선(ray)을 쏘아 충돌을 감지합니다.
# 총알 궤적, 시야 확인, 지형 감지 등에 널리 사용됩니다.

extends CharacterBody2D

# ============================================
# 1. RayCast2D 노드 참조
# ============================================
# 씬 구조:
#   CharacterBody2D (이 스크립트)
#     +-- CollisionShape2D
#     +-- RayCast2D (아래 방향 - 바닥 감지)
#     +-- RayCast2D (전방 - 벽/적 감지)
#     +-- RayCast2D (시선 - 시야 확인)

# 실제 씬에서는 @onready로 참조합니다
# @onready var floor_ray: RayCast2D = $FloorRay
# @onready var wall_ray: RayCast2D = $WallRay
# @onready var sight_ray: RayCast2D = $SightRay

var floor_ray: RayCast2D
var wall_ray: RayCast2D
var sight_ray: RayCast2D

func _ready():
	print("=== Chapter 05-3: RayCast2D 사용법 ===\n")

	_setup_raycasts()
	_explain_raycast_properties()
	_explain_raycast_methods()
	_show_code_raycast()
	_practical_floor_detection()
	_practical_wall_detection()
	_practical_line_of_sight()
	_practical_weapon_raycast()
	_tips_and_tricks()

# ============================================
# 2. RayCast2D 코드로 생성 및 설정
# ============================================

func _setup_raycasts():
	print("--- 2. RayCast2D 생성 및 설정 ---")

	# 바닥 감지 레이캐스트
	floor_ray = RayCast2D.new()
	floor_ray.name = "FloorRay"
	floor_ray.target_position = Vector2(0, 30)     # 아래로 30픽셀
	floor_ray.enabled = true                         # 활성화
	floor_ray.collision_mask = 1                     # 지형 레이어만 감지
	floor_ray.collide_with_areas = false             # Area2D 무시
	floor_ray.collide_with_bodies = true             # PhysicsBody 감지
	floor_ray.hit_from_inside = false                # 내부에서의 충돌 무시
	add_child(floor_ray)
	print("FloorRay 생성: 아래로 30px, 지형(레이어1) 감지")

	# 벽 감지 레이캐스트
	wall_ray = RayCast2D.new()
	wall_ray.name = "WallRay"
	wall_ray.target_position = Vector2(40, 0)       # 오른쪽으로 40픽셀
	wall_ray.enabled = true
	wall_ray.collision_mask = 1                      # 지형 레이어만
	add_child(wall_ray)
	print("WallRay 생성: 오른쪽으로 40px, 지형(레이어1) 감지")

	# 시선 감지 레이캐스트
	sight_ray = RayCast2D.new()
	sight_ray.name = "SightRay"
	sight_ray.target_position = Vector2(200, 0)     # 전방 200픽셀
	sight_ray.enabled = true
	sight_ray.collision_mask = 1 | 2                 # 지형 + 플레이어
	sight_ray.collide_with_areas = true              # Area2D도 감지
	add_child(sight_ray)
	print("SightRay 생성: 전방 200px, 지형+플레이어 감지")

	print()

# ============================================
# 3. RayCast2D 주요 속성
# ============================================

func _explain_raycast_properties():
	print("--- 3. RayCast2D 주요 속성 ---")

	print("[target_position: Vector2]")
	print("  레이의 끝 지점 (로컬 좌표)")
	print("  Vector2(0, 50) = 아래로 50px")
	print("  Vector2(100, 0) = 오른쪽으로 100px")
	print("  Vector2(-100, -50) = 왼쪽 위 대각선")

	print("\n[enabled: bool]")
	print("  true: 매 물리 프레임마다 자동으로 충돌 체크")
	print("  false: 비활성화 (force_raycast_update()로만 체크 가능)")

	print("\n[collision_mask: int]")
	print("  감지할 충돌 레이어 (비트마스크)")
	print("  레이는 layer가 없고 mask만 있음 (감지만 하니까)")

	print("\n[collide_with_areas: bool]")
	print("  Area2D와의 충돌 감지 여부")

	print("\n[collide_with_bodies: bool]")
	print("  PhysicsBody2D와의 충돌 감지 여부")

	print("\n[hit_from_inside: bool]")
	print("  레이 시작점이 콜라이더 내부에 있을 때 충돌 감지 여부")

	print("\n[exclude_parent: bool]")
	print("  부모 노드를 충돌 대상에서 제외 (기본: true)")

	print()

# ============================================
# 4. RayCast2D 주요 메서드
# ============================================

func _explain_raycast_methods():
	print("--- 4. RayCast2D 주요 메서드 ---")

	# force_raycast_update() - 즉시 충돌 체크
	print("[force_raycast_update()]")
	print("  다음 물리 프레임을 기다리지 않고 즉시 충돌 체크")
	print("  _ready()에서 바로 결과를 확인하고 싶을 때 필수!")

	floor_ray.force_raycast_update()

	# is_colliding() - 충돌 여부
	print("\n[is_colliding() -> bool]")
	print("  레이가 무언가와 충돌했는지 여부")
	print("  FloorRay 충돌 여부: %s" % str(floor_ray.is_colliding()))

	# get_collider() - 충돌한 객체
	print("\n[get_collider() -> Object]")
	print("  충돌한 객체 반환 (없으면 null)")
	var collider = floor_ray.get_collider()
	if collider:
		print("  충돌 객체: %s" % collider.name)
	else:
		print("  충돌 객체: null (충돌 없음)")

	# get_collision_point() - 충돌 지점
	print("\n[get_collision_point() -> Vector2]")
	print("  충돌이 발생한 글로벌 좌표")
	if floor_ray.is_colliding():
		print("  충돌 지점: %s" % str(floor_ray.get_collision_point()))
	else:
		print("  충돌 없음 - Vector2(0,0) 반환")

	# get_collision_normal() - 충돌면의 법선 벡터
	print("\n[get_collision_normal() -> Vector2]")
	print("  충돌 표면의 법선(수직) 벡터")
	print("  평평한 바닥: Vector2(0, -1) (위쪽)")
	print("  오른쪽 벽: Vector2(-1, 0) (왼쪽)")
	print("  경사면: 법선이 기울어진 벡터")
	if floor_ray.is_colliding():
		print("  현재 법선: %s" % str(floor_ray.get_collision_normal()))

	# get_collider_rid() - 충돌체의 RID
	print("\n[get_collider_rid() -> RID]")
	print("  충돌한 물리 객체의 Resource ID")

	# get_collider_shape() - 충돌한 Shape의 인덱스
	print("\n[get_collider_shape() -> int]")
	print("  충돌한 CollisionShape의 인덱스 번호")

	# add_exception / remove_exception
	print("\n[add_exception(object) / remove_exception(object)]")
	print("  특정 객체를 레이캐스트 감지에서 제외/포함")
	print("  예: 자기 자신이나 아군을 제외하고 싶을 때")
	print("  floor_ray.add_exception(self)  # 자기 자신 제외")

	# clear_exceptions
	print("\n[clear_exceptions()]")
	print("  모든 예외 목록 초기화")

	print()

# ============================================
# 5. 코드로 직접 레이캐스트 (PhysicsDirectSpaceState2D)
# ============================================

func _show_code_raycast():
	print("--- 5. 코드 레이캐스트 (PhysicsDirectSpaceState2D) ---")

	print("[RayCast2D 노드 없이 코드로 직접 레이캐스트]")
	print("  노드를 만들지 않고 한 번만 체크하고 싶을 때 유용")
	print("")

	# PhysicsDirectSpaceState2D 사용법
	print("  # 물리 공간 상태 가져오기")
	print("  var space_state = get_world_2d().direct_space_state")
	print("")
	print("  # 쿼리 파라미터 설정")
	print("  var query = PhysicsRayQueryParameters2D.create(")
	print("      Vector2(100, 100),   # 시작점 (from)")
	print("      Vector2(100, 500),   # 끝점 (to)")
	print("      1,                   # collision_mask")
	print("      [self.get_rid()]     # 제외할 객체 RID 배열")
	print("  )")
	print("")
	print("  # 레이캐스트 실행")
	print("  var result = space_state.intersect_ray(query)")
	print("")

	# 결과 딕셔너리 설명
	print("[결과 Dictionary 구조]")
	print("  result가 비어있으면 충돌 없음")
	print("  result = {")
	print("      'position': Vector2,   # 충돌 지점")
	print("      'normal': Vector2,     # 충돌면 법선")
	print("      'collider': Object,    # 충돌한 객체")
	print("      'collider_id': int,    # 객체의 인스턴스 ID")
	print("      'rid': RID,            # 물리 객체 RID")
	print("      'shape': int           # Shape 인덱스")
	print("  }")

	# 실제 코드 (물리 프레임에서 실행해야 함)
	# _physics_process에서 사용하는 것이 안전합니다
	print("\n[주의사항]")
	print("  - intersect_ray()는 _physics_process()에서 호출하는 것이 안전")
	print("  - _ready()에서도 가능하지만 물리 공간이 아직 초기화 안 됐을 수 있음")
	print("  - RayCast2D 노드: 지속적 감지에 적합")
	print("  - 코드 레이캐스트: 일회성 체크에 적합")

	print()

# ============================================
# 6. 실전: 바닥 감지 (Floor Detection)
# ============================================

func _practical_floor_detection():
	print("--- 6. 실전: 바닥/절벽 감지 ---")

	print("[바닥 감지 - 점프 가능 여부 확인]")
	print("""
  # 캐릭터 아래로 레이 발사
  @onready var floor_ray: RayCast2D = $FloorRay
  # target_position = Vector2(0, 20)  # 아래로 20px

  func _physics_process(delta):
      var is_grounded = floor_ray.is_colliding()

      if is_grounded:
          # 바닥 위에 있음 - 점프 가능
          if Input.is_action_just_pressed("jump"):
              velocity.y = JUMP_FORCE
      else:
          # 공중 - 중력 적용
          velocity.y += GRAVITY * delta
	""")

	print("[절벽 감지 - 적 AI가 절벽에서 방향 전환]")
	print("""
  # 적의 발 앞쪽에 아래로 향하는 레이
  @onready var cliff_ray: RayCast2D = $CliffDetector
  # 위치: 캐릭터 앞쪽 아래로
  # target_position = Vector2(0, 30)

  func _physics_process(delta):
      if not cliff_ray.is_colliding():
          # 앞에 바닥이 없음 = 절벽!
          direction *= -1  # 방향 전환
          cliff_ray.target_position.x *= -1  # 레이도 반전
	""")

	print("[경사면 감지 - 법선 벡터 활용]")
	print("""
  func get_floor_angle() -> float:
      if floor_ray.is_colliding():
          var normal = floor_ray.get_collision_normal()
          # Vector2.UP과의 각도 = 경사각
          var angle = normal.angle_to(Vector2.UP)
          return rad_to_deg(angle)
      return 0.0

  func _physics_process(delta):
      var slope_angle = get_floor_angle()
      if slope_angle > 45.0:
          # 너무 가파른 경사 - 미끄러짐
          velocity += Vector2.DOWN * SLIDE_SPEED * delta
	""")

	print()

# ============================================
# 7. 실전: 벽 감지 (Wall Detection)
# ============================================

func _practical_wall_detection():
	print("--- 7. 실전: 벽 감지 ---")

	print("[벽 점프 감지]")
	print("""
  @onready var left_wall_ray: RayCast2D = $LeftWallRay
  @onready var right_wall_ray: RayCast2D = $RightWallRay
  # target_position: Vector2(-20, 0) / Vector2(20, 0)

  var is_on_wall: bool = false
  var wall_normal: Vector2 = Vector2.ZERO

  func _physics_process(delta):
      if left_wall_ray.is_colliding():
          is_on_wall = true
          wall_normal = left_wall_ray.get_collision_normal()
      elif right_wall_ray.is_colliding():
          is_on_wall = true
          wall_normal = right_wall_ray.get_collision_normal()
      else:
          is_on_wall = false

      # 벽 슬라이드 (벽에 붙어서 천천히 내려감)
      if is_on_wall and velocity.y > 0:
          velocity.y *= 0.8  # 낙하 속도 감소

      # 벽 점프
      if is_on_wall and Input.is_action_just_pressed("jump"):
          velocity = wall_normal * WALL_JUMP_H_FORCE
          velocity.y = WALL_JUMP_V_FORCE
	""")

	print("[벽까지의 거리 측정]")
	print("""
  func get_wall_distance() -> float:
      if wall_ray.is_colliding():
          var hit_point = wall_ray.get_collision_point()
          return global_position.distance_to(hit_point)
      return INF  # 벽 없음
	""")

	print()

# ============================================
# 8. 실전: 시선 감지 (Line of Sight)
# ============================================

func _practical_line_of_sight():
	print("--- 8. 실전: 시선/시야 감지 ---")

	print("[적 AI - 플레이어 시야 확인]")
	print("""
  @onready var sight_ray: RayCast2D = $SightRay
  var target_player: CharacterBody2D = null
  var can_see_player: bool = false

  func _physics_process(delta):
      if target_player == null:
          return

      # 레이를 플레이어 방향으로 설정
      var direction = target_player.global_position - global_position
      sight_ray.target_position = direction
      sight_ray.force_raycast_update()

      if sight_ray.is_colliding():
          var collider = sight_ray.get_collider()
          if collider == target_player:
              # 플레이어를 직접 볼 수 있음 (장애물 없음)
              can_see_player = true
              start_attack()
          else:
              # 벽 등의 장애물에 가려짐
              can_see_player = false
              lose_target()
	""")

	print("[부채꼴 시야 (여러 레이 활용)]")
	print("""
  # 여러 레이를 부채꼴로 펼쳐서 넓은 시야 구현
  var sight_rays: Array[RayCast2D] = []
  var fov_angle: float = 90.0  # 시야각
  var ray_count: int = 5       # 레이 개수

  func _ready():
      for i in range(ray_count):
          var ray = RayCast2D.new()
          var angle_offset = -fov_angle/2 + (fov_angle / (ray_count-1)) * i
          var direction = Vector2.RIGHT.rotated(deg_to_rad(angle_offset))
          ray.target_position = direction * 200  # 감지 거리
          ray.collision_mask = 2  # 플레이어 레이어
          add_child(ray)
          sight_rays.append(ray)

  func check_sight() -> bool:
      for ray in sight_rays:
          ray.force_raycast_update()
          if ray.is_colliding():
              var collider = ray.get_collider()
              if collider.is_in_group("player"):
                  return true
      return false
	""")

	print()

# ============================================
# 9. 실전: 무기 레이캐스트 (히트스캔)
# ============================================

func _practical_weapon_raycast():
	print("--- 9. 실전: 히트스캔 무기 ---")

	print("[즉발 총알 (히트스캔)]")
	print("""
  func shoot():
      var space_state = get_world_2d().direct_space_state

      # 총구 위치에서 조준 방향으로 레이 발사
      var from = $Muzzle.global_position
      var to = from + get_aim_direction() * WEAPON_RANGE

      var query = PhysicsRayQueryParameters2D.create(from, to)
      query.collision_mask = 0b00000101  # 지형(1) + 적(3)
      query.exclude = [self.get_rid()]   # 자신 제외

      var result = space_state.intersect_ray(query)

      if result:
          # 총알 궤적 표시 (시각적 효과)
          draw_bullet_trail(from, result.position)

          # 충돌 이펙트
          spawn_hit_effect(result.position, result.normal)

          # 데미지 처리
          var target = result.collider
          if target.has_method("take_damage"):
              target.take_damage(WEAPON_DAMAGE)

              # 헤드샷 확인 (충돌 위치 기반)
              if is_headshot(target, result.position):
                  target.take_damage(WEAPON_DAMAGE * 2)  # 추가 데미지
      else:
          # 빗나감 - 최대 사거리까지 궤적 표시
          draw_bullet_trail(from, to)
	""")

	print("[탄도 추적 총알 (여러 레이 연속)]")
	print("""
  # 관통 총알: 여러 적을 관통
  func shoot_penetrating():
      var from = $Muzzle.global_position
      var direction = get_aim_direction()
      var remaining_range = WEAPON_RANGE
      var excluded: Array[RID] = [self.get_rid()]
      var hit_count = 0

      while remaining_range > 0 and hit_count < MAX_PENETRATION:
          var to = from + direction * remaining_range
          var query = PhysicsRayQueryParameters2D.create(from, to)
          query.collision_mask = 0b00000101
          query.exclude = excluded

          var result = space_state.intersect_ray(query)
          if not result:
              break

          # 히트 처리
          var target = result.collider
          if target.has_method("take_damage"):
              target.take_damage(WEAPON_DAMAGE)
              hit_count += 1

          # 다음 레이: 충돌 지점에서 약간 앞으로
          excluded.append(result.rid)
          remaining_range -= from.distance_to(result.position)
          from = result.position + direction * 2  # 약간 앞으로
	""")

	print()

# ============================================
# 10. 팁과 주의사항
# ============================================

func _tips_and_tricks():
	print("--- 10. 레이캐스트 팁과 주의사항 ---")

	print("[성능 팁]")
	print("  - RayCast2D 노드는 enabled=true면 매 물리 프레임 자동 체크")
	print("  - 필요없을 때는 enabled=false로 끄세요")
	print("  - 코드 레이캐스트는 필요할 때만 호출 (일회성)")
	print("  - 많은 레이가 필요하면 ShapeCast2D도 고려하세요")

	print("\n[디버깅 팁]")
	print("  - Debug > Visible Collision Shapes 켜면 레이 시각화")
	print("  - RayCast2D의 debug 색상 커스터마이즈 가능:")
	print("    debug_shape_custom_color = Color.RED")
	print("  - 콘솔에 충돌 결과 출력하며 디버깅:")
	print("    if ray.is_colliding():")
	print("        print(ray.get_collider().name)")

	print("\n[흔한 실수]")
	print("  1. _ready()에서 force_raycast_update() 안 하고 결과 확인")
	print("     -> 첫 물리 프레임 전이라 항상 false 반환")
	print("  2. collision_mask 설정 안 함")
	print("     -> 기본값 1이라 레이어 1만 감지")
	print("  3. exclude_parent 모르고 부모와 충돌 안 됨")
	print("     -> 기본 true, 부모 감지하려면 false로 변경")
	print("  4. collide_with_areas 안 켜고 Area2D 감지 시도")
	print("     -> 기본 false, Area2D 감지하려면 true 필요")

	print("\n[ShapeCast2D 대안]")
	print("  레이(선)가 아닌 도형(Shape)을 이동시키며 충돌 감지")
	print("  용도: 넓은 범위 감지, 캐릭터 크기의 공간 확인")
	print("  예: 벽 너머 플레이어가 들어갈 공간이 있는지 확인")

	print("\n=== RayCast2D 학습 완료 ===")
