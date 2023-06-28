const c_Tile_SRC = "res://Scripts/Navigation/tile_controller.gd"

enum Scenes_List {
	Main_Menu,
	Test_Level,
}

enum UNIT_FRACTIONS {
	UUSP, #United Union of Sovet Peoples
	EC, #European Coalition
	UEC, #United East Corps
	AMD, #America of Military Dictatorship
	TNNG, #The New Nazi Germany
}

enum UNIT_TYPES {
	Commander, #лидер
	Elite, #Элита
	Big, #биг
	Specialist, #специалист
	Pawn, #пешка
}

enum EQUIPMENT_TYPES {
	MAG, #Mechanized Armored Gear
	TAG, #Tactical Armored Gear
	MAS, #Mechanized Armored Suit
	TAS, #Tactical Armored Suit
	MIG, #Mechanized Infantry Gear
	TIG, #Tactical Infantry Gear
	MIS, #Mechanized Infantry Suit
	TIS, #Tactical Infantry Suit
}

enum MOVEMENT_TYPES {
	Radius,
	Cross,
	Diagonal_Cross,
	G_shaped,
	Mixed,
}

enum TILE_TYPES {
	Ground,
	Ladder,
	Under_Cover,
}

enum WEAPON_TYPES {
	Range_Weapon,
	Melee_Weapon,
}

enum WEAPON_NAMES {
	Short_SKS_55,
	Butt_Of_Weapon,
	Fists,
	None,
}

enum WEAPON_ATTACK_TYPES {
	Point,
	Radius,
}

enum RANGE_WEAPONS {
	Short_SKS_55,
}

enum MELEE_WEAPONS {
	Butt_Of_Weapon,
	Fists,
}

static func convert_tiles_into_static_bodies(tiles_obj): 
	#Учитывая узел 3DNode в качестве параметра (tiles_obj), эта функция выполнит итерацию по каждому
	#из своих дочерних элементов, преобразуя их в статическое тело и присоединяя tile.gd сценарий.
	#например, эта функция преобразует "Плитки" в следующую структуру:
	#	> Tiles:                                > Tiles:
	#		> Tile1                                 > StaticBody3D (tile.gd):
	#		> Tile2                                     > Tile1
	#		...                                         > CollisionShape3D
	#		> TileN       -- TRANSFORM INTO ->      > StaticBody2 (tile.gd):
	#													> Tile2
	#													> CollisionShape3D
	#												...
	#												> StaticBodyN (tile.gd):
	#													> TileN
	#													> CollisionShape3D

	for t in tiles_obj.get_children(): #перебор тайлов в родительском тайловом ноде
		t.create_trimesh_collision() #Внутренний метод класса MeshInstane
		#^Этот помощник создает дочерний узел статического тела с вогнутой многоугольной формой collisionshape,
		#вычисленной на основе геометрии сетки. В основном он используется для тестирования.
		var static_body : StaticBody3D = t.get_child(0) #Получаем ранее созданный статик и вносим в переменную
		static_body.set_position(t.get_position()) #Выставляем позицию статику исходя из позиции меша
		t.set_position(Vector3.ZERO) #обнуляем позициию по вектору3
		t.set_name("Tile") #Назначаем имя ноду
		t.remove_child(static_body) #удаляем у тайла статик
		tiles_obj.remove_child(t) #удаляем из родительского нода тайлов данный тайл
		static_body.add_child(t) #добавляем данный тайл как дочерний нод к статику
		static_body.set_script(load(c_Tile_SRC)) #ставим скрипт управления тайла на статик (общая функия)
		static_body.configure_tile() #кастом. функция настройки тайла (подключает tile_raycasting.tscn)
		static_body.set_collision_layer_value(1, true)
		static_body.set_collision_mask_value(1, true)
		static_body.set_process(true) #объявляет данный нод активным в обработке в реальном в времени
		#(тип помещает нод во внутренний метод _process)
		tiles_obj.add_child(static_body) #возвращает данный нод в дочерку общего тайлового нода

static func create_material(color, texture=null, shaded_mode=0): #Функция создания материала (цвета) для нода
	var material = StandardMaterial3D.new() #создаем новый материал
	material.flags_transparent = true #Включаем прозрачность
	material.albedo_color = Color(color) #задаем вет материалу
	material.albedo_texture = texture #Даем текстуру (по дефолту она нулевая - не существует)
	material.shading_mode = shaded_mode #выставляем мод шейда
	return material #возвращаем материал

static func vector_remove_y(vector):
	return vector*Vector3(1,0,1)

static func vector_distance_without_y(b, a): #убираем Y
	return vector_remove_y(b).distance_to(vector_remove_y(a))
