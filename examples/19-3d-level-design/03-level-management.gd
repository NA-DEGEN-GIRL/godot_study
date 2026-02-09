# Chapter 19 - 3D Level Design
# 03-level-management.gd - 3D 씬 전환, 스폰 포인트, 레벨 매니저
#
# 이 파일에서 배울 내용:
# - 레벨 매니저 패턴 (씬 전환/로딩)
# - 스폰 포인트 시스템
# - 체크포인트와 저장 위치
# - 비동기 레벨 로딩 (백그라운드)
# - 씬 전환 효과 (페이드/와이프)
# - 레벨 간 데이터 전달

extends Node3D

# =============================================================================
# 레벨 매니저 데이터
# =============================================================================

## 레벨 정보 구조
var level_database := {
	"main_menu": {
		"path": "res://levels/main_menu.tscn",
		"display_name": "메인 메뉴",
		"spawn_point": "default",
	},
	"level_1": {
		"path": "res://levels/forest.tscn",
		"display_name": "숲의 입구",
		"spawn_point": "start",
		"next_level": "level_2",
	},
	"level_2": {
		"path": "res://levels/dungeon.tscn",
		"display_name": "지하 던전",
		"spawn_point": "entrance",
		"next_level": "level_3",
	},
	"level_3": {
		"path": "res://levels/castle.tscn",
		"display_name": "마왕의 성",
		"spawn_point": "gate",
		"next_level": "main_menu",
	},
}

var current_level_id := ""
var spawn_points: Dictionary = {}  # {이름: Transform3D}
var checkpoints: Array[Dictionary] = []
var is_loading := false

