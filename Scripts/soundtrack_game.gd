class_name AudioGame extends AudioStreamPlayer


# Faz a música tocar em loop na tela do jogo
func _on_finished() -> void:
	play()
