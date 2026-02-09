# 챕터 18: 3D 애니메이션 - 정답
#
# 이 챕터에서는 다음을 학습합니다:
# - AnimationPlayer로 3D 애니메이션 재생 제어
# - AnimationTree와 StateMachine으로 상태 기반 애니메이션
# - BlendSpace2D로 이동 방향에 따른 애니메이션 블렌딩
# - Tween으로 3D 오브젝트 트윈 애니메이션
# - 절차적 애니메이션 (코드 기반 IK, 흔들림 등)

extends Node3D

# 테스트용 변수
var demo_mesh: MeshInstance3D
var anim_player: AnimationPlayer


func _ready():
	print("=== 챕터 18: 3D 애니메이션 ===\n")

	_setup_demo_scene()

	# 연습 1: 애니메이션 재생 제어
	_exercise_1_animation_playback()

	# 연습 2: AnimationTree 상태 머신
	_exercise_2_animation_tree()

	# 연습 3: BlendSpace
	_exercise_3_blend_space()

	# 연습 4: Tween 3D 애니메이션
	_exercise_4_tween_3d()

	# 연습 5: 절차적 애니메이션
	_exercise_5_procedural_animation()

	# 테스트 케이스
	print("\n=== 테스트 결과 ===")
	print("결과 1: AnimationPlayer 3D 애니메이션 (이동+회전+스케일) 생성/재생 완료")
	print("결과 2: AnimationTree StateMachine 구조 설명 완료")
	print("결과 3: BlendSpace2D (이동 방향 블렌딩) 설명 완료")
	print("결과 4: Tween 3D 체이닝 (이동+회전+스케일+색상) 구현 완료")
	print("결과 5: 절차적 애니메이션 (보빙, 흔들림, LookAt IK) 구현 완료")


func _setup_demo_scene():
	# 데모 메시 생성
	demo_mesh = MeshInstance3D.new()
	demo_mesh.name = "DemoBox"
	var box := BoxMesh.new()
	box.size = Vector3(1, 1, 1)
	demo_mesh.mesh = box
	demo_mesh.position = Vector3(0, 0.5, 0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.6, 0.9)
	demo_mesh.material_override = mat
	add_child(demo_mesh)

	# AnimationPlayer 생성
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	add_child(anim_player)

	# 바닥
	var floor_mesh := MeshInstance3D.new()
	floor_mesh.name = "Floor"
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.3, 0.4, 0.3)
	floor_mesh.material_override = floor_mat
	add_child(floor_mesh)

	print("  데모 씬 구성: DemoBox + AnimationPlayer + Floor\n")


