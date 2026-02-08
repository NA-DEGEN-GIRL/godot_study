# Chapter 12 - Project Patterns
# 02-object-pool.gd - 오브젝트 풀링(Object Pooling) 패턴
#
# 이 파일에서 배울 내용:
# - 오브젝트 풀링의 개념과 필요성
# - 기본 오브젝트 풀 구현
# - 가져오기(get) / 반환(return) 패턴
# - 총알(Bullet) 풀 실전 예시
# - 풀 크기 동적 조절과 최적화

extends Node

func _ready():
	print("=== Chapter 12-2: 오브젝트 풀링(Object Pooling) ===\n")

	# -----------------------------------------------------------------
	# 1) 오브젝트 풀링이란?
	# -----------------------------------------------------------------
	print("--- 1. 오브젝트 풀링 개념 ---")

	print("  문제: 빈번한 instantiate() / queue_free()는 비용이 큼")
	print("    - 메모리 할당/해제 오버헤드")
	print("    - GC(가비지 컬렉션) 부담")
	print("    - 프레임 드랍 원인")
	print()

	print("  해결: 미리 생성해두고 재사용!")
	print("    1. 게임 시작 시 필요한 수만큼 미리 생성")
	print("    2. 필요할 때 풀에서 '가져오기' (활성화)")
	print("    3. 사용 끝나면 풀로 '반환' (비활성화)")
	print("    4. 절대 삭제하지 않음 (queue_free 금지)")
	print()

	print("  적합한 대상:")
	print("    - 총알, 미사일 등 발사체")
	print("    - 적 유닛 (웨이브 스포너)")
	print("    - 파티클 이펙트")
	print("    - 데미지 텍스트 팝업")
	print("    - 오디오 플레이어")
	print()

	# -----------------------------------------------------------------
	# 2) 기본 오브젝트 풀 구현
	# -----------------------------------------------------------------
	print("--- 2. 기본 오브젝트 풀 ---")

	var pool = SimpleObjectPool.new(10)
	print("  풀 생성: 초기 크기 = ", pool.pool_size())
	print("  사용 가능: ", pool.available_count())
	print("  사용 중: ", pool.active_count())
	print()

	# 오브젝트 가져오기
	print("  오브젝트 가져오기:")
	var objects: Array = []
	for i in range(5):
		var obj = pool.get_object()
		if obj:
			objects.append(obj)
			print("    가져옴: %s (사용 가능: %d)" % [obj.id, pool.available_count()])
	print()

	# 오브젝트 반환
	print("  오브젝트 반환:")
	for i in range(3):
		var obj = objects.pop_back()
		pool.return_object(obj)
		print("    반환: %s (사용 가능: %d)" % [obj.id, pool.available_count()])
	print()

	# 풀 고갈 테스트
	print("  풀 고갈 테스트:")
	var temp_objects: Array = []
	for i in range(15):  # 풀 크기 초과 시도
		var obj = pool.get_object()
		if obj:
			temp_objects.append(obj)
			print("    #%d 가져옴: %s" % [i, obj.id])
		else:
			print("    #%d 풀 고갈! (null 반환)" % i)
	print("  최종 - 사용 가능: %d, 사용 중: %d" % [
		pool.available_count(), pool.active_count()
	])
	print()

	# 모두 반환
	for obj in temp_objects:
		pool.return_object(obj)
	for obj in objects:
		pool.return_object(obj)
	print("  모두 반환 후 - 사용 가능: %d" % pool.available_count())
	print()

	# -----------------------------------------------------------------
	# 3) 자동 확장 풀
	# -----------------------------------------------------------------
	print("--- 3. 자동 확장 풀 ---")

	var auto_pool = AutoExpandPool.new(5)
	print("  초기 크기: ", auto_pool.pool_size())

	# 크기 초과 시 자동 확장
	var auto_objects: Array = []
	for i in range(8):
		var obj = auto_pool.get_object()
		auto_objects.append(obj)
		print("    #%d: %s (풀 크기: %d, 사용 가능: %d)" % [
			i, obj.id, auto_pool.pool_size(), auto_pool.available_count()
		])
	print()

	# 모두 반환
	for obj in auto_objects:
		auto_pool.return_object(obj)
	print("  모두 반환 후 풀 크기: %d (확장된 상태 유지)" % auto_pool.pool_size())
	print()

	# -----------------------------------------------------------------
	# 4) 총알 풀 시뮬레이션
	# -----------------------------------------------------------------
	print("--- 4. 총알 풀 시뮬레이션 ---")

	var bullet_pool = BulletPool.new(20)
	print("  총알 풀 초기화: %d발" % bullet_pool.pool_size())
	print()

	# 연사 시뮬레이션
	print("  [연사 시뮬레이션 - 0.1초 간격]")
	var active_bullets: Array = []

	for frame in range(10):
		# 총알 발사
		var bullet = bullet_pool.fire(
			Vector2(100, 300),           # 발사 위치
			Vector2(1, 0).normalized(),  # 방향 (오른쪽)
			500.0                        # 속도
		)
		if bullet:
			active_bullets.append(bullet)

		# 기존 총알 업데이트
		var to_remove: Array = []
		for b in active_bullets:
			b.position += b.velocity * 0.1  # 0.1초 경과
			b.lifetime -= 0.1
			if b.lifetime <= 0 or b.position.x > 1000:
				to_remove.append(b)

		# 만료된 총알 반환
		for b in to_remove:
			active_bullets.erase(b)
			bullet_pool.return_bullet(b)

		print("    프레임 %d: 활성 %d, 풀 여유 %d" % [
			frame, active_bullets.size(), bullet_pool.available_count()
		])
	print()

	# 모든 총알 반환
	for b in active_bullets:
		bullet_pool.return_bullet(b)
	print("  정리 후 풀 여유: %d/%d" % [
		bullet_pool.available_count(), bullet_pool.pool_size()
	])
	print()

	# -----------------------------------------------------------------
	# 5) Godot 노드 기반 오브젝트 풀
	# -----------------------------------------------------------------
	print("--- 5. Godot 노드 기반 풀 ---")

	print("  실제 Godot에서의 풀링 구현:")
	print()
	print("  # bullet_pool.gd")
	print("  extends Node")
	print()
	print("  @export var bullet_scene: PackedScene")
	print("  @export var pool_size: int = 50")
	print("  var _pool: Array[Node2D] = []")
	print("  var _active: Array[Node2D] = []")
	print()
	print("  func _ready():")
	print("      for i in range(pool_size):")
	print("          var bullet = bullet_scene.instantiate() as Node2D")
	print("          bullet.set_process(false)")
	print("          bullet.set_physics_process(false)")
	print("          bullet.visible = false")
	print("          add_child(bullet)")
	print("          _pool.append(bullet)")
	print()
	print("  func get_bullet() -> Node2D:")
	print("      if _pool.is_empty():")
	print("          # 자동 확장 또는 null 반환")
	print("          return _expand_and_get()")
	print("      var bullet = _pool.pop_back()")
	print("      bullet.set_process(true)")
	print("      bullet.set_physics_process(true)")
	print("      bullet.visible = true")
	print("      _active.append(bullet)")
	print("      return bullet")
	print()
	print("  func return_bullet(bullet: Node2D):")
	print("      bullet.set_process(false)")
	print("      bullet.set_physics_process(false)")
	print("      bullet.visible = false")
	print("      bullet.position = Vector2(-9999, -9999)")
	print("      _active.erase(bullet)")
	print("      _pool.append(bullet)")
	print()

	# -----------------------------------------------------------------
	# 6) 이펙트 풀 패턴
	# -----------------------------------------------------------------
	print("--- 6. 이펙트 풀 패턴 ---")

	print("  # 히트 이펙트 풀")
	print("  # 파티클 + 사운드 조합")
	print()
	print("  func spawn_hit_effect(pos: Vector2, type: String):")
	print("      var effect = effect_pool.get_effect(type)")
	print("      if effect:")
	print("          effect.global_position = pos")
	print("          effect.restart()  # 파티클 재시작")
	print("          # Timer로 자동 반환")
	print("          get_tree().create_timer(1.0).timeout.connect(")
	print("              func(): effect_pool.return_effect(effect)")
	print("          )")
	print()

	# 이펙트 풀 시뮬레이션
	var fx_pool = EffectPool.new(8)
	print("  이펙트 풀 크기: ", fx_pool.pool_size())

	# 빠르게 여러 이펙트 스폰
	var fx_list: Array = []
	for i in range(5):
		var fx = fx_pool.spawn(Vector2(randf_range(0, 800), randf_range(0, 600)))
		if fx:
			fx_list.append(fx)
	print("  5개 이펙트 스폰: 활성 %d, 풀 여유 %d" % [
		fx_pool.active_count(), fx_pool.available_count()
	])

	# 반환
	for fx in fx_list:
		fx_pool.despawn(fx)
	print("  모두 반환: 풀 여유 %d" % fx_pool.available_count())
	print()

	# -----------------------------------------------------------------
	# 7) 다중 타입 풀 매니저
	# -----------------------------------------------------------------
	print("--- 7. 다중 타입 풀 매니저 ---")

	var pool_manager = MultiPoolManager.new()
	pool_manager.register_pool("bullet", 30)
	pool_manager.register_pool("enemy", 10)
	pool_manager.register_pool("coin", 20)
	pool_manager.register_pool("explosion", 5)

	print("  등록된 풀:")
	pool_manager.print_status("    ")
	print()

	# 여러 타입에서 가져오기
	var bullet1 = pool_manager.get_from("bullet")
	var bullet2 = pool_manager.get_from("bullet")
	var enemy1 = pool_manager.get_from("enemy")
	var coin1 = pool_manager.get_from("coin")

	print("  가져오기 후:")
	pool_manager.print_status("    ")
	print()

	# 반환
	pool_manager.return_to("bullet", bullet1)
	pool_manager.return_to("enemy", enemy1)
	print("  반환 후:")
	pool_manager.print_status("    ")
	print()

	# -----------------------------------------------------------------
	# 8) 풀링 성능 비교
	# -----------------------------------------------------------------
	print("--- 8. 풀링 vs instantiate 성능 비교 ---")

	_benchmark_pooling()
	print()

	# -----------------------------------------------------------------
	# 9) 풀링 모범 사례
	# -----------------------------------------------------------------
	print("--- 9. 풀링 모범 사례 ---")

	print("  1. 풀 크기는 최대 동시 사용량 + 여유분")
	print("     - 총알: 화면 내 최대 수 기준")
	print("     - 적: 동시 스폰 최대 수 기준")
	print()
	print("  2. 반환 시 상태 초기화 필수")
	print("     func return_to_pool(obj):")
	print("         obj.reset()  # 모든 상태 초기화")
	print("         obj.visible = false")
	print("         obj.set_process(false)")
	print("         pool.append(obj)")
	print()
	print("  3. 자동 반환 메커니즘 구현")
	print("     - 화면 밖 감지")
	print("     - 수명 타이머")
	print("     - HP <= 0 시 자동 반환")
	print()
	print("  4. 풀링이 불필요한 경우")
	print("     - 드물게 생성되는 객체")
	print("     - 게임 내내 존재하는 객체")
	print("     - 복잡한 초기화가 필요한 객체")
	print()
	print("  5. 디버그 모드에서 풀 상태 모니터링")
	print("     - 최대 동시 사용량 추적")
	print("     - 풀 고갈 횟수 기록")
	print("     - 평균 사용률 통계")
	print()

	print("=== 02-object-pool.gd 완료 ===")


