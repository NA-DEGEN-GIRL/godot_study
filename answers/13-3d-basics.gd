# 챕터 13: 3D 기초 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - Vector3와 3D 좌표계 (Y-up, 오른손 좌표계)
# - MeshInstance3D로 3D 메시 생성 및 배치
# - Camera3D 설정과 프로젝션 방식
# - look_at()으로 노드 방향 제어
# - 3D 조명 시스템 (DirectionalLight3D, OmniLight3D, SpotLight3D)
# - 기본 3D 씬 구성 (카메라 + 조명 + 오브젝트)

extends Node3D


func _ready():
	print("=== 챕터 13: 3D 기초 ===\n")

	# 연습 1: Vector3와 3D 좌표계
	_exercise_1_vector3_basics()

	# 연습 2: MeshInstance3D 메시 생성
	_exercise_2_mesh_instance()

	# 연습 3: Camera3D 설정
	_exercise_3_camera3d()

	# 연습 4: look_at() 방향 제어
	_exercise_4_look_at()

	# 연습 5: 3D 조명 시스템
	_exercise_5_lighting()

	# 연습 6: 기본 3D 씬 구성
	_exercise_6_scene_composition()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: Vector3 연산 (덧셈, 정규화, 거리, 내적, 외적) 완료")
	print("결과 2: MeshInstance3D 5종 (Box, Sphere, Cylinder, Capsule, Plane) 생성 완료")
	print("결과 3: Camera3D Perspective/Orthographic 설정 완료")
	print("결과 4: look_at()과 방향 벡터 변환 구현 완료")
	print("결과 5: 3종 조명 (Directional, Omni, Spot) 설정 완료")
	print("결과 6: 기본 3D 씬 (바닥 + 오브젝트 + 카메라 + 조명) 구성 완료")


