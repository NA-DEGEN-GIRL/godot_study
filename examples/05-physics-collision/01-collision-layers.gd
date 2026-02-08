# Chapter 05 - Physics & Collision
# 01-collision-layers.gd - 충돌 레이어와 마스크 시스템
#
# 이 파일에서 배울 내용:
# - collision_layer와 collision_mask의 차이점
# - 비트 연산을 활용한 레이어 설정
# - set_collision_layer_value / set_collision_mask_value 사용법
# - 실전 레이어 구성 예시 (플레이어, 적, 아이템 등)
#
# Godot의 충돌 시스템은 32개의 레이어(비트)를 사용합니다.
# collision_layer: "나는 이 레이어에 존재한다" (내 정체)
# collision_mask: "나는 이 레이어와 충돌을 감지한다" (감지 대상)

extends CharacterBody2D

# ============================================
# 1. 충돌 레이어 기본 개념
# ============================================
# Godot는 32개의 물리 레이어를 제공합니다.
# 각 레이어는 하나의 비트(bit)로 표현됩니다.
#
# 레이어 1 = 비트 0 = 0b0001 = 1
# 레이어 2 = 비트 1 = 0b0010 = 2
# 레이어 3 = 비트 2 = 0b0100 = 4
# 레이어 4 = 비트 3 = 0b1000 = 8
#
# 일반적인 레이어 구성:
# 레이어 1: 환경/지형 (Terrain)
# 레이어 2: 플레이어 (Player)
# 레이어 3: 적 (Enemy)
# 레이어 4: 아이템 (Item)
# 레이어 5: 플레이어 총알 (Player Bullet)
# 레이어 6: 적 총알 (Enemy Bullet)
# 레이어 7: 트리거/센서 (Trigger Zone)

func _ready():
	print("=== Chapter 05-1: 충돌 레이어와 마스크 ===\n")

	_explain_layer_mask_concept()
	_demonstrate_bit_operations()
	_show_layer_value_methods()
	_practical_layer_setup()
	_show_collision_matrix()
	_demonstrate_runtime_changes()

# ============================================
# 2. Layer와 Mask 개념 설명
# ============================================

func _explain_layer_mask_concept():
	print("--- 2. collision_layer vs collision_mask ---")

	# collision_layer: 이 오브젝트가 존재하는 레이어
	# "나는 누구인가?"
	print("collision_layer: 이 객체가 존재하는 레이어 (나의 정체)")
	print("collision_mask: 이 객체가 감지하는 레이어 (감지 대상)")

	# 충돌이 발생하려면:
	# A의 mask가 B의 layer를 포함하거나
	# B의 mask가 A의 layer를 포함해야 함
	print("\n[충돌 조건]")
	print("A와 B가 충돌하려면:")
	print("  (A.mask & B.layer) != 0  또는")
	print("  (B.mask & A.layer) != 0")

	# 예시: 플레이어와 적의 충돌
	var player_layer = 2   # 레이어 2에 존재
	var player_mask = 1 | 4 | 8  # 레이어 1(지형), 3(적), 4(아이템) 감지

	var enemy_layer = 4    # 레이어 3에 존재 (비트값 4)
	var enemy_mask = 1 | 2  # 레이어 1(지형), 2(플레이어) 감지

	# 충돌 확인
	var collision_check = (player_mask & enemy_layer) != 0
	print("\n플레이어 mask & 적 layer = %d & %d = %d (충돌: %s)" % [
		player_mask, enemy_layer, player_mask & enemy_layer, str(collision_check)
	])

	collision_check = (enemy_mask & player_layer) != 0
	print("적 mask & 플레이어 layer = %d & %d = %d (충돌: %s)" % [
		enemy_mask, player_layer, enemy_mask & player_layer, str(collision_check)
	])

	print()

# ============================================
# 3. 비트 연산으로 레이어 다루기
# ============================================

