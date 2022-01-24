extends Node


var pronunciations = {}


func _ready():
	var file = File.new()
	file.open("res://words-json.txt", File.READ)
	var json = file.get_as_text()
	file.close()
	pronunciations = JSON.parse(json).result

func get_word_pronounciation(word: String):
	return pronunciations.get(word.to_upper())

func word_exists(word):
	return pronunciations.has(word.to_upper())

func check_rhyme(word1, word2):
#	print(get_word_pronounciation(word1))
#	print(get_word_pronounciation(word2))
	return get_word_pronounciation(word1) == get_word_pronounciation(word2)

func check_first_letter_equal(word1, word2):
	return word1.left(1).to_upper() == word2.left(1).to_upper()

func is_word1_good(word1, word2):
	if Global.game_state.serving == true:
		return check_first_letter_equal(word1, word2)
	else:
		return check_rhyme(word1, word2)
