# 챕터 2: GDScript 기초 문법 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - 타입 힌트와 타입 추론
# - 배열(Array) 조작
# - 딕셔너리(Dictionary) 활용
# - match 문으로 패턴 매칭
# - 반복문으로 구구단 출력
# - 함수 정의와 반환값
# - 클래스(class) 정의와 상속

extends Node


# =============================================
# 연습 6: 최대값을 반환하는 함수
# =============================================
# 풀이: 함수는 func 키워드로 정의합니다.
# 매개변수와 반환값에 타입 힌트를 사용하면 안전합니다.
# 배열에서 최대값을 찾으려면 첫 번째 원소를 기준으로
# 순회하며 더 큰 값을 발견할 때마다 갱신합니다.
# 추가 설명: GDScript 배열에는 .max() 메서드가 없으므로 직접 구현합니다.
# (Godot 4.x에서는 배열에 .max() 내장 메서드가 있지만, 학습 목적으로 직접 구현)
func find_max(numbers: Array) -> int:
	if numbers.is_empty():
		return 0
	var max_val: int = numbers[0]
	for num in numbers:
		if num > max_val:
			max_val = num
	return max_val


# =============================================
# 연습 7: Animal 클래스 정의
# =============================================
# 풀이: GDScript에서 내부 클래스는 class 키워드로 정의합니다.
# 생성자는 _init() 메서드를 사용합니다.
# 메서드를 정의하여 동물의 행동을 표현합니다.
# 추가 설명: 내부 클래스는 스크립트 내부에서만 사용 가능합니다.
# 별도 파일로 분리하면 class_name 키워드로 전역 접근이 가능합니다.
class Animal:
	var name: String
	var sound: String
	var legs: int

	func _init(p_name: String, p_sound: String, p_legs: int):
		name = p_name
		sound = p_sound
		legs = p_legs

	func speak() -> String:
		return name + "이(가) " + sound + " 소리를 냅니다!"

	func info() -> String:
		return name + " - 다리: " + str(legs) + "개, 울음소리: " + sound


