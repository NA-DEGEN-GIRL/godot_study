# 챕터 2: GDScript 기초
#
# 이 챕터에서는 다음을 학습합니다:
# - 타입 힌트를 사용한 변수 선언
# - 배열(Array) 조작 메서드
# - 딕셔너리(Dictionary) 활용
# - match 문 (패턴 매칭)
# - for/while 반복문
# - 함수 정의와 반환값
# - 내부 클래스 (inner class) 작성

extends Node


# =============================================
# 연습 7에서 사용할 클래스
# =============================================
# TODO: Animal 클래스를 완성하세요
# - 속성: name(String), sound(String), legs(int)
# - 메서드: speak() -> String : "{name}이(가) {sound} 소리를 냅니다" 반환
# - 메서드: describe() -> String : "{name}: 다리 {legs}개" 반환
class Animal:
	var name: String
	var sound: String
	var legs: int

	func _init(_name: String, _sound: String, _legs: int):
		pass  # 여기를 수정하세요

	func speak() -> String:
		return ""  # 여기를 수정하세요

	func describe() -> String:
		return ""  # 여기를 수정하세요


func _ready():
	# =============================================
	# 연습 1: 타입 힌트 변수 선언
	# =============================================
	# TODO: 다음 변수들을 타입 힌트를 사용하여 선언하세요
	# - score: int 타입, 초기값 0
	# - player_name: String 타입, 초기값 "Player1"
	# - speed: float 타입, 초기값 3.5
	# - is_alive: bool 타입, 초기값 true
	# - position: Vector2 타입, 초기값 Vector2(100, 200)
	# 예: var score: int = 0
	var score = null  # 여기를 수정하세요
	var player_name = null  # 여기를 수정하세요
	var speed = null  # 여기를 수정하세요
	var is_alive = null  # 여기를 수정하세요
	var position = null  # 여기를 수정하세요

	# =============================================
	# 연습 2: 배열 조작 (append, remove, sort)
	# =============================================
	# TODO: 아래 지시에 따라 배열을 조작하세요
	# 1) fruits 배열을 생성하세요: ["사과", "바나나", "체리"]
	# 2) "딸기"를 배열 끝에 추가하세요 (append)
	# 3) "바나나"를 배열에서 제거하세요 (erase)
	# 4) 배열을 정렬하세요 (sort)
	# 5) 최종 배열의 크기를 answer2_size에 저장하세요
	# 예: var fruits: Array = ["사과", "바나나", "체리"]
	var fruits = null  # 여기를 수정하세요
	var answer2_size = null  # 여기를 수정하세요 (최종 배열 크기)

	# =============================================
	# 연습 3: 딕셔너리로 학생 정보 관리
	# =============================================
	# TODO: 학생 정보를 딕셔너리로 만드세요
	# - student 딕셔너리를 생성하세요
	#   키: "name"(String), "age"(int), "grades"(Array[int]), "is_active"(bool)
	# - "name": "김철수", "age": 20, "grades": [85, 92, 78], "is_active": true
	# - grades의 평균을 계산하여 answer3_avg에 저장하세요
	# 예: var student: Dictionary = {"name": "김철수", ...}
	var student = null  # 여기를 수정하세요
	var answer3_avg = null  # 여기를 수정하세요 (grades 평균, float)

	# =============================================
	# 연습 4: match 문으로 등급 판별
	# =============================================
	# TODO: get_grade() 함수를 완성한 뒤, 아래에서 호출하세요
	# 점수 범위에 따라 등급을 반환합니다
	# - 90 이상: "A"
	# - 80 이상: "B"
	# - 70 이상: "C"
	# - 60 이상: "D"
	# - 60 미만: "F"
	var grade_85 = get_grade(85)  # "B"가 되어야 합니다
	var grade_92 = get_grade(92)  # "A"가 되어야 합니다
	var grade_55 = get_grade(55)  # "F"가 되어야 합니다

	# =============================================
	# 연습 5: for 루프로 구구단 출력
	# =============================================
	# TODO: 특정 단의 구구단을 배열로 반환하는 함수를 완성하세요
	# multiply_table(3)을 호출하면 [3, 6, 9, 12, 15, 18, 21, 24, 27]을 반환
	# (3x1부터 3x9까지의 결과)
	var table_3 = multiply_table(3)
	var table_7 = multiply_table(7)

	# =============================================
	# 연습 6: 함수 작성 (최대값 찾기)
	# =============================================
	# TODO: find_max() 함수를 완성하세요
	# 정수 배열을 받아 가장 큰 값을 반환합니다
	# 빈 배열인 경우 null을 반환합니다
	# 예: find_max([3, 7, 1, 9, 4]) -> 9
	var max_result1 = find_max([3, 7, 1, 9, 4])
	var max_result2 = find_max([100, -5, 42, 88])
	var max_result3 = find_max([])

	# =============================================
	# 연습 7: 클래스 작성 (Animal)
	# =============================================
	# TODO: 위에 정의된 Animal 클래스를 완성한 뒤 아래에서 인스턴스를 생성하세요
	# - dog: 이름 "강아지", 소리 "멍멍", 다리 4
	# - bird: 이름 "참새", 소리 "짹짹", 다리 2
	var dog = null  # 여기를 수정하세요 (Animal.new("강아지", "멍멍", 4))
	var bird = null  # 여기를 수정하세요 (Animal.new("참새", "짹짹", 2))
	var dog_speak = ""  # 여기를 수정하세요 (dog.speak())
	var bird_desc = ""  # 여기를 수정하세요 (bird.describe())

	# =============================================
	# 테스트 케이스
	# =============================================
	print("\n=== 챕터 2: GDScript 기초 ===")

	print("--- 연습 1: 타입 힌트 변수 ---")
	print("결과 1-1 (score): ", score)
	print("결과 1-2 (player_name): ", player_name)
	print("결과 1-3 (speed): ", speed)
	print("결과 1-4 (is_alive): ", is_alive)
	print("결과 1-5 (position): ", position)

	print("--- 연습 2: 배열 조작 ---")
	print("결과 2 (fruits): ", fruits)
	print("결과 2 (배열 크기): ", answer2_size)

	print("--- 연습 3: 딕셔너리 ---")
	print("결과 3 (student): ", student)
	print("결과 3 (성적 평균): ", answer3_avg)

	print("--- 연습 4: match 등급 판별 ---")
	print("결과 4-1 (85점 등급): ", grade_85, " (기대값: B)")
	print("결과 4-2 (92점 등급): ", grade_92, " (기대값: A)")
	print("결과 4-3 (55점 등급): ", grade_55, " (기대값: F)")

	print("--- 연습 5: 구구단 ---")
	print("결과 5-1 (3단): ", table_3)
	print("결과 5-2 (7단): ", table_7)

	print("--- 연습 6: 최대값 찾기 ---")
	print("결과 6-1 ([3,7,1,9,4] 최대값): ", max_result1, " (기대값: 9)")
	print("결과 6-2 ([100,-5,42,88] 최대값): ", max_result2, " (기대값: 100)")
	print("결과 6-3 (빈 배열 최대값): ", max_result3, " (기대값: null)")

	print("--- 연습 7: Animal 클래스 ---")
	print("결과 7-1 (dog.speak()): ", dog_speak)
	print("결과 7-2 (bird.describe()): ", bird_desc)
	print("=== 완료 ===\n")


