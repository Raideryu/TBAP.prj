extends HBoxContainer

signal weapon_taked(id : int)

var shower : WeaponsShower

func _ready():
	$Name/Button.pressed.connect(Callable(self, "deliver_weapon"))
	pass

func set_values(w_name : String, a_range : int, count : int, damage: int, ap : int, type):
	$Name/Button.text = w_name
	$Range/Value.text = str(a_range)
	$Count/Value.text = str(count)
	$Damage/Value.text = str(damage)
	$AP/Value.text = str(ap)
	$Type/Value.text = str(type)
	pass

func deliver_weapon():
	weapon_taked.emit(get_index())
	pass
