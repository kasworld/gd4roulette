extends Node3D
class_name 회전판

var 칸_scene = preload("res://칸.tscn")
var bartree_scene = preload("res://bar_tree_2/bar_tree_2.tscn")

signal rotation_stopped(n :int)

var 선택각도 :float = 0.0 # degree
var id :int
var 반지름 :float
var 깊이 :float
var 칸들 :Array[칸]
var 회전중인가 :bool # need emit

func init(ida :int, 반지름a :float, 깊이a :float, 
		원판색 :Color = Color.DARK_GREEN,
		장식색 :Color = Color.GOLD,
		장식팔개수 :int = 4,
		화살표색 :Color = Color.WHITE,
		) -> 회전판:
	id = ida
	반지름 = 반지름a
	깊이 = 깊이a
	
	$"원판".mesh.height = 깊이
	$"원판".mesh.bottom_radius = 반지름
	$"원판".mesh.top_radius = 반지름
	$"원판".mesh.material.albedo_color = 원판색
	$"원판".position.y = -깊이
	
	$"원판/ValveHandle".init(반지름*0.1, 반지름*0.1, 장식팔개수, 장식색)
	var rot = 0 #2*PI
	if randi_range(0,1) == 0:
		rot = - rot

	$"원판/BarTree2".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, rot, deg_to_rad(선택각도), 1.0, false 
		).init_with_color(장식색, 원판색)
	$"원판/BarTree2".position.y = 깊이/2
	$"원판/BarTree3".init_common_params(반지름*0.5, 깊이, 반지름*0.05, 256, rot, deg_to_rad(선택각도+180), 1.0, false 
		).init_with_color(장식색.inverted(), 원판색.inverted())
	$"원판/BarTree3".position.y = 깊이/2
	
	$화살표.init(반지름/5, 화살표색, 깊이/2, 깊이*1.5,0.5)
	선택각도바꾸기(선택각도)
	return self

func 선택각도바꾸기(deg :float) -> void:
	선택각도 = deg
	var rad = deg_to_rad(선택각도)
	$화살표.rotation = Vector3(PI/2, PI+rad, 0)
	$화살표.position = Vector3(sin(rad) *반지름*1.1, 깊이, cos(rad) *반지름*1.1 )

func 색바꾸기(원판색 :Color, 장식색 :Color, 화살표색 :Color) -> void:
	$"원판".mesh.material.albedo_color = 원판색
	$"원판/ValveHandle".색바꾸기(장식색)
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
	$"원판/BarTree2".bar_rotation = -rotation_per_second/10
	$"원판/BarTree3".bar_rotation = -rotation_per_second/10

func 선택된칸강조상태켜기() -> void:
	var 선택칸 = 선택된칸얻기()
	if 선택칸 != null:
		선택칸.강조상태켜기()

# spd : 초당 회전수 
func 돌리기시작(spd :float) -> void:
	rotation_per_second = spd
	회전중인가 = true
	$"원판/BarTree2".auto_rotate_bar = true
	$"원판/BarTree2".bar_rotation = -spd/10
	$"원판/BarTree3".auto_rotate_bar = true
	$"원판/BarTree2".bar_rotation = -spd/10
	$"원판/BarTree3".bar_rotation = -spd/10

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

# 칸들의 각도가 동일하게 조정한다.
func 칸위치정리하기() -> void:
	if 칸들.size() == 0 :
		return
	var 칸각도 = 360.0/칸들.size()
	var pixel_크기 = 반지름 *sin(deg_to_rad(칸각도)) * 0.01
	if 칸들.size() <= 2:
		pixel_크기 = 반지름 * 0.01
	for i in 칸들.size():
		칸들[i].칸각도바꾸기(칸각도)
		var deg = 칸각도 * i
		칸들[i].rotation.y = deg_to_rad(-deg)
		칸들[i].글씨크기바꾸기(pixel_크기, 48)
	$"원판".mesh.radial_segments = 칸들.size()
	$"원판/BarTree2".set_visible_bar_count(칸들.size())
	$"원판/BarTree3".set_visible_bar_count(칸들.size())

func 선택된칸얻기() -> 칸:
	var 각도 = rad_to_deg($"원판".rotation.y) - 선택각도
	if 칸들.size() == 0 :
		return null
	while 각도 < 0:
		각도 += 360
	while 각도 >= 360:
		각도 -= 360
	var 칸각도 = 360.0 / 칸들.size()
	for 현재칸번호 in 칸들.size():
		if 칸각도/2 + 현재칸번호*칸각도 > 각도:
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
