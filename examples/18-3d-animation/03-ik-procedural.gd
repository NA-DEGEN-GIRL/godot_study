# Chapter 18 - 3D Animation
# 03-ik-procedural.gd - SkeletonIK3D, 절차적 애니메이션, 스프링 시뮬레이션
#
# 이 파일에서 배울 내용:
# - Inverse Kinematics (IK) 개념과 SkeletonIK3D
# - Look-at (시선 추적) 절차적 애니메이션
# - 스프링 기반 부드러운 움직임 시뮬레이션
# - 호흡, 걷기 흔들림 등 절차적 모션
# - IK와 애니메이션 블렌딩

extends Node3D

# 스프링 시뮬레이션 변수
var spring_position := Vector3.ZERO
var spring_velocity := Vector3.ZERO

# 절차적 애니메이션 시간 추적
var time_elapsed := 0.0

func _ready():
	print("=== Chapter 18-3: IK & Procedural Animation ===\n")

	# -----------------------------------------------------------------
	# 1) IK (Inverse Kinematics) 개념
	# -----------------------------------------------------------------
	print("--- 1. IK 기본 개념 ---")

	print("  FK (Forward Kinematics): 부모 본에서 자식 본으로 전파")
	print("    어깨 회전 -> 팔꿈치 위치 결정 -> 손 위치 결정")
	print("    (원인 -> 결과)")
	print()
	print("  IK (Inverse Kinematics): 끝 위치에서 역으로 본 회전 계산")
	print("    손 위치 목표 -> 팔꿈치 각도 계산 -> 어깨 각도 계산")
	print("    (결과 -> 원인)")
	print()
	print("  IK 활용 사례:")
	print("    - 발이 지면에 정확히 닿기 (Foot IK)")
	print("    - 손으로 물건 잡기 (Hand IK)")
	print("    - 머리가 대상을 바라보기 (Look-at)")
	print("    - 무기 조준점 맞추기")
	print("    - 사다리 오르기")
	print()

	# -----------------------------------------------------------------
	# 2) SkeletonIK3D 설정
	# -----------------------------------------------------------------
	print("--- 2. SkeletonIK3D 설정 ---")

	# 스켈레톤 생성
	var skeleton := Skeleton3D.new()
	add_child(skeleton)

	# 팔 체인 생성: Shoulder -> UpperArm -> LowerArm -> Hand
	var shoulder_idx := skeleton.add_bone("Shoulder")
	var upper_arm_idx := skeleton.add_bone("UpperArm")
	var lower_arm_idx := skeleton.add_bone("LowerArm")
	var hand_idx := skeleton.add_bone("Hand")

	skeleton.set_bone_parent(upper_arm_idx, shoulder_idx)
	skeleton.set_bone_parent(lower_arm_idx, upper_arm_idx)
	skeleton.set_bone_parent(hand_idx, lower_arm_idx)

	# Rest 포즈 (팔 펴기)
	skeleton.set_bone_rest(shoulder_idx, Transform3D(Basis(), Vector3(0, 1.5, 0)))
	skeleton.set_bone_rest(upper_arm_idx, Transform3D(Basis(), Vector3(0.3, 0, 0)))
	skeleton.set_bone_rest(lower_arm_idx, Transform3D(Basis(), Vector3(0.3, 0, 0)))
	skeleton.set_bone_rest(hand_idx, Transform3D(Basis(), Vector3(0.2, 0, 0)))

	print("  팔 체인 생성: Shoulder -> UpperArm -> LowerArm -> Hand")
	print()

	print("  SkeletonIK3D 설정 코드:")
	print("    var ik = SkeletonIK3D.new()")
	print("    ik.root_bone = \"Shoulder\"     # IK 체인 시작 본")
	print("    ik.tip_bone = \"Hand\"           # IK 체인 끝 본 (타겟)")
	print("    ik.target_node = $TargetMarker # 타겟 노드 경로")
	print("    ik.use_magnet = true           # 중간 본 힌트")
	print("    ik.magnet = Vector3(0, 0, -1)  # 팔꿈치 방향 힌트")
	print("    skeleton.add_child(ik)")
	print("    ik.start()                     # IK 시작")
	print()

	print("  SkeletonIK3D 주요 속성:")
	print("    root_bone     - IK 체인의 시작 본")
	print("    tip_bone      - IK 체인의 끝 본 (타겟에 맞출 본)")
	print("    target_node   - 타겟 위치를 제공하는 Node3D")
	print("    target        - 직접 Transform3D 지정")
	print("    use_magnet    - 중간 관절 힌트 사용 여부")
	print("    magnet        - 팔꿈치/무릎 방향 힌트")
	print("    interpolation - IK 결과 블렌딩 (0=원본, 1=IK)")
	print("    max_iterations - 해석 반복 횟수 (정확도)")
	print()

	# -----------------------------------------------------------------
	# 3) Foot IK (발 IK)
	# -----------------------------------------------------------------
	print("--- 3. Foot IK 구현 ---")

	print("  발 IK: 경사면/계단에서 발이 지면에 정확히 닿도록")
	print()
	print("  구현 단계:")
	print("    1. 골반에서 아래로 RayCast (각 발 위치)")
	print("    2. 지면 높이 차이 계산")
	print("    3. IK 타겟을 지면 위치로 설정")
	print("    4. 골반 높이 보정")
	print()

	print("  코드 예시:")
	print("    func _update_foot_ik():")
	print("        # 왼발 레이캐스트")
	print("        var left_origin = skeleton.get_bone_global_pose(left_foot_idx).origin")
	print("        left_origin += global_position")
	print("        var left_hit = _raycast_down(left_origin)")
	print("        if left_hit:")
	print("            left_ik.target = Transform3D(Basis(), left_hit.position)")
	print()
	print("        # 오른발도 동일하게")
	print("        # 골반 높이 = min(left_offset, right_offset)")
	print("        var hip_offset = min(left_offset, right_offset)")
	print("        skeleton.set_bone_pose_position(hip_idx,")
	print("            Vector3(0, hip_offset, 0))")
	print()

	# -----------------------------------------------------------------
	# 4) Look-at (시선 추적) 절차적 애니메이션
	# -----------------------------------------------------------------
	print("--- 4. Look-at (시선 추적) ---")

	# Look-at 데모용 타겟
	var target_marker := MeshInstance3D.new()
	var target_mesh := SphereMesh.new()
	target_mesh.radius = 0.2
	target_marker.mesh = target_mesh
	var target_mat := StandardMaterial3D.new()
	target_mat.albedo_color = Color.RED
	target_marker.material_override = target_mat
	target_marker.position = Vector3(2, 2, -1)
	add_child(target_marker)

	print("  시선 추적: 머리/눈이 타겟을 바라보게 하기")
	print()
	print("  간단한 Look-at 구현:")
	print("    func _process(delta):")
	print("        var head_idx = skeleton.find_bone(\"Head\")")
	print("        var head_global = skeleton.get_bone_global_pose(head_idx)")
	print("        var target_local = skeleton.global_transform.inverse() * target_pos")
	print("        var dir = (target_local - head_global.origin).normalized()")
	print()
	print("        # 현재 회전에서 타겟 방향으로 부드럽게 보간")
	print("        var current_rot = skeleton.get_bone_pose_rotation(head_idx)")
	print("        var target_rot = Quaternion(Vector3.FORWARD, dir)")
	print("        var new_rot = current_rot.slerp(target_rot, delta * 5.0)")
	print("        skeleton.set_bone_pose_rotation(head_idx, new_rot)")
	print()

	# 각도 제한
	print("  각도 제한 (자연스러운 범위):")
	print("    var euler = new_rot.get_euler()")
	print("    euler.x = clamp(euler.x, deg_to_rad(-30), deg_to_rad(30))  # 상하")
	print("    euler.y = clamp(euler.y, deg_to_rad(-60), deg_to_rad(60))  # 좌우")
	print("    new_rot = Quaternion.from_euler(euler)")
	print()

	# -----------------------------------------------------------------
	# 5) 스프링 시뮬레이션
	# -----------------------------------------------------------------
	print("--- 5. 스프링 시뮬레이션 ---")

	print("  스프링 물리: 부드럽고 탄성 있는 움직임")
	print("  카메라 팔로우, 무기 흔들림, UI 애니메이션에 활용")
	print()

	# 스프링 파라미터
	var stiffness := 50.0  # 강성 (높을수록 빠르게 복원)
	var damping := 8.0     # 감쇠 (높을수록 빠르게 멈춤)
	var target := Vector3(5, 2, 0)

	# 스프링 시뮬레이션 (수동 스텝)
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var dt := 1.0 / 60.0

	print("  스프링 파라미터:")
	print("    stiffness = %.0f (강성)" % stiffness)
	print("    damping = %.0f (감쇠)" % damping)
	print("    target = %s" % str(target))
	print()

	print("  10 스텝 시뮬레이션:")
	for step in range(10):
		# 스프링 힘 계산
		var force := (target - pos) * stiffness  # 복원력
		force -= vel * damping                     # 감쇠력
		vel += force * dt
		pos += vel * dt
		if step % 2 == 0:
			print("    step %d: pos = (%.2f, %.2f, %.2f)" % [step, pos.x, pos.y, pos.z])
	print()

	print("  스프링 함수:")
	print("    func spring_update(current, target, velocity, stiffness, damping, dt):")
	print("        var force = (target - current) * stiffness")
	print("        force -= velocity * damping")
	print("        velocity += force * dt")
	print("        current += velocity * dt")
	print("        return [current, velocity]")
	print()

	# -----------------------------------------------------------------
	# 6) 절차적 호흡 애니메이션
	# -----------------------------------------------------------------
	print("--- 6. 절차적 호흡 ---")

	print("  호흡 효과: Spine/Chest 본에 미세한 움직임")
	print()
	print("  func _process(delta):")
	print("      time += delta")
	print("      var breath_scale = sin(time * 1.5) * 0.02  # 주기: ~4초")
	print("      # Chest 본 스케일로 호흡 표현")
	print("      skeleton.set_bone_pose_scale(chest_idx,")
	print("          Vector3(1.0 + breath_scale, 1.0 + breath_scale * 1.5, 1.0 + breath_scale))")
	print("      # Spine 미세 회전")
	print("      var breath_rot = sin(time * 1.5) * 0.01")
	print("      skeleton.set_bone_pose_rotation(spine_idx,")
	print("          Quaternion.from_euler(Vector3(breath_rot, 0, 0)))")
	print()

	# 호흡 값 계산 데모
	print("  호흡 사이클 값 (1초 간격):")
	for t in range(5):
		var breath := sin(float(t) * 1.5) * 0.02
		print("    t=%d: scale_offset = %.4f" % [t, breath])
	print()

	# -----------------------------------------------------------------
	# 7) 절차적 걷기 흔들림 (Head Bob)
	# -----------------------------------------------------------------
	print("--- 7. Head Bob (걷기 흔들림) ---")

	print("  1인칭 카메라의 걷기 흔들림:")
	print()
	print("  var bob_frequency := 2.0")
	print("  var bob_amplitude := 0.05")
	print("  var bob_time := 0.0")
	print()
	print("  func _process(delta):")
	print("      if is_moving:")
	print("          bob_time += delta * velocity.length()")
	print("          camera.position.y = default_y + sin(bob_time * bob_frequency) * bob_amplitude")
	print("          camera.position.x = cos(bob_time * bob_frequency * 0.5) * bob_amplitude * 0.5")
	print("      else:")
	print("          bob_time = 0.0")
	print("          camera.position.y = lerp(camera.position.y, default_y, delta * 10.0)")
	print()

	# Bob 값 시뮬레이션
	print("  헤드밥 시뮬레이션 (10프레임):")
	var bob_freq := 2.0
	var bob_amp := 0.05
	for frame in range(10):
		var t := float(frame) * 0.1
		var y := sin(t * bob_freq) * bob_amp
		var x := cos(t * bob_freq * 0.5) * bob_amp * 0.5
		print("    frame %d: offset = (%.4f, %.4f)" % [frame, x, y])
	print()

	# -----------------------------------------------------------------
	# 8) 절차적 무기 흔들림 (Weapon Sway)
	# -----------------------------------------------------------------
	print("--- 8. Weapon Sway (무기 흔들림) ---")

	print("  마우스 움직임에 따른 무기 흔들림:")
	print()
	print("  var sway_amount := 0.002")
	print("  var sway_speed := 10.0")
	print("  var target_sway := Vector2.ZERO")
	print("  var current_sway := Vector2.ZERO")
	print()
	print("  func _input(event):")
	print("      if event is InputEventMouseMotion:")
	print("          target_sway.x = -event.relative.x * sway_amount")
	print("          target_sway.y = -event.relative.y * sway_amount")
	print()
	print("  func _process(delta):")
	print("      # 스프링으로 부드럽게")
	print("      current_sway = current_sway.lerp(target_sway, delta * sway_speed)")
	print("      target_sway = target_sway.lerp(Vector2.ZERO, delta * 5.0)")
	print("      weapon.rotation.y = current_sway.x")
	print("      weapon.rotation.x = current_sway.y")
	print()

	# -----------------------------------------------------------------
	# 9) 다중 본 체인 절차적 애니메이션 (꼬리/촉수)
	# -----------------------------------------------------------------
	print("--- 9. 체인 애니메이션 (꼬리/촉수) ---")

	print("  다수의 본이 연결된 체인의 절차적 움직임:")
	print()
	print("  var tail_bones: Array[int] = []  # 꼬리 본 인덱스 배열")
	print("  var chain_rotations: Array[float] = []  # 각 본의 회전")
	print()
	print("  func _process(delta):")
	print("      var wave_offset = 0.0")
	print("      for i in range(tail_bones.size()):")
	print("          # 각 본에 파동 효과 (뒤로 갈수록 지연)")
	print("          var angle = sin(time * 3.0 + wave_offset) * 0.3")
	print("          wave_offset += 0.5  # 본 간 위상 차이")
	print()
	print("          # 이전 본의 움직임에 약간 지연되어 따라감")
	print("          chain_rotations[i] = lerp(chain_rotations[i], angle, delta * 8.0)")
	print("          skeleton.set_bone_pose_rotation(tail_bones[i],")
	print("              Quaternion.from_euler(Vector3(chain_rotations[i], 0, 0)))")
	print()

	# 파동 시뮬레이션
	print("  파동 시뮬레이션 (본 5개):")
	for bone_i in range(5):
		var angles := []
		for t in range(4):
			var angle := sin(float(t) * 3.0 + bone_i * 0.5) * 0.3
			angles.append("%.2f" % angle)
		print("    본[%d]: %s" % [bone_i, ", ".join(angles)])
	print()

	# -----------------------------------------------------------------
	# 10) IK와 애니메이션 블렌딩
	# -----------------------------------------------------------------
	print("--- 10. IK + 애니메이션 블렌딩 ---")

	print("  IK 결과와 기존 애니메이션을 블렌딩:")
	print()
	print("  var ik_blend := 0.0  # 0 = 애니메이션만, 1 = IK만")
	print()
	print("  func _process(delta):")
	print("      # IK 활성화 조건 (예: 물건 근처)")
	print("      if target_in_range:")
	print("          ik_blend = move_toward(ik_blend, 1.0, delta * 3.0)")
	print("      else:")
	print("          ik_blend = move_toward(ik_blend, 0.0, delta * 3.0)")
	print()
	print("      # 애니메이션 포즈와 IK 포즈를 블렌딩")
	print("      var anim_rot = get_animation_pose_rotation(hand_idx)")
	print("      var ik_rot = calculate_ik_rotation(hand_idx, target)")
	print("      var final_rot = anim_rot.slerp(ik_rot, ik_blend)")
	print("      skeleton.set_bone_pose_rotation(hand_idx, final_rot)")
	print()

	print("  SkeletonIK3D의 interpolation 속성:")
	print("    ik_node.interpolation = 0.0  # 원래 애니메이션")
	print("    ik_node.interpolation = 0.5  # 50%% 블렌딩")
	print("    ik_node.interpolation = 1.0  # 완전한 IK")
	print()

	print("=== 03-ik-procedural.gd 완료 ===")
