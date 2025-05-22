extends Node2D

signal flipped_changed(is_flipped)

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

@export var start_flipped := true
@export var auto_load_textures := true

var pile_id = null #keep track of what pile the card is in
var stock:bool = false #keep track of whether the card is in the stock pile
var is_mouse_entered:bool = false
var is_dragging:bool = false
var previous_positions = []
var drag_offset

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
	elif Input.is_action_just_pressed("left_click"):
		var top_card = check_for_card()
		
		#change stock
		if stock:
			update_stock_on_top()
			return
		
		if top_card == self and (not is_flipped):
			is_dragging = true
			drag_offset = Vector2(0, get_global_mouse_position().y - global_position.y)
			#to return cards to normal position
			remember_card_position()
	
	elif event is InputEventMouseMotion and is_dragging:
		move_cards()
	
	elif Input.is_action_just_released("left_click") and is_dragging:
		is_dragging = false
		if !drop_card():
			reset_cards()

func update_stock_on_top():
	var cur_stock_top = GameManager.deck.pop_back()
	cur_stock_top.flip()
	cur_stock_top.stock = true
	var pos = cur_stock_top.position
	cur_stock_top.position = GameManager.deck[0].position
	cur_stock_top.z_index = 100
	
	GameManager.deck.insert(0, cur_stock_top)
	
	if len(GameManager.deck) > 0:
		var new_card = GameManager.deck[-1]
		new_card.stock = false
		new_card.z_index = -1
		new_card.flip()
		new_card.position = pos

#To check if we are clicking on the card
func check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#print(get_card_on_top(result).rank)
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
		
	#for i in range(result.size()):
		#var card_slot = result[i].collider.get_parent()
		#print(card_slot.is_in_group("cardslot"))
		#if card_slot.is_in_group("cardslot"): #if it is a card slot not a card
			#return card_slot
	return null

func get_card_on_top(cards):
	#assume first card in array is the one on top
	var highest_card = cards[0].collider.get_parent()
	var highest_index = highest_card.z_index
	
	for i in range(cards.size()):
		var card = cards[i].collider.get_parent()
		#empty cards from each pile keep entering the array
		if card.pile_id != self.pile_id:
			continue
		
		if stock:
			return card
		elif card.is_flipped:
			continue
		
		if card.rank == "" and card.suit == "":
			continue
	
		#loop through each card to find the top card
		if (card.z_index > highest_index):
			highest_card = card
			highest_index = card.z_index
		return highest_card

func update_texture():
	if sprite:
		sprite.texture = back_texture if is_flipped else front_texture

func flip():
	is_flipped = not is_flipped

func load_texture():
	if (rank == "" and suit == ""): return null
	
	var path = "res://assets/Cards/%s_of_%s.png" % [rank.to_lower(), suit.to_lower()]
	return load(path)

func check_valid_move(card):
	if card.pile_id == null or card.pile_id == pile_id:
		return false
	
	#if card.rank == "" and card.suit == "":
		#return false
	
	var pile = GameManager.piles[card.pile_id]
	
	#empty pile
	if len(pile) == 1 and (pile[0].rank == "" and  pile[0].suit == ""):
		return true
	
	#dont place cards on top of flipped cards
	if card.is_flipped:
		return false
	
	if CardDatabase.is_in_sequence(pile[-1], self):
		return true

