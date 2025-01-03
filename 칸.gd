extends Node3D

class_name 칸

const 선시작비 = 0.5
const 선끝비 = 1.0

var 칸각도 :float # degree
var 반지름 :float
var 깊이 :float
var 색깔 :Color
var 글내용 :String
var 강조중 :bool

func init(각도 :float, 반지름a :float, 깊이a :float, 색깔a :Color, 글 :String) -> 칸:
	칸각도 = 각도
	반지름 = 반지름a
	깊이 = 깊이a
	색깔 = 색깔a
	글내용 = 글
	선만들기()
	글씨만들기()
	return self

func 선만들기()->void:
	var 선폭 = max(1,깊이 /10)
	깊이 = max(1,깊이)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(반지름*(선끝비 - 선시작비), 깊이, 선폭)
	mesh.material = Global3d.get_color_mat(색깔)
	$"시작선".mesh = mesh
	$"시작선".rotation.y = deg_to_rad(칸각도/2)
	var rad = deg_to_rad(칸각도/2 + 90)
	$"시작선".position = Vector3(sin(rad)*반지름*(선끝비 + 선시작비)/2, 깊이/2, cos(rad)*반지름*(선끝비 + 선시작비)/2)

func 글씨만들기() -> void:
	var mesh = TextMesh.new()
	mesh.font = Global3d.font
	mesh.depth = 깊이
	mesh.pixel_size = 반지름 * 0.001
	mesh.font_size = 반지름 * 0.07
	mesh.text = 글내용
	mesh.material = Global3d.get_color_mat(색깔)
	mesh.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
	$"글씨".mesh = mesh
	$"글씨".rotation = Vector3(-PI/2,PI/2,-PI/2)
	$"글씨".position = Vector3(반지름, 깊이/2, 0)

func 칸각도바꾸기(새각도 :float) -> void:
	칸각도 = 새각도
	$"시작선".rotation.y = deg_to_rad(칸각도/2)
	var rad = deg_to_rad(칸각도/2 + 90)
	$"시작선".position = Vector3(sin(rad)*반지름*(선끝비 + 선시작비)/2, 깊이/2, cos(rad)*반지름*(선끝비 + 선시작비)/2)

func 글내용바꾸기(새글내용 :String) -> void:
	글내용 = 새글내용
	$"글씨".mesh.text = 글내용

func 색깔바꾸기(새색깔 :Color) -> void:
	색깔 = 새색깔
	$"시작선".mesh.material = Global3d.get_color_mat(색깔)
	$"글씨".mesh.material = Global3d.get_color_mat(색깔)

func 강조상태켜기() -> void:
	강조중 = true
	$AnimationPlayer.play("글씨강조")

func 강조상태끄기() -> void:
	강조중 = false
	$AnimationPlayer.play("글씨강조끄기")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "글씨강조":
		강조상태끄기.call_deferred()
