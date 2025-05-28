extends Node3D
class_name ValveHandle

var 반지름 :float
var 깊이 :float
var mat : StandardMaterial3D
func init(반지름a :float, 깊이a :float, 색 :Color = Color.GOLD) -> ValveHandle:
	반지름 = 반지름a
	깊이 = 깊이a
	
	mat = StandardMaterial3D.new()
	mat.albedo_color = 색
	
	$"중앙기둥".mesh.height = 깊이*2
	$"중앙기둥".mesh.bottom_radius = 반지름*0.1
	$"중앙기둥".mesh.top_radius = 반지름*0.1
	$"중앙기둥".mesh.material = mat
	$"중앙기둥".position.y = 깊이

	var sp = new_ball()
	add_child(sp)
	sp.position = Vector3(0, 깊이*2 , 0)

	var n := 2
	var rd = PI/n
	for i in n:
		var mesh = CylinderMesh.new()
		mesh.height = 반지름*2
		mesh.bottom_radius = 반지름*0.1
		mesh.top_radius = 반지름*0.1
		mesh.material = mat
		sp = MeshInstance3D.new()
		sp.mesh = mesh
		sp.position = Vector3(0,깊이*2,0)
		sp.rotate_x(PI/2)
		sp.rotate_y(rd*i)
		add_child(sp)
		
	n = n*2
	rd = 2*PI/n
	for i in n:
		sp = new_ball()
		add_child(sp)
		sp.position = Vector3(sin(rd*i)*반지름, 깊이*2 , cos(rd*i)*반지름)
		
	return self

func new_ball() -> MeshInstance3D:
	var mesh = SphereMesh.new()
	mesh.radius = 반지름*0.2
	mesh.height = 반지름*0.4
	mesh.material = mat
	var sp = MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func 색바꾸기(색 :Color = Color.GOLD) -> void:
	mat.albedo_color = 색
