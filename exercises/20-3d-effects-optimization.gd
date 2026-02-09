# 챕터 20: 3D 이펙트와 최적화
#
# 이 챕터에서는 다음을 학습합니다:
# - GPUParticles3D 설정과 파티클 속성
# - 다양한 파티클 프리셋 (불, 연기, 폭발 등)
# - Decal 시스템으로 표면에 텍스처 투사
# - LOD(Level of Detail) 구성
# - Occlusion Culling으로 보이지 않는 오브젝트 제거
# - 성능 측정과 최적화 기법

extends Node3D


# ============================================================
# 연습 1: GPUParticles3D 설정
# ============================================================
# GPUParticles3D는 GPU에서 대량의 파티클을 처리합니다.
# ParticleProcessMaterial로 파티클의 행동을 정의합니다.

func create_gpu_particles_config(
	amount: int,
	lifetime: float,
	one_shot: bool
) -> Dictionary:
	# TODO: GPUParticles3D의 기본 설정을 Dictionary로 반환하세요
	# amount: 파티클 수 (최소 1, 최대 10000으로 클램프)
	# lifetime: 파티클 수명 (초, 최소 0.01)
	# one_shot: 한 번만 방출 여부
	#
	# 반환 형식:
	# {
	#   "node_type": "GPUParticles3D",
	#   "amount": 클램프된 값,
	#   "lifetime": max(lifetime, 0.01),
	#   "one_shot": one_shot,
	#   "preprocess": 0.0,
	#   "explosiveness": one_shot이면 1.0, 아니면 0.0,
	#   "randomness": 0.0,
	#   "fixed_fps": 0 (0이면 제한 없음),
	#   "fract_delta": true,
	#   "visibility_aabb": {"position": Vector3(-4, -4, -4), "size": Vector3(8, 8, 8)},
	#   "local_coords": false,
	#   "draw_order": "index",
	#   "transform_align": "disabled",
	#   "trail_enabled": false,
	#   "trail_lifetime": 0.3,
	#   "process_material_properties": {
	#     "direction": Vector3(0, 1, 0),
	#     "spread": 45.0,
	#     "initial_velocity_min": 1.0,
	#     "initial_velocity_max": 3.0,
	#     "gravity": Vector3(0, -9.8, 0),
	#     "damping_min": 0.0,
	#     "damping_max": 0.0,
	#     "scale_min": 1.0,
	#     "scale_max": 1.0,
	#     "color": Color(1, 1, 1, 1)
	#   }
	# }
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 2: 파티클 프리셋
# ============================================================
# 게임에서 자주 사용하는 파티클 효과의 설정 값을 미리 정의합니다.

