# Chapter 15 - 3D Character Controller
# 01-mouse-look.gd - 마우스 캡처와 마우스 룩
#
# 이 파일에서 배울 내용:
# - Input.MOUSE_MODE_CAPTURED로 마우스 캡처
# - InputEventMouseMotion으로 마우스 이동 감지
# - 카메라 피봇 구조와 수직/수평 회전 분리
# - 마우스 감도, 수직 각도 제한, 부드러운 회전

extends Node3D

# ============================================
# 마우스 룩 설정
# ============================================

# 마우스 감도
var mouse_sensitivity := 0.002  # 라디안 단위 (낮을수록 느림)
# 수직 회전 제한 (위아래)
var pitch_min := -89.0  # 최대 아래 (도 단위)
var pitch_max := 89.0   # 최대 위 (도 단위)

# 부드러운 회전 (스무딩)
var smooth_mouse := false
var mouse_smoothing := 10.0  # 값이 클수록 빠른 반응

# 현재 회전값
var current_pitch := 0.0  # X축 회전 (위아래)
var current_yaw := 0.0    # Y축 회전 (좌우)

# 부드러운 회전용 목표값
var target_pitch := 0.0
var target_yaw := 0.0

# 노드 참조
var camera_pivot: Node3D
var camera: Camera3D

