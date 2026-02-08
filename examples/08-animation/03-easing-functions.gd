# Chapter 08 - Animation
# 03-easing-functions.gd - 이징 함수와 전환 유형
#
# 이 파일에서 배울 내용:
# - TransitionType (TRANS_*) 전환 유형 전체 목록
# - EaseType (EASE_*) 이징 방향
# - 각 조합의 커브 모양과 느낌
# - 실전에서 어떤 이징을 언제 사용하는지
# - 코드로 이징 커브 시각화
#
# 이징은 애니메이션의 "느낌"을 결정합니다.
# 같은 이동이라도 이징에 따라 완전히 다른 인상을 줍니다.

extends Node2D

# ============================================
# 1. 이징(Easing) 개념
# ============================================
# 선형(Linear): 일정한 속도로 변화 (로봇 같은 움직임)
# 이징: 시작/끝에서 속도가 달라짐 (자연스러운 움직임)
#
# 비유:
#   EASE_IN:     서서히 출발 (자동차가 정지에서 가속)
#   EASE_OUT:    서서히 정지 (자동차가 브레이크)
#   EASE_IN_OUT: 서서히 출발 + 서서히 정지 (가장 자연스러운)
#   EASE_OUT_IN: 빠른 시작/끝 + 중간에 느려짐 (특수 효과)

func _ready():
	print("=== Chapter 08-3: 이징 함수와 전환 유형 ===\n")

	_explain_ease_types()
	_explain_transition_types()
	_visualize_all_curves()
	_practical_usage_guide()
	_demonstrate_easing_comparison()
	_show_custom_curves()

# ============================================
# 2. EaseType (이징 방향)
# ============================================

func _explain_ease_types():
	print("--- 2. EaseType (이징 방향) ---")

	print("[Tween.EASE_IN]")
	print("  시작이 느리고 끝이 빠름")
	print("  __________/")
	print("  용도: 물체 가속, 공 떨어지기 시작")

	print("\n[Tween.EASE_OUT]")
	print("  시작이 빠르고 끝이 느림")
	print("  /~~~~~~~~~~")
	print("  용도: 물체 감속, UI 슬라이드 인, 바운스 착지")

	print("\n[Tween.EASE_IN_OUT]")
	print("  시작과 끝이 느리고 중간이 빠름")
	print("  __/~~~~\\__")
	print("  용도: 자연스러운 이동, 카메라 패닝, 대부분의 UI")

	print("\n[Tween.EASE_OUT_IN]")
	print("  시작과 끝이 빠르고 중간이 느림")
	print("  /~__~~__\\")
	print("  용도: 특수 효과, 탄성 중간 지점")

	print()

# ============================================
# 3. TransitionType (전환 유형)
# ============================================

func _explain_transition_types():
	print("--- 3. TransitionType (전환 커브) ---")

	var transitions = [
		{
			"name": "TRANS_LINEAR",
			"desc": "일정한 속도 (이징 없음)",
			"use": "기계적 움직임, 진행률 바, 타이머",
			"curve": "직선: /",
		},
		{
			"name": "TRANS_SINE",
			"desc": "사인 곡선 (매우 부드러움)",
			"use": "부드러운 UI, 호흡 효과, 떠다니기",
			"curve": "완만한 S자",
		},
		{
			"name": "TRANS_QUAD",
			"desc": "2차 함수 (t^2)",
			"use": "일반 애니메이션, 기본 가속/감속",
			"curve": "약간 급한 곡선",
		},
		{
			"name": "TRANS_CUBIC",
			"desc": "3차 함수 (t^3)",
			"use": "눈에 띄는 가속, 메뉴 전환",
			"curve": "더 급한 곡선",
		},
		{
			"name": "TRANS_QUART",
			"desc": "4차 함수 (t^4)",
			"use": "강한 가속 효과, 드라마틱한 전환",
			"curve": "매우 급한 곡선",
		},
		{
			"name": "TRANS_QUINT",
			"desc": "5차 함수 (t^5)",
			"use": "극적인 가속, 강한 임팩트",
			"curve": "극히 급한 곡선",
		},
		{
			"name": "TRANS_EXPO",
			"desc": "지수 함수 (2^t)",
			"use": "매우 강한 가속/감속, 폭발적 등장",
			"curve": "거의 직각에 가까운 곡선",
		},
		{
			"name": "TRANS_CIRC",
			"desc": "원 함수 (sqrt)",
			"use": "깔끔한 가속, 원형 운동",
			"curve": "원호 형태",
		},
		{
			"name": "TRANS_BACK",
			"desc": "약간 넘어갔다 돌아옴 (오버슈트)",
			"use": "팝업 효과, 등장 애니메이션, 버튼 클릭",
			"curve": "목표를 넘었다 돌아옴",
		},
		{
			"name": "TRANS_ELASTIC",
			"desc": "탄성/고무줄 효과 (여러 번 진동)",
			"use": "스프링 효과, 충돌 반동, 알림 등장",
			"curve": "진동하며 수렴",
		},
		{
			"name": "TRANS_BOUNCE",
			"desc": "공 튀기기 (바운스)",
			"use": "착지 효과, 물체 떨어짐, 활기찬 UI",
			"curve": "여러 번 튕김",
		},
		{
			"name": "TRANS_SPRING",
			"desc": "스프링 (Godot 4.2+)",
			"use": "물리적 스프링 운동, 카메라 진동",
			"curve": "감쇠 진동",
		},
	]

	for t in transitions:
		print("[%s]" % t.name)
		print("  설명: %s" % t.desc)
		print("  커브: %s" % t.curve)
		print("  용도: %s" % t.use)
		print()

