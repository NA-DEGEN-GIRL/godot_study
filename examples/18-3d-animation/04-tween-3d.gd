# Chapter 18 - 3D Animation
# 04-tween-3d.gd - Tween 3D 활용, 문/엘리베이터, 시네마틱 카메라
#
# 이 파일에서 배울 내용:
# - Tween을 이용한 3D 오브젝트 애니메이션
# - 문 열기/닫기, 엘리베이터, 플랫폼 이동
# - 시네마틱 카메라 무빙 (Dolly, Pan, Zoom)
# - Tween 체이닝과 병렬 실행
# - 커스텀 이징과 경로 기반 이동

extends Node3D

var door_open := false
var elevator_at_top := false

func _ready():
	print("=== Chapter 18-4: Tween 3D 활용 ===\n")

	# -----------------------------------------------------------------
	# 1) 3D Tween 기본 복습
	# -----------------------------------------------------------------
	print("--- 1. 3D Tween 기본 ---")

	# 이동할 큐브 생성
	var cube := _create_colored_box(Color(0.3, 0.5, 0.8), Vector3(1, 1, 1))
	cube.position = Vector3(0, 0, 0)
	add_child(cube)

	# 기본 이동 Tween
	var tween := create_tween()
	tween.tween_property(cube, "position", Vector3(3, 0, 0), 1.0)
	tween.tween_property(cube, "position", Vector3(3, 2, 0), 0.5)
	tween.tween_property(cube, "position", Vector3(0, 0, 0), 1.0)

	print("  큐브 이동 Tween:")
	print("    (0,0,0) -> (3,0,0) [1초]")
	print("    (3,0,0) -> (3,2,0) [0.5초]")
	print("    (3,2,0) -> (0,0,0) [1초]")
	print("  순차 실행 (총 2.5초)")
	print()

	# -----------------------------------------------------------------
	# 2) 회전과 스케일 Tween
	# -----------------------------------------------------------------
	print("--- 2. 회전 & 스케일 Tween ---")

	var spinning_cube := _create_colored_box(Color(0.8, 0.4, 0.2), Vector3(0.8, 0.8, 0.8))
	spinning_cube.position = Vector3(5, 1, 0)
	add_child(spinning_cube)

	var spin_tween := create_tween().set_loops()  # 무한 반복
	# 회전 (rotation_degrees 사용)
	spin_tween.tween_property(spinning_cube, "rotation_degrees",
		Vector3(0, 360, 0), 3.0).from(Vector3.ZERO)

	print("  Y축 360도 회전 (무한 반복, 3초/회)")
	print()

	# 스케일 바운스 효과
	var bounce_cube := _create_colored_box(Color(0.2, 0.7, 0.3), Vector3(1, 1, 1))
	bounce_cube.position = Vector3(8, 1, 0)
	add_child(bounce_cube)

	var bounce_tween := create_tween().set_loops()
	bounce_tween.tween_property(bounce_cube, "scale",
		Vector3(1.3, 0.7, 1.3), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	bounce_tween.tween_property(bounce_cube, "scale",
		Vector3(0.8, 1.4, 0.8), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	bounce_tween.tween_property(bounce_cube, "scale",
		Vector3(1, 1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	print("  스케일 바운스 효과:")
	print("    찌그러짐 (0.3초) -> 늘어남 (0.2초) -> 원래 (0.5초, Elastic)")
	print()

	# -----------------------------------------------------------------
	# 3) 문 열기/닫기 (Door)
	# -----------------------------------------------------------------
	print("--- 3. 문 열기/닫기 ---")

	# 문틀
	var door_frame := _create_colored_box(Color(0.5, 0.35, 0.2), Vector3(0.1, 2.5, 1.2))
	door_frame.position = Vector3(-5, 1.25, 0)
	add_child(door_frame)

	# 문 (회전축이 왼쪽 모서리)
	var door_pivot := Node3D.new()
	door_pivot.position = Vector3(-5.5, 0, -0.5)  # 피봇 위치 (경첩)
	add_child(door_pivot)

	var door_mesh := _create_colored_box(Color(0.6, 0.4, 0.25), Vector3(0.05, 2, 0.9))
	door_mesh.position = Vector3(0, 1, 0.45)  # 피봇에서 오프셋
	door_pivot.add_child(door_mesh)

	print("  문 구조: Node3D(피봇) -> MeshInstance3D(문)")
	print("  피봇을 경첩 위치에 배치하고 문을 오프셋")
	print()

	# 문 열기 함수 시연
	_animate_door(door_pivot, true)

	print("  문 열기 코드:")
	print("    func toggle_door():")
	print("        var tween = create_tween()")
	print("        if door_open:")
	print("            tween.tween_property(door_pivot, \"rotation_degrees:y\", 0.0, 0.8)")
	print("            tween.set_ease(Tween.EASE_IN_OUT)")
	print("        else:")
	print("            tween.tween_property(door_pivot, \"rotation_degrees:y\", -90.0, 0.8)")
	print("            tween.set_ease(Tween.EASE_IN_OUT)")
	print("        door_open = !door_open")
	print()

	# 슬라이딩 문
	print("  슬라이딩 문:")
	print("    tween.tween_property(sliding_door, \"position:x\",")
	print("        open_x, 0.5).set_trans(Tween.TRANS_QUAD)")
	print()

	# -----------------------------------------------------------------
	# 4) 엘리베이터 (Elevator)
	# -----------------------------------------------------------------
	print("--- 4. 엘리베이터 ---")

	# 엘리베이터 플랫폼
	var elevator := _create_colored_box(Color(0.6, 0.6, 0.65), Vector3(2, 0.2, 2))
	elevator.position = Vector3(-8, 0.1, 0)
	add_child(elevator)

	# 엘리베이터 벽
	var elev_wall := _create_colored_box(Color(0.5, 0.5, 0.55), Vector3(2, 3, 0.1))
	elev_wall.position = Vector3(0, 1.5, -1.0)
	elevator.add_child(elev_wall)

	# 엘리베이터 이동
	_animate_elevator(elevator, 5.0)

	print("  엘리베이터 동작:")
	print("    1. 대기 (1초)")
	print("    2. 위로 이동 (2초, Ease In-Out)")
	print("    3. 상단 대기 (2초)")
	print("    4. 아래로 이동 (2초)")
	print("    5. 반복")
	print()

	print("  코드:")
	print("    func move_elevator(target_y: float):")
	print("        var tween = create_tween()")
	print("        tween.tween_interval(1.0)  # 대기")
	print("        tween.tween_property(elevator, \"position:y\",")
	print("            target_y, 2.0).set_trans(Tween.TRANS_SINE)")
	print("        tween.tween_interval(2.0)  # 상단 대기")
	print("        tween.tween_property(elevator, \"position:y\",")
	print("            0.1, 2.0).set_trans(Tween.TRANS_SINE)")
	print("        tween.set_loops()  # 반복")
	print()

	# -----------------------------------------------------------------
	# 5) 이동 플랫폼 (Moving Platform)
	# -----------------------------------------------------------------
	print("--- 5. 이동 플랫폼 ---")

	var platform := _create_colored_box(Color(0.4, 0.65, 0.4), Vector3(3, 0.3, 2))
	platform.position = Vector3(-12, 2, 0)
	add_child(platform)

	# 경로를 따라 이동하는 플랫폼
	var platform_tween := create_tween().set_loops()
	platform_tween.tween_property(platform, "position",
		Vector3(-12, 2, 0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	platform_tween.tween_property(platform, "position",
		Vector3(-6, 2, 0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	platform_tween.tween_property(platform, "position",
		Vector3(-6, 5, 0), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	platform_tween.tween_property(platform, "position",
		Vector3(-12, 5, 0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	print("  경유 포인트 플랫폼:")
	print("    A(-12,2,0) -> B(-6,2,0) -> C(-6,5,0) -> D(-12,5,0) -> A")
	print("    TRANS_SINE + EASE_IN_OUT = 부드러운 감속/가속")
	print()

	# -----------------------------------------------------------------
	# 6) 시네마틱 카메라 이동
	# -----------------------------------------------------------------
	print("--- 6. 시네마틱 카메라 ---")

	# 카메라 생성
	var camera := Camera3D.new()
	camera.position = Vector3(0, 5, 10)
	camera.look_at(Vector3.ZERO)
	add_child(camera)

	print("  카메라 무빙 기법:")
	print()

	# Dolly (전/후진)
	print("  a) Dolly (전/후진):")
	print("    var tween = create_tween()")
	print("    tween.tween_property(camera, \"position\",")
	print("        Vector3(0, 5, 3), 3.0)  # 피사체 접근")
	print("    tween.set_trans(Tween.TRANS_CUBIC)")
	print()

	# Pan (수평 회전)
	print("  b) Pan (수평 회전):")
	print("    tween.tween_property(camera, \"rotation_degrees:y\",")
	print("        45.0, 2.0)  # 45도 팬")
	print()

	# Orbit (궤도 회전)
	print("  c) Orbit (궤도 회전):")
	print("    # Node3D 피봇을 이용")
	print("    var pivot = Node3D.new()")
	print("    pivot.add_child(camera)")
	print("    camera.position = Vector3(0, 3, 8)  # 오프셋")
	print("    camera.look_at(Vector3.ZERO)")
	print("    tween.tween_property(pivot, \"rotation_degrees:y\",")
	print("        360.0, 10.0)  # 360도 공전")
	print()

	# 시네마틱 시퀀스
	_run_cinematic_sequence(camera)

	# -----------------------------------------------------------------
	# 7) Tween 체이닝과 병렬 실행
	# -----------------------------------------------------------------
	print("--- 7. Tween 체이닝 & 병렬 ---")

	var demo_obj := _create_colored_box(Color(0.7, 0.3, 0.7), Vector3(0.8, 0.8, 0.8))
	demo_obj.position = Vector3(12, 1, 0)
	add_child(demo_obj)

	# 순차 (기본)
	print("  순차 실행 (기본):")
	print("    tween.tween_property(obj, \"position\", ...)")
	print("    tween.tween_property(obj, \"rotation\", ...)  # 이동 후 회전")
	print()

	# 병렬
	print("  병렬 실행 (set_parallel):")
	print("    tween.set_parallel(true)")
	print("    tween.tween_property(obj, \"position\", ...)")
	print("    tween.tween_property(obj, \"rotation\", ...)  # 동시에!")
	print()

	# 병렬 + 순차 조합
	var chain_tween := create_tween()

	# 1단계: 이동 + 회전 동시
	chain_tween.set_parallel(true)
	chain_tween.tween_property(demo_obj, "position",
		Vector3(15, 1, 0), 1.0)
	chain_tween.tween_property(demo_obj, "rotation_degrees",
		Vector3(0, 180, 0), 1.0)

	# 2단계: 스케일 변경 (순차)
	chain_tween.set_parallel(false)
	chain_tween.tween_property(demo_obj, "scale",
		Vector3(1.5, 1.5, 1.5), 0.5)

	# 3단계: 다시 병렬
	chain_tween.set_parallel(true)
	chain_tween.tween_property(demo_obj, "position",
		Vector3(12, 1, 0), 1.0)
	chain_tween.tween_property(demo_obj, "scale",
		Vector3(1, 1, 1), 1.0)

	print("  조합 예시:")
	print("    1. [병렬] 이동 + 회전 (1초)")
	print("    2. [순차] 스케일 커짐 (0.5초)")
	print("    3. [병렬] 이동 복귀 + 스케일 복귀 (1초)")
	print()

	# -----------------------------------------------------------------
	# 8) tween_method로 커스텀 보간
	# -----------------------------------------------------------------
	print("--- 8. tween_method 커스텀 보간 ---")

	var lerp_obj := _create_colored_box(Color(0.8, 0.8, 0.2), Vector3(0.5, 0.5, 0.5))
	lerp_obj.position = Vector3(0, 3, -5)
	add_child(lerp_obj)

	# 베지어 곡선 이동
	var method_tween := create_tween()
	method_tween.tween_method(
		func(t: float):
			# 2차 베지어 곡선
			var p0 := Vector3(0, 3, -5)    # 시작
			var p1 := Vector3(3, 6, -5)    # 제어점 (위로 볼록)
			var p2 := Vector3(6, 3, -5)    # 끝
			var pos := p0 * (1-t) * (1-t) + p1 * 2 * (1-t) * t + p2 * t * t
			lerp_obj.position = pos,
		0.0, 1.0, 2.0
	)

	print("  tween_method로 베지어 곡선 이동:")
	print("    P0(0,3,-5) -> P1(3,6,-5) -> P2(6,3,-5)")
	print("    2차 베지어: B(t) = P0*(1-t)^2 + P1*2*(1-t)*t + P2*t^2")
	print()

	# 재질 속성 애니메이션
	print("  재질 애니메이션:")
	print("    tween.tween_method(func(value: float):")
	print("        material.albedo_color.a = value")
	print("    , 1.0, 0.0, 2.0)  # 2초간 페이드아웃")
	print()

	# -----------------------------------------------------------------
	# 9) Tween 콜백과 이벤트
	# -----------------------------------------------------------------
	print("--- 9. Tween 콜백 ---")

	print("  Tween 완료 시 콜백:")
	print("    var tween = create_tween()")
	print("    tween.tween_property(door, \"rotation:y\", -PI/2, 1.0)")
	print("    tween.tween_callback(func():")
	print("        print(\"문이 열렸습니다!\")")
	print("        door_open = true)")
	print()

	print("  중간 지연:")
	print("    tween.tween_interval(2.0)  # 2초 대기")
	print()

	print("  시그널 대기:")
	print("    tween.finished.connect(func(): print(\"Tween 완료!\"))")
	print()

	print("  Tween 제어:")
	print("    tween.pause()   # 일시 정지")
	print("    tween.play()    # 재개")
	print("    tween.stop()    # 정지")
	print("    tween.kill()    # 제거")
	print("    tween.is_running()  # 실행 중인지")
	print()

	# -----------------------------------------------------------------
	# 10) 이징 함수 레퍼런스
	# -----------------------------------------------------------------
	print("--- 10. 이징 함수 레퍼런스 ---")

	print("  Tween.TRANS_* (전이 타입):")
	print("    LINEAR  - 일정 속도")
	print("    SINE    - 사인 곡선 (부드러움)")
	print("    QUAD    - 2차 곡선 (일반적)")
	print("    CUBIC   - 3차 곡선 (더 강조)")
	print("    QUART   - 4차 곡선")
	print("    QUINT   - 5차 곡선")
	print("    EXPO    - 지수 곡선 (극적)")
	print("    CIRC    - 원형 곡선")
	print("    ELASTIC - 탄성 (오버슈트)")
	print("    BOUNCE  - 바운스")
	print("    BACK    - 약간 뒤로 갔다가 (오버슈트)")
	print("    SPRING  - 스프링")
	print()
	print("  Tween.EASE_* (이징 방향):")
	print("    EASE_IN      - 처음 느림, 끝 빠름")
	print("    EASE_OUT     - 처음 빠름, 끝 느림")
	print("    EASE_IN_OUT  - 양쪽 느림")
	print("    EASE_OUT_IN  - 가운데 느림")
	print()

	print("  추천 조합:")
	print("    문/엘리베이터:  TRANS_SINE + EASE_IN_OUT")
	print("    바운스 착지:    TRANS_BOUNCE + EASE_OUT")
	print("    UI 팝업:       TRANS_BACK + EASE_OUT")
	print("    페이드인/아웃:  TRANS_QUAD + EASE_IN_OUT")
	print("    타격 피드백:    TRANS_ELASTIC + EASE_OUT")
	print()

	print("=== 04-tween-3d.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 색상 있는 박스 MeshInstance3D 생성
func _create_colored_box(color: Color, size: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat
	return mesh_instance


## 문 열기/닫기 애니메이션
func _animate_door(door_pivot: Node3D, open: bool):
	var tween := create_tween()
	var target_angle := -90.0 if open else 0.0
	tween.tween_property(door_pivot, "rotation_degrees:y",
		target_angle, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	door_open = open


## 엘리베이터 왕복 애니메이션
func _animate_elevator(elevator: Node3D, height: float):
	var tween := create_tween().set_loops()
	tween.tween_interval(1.0)
	tween.tween_property(elevator, "position:y",
		height, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(elevator, "position:y",
		0.1, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## 시네마틱 시퀀스
func _run_cinematic_sequence(camera: Camera3D):
	print("  시네마틱 시퀀스 생성:")

	var cine_tween := create_tween()

	# 장면 1: 와이드 숏 -> 클로즈업
	cine_tween.tween_property(camera, "position",
		Vector3(0, 3, 5), 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	# 장면 2: 팬 (수평 이동)
	cine_tween.tween_property(camera, "position",
		Vector3(5, 3, 5), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 장면 3: 크레인 숏 (위로 올라감)
	cine_tween.tween_property(camera, "position",
		Vector3(5, 8, 5), 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	# 장면 4: 원래 위치로 복귀
	cine_tween.tween_property(camera, "position",
		Vector3(0, 5, 10), 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	print("    1. 와이드 -> 클로즈업 (3초)")
	print("    2. 팬 (2초)")
	print("    3. 크레인 업 (2초)")
	print("    4. 복귀 (3초)")
	print("    총 시간: 10초")
	print()
