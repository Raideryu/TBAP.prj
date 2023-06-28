class_name TacticCamera

extends CharacterBody3D

const MOVE_SPEED = 16
const ROT_SPEED = 10

var x_rot = -30
var y_rot = -45
var target = null


func move_camera(h, v, joystick = null): #передижение камеры
	if !joystick and h == 0 and v == 0 or target: return
	#^если не геймпаж и h равен 0 и v равен 0 или есть цель - выходим из функцию
	var angle = (atan2(-h, v))+$Pivot.get_rotation().y #задаем угол
	#угол равен 
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle) #получаем направление
	var vel = dir*MOVE_SPEED #задаем велосити 
	if joystick: vel = vel*sqrt(h*h+v*v) #если с геймпада - перезадаем велосити
	set_velocity(vel) #выставляем велосити
	set_up_direction(Vector3.UP) #устаналиваем направление
	move_and_slide() #выставляем движение
	vel = velocity #возвращаем велосити


func rotate_camera(delta): #поворот камеры
	var curr_r = $Pivot.get_rotation() #получаем текущий поворот
	var x = deg_to_rad(x_rot) #получаем икс (хз как)
	var y = deg_to_rad(y_rot) #получаем игрик (анологично)
	var dst_r = Vector3(x, y, 0) #формируем Vector3 поворота
	$Pivot.set_rotation(curr_r.lerp(dst_r, ROT_SPEED*delta)) #делаем поворот


func follow(): #следить
	if !target: return #выходим из функции если нет цели
	var from = global_transform.origin #получение исходной точки
	var to = target.global_transform.origin #получение конечной точки
	var vel = (to-from)*MOVE_SPEED/4 #получение велосити
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity
	if from.distance_to(to) <= 0.25: target = null #если цель ближе чем 0.25 - цель убираем


func _process(delta):
	rotate_camera(delta)
	follow()
