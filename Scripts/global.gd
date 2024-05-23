extends Node
var players = []

var hud : CanvasLayer

func add_player(new_player):
	players.push_back(new_player)

func set_hud(new_hud):
	hud = new_hud
func get_hud():
	return hud
