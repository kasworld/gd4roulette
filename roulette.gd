extends Node3D
class_name Roulette

func init(r :float, d :float, fsize :float) -> void:
	var plane = Global3d.new_cylinder(d, r,r, Global3d.get_color_mat(Color.DARK_GREEN ) )
	plane.position.y = -d
	add_child(plane)

	var n = 36
	for i in n:
		var unit = 360.0/n
		var deg = unit * i
		add_bar(deg, r*0.5, r, d/10, d)
		var co = Color.RED
		if i % 2 == 0:
			co = Color.BLUE
		add_text(deg+ unit/2, r*0.9, r/10, d, co, "%d" % [ i * 25 % n ] )

	var cc = Global3d.new_cylinder(d,r*0.04,r*0.04, Global3d.get_color_mat(Color.GOLD))
	cc.position.y = d/2
	add_child(cc)

	var cc2 = Global3d.new_torus(r*0.1, r*0.06, Global3d.get_color_mat(Color.DARK_GOLDENROD))
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

func add_text(deg :float, r :float, fsize :float, h:float,co :Color, s :String):
	var mat = Global3d.get_color_mat(co)
	var rad = deg_to_rad(-deg+90)
	var t = Global3d.new_text(fsize, h, mat, s)
	t.rotation = Vector3(-PI/2,deg_to_rad(-deg),-PI/2)
	t.position = Vector3(sin(rad)*r, h/2, cos(rad)*r)
	add_child(t)
