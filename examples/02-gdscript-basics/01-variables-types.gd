# Chapter 02 - GDScript Basics
# 01-variables-types.gd - Variables and Data Types
#
# 이 파일에서 배울 내용:
# - var, const 키워드로 변수와 상수 선언하기
# - int, float, String, bool 등 기본 데이터 타입
# - 타입 힌트(:)와 타입 추론(:=) 사용법
# - 타입 캐스팅(as)과 타입 확인 방법

extends Node

# ============================================
# 1. 변수 선언 (var)
# ============================================

# 클래스 레벨 변수 (멤버 변수)
var untyped_var = 42                 # 타입 없이 선언 (동적 타이핑)
var typed_var: int = 42              # 타입 힌트로 선언 (정적 타이핑)
var inferred_var := 42               # 타입 추론 (:= 사용, int로 추론)

# ============================================
# 2. 상수 선언 (const)
# ============================================

# 상수는 변경할 수 없는 값입니다 (컴파일 시점에 결정)
const MAX_SPEED: float = 300.0
const GAME_TITLE: String = "My Godot Game"
const TILE_SIZE := 64                # 타입 추론도 가능
const PI_APPROX := 3.14159
const DIRECTIONS := {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}

# ============================================
# 3. static 변수
# ============================================

# static 변수는 클래스의 모든 인스턴스가 공유합니다
static var instance_count: int = 0

