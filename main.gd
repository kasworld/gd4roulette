extends Node3D

var vp_size :Vector2
var 판반지름 :float

func _ready() -> void:
	vp_size = get_viewport().get_visible_rect().size
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)

	var r = min(vp_size.x,vp_size.y)/2
	$"왼쪽패널".size = Vector2(vp_size.x/2 -r, vp_size.y)
	print($"왼쪽패널".size)
	print($"왼쪽패널/참가자목록".size)
	$오른쪽패널.size = Vector2(vp_size.x/2 -r, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + r, 0)

	판반지름 = min(vp_size.x,vp_size.y)
	var depth = 판반지름/40
	$회전판.init(판반지름, depth)
	$회전판.position = Vector3(0,0,0)

	$DirectionalLight3D.position = Vector3(판반지름,판반지름,-판반지름)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(판반지름,판반지름,-판반지름)

	$Arrow3D.init(판반지름/5,Color.WHITE, depth/2, depth*1.5)
	$Arrow3D.rotation = Vector3(0,PI/2,-PI/2)
	$Arrow3D.position = Vector3(0,depth,판반지름 + 판반지름/10)

	for i in 12:
		참가자추가하기()

	reset_camera_pos()

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(-1,max(vp_size.x,vp_size.y),0)
	$Camera3D.look_at(Vector3.ZERO)

var camera_move = false
func _process(_delta: float) -> void:
	회전판돌리기()
	회전판강조상태켜기()
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*판반지름/2 ,판반지름, cos(t)*판반지름/2  )
		$Camera3D.look_at(Vector3.ZERO)

var rot_acc :float
func 회전판돌리기() -> void:
	$회전판.rotation.y += rot_acc
	rot_acc *= 0.99

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			_on_카메라변경_pressed()
		elif event.keycode == KEY_SPACE:
			_on_돌리기_pressed()
		elif event.keycode == KEY_RIGHT:
			$회전판.rotation.y += PI/180.0
		elif event.keycode == KEY_LEFT:
			$회전판.rotation.y -= PI/180.0
		elif event.keycode == KEY_INSERT:
			참가자추가하기()
		elif event.keycode == KEY_DELETE:
			마지막참가자제거하기()

func 회전판강조상태켜기() -> void:
	var 선택칸 = $"회전판".각도로칸선택하기(rad_to_deg($"회전판".rotation.y)+90)
	if 선택칸 != null:
		선택칸.강조상태켜기()

func 참가자추가하기() -> void:
	var 현재칸수 = $"회전판".칸수얻기()
	var co = NamedColorList.color_list.pick_random()
	var 참가자 = LineEdit.new()
	참가자.text = "참가자%d" % [현재칸수+1]
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND_FILL
	참가자.add_theme_color_override("font_color",co[0])
	참가자.add_theme_color_override("font_outline_color",Color.WHITE)
	참가자.add_theme_constant_override("outline_size",1)
	$"왼쪽패널/참가자목록".add_child(참가자)
	$"회전판".칸추가하기(co[0],참가자.text)
	$"회전판".칸위치정리하기()
	참가자.text_changed.connect(
		func(t :String):
			참가자이름변경됨(현재칸수, t)
	)

func 참가자이름변경됨(i :int, t :String) -> void:
	$"회전판".칸얻기(i).글내용바꾸기(t)

func 마지막참가자제거하기() -> void:
	$"회전판".마지막칸지우기()
	var 현재참가자수 = $"왼쪽패널/참가자목록".get_child_count()
	if 현재참가자수 <= 0:
		return
	var 마지막참가자 = $"왼쪽패널/참가자목록".get_child(현재참가자수-1)
	$"왼쪽패널/참가자목록".remove_child(마지막참가자)

func _on_돌리기_pressed() -> void:
	rot_acc = randfn(0, PI)

func _on_참가자추가_pressed() -> void:
	참가자추가하기()

func _on_참가자제거_pressed() -> void:
	마지막참가자제거하기()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()
