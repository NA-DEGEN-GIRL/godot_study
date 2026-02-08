# Chapter 02 - GDScript Basics
# 04-functions.gd - Functions and Callables
#
# 이 파일에서 배울 내용:
# - func 키워드로 함수 정의하기
# - 매개변수, 반환값, 기본값 설정
# - static 함수와 클래스 메서드
# - 람다(lambda) 함수와 Callable

extends Node

# ============================================
# 1. 기본 함수 정의
# ============================================

# 매개변수 없는 함수
func greet():
	print("안녕하세요!")

# 매개변수가 있는 함수
func greet_person(person_name: String):
	print("안녕하세요, %s님!" % person_name)

# 반환값이 있는 함수
func add(a: int, b: int) -> int:
	return a + b

# 여러 타입의 매개변수
func describe_item(item_name: String, quantity: int, price: float) -> String:
	return "%s x%d = %.1f골드" % [item_name, quantity, price * quantity]

# ============================================
# 2. 기본값이 있는 매개변수
# ============================================

func create_character(char_name: String, level: int = 1, job: String = "전사") -> Dictionary:
	return {
		"name": char_name,
		"level": level,
		"job": job,
		"hp": level * 100,
		"mp": level * 50
	}

# 다양한 타입의 기본값
func configure(
	width: int = 800,
	height: int = 600,
	fullscreen: bool = false,
	title: String = "My Game",
	vsync: bool = true
) -> Dictionary:
	return {
		"width": width,
		"height": height,
		"fullscreen": fullscreen,
		"title": title,
		"vsync": vsync
	}

# ============================================
# 3. 반환 타입
# ============================================

# void - 반환값 없음 (명시적으로 선언 가능)
func log_message(msg: String) -> void:
	print("[LOG] ", msg)

# 여러 값 반환 (배열 사용)
func get_min_max(numbers: Array[int]) -> Array:
	if numbers.is_empty():
		return [0, 0]
	var min_val := numbers[0]
	var max_val := numbers[0]
	for n in numbers:
		if n < min_val:
			min_val = n
		if n > max_val:
			max_val = n
	return [min_val, max_val]

# 여러 값 반환 (딕셔너리 사용 - 더 명확함)
func get_stats(values: Array[int]) -> Dictionary:
	if values.is_empty():
		return {"sum": 0, "avg": 0.0, "count": 0}
	var total := 0
	for v in values:
		total += v
	return {
		"sum": total,
		"avg": float(total) / values.size(),
		"count": values.size()
	}

# ============================================
# 4. 재귀 함수
# ============================================

func factorial(n: int) -> int:
	if n <= 1:
		return 1
	return n * factorial(n - 1)

func fibonacci(n: int) -> int:
	if n <= 0:
		return 0
	if n == 1:
		return 1
	return fibonacci(n - 1) + fibonacci(n - 2)

# ============================================
# 5. static 함수
# ============================================

# static 함수는 인스턴스 없이 호출할 수 있습니다
# self에 접근할 수 없습니다 (인스턴스 변수 사용 불가)
static func clamp_value(value: float, min_val: float, max_val: float) -> float:
	if value < min_val:
		return min_val
	if value > max_val:
		return max_val
	return value

static func lerp_value(from: float, to: float, weight: float) -> float:
	return from + (to - from) * weight

static func random_range_int(from: int, to: int) -> int:
	return randi() % (to - from + 1) + from

# ============================================
# 6. 가변 인자 패턴 (배열 사용)
# ============================================

# GDScript에는 가변 인자가 없으므로 배열을 사용합니다
func sum_all(numbers: Array) -> float:
	var total := 0.0
	for n in numbers:
		total += n
	return total

func join_strings(parts: Array[String], separator: String = ", ") -> String:
	var result := ""
	for i in range(parts.size()):
		result += parts[i]
		if i < parts.size() - 1:
			result += separator
	return result

# ============================================
# _ready() - 실행 예제
# ============================================

