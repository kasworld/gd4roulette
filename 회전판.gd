extends Node3D
class_name 회전판

var 칸_scene = preload("res://칸.tscn")

signal rotation_stopped(n :int)

var id :int
var 반지름 :float
var 깊이 :float
var 칸들 :Array[칸]
var 회전중인가 :bool # need emit

func init(ida :int, 반지름a :float, 깊이a :float, 
		원판색 :Color = Color.DARK_GREEN,
		작은장식색 :Color = Color.GOLD,
		큰장식색 :Color = Color.GOLDENROD,
		화살표색 :Color = Color.WHITE,
		) -> 회전판:
	id = ida
	반지름 = 반지름a
	깊이 = 깊이a
	
	$"원판".mesh.height = 깊이
	$"원판".mesh.bottom_radius = 반지름
	$"원판".mesh.top_radius = 반지름
	$"원판".mesh.radial_segments = 반지름
	$"원판".mesh.material.albedo_color = 원판색
	$"원판".position.y = -깊이
	
	$"원판/작은장식".mesh.height = 깊이
	$"원판/작은장식".mesh.bottom_radius = 반지름*0.04
	$"원판/작은장식".mesh.top_radius = 반지름*0.04
	$"원판/작은장식".mesh.radial_segments = 반지름
	$"원판/작은장식".mesh.material.albedo_color = 작은장식색
	$"원판/작은장식".position.y = 깊이/2

	$"원판/큰장식".mesh.outer_radius = 반지름*0.1
	$"원판/큰장식".mesh.inner_radius = 반지름*0.06
	$"원판/큰장식".mesh.material.albedo_color = 큰장식색
	$"원판/큰장식".position.y = 깊이/2

	$화살표.init(반지름/5, 화살표색, 깊이/2, 깊이*1.5,0.5)
	$화살표.rotation = Vector3(0,PI/2,-PI/2)
	$화살표.position = Vector3(0,깊이,반지름 + 반지름/10)
	return self

func 색바꾸기(
		원판색 :Color = Color.DARK_GREEN,
		작은장식색 :Color = Color.GOLD,
		큰장식색 :Color = Color.GOLDENROD,
		화살표색 :Color = Color.WHITE,
		) -> void:
	$"원판".mesh.material.albedo_color = 원판색
	$"원판/작은장식".mesh.material.albedo_color = 작은장식색
	$"원판/큰장식".mesh.material.albedo_color = 큰장식색
	$"화살표".색바꾸기(화살표색)

var rotation_per_second :float
var decelerate := 0.5 # per second
func 회전판돌리기(dur_sec :float = 1.0) -> void:
	$"원판".rotation.y += rotation_per_second * 2 * PI * dur_sec
	if decelerate > 0:
		rotation_per_second /= pow( 1.0/decelerate , dur_sec)
	if 회전중인가 and abs(rotation_per_second) <= 0.001:
		rotation_stopped.emit(id)
		회전중인가 = false
		rotation_per_second = 0.0

func 회전판강조상태켜기(deg: float) -> void:
	var 선택칸 = 각도로칸선택하기(deg)
	if 선택칸 != null:
		선택칸.강조상태켜기()

# spd : 초당 회전수 
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true

func 멈추기시작(decel :float=0.5) -> void:
	assert(decel < 1.0)
	decelerate = decel

func 칸들지우기() -> void:
	for i in 칸들.size():
		$"원판".remove_child(칸들[i])
	칸들 = []

# 추가로 칸위치정리하기() 호출할것.
func 칸추가하기(co :Color, t :String) -> void:
	var 칸각도 = 360.0/(칸들.size()+1)
	var deg = 칸각도 * 칸들.size()
	var l = 칸_scene.instantiate().init(칸각도, 반지름, 깊이, co , t)
	l.rotation.y = deg_to_rad(-deg)
	l.position.y = 깊이/2
	$"원판".add_child(l)
	칸들.append(l)

func 마지막칸지우기() -> void:
	if 칸들.size() <= 0:
		return
	var n = 칸들.pop_back()
	$"원판".remove_child(n)
	칸위치정리하기()

# 칸들의 각도가 동일하게 조정한다.
func 칸위치정리하기() -> void:
	if 칸들.size() == 0 :
		return
	var 칸각도 = 360.0/칸들.size()
	var pixel_크기 = 반지름 *sin(deg_to_rad(칸각도)) * 0.01
	for i in 칸들.size():
		칸들[i].칸각도바꾸기(칸각도)
		var deg = 칸각도 * i
		칸들[i].rotation.y = deg_to_rad(-deg)
		칸들[i].글씨크기바꾸기(pixel_크기, 48)

func 각도로칸선택하기(선택각도 :float) -> 칸:
	선택각도 += rad_to_deg($"원판".rotation.y)
	if 칸들.size() == 0 :
		return null
	while 선택각도 < 0:
		선택각도 += 360
	while 선택각도 >= 360:
		선택각도 -= 360
	var 칸각도 = 360.0 / 칸들.size()
	for 현재칸번호 in 칸들.size():
		if 칸각도/2 + 현재칸번호*칸각도 > 선택각도:
			return 칸들[현재칸번호]
	return 칸들[0]

func 칸강조하기(i :int)->void:
	칸들[i].강조상태켜기()

func 칸강조끄기(i :int)->void:
	칸들[i].강조상태끄기()

func 칸수얻기() -> int:
	return 칸들.size()

func 칸얻기(i :int) -> 칸:
	return 칸들[i]
