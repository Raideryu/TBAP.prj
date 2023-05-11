class_name MainSceneController

extends Node

const Library = preload("res://Scripts/GameControllers/GameLibrary.gd")

@export_category("System Logic")
@export_group("Switch connector")
@export var scene_type : Library.SCENES_TYPE
@export var scene_id : Library.SCENES_LIST

@export_group("Inner Logic")
@export_subgroup("Files")
@export var controller_path : NodePath
var controller

var is_scene_current = false

func do_init_scene() -> void:
	controller = get_node(controller_path)
	controller.connector = self
