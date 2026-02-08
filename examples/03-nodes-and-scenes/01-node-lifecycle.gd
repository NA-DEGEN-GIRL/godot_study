# Chapter 03 - Nodes and Scenes
# 01-node-lifecycle.gd - Node Lifecycle Methods
#
# 이 파일에서 배울 내용:
# - _init(), _ready(), _enter_tree(), _exit_tree() 초기화 순서
# - _process(delta)와 _physics_process(delta) 차이점
# - delta 시간의 의미와 프레임 독립적 움직임
# - 노드 라이프사이클 전체 흐름 이해

extends Node

# ============================================
# 1. 라이프사이클 함수 개요
# ============================================

# Godot 노드의 라이프사이클 순서:
#
# 1. _init()           - 객체 생성 시 (생성자)
# 2. _enter_tree()     - 씬 트리에 들어갈 때
# 3. _ready()          - 모든 자식 노드가 준비된 후 (1회)
# 4. _process(delta)   - 매 프레임마다 (렌더링 프레임)
# 5. _physics_process(delta) - 고정 간격으로 (물리 프레임)
# 6. _exit_tree()      - 씬 트리에서 나갈 때
#
# 프레임 순서 (매 프레임):
# _physics_process -> _process -> 렌더링

# 멤버 변수
var creation_time: int = 0
var frame_count: int = 0
var physics_frame_count: int = 0
var elapsed_time: float = 0.0
var physics_elapsed: float = 0.0
var max_demo_frames: int = 5  # 데모에서 보여줄 프레임 수

# ============================================
# 2. _init() - 생성자
# ============================================

# 객체가 메모리에 생성될 때 호출됩니다.
# 씬 트리에 아직 추가되지 않은 상태입니다.
# 다른 노드에 접근할 수 없습니다!
func _init():
	creation_time = Time.get_ticks_msec()
	print("[_init] 객체 생성됨 (시간: %dms)" % creation_time)
	print("[_init] 씬 트리에 아직 들어가지 않았습니다")
	print("[_init] get_parent() 등 노드 참조 사용 불가")
	print("")

# ============================================
# 3. _enter_tree() - 씬 트리 진입
# ============================================

# 노드가 씬 트리에 추가될 때 호출됩니다.
# add_child()로 추가하거나, 씬이 로드될 때 호출됩니다.
# _ready()보다 먼저 호출됩니다.
func _enter_tree():
	var enter_time := Time.get_ticks_msec()
	print("[_enter_tree] 씬 트리에 들어감 (시간: %dms)" % enter_time)
	print("[_enter_tree] 부모 노드: ", get_parent().name if get_parent() else "없음")
	print("[_enter_tree] 노드 경로: ", get_path())
	print("[_enter_tree] 자식 노드의 _ready()는 아직 호출되지 않았음")
	print("")

# ============================================
# 4. _ready() - 준비 완료
# ============================================