func create_particle_preset(preset: String) -> Dictionary:
	# TODO: 파티클 프리셋 설정을 Dictionary로 반환하세요
	# preset: "fire", "smoke", "explosion", "sparkle", "rain", "snow"
	#
	# 반환 형식:
	# {
	#   "preset": preset,
	#   "description": 프리셋 설명,
	#   "amount": 파티클 수,
	#   "lifetime": 수명,
	#   "one_shot": 한 번만 방출 여부,
	#   "material": {
	#     "direction": 방출 방향 Vector3,
	#     "spread": 퍼짐 각도,
	#     "initial_velocity_min": 최소 초기 속도,
	#     "initial_velocity_max": 최대 초기 속도,
	#     "gravity": 중력 Vector3,
	#     "scale_min": 최소 크기,
	#     "scale_max": 최대 크기,
	#     "color_ramp": [시작 색상, 끝 색상],
	#     "emission_shape": 방출 형태
	#   }
	# }
	#
	# "fire":
	#   description: "불꽃 파티클 - 위로 솟는 화염"
	#   amount: 200, lifetime: 1.0, one_shot: false
	#   direction: (0, 1, 0), spread: 15.0
	#   velocity: 2.0~4.0, gravity: (0, 0, 0)
	#   scale: 0.5~1.5
	#   color_ramp: [Color(1, 0.8, 0, 1), Color(1, 0, 0, 0)]
	#   emission_shape: "sphere" (radius 0.5)
	#
	# "smoke":
	#   description: "연기 파티클 - 천천히 퍼지는 연기"
	#   amount: 100, lifetime: 3.0, one_shot: false
	#   direction: (0, 1, 0), spread: 25.0
	#   velocity: 0.5~1.5, gravity: (0, 0.5, 0) (위로 떠오름)
	#   scale: 1.0~3.0
	#   color_ramp: [Color(0.3, 0.3, 0.3, 0.6), Color(0.5, 0.5, 0.5, 0)]
	#   emission_shape: "sphere" (radius 0.3)
	#
	# "explosion":
	#   description: "폭발 파티클 - 한 번에 사방으로 퍼짐"
	#   amount: 500, lifetime: 0.8, one_shot: true
	#   direction: (0, 1, 0), spread: 180.0 (전 방향)
	#   velocity: 5.0~15.0, gravity: (0, -5.0, 0)
	#   scale: 0.5~2.0
	#   color_ramp: [Color(1, 1, 0.5, 1), Color(1, 0.2, 0, 0)]
	#   emission_shape: "sphere" (radius 0.1)
	#
	# "sparkle":
	#   description: "반짝임 파티클 - 아이템/마법 효과"
	#   amount: 50, lifetime: 1.5, one_shot: false
	#   direction: (0, 1, 0), spread: 180.0
	#   velocity: 0.5~2.0, gravity: (0, -1.0, 0)
	#   scale: 0.1~0.3
	#   color_ramp: [Color(1, 1, 0.8, 1), Color(0.5, 0.8, 1, 0)]
	#   emission_shape: "box" (size 1.0)
	#
	# "rain":
	#   description: "빗방울 파티클 - 위에서 떨어지는 비"
	#   amount: 1000, lifetime: 1.0, one_shot: false
	#   direction: (0, -1, 0), spread: 5.0
	#   velocity: 10.0~15.0, gravity: (0, -9.8, 0)
	#   scale: 0.05~0.1
	#   color_ramp: [Color(0.7, 0.8, 0.9, 0.6), Color(0.7, 0.8, 0.9, 0.2)]
	#   emission_shape: "box" (size 20.0)
	#
	# "snow":
	#   description: "눈송이 파티클 - 천천히 내리는 눈"
	#   amount: 500, lifetime: 5.0, one_shot: false
	#   direction: (0, -1, 0), spread: 30.0
	#   velocity: 0.5~1.5, gravity: (0, -1.0, 0)
	#   scale: 0.1~0.3
	#   color_ramp: [Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.3)]
	#   emission_shape: "box" (size 20.0)
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 3: Decal 설정
# ============================================================
# Decal은 기존 표면 위에 텍스처를 투사(projection)합니다.
# 총알 자국, 혈흔, 균열, 물웅덩이 등에 사용됩니다.

