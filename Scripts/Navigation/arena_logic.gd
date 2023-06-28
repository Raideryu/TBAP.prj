class_name ArenaController

extends Node3D

const c_Utils = preload("res://Scripts/Utils.gd")

var controller : LevelController = null

func _ready():
	$Tiles.visible = true #делает видимым тайлы (активными)
	await c_Utils.convert_tiles_into_static_bodies($Tiles) #конвертирует тайлы в статик боди
	controller = get_parent()
	pass

func link_tiles(root, height, allies_arr=null): #Задает связь тайл для следующих вычисленний
	var pq = [root] #Передаем root внутри массива как единственный элемент (это у нас тайл под персонажем)
	while !pq.is_empty(): #производим цикл перебора, пока массив не пустой
		var curr_tile : TacticTile = pq.pop_front() #pop_front() удаляет первый элемент массива и возвращает его
		#в пересоздаваемую переменную типа TacticTile помещаем тайл из полученого массива и удаляем его в массиве
		for neighbor in curr_tile.get_neighbors(height, curr_tile.distance): #для каждого соседа (тайла) проходим по циклу
			if !neighbor.root and neighbor != root: #Проверяем, что тайл не имеет рута и не является нашем рутом
				if !(neighbor.is_taken() and allies_arr and !neighbor.get_object_above() in allies_arr):
					if abs(curr_tile.get_position().y-neighbor.get_position().y) <= height - curr_tile.distance:
				#если не(проверяемый сосед не взят(персонаж над ним) и у преверяемого объекта нет объекта над ним
				#и есть союзные юниты (переменная не пуста))
					#if curr_tile.distance and 
						neighbor.root = curr_tile #устанавливаем корнем проверяемого тайла текущий тайл
						neighbor.distance = curr_tile.distance+1 if abs(curr_tile.get_position().y-neighbor.get_position().y) < 0.7 else curr_tile.distance + abs(curr_tile.get_position().y-neighbor.get_position().y)
						pq.push_back(neighbor) #добавляем тайл в конец массива
	pass

func mark_hover_tile(tile : TacticTile): #показывать тайлы на которых курсор мыши
	for t in $Tiles.get_children(): t.hover = false #выключаем у всех hover
	if tile: tile.hover = true #включаем hover у нужного тайла

func mark_reachable_tiles(root : TacticTile, distance): #показывать доступные тайлы
	for t in $Tiles.get_children(): #перебор всех тайлов
		t.reachable = t.distance > 0 and t.distance <= distance and !t.is_taken() or t == root
		#^включаем отображения тайла как доступного если:
		#тайл находится на растоянии от 0 до необходимой дистанции
		#тайл не считается взятым (наверное)
		#или тайл является тем, откуда идет расчет

func mark_attackable_tiles(root : TacticTile, distance, allies : Array): #показывает зону атаки персонажа
#^принимает корневой тайл (под персонажем) и дистанцию (дальность)
	for t in $Tiles.get_children(): #прогонка каждого тайла на арене
		if !t.is_taken():
			t.attackable = t.distance > 0 and t.distance <= distance or t == root
		else:
			t.attack_target = t.distance > 0 and t.distance <= distance or t != root
		#^устанавливаем true если дистанция тайла больше 0 и меньше или равна полученной дистанции
		#+ или данный тайл и есть корневой

func generate_path_stack(to): #генерируем путь до нужной цели
	var path_stack = [] #стек путей (массив)
	while to: #
		#to.hover = true
		path_stack.push_front(to.global_transform.origin) #добавляем позицию след тайла
		to = to.root
	
	print(path_stack)
	return path_stack
	
func reset(): #сбрасываем все тайлы до дефолта
	for t in $Tiles.get_children(): t.reset() 
