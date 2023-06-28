class_name PlayerController

extends Node3D

@export var is_gamepad : bool = false

@export var player_id := 1 :
	set(id):
		player_id = id
		
		$MultiplayerSynchronizer.set_multiplayer_authority(id)
		#$PlayerInput.set_multiplayer_authority(id)
		set_multiplayer_authority(id)
		
#@onready var input = $PlayerInput
@onready var ui_control : PlayerUI = $PlayerUI

var level_controller : LevelController = null

var arena : ArenaController = null
var camera : TacticCamera = null


var current_unit : UnitController = null
var target_unit : UnitController = null

var activations_count : int = 1

var can_do_turn : bool = true

var units : Array = []

var wait_time = 0

var stage = 0

func _ready():
	level_controller = get_parent().get_parent()
	$MultiplayerSynchronizer.set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	#w$PlayerInput.set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	#if player_id == multiplayer.get_unique_id(): $TacticCamera/Pivot/Camera3D.current = true
	#level_controller.player = self
	pass

func configure(my_arena : ArenaController):
#^настройка контроллера игрока
#принимает: Нод арены, камеры, UI
	arena = my_arena
	camera = $TacticCamera
	#units = $Units.get_children()
	#camera.target = units.front() #передаем камере первого юнита как цель
	ui_control.configure(self)
	activations_count = 1
	print("activations: " + str(activations_count) + "\tcan_do_turn: " + str(can_do_turn))
	if player_id == multiplayer.get_unique_id(): $TacticCamera/Pivot/Camera3D.current = true
	#for unit in units:
		#unit.holder_id = player_id
#
func move_camera(): #перемещение камеры
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backward")
	camera.move_camera(h, v, is_gamepad)
##
func camera_rotation(): #поворот камеры
	if Input.is_action_just_pressed("camera_rotate_left"): camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): camera.y_rot += 90
#
func get_mouse_over_object(lmask): #получение объекта под курсором (вроде как)
	#if ui_control.is_mouse_hover_button(): return #выходим из функции, если ?...?
	var cam = get_viewport().get_camera_3d() #получаем камеру во вьюпорте (именно вид из камеры(направление))
	var origin = get_viewport().get_mouse_position() if !is_gamepad else get_viewport().size/2
	#^получаем позицию курсора
	var from = cam.project_ray_origin(origin) #создаем начальную точку луча
	var to = from + cam.project_ray_normal(origin)*1000000 #создаем конечную точку луча
	var ray_query = PhysicsRayQueryParameters3D.create(from, to, lmask, []) #создаем сам луч
	#lmask - скорее всего, это слой колизии, на котором находится юнит
	return get_world_3d().direct_space_state.intersect_ray(ray_query).get("collider")
	#^возвращаем объект при столкновении
#
func _aux_select_unit():
	var unit = get_mouse_over_object(2) #получение объекта под курсором
	var tile = get_mouse_over_object(1) if !unit else unit.get_tile()
	#print(tile.name)
	#^получаем тайл если ранее мы не получили юнита в unit, иначе получаем тайл через его функцию
	arena.mark_hover_tile(tile) #обозначаем выбранный тайл
	return unit if unit else tile.get_object_above() if tile else null #условия возвращения
#
func _aux_select_tile(): #получения тайла под курсором
	var unit = get_mouse_over_object(2)
	var tile = get_mouse_over_object(1) if !unit else unit.get_tile()
	arena.mark_hover_tile(tile)
	return tile #возвращаем сам тайл и только
#
func player_wants_to_move(): stage = 2
#
func player_wants_to_cancel():
	if current_unit.cur_weapon:
		current_unit.cur_weapon = null
		current_unit.cur_weapon_id = 0
	arena.reset()
	stage = 1 if stage > 1 else 0

func player_wants_to_wait(): 
	current_unit.do_wait()
	stage = 0

func player_wants_to_attack(): stage = 5

func player_wants_to_defence(): stage = 8
#func player_wants_to_use_ability(): stage = 
#func player_wants_to_other_do(): stge = 

#	STAGES

func select_unit():
	arena.reset() #сбрасываем арену
	if current_unit: current_unit.display_unit_stats(false) #если есть выбранный юнит - отключаем отображение статов
	current_unit = _aux_select_unit() #получаем необходимого юнита
	if !current_unit : return #если мы не получили юнита - выходим из функции
	current_unit.display_unit_stats(true) #отображаем необходимое
	if Input.is_action_just_pressed("select") and current_unit.can_act() and current_unit in units:
	#^если все ок (прожата нужная кнопка, персонаж может совершать действия и он является дочерним нодом)
		camera.target = current_unit #переключаем камеру на него
		stage = 1 #меняем у него стадию котроля (на ожидания ввода)
	pass

func display_available_actions_for_unit(): #Отображение доступных действий для персонажа
	current_unit.display_unit_stats(true) #Отображаем стату юнита
	arena.reset() #Сбрасываем арену
	arena.mark_hover_tile(current_unit.get_tile()) #показывем необходимый тайл под персонажем

