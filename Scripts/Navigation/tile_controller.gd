class_name TacticTile

extends StaticBody3D


const c_Utils = preload("res://Scripts/Utils.gd")

# tile tint materials https://fffuel.co/cccolor/ 
var hover_mat = c_Utils.create_material("FFFFFF3F")

var reachable_mat = c_Utils.create_material("008fdbBF")
var hover_reachable_mat = c_Utils.create_material("0aa9ffBF")

var attackable_mat = c_Utils.create_material("#9E0000BF")
var attack_target_mat = c_Utils.create_material("d10000BF")
var hover_attackable_mat = c_Utils.create_material("ff4242BF")

# pathfinding attributes
var root
var distance

# tile state
var attack_target : bool = false
var reachable : bool = false
var attackable : bool = false
var hover : bool = false #тайл на котором находиться курсор


# indicators & stuff
var tile_raycasting = load("res://Scenes/Navigation/tile_raycasting.tscn")

func _process(_delta):
	$Tile.visible = attackable or reachable or hover or attack_target #делает тайл видимым, если одна из переменных true
	match hover: #выбираем тип отображения
		true: #если есть hover
			if reachable:
				$Tile.material_override = hover_reachable_mat #делаем тайл вида "досигаемый"
				#print("\nReachable = " + name + "\n")
			elif attackable:
				$Tile.material_override = hover_attackable_mat #Делаем тайл вида "цель атаки"
				#print("\nAttackable = " + name + "\n")
			else:
				$Tile.material_override = hover_mat #Делаем тайл вида "в воздухе/на возвышенности" Предположительно
				#print("\nHover = " + name + "\n")				 
		false:
			if reachable:
				$Tile.material_override = reachable_mat #делаем тайл вида "досигаемый"
				#print("\nReachable = " + name + "\n")
			elif attackable:
				$Tile.material_override = attackable_mat #Делаем тайл вида "цель атаки"
				#print("\nAttackable = " + name + "\n")
			elif attack_target:
				$Tile.material_override = attack_target_mat

func configure_tile(): #функия настройки тайла
	hover = false #отключаем отображение
	add_child(tile_raycasting.instantiate()) #подключение и инициализация рейкаста
	reset()

func reset(): #сбрасывает тайл до дефолтного состояния
	$Tile.visible = false
	root = null
	distance = 0
	reachable = false
	attackable = false
	hover = false

func get_neighbors(height, dist = 0): #получение соседних тайлов
	return $RayCasting.get_all_neighbors(height, dist)


func get_object_above(): #получение объекта выше тайла
	return $RayCasting.get_object_above()


func is_taken(): #возвращает объект над тайлом (предположительно)
	return get_object_above() != null #возвращает объект не равный null
