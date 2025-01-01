extends Node3D

class_name 칸

const 선시작비 = 0.5
const 선끝비 = 1.0

var 칸각도 :float # degree
var 글내용 :String

func init(각도 :float, 반지름 :float, 깊이 :float, 색깔 :Color, 글 :String) -> 칸:
	글내용 = 글
	칸각도 = 각도
	선만들기(반지름,깊이,색깔)
	글씨만들기(반지름,깊이,색깔,글)
	return self

func 선만들기(반지름 :float, 깊이 :float, 색깔 :Color)->void:
	var 선폭 = max(1,깊이 /10)
	깊이 = max(1,깊이)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(반지름*(선끝비 - 선시작비), 깊이, 선폭)
	mesh.material = Global3d.get_color_mat(색깔)
	$"시작선".mesh = mesh
	$"시작선".rotation.y = deg_to_rad(칸각도/2)
	var rad = deg_to_rad(칸각도/2 + 90)
	$"시작선".position = Vector3(sin(rad)*반지름*(선끝비 + 선시작비)/2, 깊이/2, cos(rad)*반지름*(선끝비 + 선시작비)/2)

func 글씨만들기(반지름 :float, 깊이 :float, 색깔 :Color, 글 :String) -> void:
	var mesh = TextMesh.new()
	mesh.font = Global3d.font
	mesh.depth = 깊이
	mesh.pixel_size = 반지름 * 0.001
	mesh.font_size = 반지름 * 0.07
	mesh.text = 글
	mesh.material = Global3d.get_color_mat(색깔)
	$"글씨".mesh = mesh
	$"글씨".rotation = Vector3(-PI/2,PI/2,-PI/2)
	var 위치 = 반지름*(50.0 - 글.length())/55.0
	$"글씨".position = Vector3(위치, 깊이/2, 0)