func _ready():
	print("=== Chapter 19-3: Level Management ===\n")

	# -----------------------------------------------------------------
	# 1) 레벨 매니저 패턴
	# -----------------------------------------------------------------
	print("--- 1. 레벨 매니저 패턴 ---")

	print("  레벨 매니저: 게임의 레벨/씬 전환을 중앙 관리")
	print()
	print("  씬 트리 구조:")
	print("    Root")
	print("    +-- LevelManager (Autoload/싱글톤)")
	print("    |   +-- TransitionOverlay (CanvasLayer)")
	print("    |   +-- LoadingScreen (CanvasLayer)")
	print("    +-- CurrentLevel (동적 교체)")
	print("    |   +-- Environment")
	print("    |   +-- SpawnPoints")
	print("    |   +-- Enemies")
	print("    |   +-- Items")
	print("    +-- Player (레벨 전환 시 유지)")
	print("    +-- UI (레벨 전환 시 유지)")
	print()

	print("  Autoload 등록:")
	print("    프로젝트 설정 > Autoload > LevelManager 추가")
	print("    -> 모든 씬에서 LevelManager로 접근 가능")
	print()

	# -----------------------------------------------------------------
	# 2) 기본 씬 전환
	# -----------------------------------------------------------------
	print("--- 2. 기본 씬 전환 ---")

	print("  방법 1: 전체 씬 교체 (간단)")
	print("    get_tree().change_scene_to_file(\"res://levels/level_2.tscn\")")
	print("    # 현재 씬 전체가 교체됩니다")
	print("    # 플레이어, UI 등 모두 새로 로드")
	print()

	print("  방법 2: 서브 씬 교체 (권장)")
	print("    # 레벨만 교체, 플레이어/UI는 유지")
	print("    func change_level(level_path: String):")
	print("        # 기존 레벨 제거")
	print("        var old_level = get_node(\"CurrentLevel\")")
	print("        if old_level:")
	print("            old_level.queue_free()")
	print("            await old_level.tree_exited")
	print()
	print("        # 새 레벨 로드")
	print("        var new_level = load(level_path).instantiate()")
	print("        add_child(new_level)")
	print("        new_level.name = \"CurrentLevel\"")
	print()

	# 데모: 레벨 데이터 표시
	print("  등록된 레벨:")
	for level_id in level_database:
		var info: Dictionary = level_database[level_id]
		print("    [%s] %s" % [level_id, info["display_name"]])
	print()

	# -----------------------------------------------------------------
	# 3) 스폰 포인트 시스템
	# -----------------------------------------------------------------
	print("--- 3. 스폰 포인트 시스템 ---")

	# 스폰 포인트 마커 생성
	_create_spawn_point("start", Vector3(0, 0, 0), 0.0)
	_create_spawn_point("checkpoint_1", Vector3(10, 0, 5), 45.0)
	_create_spawn_point("checkpoint_2", Vector3(20, 2, 10), 90.0)
	_create_spawn_point("boss_entrance", Vector3(30, 0, 0), 180.0)
	_create_spawn_point("secret_area", Vector3(-10, -3, 15), 0.0)

	print("  스폰 포인트 등록:")
	for sp_name in spawn_points:
		var sp: Transform3D = spawn_points[sp_name]
		print("    [%s] 위치: %s" % [sp_name, sp.origin])
	print()

	print("  스폰 포인트 스크립트 (Marker3D 사용):")
	print("    # spawn_point.gd")
	print("    extends Marker3D")
	print("    @export var spawn_name: String = \"default\"")
	print("    @export var spawn_direction: float = 0.0  # Y축 회전")
	print()
	print("    func _ready():")
	print("        LevelManager.register_spawn_point(spawn_name, global_transform)")
	print()

	# 플레이어를 스폰 포인트로 이동
	print("  플레이어 스폰:")
	print("    func spawn_player(point_name: String):")
	print("        var spawn = spawn_points.get(point_name, spawn_points[\"start\"])")
	print("        player.global_transform = spawn")
	print("        player.velocity = Vector3.ZERO")
	print()

	# -----------------------------------------------------------------
	# 4) 체크포인트 시스템
	# -----------------------------------------------------------------
	print("--- 4. 체크포인트 시스템 ---")

	# 체크포인트 데이터 구조
	_register_checkpoint("checkpoint_1", Vector3(10, 0, 5), {
		"level_id": "level_1",
		"enemies_cleared": 5,
		"items_collected": ["key_a", "potion"],
	})

	_register_checkpoint("checkpoint_2", Vector3(20, 2, 10), {
		"level_id": "level_1",
		"enemies_cleared": 12,
		"items_collected": ["key_a", "key_b", "potion", "shield"],
	})

	print("  체크포인트 저장 데이터:")
	for cp in checkpoints:
		print("    [%s] 위치: %s" % [cp["name"], cp["position"]])
		print("      게임 상태: %s" % str(cp["game_state"]))
	print()

	print("  체크포인트 트리거 (Area3D):")
	print("    extends Area3D")
	print("    @export var checkpoint_name: String")
	print()
	print("    func _on_body_entered(body):")
	print("        if body.is_in_group(\"player\"):")
	print("            LevelManager.save_checkpoint(checkpoint_name, {")
	print("                \"position\": body.global_position,")
	print("                \"health\": body.health,")
	print("                \"inventory\": body.inventory.duplicate(),")
	print("            })")
	print("            show_checkpoint_saved_message()")
	print()

	# -----------------------------------------------------------------
	# 5) 비동기 레벨 로딩
	# -----------------------------------------------------------------
	print("--- 5. 비동기 레벨 로딩 ---")

	print("  ResourceLoader를 이용한 백그라운드 로딩:")
	print()
	print("  var loading_path := \"\"")
	print("  var progress := []")
	print()
	print("  func load_level_async(level_id: String):")
	print("      var path = level_database[level_id][\"path\"]")
	print("      loading_path = path")
	print("      is_loading = true")
	print()
	print("      # 페이드아웃 시작")
	print("      await transition_fade_out()")
	print()
	print("      # 로딩 화면 표시")
	print("      loading_screen.show()")
	print()
	print("      # 비동기 로딩 시작")
	print("      ResourceLoader.load_threaded_request(path)")
	print()
	print("  func _process(delta):")
	print("      if not is_loading:")
	print("          return")
	print()
	print("      # 로딩 상태 확인")
	print("      var status = ResourceLoader.load_threaded_get_status(loading_path, progress)")
	print()
	print("      match status:")
	print("          ResourceLoader.THREAD_LOAD_IN_PROGRESS:")
	print("              loading_screen.set_progress(progress[0] * 100)")
	print()
	print("          ResourceLoader.THREAD_LOAD_LOADED:")
	print("              var scene = ResourceLoader.load_threaded_get(loading_path)")
	print("              _finish_loading(scene)")
	print()
	print("          ResourceLoader.THREAD_LOAD_FAILED:")
	print("              printerr(\"레벨 로딩 실패: \" + loading_path)")
	print("              is_loading = false")
	print()

	# 로딩 시뮬레이션
	print("  로딩 진행률 시뮬레이션:")
	for p in range(0, 101, 25):
		print("    진행률: %d%%" % p)
	print()

	# -----------------------------------------------------------------
	# 6) 씬 전환 효과
	# -----------------------------------------------------------------
	print("--- 6. 씬 전환 효과 ---")

	print("  페이드 인/아웃 (CanvasLayer + ColorRect):")
	print()
	print("  # TransitionManager.gd (Autoload)")
	print("  extends CanvasLayer")
	print()
	print("  @onready var fade_rect = $FadeRect  # ColorRect, 전체 화면")
	print()
	print("  func fade_out(duration := 0.5):")
	print("      var tween = create_tween()")
	print("      tween.tween_property(fade_rect, \"color:a\", 1.0, duration)")
	print("      await tween.finished")
	print()
	print("  func fade_in(duration := 0.5):")
	print("      var tween = create_tween()")
	print("      tween.tween_property(fade_rect, \"color:a\", 0.0, duration)")
	print("      await tween.finished")
	print()
	print("  func transition_to(scene_path: String):")
	print("      await fade_out()")
	print("      get_tree().change_scene_to_file(scene_path)")
	print("      await get_tree().process_frame  # 1프레임 대기")
	print("      await fade_in()")
	print()

	print("  3D 전용 전환 효과:")
	print("    - 카메라 줌 인/아웃")
	print("    - 포탈 이펙트 (셰이더)")
	print("    - 화이트아웃/블랙아웃")
	print("    - 디졸브 셰이더 전환")
	print()

	# -----------------------------------------------------------------
	# 7) 레벨 간 데이터 전달
	# -----------------------------------------------------------------
	print("--- 7. 레벨 간 데이터 전달 ---")

	print("  방법 1: Autoload 싱글톤 (권장)")
	print("    # GameData.gd (Autoload)")
	print("    extends Node")
	print("    var player_health := 100")
	print("    var inventory := []")
	print("    var quest_flags := {}")
	print("    var destination_spawn := \"default\"")
	print()

	print("  방법 2: 메타데이터")
	print("    # 씬 전환 전")
	print("    var next_scene = load(\"res://level2.tscn\").instantiate()")
	print("    next_scene.set_meta(\"spawn_point\", \"from_level1\")")
	print("    next_scene.set_meta(\"player_data\", player.save_data())")
	print()

	# 실제 데이터 전달 예시
	var transition_data := {
		"from_level": "level_1",
		"spawn_point": "entrance",
		"player_health": 75,
		"player_items": ["sword", "shield", "potion_x3"],
		"quest_progress": {"main_quest": 3, "side_quest_a": 1},
	}

	print("  전환 데이터 예시:")
	for key in transition_data:
		print("    %s: %s" % [key, str(transition_data[key])])
	print()

	# -----------------------------------------------------------------
	# 8) 존(Zone) 트리거
	# -----------------------------------------------------------------
	print("--- 8. 존(Zone) 트리거 ---")

	print("  레벨 전환 트리거 (Area3D):")
	print()
	print("  # zone_trigger.gd")
	print("  extends Area3D")
	print("  @export var target_level: String = \"level_2\"")
	print("  @export var target_spawn: String = \"entrance\"")
	print("  @export var require_item: String = \"\"  # 필요 아이템")
	print()
	print("  func _on_body_entered(body):")
	print("      if not body.is_in_group(\"player\"):")
	print("          return")
	print()
	print("      # 아이템 확인")
	print("      if require_item != \"\" and not body.has_item(require_item):")
	print("          show_message(\"열쇠가 필요합니다!\")")
	print("          return")
	print()
	print("      # 레벨 전환")
	print("      GameData.destination_spawn = target_spawn")
	print("      LevelManager.change_level(target_level)")
	print()

	# 데모: 존 트리거 생성
	var zone := Area3D.new()
	var zone_shape := CollisionShape3D.new()
	var zone_box := BoxShape3D.new()
	zone_box.size = Vector3(2, 3, 1)
	zone_shape.shape = zone_box
	zone.add_child(zone_shape)
	zone.position = Vector3(30, 1.5, 0)
	add_child(zone)

	print("  존 트리거 생성: 위치 = %s, 크기 = %s" % [
		zone.position, zone_box.size
	])
	print()

	# -----------------------------------------------------------------
	# 9) 레벨 매니저 완전한 구현
	# -----------------------------------------------------------------
	print("--- 9. 레벨 매니저 전체 구조 ---")

	print("  # level_manager.gd (Autoload)")
	print("  extends Node")
	print()
	print("  signal level_changed(level_id: String)")
	print("  signal loading_progress(percent: float)")
	print("  signal checkpoint_saved(name: String)")
	print()
	print("  var current_level_id: String")
	print("  var current_level_node: Node")
	print("  var spawn_points: Dictionary")
	print("  var last_checkpoint: Dictionary")
	print()
	print("  func change_level(level_id: String, spawn: String = \"\"):")
	print("      # 1. 전환 효과")
	print("      await TransitionManager.fade_out()")
	print("      # 2. 기존 레벨 정리")
	print("      _cleanup_current_level()")
	print("      # 3. 새 레벨 로드")
	print("      await _load_level(level_id)")
	print("      # 4. 플레이어 스폰")
	print("      _spawn_player(spawn)")
	print("      # 5. 전환 효과")
	print("      await TransitionManager.fade_in()")
	print("      # 6. 시그널")
	print("      level_changed.emit(level_id)")
	print()
	print("  func restart_from_checkpoint():")
	print("      if last_checkpoint.is_empty():")
	print("          change_level(current_level_id, \"start\")")
	print("      else:")
	print("          change_level(last_checkpoint[\"level_id\"])")
	print("          _restore_game_state(last_checkpoint[\"game_state\"])")
	print()

	# -----------------------------------------------------------------
	# 10) 레벨 디자인 체크리스트
	# -----------------------------------------------------------------
	print("--- 10. 레벨 디자인 체크리스트 ---")

	print("  [필수 요소]")
	print("    [ ] 스폰 포인트 (최소 1개)")
	print("    [ ] 네비게이션 메시 (AI 이동)")
	print("    [ ] 충돌 지오메트리 (바닥, 벽)")
	print("    [ ] 카메라 설정")
	print("    [ ] 조명 (DirectionalLight3D + 환경)")
	print()
	print("  [선택 요소]")
	print("    [ ] 체크포인트")
	print("    [ ] 존 트리거 (레벨 전환)")
	print("    [ ] 킬 존 (낙사 영역)")
	print("    [ ] 적 스폰 포인트")
	print("    [ ] 아이템 배치")
	print("    [ ] 시네마틱 트리거")
	print("    [ ] 앰비언트 사운드")
	print()
	print("  [최적화]")
	print("    [ ] 오클루전 컬링")
	print("    [ ] LOD 설정")
	print("    [ ] 라이트맵 베이크")
	print("    [ ] 불필요한 노드 정리")
	print()

	print("=== 03-level-management.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 스폰 포인트 생성 및 등록
func _create_spawn_point(sp_name: String, pos: Vector3, rotation_y: float):
	var marker := Marker3D.new()
	marker.position = pos
	marker.rotation_degrees.y = rotation_y
	marker.name = "Spawn_" + sp_name
	add_child(marker)

	# 시각적 표시 (디버그용)
	var mesh := MeshInstance3D.new()
	var arrow := CylinderMesh.new()
	arrow.top_radius = 0.0
	arrow.bottom_radius = 0.3
	arrow.height = 0.5
	mesh.mesh = arrow
	mesh.position = Vector3(0, 0.25, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.GREEN
	mat.emission_enabled = true
	mat.emission = Color.GREEN
	mat.emission_energy_multiplier = 1.5
	mesh.material_override = mat
	marker.add_child(mesh)

	# 등록
	spawn_points[sp_name] = marker.transform


## 체크포인트 등록
func _register_checkpoint(cp_name: String, pos: Vector3, game_state: Dictionary):
	checkpoints.append({
		"name": cp_name,
		"position": pos,
		"game_state": game_state,
		"timestamp": Time.get_unix_time_from_system(),
	})
