extends Node2D

signal flipped_changed(is_flipped)

@export var start_flipped := true
@export var auto_load_textures := true

var pile_id = null #keep track of what pile the card is in
var stock:bool = false #keep track of whether the card is in the stock pile
var is_mouse_entered:bool = false
var is_dragging:bool = false
var previous_positions = []

const RED_SUITS = ["Hearts", "Diamonds"]
const BLACK_SUITS = ["Clubs", "Spades"]

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
	if not is_mouse_entered:
		return
	
	# can move only top card
	if Input.is_action_just_pressed("left_click") and not is_flipped:
		is_dragging = true
		#to return cards to normal position
		remember_card_position()
	elif event is InputEventMouseMotion and is_dragging:
		move_cards()
	elif Input.is_action_just_released("left_click") and is_dragging:
		is_dragging = false
		if !drop_card():
			reset_cards()

func update_texture():
	if sprite:
		sprite.texture = back_texture if is_flipped else front_texture

func flip():
	is_flipped = not is_flipped

func load_texture():
	var path = "res://assets/Cards/%s_of_%s.png" % [rank.to_lower(), suit.to_lower()]
	return load(path)

func check_valid_move(card):
	if card.pile_id == null or card.pile_id == pile_id:
		return false
	
	var pile = GameManager.piles[card.pile_id]
	
	if pile.is_empty():
		return true # move cards to an empty pile
	
	#dont place cards on top of unflipped cards
	if card.is_flipped:
		return false
	
	var previous_card = pile[-1]
	var previous_card_index = CardDatabase.card_index(self)
	var card_index = CardDatabase.card_index(card)
	
	var opposite_suit = (suit in RED_SUITS and previous_card.suit in BLACK_SUITS) or \
		   (suit in BLACK_SUITS and previous_card.suit in RED_SUITS)
	
	#one more in value and opposite suit
	if ((card_index + 1) == previous_card_index) and  opposite_suit:
		return true
	
	return false

func move_to_new_pile(new_card):
	if pile_id != null:
		var current_pile = GameManager.piles[pile_id]
		var current_card_index = current_pile.find(self)
		if current_pile.is_empty():
			print("hello")
		
		var new_pile =  GameManager.piles[new_card.pile_id]
		
		#move cards to new pile
		var cards_to_move = current_pile.slice(current_card_index, len(current_pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.pile_id = new_card.pile_id
			card.position = GameManager.get_pile_position(
				new_card.pile_id, len(new_pile),
				GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET
			)
			card.z_index = new_pile[-1].z_index + 1
			new_pile.append(card)
			
		print("Moving to pile :", new_card.pile_id, " New pile len before :", len(new_pile))
		
		#remove the top cards from old pile
		for i in range(len(cards_to_move)):
			current_pile.pop_back()
		
		#var descriptions = []
		#for cards in current_pile:
			#if cards.rank != "" and cards.suit != "":
				#descriptions.append(cards.rank + " of " + cards.suit)
		#print(", ".join(descriptions) )
		
		#flip top most card of previous pile after moving
		if len(current_pile) > 1:
			current_pile.back().flip()

func get_overlapping_cards() -> Array:
	var cards = []
	for card in $Area2D.get_overlapping_areas():
		card = card.get_parent()
		if not card.is_flipped:
			cards.append(card)
	
	#for card in cards:
		#print(card.rank, " of ",card.suit)
	
	return cards

#### mouse movement functions
func move_cards():
	#move the selected cards
	if pile_id == null:
		position = get_global_mouse_position()
		z_index = 100
		return
	
	#find selected cards
	var pile = GameManager.piles[pile_id]
	var current_card_index = pile.find(self)
	if len(pile) > current_card_index:
		#we need to move selected set of cards
		var cards_to_move = pile.slice(current_card_index, len(pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.position = get_global_mouse_position()
			
			#apply vertical width to separate multipule cards
			card.position.y += 30 * i
			
			#apply high z-index to make cards appear above other piles
			card.z_index = 100 + i

func drop_card():
	#if card is moved to a valid set, then we need to move it
	var overlapping_cards = get_overlapping_cards()
	for card in overlapping_cards:
		#need to detect other cards
		if check_valid_move(card):
			move_to_new_pile(card)
			return true
	#if cards cannot be moved, we reset the state
	return false

func remember_card_position():
	#stock cards are not a part of pile
	previous_positions = []
	
	if pile_id == null:
		position = previous_positions[0]['position']
		z_index = 1
	else:	
		
		var pile = GameManager.piles[pile_id]
		var current_card_index = pile.find(self)
		if len(pile) > current_card_index:
			#we need to move selected set of cards
			var cards_to_move = pile.slice(current_card_index, len(pile))
			for card in cards_to_move:
				previous_positions.append({
					"position": card.position
				})

func reset_cards():
	var pile = GameManager.piles[pile_id]
	var current_card_index = pile.find(self)
	if len(pile) > current_card_index:
		#we need to reset selected set of cards
		var cards_to_move = pile.slice(current_card_index, len(pile))
		for i in range(len(previous_positions)):
			var card = cards_to_move[i]
			card.position = previous_positions[i]["position"]
			card.z_index = pile[current_card_index - 1].z_index + i + 1
	previous_positions = []

func _on_area_2d_mouse_exited() -> void:
	is_mouse_entered = false


func _on_area_2d_mouse_entered() -> void:
	is_mouse_entered = true
