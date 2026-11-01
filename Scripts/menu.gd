class_name MainMenu extends Control


func _ready() -> void:
	# No navegador não dá para "fechar" o jogo, então o botão QUIT some
	if OS.has_feature("web"):
		$MarginContainer/HBoxContainer/VBoxContainer/quit_btn.hide()
		$MarginContainer/HBoxContainer/VBoxContainer/HSeparator.hide()


# Linka o botão Start para a tela do jogo
func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/play_game.tscn")


# Linka o botão Ranking para a tela com os melhores jogadores
func _on_ranking_btn_pressed() -> void:
	Globals.ultima_posicao = -1
	get_tree().change_scene_to_file("res://Scenes/ranking.tscn")


# Linka o botão Credits para a tela de créditos
func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")


# Linka o botão Settings para a tela de configurações
func _on_settings_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")


# Linka o botão Quit para o fechamento do jogo
func _on_quit_btn_pressed() -> void:
	get_tree().quit()
