# Chapter 13 - 3D Basics
# 01-3d-coordinates.gd - 3D 좌표계와 벡터
#
# 이 파일에서 배울 내용:
# - Godot의 3D 좌표계 (Y-up, 오른손 법칙)
# - Vector3 생성, 연산, 정규화
# - 방향 벡터와 거리 계산
# - 벡터의 내적(dot)과 외적(cross) 활용

extends Node3D

func _ready():
	print("=== 3D 좌표계와 벡터 (3D Coordinates & Vectors) ===\n")

	# ============================================
	# 1. Godot 3D 좌표계
	# ============================================
	print("--- 1. Godot 3D 좌표계 ---\n")

	# Godot는 Y-up 오른손 좌표계를 사용합니다
	# X축: 오른쪽 (+) / 왼쪽 (-)
	# Y축: 위 (+) / 아래 (-)
	# Z축: 화면 앞쪽(카메라 쪽) (+) / 화면 안쪽 (-)
	print("Godot 3D 좌표계: Y-up 오른손 법칙")
	print("  X축: 오른쪽(+) <-> 왼쪽(-)")
	print("  Y축: 위(+) <-> 아래(-)")
	print("  Z축: 카메라 쪽(+) <-> 화면 안쪽(-)")
	print("")

	# 오른손 법칙 설명
	print("오른손 법칙:")
	print("  오른손을 펴고:")
	print("  - 엄지 = X축 (오른쪽)")
	print("  - 검지 = Y축 (위)")
	print("  - 중지 = Z축 (카메라 쪽)")
	print("  -> 엄지를 X, 검지를 Y로 향하면 중지가 Z 방향")
	print("")

	# 다른 엔진과의 차이
	print("다른 엔진과 비교:")
	print("  Godot:  Y-up, 오른손 (Z+ = 카메라 쪽)")
	print("  Unity:  Y-up, 왼손  (Z+ = 화면 안쪽)")
	print("  Unreal: Z-up, 왼손  (완전히 다름)")
	print("  -> 다른 엔진에서 에셋 가져올 때 축 변환 필요!")

	# ============================================
	# 2. Vector3 기본
	# ============================================
	print("\n--- 2. Vector3 기본 ---\n")

	# Vector3 생성 방법들
	var pos1 := Vector3(1.0, 2.0, 3.0)
	var pos2 := Vector3(4, 5, 6)        # int도 가능 (float로 변환됨)
	var zero := Vector3.ZERO             # (0, 0, 0)
	var one := Vector3.ONE               # (1, 1, 1)

	print("Vector3 생성:")
	print("  Vector3(1.0, 2.0, 3.0) = %s" % str(pos1))
	print("  Vector3.ZERO = %s" % str(zero))
	print("  Vector3.ONE  = %s" % str(one))
	print("")

	# Vector3 상수 (방향 벡터)
	print("Vector3 방향 상수:")
	print("  Vector3.UP      = %s  (Y+)" % str(Vector3.UP))
	print("  Vector3.DOWN    = %s  (Y-)" % str(Vector3.DOWN))
	print("  Vector3.RIGHT   = %s  (X+)" % str(Vector3.RIGHT))
	print("  Vector3.LEFT    = %s  (X-)" % str(Vector3.LEFT))
	print("  Vector3.FORWARD = %s  (Z-) 주의: 앞쪽이 -Z!" % str(Vector3.FORWARD))
	print("  Vector3.BACK    = %s  (Z+)" % str(Vector3.BACK))
	print("")

	# 중요: Godot에서 "앞"은 -Z 방향
	print("** 중요: Godot에서 오브젝트의 '앞쪽'은 -Z 방향! **")
	print("  노드의 앞 방향: -transform.basis.z")
	print("  이것은 3D 모델링 도구와의 호환성 때문입니다")

	# ============================================
	# 3. Vector3 성분 접근
	# ============================================
	print("\n--- 3. Vector3 성분 접근 ---\n")

	var v := Vector3(10.0, 20.0, 30.0)

	# 이름으로 접근
	print("성분 접근 (이름):")
	print("  v = %s" % str(v))
	print("  v.x = %.1f" % v.x)
	print("  v.y = %.1f" % v.y)
	print("  v.z = %.1f" % v.z)
	print("")

	# 인덱스로 접근
	print("성분 접근 (인덱스):")
	print("  v[0] = %.1f (x)" % v[0])
	print("  v[1] = %.1f (y)" % v[1])
	print("  v[2] = %.1f (z)" % v[2])
	print("")

	# 성분 수정
	var pos := Vector3(1, 2, 3)
	pos.x = 10.0
	pos.y += 5.0
	print("성분 수정: Vector3(1,2,3) -> x=10, y+=5 -> %s" % str(pos))

	# ============================================
	# 4. Vector3 산술 연산
	# ============================================
	print("\n--- 4. Vector3 산술 연산 ---\n")

	var a := Vector3(1, 2, 3)
	var b := Vector3(4, 5, 6)

	# 벡터 + 벡터
	print("벡터 연산:")
	print("  a = %s, b = %s" % [str(a), str(b)])
	print("  a + b = %s" % str(a + b))
	print("  a - b = %s" % str(a - b))
	print("  a * b = %s  (성분별 곱셈)" % str(a * b))
	print("  a / b = %s  (성분별 나눗셈)" % str(a / b))
	print("")

	# 스칼라 연산
	print("스칼라 연산:")
	print("  a * 2 = %s" % str(a * 2))
	print("  a / 2 = %s" % str(a / 2))
	print("  -a    = %s  (반대 방향)" % str(-a))

	# ============================================
	# 5. 벡터 길이와 정규화
	# ============================================
	print("\n--- 5. 벡터 길이와 정규화 ---\n")

	var dir := Vector3(3, 4, 0)

	# length() - 벡터의 크기 (유클리드 거리)
	print("벡터 길이:")
	print("  dir = %s" % str(dir))
	print("  dir.length() = %.3f" % dir.length())
	print("  dir.length_squared() = %.3f (제곱근 생략, 비교에 유용)" % dir.length_squared())
	print("")

	# normalized() - 방향은 유지, 길이를 1로
	var norm := dir.normalized()
	print("정규화 (Normalize):")
	print("  dir.normalized() = %s" % str(norm))
	print("  정규화 후 길이 = %.3f (항상 1)" % norm.length())
	print("  -> 방향만 필요할 때 사용 (이동 방향, 시선 방향)")
	print("")

	# is_normalized() - 단위 벡터인지 확인
	print("단위 벡터 확인:")
	print("  dir.is_normalized() = %s" % dir.is_normalized())
	print("  norm.is_normalized() = %s" % norm.is_normalized())
	print("  Vector3.UP.is_normalized() = %s" % Vector3.UP.is_normalized())

	# ============================================
	# 6. 거리 계산
	# ============================================
	print("\n--- 6. 거리 계산 ---\n")

	var player_pos := Vector3(10, 0, 5)
	var enemy_pos := Vector3(20, 0, 15)

	# distance_to() - 두 점 사이 거리
	var dist := player_pos.distance_to(enemy_pos)
	var dist_sq := player_pos.distance_squared_to(enemy_pos)

	print("두 점 사이 거리:")
	print("  플레이어: %s" % str(player_pos))
	print("  적:       %s" % str(enemy_pos))
	print("  distance_to()         = %.3f" % dist)
	print("  distance_squared_to() = %.3f" % dist_sq)
	print("")

	# 성능 팁: 거리 비교에는 squared 사용
	var detection_range := 15.0
	print("거리 비교 최적화:")
	print("  # 느림 (매번 제곱근 계산)")
	print("  if player_pos.distance_to(enemy_pos) < %.1f:" % detection_range)
	print("")
	print("  # 빠름 (제곱근 생략)")
	print("  if player_pos.distance_squared_to(enemy_pos) < %.1f:" % (detection_range * detection_range))
	print("  -> 제곱근은 비싼 연산! 단순 비교에는 squared 사용")

	# ============================================
	# 7. 방향 벡터 (Direction Vector)
	# ============================================
	print("\n--- 7. 방향 벡터 ---\n")

	# A에서 B로의 방향 = (B - A).normalized()
	var from := Vector3(0, 0, 0)
	var to := Vector3(10, 5, -10)
	var direction := (to - from).normalized()

	print("방향 벡터 계산:")
	print("  from = %s" % str(from))
	print("  to   = %s" % str(to))
	print("  방향 = (to - from).normalized() = %s" % str(direction))
	print("")

	# direction_to() - 더 간편한 메서드
	var dir_to := from.direction_to(to)
	print("  from.direction_to(to) = %s" % str(dir_to))
	print("  -> 같은 결과, 더 깔끔한 코드!")
	print("")

	# 방향 벡터 활용
	var speed := 5.0
	var velocity := direction * speed
	print("방향 벡터 활용:")
	print("  속도(speed) = %.1f" % speed)
	print("  velocity = direction * speed = %s" % str(velocity))
	print("  -> 방향 * 속력 = 속도 (물리학의 기본!)")

	# ============================================
	# 8. 내적 (Dot Product)
	# ============================================
	print("\n--- 8. 내적 (Dot Product) ---\n")

	# dot() - 두 벡터의 내적
	# 결과 > 0: 같은 방향 (0~90도)
	# 결과 = 0: 수직 (90도)
	# 결과 < 0: 반대 방향 (90~180도)

	var forward := Vector3(0, 0, -1)  # 앞
	var right_dir := Vector3(1, 0, 0)     # 오른쪽
	var behind := Vector3(0, 0, 1)    # 뒤

	print("내적 (Dot Product) = a.x*b.x + a.y*b.y + a.z*b.z")
	print("  정규화된 벡터의 내적 = cos(두 벡터 사이의 각도)")
	print("")
	print("  forward = %s (앞)" % str(forward))
	print("  forward.dot(forward) = %.1f  (같은 방향: 1)" % forward.dot(forward))
	print("  forward.dot(right)   = %.1f  (수직: 0)" % forward.dot(right_dir))
	print("  forward.dot(behind)  = %.1f  (반대 방향: -1)" % forward.dot(behind))
	print("")

	# 내적 활용: 적이 앞에 있는지 확인
	var my_forward := Vector3(0, 0, -1)
	var enemy_dir := Vector3(0.5, 0, -0.866).normalized()  # 약 30도 옆
	var dot_result := my_forward.dot(enemy_dir)

	print("내적 활용 - 시야각 체크:")
	print("  내 앞 방향: %s" % str(my_forward))
	print("  적 방향:    %s" % str(enemy_dir))
	print("  dot = %.3f" % dot_result)
	print("  cos(60도) = 0.5 -> dot > 0.5면 시야 60도 안에 있음")
	if dot_result > 0.5:
		print("  -> 적이 시야 안에 있다!")
	else:
		print("  -> 적이 시야 밖에 있다!")

	# ============================================
	# 9. 외적 (Cross Product)
	# ============================================
	print("\n--- 9. 외적 (Cross Product) ---\n")

	# cross() - 두 벡터에 수직인 벡터를 반환
	var vec_a := Vector3(1, 0, 0)  # X축
	var vec_b := Vector3(0, 0, -1) # -Z축 (앞)
	var cross_result := vec_a.cross(vec_b)

	print("외적 (Cross Product):")
	print("  두 벡터에 수직인 새 벡터를 반환")
	print("  오른손 법칙으로 방향 결정")
	print("")
	print("  X축.cross(-Z축) = %s (Y축, 위쪽)" % str(cross_result))
	print("")

	# 외적 활용: 표면의 법선 벡터 계산
	print("외적 활용:")
	print("  - 표면의 법선(normal) 벡터 계산")
	print("  - 회전축 결정")
	print("  - 왼쪽/오른쪽 판별")
	print("")

	# 왼쪽/오른쪽 판별
	var my_dir := Vector3(0, 0, -1)    # 내가 보는 방향 (앞)
	var target_dir_left := Vector3(-1, 0, -1).normalized()  # 왼쪽 앞
	var target_dir_right := Vector3(1, 0, -1).normalized()  # 오른쪽 앞

	var cross_left := my_dir.cross(target_dir_left)
	var cross_right := my_dir.cross(target_dir_right)

	print("외적으로 좌우 판별:")
	print("  내 방향: %s" % str(my_dir))
	print("  왼쪽 대상: cross.y = %.3f (양수 = 왼쪽)" % cross_left.y)
	print("  오른쪽 대상: cross.y = %.3f (음수 = 오른쪽)" % cross_right.y)

	# ============================================
	# 10. 벡터 보간 (Interpolation)
	# ============================================
	print("\n--- 10. 벡터 보간 ---\n")

	var start := Vector3(0, 0, 0)
	var end := Vector3(10, 10, 10)

	# lerp - 선형 보간
	print("선형 보간 (lerp):")
	print("  start = %s, end = %s" % [str(start), str(end)])
	print("  lerp(end, 0.0) = %s (시작)" % str(start.lerp(end, 0.0)))
	print("  lerp(end, 0.5) = %s (중간)" % str(start.lerp(end, 0.5)))
	print("  lerp(end, 1.0) = %s (끝)" % str(start.lerp(end, 1.0)))
	print("  -> 부드러운 이동, 카메라 추적에 필수!")
	print("")

	# slerp - 구면 보간 (방향 보간에 적합)
	var dir1 := Vector3(1, 0, 0).normalized()   # 오른쪽
	var dir2 := Vector3(0, 0, -1).normalized()  # 앞쪽
	var slerped := dir1.slerp(dir2, 0.5)

	print("구면 보간 (slerp):")
	print("  방향 벡터 보간에 사용 (일정한 각속도)")
	print("  dir1 = %s (오른쪽)" % str(dir1))
	print("  dir2 = %s (앞쪽)" % str(dir2))
	print("  slerp(dir2, 0.5) = %s" % str(slerped))
	print("  slerp 결과 길이 = %.3f (항상 일정!)" % slerped.length())

	# ============================================
	# 11. 유용한 Vector3 메서드들
	# ============================================
	print("\n--- 11. 유용한 Vector3 메서드들 ---\n")

	var test_vec := Vector3(3.7, -2.3, 5.9)

	print("기타 유용한 메서드:")
	print("  abs()    = %s  (절대값)" % str(test_vec.abs()))
	print("  floor()  = %s  (내림)" % str(test_vec.floor()))
	print("  ceil()   = %s  (올림)" % str(test_vec.ceil()))
	print("  round()  = %s  (반올림)" % str(test_vec.round()))
	print("  sign()   = %s  (부호)" % str(test_vec.sign()))
	print("")

	# clamp - 범위 제한
	var clamped := test_vec.clamp(Vector3(-2, -2, -2), Vector3(4, 4, 4))
	print("  clamp(-2~4) = %s" % str(clamped))
	print("")

	# min/max axis
	print("  min_axis_index() = %d (가장 작은 축)" % test_vec.min_axis_index())
	print("  max_axis_index() = %d (가장 큰 축)" % test_vec.max_axis_index())

	# ============================================
	# 12. 실전 예제: 3D 공간 활용
	# ============================================
	print("\n--- 12. 실전 예제 ---\n")

	# 수평 거리만 계산 (Y 무시)
	var pos_a := Vector3(10, 50, 20)
	var pos_b := Vector3(30, 0, 40)

	var horizontal_dist := Vector3(pos_a.x, 0, pos_a.z).distance_to(
		Vector3(pos_b.x, 0, pos_b.z))
	var full_dist := pos_a.distance_to(pos_b)

	print("수평 거리 vs 전체 거리:")
	print("  A = %s, B = %s" % [str(pos_a), str(pos_b)])
	print("  수평 거리 (Y 무시) = %.3f" % horizontal_dist)
	print("  전체 거리         = %.3f" % full_dist)
	print("  -> 높이 무시하고 평면 거리만 필요할 때 유용")
	print("")

	# 반사 벡터 (bounce/reflect)
	var incoming := Vector3(1, -1, 0).normalized()
	var normal := Vector3.UP
	var reflected := incoming.bounce(normal)

	print("반사 벡터 (공 튕기기):")
	print("  입사 벡터: %s" % str(incoming))
	print("  법선:      %s" % str(normal))
	print("  반사:      %s" % str(reflected))
	print("  -> 공이 바닥에 부딪혀 튕기는 방향!")

	# ============================================
	# 13. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Godot 3D: Y-up 오른손 좌표계, 앞쪽 = -Z")
	print("2. Vector3: x, y, z 세 성분, 상수 활용 (UP, FORWARD 등)")
	print("3. normalized(): 방향만 필요할 때 (길이를 1로)")
	print("4. distance_to(): 두 점 사이 거리, squared로 최적화")
	print("5. direction_to(): A에서 B로의 방향 벡터")
	print("6. dot(): 각도/방향 관계 (-1~1), 시야각 체크")
	print("7. cross(): 수직 벡터, 좌우 판별, 법선 계산")
	print("8. lerp()/slerp(): 부드러운 보간 (위치/방향)")
