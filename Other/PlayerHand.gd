extends Node2D

const CARD_WIDTH = 150
const  HAND_Y_POSITION = 145
const  HAND_X_POSITION = 300
const DEFAULT_MOVE_SPEED = 0.1

var player_hand = []
	
signal card_count_changed(new_count)

func add_card_to_hand(card, speed):
	if card not in player_hand:
		#add card to end of hand
		player_hand.append(card)
		emit_signal("card_count_changed", player_hand.size())
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_MOVE_SPEED)

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		#set new card position
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	return HAND_X_POSITION + index * CARD_WIDTH

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		emit_signal("card_count_changed", player_hand.size())
		update_hand_positions(DEFAULT_MOVE_SPEED)