# ==============================================================================
# 연습 1: 애니메이션 재생 - AnimationPlayer로 3D 오브젝트의 위치, 회전,
#          스케일 애니메이션을 코드로 생성하고 제어하세요.
# ==============================================================================
func _exercise_1_animation_playback():
	# 풀이: Animation 리소스에 트랙을 추가하여 3D 속성을 키프레임합니다.
	#       TYPE_VALUE: 일반 속성 (position, rotation, scale, color 등)
	#       TYPE_BEZIER: 베지어 커브 (부드러운 곡선)
	#       TYPE_METHOD: 함수 호출 (사운드, 이벤트 트리거)
	#       AnimationLibrary에 등록 후 play()로 재생합니다.

	print("연습 1: 애니메이션 재생 제어")

	# 바운스 애니메이션 생성
	var bounce_anim := Animation.new()
	bounce_anim.length = 2.0
	bounce_anim.loop_mode = Animation.LOOP_LINEAR

	# 트랙 1: Y 위치 (바운스)
	# 풀이: track_set_path에서 "DemoBox:position:y"처럼 속성 경로를 지정합니다.
	#       중간 키프레임을 삽입하여 부드러운 곡선을 만듭니다.
	var pos_track := bounce_anim.add_track(Animation.TYPE_VALUE)
	bounce_anim.track_set_path(pos_track, "DemoBox:position:y")
	bounce_anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC)
	bounce_anim.track_insert_key(pos_track, 0.0, 0.5)     # 바닥
	bounce_anim.track_insert_key(pos_track, 0.5, 2.5)     # 정점
	bounce_anim.track_insert_key(pos_track, 1.0, 0.5)     # 착지
	bounce_anim.track_insert_key(pos_track, 1.2, 0.3)     # 찌그러짐
	bounce_anim.track_insert_key(pos_track, 1.4, 0.5)     # 복원
	bounce_anim.track_insert_key(pos_track, 2.0, 0.5)     # 대기

	# 트랙 2: 스케일 (찌그러짐/늘어남)
	var scale_track := bounce_anim.add_track(Animation.TYPE_VALUE)
	bounce_anim.track_set_path(scale_track, "DemoBox:scale")
	bounce_anim.track_set_interpolation_type(scale_track, Animation.INTERPOLATION_CUBIC)
	bounce_anim.track_insert_key(scale_track, 0.0, Vector3(1, 1, 1))
	bounce_anim.track_insert_key(scale_track, 0.3, Vector3(0.8, 1.2, 0.8))  # 늘어남
	bounce_anim.track_insert_key(scale_track, 0.5, Vector3(0.9, 1.1, 0.9))
	bounce_anim.track_insert_key(scale_track, 1.0, Vector3(1, 1, 1))
	bounce_anim.track_insert_key(scale_track, 1.2, Vector3(1.3, 0.7, 1.3))  # 착지 찌그러짐
	bounce_anim.track_insert_key(scale_track, 1.4, Vector3(1, 1, 1))
	bounce_anim.track_insert_key(scale_track, 2.0, Vector3(1, 1, 1))

	# 트랙 3: Y축 회전
	var rot_track := bounce_anim.add_track(Animation.TYPE_VALUE)
	bounce_anim.track_set_path(rot_track, "DemoBox:rotation:y")
	bounce_anim.track_insert_key(rot_track, 0.0, 0.0)
	bounce_anim.track_insert_key(rot_track, 2.0, TAU)  # 한 바퀴

	# AnimationLibrary에 등록
	var library := AnimationLibrary.new()
	library.add_animation("bounce", bounce_anim)

	# 대기 애니메이션 (idle)
	var idle_anim := Animation.new()
	idle_anim.length = 1.5
	idle_anim.loop_mode = Animation.LOOP_LINEAR

	var idle_scale := idle_anim.add_track(Animation.TYPE_VALUE)
	idle_anim.track_set_path(idle_scale, "DemoBox:scale")
	idle_anim.track_set_interpolation_type(idle_scale, Animation.INTERPOLATION_CUBIC)
	idle_anim.track_insert_key(idle_scale, 0.0, Vector3(1, 1, 1))
	idle_anim.track_insert_key(idle_scale, 0.75, Vector3(1.05, 0.95, 1.05))  # 숨쉬기
	idle_anim.track_insert_key(idle_scale, 1.5, Vector3(1, 1, 1))

	library.add_animation("idle", idle_anim)
	anim_player.add_animation_library("", library)

	print("  애니메이션 생성:")
	print("    'bounce': 3트랙 (위치Y + 스케일 + 회전Y), 길이 %.1f초, 루프" % bounce_anim.length)
	print("    'idle': 1트랙 (스케일 호흡), 길이 %.1f초, 루프" % idle_anim.length)
	print()

	# 재생 제어
	anim_player.play("bounce")
	print("  재생 제어 API:")
	print("    play(name, blend=-1, speed=1.0, from_end=false)")
	print("    play_backwards(name)  # 역재생")
	print("    pause()               # 일시정지")
	print("    stop()                # 정지")
	print("    seek(sec, update=false)  # 특정 시간으로 이동")
	print("    speed_scale = 1.5     # 재생 속도 배율")
	print("    queue(name)           # 현재 끝나면 다음 재생")
	print()
	print("    현재: '%s' 재생 중" % anim_player.current_animation)
	print()

	# 블렌딩
	print("  애니메이션 블렌딩:")
	print("    play(\"run\", 0.3)  # 0.3초에 걸쳐 전환")
	print("    -> 이전 애니메이션에서 새 애니메이션으로 부드럽게 전환")
	print()

	# 시그널
	anim_player.animation_finished.connect(func(name):
		print("    [시그널] 애니메이션 '%s' 완료" % name)
	)

	# 메서드 콜 트랙
	print("  메서드 콜 트랙 (이벤트 트리거):")
	print("    var method_track = anim.add_track(Animation.TYPE_METHOD)")
	print("    anim.track_set_path(method_track, \".\")")
	print("    anim.track_insert_key(method_track, 0.5,")
	print("        {\"method\": \"play_footstep\", \"args\": []})")

	print("연습 1 완료: 애니메이션 재생 제어\n")


