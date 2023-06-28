class_name SceneController

extends Node

const c_Utils = preload("res://Scripts/Utils.gd")

@export var scene_name : String
@export var scene_type : c_Utils.Scenes_List = c_Utils.Scenes_List.Main_Menu
@export_node_path var ui_controller_path
@export_node_path var level_controller_path
@export var is_level : bool = false
@export var can_connect_ui : bool = true

var is_cur_scene : bool = false
var scene_switcher : GameController
var ui_controller
var level_controller : LevelController

func _ready():
	if can_connect_ui:
		ui_controller = get_node(ui_controller_path)
		ui_controller.controller = self
	
	if is_level:
		level_controller = get_node(level_controller_path)
		level_controller.controller = self
		#level_controller.scene_ui = ui_controller
	pass
	
func do_call_switch_scene(value : c_Utils.Scenes_List):
	scene_switcher._set_next_scene(value)
	print("taked")
	scene_switcher.do_switch_scene()
	pass

func do_host_game(value : c_Utils.Scenes_List):
	scene_switcher.do_host(value)
	pass

func do_connect_to_game(value : String):
	print(value)
	scene_switcher.do_connect(value)
	pass