# =============================================================================
# 풀링 가능 오브젝트
# =============================================================================

class PoolableObject:
	var id: String
	var active: bool = false
	var position: Vector2 = Vector2.ZERO

	func _init(p_id: String = ""):
		id = p_id

	func activate():
		active = true

	func deactivate():
		active = false
		position = Vector2.ZERO

	func reset():
		position = Vector2.ZERO


# =============================================================================
# 간단한 오브젝트 풀
# =============================================================================

class SimpleObjectPool:
	var _available: Array = []
	var _active: Array = []
	var _next_id: int = 0

	func _init(initial_size: int):
		for i in range(initial_size):
			var obj = _create_object()
			_available.append(obj)

	func _create_object() -> PoolableObject:
		_next_id += 1
		return PoolableObject.new("obj_%d" % _next_id)

	func get_object() -> PoolableObject:
		if _available.is_empty():
			return null

		var obj = _available.pop_back()
		obj.activate()
		_active.append(obj)
		return obj

	func return_object(obj: PoolableObject):
		if obj in _active:
			_active.erase(obj)
		obj.deactivate()
		obj.reset()
		_available.append(obj)

	func pool_size() -> int:
		return _available.size() + _active.size()

	func available_count() -> int:
		return _available.size()

	func active_count() -> int:
		return _active.size()


