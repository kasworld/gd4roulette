extends Node3D

class_name Arrow3D

func init(l :float, co :Color, bodyw :float, headw :float) -> Arrow3D:
	# body
	var bodyMesh = CylinderMesh.new()
	bodyMesh.height = l *0.7
	bodyMesh.bottom_radius = bodyw
	bodyMesh.top_radius = bodyw
	bodyMesh.radial_segments = clampi( int(bodyw*2) , 64, 360)
	bodyMesh.material = Global3d.get_color_mat(co)
	$Body.mesh = bodyMesh
	$Body.position = Vector3(0,-l*0.7/2,0)

	# head
	var headMesh = CylinderMesh.new()
	headMesh.height = l *0.3
	headMesh.bottom_radius = headw
	headMesh.top_radius = 0
	headMesh.radial_segments = clampi( int(headw*2) , 64, 360)
	headMesh.material = Global3d.get_color_mat(co)
	$Head.mesh = headMesh
	$Head.position = Vector3(0,l*0.3/2,0)

	return self
