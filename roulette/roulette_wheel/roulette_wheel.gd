extends Node3D
class_name RouletteWheel

var 반지름 :float
var 깊이 :float
var cell_list :Array[RouletteCell]
var cell각도 :float
func init(r :float, d: float, cell정보목록 :Array =[]) -> RouletteWheel:
	반지름 = r
	깊이 = d
	$"칸통".rotation.x = PI/2
	var count := cell정보목록.size()
	cell각도 = 2*PI / count
	for i in count:
		var k :RouletteCell = preload("res://roulette/roulette_cell/roulette_cell.tscn").instantiate().init(cell각도, 반지름, 깊이,cell정보목록[i][0], cell정보목록[i][1])
		k.position.z = 깊이/2
		k.rotation.y = cell각도 *i
		$"칸통".add_child(k)
		cell_list.append(k)
	return self

func cell들지우기() -> void:
	for i in cell_list.size():
		$"칸통".remove_child(cell_list[i])
	cell_list = []

func cell강조하기(i :int)->void:
	cell_list[i].강조상태켜기()

func cell강조끄기(i :int)->void:
	cell_list[i].강조상태끄기()

func cell_count얻기() -> int:
	return cell_list.size()

func cell얻기(i :int) -> RouletteCell:
	return cell_list[i]

func 각도로cell얻기(rad :float) -> RouletteCell:
	var 현재각도 = fposmod(-rad, 2*PI)
	return cell얻기( ceili( (현재각도-cell각도/2) / cell각도 ) % cell_list.size() )

func cell중심각도(n :int) -> float:
	return cell각도 * n

#func cell중심근처인가() -> bool:
	#var 현재각도 = fposmod(-rotation.x, 2*PI)
	#var 중심각도 = cell중심각도(선택된cell번호())
	#return abs(현재각도 - 중심각도) <= cell각도/100
