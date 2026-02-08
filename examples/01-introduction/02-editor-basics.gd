# Chapter 01 - Godot Engine Introduction
# 02-editor-basics.gd - Editor Features and Node References
#
# 이 파일에서 배울 내용:
# - @export 변수로 에디터에서 값 조정하기
# - @onready로 노드 참조 안전하게 가져오기
# - $ 연산자와 get_node()로 노드 접근하기
# - 에디터 Inspector에서 사용할 수 있는 다양한 어노테이션

extends Node

# ============================================
# 1. @export - 에디터 Inspector에 변수 노출
# ============================================

# @export를 붙이면 Godot 에디터의 Inspector 패널에서 값을 수정할 수 있습니다.
# 이렇게 하면 코드를 수정하지 않고도 게임 파라미터를 조정할 수 있습니다.

## 플레이어의 이동 속도 (pixels/second)
@export var move_speed: float = 200.0

## 플레이어의 최대 체력
@export var max_health: int = 100

## 플레이어의 이름
@export var player_name: String = "Hero"

## 디버그 모드 활성화 여부
@export var debug_mode: bool = false

# ============================================
# 2. @export 고급 옵션
# ============================================

# 범위 제한 - 슬라이더로 표시됨
@export_range(0, 100, 1) var health: int = 100
@export_range(0.0, 10.0, 0.1) var gravity_scale: float = 1.0
@export_range(1, 1000, 1, "suffix:px") var jump_height: int = 300

# 파일 경로 선택기
@export_file("*.png", "*.jpg") var texture_path: String = ""
@export_dir var save_directory: String = ""

# 멀티라인 텍스트 에디터
@export_multiline var description: String = "캐릭터 설명을 입력하세요."

# 색상 선택기
@export var tint_color: Color = Color.WHITE

# 열거형 선택 (드롭다운)
@export_enum("Warrior", "Mage", "Archer", "Thief") var character_class: String = "Warrior"
@export_enum("Easy:0", "Normal:1", "Hard:2") var difficulty: int = 1

# 그룹과 서브그룹으로 Inspector 정리
@export_group("Movement")
@export var walk_speed: float = 100.0
@export var run_speed: float = 250.0
@export var acceleration: float = 500.0

@export_group("Combat")
@export var attack_damage: int = 10
@export var attack_range: float = 50.0

@export_subgroup("Defense")
@export var armor: int = 5
@export var block_chance: float = 0.2

# 노드 경로 - 에디터에서 노드를 드래그해서 연결
@export var target_node: NodePath = NodePath("")

# 리소스 참조
@export var custom_font: Font = null

# 플래그 (비트마스크)
@export_flags("Fire", "Water", "Earth", "Wind") var elements: int = 0

# ============================================
# 3. @onready - 안전한 노드 참조
# ============================================

# @onready는 _ready() 시점에 변수를 초기화합니다.
# 노드 참조를 가져올 때 안전하게 사용할 수 있습니다.
# (씬 트리가 준비된 후에 참조를 가져오므로 null 에러를 방지합니다)

# $ 연산자 사용 (get_node()의 축약형)
# 주의: 이 예제에서는 해당 노드가 없으므로 주석으로 설명합니다.
# 실제 씬에서는 아래와 같이 사용합니다:
#
# @onready var sprite = $Sprite2D
# @onready var collision = $CollisionShape2D
# @onready var animation_player = $AnimationPlayer
# @onready var label = $UI/HUD/Label  # 중첩된 경로

# get_node() 명시적 사용
# @onready var camera = get_node("Camera2D")
# @onready var timer = get_node("Timers/AttackTimer")

# 타입 캐스팅과 함께 사용 (권장)
# @onready var sprite: Sprite2D = $Sprite2D as Sprite2D
# @onready var body: CharacterBody2D = $".." as CharacterBody2D  # 부모 노드

# ============================================
# _ready() - 실행 예제
# ============================================