# ============================================
# 4. 모든 커브 시각화 (ASCII)
# ============================================

func _visualize_all_curves():
	print("--- 4. 이징 커브 시각화 (EASE_OUT 기준) ---\n")

	var width = 40
	var height = 8

	var curves = {
		"LINEAR": Tween.TRANS_LINEAR,
		"SINE":   Tween.TRANS_SINE,
		"QUAD":   Tween.TRANS_QUAD,
		"CUBIC":  Tween.TRANS_CUBIC,
		"EXPO":   Tween.TRANS_EXPO,
		"BACK":   Tween.TRANS_BACK,
		"ELASTIC": Tween.TRANS_ELASTIC,
		"BOUNCE": Tween.TRANS_BOUNCE,
	}

	for curve_name in curves:
		var trans_type = curves[curve_name]
		print("  [%s + EASE_OUT]" % curve_name)
		_draw_ascii_curve(trans_type, Tween.EASE_OUT, width, height)
		print()

func _draw_ascii_curve(trans: Tween.TransitionType, ease: Tween.EaseType,
		w: int, h: int):
	# 커브 값을 계산하여 ASCII로 그리기
	var grid: Array = []
	for y in range(h):
		var row = ""
		for x in range(w):
			row += " "
		grid.append(row)

	# 각 x 위치에서의 y 값 계산
	for x in range(w):
		var t = float(x) / (w - 1)  # 0.0 ~ 1.0
		var value = _calculate_easing(t, trans, ease)
		value = clampf(value, -0.1, 1.1)  # 범위 제한

		var y = h - 1 - int(value * (h - 1))
		y = clampi(y, 0, h - 1)

		var row = grid[y]
		grid[y] = row.substr(0, x) + "#" + row.substr(x + 1)

	for row in grid:
		print("  |%s|" % row)
	print("  +%s+" % "-".repeat(w))

