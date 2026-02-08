# Chapter 10 - TileMap & Level Design
# 03-level-manager.gd - 레벨 관리 시스템
#
# 이 파일에서 배울 내용:
# - LevelManager Autoload 패턴
# - 레벨 순서와 진행 관리
# - 체크포인트 시스템
# - 레벨 잠금/해제 (Level Unlock)
# - 레벨 데이터 구조 설계

extends Node

# =============================================================================
# 레벨 데이터 구조
# =============================================================================

# 각 레벨의 메타 정보
class LevelInfo:
	var id: int
	var name: String
	var scene_path: String
	var unlocked: bool
	var completed: bool
	var best_time: float  # 초 단위 (-1 = 기록 없음)
	var stars: int        # 0 ~ 3
	var checkpoints_found: int
	var total_checkpoints: int

	func _init(p_id: int, p_name: String, p_scene_path: String,
			p_total_checkpoints: int = 0):
		id = p_id
		name = p_name
		scene_path = p_scene_path
		unlocked = (p_id == 0)  # 첫 레벨만 기본 해제
		completed = false
		best_time = -1.0
		stars = 0
		checkpoints_found = 0
		total_checkpoints = p_total_checkpoints

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"unlocked": unlocked,
			"completed": completed,
			"best_time": best_time,
			"stars": stars,
			"checkpoints_found": checkpoints_found,
		}

	func from_dict(data: Dictionary):
		unlocked = data.get("unlocked", false)
		completed = data.get("completed", false)
		best_time = data.get("best_time", -1.0)
		stars = data.get("stars", 0)
		checkpoints_found = data.get("checkpoints_found", 0)

	func _to_string() -> String:
		var lock_str = "OPEN" if unlocked else "LOCKED"
		var done_str = "CLEAR" if completed else "-----"
		var star_str = "*".repeat(stars) + ".".repeat(3 - stars)
		var time_str = "%.1fs" % best_time if best_time >= 0 else "--.-s"
		return "[%d] %-12s %6s %5s [%s] %s" % [
			id, name, lock_str, done_str, star_str, time_str
		]


# =============================================================================
# LevelManager 본체
# =============================================================================

# 레벨 목록
var levels: Array[LevelInfo] = []
var current_level_id: int = -1

# 체크포인트
var current_checkpoint_id: int = -1
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_data: Dictionary = {}

# 시그널
signal level_completed(level_id: int, stars: int, time: float)
signal level_unlocked(level_id: int)
signal checkpoint_reached(checkpoint_id: int, position: Vector2)


