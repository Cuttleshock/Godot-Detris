extends Node


signal scores_updated
signal lines_updated
signal level_updated


const LINE_SCORES := PoolIntArray([
	0,
	100,
	300,
	600,
	1000,
])

export var points_harddrop := 10
export var lines_per_level := 10

var current_score := 0 setget set_score
var current_level := 1
var current_lines := 0 setget set_lines
var high_score := 0

var title_scene : PackedScene = preload("res://TitleScreen.tscn")
var game_scene : PackedScene = preload("res://Playfield.tscn")


func _init() -> void:
	randomize()
	reset()


func reset() -> void:
	set_score(0)
	set_lines(0)
	current_level = 1


func increment_score(points : int) -> void:
	set_score(current_score + points)


func increment_lines(lines : int) -> void:
	set_lines(current_lines + lines)


func set_score(score_ : int) -> void:
	current_score = score_
	if current_score > high_score:
		high_score = current_score
	emit_signal("scores_updated")


func set_lines(lines_ : int) -> void:
	current_lines = lines_
	emit_signal("lines_updated")
	# warning-ignore: INTEGER_DIVISION
	var target_level = current_lines / lines_per_level
	if target_level > current_level:
		current_level = target_level
		emit_signal("level_updated")


func _on_Matrix_hard_dropped() -> void:
	increment_score(points_harddrop)


func _on_Matrix_lines_cleared(lines : int) -> void:
	assert(lines <= LINE_SCORES.size() - 1, "Unexpected number of lines cleared: %d" % lines)
	increment_score(current_level * LINE_SCORES[lines])
	increment_lines(lines)


func _on_TitleScreen_game_started() -> void:
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(game_scene)


func _on_Matrix_game_lost() -> void:
	reset()
	# warning-ignore: RETURN_VALUE_DISCARDED
	get_tree().change_scene_to(title_scene)