func create_decal_config(decal_type: String, size: float) -> Dictionary:
	# TODO: Decal 유형별 설정을 Dictionary로 반환하세요
	# decal_type: "bullet_hole", "blood", "crack", "scorch", "footprint"
	# size: 데칼 크기 (최소 0.1)
	#
	# size를 최소 0.1로 클램프하세요
	#
	# 반환 형식:
	# {
	#   "node_type": "Decal",
	#   "decal_type": decal_type,
	#   "size": Vector3(size, size * 2, size),
	#   "texture_albedo": 텍스처 경로 문자열,
	#   "texture_normal": 노멀맵 경로 (있으면),
	#   "modulate": 데칼 색상 변조,
	#   "emission_energy": 발광 에너지,
	#   "albedo_mix": 알베도 혼합 정도 (0~1),
	#   "normal_fade": 법선 페이드 각도,
	#   "upper_fade": 위쪽 페이드,
	#   "lower_fade": 아래쪽 페이드,
	#   "cull_mask": 적용 대상 레이어,
	#   "lifetime": 데칼 수명 (-1이면 영구),
	#   "description": 설명
	# }
	#
	# "bullet_hole":
	#   texture_albedo: "res://textures/decals/bullet_hole.png"
	#   texture_normal: "res://textures/decals/bullet_hole_normal.png"
	#   modulate: Color(0.3, 0.3, 0.3, 0.9)
	#   emission_energy: 0.0, albedo_mix: 1.0, normal_fade: 0.5
	#   upper_fade: 0.3, lower_fade: 0.3, cull_mask: 1
	#   lifetime: 30.0
	#   description: "총알 자국 - 벽이나 바닥에 표시"
	#
	# "blood":
	#   texture_albedo: "res://textures/decals/blood_splatter.png"
	#   texture_normal: null
	#   modulate: Color(0.5, 0.0, 0.0, 0.8)
	#   emission_energy: 0.0, albedo_mix: 0.9, normal_fade: 0.5
	#   upper_fade: 0.5, lower_fade: 0.1, cull_mask: 1
	#   lifetime: 60.0
	#   description: "혈흔 - 전투 효과"
	#
	# "crack":
	#   texture_albedo: "res://textures/decals/crack.png"
	#   texture_normal: "res://textures/decals/crack_normal.png"
	#   modulate: Color(0.4, 0.4, 0.4, 1.0)
	#   emission_energy: 0.0, albedo_mix: 0.8, normal_fade: 0.3
	#   upper_fade: 0.2, lower_fade: 0.2, cull_mask: 1
	#   lifetime: -1.0 (영구)
	#   description: "균열 - 폭발이나 충격 흔적"
	#
	# "scorch":
	#   texture_albedo: "res://textures/decals/scorch_mark.png"
	#   texture_normal: null
	#   modulate: Color(0.1, 0.1, 0.1, 0.7)
	#   emission_energy: 0.2, albedo_mix: 0.9, normal_fade: 0.5
	#   upper_fade: 0.4, lower_fade: 0.4, cull_mask: 1
	#   lifetime: 45.0
	#   description: "그을음 자국 - 화염 효과 흔적"
	#
	# "footprint":
	#   texture_albedo: "res://textures/decals/footprint.png"
	#   texture_normal: "res://textures/decals/footprint_normal.png"
	#   modulate: Color(0.6, 0.5, 0.4, 0.5)
	#   emission_energy: 0.0, albedo_mix: 0.6, normal_fade: 0.7
	#   upper_fade: 0.5, lower_fade: 0.1, cull_mask: 1
	#   lifetime: 10.0
	#   description: "발자국 - 눈이나 진흙 위의 흔적"
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 4: LOD(Level of Detail) 구성
# ============================================================
# LOD는 카메라와의 거리에 따라 메시의 세밀도를 조절합니다.
# 먼 오브젝트는 저폴리곤으로 렌더링하여 성능을 최적화합니다.

func create_lod_config(
	base_mesh_polygons: int,
	lod_levels: int
) -> Dictionary:
	# TODO: LOD 설정을 Dictionary로 반환하세요
	# base_mesh_polygons: 원본 메시의 폴리곤 수
	# lod_levels: LOD 레벨 수 (2~4로 클램프)
	#
	# 각 LOD 레벨의 폴리곤 수:
	# LOD 0: 100% (원본)
	# LOD 1: 50%
	# LOD 2: 25%
	# LOD 3: 10%
	#
	# 각 LOD 레벨의 전환 거리:
	# LOD 0 -> 1: 20m
	# LOD 1 -> 2: 50m
	# LOD 2 -> 3: 100m
	#
	# 반환 형식:
	# {
	#   "base_polygons": base_mesh_polygons,
	#   "lod_count": lod_levels,
	#   "levels": [
	#     {
	#       "level": 0,
	#       "polygon_count": base_mesh_polygons,
	#       "polygon_percent": 100,
	#       "distance_min": 0.0,
	#       "distance_max": 20.0,
	#       "description": "최고 품질 (원본 메시)"
	#     },
	#     {
	#       "level": 1,
	#       "polygon_count": base_mesh_polygons * 0.5 (정수),
	#       "polygon_percent": 50,
	#       "distance_min": 20.0,
	#       "distance_max": 50.0,
	#       "description": "중간 품질"
	#     },
	#     ... (lod_levels만큼)
	#   ],
	#   "total_memory_savings": 예상 메모리 절약 비율 문자열,
	#   "lod_bias": 0.0 (LOD 편향, 양수면 일찍 전환),
	#   "fade_mode": "disabled" ("disabled", "alpha", "dither"),
	#   "code_example": "# Godot 4에서는 메시 임포트 시 자동 LOD 생성\n# mesh_instance.lod_bias = 0.0"
	# }
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 5: Occlusion Culling 설정
# ============================================================
# Occlusion Culling은 다른 오브젝트에 의해 가려진 오브젝트를
# 렌더링에서 제외하여 성능을 향상시킵니다.

