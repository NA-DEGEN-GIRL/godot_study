# Chapter 13 - 3D Basics
# 04-transform-rotation.gd - Transform3D, Basis, 회전
#
# 이 파일에서 배울 내용:
# - Transform3D 구조 (Basis + origin)
# - Basis 행렬과 좌표축
# - Euler 각도 vs Quaternion 회전
# - look_at, rotate, 각종 회전 메서드

extends Node3D

func _ready():
	print("=== Transform3D와 회전 (Transform & Rotation) ===\n")

	# ============================================
	# 1. Transform3D 구조
	# ============================================
	print("--- 1. Transform3D 구조 ---\n")

	# Transform3D = Basis(회전+스케일) + origin(위치)
	print("Transform3D = Basis + origin")
	print("  Basis:  3x3 행렬 (회전과 스케일 정보)")
	print("  origin: Vector3 (위치 정보)")
	print("")

	var t := Transform3D()
	print("기본 Transform3D (단위 행렬):")
	print("  basis.x = %s (X축 방향, 오른쪽)" % str(t.basis.x))
	print("  basis.y = %s (Y축 방향, 위쪽)" % str(t.basis.y))
	print("  basis.z = %s (Z축 방향, 뒤쪽)" % str(t.basis.z))
	print("  origin  = %s (위치)" % str(t.origin))
	print("")

	print("Node3D에서의 Transform:")
	print("  node.transform         -> 부모 기준 로컬 트랜스폼")
	print("  node.global_transform  -> 월드 기준 글로벌 트랜스폼")
	print("  node.position          -> transform.origin의 단축")
	print("  node.rotation          -> 라디안 Euler 각도")
	print("  node.rotation_degrees  -> 도 단위 Euler 각도")
	print("  node.scale             -> 스케일")

	# ============================================
	# 2. Basis 이해하기
	# ============================================
	print("\n--- 2. Basis 이해하기 ---\n")

	# Basis의 3개 벡터는 노드의 로컬 축 방향을 나타냄
	print("Basis = 노드의 로컬 좌표축:")
	print("  basis.x = 노드의 '오른쪽' 방향")
	print("  basis.y = 노드의 '위쪽' 방향")
	print("  basis.z = 노드의 '뒤쪽' 방향")
	print("  -basis.z = 노드의 '앞쪽' 방향!")
	print("")

	# 회전된 노드의 basis 예시
	var node := Node3D.new()
	add_child(node)
	node.rotation_degrees = Vector3(0, 45, 0)  # Y축으로 45도 회전

	print("Y축 45도 회전 후 basis:")
	print("  basis.x = %s (오른쪽이 대각선으로)" % str(node.transform.basis.x))
	print("  basis.y = %s (위는 변함 없음)" % str(node.transform.basis.y))
	print("  basis.z = %s (뒤쪽이 대각선으로)" % str(node.transform.basis.z))
	print("  -basis.z = %s (앞쪽 방향)" % str(-node.transform.basis.z))
	print("")

	# 방향 벡터 추출 (매우 자주 사용!)
	print("노드의 방향 벡터 추출 (실전에서 매우 중요!):")
	print("  # 노드가 바라보는 방향 (앞)")
	print("  var forward = -node.transform.basis.z")
	print("  # 또는")
	print("  var forward = -node.global_transform.basis.z")
	print("")
	print("  # 노드의 오른쪽 방향")
	print("  var right = node.transform.basis.x")
	print("")
	print("  # 노드의 위쪽 방향")
	print("  var up = node.transform.basis.y")

	# ============================================
	# 3. 위치 이동 (Translation)
	# ============================================
	print("\n--- 3. 위치 이동 ---\n")

	node.position = Vector3.ZERO  # 초기화

	# 절대 위치 설정
	node.position = Vector3(5, 0, 3)
	print("절대 위치: node.position = %s" % str(node.position))

	# 상대 이동 (글로벌 기준)
	node.position += Vector3(1, 0, 0)
	print("글로벌 이동: position += Vector3(1,0,0) -> %s" % str(node.position))

	# 로컬 기준 이동 (translate)
	node.position = Vector3.ZERO
	node.rotation_degrees = Vector3(0, 90, 0)  # 90도 회전
	node.translate(Vector3(0, 0, -5))  # 로컬 앞쪽으로 5

	print("")
	print("로컬 이동 (90도 회전 후):")
	print("  translate(Vector3(0,0,-5))  # 로컬 앞으로 5")
	print("  결과 position = %s" % str(node.position))
	print("  -> 90도 회전했으므로 '앞'은 X축 방향!")
	print("")

	# translate vs global_translate
	print("이동 메서드 비교:")
	print("  node.translate(offset)        -> 로컬 기준 이동")
	print("  node.global_translate(offset)  -> 월드 기준 이동")
	print("  node.position += offset       -> 부모 기준 이동")

	# ============================================
	# 4. Euler 각도 회전
	# ============================================
	print("\n--- 4. Euler 각도 회전 ---\n")

	node.rotation_degrees = Vector3.ZERO  # 초기화

	# rotation_degrees로 설정
	node.rotation_degrees = Vector3(30, 45, 0)
	print("Euler 각도 (도 단위):")
	print("  rotation_degrees = %s" % str(node.rotation_degrees))
	print("  X(Pitch): %.1f도 - 고개 끄덕임 (위아래)" % node.rotation_degrees.x)
	print("  Y(Yaw):   %.1f도 - 고개 돌림 (좌우)" % node.rotation_degrees.y)
	print("  Z(Roll):  %.1f도 - 고개 기울임 (좌우 기울기)" % node.rotation_degrees.z)
	print("")

	# rotation (라디안)
	print("라디안 vs 도:")
	print("  rotation         = %s (라디안)" % str(node.rotation))
	print("  rotation_degrees = %s (도)" % str(node.rotation_degrees))
	print("  deg_to_rad(90) = %.4f" % deg_to_rad(90))
	print("  rad_to_deg(PI) = %.1f" % rad_to_deg(PI))
	print("")

	# Euler 각도의 문제: 짐벌 락
	print("짐벌 락 (Gimbal Lock) 문제:")
	print("  X를 90도 회전하면 Y와 Z 회전이 같은 축이 됨!")
	print("  -> 3개 축이 독립적으로 동작하지 못함")
	print("  -> 부드러운 회전 보간이 불가능")
	print("  -> 해결책: Quaternion 사용!")

	# ============================================
	# 5. Quaternion (쿼터니언)
	# ============================================
	print("\n--- 5. Quaternion ---\n")

	# Quaternion 기본
	print("Quaternion이란?")
	print("  4D 숫자 (x, y, z, w)로 회전을 표현")
	print("  짐벌 락 문제 없음!")
	print("  부드러운 보간(slerp) 가능!")
	print("  Godot 내부적으로 Quaternion을 사용")
	print("")

	# Quaternion 생성 방법
	var q1 := Quaternion.IDENTITY                          # 회전 없음
	var q2 := Quaternion.from_euler(Vector3(0, PI/2, 0))  # Euler에서
	var q3 := Quaternion(Vector3.UP, deg_to_rad(45))      # 축-각도

	print("Quaternion 생성:")
	print("  IDENTITY = %s (회전 없음)" % str(q1))
	print("  from_euler(Vector3(0, PI/2, 0)) = %s (Y축 90도)" % str(q2))
	print("  Quaternion(Vector3.UP, 45도) = %s (Y축 45도)" % str(q3))
	print("")

	# Node3D에서 Quaternion 사용
	node.quaternion = q3
	print("노드에 Quaternion 적용:")
	print("  node.quaternion = %s" % str(node.quaternion))
	print("  -> rotation_degrees = %s" % str(node.rotation_degrees))
	print("")

	# Quaternion 보간 (slerp)
	var q_start := Quaternion.IDENTITY
	var q_end := Quaternion(Vector3.UP, deg_to_rad(180))

	print("Quaternion 보간 (slerp):")
	print("  시작: %s (0도)" % str(q_start))
	print("  끝:   %s (180도)" % str(q_end))
	for i in range(5):
		var t_val := i / 4.0
		var q_interp := q_start.slerp(q_end, t_val)
		var euler := q_interp.get_euler()
		print("  t=%.2f: Y축 = %.1f도" % [t_val, rad_to_deg(euler.y)])

	# ============================================
	# 6. rotate 메서드들
	# ============================================
	print("\n--- 6. rotate 메서드들 ---\n")

	node.rotation_degrees = Vector3.ZERO  # 초기화

	# rotate() - 로컬 축 기준 회전
	node.rotate(Vector3.UP, deg_to_rad(45))
	print("rotate(axis, angle):")
	print("  rotate(Vector3.UP, 45도) -> %s" % str(node.rotation_degrees))
	print("  로컬 축 기준으로 회전")
	print("")

	# rotate_x/y/z - 축별 회전
	node.rotation_degrees = Vector3.ZERO
	node.rotate_y(deg_to_rad(30))
	node.rotate_x(deg_to_rad(15))
	print("rotate_x/y/z(angle):")
	print("  rotate_y(30도) 후 rotate_x(15도)")
	print("  -> rotation_degrees = %s" % str(node.rotation_degrees))
	print("  -> 순서가 중요! (Y 먼저, X 나중)")
	print("")

	# rotate_object_local - 오브젝트 로컬 축 기준
	print("rotate_object_local(axis, angle):")
	print("  오브젝트의 현재 로컬 축 기준으로 회전")
	print("  이미 회전된 상태에서 추가 회전할 때 유용")
	print("")

	# global_rotate - 월드 축 기준 회전
	print("global_rotate(axis, angle):")
	print("  항상 월드 축 기준으로 회전")
	print("  -> 노드가 어떻게 회전되어 있든 월드 Y축 기준")

	# ============================================
	# 7. look_at (바라보기)
	# ============================================
	print("\n--- 7. look_at ---\n")

	# look_at - 특정 위치를 바라봄
	node.position = Vector3(0, 0, 0)
	var target_pos := Vector3(5, 2, -3)
	node.look_at(target_pos)

	print("look_at(target, up):")
	print("  node.look_at(%s)" % str(target_pos))
	print("  -> rotation = %s" % str(node.rotation_degrees))
	print("  -> 노드의 -Z축이 타겟을 향함")
	print("")

	# look_at with custom up vector
	node.look_at(target_pos, Vector3.UP)
	print("  look_at(target, Vector3.UP)")
	print("  -> 두 번째 인수는 '위' 방향 (기본 Y축)")
	print("  -> 경사면에서 캐릭터가 기울어지지 않도록!")
	print("")

	# 주의사항
	print("look_at 주의사항:")
	print("  - 타겟이 노드와 같은 위치면 오류!")
	print("  - 타겟이 정확히 위/아래면 이상하게 회전")
	print("  - 즉시 회전 (부드럽지 않음)")
	print("")

	# 부드러운 look_at
	print("부드러운 바라보기 (Smooth Look At):")
	print("""  func _process(delta):
      var target_pos = enemy.global_position
      var direction = (target_pos - global_position).normalized()
      var target_rotation = atan2(direction.x, direction.z)
      rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)""")

	# ============================================
	# 8. Transform3D 연산
	# ============================================
	print("\n--- 8. Transform3D 연산 ---\n")

	# Transform3D 직접 조작
	var custom_transform := Transform3D()

	# 위치 설정
	custom_transform.origin = Vector3(5, 0, 3)
	print("Transform3D 직접 조작:")
	print("  transform.origin = %s (위치)" % str(custom_transform.origin))
	print("")

	# Basis 회전
	var rotated_basis := Basis(Vector3.UP, deg_to_rad(45))
	custom_transform.basis = rotated_basis
	print("  Basis 회전 (Y축 45도):")
	print("  basis.x = %s" % str(custom_transform.basis.x))
	print("  basis.y = %s" % str(custom_transform.basis.y))
	print("  basis.z = %s" % str(custom_transform.basis.z))
	print("")

	# Transform3D 곱셈 (합성)
	var t1 := Transform3D(Basis(), Vector3(5, 0, 0))       # 위치만
	var t2 := Transform3D(Basis(Vector3.UP, PI/2), Vector3()) # 회전만

	var combined := t2 * t1  # t2를 먼저 적용한 후 t1
	print("Transform3D 합성 (곱셈):")
	print("  t1 = 위치(5,0,0)")
	print("  t2 = 회전(Y 90도)")
	print("  t2 * t1 -> origin = %s" % str(combined.origin))
	print("  -> 곱셈 순서에 따라 결과가 다름!")
	print("")

	# inverse - 역변환
	var inv := custom_transform.inverse()
	print("inverse() - 역변환:")
	print("  transform * transform.inverse() = 단위 행렬")
	print("  -> 월드 좌표를 로컬 좌표로 변환할 때 유용")

	# ============================================
	# 9. 좌표 변환 (Local <-> Global)
	# ============================================
	print("\n--- 9. 좌표 변환 ---\n")

	# to_local / to_global
	node.position = Vector3(10, 5, 0)
	node.rotation_degrees = Vector3(0, 90, 0)

	var world_point := Vector3(15, 5, 0)
	var local_point := node.to_local(world_point)
	var back_to_world := node.to_global(local_point)

	print("좌표 변환:")
	print("  노드 위치: %s, 회전: Y=90도" % str(node.position))
	print("  월드 점:  %s" % str(world_point))
	print("  to_local() = %s (노드 기준 로컬 좌표)" % str(local_point))
	print("  to_global() = %s (다시 월드 좌표로)" % str(back_to_world))
	print("")

	print("활용 예시:")
	print("  # 적이 내 앞에 있는지? (로컬 Z 확인)")
	print("  var local_enemy = to_local(enemy.position)")
	print("  if local_enemy.z < 0:  # 로컬 -Z = 앞")
	print("      print('적이 앞에 있다!')")

	# ============================================
	# 10. Basis 유용한 메서드
	# ============================================
	print("\n--- 10. Basis 유용한 메서드 ---\n")

	var basis := Basis(Vector3.UP, deg_to_rad(45))

	print("Basis 메서드:")
	print("  get_euler() = %s (Euler 각도)" % str(basis.get_euler()))
	print("  get_rotation_quaternion() = %s" % str(basis.get_rotation_quaternion()))
	print("  get_scale() = %s (스케일)" % str(basis.get_scale()))
	print("")

	# Basis로 벡터 변환
	var local_dir := Vector3(0, 0, -1)  # 로컬 앞 방향
	var world_dir := basis * local_dir

	print("Basis로 방향 변환:")
	print("  로컬 앞 방향: %s" % str(local_dir))
	print("  월드 방향: basis * local_dir = %s" % str(world_dir))
	print("  -> 로컬 방향을 월드 방향으로 변환!")
	print("")

	# 스케일 적용
	var scaled_basis := Basis.from_scale(Vector3(2, 1, 2))
	print("스케일 Basis:")
	print("  Basis.from_scale(Vector3(2,1,2)) -> X,Z 2배 크기")

	# ============================================
	# 11. 실전: 회전 패턴 모음
	# ============================================
	print("\n--- 11. 실전 회전 패턴 ---\n")

	# 오브젝트 주위를 도는 회전 (Orbit)
	print("1) 오브젝트 주위를 도는 카메라:")
	print("""  var orbit_speed: float = 1.0
  var orbit_radius: float = 10.0
  var orbit_angle: float = 0.0

  func _process(delta):
      orbit_angle += orbit_speed * delta
      position.x = target.position.x + cos(orbit_angle) * orbit_radius
      position.z = target.position.z + sin(orbit_angle) * orbit_radius
      look_at(target.position)""")
	print("")

	# Y축 회전 (터렛)
	print("2) Y축만 회전 (터렛/NPC 시선):")
	print("""  func look_at_flat(target_pos: Vector3):
      var direction = target_pos - global_position
      direction.y = 0  # 수평만
      if direction.length_squared() > 0.001:
          var angle = atan2(direction.x, direction.z)
          rotation.y = angle""")
	print("")

	# 부드러운 회전 보간
	print("3) 부드러운 Quaternion 보간:")
	print("""  func smooth_rotate_toward(target_pos: Vector3, delta: float):
      var direction = (target_pos - global_position).normalized()
      var target_basis = Basis.looking_at(direction)
      var target_quat = target_basis.get_rotation_quaternion()
      quaternion = quaternion.slerp(target_quat, 5.0 * delta)""")

	# ============================================
	# 12. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Transform3D = Basis(회전+스케일) + origin(위치)")
	print("2. Basis: 노드의 로컬 축 방향, -basis.z = 앞 방향")
	print("3. rotation_degrees: 도 단위 Euler 각도 (직관적)")
	print("4. Quaternion: 짐벌 락 없음, slerp 보간 가능")
	print("5. look_at(): 특정 위치를 바라봄 (즉시)")
	print("6. rotate()/rotate_y(): 축 기준 회전 (누적)")
	print("7. to_local()/to_global(): 좌표계 변환")
	print("8. 회전 순서 중요! X->Y->Z와 Z->Y->X는 다름")
