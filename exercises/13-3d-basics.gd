# 챕터 13: 3D 기초
#
# 이 챕터에서는 다음을 학습합니다:
# - Vector3 생성과 벡터 연산
# - MeshInstance3D로 3D 메시 설정
# - Camera3D 설정과 투영 방식
# - look_at()을 이용한 오브젝트 방향 전환
# - 3D 조명(Light3D) 생성과 속성
# - 3D 씬 구성 계층 이해

extends Node3D


# ============================================================
# 연습 1: Vector3 생성과 벡터 연산
# ============================================================
# 3D 공간에서의 좌표와 방향은 Vector3로 표현합니다.
# Godot은 Y-up 좌표계를 사용합니다 (Y축이 위쪽).
# Vector3는 x, y, z 세 개의 float 성분으로 구성됩니다.

# TODO: 3D 위치 벡터를 생성하세요 (x=3.0, y=5.0, z=-2.0)
var position_3d = null  # 여기를 수정하세요

# TODO: 3D 방향 벡터를 생성하세요 (앞쪽 방향: z축 음의 방향)
# Godot에서 앞쪽(forward)은 -Z 방향입니다
var forward_direction = null  # 여기를 수정하세요

func calculate_vector3_operations() -> Dictionary:
	# TODO: 두 벡터의 연산 결과를 Dictionary로 반환하세요
	var vec_a = Vector3(2.0, 3.0, 1.0)
	var vec_b = Vector3(1.0, -1.0, 4.0)

	# TODO: 아래 항목들을 계산하세요
	# - "addition": vec_a + vec_b
	# - "subtraction": vec_a - vec_b
	# - "dot_product": vec_a.dot(vec_b)  (내적)
	# - "cross_product": vec_a.cross(vec_b)  (외적)
	# - "distance": vec_a.distance_to(vec_b)
	# - "length_a": vec_a.length()
	# - "normalized_a": vec_a.normalized()
	# - "lerp_half": vec_a.lerp(vec_b, 0.5)  (중간 지점)
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 2: MeshInstance3D 메시 설정
# ============================================================
# MeshInstance3D는 3D 메시를 화면에 렌더링하는 노드입니다.
# BoxMesh, SphereMesh, CylinderMesh 등 기본 도형을 사용할 수 있습니다.

func create_mesh_config(mesh_type: String, size: Vector3) -> Dictionary:
	# TODO: 메시 유형별 설정 데이터를 Dictionary로 반환하세요
	# mesh_type: "box", "sphere", "cylinder", "capsule", "plane"
	#
	# 반환 형식:
	# {
	#   "node_type": "MeshInstance3D",
	#   "mesh_type": mesh_type,
	#   "mesh_class": 메시 클래스명 (예: "BoxMesh", "SphereMesh" 등),
	#   "size": size,
	#   "properties": 메시별 속성 Dictionary
	# }
	#
	# 메시별 속성:
	# - "box": {"width": size.x, "height": size.y, "depth": size.z}
	# - "sphere": {"radius": size.x / 2.0, "height": size.y}
	# - "cylinder": {"top_radius": size.x / 2.0, "bottom_radius": size.x / 2.0, "height": size.y}
	# - "capsule": {"radius": size.x / 2.0, "height": size.y}
	# - "plane": {"size": Vector2(size.x, size.z)}
	# - 그 외: 빈 Dictionary
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 3: Camera3D 설정
# ============================================================
# Camera3D는 3D 씬을 바라보는 카메라입니다.
# 투영 방식(Perspective/Orthogonal), FOV, 클리핑 등을 설정합니다.