func move_to_new_pile(new_card):
	if pile_id != null:
		var current_pile = GameManager.piles[pile_id]
		var current_card_index = current_pile.find(self)
		
		var new_pile =  GameManager.piles[new_card.pile_id]
		
		#move cards to new pile
		var cards_to_move = current_pile.slice(current_card_index, len(current_pile))
		for i in range(len(cards_to_move)):
			var card = cards_to_move[i]
			card.pile_id = new_card.pile_id
			card.position = GameManager.get_pile_position(
				# -1 cause of the empty card
				new_card.pile_id, len(new_pile) - 1,
				GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET
			)
			card.z_index = new_pile[-1].z_index + 1
			new_pile.append(card)
			
		#print("Moving to pile :", new_card.pile_id, " New pile len before :", len(new_pile))
		
		#remove the top cards from old pile
		for i in range(len(cards_to_move)):
			current_pile.pop_back()
		
		#flip top most card of previous pile after moving
		if len(current_pile) > 1:
			if current_pile.back().is_flipped == true:
				current_pile.back().flip()
		
		#var descriptions = []
		#for cards in GameManager.piles[0]:
			#if cards.rank == "" and cards.suit == "":
				#descriptions.append("Empty card")
			#else:
				#descriptions.append(cards.rank + " of " + cards.suit)
		#print(", ".join(descriptions) )
	
	#move from stock
	elif pile_id == null:
		var new_pile = GameManager.piles[new_card.pile_id]
		var card = GameManager.deck.pop_back()
		card.stock = false
		card.position = GameManager.get_pile_position(
			# -1 cause of the empty card
			new_card.pile_id, len(new_pile) - 1,
			GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET
		)
		card.z_index = new_pile[-1].z_index + 1
		card.pile_id = new_card.pile_id
		new_pile.append(card)
		
		#flip card in the stock
		var card_on_stock = GameManager.deck.pop_back()
		card_on_stock.stock = false
		new_card.z_index = -1
		card_on_stock.flip()
		card_on_stock.position = GameManager.get_pile_position(
			0, 0,  GameManager.PILE_X_OFFSET - 300, GameManager.PILE_Y_OFFSET + 300
		)
	
	previous_positions = []
	if check_win():
		print("YOU WON!!")


func check_win():
	if len(GameManager.deck) > 0:
		return false
	
	for pile in GameManager.piles:
		for card in pile:
			if not card.is_flipped:
				return false
	
	return true

#has to check for empty cards too
func get_overlapping_cards() -> Array:
	var card_set := {}
	for card in $Area2D.get_overlapping_areas():
		card = card.get_parent()
		if not card.is_flipped:
			card_set[card] = true
	
	return card_set.keys()

#### mouse movement functions
func move_cards():
	#move the selected cards
	if pile_id == null or (rank == "" and suit == ""):
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
			card.position = get_global_mouse_position() - drag_offset
			
			#apply vertical width to separate multipule cards
			card.position.y += 40 * i
			
			#apply high z-index to make cards appear above other piles
			card.z_index = 100 + i

func drop_card():
	var overlapping_cards = get_overlapping_cards()
	var card_slot = check_for_card_slot()
	
	if card_slot:
		if add_card_to_slot(card_slot):
			return true
		else:
			return false
	else:
		for card in overlapping_cards:
			if check_valid_move(card):
				move_to_new_pile(card)
				return true
	
	#if cards cannot be moved, we reset the state
	return false

func add_card_to_slot(card_slot):
	#if card is moved to a valid set, then we need to move it
	var isEmpty = card_slot.cards.is_empty()
	var final_card = null if isEmpty else card_slot.cards.back() 
	
	var is_valid_move:bool = false
	if isEmpty and rank == "Ace":
		is_valid_move = true
	elif final_card != null and (CardDatabase.ascending_order(final_card, self)) \
		and CardDatabase.same_suit(self, final_card):
		is_valid_move = true
	
	if is_valid_move:
		if self == GameManager.deck.back():
			GameManager.deck.pop_back()
			stock = false
			position = card_slot.position
			z_index = 5
			card_slot.cards.append(self)
			
			if len(GameManager.deck) > 0:
				var new_card = GameManager.deck[-1]
				new_card.stock = true
				new_card.z_index = -1
				new_card.flip()
				new_card.position = GameManager.get_pile_position(
					0, 0,  GameManager.PILE_X_OFFSET - 300, GameManager.PILE_Y_OFFSET + 300
				)
		else:
			var pile = GameManager.piles[pile_id]
			var card = pile.pop_back()
			
			#remove itself from the pile
			if pile.has(card):
				pile.erase(card)
			
			#stock = false
			position = card_slot.position
			z_index = 5
			card_slot.cards.append(self)
			get_node("Area2D/CollisionShape2D").disabled = true
			
			#flip top most card of previous pile after moving
			if len(pile) > 1:
				if pile.back().is_flipped == true:
					pile.back().flip()
			
		return true
	else:
		return false

func remember_card_position():
	#stock cards are not a part of pile
	previous_positions = []
	
	if pile_id == null:
		previous_positions.append({"position":position})
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
	if pile_id == null:
		#we need to reset selected set of cards
		var card = GameManager.deck[-1]
		card.position = previous_positions[0]["position"]
	
	else:
		var pile = GameManager.piles[pile_id]
		var current_card_index = pile.find(self)
		if current_card_index == 0: return
		
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
