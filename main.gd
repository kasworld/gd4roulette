extends Node3D


var vp_size :Vector2
var 판반지름 :float

func _ready() -> void:
	vp_size = get_viewport().get_visible_rect().size
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)

	vp_size = get_viewport().get_visible_rect().size
	판반지름 = min(vp_size.x,vp_size.y)
	var depth = 판반지름/40
	$회전판.init(36, 판반지름, depth)
	$회전판.position = Vector3(0,0,0)

	$DirectionalLight3D.position = Vector3(판반지름,판반지름,-판반지름)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(판반지름,판반지름,-판반지름)

	$Arrow3D.init(판반지름/5,Color.WHITE, depth/2, depth*1.5)
	$Arrow3D.rotation = Vector3(0,PI/2,-PI/2)
	$Arrow3D.position = Vector3(0,0,판반지름*1.05)
	reset_camera_pos()


func reset_camera_pos()->void:
	$Camera3D.position = Vector3(-1,max(vp_size.x,vp_size.y),0)
	$Camera3D.look_at(Vector3.ZERO)

var camera_move = false
func _process(_delta: float) -> void:
	rot_by_accel()
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*판반지름/2 ,판반지름, cos(t)*판반지름/2  )
		$Camera3D.look_at(Vector3.ZERO)

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
			$Timer.start(0.5)

var oldvt = Vector2(0,-100)
func rot_by_accel()->void:
	var vt = Input.get_accelerometer()
	if  vt != Vector3.ZERO :
		oldvt = (Vector2(vt.x,vt.y) + oldvt).normalized() *100
		var rad = oldvt.angle_to(Vector2(0,-1))
		rotate_all(rad)
	else :
		vt = Input.get_last_mouse_velocity()/100
		if vt == Vector2.ZERO :
			vt = Vector2(0,-5)
		oldvt = (Vector2(vt.x,vt.y) + oldvt).normalized() *100
		var rad = oldvt.angle_to(Vector2(0,-1))
		rotate_all(rad)

func rotate_all(rad :float):
	$회전판.rotation.y = -rad

var 강조번호 :int
func 칸선택강조효과() -> void:
	if 강조번호 > 0:
		$"회전판".칸강조끄기(강조번호-1)
	if 강조번호 < $"회전판".칸수얻기():
		$"회전판".칸강조하기(강조번호)
	강조번호 +=1
	if 강조번호 > $"회전판".칸수얻기():
		강조번호 = 0
		$Timer.stop()

func _on_timer_timeout() -> void:
	칸선택강조효과()
