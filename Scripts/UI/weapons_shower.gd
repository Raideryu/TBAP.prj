class_name WeaponsShower

extends PanelContainer

const weapon_profile = preload("res://Scenes/UI/level_weapon_profile.tscn")
const c_Utils = preload("res://Scripts/Utils.gd")

var player : PlayerController
#var weapons : Array[WeaponConfig] = []
var weapon_profiles : Array = []

func configurate(p : PlayerController):
	player = p
	pass

func load_weapons(arr : Array[WeaponConfig]):
	if weapon_profiles: return
	for i in arr.size():
		var weapon = weapon_profile.instantiate()
		$VBoxContainer/Weapons.add_child(weapon, true)
		weapon_profiles.append($VBoxContainer/Weapons.get_child(i))
		weapon_profiles[i].shower = self
		weapon_profiles[i].set_name(c_Utils.WEAPON_NAMES.keys()[arr[i].weapon_name])
		#var stats = weapon_profiles[i].get_child(1)
		weapon_profiles[i].set_values(c_Utils.WEAPON_NAMES.keys()[arr[i].weapon_name],
			arr[i].attack_range, arr[i].attack_count, arr[i].attack_damage, arr[i].armor_piercing,
			c_Utils.WEAPON_ATTACK_TYPES.keys()[arr[i].attack_type])
		weapon_profiles[i].weapon_taked.connect(Callable(self, "take_weapon"))
		#stats.get_child(0).pressed.connect(Callable(self, "take_weapon"))
	pass

func clear_weapons_list():
	for i in weapon_profiles.size():
		var weapon = weapon_profiles.pop_front()
		weapon.queue_free()
	weapon_profiles.clear()
	pass

func take_weapon(id : int):
	print("Weapon taked\tid: " + str(id))
	player.current_unit.cur_weapon_id = id+1
	print(c_Utils.WEAPON_NAMES.keys()[id])
	pass