func display_available_movements(): #Показываем доступную зону передвижения
	arena.reset() #сброс арены
	if !current_unit: return #проверка на отсутствие юнита - выходит из функции при прохождении проверки
	camera.target = current_unit #переключение камеры на выбранного юнита
	var allies : Array = units if units.size() > 1 else []
	arena.link_tiles(current_unit.get_tile(), current_unit.movement_length, allies)
	#^создает связь тайлов между собой. Принимает: (корневой тайл под юнитом, высоту прыжка юнита и всех юнитов)
	arena.mark_reachable_tiles(current_unit.get_tile(), current_unit.movement_length)
	#^помечает доступные для передвижения тайлы
	stage = 3 #переключает контроллер на стадию 3 (Выбор новой точки для передвижения)

func select_new_location(): #выбор тайла, как цель перемещения
	var tile = get_mouse_over_object(1) #получаем тайл под курсором
	arena.mark_hover_tile(tile) #показываем данный тайл
	if Input.is_action_just_pressed("select"): #если нажата ЛКМ
		if tile and tile.reachable: #если это тайл и он доступен
			current_unit.path_stack = arena.generate_path_stack(tile) #генерируем путь
			camera.target = tile #перемещаем камеру к данному тайлу
			stage = 4 #переключаем стадию контроллера на 4 (передвижение юнита)

func move_unit(): #передвижение юнита
	current_unit.display_unit_stats(false) #отображаем хп юнита
	if current_unit.path_stack.is_empty(): #если путь пустой
		stage = 0 if !current_unit.can_act() else 1 #Если путь пустой, устанавливаем стадию 1

func load_weapons_to_ui():
	ui_control.load_wepons(current_unit, 0)
	stage = 6
	pass

func display_available_weapons():
	if !current_unit.cur_weapon_id: return
	else:
		current_unit.cur_weapon_id -= 1
		current_unit.cur_weapon = current_unit.weapons[current_unit.cur_weapon_id]
		print("Taked id: " + str(current_unit.cur_weapon_id)) 
		stage = 7
	pass

func display_attackable_targets(): #Отображение доступных целей для атаки
	arena.reset() #сброс арены
	if !current_unit: return #выходит из фукции если нет текущего юнита (выбранного)
	camera.target = current_unit #назначает выбранного юнита целью камеры
	arena.link_tiles(current_unit.get_tile(), current_unit.cur_weapon.attack_range) #связыает тайлы между собой
	arena.mark_attackable_tiles(current_unit.get_tile(), current_unit.cur_weapon.attack_range, units) #помечает тайлы атаки
	stage = 8 #переключает контроллер на стадию 6 (выбрать цель атаки)

func select_target_to_attack(): #выбор юнита для атаки
	current_unit.display_unit_stats(true) #Отображаем здоровье персонажа
	if target_unit: target_unit.display_unit_stats(false)
	#^У старой цели (если она есть) отключаем отобрахение здоровье
	var tile = _aux_select_tile() #if _aux_select_unit() not in units else null
	target_unit = tile.get_object_above() if tile else null #берем юнита
	if target_unit: target_unit.display_unit_stats(true) #если юнит получен - показываем его здоровье
	if Input.is_action_just_pressed("ui_accept") and tile and tile.attackable: #если нажата лкм
	#и есть тайл и он считается как тайл атаки
		camera.target = target_unit #вокусируем камеру на цели атаки
		stage = 9 #переключаем стадию на 7 (атаковать юнита (принимает дельту)

func can_act():
	if activations_count: return true
	else: false

func check_activations():
	for unit in units:
		if unit.is_activated:
			activations_count -= 1

func take_turn():
	activations_count = 1
	can_do_turn = true
	for unit in units:
		unit.reset()
	pass
	
func act(_delta):
	#print(stage)
	#print(activations_count)
	check_activations()
	move_camera()
	camera_rotation()
	ui_control.set_visibility_of_actions_menu(stage in [1,2,3,5,6,7,8], current_unit)
	ui_control.set_visibility_of_weapons_menu(stage in [6], current_unit)
	match stage:
		0: select_unit()
		1: display_available_actions_for_unit()
		2: display_available_movements()
		3: select_new_location()
		4: move_unit()
		5: load_weapons_to_ui()
		6: display_available_weapons()
		7: display_attackable_targets()
		8: select_target_to_attack()
	
func _input(_event):
	if current_unit:
		if Input.is_action_just_pressed("action_move") and current_unit.can_move:
			if stage != 3: player_wants_to_move()
			elif stage != 3 and stage > 1:
				player_wants_to_cancel()
				player_wants_to_move()
			elif stage != 1: player_wants_to_cancel()
		if Input.is_action_just_pressed("action_attack") and current_unit.can_attack:
			if stage != 6 or stage != 8: player_wants_to_attack()
			elif stage > 1 and (stage != 6 or stage != 8):
				player_wants_to_cancel()
				player_wants_to_attack()
			elif stage != 1: player_wants_to_cancel()
		if Input.is_action_just_pressed("action_cancel"):
			player_wants_to_cancel()
		if Input.is_action_just_pressed("action_wait"):
			if stage == 1: player_wants_to_wait()
	pass
