# Chapter 20 - 3D Effects & Optimization
# 04-performance-3d.gd - MultiMesh, draw call 최적화, 프로파일링
#
# 이 파일에서 배울 내용:
# - Draw Call 개념과 최적화
# - MultiMesh를 이용한 인스턴싱
# - 배칭(Batching)과 메시 병합
# - 셰이더/재질 최적화
# - 물리/스크립트 최적화
# - 프로파일링 도구 활용

extends Node3D

const BENCHMARK_ITERATIONS := 5000

func _ready():
	print("=== Chapter 20-4: 3D Performance Optimization ===\n")

	# -----------------------------------------------------------------
	# 1) Draw Call 이해
	# -----------------------------------------------------------------
	print("--- 1. Draw Call 이해 ---")

	print("  Draw Call: CPU가 GPU에 '이것을 그려라'라고 명령하는 횟수")
	print()
	print("  Draw Call 발생 조건 (각각 별도 draw call):")
	print("    - 다른 메시")
	print("    - 다른 재질 (Material)")
	print("    - 다른 셰이더")
	print("    - 다른 텍스처")
	print("    - 다른 렌더링 상태 (blend mode 등)")
	print()
	print("  같은 재질 + 같은 메시 = 1 draw call (인스턴싱)")
	print("  다른 재질 + 같은 메시 = 2 draw calls")
	print()
	print("  일반적인 Draw Call 예산:")
	print("    PC: ~1000-3000 draw calls")
	print("    모바일: ~100-500 draw calls")
	print("    콘솔: ~2000-5000 draw calls")
	print()

	# 현재 Draw Call 확인
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var total_objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	print("  현재 상태:")
	print("    Draw Calls: %.0f" % draw_calls)
	print("    렌더링 오브젝트: %.0f" % total_objects)
	print()

	# -----------------------------------------------------------------
	# 2) Draw Call 최적화: MultiMesh 인스턴싱
	# -----------------------------------------------------------------
	print("--- 2. MultiMesh 인스턴싱 ---")

	# 방법 1: 개별 MeshInstance3D (나쁜 예)
	var individual_time := _benchmark_individual_meshes(100)

	# 방법 2: MultiMesh (좋은 예)
	var multimesh_time := _benchmark_multimesh(100)

	print("  100개 오브젝트 생성 시간:")
	print("    개별 MeshInstance3D: %d us" % individual_time)
	print("    MultiMesh:          %d us" % multimesh_time)
	print()

	print("  렌더링 비교 (개념적):")
	print("    개별 1000개 = ~1000 draw calls")
	print("    MultiMesh 1000개 = 1 draw call")
	print()

	# 대규모 MultiMesh 데모 (풀밭)
	_create_grass_field(Vector3(0, 0, 10), 2000)
	print("  풀밭 데모: MultiMesh 2000 인스턴스 생성")
	print()

	# -----------------------------------------------------------------
	# 3) 재질 통합 (Material Merging)
	# -----------------------------------------------------------------
	print("--- 3. 재질 최적화 ---")

	print("  Draw Call 줄이기 - 재질 통합:")
	print()
	print("  a) 텍스처 아틀라스:")
	print("     여러 텍스처를 하나의 큰 텍스처에 합치기")
	print("     UV를 조절하여 각 오브젝트가 올바른 영역 사용")
	print("     -> 텍스처 1개 = draw call 병합 가능")
	print()
	print("  b) 재질 공유:")
	print("     # 나쁜 예: 각 인스턴스마다 새 재질")
	print("     for enemy in enemies:")
	print("         enemy.material = StandardMaterial3D.new()  # 매번 새로!")
	print()
	print("     # 좋은 예: 재질 공유")
	print("     var shared_mat = preload(\"res://materials/enemy.tres\")")
	print("     for enemy in enemies:")
	print("         enemy.material = shared_mat  # 같은 재질 참조")
	print()

	# 재질 공유 데모
	var shared_mat := StandardMaterial3D.new()
	shared_mat.albedo_color = Color(0.3, 0.6, 0.3)

	var unique_mat_count := 0
	var shared_mat_count := 0

	# 공유 재질
	for i in range(10):
		var mesh := MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.material_override = shared_mat  # 같은 참조
		mesh.position = Vector3(i * 2, 0, 20)
		mesh.visible = false
		add_child(mesh)
		shared_mat_count += 1

	# 각각 다른 재질 (비효율적 예시)
	for i in range(10):
		var mesh := MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		var unique_mat := StandardMaterial3D.new()
		unique_mat.albedo_color = Color(randf(), randf(), randf())
		mesh.material_override = unique_mat  # 매번 새 재질
		mesh.position = Vector3(i * 2, 0, 22)
		mesh.visible = false
		add_child(mesh)
		unique_mat_count += 1

	print("  데모: 공유 재질 %d개, 고유 재질 %d개" % [shared_mat_count, unique_mat_count])
	print("  공유 재질: ~1 draw call, 고유 재질: ~%d draw calls" % unique_mat_count)
	print()

	print("  c) 재질 독립 변경 필요 시:")
	print("     var unique = shared_mat.duplicate()")
	print("     unique.albedo_color = Color.RED")
	print("     specific_mesh.material_override = unique")
	print()

	# -----------------------------------------------------------------
	# 4) 메시 병합 (Static Batching)
	# -----------------------------------------------------------------
	print("--- 4. 메시 병합 ---")

	print("  정적 오브젝트들을 하나의 메시로 병합:")
	print()
	print("  SurfaceTool을 이용한 병합:")
	print("    var combined_st = SurfaceTool.new()")
	print("    combined_st.begin(Mesh.PRIMITIVE_TRIANGLES)")
	print()
	print("    for mesh_instance in static_objects:")
	print("        combined_st.append_from(")
	print("            mesh_instance.mesh, 0, mesh_instance.transform)")
	print()
	print("    var combined_mesh = combined_st.commit()")
	print("    # 하나의 MeshInstance3D로 모든 정적 오브젝트 렌더링")
	print()

	# 병합 데모
	var merge_time := _benchmark_mesh_merging(50)
	print("  50개 메시 병합 시간: %d us" % merge_time)
	print("  결과: %d draw calls -> 1 draw call" % 50)
	print()

	print("  주의사항:")
	print("    - 정적 오브젝트만 병합 (움직이지 않는)")
	print("    - 같은 재질의 오브젝트끼리 병합")
	print("    - 너무 큰 메시는 오클루전 컬링 무효화")
	print("    - 개별 오브젝트 제거/수정 불가")
	print()

	# -----------------------------------------------------------------
	# 5) 셰이더 최적화
	# -----------------------------------------------------------------
	print("--- 5. 셰이더 최적화 ---")

	print("  a) 셰이더 복잡도 줄이기:")
	print("     - 텍스처 샘플링 최소화")
	print("     - branch(if) 대신 mix/step 사용")
	print("     - 복잡한 수학은 LUT 텍스처로 대체")
	print()
	print("  b) 셰이더 변형(Variant) 최소화:")
	print("     - render_mode 플래그는 셰이더 변형 생성")
	print("     - 사용하지 않는 기능 비활성화")
	print()
	print("  c) 셰이더 컴파일 히치(Hitch) 방지:")
	print("     - 셰이더 사전 컴파일/캐싱")
	print("     - 프로젝트 설정 > Shader Compilation")
	print()

	print("  StandardMaterial3D 최적화:")
	print("     - 사용하지 않는 기능 끄기")
	print("     - shading_mode = SHADING_MODE_UNSHADED (조명 불필요 시)")
	print("     - 노멀맵 불필요하면 비활성화")
	print()

	# -----------------------------------------------------------------
	# 6) 물리 최적화
	# -----------------------------------------------------------------
	print("--- 6. 물리 최적화 ---")

	print("  a) 충돌 형태 단순화:")
	print("     빠름: SphereShape3D > BoxShape3D > CapsuleShape3D")
	print("     느림: ConvexPolygonShape3D > ConcavePolygonShape3D")
	print("     # 복잡한 메시에 ConcavePolygon 대신 여러 Box/Sphere 조합")
	print()

	# 충돌 형태 벤치마크
	_benchmark_collision_shapes()

	print("  b) 물리 레이어 최적화:")
	print("     - 충돌이 필요한 레이어만 마스크 설정")
	print("     - 불필요한 충돌 비활성화")
	print()
	print("  c) RayCast 최적화:")
	print("     - 매 프레임 사용 최소화")
	print("     - collision_mask로 검사 대상 제한")
	print("     - 여러 레이캐스트보다 ShapeCast 사용")
	print()

	print("  d) 정적 vs 동적:")
	print("     - 움직이지 않는 물체: StaticBody3D")
	print("     - 자주 이동: CharacterBody3D > RigidBody3D")
	print("     - StaticBody3D의 Transform 변경 금지!")
	print("       (내부 최적화 무효화)")
	print()

	# -----------------------------------------------------------------
	# 7) 스크립트 최적화
	# -----------------------------------------------------------------
	print("--- 7. 스크립트 최적화 ---")

	# 타입 지정 벤치마크
	_benchmark_typed_vs_untyped()

	print("  주요 스크립트 최적화:")
	print("    a) 타입 지정 변수 사용")
	print("    b) 노드 참조 캐싱 (@onready)")
	print("    c) _process 필요 시에만 활성화")
	print("    d) distance_squared_to 사용")
	print("    e) 배열 대신 Dictionary (검색)")
	print("    f) PackedArray 사용 (대량 데이터)")
	print()

	print("  _process 최적화:")
	print("    # 필요 없으면 비활성화")
	print("    set_process(false)")
	print("    set_physics_process(false)")
	print()
	print("    # 주기적 업데이트 (10FPS)")
	print("    var _timer := 0.0")
	print("    func _process(delta):")
	print("        _timer += delta")
	print("        if _timer < 0.1: return")
	print("        _timer = 0.0")
	print("        _expensive_update()")
	print()

	# -----------------------------------------------------------------
	# 8) 메모리 최적화
	# -----------------------------------------------------------------
	print("--- 8. 메모리 최적화 ---")

	var static_mem := Performance.get_monitor(Performance.MEMORY_STATIC)
	print("  현재 정적 메모리: %.2f MB" % (static_mem / 1048576.0))
	print()

	print("  텍스처 메모리:")
	print("    - 크기: Power of 2 (256, 512, 1024)")
	print("    - 압축: VRAM 압축 사용 (S3TC/BPTC)")
	print("    - Mipmap: 원거리용 자동 축소")
	print("    - 불필요한 큰 텍스처 제거")
	print()
	print("  메시 메모리:")
	print("    - 정점 수 최소화")
	print("    - LOD 사용 (원거리 메시 간소화)")
	print("    - 동일 메시 리소스 공유")
	print()
	print("  리소스 관리:")
	print("    preload() - 시작 시 로드 (작은 리소스)")
	print("    load()    - 필요 시 로드 (큰 리소스)")
	print("    ResourceLoader.load_threaded_request() - 비동기 로드")
	print()

	# -----------------------------------------------------------------
	# 9) 프로파일링 도구
	# -----------------------------------------------------------------
	print("--- 9. 프로파일링 도구 ---")

	print("  a) Godot 내장 프로파일러:")
	print("     하단 패널 > Debugger > Profiler")
	print("     - 함수별 실행 시간")
	print("     - 프레임별 CPU 시간")
	print()

	print("  b) Godot 모니터:")
	print("     하단 패널 > Debugger > Monitors")

	# 주요 모니터 값 표시
	var monitors := {
		"FPS": Performance.TIME_FPS,
		"프레임 시간": Performance.TIME_PROCESS,
		"물리 시간": Performance.TIME_PHYSICS_PROCESS,
		"오브젝트 수": Performance.OBJECT_COUNT,
		"노드 수": Performance.OBJECT_NODE_COUNT,
		"리소스 수": Performance.OBJECT_RESOURCE_COUNT,
	}

	for mon_name in monitors:
		var value := Performance.get_monitor(monitors[mon_name])
		if mon_name == "프레임 시간" or mon_name == "물리 시간":
			print("     %s: %.2f ms" % [mon_name, value * 1000])
		else:
			print("     %s: %.0f" % [mon_name, value])
	print()

	print("  c) 코드에서 측정:")
	print("     var start = Time.get_ticks_usec()")
	print("     # 측정할 코드")
	print("     var elapsed = Time.get_ticks_usec() - start")
	print("     print(\"소요 시간: %%d us\" %% elapsed)")
	print()

	print("  d) RenderingServer 정보:")
	var info_objects := RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME
	)
	var info_primitives := RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME
	)
	var info_draw_calls := RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
	)
	print("     렌더 오브젝트: %d" % info_objects)
	print("     프리미티브: %d" % info_primitives)
	print("     Draw Calls: %d" % info_draw_calls)
	print()

	# -----------------------------------------------------------------
	# 10) 최적화 체크리스트
	# -----------------------------------------------------------------
	print("--- 10. 3D 최적화 체크리스트 ---")

	print("  [렌더링]")
	print("    [ ] Draw Call 수 확인 (목표치 설정)")
	print("    [ ] MultiMesh 사용 (반복 오브젝트)")
	print("    [ ] 재질 공유 (같은 Material 참조)")
	print("    [ ] 텍스처 아틀라스 (재질 통합)")
	print("    [ ] LOD 설정 (거리별 디테일)")
	print("    [ ] 오클루전 컬링 (가려진 오브젝트)")
	print("    [ ] 그림자 최적화 (원거리 그림자 OFF)")
	print("    [ ] AABB 정확성 확인")
	print()
	print("  [물리]")
	print("    [ ] 간단한 충돌 형태 (Sphere > Box > Convex)")
	print("    [ ] 물리 레이어/마스크 최적화")
	print("    [ ] 정적 오브젝트는 StaticBody3D")
	print("    [ ] RayCast collision_mask 제한")
	print()
	print("  [스크립트]")
	print("    [ ] 타입 지정 변수 (int, float, Vector3)")
	print("    [ ] 노드 참조 캐싱")
	print("    [ ] _process 필요 시에만 활성화")
	print("    [ ] distance_squared_to 사용")
	print("    [ ] 오브젝트 풀링 (빈번한 생성/삭제)")
	print()
	print("  [메모리]")
	print("    [ ] 텍스처 크기/압축 확인")
	print("    [ ] 리소스 공유 (preload)")
	print("    [ ] 고아 노드 확인")
	print("    [ ] 비동기 로딩 (큰 씬)")
	print()
	print("  [프로파일링]")
	print("    [ ] 프로파일러로 병목 확인")
	print("    [ ] GPU vs CPU 바운드 판별")
	print("    [ ] 목표 FPS에서 테스트")
	print("    [ ] 최저 사양 기기에서 테스트")
	print()

	print("=== 04-performance-3d.gd 완료 ===")