func _calculate_easing(t: float, trans: Tween.TransitionType,
		ease_type: Tween.EaseType) -> float:
	# 간단한 이징 근사 계산
	match trans:
		Tween.TRANS_LINEAR:
			return t
		Tween.TRANS_SINE:
			match ease_type:
				Tween.EASE_OUT:
					return sin(t * PI / 2)
				Tween.EASE_IN:
					return 1 - cos(t * PI / 2)
				_:
					return -(cos(PI * t) - 1) / 2
		Tween.TRANS_QUAD:
			match ease_type:
				Tween.EASE_OUT:
					return 1 - (1 - t) * (1 - t)
				Tween.EASE_IN:
					return t * t
				_:
					if t < 0.5:
						return 2 * t * t
					else:
						return 1 - pow(-2 * t + 2, 2) / 2
		Tween.TRANS_CUBIC:
			match ease_type:
				Tween.EASE_OUT:
					return 1 - pow(1 - t, 3)
				Tween.EASE_IN:
					return t * t * t
				_:
					if t < 0.5:
						return 4 * t * t * t
					else:
						return 1 - pow(-2 * t + 2, 3) / 2
		Tween.TRANS_EXPO:
			match ease_type:
				Tween.EASE_OUT:
					return 1 - pow(2, -10 * t) if t < 1.0 else 1.0
				Tween.EASE_IN:
					return pow(2, 10 * t - 10) if t > 0.0 else 0.0
				_:
					return t
		Tween.TRANS_BACK:
			var c1 = 1.70158
			var c3 = c1 + 1
			match ease_type:
				Tween.EASE_OUT:
					return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2)
				Tween.EASE_IN:
					return c3 * t * t * t - c1 * t * t
				_:
					return t
		Tween.TRANS_ELASTIC:
			match ease_type:
				Tween.EASE_OUT:
					if t <= 0 or t >= 1:
						return t
					return pow(2, -10 * t) * sin((t * 10 - 0.75) * (2 * PI) / 3) + 1
				_:
					return t
		Tween.TRANS_BOUNCE:
			match ease_type:
				Tween.EASE_OUT:
					return _bounce_ease_out(t)
				_:
					return 1 - _bounce_ease_out(1 - t)
		_:
			return t

	return t

func _bounce_ease_out(t: float) -> float:
	var n1 = 7.5625
	var d1 = 2.75
	if t < 1.0 / d1:
		return n1 * t * t
	elif t < 2.0 / d1:
		t -= 1.5 / d1
		return n1 * t * t + 0.75
	elif t < 2.5 / d1:
		t -= 2.25 / d1
		return n1 * t * t + 0.9375
	else:
		t -= 2.625 / d1
		return n1 * t * t + 0.984375

# ============================================
# 5. 실전 사용 가이드
# ============================================

func _practical_usage_guide():
	print("--- 5. 실전: 언제 어떤 이징을 쓸까? ---")

	print("[UI 애니메이션]")
	print("  팝업 등장:    TRANS_BACK  + EASE_OUT   (오버슈트!)")
	print("  팝업 사라짐:  TRANS_QUAD  + EASE_IN    (빠르게)")
	print("  슬라이드 인:  TRANS_CUBIC + EASE_OUT   (자연스러운 감속)")
	print("  슬라이드 아웃: TRANS_CUBIC + EASE_IN    (자연스러운 가속)")
	print("  페이드:       TRANS_SINE  + EASE_IN_OUT (매끄러운)")
	print("  버튼 클릭:    TRANS_BACK  + EASE_OUT   (팝!)")
	print("  알림 등장:    TRANS_ELASTIC + EASE_OUT  (주목!)")

	print("\n[게임 오브젝트]")
	print("  점프 상승:   TRANS_QUAD + EASE_OUT (감속하며 올라감)")
	print("  점프 하강:   TRANS_QUAD + EASE_IN  (가속하며 떨어짐)")
	print("  착지:        TRANS_BOUNCE + EASE_OUT (통통!)")
	print("  대시:        TRANS_EXPO + EASE_OUT (폭발적 시작)")
	print("  카메라 이동: TRANS_SINE + EASE_IN_OUT (부드러운)")
	print("  화면 흔들림: TRANS_SINE + EASE_OUT (진동 감쇠)")

	print("\n[특수 효과]")
	print("  스프링:      TRANS_ELASTIC + EASE_OUT (탄성)")
	print("  충격파:      TRANS_EXPO + EASE_OUT (폭발적)")
	print("  물결:        TRANS_SINE + EASE_IN_OUT (반복)")
	print("  심장박동:    TRANS_QUAD, 빠른 팽창 + 느린 수축")
	print("  호흡:        TRANS_SINE + EASE_IN_OUT + set_loops()")

	print()

# ============================================
# 6. 이징 비교 데모
# ============================================

