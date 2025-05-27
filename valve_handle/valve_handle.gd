extends Node3D
class_name ValveHandle

var 반지름 :float
var 깊이 :float

func init(반지름a :float, 깊이a :float, 
		작은장식색 :Color = Color.GOLD,
		큰장식색 :Color = Color.GOLDENROD,
		십자장식색 :Color = Color.GOLDENROD,
		) -> ValveHandle:
	반지름 = 반지름a
	깊이 = 깊이a
	
	$"작은장식".mesh.height = 깊이*2
	$"작은장식".mesh.radius = 반지름*0.1
	$"작은장식".mesh.material.albedo_color = 작은장식색
	$"작은장식".position.y = 깊이*1.5

	$"큰장식".mesh.outer_radius = 반지름*1
	$"큰장식".mesh.inner_radius = 반지름*0.8
	$"큰장식".mesh.material.albedo_color = 큰장식색
	$"큰장식".position.y = 깊이*2
	
	$"가로장식".mesh.height = 반지름*2
	$"가로장식".mesh.radius = 반지름*0.1
	$"가로장식".mesh.material.albedo_color = 십자장식색
	$"가로장식".position.y = 깊이*2

	$"세로장식".mesh.height = 반지름*2
	$"세로장식".mesh.radius = 반지름*0.1
	$"세로장식".mesh.material.albedo_color = 십자장식색
	$"세로장식".position.y = 깊이*2

	return self

func 색바꾸기(
		작은장식색 :Color = Color.GOLD,
		큰장식색 :Color = Color.GOLDENROD,
		십자장식색 :Color = Color.GOLDENROD,
		) -> void:
	$"작은장식".mesh.material.albedo_color = 작은장식색
	$"큰장식".mesh.material.albedo_color = 큰장식색
	$"가로장식".mesh.material.albedo_color = 십자장식색
	$"세로장식".mesh.material.albedo_color = 십자장식색
