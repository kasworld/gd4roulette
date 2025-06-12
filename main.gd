extends Node3D

var vp_size :Vector2
var 짧은길이 :float
var 회전판들 :Array
var 이름후보목록 :Array
var deck_index :int
func 이름후보얻기() -> String:
	var txt = 이름후보목록[deck_index]
	deck_index +=1
	deck_index %= 이름후보목록.size()
	return txt
var 자동으로다시돌리기 :bool = true

func _ready() -> void:
	vp_size = get_viewport().get_visible_rect().size
	RenderingServer.set_default_clear_color( Global3d.colors.default_clear)
	짧은길이 = min(vp_size.x,vp_size.y)

	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	$DirectionalLight3D.position = Vector3(짧은길이,짧은길이,짧은길이)
	$DirectionalLight3D.look_at(Vector3.ZERO)
	$OmniLight3D.position = Vector3(0,0,vp_size.length()/2)
	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect, tr("회전판 2.0.0"))
	$TimedMessage.show_message("",0)
	이름후보목록 = PlayingCard.make_deck()
	#이름후보목록.shuffle()
	
	var xn = 3
	var yn = 2
	for i in xn*yn:
		var r = min( vp_size.x / xn  , vp_size.y / yn  )
		var adjust = Vector2( 1.0- r/vp_size.x , 1.0- r/vp_size.y   )
		var pos = calc_posf_by_i(i, xn,yn)
		회전판추가( 
			i, r, r/40, 
			Vector3(pos.x*vp_size.x*2*adjust.x, pos.y*vp_size.y*2*adjust.y , 0), 
			PI/2)

	reset_camera_pos()

func calc_posi_by_i(i :int, xn:int) -> Vector2i:
	return Vector2i(i % xn, i / xn)

func calc_posf_by_i(i :int, xn :int, yn :int) -> Vector2:
	var posi := Vector2i(i % xn, i / xn)
	var x = posi.x / float(xn-1) - 0.5
	var y = posi.y / float(yn-1) - 0.5
	return Vector2(x,y)

func 회전판추가(id :int, 반지름 :float, 깊이 :float, pos :Vector3, rot :float) -> 회전판:
	var rp = preload("res://회전판.tscn").instantiate().init(
		id, 반지름, 깊이,
		make_random_color(),
		make_random_color(), randi_range(2,8),
		make_random_color(),
		)
	회전판들.append(rp)
	for i in 이름후보목록.size()/2:# randi_range(4,12):
		if id == 0:
			참가자추가하기()
		else :
			rp.칸추가하기(make_random_color(), 이름후보얻기() )
	rp.칸위치정리하기()
	rp.rotation_stopped.connect(결과가결정됨)
	add_child(rp)
	rp.position = pos
	rp.선택rad바꾸기(rot)
	return rp
	
func make_random_color() -> Color:
	return NamedColorList.color_list.pick_random()[0]
	
func 결과가결정됨(_id :int) -> void:
	var 모두멈추었나 = true
	for n in 회전판들:
		if n.회전중인가:
			모두멈추었나 = false
	
	var 결과들 = ""
	if 모두멈추었나 and 자동으로다시돌리기:
		for n in 회전판들:
			결과들 += n.선택된칸얻기().글내용 + " "
			$TimedMessage.show_message( 결과들, 3)
		모두돌리기()
		
func 모두돌리기() -> void:
	for n in 회전판들:
		var rot = randfn(2*PI, PI/2)
		if randi_range(0,1) == 0:
			rot = -rot
		n.돌리기시작.call_deferred(rot)
	

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(1,0,max(vp_size.x,vp_size.y))
	$Camera3D.look_at(Vector3.ZERO)
	$Camera3D.far = vp_size.length()*2
	#for n in 회전판들:
		#n.look_at($Camera3D.position, Vector3.UP, true)

var camera_move = false
func _process(delta: float) -> void:
	for rp in 회전판들:
		rp.회전판돌리기(delta)
		rp.선택된칸강조상태켜기()
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*짧은길이, cos(t)*짧은길이, 짧은길이)
		$Camera3D.look_at(Vector3.ZERO)

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_SPACE:_on_돌리기_pressed,
	KEY_INSERT:_on_참가자추가_pressed,
	KEY_DELETE:_on_참가자제거_pressed,
	KEY_F1:_on_참가자숨기기_pressed,
	KEY_F2:_on_자동돌리기_pressed,
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

func 참가자추가하기() -> void:
	var txt = 이름후보얻기()
	var 현재칸수 = 회전판들[0].칸수얻기()
	var co = make_random_color()
	var 참가자 = LineEdit.new()
	참가자.text = txt
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND_FILL
	참가자.add_theme_color_override("font_color",co)
	참가자.add_theme_color_override("font_outline_color",Color.WHITE)
	참가자.add_theme_constant_override("outline_size",1)
	$"왼쪽패널/참가자목록".add_child(참가자)
	회전판들[0].칸추가하기(co,참가자.text)
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
	모두돌리기()

func _on_참가자추가_pressed() -> void:
	참가자추가하기()
	회전판들[0].칸위치정리하기()

func _on_참가자제거_pressed() -> void:
	마지막참가자제거하기()
	회전판들[0].칸위치정리하기()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func _on_참가자숨기기_pressed() -> void:
	$"왼쪽패널".visible = not $"왼쪽패널".visible

func _on_자동돌리기_pressed() -> void:
	자동으로다시돌리기 = not 자동으로다시돌리기
