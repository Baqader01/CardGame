extends Node2D

const RANK = ["King", "Queen", "Jack", "10", "9", "8", "7", "6", "5", "4", "3", "2", "Ace"];
const SUIT = ["Hearts", "Diamonds", "Clubs", "Spades"];

const RED_SUITS = ["Hearts", "Diamonds"]
const BLACK_SUITS = ["Clubs", "Spades"]

func compare_cards_by_rank(card_a, card_b):
	var rank_a = card_a.rank  # card's rank property, e.g. "Ace", "2", etc.
	var rank_b = card_b.rank

	var index_a = RANK.find(rank_a)
	var index_b = RANK.find(rank_b)

	if index_a < index_b:
		return -1
	elif index_a > index_b:
		return 1
	else:
		return 0

func is_in_sequence(card_a, card_b) -> bool:
	var previous_card_index = card_index(card_a)
	var card_index = card_index(card_b)
	
	var opposite_suit = (card_a.suit in RED_SUITS and card_b.suit in BLACK_SUITS) or \
		   (card_a.suit in BLACK_SUITS and card_b.suit in RED_SUITS)
	
	#one more in value and opposite suit
	if ((previous_card_index + 1) == card_index) and opposite_suit:
		return true
	
	return false

func card_index(card):
	return RANK.find(card.rank)
