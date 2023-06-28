class_name LevelController

extends Node3D

const c_Utils = preload("res://Scripts/Utils.gd")

enum Game_Phases {
	Deploy,
	Battle,
	End,
}

@export var launching_phase : Game_Phases = Game_Phases.Deploy

@onready var players_holder = $Players

var controller : SceneController
#var camera : TacticCamera
var arena : ArenaController
var players : Array[PlayerController] = []
var ui_controllers : Array[PlayerUI] = []
var scene_ui : Control

var current_phase : Game_Phases

func _ready():
	if !multiplayer.is_server(): return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	
	arena = $Arena
	
	for id in multiplayer.get_peers():
		print("player id:" + str(id))
		add_player(id)
	
	if not OS.has_feature("dedicated_server"):
		add_player(1)
	#camera = $TacticCamera
	#for i in players_holder.get_child_count():
		#players.append(players_holder.get_child(i))
		#ui_controllers.append(players[i].ui_control)
		#players[0].player_id = "plr" + str(players[0].get_instance_id()) + "n" + str(players[0].get_index())
		#print(players[i].player_id)
		#players[i].configure(arena)
		#pass
	current_phase = launching_phase
	pass

func _process(delta):
	phase_handler(delta)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(delete_player)

func phase_handler(delta):
	match current_phase:
		Game_Phases.Deploy:
			pass
		Game_Phases.Battle:
			turn_handler(delta)
			pass
		Game_Phases.End:
			pass

func turn_handler(delta):
	if players[0].can_act(): players[0].act(delta)
	else: players[0].take_turn()
	#pass

func add_player(id):
	var player = preload("res://Scenes/player_controller.tscn").instantiate()
	
	player.player_id = id
	player.name = "pl" + str(id)
	players_holder.add_child(player, true)
	
	var player_scene : PlayerController
	for p in players_holder.get_children():
		player_scene = p if player.player_id == p.player_id else null
	
	players.append(player_scene)
	ui_controllers.append(player_scene.ui_control)
	print(player_scene.player_id)
	player_scene.configure(arena)
	pass

func delete_player(id):
	pass

func get_scene_switcher():
	return controller.scene_switcher