func _demonstrate_easing_comparison():
	print("--- 6. 이징 비교 데모 ---\n")

	# 같은 이동을 다른 이징으로 수행
	var test_positions = [
		{"label": "LINEAR", "trans": Tween.TRANS_LINEAR, "ease": Tween.EASE_IN_OUT},
		{"label": "SINE OUT", "trans": Tween.TRANS_SINE, "ease": Tween.EASE_OUT},
		{"label": "QUAD OUT", "trans": Tween.TRANS_QUAD, "ease": Tween.EASE_OUT},
		{"label": "CUBIC OUT", "trans": Tween.TRANS_CUBIC, "ease": Tween.EASE_OUT},
		{"label": "EXPO OUT", "trans": Tween.TRANS_EXPO, "ease": Tween.EASE_OUT},
		{"label": "BACK OUT", "trans": Tween.TRANS_BACK, "ease": Tween.EASE_OUT},
	]

	# 시각적 비교를 위해 Label 생성
	for i in range(test_positions.size()):
		var data = test_positions[i]
		var lbl = Label.new()
		lbl.text = data.label
		lbl.position = Vector2(20, 100 + i * 30)
		lbl.add_theme_font_size_override("font_size", 14)
		add_child(lbl)

		# 마커 (이동하는 점)
		var marker = Label.new()
		marker.text = ">>>"
		marker.position = Vector2(150, 100 + i * 30)
		marker.add_theme_color_override("font_color", Color.CYAN)
		add_child(marker)

		# Tween으로 이동
		var tween = create_tween()
		tween.tween_property(marker, "position:x", 500.0, 2.0) \
			.set_trans(data.trans).set_ease(data.ease)

	print("  6개 이징을 동시에 비교 (2초간 이동)")
	print("  LINEAR / SINE / QUAD / CUBIC / EXPO / BACK")
	print("  -> 속도 차이를 관찰하세요!")

	print()

# ============================================
# 7. 커스텀 커브 (Curve 리소스)
# ============================================

func _show_custom_curves():
	print("--- 7. 커스텀 커브 ---")

	print("[Curve 리소스로 완전한 커스텀 커브]")
	print("""
  # Curve 리소스 생성 (에디터에서 그리기 가능)
  var curve = Curve.new()
  curve.add_point(Vector2(0, 0))    # 시작
  curve.add_point(Vector2(0.3, 1))  # 빠르게 올라감
  curve.add_point(Vector2(0.7, 0.8)) # 살짝 내려감
  curve.add_point(Vector2(1, 1))    # 끝

  # tween_method로 커스텀 커브 적용
  var tween = create_tween()
  tween.tween_method(
      func(t: float):
          var curved_t = curve.sample(t)
          node.position.x = lerp(start_x, end_x, curved_t),
      0.0, 1.0, 1.0
  )
	""")

	print("[코드로 커스텀 이징 함수]")
	print("""
  # 커스텀 이징: 시작에 흔들림이 있는 이동
  func custom_ease(t: float) -> float:
      if t < 0.2:
          # 처음 20%: 작은 흔들림
          return sin(t * 25) * 0.05
      else:
          # 나머지: ease_out_cubic
          var adjusted_t = (t - 0.2) / 0.8
          return 1.0 - pow(1.0 - adjusted_t, 3)

  # 사용:
  tween.tween_method(
      func(t: float):
          node.position = start_pos.lerp(end_pos, custom_ease(t)),
      0.0, 1.0, duration
  )
	""")

	print("[lerp + ease 조합 패턴]")
	print("""
  # 두 값 사이를 이징하며 보간
  func ease_lerp(from: float, to: float, t: float, ease_power: float = 2.0) -> float:
      # t를 이징 처리
      var eased_t = pow(t, ease_power)  # ease_in
      # 또는: 1 - pow(1 - t, ease_power)  # ease_out
      return lerp(from, to, eased_t)
	""")

	print("\n[권장 조합 치트시트]")
	print("  자연스러운 기본: TRANS_QUAD + EASE_OUT")
	print("  부드러운 전환:  TRANS_SINE + EASE_IN_OUT")
	print("  탄력 있는:      TRANS_BACK + EASE_OUT")
	print("  강한 임팩트:    TRANS_EXPO + EASE_OUT")
	print("  통통 튀기:      TRANS_BOUNCE + EASE_OUT")
	print("  고무줄:         TRANS_ELASTIC + EASE_OUT")

	print("\n=== 이징 함수 학습 완료 ===")
