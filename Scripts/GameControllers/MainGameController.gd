class_name MainGameController

extends Node

const Library = preload("res://Scripts/GameControllers/GameLibrary.gd")

@export_category("Switch properties")
@export_group("Scene")
@export var current_scene : Library.SCENES_LIST

@export_group("Files")
@export var scenes_path :Array

var scenes : Array

func _ready():
	do_switch_map()
	pass

func do_switch_map() -> void:
	var map_buffer
	var taked_map
	
	#maps.clear()
	
	for i in scenes_path.size():
		map_buffer = load(scenes_path[i])
		scenes.append(map_buffer.instantiate())
		if scenes[i].is_scene_current == true and scenes[i].scene_id != current_scene:
			scenes[i].is_scene_current = false
			scenes[i].queue_free()
		if scenes[i].scene_id == current_scene:
			taked_map = scenes[i]
	taked_map.is_scene_current = true
	add_child(taked_map, true)
	pass