# ==============================================================================
# 연습 1: Vector3와 3D 좌표계 - Vector3의 기본 연산과 Godot의
#          3D 좌표계(Y-up)를 이해하세요.
# ==============================================================================
func _exercise_1_vector3_basics():
	# 풀이: Godot 4는 Y-up 오른손 좌표계를 사용합니다.
	#       X = 오른쪽, Y = 위, Z = 카메라 쪽(앞이 -Z).
	#       Vector3는 3D 공간의 위치, 방향, 속도 등을 나타냅니다.
	#       normalized()는 길이 1의 방향 벡터를 반환하고,
	#       cross()는 두 벡터에 수직인 벡터를, dot()은 두 벡터의 유사도를 반환합니다.

	print("연습 1: Vector3와 3D 좌표계")

	# 기본 방향 상수
	print("  Godot 3D 좌표계 (Y-up, 오른손 법칙):")
	print("    Vector3.RIGHT  = %s (X+, 오른쪽)" % Vector3.RIGHT)
	print("    Vector3.LEFT   = %s (X-, 왼쪽)" % Vector3.LEFT)
	print("    Vector3.UP     = %s (Y+, 위)" % Vector3.UP)
	print("    Vector3.DOWN   = %s (Y-, 아래)" % Vector3.DOWN)
	print("    Vector3.FORWARD = %s (Z-, 앞)" % Vector3.FORWARD)
	print("    Vector3.BACK   = %s (Z+, 뒤)" % Vector3.BACK)
	print()

	# 벡터 생성과 기본 연산
	var pos_a := Vector3(3.0, 1.0, -2.0)
	var pos_b := Vector3(1.0, 4.0, 2.0)

	# 풀이: 벡터 덧셈은 각 성분을 더합니다.
	var sum := pos_a + pos_b
	print("  벡터 덧셈: %s + %s = %s" % [pos_a, pos_b, sum])

	# 풀이: 뺄셈으로 방향 벡터(A에서 B로의 방향)를 구합니다.
	var direction := pos_b - pos_a
	print("  방향 벡터 (A->B): %s" % direction)

	# 풀이: normalized()는 길이를 1로 만든 단위 벡터를 반환합니다.
	var dir_normalized := direction.normalized()
	print("  정규화: %s (길이: %.4f)" % [dir_normalized, dir_normalized.length()])

	# 풀이: distance_to()는 두 점 사이의 유클리드 거리를 반환합니다.
	var dist := pos_a.distance_to(pos_b)
	print("  거리: %.4f" % dist)

	# 풀이: distance_squared_to()는 제곱근 없이 거리의 제곱을 반환합니다 (성능 우수).
	var dist_sq := pos_a.distance_squared_to(pos_b)
	print("  거리 제곱: %.4f (비교용, sqrt 생략)" % dist_sq)
	print()

	# 내적 (Dot Product)
	# 풀이: dot()은 두 벡터의 유사도를 반환합니다.
	#       같은 방향이면 양수, 직각이면 0, 반대 방향이면 음수입니다.
	#       시야 판단(적이 앞에 있는지)에 자주 사용합니다.
	var forward := Vector3.FORWARD  # (0, 0, -1)
	var to_enemy := Vector3(0, 0, -5).normalized()
	var dot_result := forward.dot(to_enemy)
	print("  내적 (Dot Product):")
	print("    forward.dot(앞쪽 적): %.2f (양수 = 앞에 있음)" % dot_result)

	var behind := Vector3(0, 0, 5).normalized()
	print("    forward.dot(뒤쪽 적): %.2f (음수 = 뒤에 있음)" % forward.dot(behind))

	var side := Vector3(5, 0, 0).normalized()
	print("    forward.dot(옆쪽 적): %.2f (0 = 직각)" % forward.dot(side))
	print()

	# 외적 (Cross Product)
	# 풀이: cross()는 두 벡터에 수직인 벡터를 반환합니다.
	#       법선 벡터 계산, 회전축 결정에 사용합니다.
	var right := Vector3.RIGHT
	var up := Vector3.UP
	var cross_result := right.cross(up)
	print("  외적 (Cross Product):")
	print("    RIGHT x UP = %s (BACK 방향)" % cross_result)
	print("    UP x RIGHT = %s (FORWARD 방향)" % up.cross(right))
	print()

	# 선형 보간 (Lerp)
	# 풀이: lerp()는 두 벡터 사이를 비율(0~1)로 보간합니다.
	#       부드러운 이동, 카메라 추적 등에 사용합니다.
	var start := Vector3(0, 0, 0)
	var end := Vector3(10, 5, -3)
	print("  선형 보간 (Lerp):")
	print("    lerp(0.0): %s" % start.lerp(end, 0.0))
	print("    lerp(0.5): %s" % start.lerp(end, 0.5))
	print("    lerp(1.0): %s" % start.lerp(end, 1.0))

	# 각도와 회전
	# 풀이: angle_to()는 두 벡터 사이의 라디안 각도를 반환합니다.
	var angle := Vector3.FORWARD.angle_to(Vector3.RIGHT)
	print("  FORWARD와 RIGHT 사이 각도: %.4f rad (%.1f도)" % [angle, rad_to_deg(angle)])

	print("연습 1 완료: Vector3와 3D 좌표계\n")


