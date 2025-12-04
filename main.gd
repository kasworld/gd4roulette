extends Node3D

var colorlist :Array = NamedColorList.filter_to_colorlist(NamedColorList.make_dark_color_list())
var cardlist :Array = PlayingCard.make_deck_with_joker()

var WorldSize :Vector3
var vp_size :Vector2
var 짧은길이 :float
var wheel들 :Array
var 자동으로다시돌리기 :bool = true

func ui_panel_init() -> void:
	vp_size = get_viewport().get_visible_rect().size
	짧은길이 = min(vp_size.x, vp_size.y)
	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)

func timed_message_init() -> void:
	vp_size = get_viewport().get_visible_rect().size
	var msgrect := Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect,
		"%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version")
			] )

	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

func message_hidden(_s :String) -> void:
	모두돌리기()

func on_viewport_size_changed():
	ui_panel_init()

func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	timed_message_init()
	ui_panel_init()
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)
	WorldSize = Vector3(vp_size.x, vp_size.y , vp_size.length())

	$DirectionalLight3D.position = Vector3(1,1,짧은길이)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(0,0,-짧은길이)
	$OmniLight3D.omni_range = 짧은길이 *2

	$FixedCameraLight.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*2)
	$MovingCameraLightHober.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*2)
	$MovingCameraLightAround.set_center_pos_far( Vector3.ZERO, Vector3(0, 0, WorldSize.z), WorldSize.length()*2)

	$AxisArrow3D.set_size(1000)

	#var aspect = vp_size.x / vp_size.y
	#var xn = 3
	#var yn = 2
	#for i in xn*yn:
		#var r = min( vp_size.x / xn  , vp_size.y / yn  )
		#var pos = calc_posf_by_i(i, xn,yn)
		#wheel추가(i, r, r/40,
			#calc_posf_spherical(pos, vp_size.length(), PI/4 *aspect, PI/4 ),
			#PI/2)
	var r = max( vp_size.x, vp_size.y)*0.9
	wheel추가(0, r, r/40, Vector3(0,0,0))
	face_to_camera()

# x,y : -0.5 ~ 0.5
func calc_posf_by_i(i :int, xn :int, yn :int) -> Vector2:
	var posi := Vector2i(i % xn, i / xn)
	var x = posi.x / float(xn-1) - 0.5
	var y = posi.y / float(yn-1) - 0.5
	var rtn = Vector2(x,y)
	return rtn

func calc_posf_spherical( src :Vector2, r :float, xvprad :float, yvprad :float) -> Vector3:
	var xrtn = r*sin(src.x *xvprad )
	var yrtn = r*sin(src.y *yvprad)
	var zrtn = -r*cos(src.x *xvprad) *cos(src.y *yvprad) +r
	var rtn = Vector3(xrtn,yrtn,zrtn)
	print(rtn)
	return rtn

func wheel추가(id :int, 반지름 :float, 깊이 :float, pos :Vector3) -> Roulette:
	var cell정보목록 := []
	for i in cardlist.size():
		cell정보목록.append( [ colorlist[i%colorlist.size()] , cardlist[i] ] )
	cell정보목록.shuffle()

	var rp = preload("res://roulette/roulette.tscn").instantiate().init(id, 반지름, 깊이, cell정보목록)
	rp.색설정하기(make_random_color(), make_random_color(), make_random_color() )
	wheel들.append(rp)
	rp.rotation_stopped.connect(결과가결정됨)
	add_child(rp)
	rp.position = pos
	return rp

func make_random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]

func 결과가결정됨(_id :int) -> void:
	var 모두멈추었나 = true
	for n in wheel들:
		if n.회전중인가:
			모두멈추었나 = false

	var 결과들 = ""
	if 모두멈추었나 and 자동으로다시돌리기:
		for n in wheel들:
			결과들 += n.선택된cell얻기().글내용 + " "
		$TimedMessage.show_message( 결과들, 3)

func 모두돌리기() -> void:
	for n in wheel들:
		var rot = randfn(2*PI, PI/2)
		if randi_range(0,1) == 0:
			rot = -rot
		n.돌리기시작.call_deferred(rot)

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(1,0,max(vp_size.x,vp_size.y)*1.5)
	$Camera3D.look_at(Vector3.ZERO)
	$Camera3D.far = vp_size.length()*2

func face_to_camera() -> void:
	for n in wheel들:
		n.look_at($FixedCameraLight.position, Vector3.UP, true)

func _process(delta: float) -> void:
	for rp in wheel들:
		rp.돌리기(delta)
		rp.선택된cell강조상태켜기()

	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_around_y(Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_SPACE:_on_돌리기_pressed,
	KEY_F1:_on_참가자숨기기_pressed,
	KEY_F2:_on_자동돌리기_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_INSERT:_on_button_fov_up_pressed,
	KEY_DELETE:_on_button_fov_down_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()

func _on_돌리기_pressed() -> void:
	모두돌리기()

func _on_참가자숨기기_pressed() -> void:
	$"왼쪽패널".visible = not $"왼쪽패널".visible

func _on_자동돌리기_pressed() -> void:
	자동으로다시돌리기 = not 자동으로다시돌리기
