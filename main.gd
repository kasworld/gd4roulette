extends Node3D

var vp_size :Vector2
var 짧은길이 :float
var 회전판들 :Array
func _ready() -> void:
	vp_size = get_viewport().get_visible_rect().size
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)
	짧은길이 = min(vp_size.x,vp_size.y)

	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	$DirectionalLight3D.position = Vector3(짧은길이,짧은길이,-짧은길이)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(짧은길이,짧은길이,-짧은길이)
	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect, tr("회전판 2.0.0"))
	$TimedMessage.show_message("",0)

	var n = 4
	for i in n:
		var rd = 2*PI/n *i
		var r = 짧은길이*0.8
		회전판추가(i)
		회전판들[i].position = Vector3(sin(rd)*r/1.3, 0, cos(rd)*r*1.3)
	
	reset_camera_pos()

func 회전판추가(id :int) -> 회전판:
	var rp = preload("res://회전판.tscn").instantiate().init(
		id, 짧은길이*0.6, 짧은길이/40,
		NamedColorList.color_list.pick_random()[0],
		NamedColorList.color_list.pick_random()[0],
		NamedColorList.color_list.pick_random()[0],
		NamedColorList.color_list.pick_random()[0],
		)
	회전판들.append(rp)
	for i in 12:
		if id == 0:
			참가자추가하기()
		else :
			var co = NamedColorList.color_list.pick_random()
			rp.칸추가하기(co[0],"%d" % i)
			rp.칸위치정리하기()
	if id == 0:
		rp.rotation_stopped.connect(결과가결정됨)
	add_child(rp)
	return rp
	
func 결과가결정됨(id :int) -> void:
	print("결과" , 회전판들[0].각도로칸선택하기(90))
	$TimedMessage.show_message( "%d %s (이)가 선택되었습니다." % [id, 회전판들[0].각도로칸선택하기(90)] ,3 )

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(-1,max(vp_size.x,vp_size.y),0)
	$Camera3D.look_at(Vector3.ZERO)

var camera_move = false
func _process(delta: float) -> void:
	for rp in 회전판들:
		rp.회전판돌리기(delta)
		rp.회전판강조상태켜기(90)
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*짧은길이/2 ,짧은길이, cos(t)*짧은길이/2  )
		$Camera3D.look_at(Vector3.ZERO)

# esc to exit
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER:
			_on_카메라변경_pressed()
		elif event.keycode == KEY_SPACE:
			_on_돌리기_pressed()
		elif event.keycode == KEY_INSERT:
			참가자추가하기()
		elif event.keycode == KEY_DELETE:
			마지막참가자제거하기()

func 참가자추가하기() -> void:
	var 현재칸수 = 회전판들[0].칸수얻기()
	var co = NamedColorList.color_list.pick_random()
	var 참가자 = LineEdit.new()
	참가자.text = "참가자%d" % [현재칸수+1]
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND_FILL
	참가자.add_theme_color_override("font_color",co[0])
	참가자.add_theme_color_override("font_outline_color",Color.WHITE)
	참가자.add_theme_constant_override("outline_size",1)
	$"왼쪽패널/참가자목록".add_child(참가자)
	회전판들[0].칸추가하기(co[0],참가자.text)
	회전판들[0].칸위치정리하기()
	참가자.text_changed.connect(
		func(t :String):
			참가자이름변경됨(현재칸수, t)
	)

func 참가자이름변경됨(i :int, t :String) -> void:
	회전판들[0].칸얻기(i).글내용바꾸기(t)

func 마지막참가자제거하기() -> void:
	회전판들[0].마지막칸지우기()
	var 현재참가자수 = $"왼쪽패널/참가자목록".get_child_count()
	if 현재참가자수 <= 0:
		return
	var 마지막참가자 = $"왼쪽패널/참가자목록".get_child(현재참가자수-1)
	$"왼쪽패널/참가자목록".remove_child(마지막참가자)

func _on_돌리기_pressed() -> void:
	for rp in 회전판들:
		rp.돌리기시작(randfn(0, 5) )

func _on_참가자추가_pressed() -> void:
	참가자추가하기()

func _on_참가자제거_pressed() -> void:
	마지막참가자제거하기()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()
