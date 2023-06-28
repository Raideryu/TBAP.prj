extends Control

const c_Utils = preload("res://Scripts/Utils.gd")

var controller : SceneController



func _on_return_button_pressed():
	controller.do_call_switch_scene(c_Utils.Scenes_List.Main_Menu)
	pass # Replace with function body.
