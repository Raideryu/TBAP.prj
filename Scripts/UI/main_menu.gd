extends Control

const c_Utils = preload("res://Scripts/Utils.gd")

var controller : SceneController
# Called when the node enters the scene tree for the first time.
@onready var multiplyer_buttons = $HBoxContainer/Mid/Buttons/Multiplayer
@onready var adress = $HBoxContainer/Mid/Buttons/Adress

func _on_exit_button_pressed():
	controller.scene_switcher.get_tree().quit()
	pass # Replace with function body.


func _on_play_button_pressed():
	#controller.is_cur_scene = false
	#controller.do_call_switch_scene(c_Utils.Scenes_List.Test_Level)
	if !multiplyer_buttons.visible:
		multiplyer_buttons.visible = true
	else:
		multiplyer_buttons.visible = false
	pass # Replace with function body.


func _on_host_button_pressed():
	controller.do_host_game(c_Utils.Scenes_List.Test_Level)
	pass # Replace with function body.


func _on_client_button_pressed():
	if !adress.visible:
		adress.visible = true
	else:
		adress.visible = false
	pass # Replace with function body.

func _on_connect_button_pressed():
	if adress.get_child(0).text == "":
		controller.do_connect_to_game(adress.get_child(0).placeholder_text)
	else:
		controller.do_connect_to_game(adress.get_child(0).text)
		pass
	pass # Replace with function body.
