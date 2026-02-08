# Chapter 12 - Project Patterns
# 05-optimization.gd - 성능 최적화 팁
#
# 이 파일에서 배울 내용:
# - 노드 참조 캐싱과 $접근 비용
# - 타입 지정(typed) 배열/변수의 성능 이점
# - 오브젝트 풀링 vs instantiate 벤치마크
# - _process vs _physics_process 최적화
# - 일반적인 성능 실수와 해결책

extends Node

# =============================================================================
# 벤치마크 설정
# =============================================================================

const ITERATIONS = 10000
const WARMUP_ITERATIONS = 1000  # 워밍업 반복

func _ready():
	print("=== Chapter 12-5: 성능 최적화 팁 ===\n")

	# 워밍업 (JIT 등의 영향 최소화)
	_warmup()

	# -----------------------------------------------------------------
	# 1) 변수 캐싱
	# -----------------------------------------------------------------
	print("--- 1. 노드 참조 캐싱 ---")

	print("  나쁜 패턴: 매 프레임마다 get_node() 호출")
	print("    func _process(delta):")
	print("        get_node(\"Sprite2D\").position.x += 1")
	print("        $Label.text = str(score)  # $도 매번 탐색!")
	print()

	print("  좋은 패턴: @onready로 캐싱")
	print("    @onready var sprite = $Sprite2D")
	print("    @onready var label = $Label")
	print("    func _process(delta):")
	print("        sprite.position.x += 1")
	print("        label.text = str(score)")
	print()

	# 벤치마크: get_node vs 캐싱
	var test_node = Node.new()
	test_node.name = "TestChild"
	add_child(test_node)

	# 매번 get_node
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _n = get_node("TestChild")
	var get_node_time = Time.get_ticks_usec() - start

	# 캐싱된 참조
	var cached = test_node
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _n = cached
	var cached_time = Time.get_ticks_usec() - start

	print("  벤치마크 (%d회):" % ITERATIONS)
	print("    get_node():  %d us" % get_node_time)
	print("    캐싱 참조:   %d us" % cached_time)
	if cached_time > 0:
		print("    캐싱이 약 %.1f배 빠름" % (float(get_node_time) / cached_time))
	print()

	test_node.queue_free()

	# -----------------------------------------------------------------
	# 2) 타입 지정의 성능 이점
	# -----------------------------------------------------------------
	print("--- 2. 타입 지정 (Typed Variables) ---")

	print("  타입 없는 변수 vs 타입 있는 변수:")
	print("    var x = 0        # Variant (동적 타입)")
	print("    var x: int = 0   # int (정적 타입)")
	print()

	# 벤치마크: 타입 없는 배열 vs 타입 있는 배열
	_benchmark_typed_vs_untyped_arrays()
	print()

	# 타입 있는 산술 연산
	_benchmark_typed_vs_untyped_arithmetic()
	print()

	# -----------------------------------------------------------------
	# 3) 배열/딕셔너리 최적화
	# -----------------------------------------------------------------
	print("--- 3. 배열/딕셔너리 최적화 ---")

	# PackedArray vs Array
	_benchmark_packed_vs_regular_array()
	print()

	# 딕셔너리 vs 배열 검색
	_benchmark_dict_vs_array_lookup()
	print()

	# -----------------------------------------------------------------
	# 4) 문자열 최적화
	# -----------------------------------------------------------------
	print("--- 4. 문자열 최적화 ---")

	# 문자열 연결 방법 비교
	_benchmark_string_concat()
	print()

	# -----------------------------------------------------------------
	# 5) 시그널 vs 직접 호출
	# -----------------------------------------------------------------
	print("--- 5. 시그널 vs 직접 호출 ---")

	_benchmark_signal_vs_direct_call()
	print()

	# -----------------------------------------------------------------
	# 6) 수학 최적화
	# -----------------------------------------------------------------
	print("--- 6. 수학 최적화 ---")

	# distance_to vs distance_squared_to
	print("  거리 비교 최적화:")
	print("    distance_to()         = sqrt(dx*dx + dy*dy)  <- sqrt 비용!")
	print("    distance_squared_to() = dx*dx + dy*dy        <- sqrt 생략!")
	print()
	print("    # 나쁜 예:")
	print("    if pos.distance_to(target) < 100:")
	print("    # 좋은 예:")
	print("    if pos.distance_squared_to(target) < 100 * 100:")
	print()

	_benchmark_distance_comparison()
	print()

	# -----------------------------------------------------------------
	# 7) _process 최적화
	# -----------------------------------------------------------------
	print("--- 7. _process 최적화 ---")

	print("  a) 필요 없을 때 비활성화:")
	print("    func _ready():")
	print("        set_process(false)  # _process 비활성화")
	print("    func start_moving():")
	print("        set_process(true)   # 필요할 때 활성화")
	print("    func _process(delta):")
	print("        if reached_target:")
	print("            set_process(false)  # 다시 비활성화")
	print()

	print("  b) 매 프레임이 아닌 주기적 처리:")
	print("    var _update_timer: float = 0.0")
	print("    const UPDATE_INTERVAL: float = 0.1  # 10FPS")
	print()
	print("    func _process(delta):")
	print("        _update_timer += delta")
	print("        if _update_timer >= UPDATE_INTERVAL:")
	print("            _update_timer = 0.0")
	print("            _do_expensive_update()  # 비싼 처리는 여기서만")
	print()

	print("  c) 화면 밖 노드 처리 중단:")
	print("    # VisibleOnScreenNotifier2D 사용")
	print("    func _on_screen_exited():")
	print("        set_process(false)")
	print("        set_physics_process(false)")
	print("    func _on_screen_entered():")
	print("        set_process(true)")
	print("        set_physics_process(true)")
	print()

	# -----------------------------------------------------------------
	# 8) 메모리 최적화
	# -----------------------------------------------------------------
	print("--- 8. 메모리 최적화 ---")

	print("  a) 리소스 공유:")
	print("    # 같은 리소스는 한 번만 로드하고 공유")
	print("    var shared_material = preload(\"res://mat.tres\")")
	print("    # 모든 적이 동일 material 참조 -> 메모리 절약")
	print()

	print("  b) 텍스처 최적화:")
	print("    - Power of 2 크기 (256, 512, 1024)")
	print("    - 텍스처 아틀라스 사용 (draw call 감소)")
	print("    - 불필요한 큰 텍스처 피하기")
	print("    - 프로젝트 설정에서 압축 모드 확인")
	print()

	print("  c) 노드 수 줄이기:")
	print("    - 빈 노드/불필요한 계층 제거")
	print("    - 단순 데이터는 Resource/Dictionary 사용")
	print("    - 많은 동일 객체는 MultiMeshInstance2D 사용")
	print()

	# Node 수 영향 벤치마크
	_benchmark_node_count()
	print()

	# -----------------------------------------------------------------
	# 9) 일반적인 성능 실수
	# -----------------------------------------------------------------
	print("--- 9. 일반적인 성능 실수 ---")

	print("  1. _process()에서 매 프레임 배열 생성")
	print("     나쁨: func _process(d): var arr = []  # 매 프레임 할당")
	print("     좋음: var arr = []  # 멤버 변수로 재사용")
	print()

	print("  2. 매 프레임 문자열 포맷팅")
	print("     나쁨: label.text = \"Score: \" + str(score)  # 매 프레임")
	print("     좋음: score 변경 시에만 업데이트 (시그널 활용)")
	print()

	print("  3. get_overlapping_areas() 남용")
	print("     나쁨: 매 프레임 겹침 확인")
	print("     좋음: area_entered/exited 시그널 사용")
	print()

	print("  4. 불필요한 print() 남기기")
	print("     나쁨: func _process(d): print(\"frame\")  # 60fps * 출력")
	print("     좋음: 릴리즈 빌드 전 디버그 출력 제거")
	print()

	print("  5. yield/await 남발")
	print("     나쁨: await get_tree().create_timer(0.0).timeout  # 불필요")
	print("     좋음: 필요한 경우에만 비동기 사용")
	print()

	print("  6. 재귀적 get_children() 호출")
	print("     나쁨: func _process(d): for c in get_children(): ...")
	print("     좋음: 자식 노드 참조 캐싱 또는 그룹 사용")
	print()

	# -----------------------------------------------------------------
	# 10) 프로파일링 도구
	# -----------------------------------------------------------------
	print("--- 10. 프로파일링 도구 ---")

	print("  Godot 내장 프로파일러:")
	print("    - 하단 패널 > Debugger > Profiler")
	print("    - 각 함수의 실행 시간 측정")
	print("    - 프레임별 CPU/GPU 사용량 확인")
	print()

	print("  모니터 (Performance):")
	print("    - 하단 패널 > Debugger > Monitors")
	print("    - FPS, 메모리, 노드 수, draw call 등")
	print()

	print("  코드에서 성능 측정:")
	print("    var start = Time.get_ticks_usec()")
	print("    # 측정할 코드")
	print("    var elapsed = Time.get_ticks_usec() - start")
	print("    print(\"소요 시간: %d us\" % elapsed)")
	print()

	print("  Performance 싱글톤:")
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	var memory = Performance.get_monitor(Performance.MEMORY_STATIC)

	print("    FPS: %.0f" % fps)
	print("    Object 수: %.0f" % objects)
	print("    Node 수: %.0f" % nodes)
	print("    고아 노드: %.0f" % orphans)
	print("    정적 메모리: %.2f MB" % (memory / 1048576.0))
	print()

	# -----------------------------------------------------------------
	# 11) 최적화 체크리스트
	# -----------------------------------------------------------------
	print("--- 11. 최적화 체크리스트 ---")

	print("  [코드 레벨]")
	print("    [ ] 노드 참조 캐싱 (@onready)")
	print("    [ ] 타입 지정 변수/배열 사용")
	print("    [ ] _process에서 불필요한 할당 제거")
	print("    [ ] distance_squared_to 사용 (거리 비교)")
	print("    [ ] 화면 밖 객체 비활성화")
	print("    [ ] 오브젝트 풀링 (빈번한 생성/삭제)")
	print()
	print("  [렌더링 레벨]")
	print("    [ ] 텍스처 아틀라스 사용")
	print("    [ ] CanvasGroup으로 draw call 줄이기")
	print("    [ ] 불필요한 노드 숨기기 (visible = false)")
	print("    [ ] 카메라 밖 컬링 확인")
	print("    [ ] Light2D 사용 최소화")
	print()
	print("  [물리 레벨]")
	print("    [ ] 물리 레이어/마스크 최소화")
	print("    [ ] 간단한 충돌 형태 사용 (원 > 사각형 > 다각형)")
	print("    [ ] RayCast로 대체 가능한 곳은 Area2D 대신 사용")
	print("    [ ] 정적 객체는 StaticBody2D 사용")
	print()
	print("  [프로젝트 레벨]")
	print("    [ ] 디버그 print() 제거")
	print("    [ ] 릴리즈 빌드 사용")
	print("    [ ] 에셋 압축 확인")
	print("    [ ] 불필요한 플러그인 비활성화")
	print()

	print("=== 05-optimization.gd 완료 ===")