func create_camera_config(projection_type: String) -> Dictionary:
	# TODO: Camera3D 설정을 Dictionary로 반환하세요
	# projection_type: "perspective" 또는 "orthogonal"
	#
	# 반환 형식:
	# {
	#   "node_type": "Camera3D",
	#   "projection": projection_type,
	#   "fov": 75.0 (perspective일 때만),
	#   "orthogonal_size": 10.0 (orthogonal일 때만),
	#   "near": 0.05,
	#   "far": 4000.0,
	#   "position": Vector3(0, 5, 10),
	#   "current": true
	# }
	#
	# TODO: projection_type이 "perspective"이면 "fov" 키를 포함하세요
	# TODO: projection_type이 "orthogonal"이면 "orthogonal_size" 키를 포함하세요
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 4: look_at 방향 전환 구현
# ============================================================
# look_at()은 오브젝트가 특정 위치를 바라보도록 회전시킵니다.
# 3D에서 방향 계산은 벡터 뺄셈과 정규화로 이루어집니다.

func calculate_look_at_direction(from_pos: Vector3, target_pos: Vector3) -> Dictionary:
	# TODO: from_pos에서 target_pos를 바라보는 방향 정보를 반환하세요
	#
	# 계산:
	# - "direction": (target_pos - from_pos).normalized()
	# - "distance": from_pos.distance_to(target_pos)
	# - "horizontal_direction": direction에서 y=0으로 만든 후 normalized()
	#   (수평 방향만, y축 무시)
	#   힌트: Vector3(direction.x, 0, direction.z).normalized()
	# - "is_above": target_pos.y > from_pos.y (타겟이 위에 있는지)
	# - "is_behind": direction.z > 0 (타겟이 뒤에 있는지, +Z가 뒤)
	#
	# 주의: direction이 Vector3.ZERO가 되면 (동일 위치) 기본값 반환
	# 기본값: {"direction": Vector3.ZERO, "distance": 0.0, ...}
	var result = {}  # 여기를 수정하세요
	return result


# ============================================================
# 연습 5: 3D 조명 생성
# ============================================================
# Godot 4에서 사용하는 주요 조명 유형:
# - DirectionalLight3D: 태양광 (방향만 있음, 위치 무관)
# - OmniLight3D: 점광원 (모든 방향으로 빛 발산)
# - SpotLight3D: 스포트라이트 (원뿔 형태)

func create_light_config(light_type: String) -> Dictionary:
	# TODO: 조명 유형별 설정을 Dictionary로 반환하세요
	# light_type: "directional", "omni", "spot"
	#
	# 공통 속성:
	# - "node_type": 노드 클래스명 (예: "DirectionalLight3D")
	# - "light_type": light_type
	# - "color": Color(1.0, 0.95, 0.9)  (따뜻한 백색)
	# - "energy": 1.0
	# - "shadow_enabled": true
	#
	# 유형별 추가 속성:
	# - "directional":
	#   "rotation_degrees": Vector3(-45, -30, 0)  (태양 각도)
	#   "directional_shadow_mode": "parallel_4_splits"
	#
	# - "omni":
	#   "position": Vector3(0, 3, 0)
	#   "omni_range": 10.0
	#   "omni_attenuation": 1.0
	#
	# - "spot":
	#   "position": Vector3(0, 5, 0)
	#   "rotation_degrees": Vector3(-90, 0, 0)  (아래를 향함)
	#   "spot_range": 15.0
	#   "spot_angle": 30.0
	#   "spot_attenuation": 1.0
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 6: 3D 씬 구성
# ============================================================
# 3D 씬의 노드 계층 구조를 설계합니다.
# 일반적인 3D 씬: 루트 -> 카메라, 조명, 메시, 물리 오브젝트