# ==============================================================================
# 연습 2: AnimationTree - StateMachine으로 상태 기반 애니메이션
#          전환을 구현하세요.
# ==============================================================================
func _exercise_2_animation_tree():
	# 풀이: AnimationTree는 복잡한 애니메이션 전환 로직을 관리합니다.
	#       AnimationNodeStateMachine으로 상태 머신을 구성하고,
	#       각 상태 사이의 전환(Transition)을 정의합니다.
	#       코드에서 travel()로 상태를 전환하면 자동으로 블렌딩됩니다.
	#       advance 조건으로 자동 전환도 가능합니다.

	print("연습 2: AnimationTree (StateMachine)")

	# AnimationTree 구조 설명
	print("  AnimationTree 노드 타입:")
	print("    AnimationNodeStateMachine: 상태 머신 (가장 흔함)")
	print("    AnimationNodeBlendTree: 블렌드 트리 (믹싱)")
	print("    AnimationNodeBlendSpace1D: 1D 블렌드 (speed)")
	print("    AnimationNodeBlendSpace2D: 2D 블렌드 (direction)")
	print("    AnimationNodeAnimation: 단일 애니메이션 참조")
	print("    AnimationNodeTransition: 수동 전환")
	print()

	# StateMachine 코드 생성
	# 풀이: AnimationTree를 코드로 구성할 수 있지만,
	#       보통 에디터에서 시각적으로 구성하는 것이 더 편리합니다.
	var anim_tree := AnimationTree.new()
	anim_tree.name = "AnimationTree"

	var state_machine := AnimationNodeStateMachine.new()
	anim_tree.tree_root = state_machine
	anim_tree.anim_player = anim_player.get_path()

	# 상태 추가
	# 풀이: add_node()로 상태를, add_transition()으로 전환을 추가합니다.
	var idle_node := AnimationNodeAnimation.new()
	idle_node.animation = &"idle"
	state_machine.add_node("idle", idle_node, Vector2(0, 0))

	var bounce_node := AnimationNodeAnimation.new()
	bounce_node.animation = &"bounce"
	state_machine.add_node("bounce", bounce_node, Vector2(200, 0))

	# 전환 추가
	var transition_to_bounce := AnimationNodeStateMachineTransition.new()
	transition_to_bounce.xfade_time = 0.3      # 블렌딩 시간
	transition_to_bounce.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
	state_machine.add_transition("idle", "bounce", transition_to_bounce)

	var transition_to_idle := AnimationNodeStateMachineTransition.new()
	transition_to_idle.xfade_time = 0.3
	state_machine.add_transition("bounce", "idle", transition_to_idle)

	anim_tree.active = true
	add_child(anim_tree)

	print("  StateMachine 구성:")
	print("    상태: idle, bounce")
	print("    전환: idle <-> bounce (xfade: 0.3초)")
	print("    active: %s" % anim_tree.active)
	print()

	# 상태 전환 API
	print("  상태 전환 코드:")
	print("  ```gdscript")
	print("  var playback = anim_tree[\"parameters/playback\"]")
	print("  # AnimationNodeStateMachinePlayback 가져오기")
	print("")
	print("  # 상태 전환 (경로를 따라 자동 전환)")
	print("  playback.travel(\"run\")")
	print("")
	print("  # 즉시 전환 (블렌딩 무시)")
	print("  playback.start(\"jump\")")
	print("")
	print("  # 현재 상태 확인")
	print("  var current = playback.get_current_node()")
	print("  var is_playing = playback.is_playing()")
	print("  ```")
	print()

	# 전형적인 캐릭터 상태 머신
	print("  전형적인 캐릭터 StateMachine:")
	print("    [idle] --입력--> [walk] --속도증가--> [run]")
	print("      |                |                  |")
	print("      +---점프----> [jump] --착지------> [idle]")
	print("      |                |")
	print("      +---공격----> [attack] --끝------> [idle]")
	print("      |")
	print("      +---피격----> [hit] --회복-------> [idle]")
	print("      |")
	print("      +---사망----> [death]")
	print()

	# 전환 옵션
	print("  전환 옵션:")
	print("    xfade_time: 블렌딩 시간 (초)")
	print("    xfade_curve: 블렌딩 커브")
	print("    switch_mode:")
	print("      IMMEDIATE: 즉시 전환")
	print("      SYNC: 동기화 전환 (같은 시간 위치)")
	print("      AT_END: 현재 애니메이션 끝나면 전환")
	print("    advance_mode:")
	print("      AUTO: 자동 (advance_condition 사용)")
	print("      ENABLED: 항상 전환 가능")
	print("      DISABLED: 전환 비활성")

	print("연습 2 완료: AnimationTree\n")