# =============================================
# 연습 4: match 문으로 등급 판별 함수
# =============================================
# TODO: 점수(score)를 받아 등급 문자열을 반환하세요
# match 문 또는 if/elif를 사용할 수 있지만, match 문 연습을 권장합니다
# 힌트: match에서 범위 비교가 어려우면 score / 10 값을 match에 사용하세요
# 예:
#   match score / 10:
#       9, 10: return "A"
#       8: return "B"
#       ...
func get_grade(score: int) -> String:
	return ""  # 여기를 수정하세요


# =============================================
# 연습 5: 구구단 함수
# =============================================
# TODO: dan 값을 받아 dan*1 부터 dan*9 까지의 결과를 배열로 반환하세요
# 예: multiply_table(2) -> [2, 4, 6, 8, 10, 12, 14, 16, 18]
func multiply_table(dan: int) -> Array:
	return []  # 여기를 수정하세요


# =============================================
# 연습 6: 최대값 찾기 함수
# =============================================
# TODO: 정수 배열에서 가장 큰 값을 찾아 반환하세요
# 빈 배열이면 null을 반환하세요
# 힌트: 첫 번째 요소를 초기 최대값으로 설정한 뒤 순회하세요
func find_max(arr: Array):
	return null  # 여기를 수정하세요