func create_occlusion_config(scene_type: String) -> Dictionary:
	# TODO: 씬 유형별 Occlusion Culling 설정을 반환하세요
	# scene_type: "indoor", "outdoor", "mixed"
	#
	# 반환 형식:
	# {
	#   "scene_type": scene_type,
	#   "occlusion_enabled": true,
	#   "occluder_nodes": 오클루더로 사용할 노드 유형 목록,
	#   "settings": {
	#     "bake_quality": ...,
	#     "bake_use_degenerate_triangles": ...,
	#     "occlusion_rays_per_thread": ...
	#   },
	#   "best_practices": 모범 사례 배열,
	#   "expected_improvement": 예상 성능 향상 문자열,
	#   "setup_steps": 설정 단계 배열
	# }
	#
	# "indoor" (실내 - 벽과 문으로 많은 오클루전 가능):
	#   occluder_nodes: ["OccluderInstance3D", "CSGShape3D (use_collision)"]
	#   bake_quality: "high"
	#   bake_use_degenerate_triangles: false
	#   occlusion_rays_per_thread: 512
	#   best_practices: [
	#     "벽, 바닥, 천장에 OccluderInstance3D 배치",
	#     "문이 열리면 오클루더 비활성화",
	#     "큰 가구에도 간단한 오클루더 추가",
	#     "방마다 별도의 오클루더 그룹 사용"
	#   ]
	#   expected_improvement: "40-60% 드로우콜 감소"
	#   setup_steps: [
	#     "1. 벽/바닥 메시에 OccluderInstance3D 자식 추가",
	#     "2. QuadOccluder3D 또는 BoxOccluder3D 리소스 할당",
	#     "3. 프로젝트 설정에서 Occlusion Culling 활성화",
	#     "4. 디버그 > Occlusion Culling 시각화로 확인"
	#   ]
	#
	# "outdoor" (야외 - 지형과 큰 건물):
	#   occluder_nodes: ["OccluderInstance3D"]
	#   bake_quality: "medium"
	#   bake_use_degenerate_triangles: true
	#   occlusion_rays_per_thread: 256
	#   best_practices: [
	#     "큰 건물에 간단한 박스 오클루더 사용",
	#     "지형 높이에 따른 오클루전 활용",
	#     "먼 거리는 LOD와 함께 사용",
	#     "식물 등 반투명 오브젝트에는 오클루더 사용하지 않음"
	#   ]
	#   expected_improvement: "20-35% 드로우콜 감소"
	#   setup_steps: [
	#     "1. 큰 건물에 BoxOccluder3D 배치",
	#     "2. 지형에 PolygonOccluder3D 사용 고려",
	#     "3. 프로젝트 설정에서 Occlusion Culling 활성화",
	#     "4. LOD와 함께 사용하여 최대 효과"
	#   ]
	#
	# "mixed" (실내+야외 혼합):
	#   occluder_nodes: ["OccluderInstance3D", "CSGShape3D (use_collision)"]
	#   bake_quality: "high"
	#   bake_use_degenerate_triangles: false
	#   occlusion_rays_per_thread: 384
	#   best_practices: [
	#     "건물 내부/외부 별도 오클루더 그룹",
	#     "건물 전체를 하나의 큰 오클루더로 사용",
	#     "실내에서는 벽 오클루전, 야외에서는 건물 오클루전",
	#     "포탈(문/창문)을 통한 가시성 관리"
	#   ]
	#   expected_improvement: "30-50% 드로우콜 감소"
	#   setup_steps: [
	#     "1. 건물 외벽에 큰 박스 오클루더 배치",
	#     "2. 건물 내부에 세분화된 오클루더 추가",
	#     "3. 문/창문에 동적 오클루더 연결",
	#     "4. 프로젝트 설정에서 Occlusion Culling 활성화",
	#     "5. 실내/야외 전환 시 오클루더 그룹 전환"
	#   ]
	var config = {}  # 여기를 수정하세요
	return config


# ============================================================
# 연습 6: 성능 측정과 최적화
# ============================================================
# 게임 성능을 측정하고 병목을 찾아 최적화합니다.
# FPS, 드로우콜, 메모리 등의 지표를 모니터링합니다.

var frame_times: Array = []
const MAX_FRAME_SAMPLES: int = 60