# =============================================================================
# 벤치마크 함수들
# =============================================================================

func _warmup():
	# JIT 워밍업
	var _x = 0
	for i in range(WARMUP_ITERATIONS):
		_x += i


# 타입 지정 배열 벤치마크
func _benchmark_typed_vs_untyped_arrays():
	print("  배열 타입 지정 벤치마크 (%d 요소):" % ITERATIONS)

	# 타입 없는 배열
	var untyped_arr = []
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		untyped_arr.append(i)
	var untyped_time = Time.get_ticks_usec() - start

	# 타입 있는 배열
	var typed_arr: Array[int] = []
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		typed_arr.append(i)
	var typed_time = Time.get_ticks_usec() - start

	# PackedInt32Array
	var packed_arr = PackedInt32Array()
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		packed_arr.append(i)
	var packed_time = Time.get_ticks_usec() - start

	print("    Array (untyped):     %d us" % untyped_time)
	print("    Array[int] (typed):  %d us" % typed_time)
	print("    PackedInt32Array:    %d us" % packed_time)

	# 합산 벤치마크
	var _sum: int = 0

	start = Time.get_ticks_usec()
	for val in untyped_arr:
		_sum += val
	var sum_untyped = Time.get_ticks_usec() - start

	_sum = 0
	start = Time.get_ticks_usec()
	for val in typed_arr:
		_sum += val
	var sum_typed = Time.get_ticks_usec() - start

	_sum = 0
	start = Time.get_ticks_usec()
	for val in packed_arr:
		_sum += val
	var sum_packed = Time.get_ticks_usec() - start

	print("    합산 - untyped: %d us, typed: %d us, packed: %d us" % [
		sum_untyped, sum_typed, sum_packed
	])


