class_name UnitController

extends CharacterBody3D

const c_Utils = preload("res://Scripts/Utils.gd")

#const c_Speed = 7
#const c_Animation_Frames = 1
const c_Min_Jump_High = 1
#const c_Gravity_Strength = 7
const c_Min_Time_For_Attack = 1

@export_category("Unit Config")

@export_group("Backend unit settings")
@export_subgroup("Physics")
@export_range(1, 10, 1) var speed : int = 7
@export_range(1, 10, 1) var gravity_strength : int = 7
@export_subgroup("Animations")
@export_range(1, 20, 1) var animation_frames : int = 1
@export_subgroup("Other")
@export_range(1, 10, 1) var min_time_for_attack = 1

@export_group("Unit Personal Info")
@export var unit_fraction : c_Utils.UNIT_FRACTIONS
@export var unit_type : c_Utils.UNIT_TYPES = c_Utils.UNIT_TYPES.Pawn
@export var unit_name : String = ""

@export_group("Unit Stats")
@export_subgroup("Activation")
@export_range(1, 10, 1) var actions_count : int = 1
@export_subgroup("Size")
@export_range(1, 4, 1) var unit_size : int = 1
@export_subgroup("Movement")
@export var movement_type : c_Utils.MOVEMENT_TYPES = c_Utils.MOVEMENT_TYPES.Radius
@export_range(1, 10, 1) var movement_length : int = 1
@export_range(0.00, 10.00, 0.50) var jump_high : float = 1
@export_subgroup("Armour")
@export var armour_type : c_Utils.EQUIPMENT_TYPES = c_Utils.EQUIPMENT_TYPES.TIS
@export_range(0, 20, 1) var armour_value : int = 0
@export_subgroup("Health")
@export_range(1, 20, 1) var max_wounds : int = 2

@export_group("Unit's weapon")
@export var weapons : Array[WeaponConfig]
@export_category("")

var holder_id : String = ""

var cur_weapon : WeaponConfig = null
var cur_weapon_id = null
var cur_wounds : int = 0
var cur_armour : int = 0

var is_unconscious : bool = false
var is_alive : bool = true

#animations
var cur_frame : int = 0
var animator = null

#pathfinding
var path_stack : Array = []
var move_direction = null
var is_jumping : bool = false
var is_climbing : bool = false
var gravity = Vector3.ZERO
var wait_delay = 0

var cur_actions_count : int = 0
var did_action : bool = false

var is_activated : bool = false
var can_action : bool = true
var can_move : bool = true
var can_attack : bool = true
var can_def : bool = true
var can_use_ability : bool = true

var unit_id : String = ""
var units_holder = null

func _ready():
	_configurate_unit()
	pass

func _process(delta):
	rotate_pawn_sprite()
	apply_movement(delta)
	actions_control()
	$Stats/Wounds.text = str(cur_wounds) + "/" + str(max_wounds)
	$Stats/Armour.text = str(cur_armour) + "/" + str(armour_value)
	

func _configurate_unit():
	$Stats/Name.text = unit_name
	cur_wounds = 0
	cur_armour = armour_value
	
	#cur_actions_count = actions_count
	_load_animator_sprite()
	display_unit_stats(false)
	units_holder = get_parent()
	unit_id = unit_name[0] + str(unit_name.length()) + "h" + str(unit_name.hash()) + "i" + str(get_index())
	print(unit_id)
	reset()
	pass

func rotate_pawn_sprite(): #поворот спрайта
	var camera_forward = -get_viewport().get_camera_3d().global_transform.basis.z #находим перед камеры
	var dot = global_transform.basis.z.dot(camera_forward) #хз что такое дот, тормазуха вроде
	$Character.flip_h = global_transform.basis.x.dot(camera_forward) > 0 #флипаем спрайт (отражаем его)
	if dot < -0.306: $Character.frame = cur_frame
	elif dot > 0.306: $Character.frame = cur_frame + 1 * animation_frames

func _load_animator_sprite(): #загрузка анимации
	animator = $Character/AnimationTree.get("parameters/playback")
	animator.start("IDLE")
	$Character/AnimationTree.active = true
	$Character.texture = load("res://Arts/Sprites/Characters/Test_sprite.png")
	#$Character.texture = c_Utils.get_pawn_sprite(pawn_class)
	#$CharacterStats/NameLabel.text = pawn_name+", the "+String(Utils.PAWN_CLASSES.keys()[pawn_class])

func start_animator(): #Запуск аниматора
	if move_direction == null : animator.travel("IDLE")
	elif is_jumping: animator.travel("JUMP")
	
func display_unit_stats(v):
	$Stats.visible = v
	pass

func reset(): #сброс юнита
	did_action = false
	can_action = true
	can_move = true
	can_attack = true
	can_def = true
	can_use_ability = true
	cur_actions_count = actions_count
	is_activated = false

func get_tile(): #полуение тайла
	#print("do get tile")
	return $Tile.get_collider()

