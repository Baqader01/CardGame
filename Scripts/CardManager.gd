extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

const DEFAULT_MOVE_SPEED = 0.1

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference 
var card_database_reference = preload("res://Scripts/CardDatabase.gd").new()

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

func on_left_click_released():
	if card_being_dragged:
		end_drag()

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y))

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(0.5, 0.5)

func end_drag():
	card_being_dragged.scale = Vector2(0.55, 0.55)
	var card_slot_found = check_for_card_slot()
	if card_slot_found:
		var first_card = card_slot_found.cards.is_empty()
		
		if card_slot_found.slot_type == card_slot_found.SlotType.FOUNDATION:
			# handle foundation drop logic
			print("Dropped in foundation!")
		elif card_slot_found.slot_type == card_slot_found.SlotType.TABLEAU:
			# handle tableau drop logic
			print("Dropped in tableau!")
		
		card_slot_found.cards.append(card_being_dragged)
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		
		card_being_dragged.position = card_slot_found.position
		
		# Update all card positions in the slot after adding the new card
		update_slot_positions(card_slot_found)

			
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_MOVE_SPEED)
		
	card_being_dragged = null

func update_slot_positions(slot):
	var offset_y = 30
	
	slot.cards.sort_custom(card_database_reference.compare_cards_by_rank)

	for i in range(slot.cards.size()):
		var card = slot.cards[i]
		card.position = slot.position + Vector2(0, offset_y * i)
		card.z_index = i


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func  on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func  on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		
		var new_card_hovered = check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(0.55, 0.55)
		card.z_index = 2
	else:
		card.scale = Vector2(0.5, 0.5)
		card.z_index = 1

#To check if we are clicking on the card
func check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_on_top(result)
	return null

#To check if we are clicking on the card
func check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func get_card_on_top(cards):
	#assume first card in array is the one on top
	var highest_card = cards[0].collider.get_parent()
	var highest_index = highest_card.z_index
	
	#loop through each card to find the top card
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_index:
			highest_card = current_card
			highest_index = current_card.z_index
	return highest_card
			
	