# 타입 지정 산술 연산
func _benchmark_typed_vs_untyped_arithmetic():
	print("  산술 연산 타입 지정 벤치마크 (%d회):" % ITERATIONS)

	# 타입 없는 변수
	var start = Time.get_ticks_usec()
	var a = 0
	var b = 1
	for i in range(ITERATIONS):
		a = a + b * 2 - 1
		b = b + 1
	var untyped_time = Time.get_ticks_usec() - start

	# 타입 있는 변수
	start = Time.get_ticks_usec()
	var a2: int = 0
	var b2: int = 1
	for i in range(ITERATIONS):
		a2 = a2 + b2 * 2 - 1
		b2 = b2 + 1
	var typed_time = Time.get_ticks_usec() - start

	print("    Variant (untyped): %d us" % untyped_time)
	print("    int (typed):       %d us" % typed_time)


# PackedArray vs Array
func _benchmark_packed_vs_regular_array():
	print("  PackedVector2Array vs Array[Vector2] (%d 요소):" % ITERATIONS)

	# Array[Vector2]
	var regular: Array[Vector2] = []
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		regular.append(Vector2(i, i * 2))
	var regular_time = Time.get_ticks_usec() - start

	# PackedVector2Array
	var packed = PackedVector2Array()
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		packed.append(Vector2(i, i * 2))
	var packed_time = Time.get_ticks_usec() - start

	print("    Array[Vector2]:     %d us" % regular_time)
	print("    PackedVector2Array: %d us" % packed_time)

	# 메모리 비교 (대략적)
	print("    참고: PackedArray는 연속 메모리, Array는 Variant 배열")
	print("    PackedVector2Array는 Vector2당 8바이트 (연속)")
	print("    Array[Vector2]는 Vector2당 ~20바이트+ (Variant 오버헤드)")