func look_at_direction(dir): #смотреть в направлении
	var fixed_dir = dir*(Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1)) #фиксированное направление
	#^фикс_дир = направление * (вектор3 икса если |x| больше |z|, иначе берем вектор 3 зет)
	var angle = Vector3.FORWARD.signed_angle_to(fixed_dir.normalized(), Vector3.UP)+PI
	#^получаем угол
	set_rotation(Vector3.UP*angle) #поворачиваем в нужном направлении


func follow_the_path(delta): #прохождение пути
	
	if !can_action : return #отмена действия, если перс не может ходить
	if move_direction == null : move_direction = path_stack.front()-global_transform.origin
	#^получение направления если оно изначально равно нулю
	if move_direction.length() > 0.5: #Проверка направления по длине

		look_at_direction(move_direction) #Поворот в сторону направления (сам объект)
		var p_velocity = move_direction.normalized() #нормализуем вектор и передаем в переменную
		var curr_speed = speed #берем скорость персонажа

		# apply jump
		if move_direction.y > c_Min_Jump_High: #проверяем на возможность прыжка
			curr_speed = clamp(abs(move_direction.y)*2.3, 3, INF)
			is_jumping = true

		# fall or move to the edge before falling
		#проверяем на падение или на передвижение к краю перед падением
		elif move_direction.y < -c_Min_Jump_High: #если у направление ниже минимального значения
			if c_Utils.vector_distance_without_y(path_stack.front(), global_transform.origin) <= 0.2:
			#если "вектор без y" меньше или равен 0.2
				gravity += Vector3.DOWN*delta*gravity_strength #устанавливаем гравитацию
				p_velocity = (path_stack.front()-global_transform.origin).normalized()+gravity
				#^ выставляем велосити через гравитацию
			else: #иначе
				p_velocity = c_Utils.vector_remove_y(move_direction).normalized()
				#велосити без у и нормализован
		
		#устанавливаем движение юнита
		set_velocity(p_velocity*curr_speed)
		set_up_direction(Vector3.UP)
		move_and_slide()
		var _v = p_velocity #хз, нахуя
		if global_transform.origin.distance_to(path_stack.front()) >= 0.2: return
		#если дистанция юнита до след точки дальше или равен 0.2 - выходим из функции

	path_stack.pop_front() #убираем первый элемент (который мы обрабатывали) из массива
	#сбрасываем все что надо
	move_direction = null
	is_jumping = false
	gravity = Vector3.ZERO
	#cur_actions_count -= 1 if path_stack.size() == 0 else 
	#print("Cur actions: " + str(cur_actions_count) + "\tCan action: " + str(can_action))
	did_action = !path_stack.size() > 0
	#print("did action: " + str(did_action))

func adjust_to_center(): #центрирование юнита на тайле
	move_direction = get_tile().global_transform.origin-global_transform.origin
	#^получение разности позиций между юнитом и тайлом
	#выставляем движение
	set_velocity(move_direction*speed*4)
	set_up_direction(Vector3.UP)
	move_and_slide()
	var _v = velocity

func apply_movement(delta): #подтверждение движения
	if !path_stack.is_empty(): follow_the_path(delta) #если путь не пустой - проходим по пути
	else: adjust_to_center() #иначе - центрирование на тайле

func do_wait(): #выставляем простой персонажа
	can_action = false
	did_action = false
	can_move = false
	can_attack = false
	can_def = false
	can_use_ability = false
	cur_actions_count = 0
	is_activated = true

func can_act() -> bool :
	if can_action: return true
	else:
		print("unit can't act")
		print(can_action)
		return false

func actions_control():
	if did_action and cur_actions_count > 0:
		did_action = false
		cur_actions_count -= 1
		print("Cur actions: " + str(cur_actions_count))
		print("can action: " + str(can_action))
		for ally in units_holder.get_children():
			#print(ally.unit_id + "\t" + unit_id)
			if ally.unit_id != unit_id:
				ally.can_action = false
				#print(ally.name + " " + str(ally.can_action) + str(ally.is_activated))
			
	if !cur_actions_count:
		can_move = false
	pass

func do_attack(trgt_unit, delta): #делаем атаку (цель юнит, дельта)
	look_at_direction(trgt_unit.global_transform.origin-global_transform.origin)
	#^смотреть в направлении врага
	if can_attack and wait_delay > min_time_for_attack / 4.0:
	#^если может атаковать и делей больше мин. времени для атаки / 4:
		#trgt_unit.curr_health = clamp(trgt_unit.curr_health-attack_power, 0, INF)
		#^получаем хп противника после атаки
		#clamp(value, min, max) возвращает значение больше мин. и меньше макс.
		can_attack = false #отключаем возможность атаковать
	#if wait_delay < MIN_TIME_FOR_ATTACK: #если делей меньше мин времени для атаки
		wait_delay += delta #прибавляем к делей дельту
		return false #возвращаем false
	wait_delay = 0 #выставляем 0
	return true #возвращаем true