func _demonstrate_bit_operations():
	print("--- 3. 비트 연산을 활용한 레이어 설정 ---")

	# 레이어 번호를 비트값으로 변환
	# 레이어 N의 비트값 = 1 << (N - 1)
	print("[레이어 번호 -> 비트값 변환]")
	for i in range(1, 9):
		var bit_value = 1 << (i - 1)
		print("  레이어 %d = 1 << %d = %d (0b%s)" % [
			i, i - 1, bit_value, _to_binary(bit_value, 8)
		])

	# 여러 레이어 조합하기 (OR 연산)
	print("\n[여러 레이어 조합 - OR 연산 (|)]")
	var layers_1_and_3 = (1 << 0) | (1 << 2)  # 레이어 1 + 레이어 3
	print("  레이어 1 + 3 = %d (0b%s)" % [layers_1_and_3, _to_binary(layers_1_and_3, 8)])

	var layers_2_4_5 = (1 << 1) | (1 << 3) | (1 << 4)  # 레이어 2 + 4 + 5
	print("  레이어 2 + 4 + 5 = %d (0b%s)" % [layers_2_4_5, _to_binary(layers_2_4_5, 8)])

	# 특정 레이어 확인 (AND 연산)
	print("\n[특정 레이어 포함 확인 - AND 연산 (&)]")
	var current_mask = 0b00010101  # 레이어 1, 3, 5
	print("  현재 마스크: 0b%s (레이어 1, 3, 5)" % _to_binary(current_mask, 8))

	var has_layer_3 = (current_mask & (1 << 2)) != 0
	print("  레이어 3 포함? %s" % str(has_layer_3))

	var has_layer_4 = (current_mask & (1 << 3)) != 0
	print("  레이어 4 포함? %s" % str(has_layer_4))

	# 레이어 추가 (OR 대입)
	print("\n[레이어 추가 - OR 대입 (|=)]")
	var mask = 0b00000001  # 레이어 1만
	print("  시작: 0b%s" % _to_binary(mask, 8))

	mask |= (1 << 2)  # 레이어 3 추가
	print("  레이어 3 추가 후: 0b%s" % _to_binary(mask, 8))

	mask |= (1 << 4)  # 레이어 5 추가
	print("  레이어 5 추가 후: 0b%s" % _to_binary(mask, 8))

	# 레이어 제거 (AND NOT)
	print("\n[레이어 제거 - AND NOT (&= ~)]")
	mask &= ~(1 << 2)  # 레이어 3 제거
	print("  레이어 3 제거 후: 0b%s" % _to_binary(mask, 8))

	# 레이어 토글 (XOR)
	print("\n[레이어 토글 - XOR (^)]")
	mask ^= (1 << 4)  # 레이어 5 토글 (켜져있으면 끄고, 꺼져있으면 켜기)
	print("  레이어 5 토글 후: 0b%s" % _to_binary(mask, 8))

	print()

# ============================================
# 4. set_collision_layer_value / mask_value
# ============================================

func _show_layer_value_methods():
	print("--- 4. Godot API: layer_value / mask_value 메서드 ---")

	# Godot 4에서는 비트 연산 대신 편리한 메서드를 제공합니다
	# 주의: 이 메서드들은 실제 PhysicsBody2D 노드에서만 동작합니다

	print("[set_collision_layer_value(layer_number, value)]")
	print("  레이어 번호(1~32)로 직접 설정")
	print("")
	print("  # 플레이어를 레이어 2에 배치")
	print("  collision_layer = 0  # 먼저 모든 레이어 초기화")
	print("  set_collision_layer_value(2, true)  # 레이어 2 활성화")
	print("")

	# 실제 코드 (이 스크립트가 CharacterBody2D에 붙어있을 때)
	# 주의: 씬에서 실행될 때만 실제로 동작합니다
	collision_layer = 0
	set_collision_layer_value(2, true)  # 레이어 2에 존재
	print("  현재 collision_layer: %d (레이어 2 = 비트값 2)" % collision_layer)

	print("\n[set_collision_mask_value(layer_number, value)]")
	print("  감지할 레이어를 번호로 직접 설정")
	print("")
	print("  # 플레이어가 지형(1), 적(3), 아이템(4)과 충돌 감지")
	print("  collision_mask = 0  # 먼저 초기화")
	print("  set_collision_mask_value(1, true)  # 지형 감지")
	print("  set_collision_mask_value(3, true)  # 적 감지")
	print("  set_collision_mask_value(4, true)  # 아이템 감지")

	collision_mask = 0
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	set_collision_mask_value(4, true)
	print("  현재 collision_mask: %d" % collision_mask)

	# get 메서드로 확인
	print("\n[get_collision_layer_value / get_collision_mask_value]")
	for i in range(1, 6):
		var in_layer = get_collision_layer_value(i)
		var in_mask = get_collision_mask_value(i)
		print("  레이어 %d: layer=%s, mask=%s" % [i, str(in_layer), str(in_mask)])

	print()

# ============================================
# 5. 실전 레이어 구성 예시
# ============================================