func _ready():
	var ready_time := Time.get_ticks_msec()
	print("[_ready] 노드 준비 완료 (시간: %dms)" % ready_time)
	print("[_ready] 초기화부터 준비까지: %dms" % (ready_time - creation_time))
	print("[_ready] 모든 자식 노드도 준비 완료됨")
	print("[_ready] 이제 다른 노드를 안전하게 참조할 수 있음")

	# ============================================
	# 5. _process vs _physics_process 비교
	# ============================================
	print("\n=== _process vs _physics_process ===\n")

	print("_process(delta):")
	print("  - 매 렌더링 프레임마다 호출")
	print("  - FPS에 따라 호출 빈도가 달라짐")
	print("  - 60FPS -> 약 16.67ms 간격")
	print("  - 144FPS -> 약 6.94ms 간격")
	print("  - UI 업데이트, 애니메이션, 시각 효과에 사용")

	print("\n_physics_process(delta):")
	print("  - 고정 간격으로 호출 (기본 60Hz)")
	print("  - FPS와 무관하게 일정한 간격")
	print("  - Project Settings > Physics > Common > Physics Ticks Per Second")
	print("  - 물리 계산, 이동, 충돌 감지에 사용")

	# ============================================
	# 6. delta 시간 이해
	# ============================================
	print("\n=== delta 시간 이해 ===\n")

	print("delta = 이전 프레임부터 경과한 시간 (초 단위)")
	print("")
	print("프레임 독립적 이동 (필수!):")
	print("  잘못된 방법: position.x += 5    (FPS마다 다른 속도)")
	print("  올바른 방법: position.x += 5 * delta  (일정한 속도)")
	print("")
	print("예시 (speed = 200):")
	print("  60FPS: delta ~= 0.0167 -> 200 * 0.0167 = 3.33px/frame")
	print("  30FPS: delta ~= 0.0333 -> 200 * 0.0333 = 6.67px/frame")
	print("  둘 다 초당 200px 이동 (일정!)")

	# delta 시뮬레이션
	print("\ndelta 시뮬레이션:")
	var speed := 200.0

	# 60FPS 시뮬레이션
	var delta_60 := 1.0 / 60.0
	var movement_60 := speed * delta_60
	print("  60FPS: delta=%.4f, 이동=%.2fpx/frame, 초당=%.0fpx" % [delta_60, movement_60, movement_60 * 60])

	# 30FPS 시뮬레이션
	var delta_30 := 1.0 / 30.0
	var movement_30 := speed * delta_30
	print("  30FPS: delta=%.4f, 이동=%.2fpx/frame, 초당=%.0fpx" % [delta_30, movement_30, movement_30 * 30])

	# 144FPS 시뮬레이션
	var delta_144 := 1.0 / 144.0
	var movement_144 := speed * delta_144
	print("  144FPS: delta=%.4f, 이동=%.2fpx/frame, 초당=%.0fpx" % [delta_144, movement_144, movement_144 * 144])

	# ============================================
	# 7. 프로세싱 제어
	# ============================================
	print("\n=== 프로세싱 제어 ===\n")

	# _process 활성화/비활성화
	print("set_process(true/false): _process() 활성화/비활성화")
	print("set_physics_process(true/false): _physics_process() 활성화/비활성화")
	print("is_processing(): _process가 활성화되어 있는지 확인")
	print("is_physics_processing(): _physics_process가 활성화되어 있는지 확인")

	print("\n현재 상태:")
	print("  _process 활성: ", is_processing())
	print("  _physics_process 활성: ", is_physics_processing())

	# 일시 정지 (Pause)
	print("\n일시 정지 관련:")
	print("  get_tree().paused = true  -> 게임 일시 정지")
	print("  process_mode 속성으로 정지 시 동작 제어:")
	print("    PROCESS_MODE_INHERIT  -> 부모를 따름 (기본)")
	print("    PROCESS_MODE_PAUSABLE -> 정지 시 멈춤")
	print("    PROCESS_MODE_WHEN_PAUSED -> 정지 시에만 동작")
	print("    PROCESS_MODE_ALWAYS   -> 항상 동작")
	print("    PROCESS_MODE_DISABLED -> 항상 멈춤")

	# ============================================
	# 8. 기타 라이프사이클 함수
	# ============================================
	print("\n=== 기타 라이프사이클 함수 ===\n")

	print("_unhandled_input(event):")
	print("  - UI에서 처리되지 않은 입력 이벤트")
	print("  - 게임 플레이 입력 처리에 적합")

	print("\n_input(event):")
	print("  - 모든 입력 이벤트 (UI 포함)")
	print("  - 어떤 입력이든 가장 먼저 받음")

	print("\n_unhandled_key_input(event):")
	print("  - UI에서 처리되지 않은 키보드 입력만")

	print("\n_notification(what):")
	print("  - 모든 알림을 받는 저수준 함수")
	print("  - NOTIFICATION_READY, NOTIFICATION_PROCESS 등")

	# ============================================
	# 9. 노드 순서와 그룹
	# ============================================
	print("\n=== 노드 순서 ===\n")

	print("씬 트리에서 _ready() 호출 순서:")
	print("  Parent")
	print("  ├── Child_A  <- _ready() 1번째")
	print("  ├── Child_B  <- _ready() 2번째")
	print("  └── Child_C  <- _ready() 3번째")
	print("  Parent       <- _ready() 4번째 (자식 후에)")
	print("")
	print("_process() 호출 순서:")
	print("  Parent -> Child_A -> Child_B -> Child_C (위에서 아래)")

	# ============================================
	# 10. 타이머 예제
	# ============================================
	print("\n=== 타이머 활용 ===\n")

	# SceneTreeTimer 사용 (간단한 지연)
	print("get_tree().create_timer(2.0) -> 2초 후 실행")
	print("await get_tree().create_timer(1.0).timeout -> 1초 대기")

	# 타이머 시뮬레이션 (실제로는 await 사용)
	print("\n타이머 예제 (개념):")
	print("  func delayed_action():")
	print("    print('3초 후 실행')")
	print("    await get_tree().create_timer(3.0).timeout")
	print("    print('3초 지났습니다!')")

	# ============================================
	# 11. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("라이프사이클 순서:")
	print("  1. _init()           -> 객체 생성 (씬 트리 밖)")
	print("  2. _enter_tree()     -> 씬 트리 진입")
	print("  3. _ready()          -> 준비 완료 (1회)")
	print("  4. _process(delta)   -> 매 프레임 (렌더링)")
	print("  5. _physics_process(delta) -> 고정 간격 (물리)")
	print("  6. _exit_tree()      -> 씬 트리 퇴장")
	print("")
	print("핵심:")
	print("  - delta를 곱해서 프레임 독립적으로 만들기")
	print("  - 물리 관련은 _physics_process 사용")
	print("  - 시각 관련은 _process 사용")

	# 데모 목적으로 5프레임 후 _process를 비활성화
	print("\n(데모: %d프레임만 _process 출력 후 중단)\n" % max_demo_frames)


