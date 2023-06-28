extends Node3D

func get_all_neighbors(height, dist = 0): #Функция получения всех соседних тайлов
	var objects = [] #создаем переменную, массив
	for ray in $Neighbors.get_children(): #прогоняем через все лучи в ноде Neighbors
		var obj = ray.get_collider()
		if obj and abs(obj.get_position().y-get_parent().get_position().y) <= height - dist:
		#^проверяем соприкосновение луча и колайда
			objects.append(obj) #Подходящий объект добавляем в массив
	return objects

	
func get_object_above():
	return $Above.get_collider() #возвращает первый объект, сопрекоснувшийся с лучом Above