func _ready():
	print("=== 마우스 캡처와 마우스 룩 ===\n")

	# 씬 구성
	_create_scene()

	# ============================================
	# 1. 마우스 캡처 (Mouse Capture)
	# ============================================
	print("--- 1. 마우스 캡처 ---\n")

	print("마우스 모드 종류:")
	print("  MOUSE_MODE_VISIBLE   -> 일반 (기본값)")
	print("  MOUSE_MODE_HIDDEN    -> 숨김 (커서 안 보임)")
	print("  MOUSE_MODE_CAPTURED  -> 캡처 (FPS 필수!)")
	print("  MOUSE_MODE_CONFINED  -> 창 안에 가둠")
	print("  MOUSE_MODE_CONFINED_HIDDEN -> 가둠 + 숨김")
	print("")

	# 마우스 캡처 (FPS에서 필수)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)")
	print("  마우스가 화면 중앙에 고정됨")
	print("  마우스 이동은 InputEventMouseMotion.relative로 감지")
	print("  ESC로 캡처 해제 (코드 작성 필요)")
	print("")

	print("마우스 캡처 해제 코드:")
	print("""  func _unhandled_input(event):
      if event.is_action_pressed("ui_cancel"):
          if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
              Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
          else:
              Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)""")
	print("")

	print("** 주의: 에디터에서 테스트 시 ESC로 캡처를 해제해야 함! **")

	# ============================================
	# 2. 카메라 피봇 구조
	# ============================================
	print("\n--- 2. 카메라 피봇 구조 ---\n")

	print("왜 피봇이 필요한가?")
	print("  FPS에서 좌우 회전은 캐릭터 전체가 도는 것")
	print("  상하 회전은 고개만 숙이는 것")
	print("  -> 두 축을 분리해야 자연스러움!")
	print("")

	print("노드 구조:")
	print("  CharacterBody3D (또는 Node3D)")
	print("    +-- CameraPivot (Node3D)    <- Y축 회전 (좌우)")
	print("         +-- Camera3D           <- X축 회전 (위아래)")
	print("    +-- CollisionShape3D")
	print("    +-- MeshInstance3D")
	print("")

	print("FPS 구조:")
	print("  캐릭터 루트:  rotate_y() -> 좌우 회전 (Yaw)")
	print("  카메라 피봇:  rotate_x() -> 위아래 회전 (Pitch)")
	print("  -> 이렇게 분리하면 짐벌 락 없이 자연스러운 회전!")
	print("")

	print("TPS 구조:")
	print("  카메라 피봇:  rotate_y() + rotate_x()")
	print("  캐릭터는 이동 방향으로 별도 회전")
	print("  -> 카메라와 캐릭터 회전이 독립적!")

	# ============================================
	# 3. 기본 마우스 룩 구현
	# ============================================
	print("\n--- 3. 기본 마우스 룩 구현 ---\n")

	print("핵심 코드 (_unhandled_input):")
	print("""  func _unhandled_input(event: InputEvent):
      if event is InputEventMouseMotion:
          # 마우스 이동량 (relative는 이전 프레임 대비 이동 픽셀)
          var mouse_delta = event.relative

          # 좌우 회전 (Y축) - 캐릭터 루트에 적용
          rotate_y(-mouse_delta.x * mouse_sensitivity)

          # 위아래 회전 (X축) - 카메라 피봇에 적용
          camera_pivot.rotate_x(-mouse_delta.y * mouse_sensitivity)

          # 수직 각도 제한 (180도 넘어가는 거 방지!)
          camera_pivot.rotation.x = clamp(
              camera_pivot.rotation.x,
              deg_to_rad(-89),
              deg_to_rad(89)
          )""")
	print("")

	print("왜 -mouse_delta.x인가?")
	print("  마우스를 오른쪽으로 -> delta.x 양수")
	print("  캐릭터는 오른쪽으로 회전 -> Y축 음수 회전")
	print("  -> 부호를 반전!")
	print("")

	print("왜 각도 제한이 필요한가?")
	print("  제한 없으면 360도 회전 가능 (목이 꺾임!)")
	print("  -89 ~ 89도로 제한 (90도에서 짐벌 락 가능)")
	print("  clamp()로 범위 제한")

	# ============================================
	# 4. 마우스 감도 설정
	# ============================================
	print("\n--- 4. 마우스 감도 설정 ---\n")

	print("감도 가이드:")
	print("  0.001: 매우 느림 (스나이퍼)")
	print("  0.002: 보통 (일반적인 FPS 기본값)")
	print("  0.003: 빠름")
	print("  0.005: 매우 빠름")
	print("")

	print("감도 설정 UI 패턴:")
	print("""  # 0.1 ~ 2.0 범위의 감도 슬라이더
  var base_sensitivity: float = 0.002
  var sensitivity_multiplier: float = 1.0  # UI에서 조절

  func get_effective_sensitivity() -> float:
      return base_sensitivity * sensitivity_multiplier

  # 슬라이더 값 변경 시
  func _on_sensitivity_slider_changed(value: float):
      sensitivity_multiplier = value  # 0.1 ~ 2.0""")
	print("")

	print("X/Y 감도 분리:")
	print("  var sensitivity_x: float = 0.002  # 좌우")
	print("  var sensitivity_y: float = 0.002  # 상하")
	print("  -> 일부 플레이어는 상하를 더 느리게 선호")
	print("")

	print("Y축 반전 (Invert Y):")
	print("  var invert_y: bool = false")
	print("  var y_direction = -1 if invert_y else 1")
	print("  camera_pivot.rotate_x(-mouse_delta.y * sensitivity * y_direction)")

	# ============================================
	# 5. 부드러운 마우스 룩 (Smoothing)
	# ============================================
	print("\n--- 5. 부드러운 마우스 룩 ---\n")

	print("즉시 반응 vs 부드러운 반응:")
	print("  즉시: 입력 즉시 적용 (FPS에서 권장)")
	print("  부드러움: lerp로 점진적 적용 (영화적, 약간의 입력 지연)")
	print("")

	print("부드러운 마우스 룩 코드:")
	print("""  var target_yaw: float = 0.0
  var target_pitch: float = 0.0
  var smoothing_speed: float = 15.0

  func _unhandled_input(event):
      if event is InputEventMouseMotion:
          target_yaw -= event.relative.x * mouse_sensitivity
          target_pitch -= event.relative.y * mouse_sensitivity
          target_pitch = clamp(target_pitch, deg_to_rad(-89), deg_to_rad(89))

  func _process(delta):
      # 현재 회전을 목표값으로 부드럽게 보간
      rotation.y = lerp_angle(rotation.y, target_yaw, smoothing_speed * delta)
      camera_pivot.rotation.x = lerp(
          camera_pivot.rotation.x, target_pitch, smoothing_speed * delta)""")
	print("")

	print("** 대부분의 FPS 게임은 즉시 반응을 사용 **")
	print("  부드러운 마우스 = 입력 지연 = FPS에서 불쾌감")
	print("  TPS/시네마틱에서는 부드러운 것이 어울릴 수 있음")

	# ============================================
	# 6. 포커스 관리
	# ============================================
	print("\n--- 6. 포커스 관리 ---\n")

	print("게임 + UI 전환 패턴:")
	print("""  var is_paused: bool = false

  func _unhandled_input(event):
      # ESC로 일시정지 메뉴 토글
      if event.is_action_pressed("ui_cancel"):
          toggle_pause()

      # 마우스 캡처 상태에서만 마우스 룩 처리
      if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
          if event is InputEventMouseMotion:
              # 마우스 룩 처리...
              pass

  func toggle_pause():
      is_paused = !is_paused
      if is_paused:
          Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
          $PauseMenu.show()
          get_tree().paused = true
      else:
          Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
          $PauseMenu.hide()
          get_tree().paused = false""")
	print("")

	print("창 포커스 잃었을 때:")
	print("""  func _notification(what):
      if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
          # 창이 포커스를 잃으면 마우스 해제
          Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
      elif what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
          # 창이 포커스를 얻으면 다시 캡처
          if not is_paused:
              Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)""")

	# ============================================
	# 7. 카메라 흔들림 (Head Bob / Shake)
	# ============================================
	print("\n--- 7. 카메라 효과 ---\n")

	print("걷기 Head Bob:")
	print("""  var head_bob_timer: float = 0.0
  var head_bob_frequency: float = 2.0  # 흔들림 빈도
  var head_bob_amplitude: float = 0.05 # 흔들림 높이

  func _process(delta):
      if is_on_floor() and velocity.length() > 0.5:
          head_bob_timer += delta * velocity.length()
          camera.position.y = sin(head_bob_timer * head_bob_frequency) * head_bob_amplitude
      else:
          camera.position.y = lerp(camera.position.y, 0.0, 10.0 * delta)""")
	print("")

	print("카메라 흔들림 (피격/폭발):")
	print("""  var shake_intensity: float = 0.0
  var shake_decay: float = 5.0

  func shake(intensity: float):
      shake_intensity = intensity

  func _process(delta):
      if shake_intensity > 0.01:
          camera.position.x = randf_range(-1, 1) * shake_intensity
          camera.position.y = randf_range(-1, 1) * shake_intensity
          shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
      else:
          shake_intensity = 0.0
          camera.position = Vector3.ZERO""")

	# ============================================
	# 8. 전체 코드 (종합)
	# ============================================
	print("\n--- 8. 완성 코드 (종합) ---\n")

	print("""  extends CharacterBody3D

  @export var mouse_sensitivity: float = 0.002
  @export var invert_y: bool = false

  @onready var camera_pivot = $CameraPivot
  @onready var camera = $CameraPivot/Camera3D

  func _ready():
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

  func _unhandled_input(event: InputEvent):
      # ESC로 마우스 토글
      if event.is_action_pressed("ui_cancel"):
          if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
              Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
          else:
              Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

      # 마우스 룩
      if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
          if event is InputEventMouseMotion:
              var y_dir = -1.0 if invert_y else 1.0
              rotate_y(-event.relative.x * mouse_sensitivity)
              camera_pivot.rotate_x(
                  -event.relative.y * mouse_sensitivity * y_dir)
              camera_pivot.rotation.x = clamp(
                  camera_pivot.rotation.x,
                  deg_to_rad(-89), deg_to_rad(89))""")

	# ============================================
	# 9. 정리
	# ============================================
	print("\n=== 정리 ===\n")

	print("1. MOUSE_MODE_CAPTURED: FPS 마우스 캡처 필수")
	print("2. InputEventMouseMotion.relative: 마우스 이동량")
	print("3. 피봇 구조: 루트(Y회전) + 피봇(X회전) 분리")
	print("4. clamp(): 수직 각도 -89~89도 제한")
	print("5. mouse_sensitivity: 0.002가 일반적 기본값")
	print("6. ESC 토글: 캡처/해제 전환 필수 구현")
	print("7. 부드러운 회전: lerp_angle() 사용 (선택)")
	print("8. Head Bob / Shake: 몰입감 증가 효과")

	# ESC로 해제
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _create_scene():
	# 바닥
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20, 0.1, 20)
	floor_col.shape = floor_shape
	floor_body.add_child(floor_col)
	var floor_mi := MeshInstance3D.new()
	var fmesh := BoxMesh.new()
	fmesh.size = Vector3(20, 0.1, 20)
	floor_mi.mesh = fmesh
	floor_body.add_child(floor_mi)
	add_child(floor_body)

	# 카메라 피봇 + 카메라
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 1.7, 0)  # 눈 높이
	add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "Camera"
	camera_pivot.add_child(camera)
	camera.make_current()

	# 조명
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	add_child(light)

	# 참고용 큐브들
	for i in range(5):
		var cube := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		cube.mesh = mesh
		cube.position = Vector3((i - 2) * 3, 0.5, -5)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(float(i) / 5, 0.5, 1.0 - float(i) / 5)
		cube.material_override = mat
		add_child(cube)