func design_3d_scene() -> Dictionary:
	# TODO: 간단한 3D 씬의 노드 트리를 Dictionary로 설계하세요
	#
	# 반환 형식:
	# {
	#   "root": {
	#     "type": "Node3D",
	#     "name": "World",
	#     "children": [
	#       {
	#         "type": "Camera3D",
	#         "name": "MainCamera",
	#         "position": Vector3(0, 5, 10),
	#         "rotation_degrees": Vector3(-20, 0, 0)
	#       },
	#       {
	#         "type": "DirectionalLight3D",
	#         "name": "Sun",
	#         "rotation_degrees": Vector3(-45, -30, 0)
	#       },
	#       {
	#         "type": "MeshInstance3D",
	#         "name": "Ground",
	#         "mesh": "PlaneMesh",
	#         "size": Vector2(20, 20),
	#         "position": Vector3(0, 0, 0)
	#       },
	#       {
	#         "type": "MeshInstance3D",
	#         "name": "Cube",
	#         "mesh": "BoxMesh",
	#         "position": Vector3(0, 0.5, 0)
	#       },
	#       {
	#         "type": "MeshInstance3D",
	#         "name": "Sphere",
	#         "mesh": "SphereMesh",
	#         "position": Vector3(3, 1, 0)
	#       }
	#     ]
	#   },
	#   "total_nodes": 6  (루트 포함 전체 노드 수)
	# }
	var scene = {}  # 여기를 수정하세요
	return scene


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 13: 3D 기초 ===")
	print("")

	# 테스트 1: Vector3 생성과 연산
	print("--- 연습 1: Vector3 생성과 연산 ---")
	print("결과 1-1 (3D 위치):", position_3d, " (기대값: (3, 5, -2))")
	print("결과 1-2 (앞쪽 방향):", forward_direction, " (기대값: (0, 0, -1))")
	var vec_ops = calculate_vector3_operations()
	print("결과 1-3 (벡터 연산):", vec_ops)
	if vec_ops.has("addition"):
		print("  덧셈:", vec_ops["addition"], " (기대값: (3, 2, 5))")
	if vec_ops.has("dot_product"):
		print("  내적:", vec_ops["dot_product"], " (기대값: 3)")
	if vec_ops.has("cross_product"):
		print("  외적:", vec_ops["cross_product"], " (기대값: (13, -7, -5))")
	print("")

	# 테스트 2: MeshInstance3D 설정
	print("--- 연습 2: MeshInstance3D 설정 ---")
	var box_config = create_mesh_config("box", Vector3(2, 1, 3))
	var sphere_config = create_mesh_config("sphere", Vector3(2, 2, 2))
	print("결과 2-1 (박스 메시):", box_config)
	print("결과 2-2 (구 메시):", sphere_config)
	print("")

	# 테스트 3: Camera3D 설정
	print("--- 연습 3: Camera3D 설정 ---")
	var persp_cam = create_camera_config("perspective")
	var ortho_cam = create_camera_config("orthogonal")
	print("결과 3-1 (원근 카메라):", persp_cam)
	print("결과 3-2 (직교 카메라):", ortho_cam)
	print("")

	# 테스트 4: look_at 방향
	print("--- 연습 4: look_at 방향 ---")
	var look1 = calculate_look_at_direction(Vector3(0, 1, 0), Vector3(0, 1, -10))
	var look2 = calculate_look_at_direction(Vector3(0, 0, 0), Vector3(5, 3, 0))
	var look3 = calculate_look_at_direction(Vector3(0, 0, 0), Vector3(0, 0, 0))
	print("결과 4-1 (앞쪽 바라보기):", look1)
	print("결과 4-2 (대각선 바라보기):", look2)
	print("결과 4-3 (동일 위치):", look3)
	print("")

	# 테스트 5: 조명 설정
	print("--- 연습 5: 조명 설정 ---")
	var dir_light = create_light_config("directional")
	var omni_light = create_light_config("omni")
	var spot_light = create_light_config("spot")
	print("결과 5-1 (방향광):", dir_light)
	print("결과 5-2 (점광원):", omni_light)
	print("결과 5-3 (스포트라이트):", spot_light)
	print("")

	# 테스트 6: 씬 구성
	print("--- 연습 6: 3D 씬 구성 ---")
	var scene = design_3d_scene()
	print("결과 6 (씬 구조):", scene)
	if scene.has("total_nodes"):
		print("결과 6 (총 노드 수):", scene["total_nodes"], " (기대값: 6)")
	if scene.has("root") and scene["root"] is Dictionary and scene["root"].has("children"):
		print("결과 6 (자식 노드 수):", scene["root"]["children"].size(), " (기대값: 5)")
	print("")

	print("=== 챕터 13 완료 ===")
