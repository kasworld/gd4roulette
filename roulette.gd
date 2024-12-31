extends Node3D
class_name Roulette

func init(r :float, d :float, fsize :float) -> void:
	var plane = Global3d.new_cylinder(d, r,r, Global3d.get_color_mat(Color.GREEN ) )
	plane.position.y = -d
	add_child(plane)
	add_bar(0, r*0.1, r*0.9, d, d)

	var cc = Global3d.new_cylinder(d*0.5,r/50,r/50, Global3d.get_color_mat(Color.BLUE))
	cc.position.y = d*0.5/2
	add_child(cc)
	var cc2 = Global3d.new_torus(r/20, r/40, Global3d.get_color_mat(Color.RED))
	cc2.position.y = d*0.5/2
	add_child( cc2 )

func add_bar(deg :float, r1 :float, r2 :float, w :float, h:float):
	var mat = Global3d.get_color_mat(Color.WHITE)
	var rad = deg_to_rad(-deg+90)
	var bar_len = r2-r1
	var bar_center = Vector3(sin(rad)*(r1+r2)/2, h/2, cos(rad)*(r1+r2)/2)
	var bar_size = Vector3(bar_len,h,w)
	var bar = Global3d.new_box(bar_size, mat)
	var bar_rot = deg_to_rad(-deg)
	bar.rotation.y = bar_rot
	bar.position = bar_center
	add_child(bar)
