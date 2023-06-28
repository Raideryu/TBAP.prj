class_name GameController

extends Node

const c_Utils = preload("res://Scripts/Utils.gd")
const c_Port = 4433

@export_category("Game settings")
@export_group("Scenes preset")
@export var launching_scene : c_Utils.Scenes_List
@export var scenes_path : Array[String]

#var is_server : bool = false

var next_scene = null : set = _set_next_scene
var current_scene : SceneController = null

var scenes : Array[SceneController]

func _ready():
	get_tree().paused = true
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		do_host(c_Utils.Scenes_List.Test_Level).call_deferred(c_Utils.Scenes_List.Test_Level)
	pass
	get_tree().paused = false
	_set_next_scene(launching_scene)
	do_switch_scene()
	#get_tree().paused = true
	pass

func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		_set_next_scene.call_deferred(c_Utils.Scenes_List.Test_Level)
		do_switch_scene.call_deferred()

func _set_next_scene(value : c_Utils.Scenes_List) -> void :
	next_scene = value
	pass

func do_switch_scene() -> void :
	var taked_scene = null
	var scene_buffer = null
	
	if scenes.size() > 0:
		scenes.clear()
		pass
	
	for i in scenes_path.size():
		scene_buffer = load(scenes_path[i])
		scenes.append(scene_buffer.instantiate())

		if current_scene and current_scene.scene_type == scenes[i].scene_type and scenes[i].scene_type != next_scene:
			$Scenes.remove_child(current_scene)
			current_scene.queue_free()
		if scenes[i].scene_type == next_scene:
			taked_scene = scenes[i]
	
	taked_scene.is_cur_scene = true
	taked_scene.scene_switcher = self
	taked_scene.set_name(taked_scene.scene_name)
	$Scenes.add_child(taked_scene, true)
	current_scene = $Scenes.get_child(0)
	pass

func do_host(value : c_Utils.Scenes_List):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(c_Port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	
	get_tree().paused = true
	start_game(value)
	pass

func do_connect(value : String):
	var txt : String = value
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, c_Port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
	pass

func start_game(value : c_Utils.Scenes_List = c_Utils.Scenes_List.Test_Level):
	print("delete scene")
	$Scenes.remove_child(current_scene)
	current_scene.queue_free()
	current_scene = null
	
	get_tree().paused = false
	if multiplayer.is_server():
		_set_next_scene(value)
		do_switch_scene.call_deferred()
	pass
