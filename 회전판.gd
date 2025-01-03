extends Node3D
class_name Roulette

var 칸_scene = preload("res://칸.tscn")

var 반지름 :float
var 깊이 :float
var 칸들 :Array[칸]

func init(반지름a :float, 깊이a :float) -> void:
	반지름 = 반지름a
	깊이 = 깊이a
	배경원판만들기(Color.DARK_GREEN)
	중앙장식만들기(Color.GOLD, Color.GOLDENROD)
	#칸들만들기(칸수)

#func 칸들만들기(칸수 :int) -> void:
	#칸들 = []
	#for i in 칸수:
		#var co = NamedColorList.color_list.pick_random()
		#칸추가하기(co[0],co[1])
	#칸위치정리하기()

func 칸들지우기() -> void:
	for i in 칸들.size():
		remove_child(칸들[i])
	칸들 = []

# 추가로 칸위치정리하기() 호출할것.
func 칸추가하기(co :Color, t :String) -> void:
	var 칸각도 = 360.0/(칸들.size()+1)
	var deg = 칸각도 * 칸들.size()
	var l = 칸_scene.instantiate().init(칸각도, 반지름, 깊이, co , t)
	l.rotation.y = deg_to_rad(-deg)
	add_child(l)
	칸들.append(l)

func 마지막칸지우기() -> void:
	if 칸들.size() <= 0:
		return
	var n = 칸들.pop_back()
	remove_child(n)
	칸위치정리하기()

# 칸들의 각도가 동일하게 조정한다.
func 칸위치정리하기() -> void:
	if 칸들.size() == 0 :
		return
	var 칸각도 = 360.0/칸들.size()
	for i in 칸들.size():
		칸들[i].칸각도바꾸기(칸각도)
		var deg = 칸각도 * i
		칸들[i].rotation.y = deg_to_rad(-deg)

func 배경원판만들기(원판색깔 :Color) -> void:
	var plane = Global3d.new_cylinder(깊이, 반지름, 반지름, Global3d.get_color_mat(원판색깔))
	plane.position.y = -깊이
	add_child(plane)

func 중앙장식만들기(색깔1 :Color, 색깔2 :Color) -> void:
	var 원판반지름 = 반지름
	var cc = Global3d.new_cylinder(깊이, 원판반지름*0.04, 원판반지름*0.04, Global3d.get_color_mat(색깔1))
	cc.position.y = 깊이/2
	add_child(cc)
	var cc2 = Global3d.new_torus(원판반지름*0.1, 원판반지름*0.06, Global3d.get_color_mat(색깔2))
	cc2.position.y = 깊이/2
	add_child(cc2)

func 각도로칸선택하기(선택각도 :float) -> 칸:
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
