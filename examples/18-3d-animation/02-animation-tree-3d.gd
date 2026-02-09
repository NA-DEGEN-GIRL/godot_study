# Chapter 18 - 3D Animation
# 02-animation-tree-3d.gd - AnimationTree, StateMachine, BlendSpace
#
# 이 파일에서 배울 내용:
# - AnimationTree의 구조와 역할
# - AnimationNodeStateMachine (상태 머신)
# - AnimationNodeBlendSpace1D/2D (블렌드 스페이스)
# - AnimationNodeBlendTree (블렌드 트리)
# - 전환 조건, 크로스페이드, 파라미터 제어

extends Node3D

func _ready():
	print("=== Chapter 18-2: AnimationTree & StateMachine ===\n")

	# -----------------------------------------------------------------
	# 1) AnimationTree 개념
	# -----------------------------------------------------------------
	print("--- 1. AnimationTree 개념 ---")

	print("  AnimationPlayer: 개별 애니메이션 재생/정지")
	print("  AnimationTree: 복잡한 애니메이션 블렌딩과 전환 관리")
	print()
	print("  AnimationTree 주요 노드 타입:")
	print("    AnimationNodeStateMachine  - 상태 기반 전환")
	print("    AnimationNodeBlendTree     - 노드 기반 블렌딩")
	print("    AnimationNodeBlendSpace1D  - 1D 블렌드 (걷기<->뛰기)")
	print("    AnimationNodeBlendSpace2D  - 2D 블렌드 (이동 방향)")
	print("    AnimationNodeAnimation     - 단일 애니메이션")
	print("    AnimationNodeAdd2          - 두 애니메이션 더하기")
	print("    AnimationNodeOneShot       - 일회성 애니메이션")
	print()

	# -----------------------------------------------------------------
	# 2) AnimationPlayer 설정 (AnimationTree의 소스)
	# -----------------------------------------------------------------
	print("--- 2. AnimationPlayer 설정 ---")

	# AnimationPlayer 생성 및 애니메이션 등록
	var anim_player := AnimationPlayer.new()
	add_child(anim_player)

	# 가상 애니메이션들 생성
	_create_dummy_animation(anim_player, "idle", 2.0)
	_create_dummy_animation(anim_player, "walk", 1.0)
	_create_dummy_animation(anim_player, "run", 0.7)
	_create_dummy_animation(anim_player, "jump", 0.5)
	_create_dummy_animation(anim_player, "attack", 0.8)
	_create_dummy_animation(anim_player, "hit", 0.4)
	_create_dummy_animation(anim_player, "death", 1.5)

	var anim_list := anim_player.get_animation_list()
	print("  등록된 애니메이션: ", anim_list)
	print()

	# -----------------------------------------------------------------
	# 3) AnimationTree + StateMachine 설정
	# -----------------------------------------------------------------
	print("--- 3. AnimationNodeStateMachine ---")

	var anim_tree := AnimationTree.new()
	anim_tree.anim_player = anim_player.get_path()

	# StateMachine 루트 노드 생성
	var state_machine := AnimationNodeStateMachine.new()
	anim_tree.tree_root = state_machine

	# 상태(애니메이션 노드) 추가
	var idle_node := AnimationNodeAnimation.new()
	idle_node.animation = &"idle"
	state_machine.add_node(&"idle", idle_node)

	var walk_node := AnimationNodeAnimation.new()
	walk_node.animation = &"walk"
	state_machine.add_node(&"walk", walk_node)

	var run_node := AnimationNodeAnimation.new()
	run_node.animation = &"run"
	state_machine.add_node(&"run", run_node)

	var jump_node := AnimationNodeAnimation.new()
	jump_node.animation = &"jump"
	state_machine.add_node(&"jump", jump_node)

	var attack_node := AnimationNodeAnimation.new()
	attack_node.animation = &"attack"
	state_machine.add_node(&"attack", attack_node)

	print("  StateMachine 상태 추가:")
	print("    idle, walk, run, jump, attack")
	print()

	# 전환(Transition) 추가
	var idle_to_walk := AnimationNodeStateMachineTransition.new()
	idle_to_walk.xfade_time = 0.2  # 크로스페이드 시간
	state_machine.add_transition(&"idle", &"walk", idle_to_walk)

	var walk_to_idle := AnimationNodeStateMachineTransition.new()
	walk_to_idle.xfade_time = 0.2
	state_machine.add_transition(&"walk", &"idle", walk_to_idle)

	var walk_to_run := AnimationNodeStateMachineTransition.new()
	walk_to_run.xfade_time = 0.3
	state_machine.add_transition(&"walk", &"run", walk_to_run)

	var run_to_walk := AnimationNodeStateMachineTransition.new()
	run_to_walk.xfade_time = 0.3
	state_machine.add_transition(&"run", &"walk", run_to_walk)

	var any_to_jump := AnimationNodeStateMachineTransition.new()
	any_to_jump.xfade_time = 0.1
	state_machine.add_transition(&"idle", &"jump", any_to_jump)
	state_machine.add_transition(&"walk", &"jump", any_to_jump)

	var jump_to_idle := AnimationNodeStateMachineTransition.new()
	jump_to_idle.xfade_time = 0.2
	jump_to_idle.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
	state_machine.add_transition(&"jump", &"idle", jump_to_idle)

	add_child(anim_tree)
	anim_tree.active = true

	print("  전환(Transition) 설정:")
	print("    idle <-> walk (xfade: 0.2s)")
	print("    walk <-> run  (xfade: 0.3s)")
	print("    idle/walk -> jump (xfade: 0.1s)")
	print("    jump -> idle (AT_END: 애니메이션 끝나면 전환)")
	print()

	# -----------------------------------------------------------------
	# 4) StateMachine 상태 전환 제어
	# -----------------------------------------------------------------
	print("--- 4. StateMachine 제어 ---")

	# StateMachinePlayback으로 상태 전환
	var playback: AnimationNodeStateMachinePlayback = anim_tree.get(
		"parameters/playback"
	)

	if playback:
		# 현재 상태 확인
		print("  현재 상태: ", playback.get_current_node())

		# 상태 전환
		playback.travel(&"walk")
		print("  travel(\"walk\") - walk 상태로 전환 요청")
		print("  현재 상태: ", playback.get_current_node())

		# start vs travel
		print()
		print("  travel() vs start():")
		print("    travel(\"run\")  - 경로를 따라 순차 전환")
		print("                    idle -> walk -> run (중간 상태 거침)")
		print("    start(\"run\")  - 즉시 해당 상태로 전환")
		print("                    idle -> run (바로 전환)")
	print()

	print("  상태 전환 코드:")
	print("    var playback = anim_tree.get(\"parameters/playback\")")
	print("    playback.travel(\"walk\")   # 순차 전환")
	print("    playback.start(\"attack\")  # 즉시 전환")
	print("    playback.stop()            # 정지")
	print("    playback.is_playing()      # 재생 중인지")
	print("    playback.get_current_node() # 현재 상태")
	print()

	# -----------------------------------------------------------------
	# 5) Transition 옵션
	# -----------------------------------------------------------------
	print("--- 5. Transition 상세 옵션 ---")

	print("  switch_mode:")
	print("    SWITCH_MODE_IMMEDIATE - 즉시 전환 (기본)")
	print("    SWITCH_MODE_SYNC      - 동기화된 타이밍에 전환")
	print("    SWITCH_MODE_AT_END    - 현재 애니메이션 끝나면 전환")
	print()
	print("  xfade_time: 크로스페이드 시간 (초)")
	print("    0.0 = 즉시 전환 (잘림)")
	print("    0.2 = 부드러운 전환 (일반적)")
	print("    0.5 = 느린 전환 (드라마틱)")
	print()
	print("  advance_mode:")
	print("    ADVANCE_MODE_DISABLED - 자동 전환 안 함")
	print("    ADVANCE_MODE_ENABLED  - 조건 충족 시 자동 전환")
	print("    ADVANCE_MODE_AUTO     - 항상 자동 전환")
	print()
	print("  advance_condition: 전환 조건 (파라미터)")
	print("    transition.advance_condition = \"is_moving\"")
	print("    anim_tree.set(\"parameters/conditions/is_moving\", true)")
	print()

	# -----------------------------------------------------------------
	# 6) BlendSpace1D - 1D 블렌딩
	# -----------------------------------------------------------------
	print("--- 6. BlendSpace1D ---")

	print("  BlendSpace1D: 하나의 축으로 애니메이션을 블렌딩")
	print("  예: 이동 속도에 따라 idle -> walk -> run")
	print()

	var blend_space_1d := AnimationNodeBlendSpace1D.new()

	# 블렌드 포인트 추가
	var bs_idle := AnimationNodeAnimation.new()
	bs_idle.animation = &"idle"
	blend_space_1d.add_blend_point(bs_idle, 0.0)  # 속도 0

	var bs_walk := AnimationNodeAnimation.new()
	bs_walk.animation = &"walk"
	blend_space_1d.add_blend_point(bs_walk, 0.5)  # 속도 0.5

	var bs_run := AnimationNodeAnimation.new()
	bs_run.animation = &"run"
	blend_space_1d.add_blend_point(bs_run, 1.0)   # 속도 1.0

	blend_space_1d.min_space = 0.0
	blend_space_1d.max_space = 1.0

	print("  BlendSpace1D 설정:")
	print("    [0.0] idle")
	print("    [0.5] walk")
	print("    [1.0] run")
	print()
	print("  블렌드 값 제어:")
	print("    anim_tree.set(\"parameters/BlendSpace1D/blend_position\", speed)")
	print("    speed = 0.0  -> idle 100%%")
	print("    speed = 0.25 -> idle 50%% + walk 50%%")
	print("    speed = 0.5  -> walk 100%%")
	print("    speed = 0.75 -> walk 50%% + run 50%%")
	print("    speed = 1.0  -> run 100%%")
	print()

	# -----------------------------------------------------------------
	# 7) BlendSpace2D - 2D 블렌딩
	# -----------------------------------------------------------------
	print("--- 7. BlendSpace2D ---")

	print("  BlendSpace2D: 두 축으로 애니메이션을 블렌딩")
	print("  예: X축 = 좌우 방향, Y축 = 전후 속도")
	print()

	var blend_space_2d := AnimationNodeBlendSpace2D.new()

	print("  BlendSpace2D 설정 (이동 방향):")
	print("    8방향 이동 애니메이션:")
	print("    (-1,1)  (0,1)  (1,1)   <- 전진")
	print("    (-1,0)  (0,0)  (1,0)   <- 좌우/대기")
	print("    (-1,-1) (0,-1) (1,-1)  <- 후진")
	print()
	print("  블렌드 값 제어:")
	print("    var move_dir = Vector2(input_x, input_y)")
	print("    anim_tree.set(\"parameters/BlendSpace2D/blend_position\", move_dir)")
	print()
	print("  blend_mode:")
	print("    BLEND_MODE_INTERPOLATED - 보간 블렌딩 (기본)")
	print("    BLEND_MODE_DISCRETE     - 가장 가까운 포인트만")
	print("    BLEND_MODE_DISCRETE_CARRY - Discrete + 시간 유지")
	print()

	# -----------------------------------------------------------------
	# 8) BlendTree - 노드 기반 블렌딩
	# -----------------------------------------------------------------
	print("--- 8. AnimationNodeBlendTree ---")

	print("  BlendTree: 노드를 연결하여 복잡한 블렌딩 구성")
	print()
	print("  주요 블렌드 노드:")
	print("    AnimationNodeAdd2   - 두 애니메이션 더하기 (상/하체)")
	print("    AnimationNodeBlend2 - 두 애니메이션 블렌딩")
	print("    AnimationNodeOneShot - 일회성 애니메이션 오버레이")
	print("    AnimationNodeTimeScale - 재생 속도 조절")
	print("    AnimationNodeTransition - 인덱스 기반 전환")
	print()

	# BlendTree 구성 예시
	var blend_tree := AnimationNodeBlendTree.new()

	# 기본 애니메이션 노드 추가
	var bt_idle := AnimationNodeAnimation.new()
	bt_idle.animation = &"idle"
	blend_tree.add_node(&"idle_anim", bt_idle)

	var bt_walk := AnimationNodeAnimation.new()
	bt_walk.animation = &"walk"
	blend_tree.add_node(&"walk_anim", bt_walk)

	# Blend2 노드 (idle과 walk 블렌딩)
	var blend2 := AnimationNodeBlend2.new()
	blend_tree.add_node(&"move_blend", blend2)

	# 연결
	blend_tree.connect_node(&"move_blend", 0, &"idle_anim")  # 입력 0 = idle
	blend_tree.connect_node(&"move_blend", 1, &"walk_anim")  # 입력 1 = walk

	# OneShot 노드 (공격 오버레이)
	var one_shot := AnimationNodeOneShot.new()
	blend_tree.add_node(&"attack_oneshot", one_shot)

	var bt_attack := AnimationNodeAnimation.new()
	bt_attack.animation = &"attack"
	blend_tree.add_node(&"attack_anim", bt_attack)

	blend_tree.connect_node(&"attack_oneshot", 0, &"move_blend")  # 기본
	blend_tree.connect_node(&"attack_oneshot", 1, &"attack_anim") # 원샷

	# output에 연결
	blend_tree.connect_node(&"output", 0, &"attack_oneshot")

	print("  BlendTree 구성:")
	print("    idle_anim --|")
	print("                |-- move_blend --|")
	print("    walk_anim --|                |-- attack_oneshot --> output")
	print("                attack_anim ----|")
	print()
	print("  OneShot 제어:")
	print("    # 공격 시작")
	print("    anim_tree.set(\"parameters/attack_oneshot/request\",")
	print("        AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)")
	print("    # 공격 중단")
	print("    anim_tree.set(\"parameters/attack_oneshot/request\",")
	print("        AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)")
	print()

	# -----------------------------------------------------------------
	# 9) 실전 캐릭터 컨트롤러 통합
	# -----------------------------------------------------------------
	print("--- 9. 실전 캐릭터 통합 예제 ---")

	print("  extends CharacterBody3D")
	print()
	print("  @onready var anim_tree = $AnimationTree")
	print("  @onready var playback: AnimationNodeStateMachinePlayback = \\")
	print("      anim_tree.get(\"parameters/playback\")")
	print()
	print("  func _physics_process(delta):")
	print("      var velocity_length = velocity.length()")
	print()
	print("      # BlendSpace1D로 이동 애니메이션 블렌딩")
	print("      var speed_ratio = velocity_length / MAX_SPEED")
	print("      anim_tree.set(\"parameters/move_blend/blend_position\", speed_ratio)")
	print()
	print("      # 상태 전환")
	print("      if is_on_floor():")
	print("          if velocity_length > 0.1:")
	print("              playback.travel(\"move\")")
	print("          else:")
	print("              playback.travel(\"idle\")")
	print("      else:")
	print("          playback.travel(\"air\")")
	print()
	print("      # 공격 (OneShot)")
	print("      if Input.is_action_just_pressed(\"attack\"):")
	print("          anim_tree.set(\"parameters/attack/request\",")
	print("              AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)")
	print()

	# -----------------------------------------------------------------
	# 10) AnimationTree 파라미터 디버깅
	# -----------------------------------------------------------------
	print("--- 10. 파라미터 디버깅 ---")

	print("  AnimationTree 파라미터 확인/설정:")
	print("    # 모든 파라미터 경로는 \"parameters/\" 접두사")
	print("    anim_tree.set(\"parameters/...\", value)")
	print("    var val = anim_tree.get(\"parameters/...\")")
	print()
	print("  에디터에서 파라미터 확인:")
	print("    AnimationTree 인스펙터 > Parameters 섹션")
	print("    각 노드의 파라미터가 트리 구조로 표시됨")
	print()
	print("  디버그 출력:")
	print("    print(\"current: \", playback.get_current_node())")
	print("    print(\"blend: \", anim_tree.get(\"parameters/blend/blend_amount\"))")
	print()

	print("=== 02-animation-tree-3d.gd 완료 ===")


# =============================================================================
# 헬퍼 함수
# =============================================================================

## 더미 애니메이션 생성 (AnimationPlayer에 추가)
func _create_dummy_animation(player: AnimationPlayer, anim_name: String, duration: float):
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR

	# 간단한 트랙 추가 (위치 변화)
	var track_idx := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, ".:position")
	animation.track_insert_key(track_idx, 0.0, Vector3.ZERO)
	animation.track_insert_key(track_idx, duration, Vector3.ZERO)

	var library: AnimationLibrary
	if player.has_animation_library(&""):
		library = player.get_animation_library(&"")
	else:
		library = AnimationLibrary.new()
		player.add_animation_library(&"", library)

	library.add_animation(anim_name, animation)