# 딕셔너리 vs 배열 검색
func _benchmark_dict_vs_array_lookup():
	var size = 1000
	print("  Dictionary vs Array 검색 (%d개 항목에서 조회):" % size)

	# 준비
	var arr: Array = []
	var dict: Dictionary = {}
	for i in range(size):
		var key = "item_%d" % i
		arr.append(key)
		dict[key] = i

	# 배열 검색 (in 연산자)
	var search_key = "item_%d" % (size - 1)  # 최악의 경우
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _found = search_key in arr
	var arr_time = Time.get_ticks_usec() - start

	# 딕셔너리 검색 (has)
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _found = dict.has(search_key)
	var dict_time = Time.get_ticks_usec() - start

	print("    Array 'in' 검색:       %d us" % arr_time)
	print("    Dictionary 'has' 검색: %d us" % dict_time)
	if dict_time > 0:
		print("    Dictionary가 약 %.1f배 빠름" % (float(arr_time) / dict_time))


# 문자열 연결 벤치마크
func _benchmark_string_concat():
	print("  문자열 연결 방법 비교 (%d회):" % ITERATIONS)

	# + 연결
	var start = Time.get_ticks_usec()
	var result = ""
	for i in range(1000):  # 1000회로 제한 (문자열이 너무 길어짐)
		result = result + "a"
	var concat_time = Time.get_ticks_usec() - start

	# 포맷 문자열
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _s = "Score: %d, HP: %d/%d" % [1000, 75, 100]
	var format_time = Time.get_ticks_usec() - start

	# str() 변환
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _s = "Score: " + str(1000) + ", HP: " + str(75) + "/" + str(100)
	var str_time = Time.get_ticks_usec() - start

	print("    + 반복 연결 (1000회): %d us (O(n^2) 주의!)" % concat_time)
	print("    %% 포맷 문자열:       %d us" % format_time)
	print("    str() + 연결:         %d us" % str_time)
	print("    -> 포맷 문자열(%%)이 가독성도 좋고 효율적")


