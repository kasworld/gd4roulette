extends PanelContainer

signal panel_hidden(s :String)

func init(fsize :int, rt :Rect2, ver :String)->void:
	position = rt.position
	size = rt.size
	$VBoxContainer/VersionLabel.text = ver
	theme.default_font_size = fsize

func show_message(msg :String, sec :float = 3)->void:
	$VBoxContainer/Label.text = msg
	visible = true
	$Timer.start(sec)

func _on_timer_timeout() -> void:
	visible = false
	panel_hidden.emit($VBoxContainer/Label.text)
