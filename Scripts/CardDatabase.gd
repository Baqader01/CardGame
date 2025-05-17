const RANK = ["King", "Queen", "Jack", "10", "9", "8", "7", "6", "5", "4", "3", "2", "Ace"];
const SUIT = ["Hearts", "Diamonds", "Clubs", "Spades"];

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

func is_one_rank_higher(card_a, card_b):
	var index_a = RANK.find(card_a.rank)
	var index_b = RANK.find(card_b.rank)

	# Check if card_a is exactly one rank higher than card_b
	return index_a == index_b - 1

func is_opposite_suit(card_a, card_b) -> bool:
	# Define which suits are considered opposites
	const RED_SUITS = ["Hearts", "Diamonds"]
	const BLACK_SUITS = ["Clubs", "Spades"]
	
	# Check if one card is red and the other is black
	return (card_a.suit in RED_SUITS and card_b.suit in BLACK_SUITS) or \
		   (card_a.suit in BLACK_SUITS and card_b.suit in RED_SUITS)
