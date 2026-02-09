# Chapter 18 - 3D Animation
# 01-skeleton-basics.gd - Skeleton3D, BoneAttachment3D, 본 조작
#
# 이 파일에서 배울 내용:
# - Skeleton3D의 구조와 본(Bone) 계층
# - 코드에서 본 인덱스/이름으로 접근하기
# - 본 포즈(pose) 설정과 Transform 조작
# - BoneAttachment3D로 무기/장비 부착
# - 본 기반 절차적 애니메이션 기초

extends Node3D

func _ready():
	print("=== Chapter 18-1: Skeleton3D & Bone Manipulation ===\n")

	# -----------------------------------------------------------------
	# 1) Skeleton3D 기본 개념
	# -----------------------------------------------------------------
	print("--- 1. Skeleton3D 기본 개념 ---")

	print("  Skeleton3D는 3D 캐릭터의 뼈대(Armature)를 관리합니다")
	print("  Blender, Maya 등에서 만든 리그(Rig)를 Godot으로 가져옵니다")
	print()
	print("  계층 구조 예시:")
	print("    Root")
	print("    +-- Hips")
	print("        +-- Spine")
	print("        |   +-- Chest")
	print("        |       +-- Neck")
	print("        |       |   +-- Head")
	print("        |       +-- LeftShoulder")
	print("        |       |   +-- LeftUpperArm")
	print("        |       |       +-- LeftLowerArm")
	print("        |       |           +-- LeftHand")
	print("        |       +-- RightShoulder")
	print("        |           +-- RightUpperArm")
	print("        |               +-- RightLowerArm")
	print("        |                   +-- RightHand")
	print("        +-- LeftUpperLeg")
	print("        |   +-- LeftLowerLeg")
	print("        |       +-- LeftFoot")
	print("        +-- RightUpperLeg")
	print("            +-- RightLowerLeg")
	print("                +-- RightFoot")
	print()

	# -----------------------------------------------------------------
	# 2) 코드에서 Skeleton3D 생성
	# -----------------------------------------------------------------
	print("--- 2. 코드에서 Skeleton3D 생성 ---")

	# 간단한 스켈레톤 생성 (3개 본: Root -> Spine -> Head)
	var skeleton := Skeleton3D.new()
	add_child(skeleton)

	# 본 추가 (add_bone은 인덱스를 반환)
	var root_bone_idx := skeleton.add_bone("Root")
	var spine_bone_idx := skeleton.add_bone("Spine")
	var head_bone_idx := skeleton.add_bone("Head")
	var left_arm_idx := skeleton.add_bone("LeftArm")
	var right_arm_idx := skeleton.add_bone("RightArm")

	# 본 부모 설정 (계층 구조)
	skeleton.set_bone_parent(spine_bone_idx, root_bone_idx)
	skeleton.set_bone_parent(head_bone_idx, spine_bone_idx)
	skeleton.set_bone_parent(left_arm_idx, spine_bone_idx)
	skeleton.set_bone_parent(right_arm_idx, spine_bone_idx)

	print("  생성된 본 수: %d" % skeleton.get_bone_count())
	print("  본 목록:")
	for i in range(skeleton.get_bone_count()):
		var parent_idx := skeleton.get_bone_parent(i)
		var parent_name := "없음(루트)" if parent_idx == -1 else skeleton.get_bone_name(parent_idx)
		print("    [%d] %s (부모: %s)" % [i, skeleton.get_bone_name(i), parent_name])
	print()

	# -----------------------------------------------------------------
	# 3) 본 Rest 포즈 설정
	# -----------------------------------------------------------------
	print("--- 3. Rest 포즈 (기본 자세) ---")

	# Rest 포즈 = T-Pose 같은 기본 자세
	# 각 본의 로컬 Transform 설정
	var root_rest := Transform3D()
	root_rest.origin = Vector3(0, 0, 0)
	skeleton.set_bone_rest(root_bone_idx, root_rest)

	var spine_rest := Transform3D()
	spine_rest.origin = Vector3(0, 1.0, 0)  # 위로 1m
	skeleton.set_bone_rest(spine_bone_idx, spine_rest)

	var head_rest := Transform3D()
	head_rest.origin = Vector3(0, 0.5, 0)  # 위로 0.5m
	skeleton.set_bone_rest(head_bone_idx, head_rest)

	var left_arm_rest := Transform3D()
	left_arm_rest.origin = Vector3(-0.5, 0, 0)  # 왼쪽으로
	skeleton.set_bone_rest(left_arm_idx, left_arm_rest)

	var right_arm_rest := Transform3D()
	right_arm_rest.origin = Vector3(0.5, 0, 0)  # 오른쪽으로
	skeleton.set_bone_rest(right_arm_idx, right_arm_rest)

	print("  Rest 포즈 설정 완료")
	print("  Root: origin = (0, 0, 0)")
	print("  Spine: origin = (0, 1, 0) - Root에서 위로 1m")
	print("  Head: origin = (0, 0.5, 0) - Spine에서 위로 0.5m")
	print("  LeftArm: origin = (-0.5, 0, 0) - Spine에서 왼쪽")
	print("  RightArm: origin = (0.5, 0, 0) - Spine에서 오른쪽")
	print()

	# 글로벌 본 포즈 확인
	for i in range(skeleton.get_bone_count()):
		var global_pose := skeleton.get_bone_global_pose(i)
		print("  [%s] 글로벌 위치: %s" % [
			skeleton.get_bone_name(i),
			global_pose.origin
		])
	print()

	# -----------------------------------------------------------------
	# 4) 본 포즈 조작 (애니메이션)
	# -----------------------------------------------------------------
	print("--- 4. 본 포즈 조작 ---")

	# 본의 현재 포즈를 변경 (애니메이션 재생 없이)
	# set_bone_pose_position/rotation/scale 사용

	# 머리 회전
	skeleton.set_bone_pose_rotation(head_bone_idx,
		Quaternion.from_euler(Vector3(0, deg_to_rad(30), 0))  # Y축 30도
	)
	print("  Head 본 Y축 30도 회전")

	# 왼팔 들기
	skeleton.set_bone_pose_rotation(left_arm_idx,
		Quaternion.from_euler(Vector3(0, 0, deg_to_rad(-45)))  # Z축 -45도
	)
	print("  LeftArm 본 Z축 -45도 회전 (팔 들기)")

	# 포즈 읽기
	var head_rotation := skeleton.get_bone_pose_rotation(head_bone_idx)
	print("  Head 현재 회전: ", head_rotation)
	print("  Head 오일러 각도: ", head_rotation.get_euler())
	print()

	# Transform으로 직접 설정
	print("  포즈 설정 방법:")
	print("    1. set_bone_pose_position(idx, Vector3)  - 위치")
	print("    2. set_bone_pose_rotation(idx, Quaternion) - 회전")
	print("    3. set_bone_pose_scale(idx, Vector3)     - 스케일")
	print()
	print("  포즈 읽기 방법:")
	print("    1. get_bone_pose(idx)          - 전체 Transform3D")
	print("    2. get_bone_pose_position(idx) - 위치 Vector3")
	print("    3. get_bone_pose_rotation(idx) - 회전 Quaternion")
	print("    4. get_bone_global_pose(idx)   - 글로벌 Transform")
	print()

	# -----------------------------------------------------------------
	# 5) 본 이름/인덱스 검색
	# -----------------------------------------------------------------
	print("--- 5. 본 검색 ---")

	# 이름으로 인덱스 찾기
	var found_idx := skeleton.find_bone("Head")
	print("  find_bone(\"Head\") = %d" % found_idx)

	var not_found := skeleton.find_bone("Tail")
	print("  find_bone(\"Tail\") = %d (없으면 -1)" % not_found)

	# 인덱스로 이름 찾기
	var bone_name := skeleton.get_bone_name(0)
	print("  get_bone_name(0) = \"%s\"" % bone_name)
	print()

	# 자식 본 찾기
	var spine_children := skeleton.get_bone_children(spine_bone_idx)
	print("  Spine의 자식 본들:")
	for child_idx in spine_children:
		print("    - %s (idx: %d)" % [skeleton.get_bone_name(child_idx), child_idx])
	print()

	# -----------------------------------------------------------------
	# 6) BoneAttachment3D - 본에 오브젝트 부착
	# -----------------------------------------------------------------
	print("--- 6. BoneAttachment3D (장비 부착) ---")

	# BoneAttachment3D는 특정 본의 위치를 따라가는 노드입니다
	# 무기, 방패, 모자 등을 캐릭터 본에 부착할 때 사용

	var attachment := BoneAttachment3D.new()
	attachment.bone_name = "RightArm"   # 부착할 본 이름
	skeleton.add_child(attachment)

	# 부착된 노드에 무기(메시) 추가
	var weapon := MeshInstance3D.new()
	var weapon_mesh := BoxMesh.new()
	weapon_mesh.size = Vector3(0.1, 0.1, 0.8)  # 검 형태
	weapon.mesh = weapon_mesh
	weapon.position = Vector3(0, 0, -0.4)  # 손에서 앞으로
	var weapon_mat := StandardMaterial3D.new()
	weapon_mat.albedo_color = Color(0.7, 0.7, 0.75)
	weapon_mat.metallic = 0.9
	weapon_mat.roughness = 0.2
	weapon.material_override = weapon_mat
	attachment.add_child(weapon)

	print("  BoneAttachment3D 생성:")
	print("    bone_name = \"RightArm\"")
	print("    자식으로 무기 메시 추가")
	print("    -> 오른팔 본을 따라 무기가 이동/회전합니다")
	print()

	print("  BoneAttachment3D 활용:")
	print("    - 무기 장착/해제 (reparent)")
	print("    - 모자/헬멧 (Head 본)")
	print("    - 방패 (LeftArm 본)")
	print("    - 등에 짐 (Spine 본)")
	print("    - 파티클 효과 (특정 본 위치에)")
	print()

	# 무기 교체 예시
	print("  무기 교체 코드:")
	print("    # 기존 무기 제거")
	print("    var old_weapon = attachment.get_child(0)")
	print("    old_weapon.queue_free()")
	print("    # 새 무기 부착")
	print("    var new_weapon = preload(\"res://weapons/sword.tscn\").instantiate()")
	print("    attachment.add_child(new_weapon)")
	print()

	# -----------------------------------------------------------------
	# 7) 실제 캐릭터 모델에서의 사용
	# -----------------------------------------------------------------
	print("--- 7. 실제 캐릭터 모델에서 사용 ---")

	print("  GLTF/GLB 모델을 임포트하면:")
	print("    Node3D")
	print("    +-- Skeleton3D (자동 생성)")
	print("    |   +-- MeshInstance3D (스킨 메시)")
	print("    +-- AnimationPlayer (애니메이션)")
	print()

	print("  본 접근 코드:")
	print("    @onready var skeleton = $Character/Skeleton3D")
	print("    var head_idx = skeleton.find_bone(\"Head\")")
	print("    # 머리를 타겟 방향으로 회전")
	print("    func look_at_target(target: Vector3):")
	print("        var head_global = skeleton.get_bone_global_pose(head_idx)")
	print("        var dir = (target - head_global.origin).normalized()")
	print("        var rot = Quaternion(Vector3.FORWARD, dir)")
	print("        skeleton.set_bone_pose_rotation(head_idx, rot)")
	print()

	# -----------------------------------------------------------------
	# 8) 본 물리 시뮬레이션 (PhysicalBone3D)
	# -----------------------------------------------------------------
	print("--- 8. PhysicalBone3D (래그돌) ---")

	print("  PhysicalBone3D: 본에 물리 시뮬레이션 적용")
	print("  래그돌(Ragdoll) 효과를 위해 사용합니다")
	print()
	print("  설정 방법:")
	print("    1. Skeleton3D 선택")
	print("    2. 메뉴 > Create Physical Skeleton")
	print("    3. 각 PhysicalBone3D에 CollisionShape3D 설정")
	print("    4. Joint 타입 설정 (Pin, Hinge, Cone)")
	print()
	print("  코드에서 래그돌 활성화:")
	print("    # 활성화")
	print("    skeleton.physical_bones_start_simulation()")
	print("    # 특정 본만 활성화")
	print("    skeleton.physical_bones_start_simulation([\"LeftArm\", \"LeftLowerArm\"])")
	print("    # 비활성화")
	print("    skeleton.physical_bones_stop_simulation()")
	print()

	# -----------------------------------------------------------------
	# 9) 본 디버그 시각화
	# -----------------------------------------------------------------
	print("--- 9. 본 디버그 시각화 ---")

	# 각 본 위치에 작은 구 표시
	for i in range(skeleton.get_bone_count()):
		var bone_pos := skeleton.get_bone_global_pose(i).origin
		var debug_sphere := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.05
		sphere.height = 0.1
		debug_sphere.mesh = sphere
		var debug_mat := StandardMaterial3D.new()
		debug_mat.albedo_color = Color.YELLOW
		debug_mat.emission_enabled = true
		debug_mat.emission = Color.YELLOW
		debug_mat.emission_energy_multiplier = 2.0
		debug_sphere.material_override = debug_mat
		debug_sphere.position = bone_pos
		add_child(debug_sphere)

	print("  각 본 위치에 노란색 구 표시 완료")
	print("  에디터에서는 Skeleton3D 선택 시 본이 시각화됩니다")
	print()

	print("  프로젝트 설정 > Debug > Skeleton 옵션:")
	print("    - 본 축 표시")
	print("    - 본 이름 표시")
	print("    - 가중치 시각화")
	print()

	# -----------------------------------------------------------------
	# 10) 요약
	# -----------------------------------------------------------------
	print("--- 10. 요약 ---")

	print("  Skeleton3D 핵심:")
	print("    - add_bone() / get_bone_count() / find_bone()")
	print("    - set_bone_rest() / set_bone_pose_rotation()")
	print("    - get_bone_global_pose() / get_bone_pose()")
	print("  BoneAttachment3D:")
	print("    - bone_name으로 특정 본에 부착")
	print("    - 무기, 장비, 이펙트에 활용")
	print("  PhysicalBone3D:")
	print("    - 래그돌 물리 시뮬레이션")
	print("    - physical_bones_start/stop_simulation()")
	print()

	print("=== 01-skeleton-basics.gd 완료 ===")
