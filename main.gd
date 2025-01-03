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
	$회전판.init(1, 판반지름, depth)
	$회전판.position = Vector3(0,0,0)

	$DirectionalLight3D.position = Vector3(판반지름,판반지름,-판반지름)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(판반지름,판반지름,-판반지름)

	$Arrow3D.init(판반지름/5,Color.WHITE, depth/2, depth*1.5)
	$Arrow3D.rotation = Vector3(0,PI/2,-PI/2)
	$Arrow3D.position = Vector3(0,depth,판반지름 + 판반지름/10)
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
			camera_move = !camera_move
			if camera_move == false:
				reset_camera_pos()
		elif event.keycode == KEY_SPACE:
			rot_acc = randfn(0, PI)
		elif event.keycode == KEY_RIGHT:
			$회전판.rotation.y += PI/180.0
		elif event.keycode == KEY_LEFT:
			$회전판.rotation.y -= PI/180.0
		elif event.keycode == KEY_INSERT:
			참가자추가하기()
		elif event.keycode == KEY_DELETE:
			$"회전판".마지막칸지우기()

func 회전판강조상태켜기() -> void:
	var 선택칸 =  $"회전판".각도로칸선택하기(rad_to_deg($"회전판".rotation.y)+90)
	선택칸.강조상태켜기()

func 참가자추가하기() -> void:
	var 현재칸수 = $"회전판".칸수얻기()
	var 참가자 = TextEdit.new()
	참가자.text = "참가자%d" % [현재칸수+1]
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND_FILL
	참가자.scroll_fit_content_height = true
	참가자.custom_minimum_size.y = 50
	$"왼쪽패널/참가자목록".add_child(참가자)
	#$"왼쪽패널/참가자목록".custom_minimum_size.y = (현재칸수+1) * 50
	var co = NamedColorList.color_list.pick_random()
	$"회전판".칸추가하기(co[0],co[1])
	$"회전판".칸위치정리하기()