func _ready():
	# =============================================
	# 연습 1: 타입 힌트 사용
	# =============================================
	# 풀이: 타입 힌트는 변수명 뒤에 : Type 형태로 작성합니다.
	# 타입 힌트를 사용하면 컴파일 시점에 타입 오류를 잡을 수 있고,
	# 에디터 자동 완성도 더 정확하게 동작합니다.
	# 추가 설명: := 연산자를 사용하면 우변의 값에서 타입을 자동 추론합니다.
	var player_name: String = "용사"
	var player_hp: int = 100
	var player_speed: float = 250.5
	var is_alive: bool = true
	var items: Array = ["검", "방패", "물약"]

	# 타입 추론 사용 (:= 연산자)
	var inferred_name := "마법사"  # String으로 자동 추론
	var inferred_hp := 80  # int로 자동 추론
	var inferred_speed := 200.0  # float으로 자동 추론

	# =============================================
	# 연습 2: 배열 조작
	# =============================================
	# 풀이: GDScript 배열은 동적 크기이며 다양한 메서드를 제공합니다.
	# - append(): 끝에 추가
	# - insert(): 지정 위치에 삽입
	# - remove_at(): 인덱스로 삭제
	# - pop_back() / pop_front(): 끝/앞에서 꺼내기
	# - find(): 값의 인덱스 검색
	# - sort(): 정렬
	# - size(): 배열 길이
	# 추가 설명: 배열 인덱스는 0부터 시작하고, 음수 인덱스(-1 = 마지막)를 지원합니다.
	var inventory: Array = ["검", "방패", "물약"]
	inventory.append("활")          # 끝에 "활" 추가 -> ["검", "방패", "물약", "활"]
	inventory.insert(1, "갑옷")     # 인덱스 1에 "갑옷" 삽입 -> ["검", "갑옷", "방패", "물약", "활"]
	inventory.remove_at(2)          # 인덱스 2 삭제("방패") -> ["검", "갑옷", "물약", "활"]
	var last_item = inventory.pop_back()  # 마지막 꺼내기 -> "활", 배열: ["검", "갑옷", "물약"]
	inventory.sort()                # 정렬 -> ["갑옷", "검", "물약"]
	var inventory_size: int = inventory.size()  # 배열 길이: 3

	# =============================================
	# 연습 3: 딕셔너리 활용
	# =============================================
	# 풀이: 딕셔너리는 키-값 쌍으로 데이터를 저장합니다.
	# {}로 생성하고, ["키"] 또는 .get("키")로 접근합니다.
	# .get()은 키가 없을 때 기본값을 반환할 수 있어 더 안전합니다.
	# 추가 설명: 딕셔너리 키는 어떤 타입이든 가능하지만, 보통 String을 사용합니다.
	var player: Dictionary = {
		"name": "용사",
		"level": 10,
		"hp": 100,
		"mp": 50,
		"skills": ["베기", "찌르기", "마법"]
	}

	# 값 접근
	var p_name: String = player["name"]             # "용사"
	var p_level: int = player.get("level", 1)       # 10 (없으면 기본값 1)
	var p_skills: Array = player["skills"]           # ["베기", "찌르기", "마법"]

	# 값 추가/수정
	player["exp"] = 2500           # 새로운 키 추가
	player["hp"] = 120             # 기존 값 수정

	# 키 존재 여부 확인
	var has_mp: bool = player.has("mp")     # true
	var has_gold: bool = player.has("gold") # false

	# 모든 키 목록
	var all_keys: Array = player.keys()     # ["name", "level", "hp", "mp", "skills", "exp"]

	# =============================================
	# 연습 4: match 문으로 등급 판정
	# =============================================
	# 풀이: match는 다른 언어의 switch/case와 유사하지만 더 강력합니다.
	# 패턴 매칭을 지원하며, _는 default(기본) 케이스입니다.
	# 여기서는 점수 범위를 변수에 매핑하는 대신,
	# if/elif를 사용해 범위를 판정한 뒤 match로 등급 문자열을 결정합니다.
	# 추가 설명: match는 값 매칭, 배열 패턴, 딕셔너리 패턴 등을 지원합니다.
	var score: int = 85
	var grade: String = ""

	# 점수를 등급 문자열로 변환
	if score >= 90:
		grade = "A"
	elif score >= 80:
		grade = "B"
	elif score >= 70:
		grade = "C"
	elif score >= 60:
		grade = "D"
	else:
		grade = "F"

	# match로 등급별 메시지 생성
	var grade_message: String = ""
	match grade:
		"A":
			grade_message = "훌륭합니다! 최고 등급입니다."
		"B":
			grade_message = "잘했습니다! 좋은 성적이네요."
		"C":
			grade_message = "보통입니다. 조금 더 노력하세요."
		"D":
			grade_message = "아쉽습니다. 분발이 필요합니다."
		"F":
			grade_message = "낙제입니다. 재시험이 필요합니다."
		_:
			grade_message = "알 수 없는 등급입니다."

	# =============================================
	# 연습 5: 구구단 출력 (반복문)
	# =============================================
	# 풀이: for 문과 range()를 사용하여 구구단을 출력합니다.
	# range(start, end)는 start부터 end-1까지의 범위를 생성합니다.
	# 중첩 for 문으로 2~9단까지 전체 구구단을 만들 수 있습니다.
	# 추가 설명: while 문으로도 같은 결과를 얻을 수 있지만, for + range가 더 간결합니다.
	var dan: int = 7  # 7단 출력
	var gugudan_result: Array = []
	for i in range(1, 10):
		var line: String = "%d x %d = %d" % [dan, i, dan * i]
		gugudan_result.append(line)

	# 전체 구구단(2~9단) 문자열 생성
	var full_gugudan: String = ""
	for d in range(2, 10):
		full_gugudan += "--- %d단 ---\n" % d
		for i in range(1, 10):
			full_gugudan += "%d x %d = %d\n" % [d, i, d * i]

	# =============================================
	# 연습 6: 최대값 함수 호출
	# =============================================
	# 풀이: 위에서 정의한 find_max() 함수를 호출합니다.
	# 함수를 별도로 정의하면 코드 재사용이 가능하고 가독성이 높아집니다.
	var test_numbers: Array = [34, 78, 12, 95, 43, 67, 88, 5]
	var max_value: int = find_max(test_numbers)  # 95

	# =============================================
	# 연습 7: Animal 클래스 사용
	# =============================================
	# 풀이: 위에서 정의한 Animal 내부 클래스를 .new()로 인스턴스화합니다.
	# _init()에 전달할 인자를 .new()에 넘깁니다.
	var cat = Animal.new("고양이", "야옹", 4)
	var dog = Animal.new("강아지", "멍멍", 4)
	var bird = Animal.new("참새", "짹짹", 2)

	var cat_speak: String = cat.speak()  # "고양이이(가) 야옹 소리를 냅니다!"
	var dog_info: String = dog.info()    # "강아지 - 다리: 4개, 울음소리: 멍멍"

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 2: GDScript 기초 문법 ===")

	print("--- 연습 1: 타입 힌트 ---")
	print("결과 1-1 (이름): ", player_name)
	print("결과 1-2 (HP): ", player_hp)
	print("결과 1-3 (속도): ", player_speed)
	print("결과 1-4 (생존): ", is_alive)
	print("결과 1-5 (아이템): ", items)
	print("결과 1-6 (추론 이름): ", inferred_name)
	print("결과 1-7 (추론 HP): ", inferred_hp)

	print("--- 연습 2: 배열 조작 ---")
	print("결과 2-1 (인벤토리): ", inventory)
	print("결과 2-2 (꺼낸 아이템): ", last_item)
	print("결과 2-3 (배열 크기): ", inventory_size)

	print("--- 연습 3: 딕셔너리 ---")
	print("결과 3-1 (이름): ", p_name)
	print("결과 3-2 (레벨): ", p_level)
	print("결과 3-3 (스킬): ", p_skills)
	print("결과 3-4 (MP 존재): ", has_mp)
	print("결과 3-5 (골드 존재): ", has_gold)
	print("결과 3-6 (모든 키): ", all_keys)

	print("--- 연습 4: match 등급 ---")
	print("결과 4-1 (점수): ", score)
	print("결과 4-2 (등급): ", grade)
	print("결과 4-3 (메시지): ", grade_message)

	print("--- 연습 5: 구구단 ---")
	print("결과 5 (7단):")
	for line in gugudan_result:
		print("  ", line)

	print("--- 연습 6: 최대값 함수 ---")
	print("결과 6-1 (배열): ", test_numbers)
	print("결과 6-2 (최대값): ", max_value)

	print("--- 연습 7: Animal 클래스 ---")
	print("결과 7-1 (고양이 울기): ", cat_speak)
	print("결과 7-2 (강아지 정보): ", dog_info)
	print("결과 7-3 (참새 울기): ", bird.speak())
	print("=== 완료 ===\n")