# ==============================================================================
# 연습 3: BlendSpace - BlendSpace2D로 이동 방향과 속도에 따라
#          애니메이션을 블렌딩하세요.
# ==============================================================================
func _exercise_3_blend_space():
	# 풀이: BlendSpace2D는 2D 좌표에 애니메이션을 배치하고,
	#       현재 좌표에 따라 가장 가까운 애니메이션들을 자동으로 블렌딩합니다.
	#       X축 = 좌우 방향, Y축 = 전후 방향(또는 속도)으로 설정하여
	#       8방향 이동 애니메이션을 부드럽게 전환할 수 있습니다.
	#       BlendSpace1D는 속도(walk->run) 같은 단일 축 블렌딩에 사용합니다.

	print("연습 3: BlendSpace")

	# BlendSpace2D 구조
	print("  BlendSpace2D 구조:")
	print("    X축: 좌우 방향 (-1 ~ 1)")
	print("    Y축: 전후 방향 (-1 ~ 1)")
	print()
	print("    배치 예시:")
	print("    (-1,1)WalkLeft  (0,1)WalkForward  (1,1)WalkRight")
	print("         \\              |              /")
	print("    (-1,0)Strafe    (0,0)Idle      (1,0)Strafe")
	print("         /              |              \\")
	print("    (-1,-1)BackLeft (0,-1)WalkBack  (1,-1)BackRight")
	print()

	# BlendSpace2D 코드 설정
	print("  코드 설정:")
	print("  ```gdscript")
	print("  # AnimationTree의 BlendSpace2D 노드에 접근")
	print("  var blend_space = AnimationNodeBlendSpace2D.new()")
	print("  blend_space.min_space = Vector2(-1, -1)")
	print("  blend_space.max_space = Vector2(1, 1)")
	print("  blend_space.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_INTERPOLATED")
	print("")
	print("  # 애니메이션 포인트 추가")
	print("  blend_space.add_blend_point(idle_anim, Vector2(0, 0))")
	print("  blend_space.add_blend_point(walk_fwd, Vector2(0, 1))")
	print("  blend_space.add_blend_point(walk_back, Vector2(0, -1))")
	print("  blend_space.add_blend_point(walk_left, Vector2(-1, 0))")
	print("  blend_space.add_blend_point(walk_right, Vector2(1, 0))")
	print("  ```")
	print()

	# 이동 입력 연결
	print("  이동 입력을 BlendSpace에 연결:")
	print("  ```gdscript")
	print("  func _physics_process(delta):")
	print("      var input_dir = Input.get_vector(\"left\", \"right\",")
	print("                                        \"forward\", \"back\")")
	print("")
	print("      # 로컬 방향으로 변환 (카메라 기준)")
	print("      var local_dir = Vector2(input_dir.x, input_dir.y)")
	print("")
	print("      # BlendSpace2D 파라미터 설정")
	print("      anim_tree[\"parameters/Movement/blend_position\"] = local_dir")
	print("  ```")
	print()

	# BlendSpace1D (1차원 블렌딩)
	print("  BlendSpace1D (속도 기반):")
	print("    0.0 = Idle")
	print("    0.5 = Walk")
	print("    1.0 = Run")
	print("  ```gdscript")
	print("  var speed_ratio = velocity.length() / max_speed")
	print("  anim_tree[\"parameters/Speed/blend_position\"] = speed_ratio")
	print("  ```")
	print()

	# 블렌드 모드
	print("  BlendSpace2D 블렌드 모드:")
	print("    INTERPOLATED: 가장 가까운 삼각형 내 보간 (기본)")
	print("    DISCRETE: 가장 가까운 포인트만 재생 (전환 없음)")
	print("    DISCRETE_CARRY: DISCRETE + 시간 유지")

	print("연습 3 완료: BlendSpace\n")