# 시그널 vs 직접 호출
func _benchmark_signal_vs_direct_call():
	print("  시그널 vs 직접 호출 비교 (%d회):" % ITERATIONS)

	var receiver = SignalReceiver.new()

	# 직접 호출
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		receiver.on_event(42)
	var direct_time = Time.get_ticks_usec() - start

	# Callable 호출
	var callable = receiver.on_event
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		callable.call(42)
	var callable_time = Time.get_ticks_usec() - start

	print("    직접 호출:    %d us" % direct_time)
	print("    Callable:     %d us" % callable_time)
	print("    참고: 시그널은 Callable + 약간의 오버헤드")
	print("    실제 게임에서 시그널 오버헤드는 무시 가능 수준")


# 거리 비교 벤치마크
func _benchmark_distance_comparison():
	print("  거리 계산 벤치마크 (%d회):" % ITERATIONS)

	var pos_a = Vector2(100, 200)
	var pos_b = Vector2(500, 600)
	var threshold = 300.0
	var threshold_sq = threshold * threshold

	# distance_to (sqrt 포함)
	var start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _close = pos_a.distance_to(pos_b) < threshold
	var dist_time = Time.get_ticks_usec() - start

	# distance_squared_to (sqrt 없음)
	start = Time.get_ticks_usec()
	for i in range(ITERATIONS):
		var _close = pos_a.distance_squared_to(pos_b) < threshold_sq
	var dist_sq_time = Time.get_ticks_usec() - start

	print("    distance_to():         %d us" % dist_time)
	print("    distance_squared_to(): %d us" % dist_sq_time)
	if dist_sq_time > 0:
		print("    squared가 약 %.1f배 빠름" % (float(dist_time) / dist_sq_time))


# 노드 수 벤치마크
func _benchmark_node_count():
	print("  노드 생성/삭제 벤치마크:")

	var counts = [100, 500, 1000]

	for count in counts:
		# 생성
		var nodes: Array[Node] = []
		var start = Time.get_ticks_usec()
		for i in range(count):
			var n = Node.new()
			add_child(n)
			nodes.append(n)
		var create_time = Time.get_ticks_usec() - start

		# 삭제
		start = Time.get_ticks_usec()
		for n in nodes:
			n.queue_free()
		var delete_time = Time.get_ticks_usec() - start

		print("    %4d 노드: 생성 %d us, 삭제 %d us" % [count, create_time, delete_time])


# =============================================================================
# 벤치마크 헬퍼 클래스
# =============================================================================

class SignalReceiver:
	var _count: int = 0

	func on_event(value: int):
		_count += value
