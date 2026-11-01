class_name Ranking extends Control
## Tela do ranking: mostra os 10 melhores (nome, cafés e fase).
## Quem acabou de entrar fica piscando.

const CORES_PODIO := [Color(1, 0.84, 0.2), Color(0.8, 0.85, 0.9), Color(0.85, 0.55, 0.3)] # Ouro, prata, bronze

@onready var tabela: GridContainer = $Conteudo/Tabela
@onready var fonte: Font = preload("res://Assets/font/m04b.TTF")


func _ready() -> void:
	_cabecalho()
	for i in Globals.MAX_RANKING:
		var linha: Array[Label] = []
		if i < Globals.ranking.size():
			var e: Dictionary = Globals.ranking[i]
			linha.append(_celula("%d" % (i + 1), HORIZONTAL_ALIGNMENT_RIGHT))
			linha.append(_celula(e["nome"]))
			linha.append(_celula("%04d" % e["cafes"], HORIZONTAL_ALIGNMENT_RIGHT))
			linha.append(_celula("%d" % e["fase"], HORIZONTAL_ALIGNMENT_RIGHT))
		else:
			# Posição vazia
			linha.append(_celula("%d" % (i + 1), HORIZONTAL_ALIGNMENT_RIGHT))
			linha.append(_celula("---"))
			linha.append(_celula("----", HORIZONTAL_ALIGNMENT_RIGHT))
			linha.append(_celula("-", HORIZONTAL_ALIGNMENT_RIGHT))

		# Cores do pódio (1º, 2º e 3º lugar)
		if i < CORES_PODIO.size() and i < Globals.ranking.size():
			for c in linha:
				c.add_theme_color_override("font_color", CORES_PODIO[i])

		# Quem acabou de entrar no ranking fica piscando
		if i == Globals.ultima_posicao:
			for c in linha:
				_piscar(c)

	Globals.ultima_posicao = -1


func _cabecalho() -> void:
	for texto in ["", "NAME", "CAFES", "LV"]:
		var c := _celula(texto, HORIZONTAL_ALIGNMENT_RIGHT if texto != "NAME" else HORIZONTAL_ALIGNMENT_LEFT)
		c.add_theme_color_override("font_color", Color(0.55, 0.75, 1))


func _celula(texto: String, alinhamento := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = texto
	label.horizontal_alignment = alinhamento
	label.add_theme_font_override("font", fonte)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabela.add_child(label)
	return label


func _piscar(label: Label) -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(label, "modulate:a", 0.2, 0.35)
	tween.tween_property(label, "modulate:a", 1.0, 0.35)


func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/play_game.tscn")


func _on_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Prefabs/menu.tscn")
