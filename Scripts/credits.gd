class_name Credits extends Control


# Direciona o jogador de volta para a tela de menu
func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Prefabs/menu.tscn")