# ==============================================================================
# 연습 2: MeshInstance3D - 코드로 다양한 3D 메시를 생성하고
#          위치/회전/스케일을 설정하세요.
# ==============================================================================
func _exercise_2_mesh_instance():
	# 풀이: MeshInstance3D는 3D 메시를 렌더링하는 노드입니다.
	#       mesh 속성에 BoxMesh, SphereMesh, CylinderMesh 등의
	#       프리미티브 메시 리소스를 할당합니다.
	#       position, rotation, scale 속성으로 변환을 적용합니다.
	#       rotation은 라디안 단위이므로 deg_to_rad()로 변환합니다.

	print("연습 2: MeshInstance3D 메시 생성")

	# 1) BoxMesh - 상자
	var box_instance := MeshInstance3D.new()
	box_instance.name = "Box"
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(2.0, 1.0, 1.5)
	box_instance.mesh = box_mesh
	box_instance.position = Vector3(0, 0.5, 0)
	add_child(box_instance)
	print("  Box: size=%s, pos=%s" % [box_mesh.size, box_instance.position])

	# 2) SphereMesh - 구
	var sphere_instance := MeshInstance3D.new()
	sphere_instance.name = "Sphere"
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16
	sphere_instance.mesh = sphere_mesh
	sphere_instance.position = Vector3(3, 0.5, 0)
	add_child(sphere_instance)
	print("  Sphere: radius=%.1f, height=%.1f, pos=%s" % [
		sphere_mesh.radius, sphere_mesh.height, sphere_instance.position
	])

	# 3) CylinderMesh - 원통
	var cylinder_instance := MeshInstance3D.new()
	cylinder_instance.name = "Cylinder"
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = 0.5
	cylinder_mesh.bottom_radius = 0.5
	cylinder_mesh.height = 2.0
	cylinder_instance.mesh = cylinder_mesh
	cylinder_instance.position = Vector3(-3, 1.0, 0)
	add_child(cylinder_instance)
	print("  Cylinder: top_r=%.1f, bot_r=%.1f, h=%.1f, pos=%s" % [
		cylinder_mesh.top_radius, cylinder_mesh.bottom_radius,
		cylinder_mesh.height, cylinder_instance.position
	])

	# 4) CapsuleMesh - 캡슐
	var capsule_instance := MeshInstance3D.new()
	capsule_instance.name = "Capsule"
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.5
	capsule_instance.mesh = capsule_mesh
	capsule_instance.position = Vector3(0, 0.75, -3)
	add_child(capsule_instance)
	print("  Capsule: radius=%.1f, height=%.1f, pos=%s" % [
		capsule_mesh.radius, capsule_mesh.height, capsule_instance.position
	])

	# 5) PlaneMesh - 평면 (바닥)
	var plane_instance := MeshInstance3D.new()
	plane_instance.name = "Floor"
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(20, 20)
	plane_instance.mesh = plane_mesh
	plane_instance.position = Vector3.ZERO
	add_child(plane_instance)
	print("  Plane: size=%s, pos=%s" % [plane_mesh.size, plane_instance.position])
	print()

	# 회전과 스케일
	# 풀이: rotation 속성은 라디안 단위의 오일러 각도(X, Y, Z)입니다.
	#       deg_to_rad()로 도를 라디안으로 변환합니다.
	#       rotate_y(), rotate_x(), rotate_z()로 축별 회전도 가능합니다.
	box_instance.rotation.y = deg_to_rad(45)
	print("  Box 회전: Y축 45도 = %.4f rad" % box_instance.rotation.y)

	cylinder_instance.scale = Vector3(1.0, 1.5, 1.0)
	print("  Cylinder 스케일: %s (Y축 1.5배 늘림)" % cylinder_instance.scale)
	print()

	# Transform3D 직접 제어
	# 풀이: global_transform은 월드 좌표 기준, transform은 로컬 좌표 기준입니다.
	#       basis는 회전+스케일 행렬, origin은 위치입니다.
	var t := box_instance.global_transform
	print("  Box Transform3D:")
	print("    origin (위치): %s" % t.origin)
	print("    basis.x (X축): %s" % t.basis.x)
	print("    basis.y (Y축): %s" % t.basis.y)
	print("    basis.z (Z축): %s" % t.basis.z)

	print("연습 2 완료: MeshInstance3D 5종 메시 생성\n")


# ==============================================================================
# 연습 3: Camera3D - 카메라 노드를 생성하고 Perspective와
#          Orthographic 프로젝션을 설정하세요.
# ==============================================================================
func _exercise_3_camera3d():
	# 풀이: Camera3D는 3D 씬의 시점을 정의합니다.
	#       projection = PROJECTION_PERSPECTIVE (원근 투영)는 가까운 물체가 크게 보이고,
	#       PROJECTION_ORTHOGONAL (직교 투영)는 거리에 상관없이 같은 크기로 보입니다.
	#       fov(시야각)는 Perspective에서, size는 Orthographic에서 사용합니다.
	#       near/far는 렌더링 범위를 결정합니다.

	print("연습 3: Camera3D 설정")

	# Perspective 카메라 (원근 투영 - 일반 3D 게임)
	var persp_cam := Camera3D.new()
	persp_cam.name = "PerspectiveCamera"
	persp_cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	persp_cam.fov = 75.0                    # 시야각 (기본 75도)
	persp_cam.near = 0.05                   # 최소 렌더 거리
	persp_cam.far = 1000.0                  # 최대 렌더 거리
	persp_cam.position = Vector3(0, 5, 10)  # 위에서 약간 뒤에서 봄
	persp_cam.rotation.x = deg_to_rad(-25)  # 아래를 바라봄
	add_child(persp_cam)

	print("  Perspective Camera:")
	print("    fov: %.0f도 (시야각)" % persp_cam.fov)
	print("    near: %.2f, far: %.0f (렌더 범위)" % [persp_cam.near, persp_cam.far])
	print("    position: %s" % persp_cam.position)
	print("    rotation: (%.1f, %.1f, %.1f)도" % [
		rad_to_deg(persp_cam.rotation.x),
		rad_to_deg(persp_cam.rotation.y),
		rad_to_deg(persp_cam.rotation.z)
	])
	print()

	# Orthographic 카메라 (직교 투영 - 전략/퍼즐 게임)
	var ortho_cam := Camera3D.new()
	ortho_cam.name = "OrthographicCamera"
	ortho_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	ortho_cam.size = 10.0                   # 직교 뷰 크기 (세로 미터)
	ortho_cam.near = 0.05
	ortho_cam.far = 500.0
	ortho_cam.position = Vector3(0, 10, 10)
	ortho_cam.rotation.x = deg_to_rad(-45)
	add_child(ortho_cam)

	print("  Orthographic Camera:")
	print("    size: %.0f (직교 뷰 크기)" % ortho_cam.size)
	print("    near: %.2f, far: %.0f" % [ortho_cam.near, ortho_cam.far])
	print("    position: %s" % ortho_cam.position)
	print()

	# 카메라 전환
	# 풀이: current = true로 활성 카메라를 전환합니다. 씬에서 하나만 활성화 가능합니다.
	persp_cam.current = true
	print("  활성 카메라: %s (current = true)" % persp_cam.name)
	print()

	# FOV 비교
	print("  FOV(시야각) 비교:")
	print("    60도: 좁은 시야, 망원 효과")
	print("    75도: 기본값, 자연스러운 시야")
	print("    90도: 넓은 시야, FPS 게임에 적합")
	print("    120도: 매우 넓은 시야, 어안 효과")

	print("연습 3 완료: Camera3D 설정\n")