func _ready():
	print("=== 함수 (Functions) ===\n")

	# ============================================
	# 기본 함수 호출
	# ============================================
	print("--- 기본 함수 호출 ---\n")

	greet()
	greet_person("Godot")

	var result := add(10, 20)
	print("add(10, 20) = ", result)

	var item_desc := describe_item("포션", 3, 50.0)
	print("아이템: ", item_desc)

	# ============================================
	# 기본값 매개변수
	# ============================================
	print("\n--- 기본값 매개변수 ---\n")

	# 모든 매개변수 지정
	var hero := create_character("용사", 10, "마법사")
	print("모든 인자: ", hero)

	# 일부만 지정 (나머지는 기본값)
	var newbie := create_character("초보자")
	print("기본값 사용: ", newbie)

	# 중간 인자만 지정
	var knight := create_character("기사", 5)
	print("일부 지정: ", knight)

	# 설정 함수 (대부분 기본값)
	var default_config := configure()
	print("\n기본 설정: ", default_config)

	var custom_config := configure(1920, 1080, true, "Epic Game")
	print("커스텀 설정: ", custom_config)

	# ============================================
	# 반환값 활용
	# ============================================
	print("\n--- 반환값 활용 ---\n")

	log_message("게임 시작!")

	var numbers: Array[int] = [5, 2, 8, 1, 9, 3, 7]
	var min_max := get_min_max(numbers)
	print("배열: ", numbers)
	print("최솟값: %d, 최댓값: %d" % [min_max[0], min_max[1]])

	var stats := get_stats(numbers)
	print("통계: 합계=%d, 평균=%.1f, 개수=%d" % [stats["sum"], stats["avg"], stats["count"]])

	# ============================================
	# 재귀 함수
	# ============================================
	print("\n--- 재귀 함수 ---\n")

	for i in range(1, 8):
		print("  %d! = %d" % [i, factorial(i)])

	print("\n피보나치 수열:")
	var fib_str := ""
	for i in range(10):
		fib_str += str(fibonacci(i)) + " "
	print("  ", fib_str)

	# ============================================
	# static 함수
	# ============================================
	print("\n--- static 함수 ---\n")

	# static 함수는 인스턴스에서도 호출 가능
	print("clamp(15, 0, 10) = ", clamp_value(15, 0, 10))
	print("clamp(-5, 0, 10) = ", clamp_value(-5, 0, 10))
	print("clamp(5, 0, 10) = ", clamp_value(5, 0, 10))

	print("lerp(0, 100, 0.5) = ", lerp_value(0, 100, 0.5))
	print("lerp(0, 100, 0.25) = ", lerp_value(0, 100, 0.25))

	# ============================================
	# 7. 람다 (Lambda) 함수
	# ============================================
	print("\n--- 람다 (Lambda) 함수 ---\n")

	# 기본 람다
	var square := func(x: int) -> int: return x * x
	print("square(5) = ", square.call(5))

	# 여러 줄 람다
	var format_name := func(first: String, last: String) -> String:
		return last + " " + first
	print("format: ", format_name.call("길동", "홍"))

	# 변수에 할당하여 콜백으로 사용
	var operations := {
		"add": func(a_val: int, b_val: int) -> int: return a_val + b_val,
		"sub": func(a_val: int, b_val: int) -> int: return a_val - b_val,
		"mul": func(a_val: int, b_val: int) -> int: return a_val * b_val,
	}

	for op_name in operations:
		var op_result = operations[op_name].call(10, 3)
		print("  %s(10, 3) = %d" % [op_name, op_result])

	# 배열의 함수형 메서드에서 람다 활용
	var nums := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

	var evens = nums.filter(func(n): return n % 2 == 0)
	print("\n짝수: ", evens)

	var doubled = nums.map(func(n): return n * 2)
	print("2배: ", doubled)

	var total = nums.reduce(func(acc, n): return acc + n, 0)
	print("합계: ", total)

	# ============================================
	# 8. Callable
	# ============================================
	print("\n--- Callable ---\n")

	# 함수를 Callable 객체로 참조
	var callable_greet: Callable = greet_person
	callable_greet.call("Callable")

	# Callable을 변수로 전달
	var math_func: Callable = add
	print("Callable로 호출: ", math_func.call(100, 200))

	# bind() - 인자를 미리 바인딩
	var greet_godot: Callable = greet_person.bind("Godot 4")
	greet_godot.call()  # "Godot 4"가 자동으로 전달됨

	# is_valid() - Callable이 유효한지 확인
	print("Callable 유효?: ", callable_greet.is_valid())

	# ============================================
	# 9. 가변 인자 패턴
	# ============================================
	print("\n--- 가변 인자 패턴 ---\n")

	print("sum_all: ", sum_all([1, 2, 3, 4, 5]))
	print("join: ", join_strings(["Godot", "is", "awesome"], " "))
	print("join(기본): ", join_strings(["A", "B", "C"]))

	# ============================================
	# 10. 함수 참조와 고차 함수
	# ============================================
	print("\n--- 고차 함수 ---\n")

	# 함수를 인자로 받는 함수
	var processed := apply_to_array([1, 2, 3, 4, 5], func(x): return x * x)
	print("제곱 적용: ", processed)

	processed = apply_to_array([1, 2, 3, 4, 5], func(x): return x + 10)
	print("+10 적용: ", processed)

	# 조건 필터 함수
	var filtered := filter_array(
		[1, -2, 3, -4, 5, -6],
		func(x): return x > 0
	)
	print("양수 필터: ", filtered)

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. func 이름(매개변수) -> 반환타입:")
	print("2. 기본값: func f(x: int = 10)")
	print("3. static func: 인스턴스 없이 호출 가능")
	print("4. 람다: var f = func(x): return x * 2")
	print("5. Callable: 함수 참조를 변수로 다루기")
	print("6. .call(): Callable/람다 호출")
	print("7. .bind(): 인자 미리 바인딩")

# ============================================
# 고차 함수 (helper functions)
# ============================================

# 배열의 각 요소에 함수를 적용
func apply_to_array(arr: Array, fn: Callable) -> Array:
	var applied_result := []
	for item in arr:
		applied_result.append(fn.call(item))
	return applied_result

# 조건에 맞는 요소만 필터링
func filter_array(arr: Array, predicate: Callable) -> Array:
	var filtered_result := []
	for item in arr:
		if predicate.call(item):
			filtered_result.append(item)
	return filtered_result