# ==============================================================================
# 연습 4: Tween 3D - Tween으로 3D 오브젝트의 위치, 회전, 스케일,
#          머티리얼 색상을 애니메이션하세요.
# ==============================================================================
func _exercise_4_tween_3d():
	# 풀이: Tween은 코드로 간단한 보간 애니메이션을 만드는 도구입니다.
	#       AnimationPlayer보다 가볍고, 일회성 효과에 적합합니다.
	#       3D에서도 position, rotation, scale 등을 tween_property로 조작합니다.
	#       parallel()로 동시 실행, 체이닝으로 순차 실행합니다.

	print("연습 4: Tween 3D 애니메이션")

	# 테스트 오브젝트 생성
	var tween_box := MeshInstance3D.new()
	tween_box.name = "TweenBox"
	var box := BoxMesh.new()
	box.size = Vector3(0.8, 0.8, 0.8)
	tween_box.mesh = box
	tween_box.position = Vector3(3, 0.4, 0)

	var tween_mat := StandardMaterial3D.new()
	tween_mat.albedo_color = Color.RED
	tween_box.material_override = tween_mat
	add_child(tween_box)

	# Phase 1: 위로 이동 + 색상 변경 (동시)
	var tween := create_tween()

	# 풀이: tween_property(node, property, final_val, duration)로 속성을 보간합니다.
	#       3D position은 Vector3, rotation은 라디안입니다.
	tween.tween_property(tween_box, "position", Vector3(3, 3, 0), 1.0) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(tween_mat, "albedo_color", Color.YELLOW, 1.0)

	# Phase 2: Y축 회전 1바퀴
	tween.tween_property(tween_box, "rotation:y", TAU, 0.8) \
		.set_trans(Tween.TRANS_SINE)

	# Phase 3: 아래로 내려옴 + 스케일 변형 (동시)
	tween.tween_property(tween_box, "position", Vector3(3, 0.4, 0), 0.6) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(tween_box, "scale", Vector3(1.3, 0.7, 1.3), 0.2)

	# Phase 4: 스케일 복원 + 색상 복원
	tween.tween_property(tween_box, "scale", Vector3.ONE, 0.3) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(tween_mat, "albedo_color", Color.RED, 0.3)

	# 완료 콜백
	tween.tween_callback(func():
		print("    [Tween] 3D 애니메이션 완료!")
		tween_box.rotation.y = 0  # 회전 리셋
	)

	print("  Tween 체이닝 애니메이션:")
	print("    Phase 1: 위로 이동 + 색상 변경 (동시, 1.0초)")
	print("    Phase 2: Y축 1바퀴 회전 (0.8초)")
	print("    Phase 3: 바운스 낙하 + 찌그러짐 (동시, 0.6초)")
	print("    Phase 4: 탄성 복원 + 색상 복원 (동시, 0.3초)")
	print()

	# 3D Tween 주요 속성
	print("  3D Tween 가능한 속성:")
	print("    position: Vector3 위치")
	print("    rotation: Vector3 회전 (라디안)")
	print("    rotation:y: 개별 축 회전")
	print("    scale: Vector3 스케일")
	print("    material_override:albedo_color: 머티리얼 색상")
	print("    material_override:emission: 발광 색상")
	print()

	# 루프 Tween
	print("  루프 Tween:")
	print("    var tween = create_tween().set_loops()  # 무한 루프")
	print("    var tween = create_tween().set_loops(3)  # 3회 반복")
	print()

	# Tween vs AnimationPlayer 비교
	print("  Tween vs AnimationPlayer:")
	print("    +--------------+------------------+---------------------+")
	print("    | 특성         | Tween            | AnimationPlayer     |")
	print("    +--------------+------------------+---------------------+")
	print("    | 생성 방식    | 코드에서         | 에디터/코드         |")
	print("    | 복잡도       | 간단한 효과      | 복잡한 시퀀스       |")
	print("    | 재사용       | 1회성            | 재사용 가능         |")
	print("    | 블렌딩       | 불가             | 자동 블렌딩         |")
	print("    | 용도         | UI, 이펙트       | 캐릭터, 씬 전환     |")
	print("    +--------------+------------------+---------------------+")

	print("연습 4 완료: Tween 3D\n")


