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
	$"중앙기둥".mesh.radius = 반지름*0.1
	$"중앙기둥".mesh.material = mat
	$"중앙기둥".position.y = 깊이*1.5

	$"중심구".mesh.radius = 반지름*0.2
	$"중심구".mesh.height = 반지름*0.4
	$"중심구".mesh.material = mat
	$"중심구".position.y = 깊이*2
	
	$"가로막대기".mesh.height = 반지름*2
	$"가로막대기".mesh.radius = 반지름*0.1
	$"가로막대기".mesh.material = mat
	$"가로막대기".position.y = 깊이*2

	$"세로막대기".mesh.height = 반지름*2
	$"세로막대기".mesh.radius = 반지름*0.1
	$"세로막대기".mesh.material = mat
	$"세로막대기".position.y = 깊이*2

	return self

func 색바꾸기(색 :Color = Color.GOLD) -> void:
	mat.albedo_color = 색