func _ready():
	print("=== @export 변수 확인 ===\n")

	# @export 변수의 현재 값 출력
	print("플레이어 이름: ", player_name)
	print("이동 속도: ", move_speed)
	print("최대 체력: ", max_health)
	print("디버그 모드: ", debug_mode)

	# ============================================
	# 4. $ 연산자와 get_node()
	# ============================================
	print("\n=== 노드 참조 방법 ===\n")

	# $ 연산자는 get_node()의 축약형입니다
	# $Sprite2D  ==  get_node("Sprite2D")
	# $UI/Label   ==  get_node("UI/Label")

	# 현재 노드 정보
	print("현재 노드 이름: ", name)
	print("현재 노드 경로: ", get_path())

	# 자식 노드 확인
	var child_count := get_child_count()
	print("자식 노드 수: ", child_count)

	# 모든 자식 노드 순회
	for child in get_children():
		print("  자식 노드: ", child.name)

	# 부모 노드 확인 (있을 경우)
	var parent := get_parent()
	if parent:
		print("부모 노드: ", parent.name)

	# 노드 존재 여부 확인 (안전한 접근)
	if has_node("Sprite2D"):
		print("Sprite2D 노드를 찾았습니다!")
	else:
		print("Sprite2D 노드가 없습니다 (예제이므로 정상)")

	# ============================================
	# 5. 노드 경로(NodePath) 이해
	# ============================================
	print("\n=== 노드 경로 ===\n")

	# 상대 경로 (현재 노드 기준)
	# "Sprite2D"           - 직접 자식
	# "Sprite2D/Texture"   - 자식의 자식
	# ".."                 - 부모 노드
	# "../Sibling"         - 형제 노드
	# "."                  - 자기 자신

	print("상대 경로 예시:")
	print('  $Sprite2D        -> 직접 자식 노드')
	print('  $"Sprite2D"      -> 특수문자가 있을 때 따옴표 사용')
	print('  $".."            -> 부모 노드')
	print('  $"../Enemy"      -> 형제 노드')

	# 절대 경로 (루트부터)
	# /root/Main/Player/Sprite2D
	print("\n절대 경로 예시:")
	print('  get_node("/root/Main/Player")')
	print("  현재 씬 트리 경로: ", get_path())

	# ============================================
	# 6. get_node 대안 메서드들
	# ============================================
	print("\n=== 노드 검색 메서드 ===\n")

	# find_child() - 이름으로 자식 노드 검색 (재귀)
	# var found = find_child("EnemySprite", true, false)
	print("find_child('이름') - 하위 트리에서 이름으로 검색")

	# get_node_or_null() - 노드가 없으면 null 반환 (크래시 방지)
	var maybe_node = get_node_or_null("NonExistent")
	print("get_node_or_null 결과: ", maybe_node)  # null

	# is_inside_tree() - 씬 트리에 포함되어 있는지 확인
	print("씬 트리 안에 있는가: ", is_inside_tree())

	# get_tree() - 씬 트리 자체에 접근
	var tree = get_tree()
	print("씬 트리: ", tree)

	# ============================================
	# 7. @export_group / @export_subgroup 정리
	# ============================================
	print("\n=== Export 그룹 값 확인 ===\n")

	print("[Movement 그룹]")
	print("  걷기 속도: ", walk_speed)
	print("  달리기 속도: ", run_speed)
	print("  가속도: ", acceleration)

	print("[Combat 그룹]")
	print("  공격력: ", attack_damage)
	print("  공격 범위: ", attack_range)
	print("  [Defense 서브그룹]")
	print("    방어력: ", armor)
	print("    블록 확률: ", block_chance)

	# ============================================
	# 8. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. @export: Inspector에서 값 조정 가능")
	print("2. @export_range: 범위 제한 슬라이더")
	print("3. @export_group: Inspector 카테고리 정리")
	print("4. @onready: _ready() 시점에 안전하게 초기화")
	print("5. $노드명: get_node()의 축약형")
	print("6. get_node_or_null(): 안전한 노드 참조")
