class_name WeaponConfig

extends Resource

const c_Utils = preload("res://Scripts/Utils.gd")

@export_category("Weapon Config")
@export_group("Weapon Info")
@export var weapon_type : c_Utils.WEAPON_TYPES = c_Utils.WEAPON_TYPES.Range_Weapon
@export var weapon_name : c_Utils.WEAPON_NAMES = c_Utils.WEAPON_NAMES.None
@export var attack_type : c_Utils.WEAPON_ATTACK_TYPES = c_Utils.WEAPON_ATTACK_TYPES.Point

@export_group("Weapon Stats")
@export_range(1, 10, 1) var attack_range : int = 1
@export_range(1, 10, 1) var attack_count : int = 1
@export_range(1, 10, 1) var attack_damage : int = 1
@export_range(0, 20, 1) var armor_piercing : int = 1