# ==============================================================================
# 연습 4: look_at() - 노드가 특정 대상을 바라보도록 방향을 설정하세요.
#          전방 벡터(-Z)와 방향 벡터 변환도 이해하세요.
# ==============================================================================
func _exercise_4_look_at():
	# 풀이: look_at(target, up)은 노드의 -Z축(전방)이 target을 향하도록 회전합니다.
	#       up 벡터(기본 Vector3.UP)는 노드의 상단 방향을 결정합니다.
	#       -transform.basis.z는 노드의 전방 방향 벡터를 나타냅니다.
	#       이는 카메라가 대상을 추적하거나, 적이 플레이어를 바라볼 때 사용합니다.

	print("연습 4: look_at() 방향 제어")

	# 테스트용 노드 생성
	var watcher := Node3D.new()
	watcher.name = "Watcher"
	watcher.position = Vector3(0, 1, 5)
	add_child(watcher)

	var target_pos := Vector3(3, 0, -2)

	# look_at 적용
	# 풀이: look_at()은 노드의 전방(-Z)이 대상을 향하도록 회전을 설정합니다.
	watcher.look_at(target_pos, Vector3.UP)

	print("  Watcher 위치: %s" % watcher.position)
	print("  Target 위치: %s" % target_pos)
	print("  look_at() 후 rotation: (%.2f, %.2f, %.2f) rad" % [
		watcher.rotation.x, watcher.rotation.y, watcher.rotation.z
	])
	print("  look_at() 후 rotation: (%.1f, %.1f, %.1f) 도" % [
		rad_to_deg(watcher.rotation.x),
		rad_to_deg(watcher.rotation.y),
		rad_to_deg(watcher.rotation.z)
	])
	print()

	# 방향 벡터 추출
	# 풀이: basis의 각 열은 로컬 축의 월드 방향을 나타냅니다.
	#       -basis.z = 전방, basis.x = 오른쪽, basis.y = 위쪽
	var forward_dir := -watcher.global_transform.basis.z
	var right_dir := watcher.global_transform.basis.x
	var up_dir := watcher.global_transform.basis.y

	print("  방향 벡터 추출:")
	print("    전방 (-Z): %s" % forward_dir)
	print("    오른쪽 (X): %s" % right_dir)
	print("    위쪽 (Y): %s" % up_dir)
	print()

	# 두 위치 사이의 방향 계산
	# 풀이: (target - origin).normalized()로 방향 벡터를 구합니다.
	var direction_to_target := (target_pos - watcher.position).normalized()
	print("  직접 계산한 방향: %s" % direction_to_target)
	print("  look_at의 전방:  %s" % forward_dir)
	print("  두 벡터가 유사함: %.6f (1에 가까울수록 동일)" % forward_dir.dot(direction_to_target))
	print()

	# 여러 대상을 순회하며 look_at
	var targets := [
		Vector3(5, 0, 0),
		Vector3(-5, 2, -3),
		Vector3(0, 10, 0),
	]
	print("  여러 대상에 look_at 적용:")
	for t in targets:
		watcher.look_at(t, Vector3.UP)
		var fwd := -watcher.global_transform.basis.z
		print("    target=%s -> forward=%s" % [t, fwd])

	print("연습 4 완료: look_at() 방향 제어\n")