func record_frame_time(delta: float) -> void:
	# TODO: 프레임 시간을 기록하세요
	# frame_times 배열에 delta를 추가
	# MAX_FRAME_SAMPLES를 초과하면 가장 오래된 항목 제거 (앞에서)
	pass  # 여기를 수정하세요

func get_performance_report() -> Dictionary:
	# TODO: 현재 성능 지표를 Dictionary로 반환하세요
	#
	# frame_times 배열이 비어있으면 기본값 반환
	#
	# 계산:
	# - average_fps: 1.0 / 평균 프레임 시간
	# - min_fps: 1.0 / 최대 프레임 시간 (가장 느린 프레임)
	# - max_fps: 1.0 / 최소 프레임 시간 (가장 빠른 프레임)
	# - frame_time_avg: 평균 프레임 시간 (ms)
	# - frame_time_max: 최대 프레임 시간 (ms) -- 가장 느린
	# - frame_time_min: 최소 프레임 시간 (ms) -- 가장 빠른
	# - jitter: (max_frame_time - min_frame_time) * 1000.0 (ms)
	# - stability: 프레임 시간의 표준편차가 작을수록 안정적
	#   (간소화: 1.0 - (jitter / frame_time_avg_ms) 범위 [0, 1] 클램프)
	#
	# 반환 형식:
	# {
	#   "sample_count": frame_times 크기,
	#   "average_fps": ...,
	#   "min_fps": ...,
	#   "max_fps": ...,
	#   "frame_time_avg_ms": ...,
	#   "frame_time_max_ms": ...,
	#   "frame_time_min_ms": ...,
	#   "jitter_ms": ...,
	#   "stability": ...,
	#   "performance_rating": 등급 문자열,
	#   "optimization_suggestions": 제안 배열
	# }
	#
	# performance_rating:
	# average_fps >= 60: "excellent" (훌륭)
	# average_fps >= 30: "good" (양호)
	# average_fps >= 20: "poor" (부족)
	# average_fps < 20: "critical" (심각)
	#
	# optimization_suggestions (해당 조건에 맞는 것만):
	# fps < 60: "LOD 시스템 활용을 검토하세요"
	# fps < 30: "오클루전 컬링을 활성화하세요"
	# fps < 30: "파티클 수를 줄이세요"
	# jitter > 5ms: "프레임 시간 변동이 큽니다. GC 또는 로딩 스파이크를 확인하세요"
	# stability < 0.5: "프레임 안정성이 낮습니다. 물리 연산을 최적화하세요"
	var report = {}  # 여기를 수정하세요
	return report

func get_optimization_checklist() -> Dictionary:
	# TODO: 3D 게임 최적화 체크리스트를 반환하세요
	#
	# 반환 형식:
	# {
	#   "rendering": [
	#     "LOD 시스템 적용",
	#     "Occlusion Culling 활성화",
	#     "그림자 해상도 최적화",
	#     "MSAA 대신 FXAA/TAA 사용 고려",
	#     "불필요한 실시간 조명 제거"
	#   ],
	#   "physics": [
	#     "간단한 충돌 도형 사용 (메시 충돌 피하기)",
	#     "물리 레이어로 불필요한 충돌 검사 제거",
	#     "RayCast 수 최소화",
	#     "물리 업데이트 빈도 조절"
	#   ],
	#   "scripting": [
	#     "_process 대신 Timer 노드 사용 고려",
	#     "화면 밖 오브젝트 비활성화",
	#     "오브젝트 풀 패턴 사용",
	#     "불필요한 노드 탐색 줄이기 (캐시 활용)"
	#   ],
	#   "memory": [
	#     "텍스처 크기 최적화 (POT 크기 사용)",
	#     "미사용 리소스 해제",
	#     "씬 인스턴스 재사용",
	#     "오디오 스트리밍 활용 (큰 파일)"
	#   ],
	#   "profiling_tools": [
	#     "Godot 내장 프로파일러",
	#     "디버그 > 모니터",
	#     "Performance 싱글톤",
	#     "RenderingServer 통계"
	#   ]
	# }
	var checklist = {}  # 여기를 수정하세요
	return checklist


# ============================================================
# 테스트 케이스
# ============================================================