# ==============================================================================
# 연습 5: 절차적 애니메이션 - 코드로 실시간 계산되는 애니메이션을
#          구현하세요 (보빙, 흔들림, LookAt IK 등).
# ==============================================================================
func _exercise_5_procedural_animation():
	# 풀이: 절차적 애니메이션은 키프레임 없이 코드로 실시간 계산합니다.
	#       sin/cos 함수로 주기적 움직임(보빙, 흔들림)을 만들고,
	#       noise로 자연스러운 랜덤 움직임을 생성합니다.
	#       LookAt IK로 머리나 눈이 대상을 추적하는 효과를 만듭니다.
	#       _process()에서 매 프레임 계산하므로 반응적이고 유연합니다.

	print("연습 5: 절차적 애니메이션")

	# 1) 보빙 (Bobbing) - 상하 움직임
	# 풀이: sin(time * speed) * amplitude로 주기적인 상하 움직임을 만듭니다.
	#       FPS 카메라의 걷기 효과, 떠 있는 아이템에 사용합니다.
	print("  1) 보빙 (Bobbing):")
	print("  ```gdscript")
	print("  var bob_time: float = 0.0")
	print("  var bob_speed: float = 8.0     # 초당 주기")
	print("  var bob_amplitude: float = 0.05 # 진폭 (미터)")
	print("")
	print("  func _process(delta):")
	print("      if is_moving:")
	print("          bob_time += delta * bob_speed")
	print("          camera.position.y = base_height + sin(bob_time) * bob_amplitude")
	print("          camera.position.x = cos(bob_time * 0.5) * bob_amplitude * 0.5")
	print("      else:")
	print("          # 부드럽게 원위치")
	print("          camera.position.y = lerp(camera.position.y, base_height, delta * 5.0)")
	print("          camera.position.x = lerp(camera.position.x, 0.0, delta * 5.0)")
	print("  ```")
	print()

	# 보빙 시뮬레이션 출력
	print("  보빙 값 시뮬레이션 (bob_speed=8.0, amplitude=0.05):")
	for i in range(8):
		var t := i * 0.1
		var bob_val := sin(t * 8.0) * 0.05
		print("    t=%.1fs: y_offset=%.4f m" % [t, bob_val])
	print()

	# 2) 무기 흔들림 (Weapon Sway)
	# 풀이: 마우스 이동에 반응하여 무기가 살짝 흔들리는 효과입니다.
	#       lerp로 부드럽게 따라가게 하면 자연스럽습니다.
	print("  2) 무기 흔들림 (Sway):")
	print("  ```gdscript")
	print("  var sway_amount: float = 0.002")
	print("  var sway_speed: float = 5.0")
	print("  var sway_target: Vector3 = Vector3.ZERO")
	print("")
	print("  func _unhandled_input(event):")
	print("      if event is InputEventMouseMotion:")
	print("          sway_target.x = -event.relative.x * sway_amount")
	print("          sway_target.y = event.relative.y * sway_amount")
	print("")
	print("  func _process(delta):")
	print("      weapon.position = weapon.position.lerp(")
	print("          base_weapon_pos + sway_target, delta * sway_speed)")
	print("      sway_target = sway_target.lerp(Vector3.ZERO, delta * 3.0)")
	print("  ```")
	print()

	# 3) LookAt IK (시선 추적)
	# 풀이: 머리나 상체가 대상을 향하도록 회전합니다.
	#       look_at()을 직접 사용하면 너무 급격하므로,
	#       lerp_angle이나 Quaternion.slerp로 부드럽게 보간합니다.
	print("  3) LookAt IK (시선 추적):")
	print("  ```gdscript")
	print("  @export var look_target: Node3D")
	print("  @export var head_bone: String = \"Head\"")
	print("  @export var look_speed: float = 5.0")
	print("  @export var max_look_angle: float = 70.0")
	print("")
	print("  func _process(delta):")
	print("      if not look_target:")
	print("          return")
	print("")
	print("      var head_pos = skeleton.global_transform *")
	print("          skeleton.get_bone_global_pose(head_idx).origin")
	print("      var dir_to_target = (look_target.global_position -")
	print("          head_pos).normalized()")
	print("")
	print("      # 각도 제한")
	print("      var forward = -global_transform.basis.z")
	print("      var angle = rad_to_deg(forward.angle_to(dir_to_target))")
	print("      if angle > max_look_angle:")
	print("          return  # 너무 큰 각도면 무시")
	print("")
	print("      # 부드럽게 회전 (Quaternion slerp)")
	print("      var current_quat = head_bone_transform.basis.get_rotation_quaternion()")
	print("      var target_quat = Basis.looking_at(dir_to_target).get_rotation_quaternion()")
	print("      var smooth_quat = current_quat.slerp(target_quat, delta * look_speed)")
	print("  ```")
	print()

	# 4) 절차적 반동 (Recoil)
	print("  4) 반동 (Recoil):")
	print("  ```gdscript")
	print("  var recoil_rotation: Vector3 = Vector3.ZERO")
	print("  var recoil_position: Vector3 = Vector3.ZERO")
	print("")
	print("  func apply_recoil():")
	print("      recoil_rotation.x -= randf_range(2.0, 4.0)  # 위로 튀기")
	print("      recoil_rotation.y += randf_range(-1.0, 1.0)  # 좌우 흔들림")
	print("      recoil_position.z += 0.05  # 뒤로 밀림")
	print("")
	print("  func _process(delta):")
	print("      # 부드럽게 원위치 복귀")
	print("      recoil_rotation = recoil_rotation.lerp(Vector3.ZERO, delta * 10.0)")
	print("      recoil_position = recoil_position.lerp(Vector3.ZERO, delta * 8.0)")
	print("      weapon.rotation += recoil_rotation * delta")
	print("      weapon.position = base_pos + recoil_position")
	print("  ```")

	print("연습 5 완료: 절차적 애니메이션\n")
