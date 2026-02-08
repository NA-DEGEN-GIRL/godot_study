# Chapter 02 - GDScript Basics
# 02-collections.gd - Arrays and Dictionaries
#
# 이 파일에서 배울 내용:
# - Array 생성, 접근, 수정 방법
# - Dictionary 생성, 접근, 수정 방법
# - 타입이 지정된 배열 (Typed Arrays)
# - 주요 컬렉션 메서드 (append, find, sort, filter, map 등)

extends Node

func _ready():
	print("=== 컬렉션 (Collections) ===\n")

	# ============================================
	# 1. Array 기본
	# ============================================
	print("--- Array 기본 ---\n")

	# 배열 생성
	var empty_array := []
	var numbers := [1, 2, 3, 4, 5]
	var mixed := [1, "hello", 3.14, true, null]  # 다양한 타입 혼합 가능
	var nested := [[1, 2], [3, 4], [5, 6]]       # 중첩 배열

	print("빈 배열: ", empty_array)
	print("숫자 배열: ", numbers)
	print("혼합 배열: ", mixed)
	print("중첩 배열: ", nested)

	# 배열 접근 (0부터 시작)
	print("\n배열 접근:")
	print("  첫 번째: ", numbers[0])     # 1
	print("  마지막: ", numbers[-1])      # 5 (음수 인덱스)
	print("  두 번째: ", numbers[1])      # 2
	print("  뒤에서 두 번째: ", numbers[-2])  # 4

	# 중첩 배열 접근
	print("  중첩[1][0]: ", nested[1][0])  # 3

	# ============================================
	# 2. Array 수정
	# ============================================
	print("\n--- Array 수정 ---\n")

	var arr := [10, 20, 30]
	print("원본: ", arr)

	# 요소 추가
	arr.append(40)                # 끝에 추가
	print("append(40): ", arr)

	arr.push_back(50)             # append와 동일
	print("push_back(50): ", arr)

	arr.push_front(0)             # 앞에 추가
	print("push_front(0): ", arr)

	arr.insert(2, 15)             # 인덱스 2에 삽입
	print("insert(2, 15): ", arr)

	# 요소 제거
	arr.pop_back()                # 마지막 요소 제거 및 반환
	print("pop_back(): ", arr)

	arr.pop_front()               # 첫 번째 요소 제거 및 반환
	print("pop_front(): ", arr)

	arr.remove_at(1)              # 인덱스 1 제거
	print("remove_at(1): ", arr)

	arr.erase(30)                 # 값 30을 찾아서 제거 (첫 번째만)
	print("erase(30): ", arr)

	# 요소 변경
	arr[0] = 99
	print("arr[0] = 99: ", arr)

	# ============================================
	# 3. Array 검색과 확인
	# ============================================
	print("\n--- Array 검색 ---\n")

	var fruits := ["apple", "banana", "cherry", "date", "banana"]

	# 검색
	print("find('banana'): ", fruits.find("banana"))        # 1 (첫 번째 위치)
	print("rfind('banana'): ", fruits.rfind("banana"))       # 4 (마지막 위치)
	print("find('grape'): ", fruits.find("grape"))           # -1 (없으면)
	print("has('cherry'): ", fruits.has("cherry"))           # true
	print("count('banana'): ", fruits.count("banana"))       # 2

	# 크기와 상태
	print("\n배열 크기와 상태:")
	print("  size(): ", fruits.size())          # 5
	print("  is_empty(): ", fruits.is_empty())  # false
	print("  빈 배열.is_empty(): ", [].is_empty())  # true

	# ============================================
	# 4. Array 정렬과 변환
	# ============================================
	print("\n--- Array 정렬과 변환 ---\n")

	var unsorted := [3, 1, 4, 1, 5, 9, 2, 6]
	print("정렬 전: ", unsorted)

	# sort() - 원본을 수정합니다 (in-place)
	var to_sort := unsorted.duplicate()  # 복사 후 정렬
	to_sort.sort()
	print("sort(): ", to_sort)

	# reverse() - 뒤집기
	var to_reverse := [1, 2, 3, 4, 5]
	to_reverse.reverse()
	print("reverse(): ", to_reverse)

	# sort_custom - 커스텀 정렬
	var words := ["banana", "apple", "cherry"]
	words.sort_custom(func(a, b): return a.length() < b.length())
	print("길이 기준 정렬: ", words)

	# shuffle() - 랜덤 섞기
	var cards := [1, 2, 3, 4, 5]
	cards.shuffle()
	print("shuffle(): ", cards)

	# ============================================
	# 5. Array 슬라이싱과 결합
	# ============================================
	print("\n--- Array 슬라이싱 ---\n")

	var data := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

	# slice(begin, end) - end는 포함하지 않음
	print("slice(2, 5): ", data.slice(2, 5))     # [2, 3, 4]
	print("slice(5): ", data.slice(5))            # [5, 6, 7, 8, 9]
	print("slice(-3): ", data.slice(-3))          # [7, 8, 9]

	# 배열 연결
	var a := [1, 2, 3]
	var b := [4, 5, 6]
	print("연결 (+): ", a + b)                    # [1, 2, 3, 4, 5, 6]

	# append_array - 다른 배열의 모든 요소 추가
	var c := [1, 2]
	c.append_array([3, 4])
	print("append_array: ", c)

	# ============================================
	# 6. Array 함수형 메서드 (map, filter, reduce)
	# ============================================
	print("\n--- 함수형 메서드 ---\n")

	var nums := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

	# filter() - 조건에 맞는 요소만 필터링
	var evens = nums.filter(func(n): return n % 2 == 0)
	print("짝수 필터: ", evens)  # [2, 4, 6, 8, 10]

	# map() - 각 요소를 변환
	var doubled = nums.map(func(n): return n * 2)
	print("2배 변환: ", doubled)  # [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

	var squared = nums.map(func(n): return n * n)
	print("제곱: ", squared)

	# reduce() - 누적 계산
	var total = nums.reduce(func(acc, n): return acc + n, 0)
	print("합계 (reduce): ", total)  # 55

	var product = [1, 2, 3, 4, 5].reduce(func(acc, n): return acc * n, 1)
	print("곱 (reduce): ", product)  # 120

	# any() - 하나라도 조건을 만족하면 true
	var has_big = nums.any(func(n): return n > 8)
	print("8보다 큰 수 있음?: ", has_big)  # true

	# all() - 모두 조건을 만족하면 true
	var all_positive = nums.all(func(n): return n > 0)
	print("모두 양수?: ", all_positive)  # true

	# ============================================
	# 7. Typed Arrays (타입 지정 배열)
	# ============================================
	print("\n--- Typed Arrays ---\n")

	# 타입을 지정하면 해당 타입만 저장 가능 (안전성 향상)
	var int_array: Array[int] = [1, 2, 3, 4, 5]
	var str_array: Array[String] = ["hello", "world"]
	var float_array: Array[float] = [1.0, 2.5, 3.7]

	print("int 배열: ", int_array)
	print("String 배열: ", str_array)
	print("float 배열: ", float_array)

	# 타입이 맞지 않으면 에러 발생
	# int_array.append("hello")  # 에러! String을 int 배열에 추가 불가

	int_array.append(6)
	print("int 배열에 6 추가: ", int_array)

	# PackedArray - 메모리 최적화된 배열 (특정 타입 전용)
	var packed_int := PackedInt32Array([1, 2, 3, 4])
	var packed_float := PackedFloat32Array([1.1, 2.2, 3.3])
	var packed_string := PackedStringArray(["a", "b", "c"])
	var packed_vector := PackedVector2Array([Vector2(0, 0), Vector2(1, 1)])
	var packed_color := PackedColorArray([Color.RED, Color.BLUE])

	print("\nPackedInt32Array: ", packed_int)
	print("PackedFloat32Array: ", packed_float)
	print("PackedStringArray: ", packed_string)
	print("PackedVector2Array: ", packed_vector)
	print("PackedColorArray: ", packed_color)

	# ============================================
	# 8. Dictionary 기본
	# ============================================
	print("\n--- Dictionary 기본 ---\n")

	# 딕셔너리 생성 (키-값 쌍)
	var empty_dict := {}
	var player := {
		"name": "Hero",
		"level": 10,
		"hp": 100,
		"position": Vector2(50, 100),
		"skills": ["fireball", "heal"]
	}

	print("빈 딕셔너리: ", empty_dict)
	print("플레이어: ", player)

	# 값 접근
	print("\n값 접근:")
	print("  ['name']: ", player["name"])
	print("  .get('level'): ", player.get("level"))
	print("  .get('없는키', 기본값): ", player.get("missing", "기본값"))

	# Lua 스타일 키 (식별자처럼 사용)
	var config := {
		health = 100,       # 따옴표 없이 키 작성 (내부적으로 StringName)
		speed = 200.0,
		jump_force = 400.0
	}
	print("\nLua 스타일: ", config)

	# ============================================
	# 9. Dictionary 수정
	# ============================================
	print("\n--- Dictionary 수정 ---\n")

	var inventory := {"sword": 1, "potion": 5}
	print("원본: ", inventory)

	# 추가/수정
	inventory["shield"] = 1           # 새 키 추가
	print("추가 ['shield']: ", inventory)

	inventory["potion"] = 10          # 기존 값 수정
	print("수정 ['potion']: ", inventory)

	# merge() - 다른 딕셔너리 병합
	inventory.merge({"arrow": 50, "potion": 15})  # 기존 키는 덮어쓰지 않음
	print("merge (기본): ", inventory)

	inventory.merge({"potion": 20}, true)  # true면 기존 키도 덮어씀
	print("merge (덮어쓰기): ", inventory)

	# 삭제
	inventory.erase("arrow")
	print("erase('arrow'): ", inventory)

	# ============================================
	# 10. Dictionary 검색과 순회
	# ============================================
	print("\n--- Dictionary 검색과 순회 ---\n")

	var scores := {
		"Alice": 95,
		"Bob": 87,
		"Charlie": 92,
		"Diana": 98
	}

	# 검색
	print("has('Bob'): ", scores.has("Bob"))         # true
	print("has('Eve'): ", scores.has("Eve"))          # false
	print("size(): ", scores.size())                  # 4

	# 키와 값 목록
	print("keys(): ", scores.keys())
	print("values(): ", scores.values())

	# 순회 - 키만
	print("\n키 순회:")
	for key in scores:
		print("  %s: %d" % [key, scores[key]])

	# 순회 - 키와 값 (Godot 4에서는 items() 없음, keys() 사용)
	print("\n최고 점수 찾기:")
	var best_name := ""
	var best_score := 0
	for name_key in scores:
		if scores[name_key] > best_score:
			best_score = scores[name_key]
			best_name = name_key
	print("  최고: %s (%d점)" % [best_name, best_score])

	# ============================================
	# 11. 중첩 컬렉션 (실전 예제)
	# ============================================
	print("\n--- 중첩 컬렉션 ---\n")

	# 게임 데이터 구조 예시
	var game_data := {
		"players": [
			{"name": "Player1", "score": 100, "items": ["sword", "shield"]},
			{"name": "Player2", "score": 200, "items": ["staff", "robe"]},
		],
		"settings": {
			"difficulty": "normal",
			"volume": 0.8,
			"resolution": Vector2i(1920, 1080)
		},
		"version": "1.0.0"
	}

	print("게임 데이터:")
	print("  버전: ", game_data["version"])
	print("  난이도: ", game_data["settings"]["difficulty"])
	print("  Player1 점수: ", game_data["players"][0]["score"])
	print("  Player2 아이템: ", game_data["players"][1]["items"])

	# ============================================
	# 12. Array와 Dictionary 유용한 패턴
	# ============================================
	print("\n--- 유용한 패턴 ---\n")

	# 배열 복사 (얕은 복사 vs 깊은 복사)
	var original := [[1, 2], [3, 4]]
	var shallow := original.duplicate()       # 얕은 복사
	var deep := original.duplicate(true)      # 깊은 복사

	original[0][0] = 99
	print("원본 수정 후:")
	print("  원본: ", original)       # [[99, 2], [3, 4]]
	print("  얕은 복사: ", shallow)    # [[99, 2], [3, 4]] - 영향 받음!
	print("  깊은 복사: ", deep)       # [[1, 2], [3, 4]]  - 영향 없음

	# 배열에서 중복 제거
	var with_dupes := [1, 2, 2, 3, 3, 3, 4]
	var unique := []
	for item in with_dupes:
		if not unique.has(item):
			unique.append(item)
	print("\n중복 제거: ", with_dupes, " -> ", unique)

	# Dictionary를 활용한 카운터
	var text := "hello world"
	var char_count := {}
	for ch in text:
		char_count[ch] = char_count.get(ch, 0) + 1
	print("\n문자 카운트 ('hello world'):")
	for ch in char_count:
		if ch != " ":
			print("  '%s': %d번" % [ch, char_count[ch]])

	# ============================================
	# 13. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. Array: 순서가 있는 리스트, [] 로 생성")
	print("2. Dictionary: 키-값 쌍, {} 로 생성")
	print("3. Array[Type]: 타입 지정 배열 (안전)")
	print("4. filter/map/reduce: 함수형 배열 처리")
	print("5. PackedArray: 메모리 최적화 배열")
	print("6. .duplicate(true): 깊은 복사")
	print("7. .get(key, default): 안전한 접근")