# ==============================================================================
# 연습 5: 3D 조명 - DirectionalLight3D, OmniLight3D, SpotLight3D를
#          생성하고 속성을 설정하세요.
# ==============================================================================
func _exercise_5_lighting():
	# 풀이: 3D 조명에는 3가지 주요 타입이 있습니다.
	#       DirectionalLight3D: 태양광처럼 평행 광선 (위치 무관, 방향만 중요)
	#       OmniLight3D: 전구처럼 한 점에서 모든 방향으로 퍼지는 빛
	#       SpotLight3D: 스포트라이트처럼 원뿔 형태로 퍼지는 빛
	#       shadow_enabled = true로 그림자를 활성화합니다.

	print("연습 5: 3D 조명 시스템")

	# 1) DirectionalLight3D - 태양광
	var dir_light := DirectionalLight3D.new()
	dir_light.name = "SunLight"
	dir_light.rotation.x = deg_to_rad(-45)     # 45도 아래를 비춤
	dir_light.rotation.y = deg_to_rad(-30)      # 약간 옆에서
	dir_light.light_color = Color(1.0, 0.95, 0.9)  # 따뜻한 흰색
	dir_light.light_energy = 1.2                # 밝기
	dir_light.shadow_enabled = true             # 그림자 활성화
	add_child(dir_light)

	print("  1) DirectionalLight3D (태양광):")
	print("    rotation: (%.0f, %.0f, 0)도" % [
		rad_to_deg(dir_light.rotation.x), rad_to_deg(dir_light.rotation.y)
	])
	print("    color: %s" % dir_light.light_color)
	print("    energy: %.1f" % dir_light.light_energy)
	print("    shadow: %s" % dir_light.shadow_enabled)
	print()

	# 2) OmniLight3D - 점광원 (전구, 횃불)
	var omni_light := OmniLight3D.new()
	omni_light.name = "TorchLight"
	omni_light.position = Vector3(2, 3, 0)
	omni_light.light_color = Color(1.0, 0.7, 0.3)  # 따뜻한 주황색
	omni_light.light_energy = 3.0
	omni_light.omni_range = 8.0                 # 빛이 닿는 범위
	omni_light.omni_attenuation = 1.0           # 감쇠 곡선 (1.0 = 선형)
	omni_light.shadow_enabled = true
	add_child(omni_light)

	print("  2) OmniLight3D (점광원):")
	print("    position: %s" % omni_light.position)
	print("    color: %s" % omni_light.light_color)
	print("    energy: %.1f" % omni_light.light_energy)
	print("    range: %.1f" % omni_light.omni_range)
	print("    attenuation: %.1f" % omni_light.omni_attenuation)
	print()

	# 3) SpotLight3D - 스포트라이트
	var spot_light := SpotLight3D.new()
	spot_light.name = "SpotLight"
	spot_light.position = Vector3(-2, 5, 2)
	spot_light.rotation.x = deg_to_rad(-60)         # 아래를 비춤
	spot_light.light_color = Color(0.8, 0.9, 1.0)   # 차가운 흰색
	spot_light.light_energy = 5.0
	spot_light.spot_range = 12.0                 # 빛 도달 거리
	spot_light.spot_angle = 30.0                 # 원뿔 반각 (도)
	spot_light.spot_angle_attenuation = 0.8
	spot_light.shadow_enabled = true
	add_child(spot_light)

	print("  3) SpotLight3D (스포트라이트):")
	print("    position: %s" % spot_light.position)
	print("    color: %s" % spot_light.light_color)
	print("    energy: %.1f" % spot_light.light_energy)
	print("    range: %.1f" % spot_light.spot_range)
	print("    angle: %.0f도" % spot_light.spot_angle)
	print()

	# 조명 타입 비교
	print("  조명 타입 비교:")
	print("    +------------------+----------+----------+-----------+")
	print("    | 속성             | Direction| Omni     | Spot      |")
	print("    +------------------+----------+----------+-----------+")
	print("    | 위치 영향        | X        | O        | O         |")
	print("    | 방향 영향        | O        | X        | O         |")
	print("    | 범위 제한        | 무한     | range    | range     |")
	print("    | 형태             | 평행     | 구형     | 원뿔      |")
	print("    | 용도             | 태양     | 전구     | 손전등    |")
	print("    +------------------+----------+----------+-----------+")

	print("연습 5 완료: 3D 조명 시스템\n")