# =============================================================================
# 자동 확장 풀
# =============================================================================

class AutoExpandPool extends SimpleObjectPool:
	var _expand_amount: int = 5

	func get_object() -> PoolableObject:
		if _available.is_empty():
			# 자동 확장
			for i in range(_expand_amount):
				var obj = _create_object()
				_available.append(obj)

		return super.get_object()


# =============================================================================
# 총알 풀
# =============================================================================

class BulletData:
	var id: String
	var active: bool = false
	var position: Vector2 = Vector2.ZERO
	var velocity: Vector2 = Vector2.ZERO
	var damage: float = 10.0
	var lifetime: float = 3.0
	var max_lifetime: float = 3.0

	func _init(p_id: String):
		id = p_id

	func reset():
		active = false
		position = Vector2.ZERO
		velocity = Vector2.ZERO
		damage = 10.0
		lifetime = max_lifetime


class BulletPool:
	var _available: Array[BulletData] = []
	var _active: Array[BulletData] = []
	var _next_id: int = 0

	func _init(size: int):
		for i in range(size):
			_next_id += 1
			var b = BulletData.new("bullet_%d" % _next_id)
			_available.append(b)

	func fire(pos: Vector2, direction: Vector2, speed: float) -> BulletData:
		if _available.is_empty():
			return null

		var bullet = _available.pop_back()
		bullet.active = true
		bullet.position = pos
		bullet.velocity = direction * speed
		bullet.lifetime = bullet.max_lifetime
		_active.append(bullet)
		return bullet

	func return_bullet(bullet: BulletData):
		if bullet in _active:
			_active.erase(bullet)
		bullet.reset()
		_available.append(bullet)

	func pool_size() -> int:
		return _available.size() + _active.size()

	func available_count() -> int:
		return _available.size()