func _ready():
	print("=== 챕터 20: 3D 이펙트와 최적화 ===")
	print("")

	# 테스트 1: GPUParticles3D
	print("--- 연습 1: GPUParticles3D ---")
	var particles_cont = create_gpu_particles_config(100, 2.0, false)
	var particles_shot = create_gpu_particles_config(500, 0.5, true)
	print("결과 1-1 (지속 방출):", particles_cont)
	if particles_cont.has("explosiveness"):
		print("  폭발성:", particles_cont["explosiveness"], " (기대값: 0.0)")
	print("결과 1-2 (일회성 방출):", particles_shot)
	if particles_shot.has("explosiveness"):
		print("  폭발성:", particles_shot["explosiveness"], " (기대값: 1.0)")
	print("")

	# 테스트 2: 파티클 프리셋
	print("--- 연습 2: 파티클 프리셋 ---")
	var p_fire = create_particle_preset("fire")
	var p_explosion = create_particle_preset("explosion")
	var p_snow = create_particle_preset("snow")
	print("결과 2-1 (불꽃):", p_fire)
	if p_fire.has("one_shot"):
		print("  일회성:", p_fire["one_shot"], " (기대값: false)")
	print("결과 2-2 (폭발):", p_explosion)
	if p_explosion.has("one_shot"):
		print("  일회성:", p_explosion["one_shot"], " (기대값: true)")
	print("결과 2-3 (눈):", p_snow)
	print("")

	# 테스트 3: Decal
	print("--- 연습 3: Decal ---")
	var decal_bullet = create_decal_config("bullet_hole", 0.2)
	var decal_crack = create_decal_config("crack", 1.5)
	var decal_foot = create_decal_config("footprint", 0.3)
	print("결과 3-1 (총알 자국):", decal_bullet)
	if decal_bullet.has("lifetime"):
		print("  수명:", decal_bullet["lifetime"], " (기대값: 30)")
	print("결과 3-2 (균열):", decal_crack)
	if decal_crack.has("lifetime"):
		print("  수명:", decal_crack["lifetime"], " (기대값: -1, 영구)")
	print("결과 3-3 (발자국):", decal_foot)
	print("")

	# 테스트 4: LOD
	print("--- 연습 4: LOD ---")
	var lod_high = create_lod_config(10000, 4)
	var lod_low = create_lod_config(1000, 2)
	print("결과 4-1 (고폴리곤 LOD):", lod_high)
	if lod_high.has("levels"):
		print("  LOD 레벨 수:", lod_high["levels"].size(), " (기대값: 4)")
		if lod_high["levels"].size() > 1:
			print("  LOD1 폴리곤:", lod_high["levels"][1].get("polygon_count", 0), " (기대값: 5000)")
	print("결과 4-2 (저폴리곤 LOD):", lod_low)
	print("")

	# 테스트 5: Occlusion
	print("--- 연습 5: Occlusion Culling ---")
	var occ_indoor = create_occlusion_config("indoor")
	var occ_outdoor = create_occlusion_config("outdoor")
	var occ_mixed = create_occlusion_config("mixed")
	print("결과 5-1 (실내):", occ_indoor)
	if occ_indoor.has("expected_improvement"):
		print("  예상 개선:", occ_indoor["expected_improvement"])
	print("결과 5-2 (야외):", occ_outdoor)
	print("결과 5-3 (혼합):", occ_mixed)
	print("")

	# 테스트 6: 성능 측정
	print("--- 연습 6: 성능 측정 ---")
	frame_times = []
	# 60fps 시뮬레이션
	for i in range(50):
		record_frame_time(0.016 + randf() * 0.002)
	# 느린 프레임 추가
	record_frame_time(0.05)
	record_frame_time(0.04)

	var perf = get_performance_report()
	print("결과 6-1 (성능 리포트):", perf)
	if perf.has("average_fps"):
		print("  평균 FPS:", perf["average_fps"])
	if perf.has("performance_rating"):
		print("  등급:", perf["performance_rating"])
	if perf.has("optimization_suggestions"):
		print("  제안:", perf["optimization_suggestions"])

	var opt = get_optimization_checklist()
	print("결과 6-2 (최적화 체크리스트 카테고리):", opt.keys())
	if opt.has("rendering"):
		print("  렌더링 항목 수:", opt["rendering"].size())
	if opt.has("profiling_tools"):
		print("  프로파일링 도구:", opt["profiling_tools"])
	print("")

	print("=== 챕터 20 완료 ===")
