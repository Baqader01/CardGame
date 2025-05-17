extends Node2D

const NO_OF_PILES = 6

var deck = []
var piles = []

const PILE_X_OFFSET = 800
const PILE_Y_OFFSET = 200

func _init() -> void:
	for i in range(NO_OF_PILES):
		piles.append([])

func get_pile_position(pile_index, card_index, X_OFFSET, Y_OFFSET):
	var x = 150 * pile_index
	var y = 30 * card_index
	return Vector2(x + X_OFFSET, y + Y_OFFSET)
