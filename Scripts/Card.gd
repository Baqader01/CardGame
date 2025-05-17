extends Node2D

signal flipped_changed(is_flipped)

@export var start_flipped := true
@export var auto_load_textures := true

var pile_id = null #keep track of what pile the card is in
var stock:bool = false #keep track of whether the card is in the stock pile
var is_mouse_entered:bool = false
var is_dragging:bool = false
var previous_positions = []


var rank: String = "":
	set(value):
		rank = value
		if auto_load_textures: update_texture()


var suit: String = "":
	set(value):
		suit = value
		if auto_load_textures: update_texture()

var is_flipped: bool = start_flipped:
	set(value):
		if is_flipped == value: return
		is_flipped = value
		update_texture()
		flipped_changed.emit(is_flipped)

@onready var front_texture: Texture2D = load_texture()
@onready var back_texture: Texture2D = preload("res://assets/Cards/Back Blue.png")
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.scale = Vector2(0.5, 0.5)
	update_texture()

func _input(event):
	#Handle all card drag events
	
	#dont move card if mouse not on the card
	if not is_mouse_entered or (rank == "" and suit == ""):
		return
	
	# can move only top card
	if Input.is_action_just_pressed("left_click") and not is_flipped:
		is_dragging = true
		#to return cards to normal position
		#remember_card_position()
	elif event is InputEventMouseMotion and is_dragging:
		#move_cards()
		print("hello")
	elif Input.is_action_just_released("left_click") and is_dragging:
		is_dragging = false
		#if !drop_card():
			#reset_cards()

func update_texture():
	if sprite:
		sprite.texture = back_texture if is_flipped else front_texture

func flip():
	is_flipped = not is_flipped

func load_texture():
	if rank == "" and suit == "": return
	var path = "res://assets/Cards/%s_of_%s.png" % [rank.to_lower(), suit.to_lower()]
	return load(path)

#func check_valid_move(card):
	#if card.pile_id == null or card.pile_id == pile_id:
		#return false
	#
	#var pile = GameManager.piles[card.pile_id]
	#
	##empty pile
	#if len(pile) == 1 and card.suit == "" and card.rank == "":
		#return true # move cards to an empty pile
	#
	##dont place cards onn top of unflipped cards
	#if not card.flipped:
		#return false
	#
	##one more in value and opposite suit
	#if CardDatabase.is_one_rank_higher(rank, pile[-1].rank) and CardDatabase.is_opposite_suit(suit, pile[-1].suit):
		#return true
	#
	#return false
#
##func move_to_new_pile(new_card):
	##if pile_id != null:
		##var current_pile = GameManager.piles[pile_id]
		##var current_card_index = current_pile.find(self)
		##
		##var new_pile =  GameManager.piles[new_card.pile_id]
		##
		###move cards to new pile
		##var cards_to_move = current_pile.slice(current_card_index, len(current_pile))
		##for i in range(len(cards_to_move)):
			##var card = cards_to_move[i]
			##card.position = GameManager.get_pile_position(
				##new_card.pile_id, len(new_pile),
				##GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET
			##)
			##card.z_index = new_pile[-1].z_index + 1
			##new_pile.append(card)#
		##
		###remove the top cards from old pile
		##for i in range(cards_to_move):
			##current_pile.pop_back()
		##
		###flip top=most card of previous pile after moving
		##if len(current_pile) > 1:
			##current_pile.back().flip()
##
###func get_overlapping_areas() -> Array:
	###var areas = []
	###for area in $Area2D.get_overlapping_areas():
		###if area.is_in_group("Card") or area.is_in_group("Pile"):
			###areas.append(area)
	###return areas
###
#### mouse movement functions
####func move_cards():
	#####move the selected cards
	####if pile_id == null:
		####position = get_global_mouse_position()
		####z_index = 100
		####return
	####
	#####find selected cards
	####var pile = GameManager.piles[pile_id]
	####var current_card_index = pile.find(self)
	####if len(pile) > current_card_index:
		#####we need to move selected set of cards
		####var cards_to_move = pile.slice(current_card_index, len(pile))
		####for i in range(len(cards_to_move)):
			####var card = cards_to_move[i]
			####card.position = get_global_mouse_position()
			####
			#####apply vertical width to separate multipule cards
			####card.position.y += 30 * i
			####
			#####apply high z-index to make cards appear above other piles
			####card.z_index = 100 + i
		####
	####pass
###
####func drop_card():
	#####if card is moved to a valid set, then we need to move it
	####var overlapping_areas = get_overlapping_areas()
	####for area in overlapping_areas:
		#####need to detect other cards
		####if area.is_in_group("Card"):
			####if check_valid_move(area):
				####move_to_new_pile(area)
				####return true
	#####if cards cannot be moved, we reset the state
	####return false
###
####func remember_card_position():
	####previous_positions = []
	#####stock cards are not a part of pile
	####if pile_id == null:
		####position = previous_positions[0]['position']
		####z_index = 1
	####else:	
		####var pile = GameManager.piles[pile_id]
		####var current_card_index = pile.find(self)
		####if len(pile) > current_card_index:
			#####we need to move selected set of cards
			####var cards_to_move = pile.slice(current_card_index, len(pile))
			####for card in cards_to_move:
				####previous_positions.append({
					####"position": card.position
				####})
###
####func reset_cards():
	####var pile = GameManager.piles[pile_id]
	####var current_card_index = pile.find(self)
	####if len(pile) > current_card_index:
		#####we need to reset selected set of cards
		####var cards_to_move = pile.slice(current_card_index, len(pile))
		####for i in range(len(previous_positions)):
			####var card = cards_to_move[i]
			####card.position = previous_positions[i]["position"]
			####card.z_index = pile[current_card_index - 1].z_index + i + 1
	####previous_positions = []

func _on_area_2d_mouse_exited() -> void:
	is_mouse_entered = false


func _on_area_2d_mouse_entered() -> void:
	is_mouse_entered = true