func _practical_layer_setup():
	print("--- 5. 실전 레이어 구성 ---")

	# 게임 레이어 정의 (상수로 관리하는 것을 권장)
	# 실제 프로젝트에서는 별도 Autoload에 정의
	var LAYER = {
		"TERRAIN":        1,   # 레이어 1: 지형
		"PLAYER":         2,   # 레이어 2: 플레이어
		"ENEMY":          3,   # 레이어 3: 적
		"ITEM":           4,   # 레이어 4: 아이템
		"PLAYER_BULLET":  5,   # 레이어 5: 플레이어 총알
		"ENEMY_BULLET":   6,   # 레이어 6: 적 총알
		"TRIGGER":        7,   # 레이어 7: 트리거 영역
	}

	print("[게임 레이어 설정]")
	for key in LAYER:
		print("  레이어 %d: %s" % [LAYER[key], key])

	# 각 오브젝트의 레이어/마스크 설정
	print("\n[각 오브젝트의 충돌 설정]")

	# 플레이어: 레이어 2에 존재, 지형/적/아이템/적총알/트리거 감지
	var player_setup = {
		"name": "Player",
		"layer": [LAYER.PLAYER],
		"mask": [LAYER.TERRAIN, LAYER.ENEMY, LAYER.ITEM,
				 LAYER.ENEMY_BULLET, LAYER.TRIGGER]
	}
	_print_collision_setup(player_setup)

	# 적: 레이어 3에 존재, 지형/플레이어/플레이어총알 감지
	var enemy_setup = {
		"name": "Enemy",
		"layer": [LAYER.ENEMY],
		"mask": [LAYER.TERRAIN, LAYER.PLAYER, LAYER.PLAYER_BULLET]
	}
	_print_collision_setup(enemy_setup)

	# 아이템: 레이어 4에 존재, 플레이어만 감지
	var item_setup = {
		"name": "Item (Coin/Heart)",
		"layer": [LAYER.ITEM],
		"mask": [LAYER.PLAYER]
	}
	_print_collision_setup(item_setup)

	# 플레이어 총알: 레이어 5에 존재, 지형/적 감지
	var player_bullet_setup = {
		"name": "Player Bullet",
		"layer": [LAYER.PLAYER_BULLET],
		"mask": [LAYER.TERRAIN, LAYER.ENEMY]
	}
	_print_collision_setup(player_bullet_setup)

	# 적 총알: 레이어 6에 존재, 지형/플레이어 감지
	var enemy_bullet_setup = {
		"name": "Enemy Bullet",
		"layer": [LAYER.ENEMY_BULLET],
		"mask": [LAYER.TERRAIN, LAYER.PLAYER]
	}
	_print_collision_setup(enemy_bullet_setup)

	print()

# ============================================
# 6. 충돌 매트릭스 시각화
# ============================================

func _show_collision_matrix():
	print("--- 6. 충돌 매트릭스 ---")
	print("누가 누구와 충돌하는지 한눈에 보기:")
	print("")
	print("             지형  플레이어  적    아이템  P총알  E총알  트리거")
	print("  지형        -     O       O      -      O      O      -")
	print("  플레이어    O     -       O      O      -      O      O")
	print("  적          O     O       -      -      O      -      -")
	print("  아이템      -     O       -      -      -      -      -")
	print("  P총알       O     -       O      -      -      -      -")
	print("  E총알       O     O       -      -      -      -      -")
	print("  트리거      -     O       -      -      -      -      -")
	print("")
	print("O = 충돌 감지됨, - = 무시됨")
	print()

# ============================================
# 7. 런타임에서 레이어 변경하기
# ============================================

func _demonstrate_runtime_changes():
	print("--- 7. 런타임 레이어 변경 ---")

	# 무적 상태 만들기 (적 총알 무시)
	print("[무적 상태 - 적 총알 레이어 마스크 해제]")
	print("  # 무적 시작")
	print("  set_collision_mask_value(6, false)  # 적 총알 무시")
	print("  await get_tree().create_timer(3.0).timeout")
	print("  # 무적 종료")
	print("  set_collision_mask_value(6, true)   # 적 총알 다시 감지")

	# 유령 상태 만들기 (벽 통과)
	print("\n[유령 상태 - 지형 레이어 마스크 해제]")
	print("  # 유령 모드 시작")
	print("  set_collision_mask_value(1, false)  # 지형 통과")
	print("  # 유령 모드 종료")
	print("  set_collision_mask_value(1, true)   # 지형 다시 감지")

	# 팀 변경 (적에서 아군으로)
	print("\n[팀 변경 - 레이어 자체를 변경]")
	print("  # 적이 아군으로 전향")
	print("  set_collision_layer_value(3, false)  # 적 레이어에서 제거")
	print("  set_collision_layer_value(2, true)   # 플레이어 레이어에 추가")
	print("  # 마스크도 업데이트")
	print("  collision_mask = 0")
	print("  set_collision_mask_value(1, true)   # 지형")
	print("  set_collision_mask_value(3, true)   # 적 (이제 적을 감지)")

	# 함수 헬퍼 예시
	print("\n[편의 함수 패턴]")
	print("  func set_invincible(enabled: bool):")
	print("      set_collision_mask_value(6, !enabled)")
	print("      # 시각적 피드백 (깜빡임 등)")
	print("      modulate.a = 0.5 if enabled else 1.0")

	print("\n=== 충돌 레이어 학습 완료 ===")

# ============================================
# 유틸리티 함수
# ============================================

func _to_binary(value: int, digits: int) -> String:
	var result = ""
	for i in range(digits - 1, -1, -1):
		result += "1" if (value & (1 << i)) else "0"
	return result

func _print_collision_setup(setup: Dictionary):
	var layer_str = ""
	for l in setup.layer:
		layer_str += str(l) + " "
	var mask_str = ""
	for m in setup.mask:
		mask_str += str(m) + " "
	print("  %s:" % setup.name)
	print("    layer: [%s] | mask: [%s]" % [layer_str.strip_edges(), mask_str.strip_edges()])
