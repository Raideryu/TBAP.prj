class_name PlayerUI

extends Control

var menu
var list : WeaponsShower
var actions : Array[Button] = []
var player_controller : PlayerController



func configure(player : PlayerController):
	player_controller = player
	menu = $VBoxContainer/BotPanel/Actions
	list = $VBoxContainer/MidBotPanel/WeaponsList
	list.configurate(player)
	for a in menu.get_children():
		actions.append(a.get_child(0))
	

func get_act(action : String = ""): #получаем Hbox с действиями персонажа
	if action == "": return $HBox/Actions
	return actions[action.to_int()]
	

func is_mouse_hover_button(): #проеряем, что курсор попадает на кнопку
	if menu.visible: #если hbox действий виден
		for action in actions: #прогонка каждого действия
			if action.get_global_rect().has_point(get_viewport().get_mouse_position()):
			#^если можем получать позицию мыши на кнопках - возвращаем true
				return true
	return false #иначе озвращаем false

func set_visibility_of_actions_menu(v, p): #отображаем кнопки действий в зависимости от их использования
	if !menu.visible: actions[0].grab_focus()
	#^если hbox не виден - фокусируемся на кнопке move
	menu.visible = v #передаем числа stage (скорее всего, если stage = 0 - hbox станет не виден)
	if !p : return #если нет выбранного юнита - выходим из функции
	actions[0].disabled = !p.can_move #отключаем кнопку если персонаж не может это делать 
	actions[1].disabled = !p.can_attack # отклюен = не (не может) => отключен = правда

func set_visibility_of_weapons_menu(v, p):
	#if !list.visible: list.weapon_profiles[0].grab_focus()
	
	list.visible = v
	if !p: return
	pass

func load_wepons(unit : UnitController, key):
	match key:
		0: list.load_weapons(unit.weapons)
		1: list.clear_weapons_list()
	pass

func _on_move_button_pressed():
	if player_controller.stage != 3: player_controller.player_wants_to_move()
	else: player_controller.player_wants_to_cancel()
	pass # Replace with function body.


func _on_attack_button_pressed():
	pass # Replace with function body.


func _on_skills_button_pressed():
	pass # Replace with function body.


func _on_def_button_pressed():
	pass # Replace with function body.


func _on_wait_button_pressed():
	if player_controller.stage == 1:
		player_controller.player_wants_to_wait()
	pass # Replace with function body.


func _on_cancel_button_pressed():
	player_controller.player_wants_to_cancel()
	pass # Replace with function body.
