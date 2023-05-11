class_name Test

extends Node

signal s_Custom_Signal

enum TEST_ENUM {
	One,
	One_Two,
}

const c_Preload_Test = preload("res://Scripts/GameControllers/GameLibrary.gd")

@export_category("Test Category")
@export_group("Test Group")
@export var e_test_export : String
@export var e_export_array : Array[int]
@export var e_alt_enum : c_Preload_Test.SCENES_LIST

var public_var : String = "string"

func _init():
	public_var = "res://Scripts/GameControllers/GameLibrary.gd"
	pass

func _ready():
	c_Preload_Test.instantiate()

func do_something(value: int, array: Array[Sprite3D]) -> Array[int]:
	var out: Array[int]
	
	out.resize(array.size())
	for i in array.size():
		out[i] = value
	
	return out
