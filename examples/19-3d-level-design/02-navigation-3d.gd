# Chapter 19 - 3D Level Design
# 02-navigation-3d.gd - NavigationAgent3D, 경로 탐색, 에이전트 회피
#
# 이 파일에서 배울 내용:
# - NavigationRegion3D와 NavigationMesh 설정
# - NavigationAgent3D를 이용한 AI 경로 탐색
# - 경로 계산과 이동 구현
# - 에이전트 간 회피 (Avoidance)
# - 동적 장애물과 네비게이션 업데이트
# - 네비게이션 레이어와 코스트

extends Node3D

# 에이전트 시뮬레이션 변수
var agents: Array[Dictionary] = []
var nav_ready := false

func _ready():
	print("=== Chapter 19-2: 3D Navigation ===\n")

	# -----------------------------------------------------------------
	# 1) 네비게이션 시스템 개요
	# -----------------------------------------------------------------
	print("--- 1. 네비게이션 시스템 개요 ---")

	print("  Godot 3D 네비게이션 구성 요소:")
	print("    NavigationRegion3D  - 이동 가능 영역 정의")
	print("    NavigationMesh      - 메시 기반 이동 영역 데이터")
	print("    NavigationAgent3D   - 경로 탐색하는 에이전트")
	print("    NavigationObstacle3D - 동적 장애물")
	print("    NavigationLink3D    - 점프/텔레포트 등 특수 연결")
	print()
	print("  작동 흐름:")
	print("    1. NavigationRegion3D에 NavigationMesh 설정")
	print("    2. NavigationMesh를 베이크 (이동 가능 영역 계산)")
	print("    3. NavigationAgent3D가 경로를 요청")
	print("    4. NavigationServer3D가 경로 계산")
	print("    5. 에이전트가 경로를 따라 이동")
	print()

	# -----------------------------------------------------------------
	# 2) NavigationRegion3D 설정
	# -----------------------------------------------------------------
	print("--- 2. NavigationRegion3D 설정 ---")

	# 네비게이션 영역 생성
	var nav_region := NavigationRegion3D.new()
	add_child(nav_region)

	# NavigationMesh 생성
	var nav_mesh := NavigationMesh.new()

	# 파싱 설정
	nav_mesh.agent_radius = 0.5       # 에이전트 반지름
	nav_mesh.agent_height = 1.8       # 에이전트 높이
	nav_mesh.agent_max_climb = 0.3    # 최대 오를 수 있는 높이
	nav_mesh.agent_max_slope = 45.0   # 최대 경사각

	nav_region.navigation_mesh = nav_mesh

	print("  NavigationMesh 에이전트 설정:")
	print("    agent_radius = %.1f m" % nav_mesh.agent_radius)
	print("    agent_height = %.1f m" % nav_mesh.agent_height)
	print("    agent_max_climb = %.1f m" % nav_mesh.agent_max_climb)
	print("    agent_max_slope = %.0f degrees" % nav_mesh.agent_max_slope)
	print()

	# 바닥 메시 생성 (네비게이션 영역의 소스)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	floor_mesh.mesh = plane
	nav_region.add_child(floor_mesh)

	# 바닥 충돌체 추가
	var floor_body := StaticBody3D.new()
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector3(0, -0.05, 0)
	floor_body.add_child(floor_collision)
	nav_region.add_child(floor_body)

	# 장애물 (네비게이션에서 제외됨)
	_add_obstacle(nav_region, Vector3(3, 0.5, 2), Vector3(2, 1, 2))
	_add_obstacle(nav_region, Vector3(-4, 0.5, -3), Vector3(3, 1, 1))
	_add_obstacle(nav_region, Vector3(0, 0.5, 5), Vector3(1, 1, 4))

	# 네비게이션 메시 베이크
	nav_region.bake_navigation_mesh()

	print("  바닥: 20x20m 평면")
	print("  장애물 3개 배치")
	print("  NavigationMesh 베이크 완료")
	print()

	print("  에디터에서 베이크:")
	print("    NavigationRegion3D 선택 > 상단 'Bake NavMesh' 버튼")
	print()

	# -----------------------------------------------------------------
	# 3) NavigationAgent3D 기본 설정
	# -----------------------------------------------------------------
	print("--- 3. NavigationAgent3D 설정 ---")

	# 에이전트 캐릭터 생성
	var agent_body := CharacterBody3D.new()
	agent_body.position = Vector3(-8, 0.5, -8)
	add_child(agent_body)

	# 충돌 형태
	var agent_collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	agent_collision.shape = capsule
	agent_body.add_child(agent_collision)

	# 시각적 메시
	var agent_mesh := MeshInstance3D.new()
	var agent_capsule := CapsuleMesh.new()
	agent_capsule.radius = 0.4
	agent_capsule.height = 1.8
	agent_mesh.mesh = agent_capsule
	var agent_mat := StandardMaterial3D.new()
	agent_mat.albedo_color = Color(0.2, 0.6, 1.0)
	agent_mesh.material_override = agent_mat
	agent_body.add_child(agent_mesh)

	# NavigationAgent3D 설정
	var nav_agent := NavigationAgent3D.new()
	nav_agent.path_desired_distance = 0.5    # 경로점 도달 판정 거리
	nav_agent.target_desired_distance = 0.5  # 최종 목표 도달 판정 거리
	nav_agent.radius = 0.5                   # 에이전트 반지름
	nav_agent.max_speed = 5.0                # 최대 속도
	nav_agent.avoidance_enabled = true       # 회피 활성화
	agent_body.add_child(nav_agent)

	print("  NavigationAgent3D 속성:")
	print("    path_desired_distance = %.1f" % nav_agent.path_desired_distance)
	print("    target_desired_distance = %.1f" % nav_agent.target_desired_distance)
	print("    radius = %.1f" % nav_agent.radius)
	print("    max_speed = %.1f" % nav_agent.max_speed)
	print("    avoidance_enabled = %s" % str(nav_agent.avoidance_enabled))
	print()

	# 목표 지점 설정
	nav_agent.target_position = Vector3(8, 0, 8)
	print("  target_position = Vector3(8, 0, 8)")
	print()

	# -----------------------------------------------------------------
	# 4) 경로 이동 구현
	# -----------------------------------------------------------------
	print("--- 4. 경로 이동 구현 ---")

	print("  _physics_process에서 경로 따라 이동:")
	print()
	print("  func _physics_process(delta):")
	print("      if nav_agent.is_navigation_finished():")
	print("          return")
	print()
	print("      # 다음 경로점 가져오기")
	print("      var next_pos = nav_agent.get_next_path_position()")
	print()
	print("      # 이동 방향 계산")
	print("      var direction = (next_pos - global_position).normalized()")
	print()
	print("      # 이동 속도 설정")
	print("      velocity = direction * MOVE_SPEED")
	print()
	print("      # 회피가 활성화된 경우")
	print("      if nav_agent.avoidance_enabled:")
	print("          nav_agent.velocity = velocity  # 안전 속도 요청")
	print("      else:")
	print("          move_and_slide()")
	print()
	print("  # 회피 콜백 (안전 속도 수신)")
	print("  func _on_nav_agent_velocity_computed(safe_velocity):")
	print("      velocity = safe_velocity")
	print("      move_and_slide()")
	print()

	# 경로 확인
	if not nav_agent.is_navigation_finished():
		print("  경로 계산됨: 이동 시작 가능")
		print("  남은 거리: %.1f" % nav_agent.distance_to_target())
	else:
		print("  경로 없음 또는 이미 도착")
	print()

	# -----------------------------------------------------------------
	# 5) 경로 시그널
	# -----------------------------------------------------------------
	print("--- 5. NavigationAgent3D 시그널 ---")

	print("  주요 시그널:")
	print("    path_changed        - 경로가 재계산되었을 때")
	print("    target_reached      - 목표에 도달했을 때")
	print("    navigation_finished - 내비게이션 완료")
	print("    velocity_computed   - 안전 속도 계산 완료 (회피)")
	print("    link_reached        - NavigationLink 도달")
	print("    waypoint_reached    - 경유점 도달")
	print()

	print("  시그널 연결:")
	print("    nav_agent.target_reached.connect(_on_target_reached)")
	print("    nav_agent.velocity_computed.connect(_on_velocity_computed)")
	print()

	print("  유용한 메서드:")
	print("    nav_agent.get_current_navigation_path()  # 전체 경로 배열")
	print("    nav_agent.get_current_navigation_path_index()  # 현재 인덱스")
	print("    nav_agent.is_target_reachable()  # 도달 가능 여부")
	print("    nav_agent.is_target_reached()    # 도달 여부")
	print()

	# -----------------------------------------------------------------
	# 6) 에이전트 회피 (Avoidance)
	# -----------------------------------------------------------------
	print("--- 6. 에이전트 회피 ---")

	print("  Avoidance: 에이전트들이 서로 충돌하지 않도록 회피")
	print()
	print("  설정:")
	print("    nav_agent.avoidance_enabled = true")
	print("    nav_agent.radius = 0.5      # 회피 반지름")
	print("    nav_agent.max_speed = 5.0   # 최대 속도")
	print("    nav_agent.neighbor_distance = 10.0  # 탐지 거리")
	print("    nav_agent.max_neighbors = 10  # 고려할 이웃 수")
	print("    nav_agent.time_horizon_agents = 1.0  # 예측 시간 (에이전트)")
	print("    nav_agent.time_horizon_obstacles = 0.5  # 예측 시간 (장애물)")
	print()

	print("  회피 레이어:")
	print("    nav_agent.avoidance_layers = 1    # 자신의 레이어")
	print("    nav_agent.avoidance_mask = 1      # 감지할 레이어")
	print("    # 아군/적군을 다른 레이어로 분리 가능")
	print()

	# 여러 에이전트 생성 데모
	print("  여러 에이전트 회피 시연:")
	var colors := [Color.RED, Color.GREEN, Color.YELLOW, Color.PURPLE]
	var starts := [
		Vector3(-7, 0.5, 0), Vector3(7, 0.5, 0),
		Vector3(0, 0.5, -7), Vector3(0, 0.5, 7)
	]
	var targets := [
		Vector3(7, 0.5, 0), Vector3(-7, 0.5, 0),
		Vector3(0, 0.5, 7), Vector3(0, 0.5, -7)
	]

	for i in range(4):
		var info := _create_nav_agent(starts[i], targets[i], colors[i])
		agents.append(info)
		print("    에이전트 %d: %s -> %s" % [i, starts[i], targets[i]])
	print()

	# -----------------------------------------------------------------
	# 7) 동적 장애물 (NavigationObstacle3D)
	# -----------------------------------------------------------------
	print("--- 7. NavigationObstacle3D ---")

	print("  동적 장애물: 런타임에 네비게이션 영역을 변경")
	print()

	var obstacle := NavigationObstacle3D.new()
	obstacle.radius = 1.0
	obstacle.avoidance_enabled = true  # 회피 대상으로 설정

	var obstacle_mesh := MeshInstance3D.new()
	var obs_cyl := CylinderMesh.new()
	obs_cyl.top_radius = 1.0
	obs_cyl.bottom_radius = 1.0
	obs_cyl.height = 1.5
	obstacle_mesh.mesh = obs_cyl
	var obs_mat := StandardMaterial3D.new()
	obs_mat.albedo_color = Color(0.8, 0.2, 0.2, 0.5)
	obs_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	obstacle_mesh.material_override = obs_mat

	var obstacle_node := Node3D.new()
	obstacle_node.position = Vector3(0, 0.75, 0)
	obstacle_node.add_child(obstacle)
	obstacle_node.add_child(obstacle_mesh)
	add_child(obstacle_node)

	print("  NavigationObstacle3D 생성:")
	print("    radius = %.1f" % obstacle.radius)
	print("    avoidance_enabled = true")
	print("    # 에이전트들이 이 장애물을 회피합니다")
	print()

	print("  정적 vs 동적 장애물:")
	print("    정적: NavigationMesh 베이크에 포함 (StaticBody3D)")
	print("    동적: NavigationObstacle3D (실시간 회피)")
	print("    정적이 더 효율적, 동적은 유연함")
	print()

	# -----------------------------------------------------------------
	# 8) NavigationLink3D (특수 연결)
	# -----------------------------------------------------------------
	print("--- 8. NavigationLink3D ---")

	print("  NavigationLink3D: 불연속적인 네비게이션 영역을 연결")
	print("  점프, 사다리, 텔레포트 등에 사용")
	print()

	var nav_link := NavigationLink3D.new()
	nav_link.start_position = Vector3(-5, 0, 0)  # 시작점
	nav_link.end_position = Vector3(-5, 3, -3)    # 끝점
	nav_link.bidirectional = false               # 단방향 (위로만)
	add_child(nav_link)

	print("  NavigationLink3D 설정:")
	print("    start_position = %s" % str(nav_link.start_position))
	print("    end_position = %s" % str(nav_link.end_position))
	print("    bidirectional = %s" % str(nav_link.bidirectional))
	print()
	print("  활용:")
	print("    - 절벽 점프 (아래로 단방향)")
	print("    - 사다리 (양방향)")
	print("    - 포탈/텔레포트")
	print("    - 다리, 엘리베이터")
	print()

	print("  Link 도달 시 처리:")
	print("    nav_agent.link_reached.connect(func(details):")
	print("        var link_type = details[\"link\"].get_meta(\"type\")")
	print("        if link_type == \"jump\":")
	print("            play_jump_animation()")
	print("        elif link_type == \"ladder\":")
	print("            play_climb_animation())")
	print()

	# -----------------------------------------------------------------
	# 9) 네비게이션 레이어와 코스트
	# -----------------------------------------------------------------
	print("--- 9. 네비게이션 레이어 & 코스트 ---")

	print("  네비게이션 레이어:")
	print("    nav_region.navigation_layers = 1  # 비트마스크")
	print("    nav_agent.navigation_layers = 1   # 사용할 레이어")
	print("    # 예: 레이어 1 = 지상, 레이어 2 = 수중, 레이어 3 = 공중")
	print("    # 에이전트마다 다른 레이어 사용 가능")
	print()

	print("  이동 코스트:")
	print("    nav_region.enter_cost = 0.0   # 진입 비용")
	print("    nav_region.travel_cost = 1.0  # 이동 비용")
	print("    # 높은 코스트 = 에이전트가 가능하면 피함")
	print("    # 예: 늪지대 travel_cost = 3.0 (일반 1.0)")
	print()

	print("  코스트 활용 예시:")
	print("    var safe_region = NavigationRegion3D.new()")
	print("    safe_region.travel_cost = 1.0    # 안전한 길")
	print("    var danger_region = NavigationRegion3D.new()")
	print("    danger_region.travel_cost = 5.0  # 위험한 길 (회피 유도)")
	print()

	# -----------------------------------------------------------------
	# 10) 디버그 시각화
	# -----------------------------------------------------------------
	print("--- 10. 네비게이션 디버그 ---")

	print("  에디터 디버그:")
	print("    에디터 > Debug > Visible Navigation 체크")
	print("    이동 가능 영역이 파란색으로 표시됩니다")
	print()

	print("  런타임 디버그:")
	print("    프로젝트 설정 > Debug > Navigation")
	print("    enable_edge_connections_debug = true")
	print("    enable_agent_paths_debug = true")
	print()

	print("  경로 시각화 코드:")
	print("    func _draw_path():")
	print("        var path = nav_agent.get_current_navigation_path()")
	print("        for i in range(path.size() - 1):")
	print("            DebugDraw3D.draw_line(path[i], path[i+1], Color.YELLOW)")
	print()

	nav_ready = true
	print("=== 02-navigation-3d.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 장애물 추가 (StaticBody3D + 시각 메시)
func _add_obstacle(parent: Node, pos: Vector3, size: Vector3):
	var body := StaticBody3D.new()
	body.position = pos

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.3, 0.2)
	mesh.material_override = mat
	body.add_child(mesh)

	parent.add_child(body)


## 네비게이션 에이전트 생성
func _create_nav_agent(start: Vector3, target: Vector3, color: Color) -> Dictionary:
	var body := CharacterBody3D.new()
	body.position = start
	add_child(body)

	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.0
	collision.shape = capsule
	body.add_child(collision)

	var mesh := MeshInstance3D.new()
	var cap_mesh := CapsuleMesh.new()
	cap_mesh.radius = 0.3
	cap_mesh.height = 1.0
	mesh.mesh = cap_mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	body.add_child(mesh)

	var agent := NavigationAgent3D.new()
	agent.target_position = target
	agent.avoidance_enabled = true
	agent.radius = 0.4
	agent.max_speed = 3.0
	body.add_child(agent)

	return {"body": body, "agent": agent, "target": target}