# ============================================
# 5-1. _process - 매 프레임 호출
# ============================================

func _process(delta: float):
	frame_count += 1
	elapsed_time += delta

	# 데모 목적으로 처음 몇 프레임만 출력
	if frame_count <= max_demo_frames:
		print("[_process] 프레임 %d | delta: %.4fs | 경과: %.3fs | FPS: %.0f" % [
			frame_count, delta, elapsed_time, 1.0 / delta
		])

	if frame_count == max_demo_frames:
		print("[_process] (이후 출력 생략...)\n")
		set_process(false)  # 데모 후 비활성화


# ============================================
# 5-2. _physics_process - 물리 프레임 호출
# ============================================

func _physics_process(delta: float):
	physics_frame_count += 1
	physics_elapsed += delta

	# 데모 목적으로 처음 몇 프레임만 출력
	if physics_frame_count <= max_demo_frames:
		print("[_physics_process] 프레임 %d | delta: %.4fs | 경과: %.3fs" % [
			physics_frame_count, delta, physics_elapsed
		])

	if physics_frame_count == max_demo_frames:
		print("[_physics_process] (이후 출력 생략...)\n")
		set_physics_process(false)  # 데모 후 비활성화


# ============================================
# 6. _exit_tree - 씬 트리 퇴장
# ============================================

func _exit_tree():
	print("[_exit_tree] 씬 트리에서 나갑니다")
	print("[_exit_tree] 총 렌더 프레임: %d, 물리 프레임: %d" % [frame_count, physics_frame_count])
	print("[_exit_tree] 여기서 정리 작업을 수행합니다 (시그널 해제, 리소스 해제 등)")
