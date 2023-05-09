const Menu_Path = [
	"res://Scenes/Menus/MainMenu.tscn",
]
const Level_Path = [
	"res://Scenes/Levels/Level1.tscn",
]

enum SceneType {
	MENU,
	LEVEL,
}

func do_get_path(type: SceneType, scene_num: int):
	match type:
		SceneType.MENU: return Menu_Path[scene_num]
		SceneType.LEVEL: return Level_Path[scene_num]