# =============================================================================
# 벤치마크 함수
# =============================================================================

## 개별 MeshInstance3D 생성 벤치마크
func _benchmark_individual_meshes(count: int) -> int:
	var container := Node3D.new()
	add_child(container)

	var start := Time.get_ticks_usec()
	for i in range(count):
		var mesh := MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.position = Vector3(randf() * 20, 0, randf() * 20)
		mesh.visible = false
		container.add_child(mesh)
	var elapsed := Time.get_ticks_usec() - start

	container.queue_free()
	return elapsed


## MultiMesh 생성 벤치마크
func _benchmark_multimesh(count: int) -> int:
	var start := Time.get_ticks_usec()

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = BoxMesh.new()
	mm.instance_count = count

	for i in range(count):
		var t := Transform3D()
		t.origin = Vector3(randf() * 20, 0, randf() * 20)
		mm.set_instance_transform(i, t)

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.visible = false
	add_child(mmi)

	var elapsed := Time.get_ticks_usec() - start
	return elapsed


## 풀밭 MultiMesh 생성
func _create_grass_field(pos: Vector3, count: int):
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true

	# 풀잎 메시
	var grass_mesh := BoxMesh.new()
	grass_mesh.size = Vector3(0.05, 0.3, 0.05)
	mm.mesh = grass_mesh
	mm.instance_count = count

	for i in range(count):
		var t := Transform3D()
		t.origin = pos + Vector3(
			randf_range(-10, 10),
			0.15,
			randf_range(-10, 10)
		)
		# 랜덤 회전
		t = t.rotated(Vector3.UP, randf() * TAU)
		# 약간의 스케일 변화
		var s := randf_range(0.7, 1.3)
		t = t.scaled(Vector3(s, s, s))
		mm.set_instance_transform(i, t)

		# 색상 변화
		var green := randf_range(0.4, 0.8)
		mm.set_instance_color(i, Color(0.2, green, 0.1))

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	grass_mesh.material = mat

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)