# ==============================================================================
# 연습 6: 기본 3D 씬 구성 - 바닥, 오브젝트, 카메라, 조명을 조합하여
#          완전한 3D 씬을 코드로 구성하세요.
# ==============================================================================
func _exercise_6_scene_composition():
	# 풀이: 기본 3D 씬에는 최소 4가지 요소가 필요합니다.
	#       1) Camera3D: 시점 (없으면 아무것도 보이지 않음)
	#       2) Light3D: 조명 (없으면 검은 화면)
	#       3) MeshInstance3D: 볼 수 있는 오브젝트
	#       4) 바닥/환경: 공간감을 주는 요소
	#       각 요소에 적절한 머티리얼을 할당하면 시각적으로 구분됩니다.

	print("연습 6: 기본 3D 씬 구성")

	# 씬 루트
	var scene_root := Node3D.new()
	scene_root.name = "CompleteScene"
	add_child(scene_root)

	# 바닥 (초록색)
	var floor_mesh := MeshInstance3D.new()
	floor_mesh.name = "Ground"
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.3, 0.5, 0.2)  # 풀 색상
	floor_mesh.material_override = floor_mat
	scene_root.add_child(floor_mesh)
	print("  바닥 생성: 30x30, 초록색")

	# 오브젝트 배치
	# 풀이: 여러 오브젝트를 배열로 정의하고 반복문으로 생성하면 효율적입니다.
	var objects_data := [
		{"name": "RedBox", "type": "box", "pos": Vector3(0, 0.5, 0),
		 "color": Color.RED, "size": Vector3(1, 1, 1)},
		{"name": "BlueSphere", "type": "sphere", "pos": Vector3(3, 0.75, -2),
		 "color": Color.CORNFLOWER_BLUE, "radius": 0.75},
		{"name": "YellowCylinder", "type": "cylinder", "pos": Vector3(-2, 1, 1),
		 "color": Color.YELLOW, "height": 2.0},
	]

	for data in objects_data:
		var instance := MeshInstance3D.new()
		instance.name = data["name"]
		instance.position = data["pos"]

		match data["type"]:
			"box":
				var m := BoxMesh.new()
				m.size = data["size"]
				instance.mesh = m
			"sphere":
				var m := SphereMesh.new()
				m.radius = data["radius"]
				m.height = data["radius"] * 2.0
				instance.mesh = m
			"cylinder":
				var m := CylinderMesh.new()
				m.height = data["height"]
				instance.mesh = m

		var mat := StandardMaterial3D.new()
		mat.albedo_color = data["color"]
		instance.material_override = mat
		scene_root.add_child(instance)
		print("  %s 생성: type=%s, pos=%s, color=%s" % [
			data["name"], data["type"], data["pos"], data["color"]
		])

	# 카메라
	var cam := Camera3D.new()
	cam.name = "MainCamera"
	cam.position = Vector3(0, 5, 8)
	cam.rotation.x = deg_to_rad(-30)
	cam.fov = 70.0
	cam.current = true
	scene_root.add_child(cam)
	print("  카메라 배치: pos=%s, fov=%.0f" % [cam.position, cam.fov])

	# 태양광
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation = Vector3(deg_to_rad(-50), deg_to_rad(-30), 0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	scene_root.add_child(sun)
	print("  태양광 배치: energy=%.1f, shadow=%s" % [sun.light_energy, sun.shadow_enabled])
	print()

	# 씬 트리 출력
	print("  씬 트리 구조:")
	print("    CompleteScene (Node3D)")
	print("    +-- Ground (MeshInstance3D / PlaneMesh)")
	print("    +-- RedBox (MeshInstance3D / BoxMesh)")
	print("    +-- BlueSphere (MeshInstance3D / SphereMesh)")
	print("    +-- YellowCylinder (MeshInstance3D / CylinderMesh)")
	print("    +-- MainCamera (Camera3D)")
	print("    +-- Sun (DirectionalLight3D)")

	print("연습 6 완료: 기본 3D 씬 구성\n")
