class_name AudioCredits extends AudioStreamPlayer


# Faz a música tocar em loop na tela de créditos
func _on_finished() -> void:
	play()