# =============================================================================
# 이펙트 풀
# =============================================================================

class EffectData:
	var id: String
	var active: bool = false
	var position: Vector2 = Vector2.ZERO

	func _init(p_id: String):
		id = p_id


class EffectPool:
	var _available: Array = []
	var _active: Array = []

	func _init(size: int):
		for i in range(size):
			_available.append(EffectData.new("fx_%d" % (i + 1)))

	func spawn(pos: Vector2) -> EffectData:
		if _available.is_empty():
			return null
		var fx = _available.pop_back()
		fx.active = true
		fx.position = pos
		_active.append(fx)
		return fx

	func despawn(fx: EffectData):
		fx.active = false
		fx.position = Vector2.ZERO
		_active.erase(fx)
		_available.append(fx)

	func pool_size() -> int:
		return _available.size() + _active.size()

	func available_count() -> int:
		return _available.size()

	func active_count() -> int:
		return _active.size()


# =============================================================================
# 다중 타입 풀 매니저
# =============================================================================

class MultiPoolManager:
	var _pools: Dictionary = {}  # type_name -> SimpleObjectPool

	func register_pool(type_name: String, size: int):
		_pools[type_name] = SimpleObjectPool.new(size)

	func get_from(type_name: String) -> PoolableObject:
		if _pools.has(type_name):
			return _pools[type_name].get_object()
		return null

	func return_to(type_name: String, obj: PoolableObject):
		if _pools.has(type_name):
			_pools[type_name].return_object(obj)

	func print_status(indent: String = ""):
		for type_name in _pools:
			var p = _pools[type_name] as SimpleObjectPool
			print("%s%s: 활성 %d / 전체 %d (여유 %d)" % [
				indent, type_name, p.active_count(), p.pool_size(), p.available_count()
			])


# =============================================================================
# 성능 벤치마크
# =============================================================================

func _benchmark_pooling():
	var iterations = 1000

	# 방법 1: 매번 새로 생성
	var start_time = Time.get_ticks_usec()
	for i in range(iterations):
		var obj = PoolableObject.new("temp_%d" % i)
		obj.position = Vector2(100, 200)
		# 사용 후 버림 (GC에 맡김)
	var create_time = Time.get_ticks_usec() - start_time

	# 방법 2: 풀에서 가져오기/반환
	var pool = SimpleObjectPool.new(iterations)
	start_time = Time.get_ticks_usec()
	for i in range(iterations):
		var obj = pool.get_object()
		if obj:
			obj.position = Vector2(100, 200)
			pool.return_object(obj)
	var pool_time = Time.get_ticks_usec() - start_time

	print("  %d회 반복 벤치마크:" % iterations)
	print("    매번 생성:    %d us" % create_time)
	print("    풀 사용:      %d us" % pool_time)

	if create_time > 0 and pool_time > 0:
		var ratio = float(create_time) / float(pool_time)
		if ratio > 1.0:
			print("    풀이 %.1f배 빠름" % ratio)
		else:
			print("    생성이 %.1f배 빠름 (소규모에서는 풀 오버헤드)" % (1.0 / ratio))

	print("    참고: 실제 Node 인스턴스화는 차이가 훨씬 큼")