func _ready():
	print("=== 변수와 타입 ===\n")

	# ============================================
	# 4. 기본 데이터 타입 - 정수 (int)
	# ============================================
	print("--- 정수 (int) ---\n")

	var a: int = 42
	var negative: int = -10
	var hex_val: int = 0xFF          # 16진수 (255)
	var bin_val: int = 0b1010        # 2진수 (10)
	var big_num: int = 1_000_000     # 밑줄로 자릿수 구분 (가독성)

	print("정수값: ", a)
	print("음수: ", negative)
	print("16진수 0xFF = ", hex_val)
	print("2진수 0b1010 = ", bin_val)
	print("큰 수 (밑줄 구분): ", big_num)

	# 정수 연산
	print("\n정수 연산:")
	print("  10 + 3 = ", 10 + 3)      # 덧셈
	print("  10 - 3 = ", 10 - 3)      # 뺄셈
	print("  10 * 3 = ", 10 * 3)      # 곱셈
	print("  10 / 3 = ", 10 / 3)      # 나눗셈 (int / int = int, 소수점 버림)
	print("  10 % 3 = ", 10 % 3)      # 나머지
	print("  2 ** 8 = ", 2 ** 8)      # 거듭제곱

	# ============================================
	# 5. 기본 데이터 타입 - 실수 (float)
	# ============================================
	print("\n--- 실수 (float) ---\n")

	var pi: float = 3.14159
	var small: float = 0.001
	var scientific: float = 1.5e3     # 과학적 표기법 (1500.0)
	var negative_exp: float = 2.5e-2  # 0.025

	print("PI: ", pi)
	print("작은 수: ", small)
	print("과학적 표기법 1.5e3 = ", scientific)
	print("음수 지수 2.5e-2 = ", negative_exp)

	# float 연산
	print("\nfloat 연산:")
	print("  10.0 / 3.0 = ", 10.0 / 3.0)  # 소수점 유지
	print("  int / float 혼합: 10 / 3.0 = ", 10 / 3.0)

	# 실수 비교 주의사항
	var f1 := 0.1 + 0.2
	print("\n실수 비교 주의:")
	print("  0.1 + 0.2 = ", f1)
	print("  0.1 + 0.2 == 0.3? ", f1 == 0.3)  # false일 수 있음!
	print("  is_equal_approx 사용: ", is_equal_approx(f1, 0.3))  # 안전한 비교

	# ============================================
	# 6. 기본 데이터 타입 - 문자열 (String)
	# ============================================
	print("\n--- 문자열 (String) ---\n")

	var greeting: String = "안녕하세요"
	var name_str: String = 'Godot'    # 작은따옴표도 가능
	var multiline: String = """
여러 줄
문자열을
작성할 수 있습니다."""
	var raw_string := r"C:\Users\path\n"  # 이스케이프 무시 (raw string)

	print("인사: ", greeting)
	print("이름: ", name_str)
	print("여러 줄: ", multiline)
	print("Raw 문자열: ", raw_string)

	# 문자열 연산
	print("\n문자열 연산:")
	print("  연결: ", "Hello" + " " + "World")
	print("  반복: ", "ha" * 3)  # "hahaha" (Godot 4에서는 .repeat() 사용)
	print("  길이: ", "Godot".length())
	print("  대문자: ", "hello".to_upper())
	print("  소문자: ", "HELLO".to_lower())
	print("  포함 여부: ", "Hello World".contains("World"))
	print("  시작 확인: ", "Godot".begins_with("Go"))
	print("  끝 확인: ", "Godot".ends_with("dot"))
	print("  치환: ", "Hello World".replace("World", "Godot"))
	print("  분할: ", "a,b,c,d".split(","))
	print("  공백 제거: ", "  hello  ".strip_edges())
	print("  부분 문자열: ", "Godot Engine".substr(0, 5))  # "Godot"

	# 문자열 포맷팅
	print("\n문자열 포맷팅:")
	print("  %% 연산자: %s is %d years old" % ["Godot", 4])
	print("  format(): {name} v{ver}".format({"name": "Godot", "ver": "4.3"}))
	print("  소수점 제어: %.2f" % 3.14159)  # "3.14"
	print("  패딩: '%10s'" % "right")  # 오른쪽 정렬
	print("  패딩: '%-10s'" % "left")  # 왼쪽 정렬

	# StringName - 최적화된 문자열 (내부 비교가 빠름)
	var sn: StringName = &"optimized_string"
	print("\nStringName: ", sn)

	# ============================================
	# 7. 기본 데이터 타입 - 불리언 (bool)
	# ============================================
	print("\n--- 불리언 (bool) ---\n")

	var is_alive: bool = true
	var is_dead: bool = false

	print("살아있는가: ", is_alive)
	print("죽었는가: ", is_dead)

	# 논리 연산
	print("\n논리 연산:")
	print("  true and false = ", true and false)   # false
	print("  true or false = ", true or false)     # true
	print("  not true = ", not true)               # false
	print("  true && false = ", true && false)     # && 도 사용 가능
	print("  true || false = ", true || false)     # || 도 사용 가능
	print("  !true = ", !true)                     # ! 도 사용 가능

	# Truthy / Falsy 값
	print("\nTruthy/Falsy 변환:")
	print("  bool(0) = ", bool(0))          # false
	print("  bool(1) = ", bool(1))          # true
	print("  bool(-1) = ", bool(-1))        # true
	print("  bool('') = ", bool(""))        # false
	print('  bool("hi") = ', bool("hi"))    # true
	print("  bool(null) = ", bool(null))    # false
	print("  bool([]) = ", bool([]))        # false
	print("  bool([1]) = ", bool([1]))      # true

	# ============================================
	# 8. 타입 힌트와 타입 추론
	# ============================================
	print("\n--- 타입 힌트와 타입 추론 ---\n")

	# 타입 없이 (동적 타이핑) - 권장하지 않음
	var dynamic_var = "hello"
	dynamic_var = 42        # 타입 변경 가능 (위험!)
	dynamic_var = true      # 또 변경 가능
	print("동적 변수 (타입 변경 가능): ", dynamic_var)

	# 타입 힌트 사용 (권장)
	var safe_int: int = 10
	# safe_int = "hello"  # 에러! int에 String 할당 불가

	# 타입 추론 (:=)
	var auto_int := 100        # int로 추론
	var auto_float := 3.14     # float로 추론
	var auto_string := "text"  # String으로 추론
	var auto_bool := true      # bool로 추론

	print("타입 추론 결과:")
	print("  100 -> ", type_string(typeof(auto_int)))
	print("  3.14 -> ", type_string(typeof(auto_float)))
	print("  'text' -> ", type_string(typeof(auto_string)))
	print("  true -> ", type_string(typeof(auto_bool)))

	# ============================================
	# 9. 타입 캐스팅과 변환
	# ============================================
	print("\n--- 타입 캐스팅과 변환 ---\n")

	# 명시적 타입 변환
	var str_num := "42"
	var num_from_str := int(str_num)      # String -> int
	var float_from_str := float("3.14")   # String -> float
	var str_from_int := str(42)           # int -> String
	var str_from_float := str(3.14)       # float -> String

	print("String -> int: '42' -> ", num_from_str)
	print("String -> float: '3.14' -> ", float_from_str)
	print("int -> String: 42 -> '", str_from_int, "'")
	print("float -> String: 3.14 -> '", str_from_float, "'")

	# int <-> float 변환
	var i := int(3.7)    # 3 (소수점 버림)
	var f := float(42)   # 42.0
	print("\nfloat -> int: 3.7 -> ", i, " (소수점 버림)")
	print("int -> float: 42 -> ", f)

	# as 키워드 (안전한 캐스팅 - 노드 타입에 주로 사용)
	# var sprite := node as Sprite2D  # 실패하면 null 반환
	print("\n'as' 키워드: 안전한 타입 캐스팅 (실패 시 null)")

	# typeof() - 타입 확인
	print("\ntypeof() 타입 확인:")
	print("  42 의 타입: ", type_string(typeof(42)))
	print("  3.14 의 타입: ", type_string(typeof(3.14)))
	print('  "hi" 의 타입: ', type_string(typeof("hi")))
	print("  true 의 타입: ", type_string(typeof(true)))
	print("  null 의 타입: ", type_string(typeof(null)))
	print("  [] 의 타입: ", type_string(typeof([])))
	print("  {} 의 타입: ", type_string(typeof({})))
	print("  Vector2() 타입: ", type_string(typeof(Vector2())))

	# is 키워드 - 타입 확인
	var test_val = 42
	print("\n'is' 키워드 타입 확인:")
	print("  42 is int: ", test_val is int)
	print("  42 is float: ", test_val is float)

	# ============================================
	# 10. 특수 값과 Variant
	# ============================================
	print("\n--- 특수 값과 Variant ---\n")

	# null - 값이 없음을 나타냄
	var empty_var = null
	print("null 값: ", empty_var)
	print("null 체크: ", empty_var == null)

	# Variant - GDScript의 모든 값을 담을 수 있는 범용 타입
	# 타입 힌트 없이 선언한 변수는 Variant입니다
	var variant_var = 42
	print("\nVariant 타입 변경 데모:")
	print("  값: ", variant_var, " 타입: ", type_string(typeof(variant_var)))
	variant_var = "hello"
	print("  값: ", variant_var, " 타입: ", type_string(typeof(variant_var)))
	variant_var = Vector2(1, 2)
	print("  값: ", variant_var, " 타입: ", type_string(typeof(variant_var)))

	# ============================================
	# 11. Godot 내장 타입 미리보기
	# ============================================
	print("\n--- Godot 내장 타입 ---\n")

	# Vector2 - 2D 좌표/방향
	var pos := Vector2(100, 200)
	var dir := Vector2.RIGHT  # (1, 0)
	print("Vector2: ", pos, " 방향: ", dir)

	# Vector3 - 3D 좌표/방향
	var pos3d := Vector3(1, 2, 3)
	print("Vector3: ", pos3d)

	# Color - 색상 (RGBA)
	var red := Color.RED
	var custom_color := Color(0.5, 0.8, 1.0, 1.0)
	var hex_color := Color.html("#FF5733")
	print("Color RED: ", red)
	print("커스텀 색상: ", custom_color)
	print("Hex 색상: ", hex_color)

	# Rect2 - 사각형 영역
	var rect := Rect2(0, 0, 100, 50)  # x, y, width, height
	print("Rect2: ", rect)

	# Transform2D - 2D 변환 행렬
	var transform := Transform2D.IDENTITY
	print("Transform2D: ", transform)

	# ============================================
	# 12. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. var: 변수 선언 / const: 상수 선언")
	print("2. 기본 타입: int, float, String, bool")
	print("3. 타입 힌트(: Type)를 사용하면 안전합니다")
	print("4. := 연산자로 타입을 자동 추론합니다")
	print("5. typeof()와 is로 타입을 확인합니다")
	print("6. int(), float(), str()로 타입을 변환합니다")
	print("7. Vector2, Color 등 Godot 내장 타입이 있습니다")
