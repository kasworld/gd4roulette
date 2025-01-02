extends Node3D
class_name Roulette

var 칸_scene = preload("res://칸.tscn")

var 칸들 :Array[칸]

func init(칸수 :int, 반지름 :float, 깊이 :float) -> void:
	배경원판만들기(반지름, 깊이, Color.DARK_GREEN)
	중앙장식만들기(반지름, 깊이, Color.GOLD, Color.GOLDENROD)
	칸들만들기(칸수, 반지름, 깊이)

func 칸들만들기(칸수 :int, 반지름 :float, 깊이 :float) -> void:
	칸들 = []
	for i in 칸수:
		var 칸각도 = 360.0/칸수
		var deg = 칸각도 * i
		var co = NamedColorList.color_list.pick_random()
		var t = "%s" % [co[1]]
		var l = 칸_scene.instantiate().init(칸각도, 반지름, 깊이,co[0] , t)
		l.rotation.y = deg_to_rad(-deg)
		add_child(l)
		칸들.append(l)

func 배경원판만들기(반지름 :float, 깊이 :float, 원판색깔 :Color) -> void:
	var plane = Global3d.new_cylinder(깊이, 반지름, 반지름, Global3d.get_color_mat(원판색깔))
	plane.position.y = -깊이
	add_child(plane)

func 중앙장식만들기(원판반지름 :float, 깊이 :float, 색깔1 :Color, 색깔2 :Color) -> void:
	var cc = Global3d.new_cylinder(깊이, 원판반지름*0.04, 원판반지름*0.04, Global3d.get_color_mat(색깔1))
	cc.position.y = 깊이/2
	add_child(cc)
	var cc2 = Global3d.new_torus(원판반지름*0.1, 원판반지름*0.06, Global3d.get_color_mat(색깔2))
	cc2.position.y = 깊이/2
	add_child(cc2)

func 칸강조하기(i :int)->void:
	칸들[i].강조상태만들기()

func 칸수얻기() -> int:
	return 칸들.size()
