class_name AudioMenu extends AudioStreamPlayer


# Faz a música tocar em loop na tela de menu
func _on_finished() -> void:
	play()
