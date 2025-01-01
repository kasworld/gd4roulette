extends Node3D
class_name Roulette

func init(r :float, d :float, fsize :float) -> void:
	var plane = Global3d.new_cylinder(d, r,r, Global3d.get_color_mat(Color.GREEN ) )
	plane.position.y = -d
	add_child(plane)

	var n = 36
	for i in n:
		var unit = 360.0/n
		var deg = unit * i
		add_bar(deg, r*0.07, r*0.99, d/10, d)
		deg = unit * i + unit/2
		add_text(deg, r*0.9, r/10, d, "%d" %i)

	var cc = Global3d.new_cylinder(d,r*0.02,r*0.02, Global3d.get_color_mat(Color.BLUE))
	cc.position.y = d/2
	add_child(cc)

	var cc2 = Global3d.new_torus(r*0.05, r*0.03, Global3d.get_color_mat(Color.RED))
	cc2.position.y = d/2
	add_child(cc2)

func add_bar(deg :float, r1 :float, r2 :float, w :float, h:float):
	w = max(1,w)
	h = max(1,h)
	var mat = Global3d.get_color_mat(Color.WHITE)
	var rad = deg_to_rad(-deg+90)
	var bar_len = r2-r1
	var bar_size = Vector3(bar_len,h,w)
	var bar = Global3d.new_box(bar_size, mat)
	bar.rotation.y = deg_to_rad(-deg)
	bar.position = Vector3(sin(rad)*(r1+r2)/2, h/2, cos(rad)*(r1+r2)/2)
	add_child(bar)

func add_text(deg :float, r :float, fsize :float, h:float, s :String):
	var mat = Global3d.get_color_mat(Color.WHITE)
	var rad = deg_to_rad(-deg+90)
	var t = Global3d.new_text(fsize, h, mat, s)
	t.rotation = Vector3(-PI/2,deg_to_rad(-deg),-PI/2)
	t.position = Vector3(sin(rad)*r, h/2, cos(rad)*r)
	add_child(t)
