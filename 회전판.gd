extends Node3D
class_name Roulette

class 한칸:
	var 시작선 :MeshInstance3D
	var 글씨 :MeshInstance3D
	var 시작각도 :float # degree
	func _init(d :float, l :MeshInstance3D, t:MeshInstance3D) -> void:
		시작각도 = d
		시작선 = l
		글씨 = t

var 칸들 :Array[한칸]

func init(칸수 :int, 반지름 :float, 깊이 :float) -> void:
	배경원판만들기(반지름, 깊이, Color.DARK_GREEN)
	중앙장식만들기(반지름, 깊이, Color.GOLD, Color.GOLDENROD)
	칸들만들기(칸수, 반지름, 깊이, Color.WHITE)

func 칸들만들기(칸수 :int, 반지름 :float, 깊이 :float, 선색깔 :Color) -> void:
	칸들 = []
	for i in 칸수:
		var unit = 360.0/칸수
		var deg = unit * i
		var l = 칸나누는선만들기(deg, 반지름*0.5, 반지름, 깊이/10, 깊이, 선색깔)
		var 글씨색깔 = Color.RED
		if i % 2 == 0:
			글씨색깔 = Color.BLUE
		var t = 칸글씨만들기(deg+ unit/2, 반지름*0.9, 반지름/10, 깊이, 글씨색깔, "%d" % [ i * 25 % 칸수 ] )
		칸들.append(한칸.new(deg,l,t))

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

func 칸나누는선만들기(deg :float, 시작거리 :float, 끝거리 :float, 폭 :float, 높이:float, 선색깔 :Color) -> MeshInstance3D:
	폭 = max(1,폭)
	높이 = max(1,높이)
	var mat = Global3d.get_color_mat(선색깔)
	var rad = deg_to_rad(-deg+90)
	var bar_len = 끝거리-시작거리
	var bar_size = Vector3(bar_len, 높이,폭)
	var bar = Global3d.new_box(bar_size, mat)
	bar.rotation.y = deg_to_rad(-deg)
	bar.position = Vector3(sin(rad)*(시작거리+끝거리)/2, 높이/2, cos(rad)*(시작거리+끝거리)/2)
	add_child(bar)
	return bar

func 칸글씨만들기(deg :float, 중심부터거리 :float, 글씨크기 :float, 높이:float, 글씨색깔 :Color, 글내용 :String) -> MeshInstance3D:
	var mat = Global3d.get_color_mat(글씨색깔)
	var rad = deg_to_rad(-deg+90)
	var t = Global3d.new_text(글씨크기, 높이, mat, 글내용)
	t.rotation = Vector3(-PI/2,deg_to_rad(-deg),-PI/2)
	t.position = Vector3(sin(rad)*중심부터거리, 높이/2, cos(rad)*중심부터거리)
	add_child(t)
	return t
