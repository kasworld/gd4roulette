extends Node3D

var vp_size :Vector2
var 짧은길이 :float
var 회전판들 :Array
var playing_card_deck :Array
var deck_index :int
var 자동으로다시돌리기 :bool = true
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

	playing_card_deck = PlayingCard.make_deck_with_joker()
	var n = 4
	for i in n:
		var rd = 2*PI/n *i
		var r = 짧은길이*0.8
		회전판추가(i)
		회전판들[i].position = Vector3(sin(rd)*r/1.3, 0, cos(rd)*r*1.3)
		회전판들[i].rotation.y = rd +PI/2 
	reset_camera_pos()

func 회전판추가(id :int) -> 회전판:
	var rp = preload("res://회전판.tscn").instantiate().init(
		id, 짧은길이*0.6, 짧은길이/40,
		NamedColorList.color_list.pick_random()[0],
		NamedColorList.color_list.pick_random()[0],
		randi_range(2,8),
		NamedColorList.color_list.pick_random()[0],
		)
	회전판들.append(rp)
	var text_list = PlayingCard.make_deck_with_joker()
	text_list.shuffle()
	for i in randi_range(4,text_list.size()):
		if id == 0:
			참가자추가하기()
		else :
			var co = NamedColorList.color_list.pick_random()
			rp.칸추가하기(co[0], text_list[i] )
	rp.칸위치정리하기()
	rp.rotation_stopped.connect(결과가결정됨)
	add_child(rp)
	return rp
	
func 결과가결정됨(id :int) -> void:
	if id == 0:
		$TimedMessage.show_message( "회전판%d 에서 %s (이)가 선택되었습니다." % [id, 회전판들[id].선택된칸얻기().글내용] ,3 )
	if 자동으로다시돌리기:
		회전판들[id].돌리기시작.call_deferred(randfn(0, 5) )

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(-1,max(vp_size.x,vp_size.y),0)
	$Camera3D.look_at(Vector3.ZERO)

var camera_move = false
func _process(delta: float) -> void:
	for rp in 회전판들:
		rp.회전판돌리기(delta)
		rp.선택된칸강조상태켜기()
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*짧은길이/2 ,짧은길이, cos(t)*짧은길이/2  )
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
	var txt = playing_card_deck[deck_index]
	deck_index +=1
	deck_index %= playing_card_deck.size()
	var 현재칸수 = 회전판들[0].칸수얻기()
	var co = NamedColorList.color_list.pick_random()
	var 참가자 = LineEdit.new()
	참가자.text = txt
	참가자.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	참가자.size_flags_vertical = Control.SIZE_EXPAND_FILL
	참가자.add_theme_color_override("font_color",co[0])
	참가자.add_theme_color_override("font_outline_color",Color.WHITE)
	참가자.add_theme_constant_override("outline_size",1)
	$"왼쪽패널/참가자목록".add_child(참가자)
	회전판들[0].칸추가하기(co[0],참가자.text)
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