func _ready():
	print("=== Chapter 10-3: LevelManager 시스템 ===\n")

	# -----------------------------------------------------------------
	# 1) 레벨 등록
	# -----------------------------------------------------------------
	print("--- 1. 레벨 등록 ---")

	_register_levels()

	print("  등록된 레벨 수: ", levels.size())
	for level in levels:
		print("    ", level)
	print()

	# -----------------------------------------------------------------
	# 2) 레벨 진행 시스템
	# -----------------------------------------------------------------
	print("--- 2. 레벨 진행 ---")

	# 레벨 1 플레이 시뮬레이션
	print("  [시뮬레이션] 레벨 0 시작...")
	start_level(0)
	print("  현재 레벨: ", current_level_id, " (", get_current_level().name, ")")
	print()

	# 레벨 클리어
	print("  [시뮬레이션] 레벨 0 클리어! (시간: 45.3초, 별: 2개)")
	complete_level(0, 2, 45.3)
	print()

	# 상태 확인
	print("  레벨 0 완료 후 상태:")
	for level in levels:
		print("    ", level)
	print()

	# 다음 레벨
	print("  [시뮬레이션] 레벨 1 시작...")
	start_level(1)
	print("  현재 레벨: ", current_level_id, " (", get_current_level().name, ")")
	complete_level(1, 3, 32.1)
	print()

	# 레벨 2까지 클리어
	complete_level(2, 1, 78.5)
	print("  레벨 2까지 클리어 후 상태:")
	for level in levels:
		print("    ", level)
	print()

	# -----------------------------------------------------------------
	# 3) 레벨 선택 화면 데이터
	# -----------------------------------------------------------------
	print("--- 3. 레벨 선택 화면 ---")

	print("  레벨 선택 UI에 필요한 데이터:")
	for level in levels:
		var status: String
		if not level.unlocked:
			status = "잠김"
		elif level.completed:
			status = "클리어"
		else:
			status = "플레이 가능"

		print("    레벨 %d '%s': %s" % [level.id, level.name, status])
		if level.completed:
			print("      별: %d/3, 최고기록: %.1fs" % [level.stars, level.best_time])
	print()

	# 전체 진행도
	var total = levels.size()
	var cleared = levels.filter(func(l): return l.completed).size()
	var total_stars = 0
	for l in levels:
		total_stars += l.stars
	print("  전체 진행도: %d/%d 레벨 클리어" % [cleared, total])
	print("  총 별: %d/%d" % [total_stars, total * 3])
	print()

	# -----------------------------------------------------------------
	# 4) 체크포인트 시스템
	# -----------------------------------------------------------------
	print("--- 4. 체크포인트 시스템 ---")

	print("  체크포인트 구현 원리:")
	print("    1. 레벨에 체크포인트 Area2D 배치")
	print("    2. 플레이어가 체크포인트에 닿으면 저장")
	print("    3. 사망 시 마지막 체크포인트에서 부활")
	print()

	# 체크포인트 도달 시뮬레이션
	current_level_id = 0
	print("  [시뮬레이션] 체크포인트 진행:")

	reach_checkpoint(0, Vector2(500, 300))
	print("    체크포인트 0 도달: 위치=%s" % checkpoint_position)

	reach_checkpoint(1, Vector2(1200, 250))
	print("    체크포인트 1 도달: 위치=%s" % checkpoint_position)

	reach_checkpoint(2, Vector2(2000, 400))
	print("    체크포인트 2 도달: 위치=%s" % checkpoint_position)
	print()

	# 사망 후 부활
	print("  [시뮬레이션] 플레이어 사망!")
	var respawn = get_respawn_position()
	print("    부활 위치: %s (체크포인트 %d)" % [respawn, current_checkpoint_id])
	print()

	# 체크포인트에 추가 데이터 저장
	print("  체크포인트에 추가 데이터 저장 가능:")
	reach_checkpoint(3, Vector2(2500, 350), {
		"hp": 80,
		"coins": 15,
		"keys": ["red_key"],
		"enemies_defeated": 12
	})
	print("    체크포인트 3 데이터: ", checkpoint_data)
	print()

	# -----------------------------------------------------------------
	# 5) 레벨 잠금/해제 조건
	# -----------------------------------------------------------------
	print("--- 5. 레벨 잠금/해제 조건 ---")

	print("  기본 조건: 이전 레벨 클리어")
	print()

	print("  고급 잠금 해제 조건 예시:")
	print("    - 특정 수의 별 획득")
	print("    - 보스 레벨 클리어")
	print("    - 숨겨진 레벨: 특수 조건 달성")
	print()

	# 별 기반 잠금 해제 예시
	var required_stars = {3: 5, 4: 10, 5: 15}
	print("  별 기반 잠금 해제 시뮬레이션:")
	for level_id in required_stars:
		var needed = required_stars[level_id]
		var have = total_stars
		var can_unlock = have >= needed
		print("    레벨 %d: 필요 별 %d개, 보유 %d개 -> %s" % [
			level_id, needed, have,
			"해제 가능" if can_unlock else "잠김"
		])
	print()

	# -----------------------------------------------------------------
	# 6) 기록 갱신
	# -----------------------------------------------------------------
	print("--- 6. 기록 갱신 ---")

	# 같은 레벨 다시 플레이
	print("  레벨 0 재도전 (기존: 45.3초, 별 2개)")
	print("  새 기록: 38.7초, 별 3개")
	complete_level(0, 3, 38.7)

	var lvl0 = get_level(0)
	print("  갱신 결과: 최고기록=%.1fs, 별=%d" % [lvl0.best_time, lvl0.stars])
	print()

	# 더 나쁜 기록은 무시
	print("  레벨 0 재도전 (더 느린 기록: 55.0초, 별 1개)")
	complete_level(0, 1, 55.0)
	print("  결과: 최고기록=%.1fs, 별=%d (변화 없음)" % [lvl0.best_time, lvl0.stars])
	print()

	# -----------------------------------------------------------------
	# 7) 레벨 데이터 저장/불러오기
	# -----------------------------------------------------------------
	print("--- 7. 레벨 데이터 직렬화 ---")

	var save_data = serialize_progress()
	print("  저장 데이터:")
	for key in save_data:
		print("    %s: %s" % [key, save_data[key]])
	print()

	# 복원 테스트
	print("  데이터 복원 테스트:")
	_register_levels()  # 초기화
	print("    초기화 후 레벨 0 상태: ", levels[0])
	deserialize_progress(save_data)
	print("    복원 후 레벨 0 상태: ", levels[0])
	print()

	# -----------------------------------------------------------------
	# 8) 레벨 매니저 전체 API 요약
	# -----------------------------------------------------------------
	print("--- 8. LevelManager API 요약 ---")

	print("  레벨 관리:")
	print("    start_level(id)              - 레벨 시작")
	print("    complete_level(id, stars, t)  - 레벨 클리어")
	print("    get_level(id)                - 레벨 정보 조회")
	print("    get_current_level()          - 현재 레벨 정보")
	print("    get_next_level_id()          - 다음 레벨 ID")
	print("    is_level_unlocked(id)        - 잠금 해제 확인")
	print()
	print("  체크포인트:")
	print("    reach_checkpoint(id, pos, data) - 체크포인트 저장")
	print("    get_respawn_position()         - 부활 위치 조회")
	print("    reset_checkpoints()            - 체크포인트 초기화")
	print()
	print("  저장:")
	print("    serialize_progress()           - 진행 상태 직렬화")
	print("    deserialize_progress(data)     - 진행 상태 복원")
	print()

	# 시그널 연결 예시
	level_completed.connect(_on_level_completed)
	level_unlocked.connect(_on_level_unlocked)
	checkpoint_reached.connect(_on_checkpoint_reached)
	print("  시그널 연결:")
	print("    level_completed(level_id, stars, time)")
	print("    level_unlocked(level_id)")
	print("    checkpoint_reached(checkpoint_id, position)")
	print()

	print("=== 03-level-manager.gd 완료 ===")