## 메시 병합 벤치마크
func _benchmark_mesh_merging(count: int) -> int:
	var start := Time.get_ticks_usec()

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var source_mesh := BoxMesh.new()
	source_mesh.size = Vector3(1, 1, 1)

	for i in range(count):
		var transform := Transform3D()
		transform.origin = Vector3(
			(i % 10) * 2.0,
			0,
			(i / 10) * 2.0
		)
		st.append_from(source_mesh, 0, transform)

	var _merged_mesh := st.commit()
	var elapsed := Time.get_ticks_usec() - start
	return elapsed


## 충돌 형태 벤치마크
func _benchmark_collision_shapes():
	print("  충돌 형태 생성 벤치마크 (%d회):" % BENCHMARK_ITERATIONS)

	# SphereShape3D
	var start := Time.get_ticks_usec()
	for i in range(BENCHMARK_ITERATIONS):
		var _s := SphereShape3D.new()
		_s.radius = 1.0
	var sphere_time := Time.get_ticks_usec() - start

	# BoxShape3D
	start = Time.get_ticks_usec()
	for i in range(BENCHMARK_ITERATIONS):
		var _s := BoxShape3D.new()
		_s.size = Vector3(1, 1, 1)
	var box_time := Time.get_ticks_usec() - start

	# ConvexPolygonShape3D
	start = Time.get_ticks_usec()
	for i in range(BENCHMARK_ITERATIONS):
		var _s := ConvexPolygonShape3D.new()
	var convex_time := Time.get_ticks_usec() - start

	print("    SphereShape3D:         %d us" % sphere_time)
	print("    BoxShape3D:            %d us" % box_time)
	print("    ConvexPolygonShape3D:  %d us" % convex_time)
	print()


## 타입 지정 벤치마크
func _benchmark_typed_vs_untyped():
	print("  타입 지정 벤치마크 (%d회):" % BENCHMARK_ITERATIONS)

	# 타입 없는 Vector3 연산
	var start := Time.get_ticks_usec()
	var a = Vector3.ZERO
	for i in range(BENCHMARK_ITERATIONS):
		a = a + Vector3(0.1, 0.2, 0.3)
		a = a * 0.99
	var untyped_time := Time.get_ticks_usec() - start

	# 타입 있는 Vector3 연산
	start = Time.get_ticks_usec()
	var b: Vector3 = Vector3.ZERO
	for i in range(BENCHMARK_ITERATIONS):
		b = b + Vector3(0.1, 0.2, 0.3)
		b = b * 0.99
	var typed_time := Time.get_ticks_usec() - start

	print("    Variant (untyped): %d us" % untyped_time)
	print("    Vector3 (typed):   %d us" % typed_time)
	print()
