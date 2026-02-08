# Chapter 02 - GDScript Basics
# 03-control-flow.gd - Control Flow Statements
#
# 이 파일에서 배울 내용:
# - if / elif / else 조건문
# - match 문 (패턴 매칭)
# - for / while 반복문
# - range() 함수 활용
# - break, continue 제어

extends Node

func _ready():
	print("=== 제어 흐름 (Control Flow) ===\n")

	# ============================================
	# 1. if / elif / else 조건문
	# ============================================
	print("--- if / elif / else ---\n")

	var score := 85

	# 기본 if-elif-else
	if score >= 90:
		print("학점: A")
	elif score >= 80:
		print("학점: B")
	elif score >= 70:
		print("학점: C")
	elif score >= 60:
		print("학점: D")
	else:
		print("학점: F")

	# 한 줄 if (간단한 경우)
	var health := 50
	var status := "위험" if health < 30 else "보통" if health < 70 else "양호"
	print("체력 %d - 상태: %s" % [health, status])

	# 복합 조건
	var level := 10
	var has_key := true

	if level >= 5 and has_key:
		print("문을 열 수 있습니다!")

	if level < 3 or not has_key:
		print("문을 열 수 없습니다!")
	else:
		print("조건 충족!")

	# null 체크
	var item = null
	if item == null:
		print("아이템이 없습니다")

	# 타입 체크와 조건문
	var value = 42
	if value is int:
		print("정수입니다: ", value)
	elif value is String:
		print("문자열입니다: ", value)

	# ============================================
	# 2. match 문 (패턴 매칭)
	# ============================================
	print("\n--- match 문 (패턴 매칭) ---\n")

	# 기본 match (다른 언어의 switch와 유사하지만 더 강력)
	var command := "attack"

	match command:
		"attack":
			print("공격!")
		"defend":
			print("방어!")
		"heal":
			print("회복!")
		"run":
			print("도주!")
		_:
			print("알 수 없는 명령: ", command)

	# 여러 값 매칭
	var day := 3
	match day:
		1, 7:
			print("주말입니다")
		2, 3, 4, 5, 6:
			print("평일입니다")
		_:
			print("잘못된 요일")

	# 패턴 바인딩 (변수에 할당)
	var data = [1, 2, 3]

	match data:
		[]:
			print("빈 배열")
		[var first]:
			print("요소 1개: ", first)
		[var first, var second]:
			print("요소 2개: ", first, ", ", second)
		[var first, ..]:
			print("첫 번째 요소: ", first, " (나머지 있음)")

	# Dictionary 패턴 매칭
	var event := {"type": "damage", "amount": 25}

	match event:
		{"type": "damage", "amount": var amt}:
			print("데미지: ", amt)
		{"type": "heal", "amount": var amt}:
			print("회복: ", amt)
		_:
			print("알 수 없는 이벤트")

	# 타입 패턴 매칭
	var test_value = 3.14

	match typeof(test_value):
		TYPE_INT:
			print("정수 타입")
		TYPE_FLOAT:
			print("실수 타입")
		TYPE_STRING:
			print("문자열 타입")
		_:
			print("기타 타입")

	# 범위 매칭은 없으므로 if-elif 사용
	# match는 정확한 값 비교에 적합합니다

	# ============================================
	# 3. for 반복문
	# ============================================
	print("\n--- for 반복문 ---\n")

	# 배열 순회
	var fruits := ["apple", "banana", "cherry"]
	print("과일 목록:")
	for fruit in fruits:
		print("  - ", fruit)

	# range() 사용
	print("\nrange(5): 0부터 4까지")
	for i in range(5):
		print("  i = ", i)

	print("\nrange(2, 7): 2부터 6까지")
	for i in range(2, 7):
		print("  i = ", i)

	print("\nrange(0, 10, 2): 0부터 8까지 (2씩 증가)")
	for i in range(0, 10, 2):
		print("  i = ", i)

	print("\nrange(10, 0, -2): 10부터 2까지 (2씩 감소)")
	for i in range(10, 0, -2):
		print("  i = ", i)

	# 정수 반복 (range와 동일)
	print("\nfor i in 5: (range(5)와 동일)")
	for i in 5:
		print("  i = ", i)

	# Dictionary 순회
	print("\nDictionary 순회:")
	var stats := {"HP": 100, "MP": 50, "STR": 15, "DEF": 10}
	for key in stats:
		print("  %s: %d" % [key, stats[key]])

	# 문자열 순회 (문자별)
	print("\n문자열 순회:")
	var text := "Godot"
	for ch in text:
		print("  문자: ", ch)

	# 인덱스와 함께 순회
	print("\n인덱스와 함께:")
	var items := ["sword", "shield", "potion"]
	for i in range(items.size()):
		print("  [%d] %s" % [i, items[i]])

	# ============================================
	# 4. while 반복문
	# ============================================
	print("\n--- while 반복문 ---\n")

	# 기본 while
	var count := 0
	print("카운트다운:")
	var countdown := 5
	while countdown > 0:
		print("  ", countdown)
		countdown -= 1
	print("  발사!")

	# while로 조건 충족까지 반복
	var hp := 100
	var damage := 15
	var turn := 0
	print("\n전투 시뮬레이션:")
	while hp > 0:
		turn += 1
		hp -= damage
		if hp < 0:
			hp = 0
		print("  턴 %d: HP = %d" % [turn, hp])
	print("  전투 종료! (총 %d턴)" % turn)

	# 무한 루프 (break로 탈출)
	# while true:
	#     if 조건:
	#         break

	# ============================================
	# 5. break와 continue
	# ============================================
	print("\n--- break와 continue ---\n")

	# break - 반복문 즉시 탈출
	print("break 예제 (5를 찾으면 중단):")
	for i in range(10):
		if i == 5:
			print("  5를 찾았습니다! 반복 중단")
			break
		print("  i = ", i)

	# continue - 현재 반복을 건너뛰고 다음으로
	print("\ncontinue 예제 (홀수만 출력):")
	for i in range(10):
		if i % 2 == 0:
			continue  # 짝수는 건너뜀
		print("  i = ", i)

	# 중첩 루프에서 break
	print("\n중첩 루프 (내부 루프만 break):")
	for row in range(3):
		for col in range(5):
			if col == 3:
				break  # 내부 루프만 탈출
			printraw("(%d,%d) " % [row, col])
		print("")  # 줄바꿈

	# ============================================
	# 6. 실전 패턴: 검색
	# ============================================
	print("\n--- 실전 패턴 ---\n")

	# 배열에서 조건 검색
	var enemies := [
		{"name": "Slime", "hp": 10, "level": 1},
		{"name": "Goblin", "hp": 30, "level": 3},
		{"name": "Dragon", "hp": 200, "level": 10},
		{"name": "Wolf", "hp": 25, "level": 2},
	]

	print("레벨 3 이상 적 찾기:")
	for enemy in enemies:
		if enemy["level"] >= 3:
			print("  %s (Lv.%d, HP:%d)" % [enemy["name"], enemy["level"], enemy["hp"]])

	# 가장 강한 적 찾기
	var strongest = enemies[0]
	for enemy in enemies:
		if enemy["hp"] > strongest["hp"]:
			strongest = enemy
	print("\n가장 강한 적: %s (HP:%d)" % [strongest["name"], strongest["hp"]])

	# ============================================
	# 7. 실전 패턴: 2D 그리드 순회
	# ============================================
	print("\n--- 2D 그리드 순회 ---\n")

	# 3x3 그리드 생성
	var grid := []
	var grid_size := 3
	for row in range(grid_size):
		var grid_row := []
		for col in range(grid_size):
			grid_row.append(row * grid_size + col + 1)
		grid.append(grid_row)

	# 그리드 출력
	print("3x3 그리드:")
	for row in grid:
		var row_str := ""
		for cell in row:
			row_str += "%3d" % cell
		print("  ", row_str)

	# ============================================
	# 8. 실전 패턴: 상태 머신
	# ============================================
	print("\n--- 간단한 상태 머신 ---\n")

	# 게임 캐릭터의 상태를 match로 처리
	var states := ["idle", "run", "jump", "attack", "idle"]

	for state in states:
		match state:
			"idle":
				print("  [대기] 캐릭터가 서 있습니다")
			"run":
				print("  [이동] 캐릭터가 달립니다")
			"jump":
				print("  [점프] 캐릭터가 점프합니다")
			"attack":
				print("  [공격] 캐릭터가 공격합니다")

	# ============================================
	# 9. 실전 패턴: FizzBuzz
	# ============================================
	print("\n--- FizzBuzz (1-20) ---\n")

	var result := ""
	for i in range(1, 21):
		if i % 15 == 0:
			result += "FizzBuzz "
		elif i % 3 == 0:
			result += "Fizz "
		elif i % 5 == 0:
			result += "Buzz "
		else:
			result += str(i) + " "
	print(result)

	# ============================================
	# 10. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. if/elif/else: 조건 분기")
	print("2. match: 값 기반 패턴 매칭 (배열, 딕셔너리도 가능)")
	print("3. for: 배열, range, 딕셔너리 순회")
	print("4. while: 조건이 참인 동안 반복")
	print("5. range(start, end, step): 숫자 범위 생성")
	print("6. break: 반복문 탈출 / continue: 다음 반복으로")
	print("7. 삼항 연산자: value_a if condition else value_b")