# =============================================================================
# LevelManager 핵심 메서드들
# =============================================================================

func _register_levels():
	levels.clear()
	levels.append(LevelInfo.new(0, "Green Hills", "res://levels/level_00.tscn", 3))
	levels.append(LevelInfo.new(1, "Desert Ruins", "res://levels/level_01.tscn", 4))
	levels.append(LevelInfo.new(2, "Ice Cave", "res://levels/level_02.tscn", 5))
	levels.append(LevelInfo.new(3, "Lava Castle", "res://levels/level_03.tscn", 3))
	levels.append(LevelInfo.new(4, "Sky Temple", "res://levels/level_04.tscn", 6))
	levels.append(LevelInfo.new(5, "Final Boss", "res://levels/level_05.tscn", 2))


func start_level(level_id: int):
	if level_id < 0 or level_id >= levels.size():
		push_error("유효하지 않은 레벨 ID: %d" % level_id)
		return

	var level = levels[level_id]
	if not level.unlocked:
		push_warning("잠긴 레벨 시작 시도: %d" % level_id)
		return

	current_level_id = level_id
	reset_checkpoints()
	# 실제로는 여기서 씬 전환:
	# get_tree().change_scene_to_file(level.scene_path)


func complete_level(level_id: int, stars: int, time: float):
	if level_id < 0 or level_id >= levels.size():
		return

	var level = levels[level_id]
	level.completed = true

	# 기록 갱신 (더 좋은 것만)
	if level.best_time < 0 or time < level.best_time:
		level.best_time = time
	if stars > level.stars:
		level.stars = stars

	# 다음 레벨 잠금 해제
	var next_id = level_id + 1
	if next_id < levels.size() and not levels[next_id].unlocked:
		levels[next_id].unlocked = true
		level_unlocked.emit(next_id)

	level_completed.emit(level_id, level.stars, level.best_time)


func get_level(level_id: int) -> LevelInfo:
	if level_id >= 0 and level_id < levels.size():
		return levels[level_id]
	return null


func get_current_level() -> LevelInfo:
	return get_level(current_level_id)


func get_next_level_id() -> int:
	var next_id = current_level_id + 1
	if next_id < levels.size():
		return next_id
	return -1  # 마지막 레벨


func is_level_unlocked(level_id: int) -> bool:
	var level = get_level(level_id)
	return level != null and level.unlocked


# 체크포인트 관련
func reach_checkpoint(id: int, position: Vector2, extra_data: Dictionary = {}):
	if id <= current_checkpoint_id:
		return  # 이미 지난 체크포인트

	current_checkpoint_id = id
	checkpoint_position = position
	checkpoint_data = extra_data

	# 레벨 정보 업데이트
	if current_level_id >= 0:
		var level = get_current_level()
		if level and id + 1 > level.checkpoints_found:
			level.checkpoints_found = id + 1

	checkpoint_reached.emit(id, position)


func get_respawn_position() -> Vector2:
	if current_checkpoint_id >= 0:
		return checkpoint_position
	return Vector2.ZERO  # 시작 지점


func reset_checkpoints():
	current_checkpoint_id = -1
	checkpoint_position = Vector2.ZERO
	checkpoint_data = {}


# 직렬화
func serialize_progress() -> Dictionary:
	var data = {}
	for level in levels:
		data["level_%d" % level.id] = level.to_dict()
	return data


func deserialize_progress(data: Dictionary):
	for level in levels:
		var key = "level_%d" % level.id
		if data.has(key):
			level.from_dict(data[key])


# =============================================================================
# 시그널 콜백 (예시)
# =============================================================================

func _on_level_completed(level_id: int, stars: int, time: float):
	# 실제로는 UI 업데이트, 결과 화면 표시 등
	pass

func _on_level_unlocked(level_id: int):
	# 실제로는 잠금 해제 연출
	pass

func _on_checkpoint_reached(cp_id: int, position: Vector2):
	# 실제로는 저장 아이콘 표시, 효과음 재생 등
	pass
