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

func 회전판강조상태켜기() -> void:
	var 선택칸 =  $"회전판".각도로칸선택하기(rad_to_deg($"회전판".rotation.y)+90)
	선택칸.강조상태켜기()
