class_name GameOver extends Control
# Script da cena de game over.
# Se a partida entrou no ranking, mostra "NEW RECORD!" e a escolha do nome
# no estilo fliperama: 3 letras, trocadas com as setinhas.

const TAMANHO_NOME := 3 # Quantas letras tem o nome (no arcade eram 3)
const LETRAS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?" # Letras que dá para escolher
const SETA_CIMA := preload("res://Assets/ui/seta_cima.png")
const SETA_BAIXO := preload("res://Assets/ui/seta_baixo.png")

@onready var pontuacao: Label = $Pontuacao
@onready var botoes: VBoxContainer = $Botoes
@onready var nome_box: VBoxContainer = $NomeBox
@onready var slots: HBoxContainer = $NomeBox/Slots
@onready var titulo_recorde: Label = $NomeBox/NovoRecorde

var indices: Array[int] = [] # Qual letra está em cada posição do nome
var letra_botoes: Array[Button] = [] # Botões que mostram as letras
var slot_atual := 0 # Qual letra está selecionada
var tween_piscar: Tween


func _ready() -> void:
	# Mostra quantos cafés o jogador pegou e até qual fase chegou.
	# (A pontuação é zerada quando a partida começa, e não aqui,
	# senão ela sumia antes de aparecer na tela.)
	pontuacao.text = "CAFES %04d\nLEVEL %d" % [Globals.coffe, Globals.fase]

	if Globals.entra_no_ranking():
		botoes.hide()
		nome_box.show()
		_montar_slots()
		_piscar_titulo()
	else:
		nome_box.hide()
		botoes.show()


# ---------- Escolha do nome ----------

func _montar_slots() -> void:
	# Começa com o último nome usado (fica mais rápido jogar de novo)
	var nome_inicial := Globals.ultimo_nome.rpad(TAMANHO_NOME, "A")
	for i in TAMANHO_NOME:
		var indice := maxi(LETRAS.find(nome_inicial[i]), 0)
		indices.append(indice)

		var coluna := VBoxContainer.new()
		coluna.add_theme_constant_override("separation", 2)

		var cima := _criar_botao_seta(SETA_CIMA)
		cima.pressed.connect(_mudar_letra.bind(i, 1))
		coluna.add_child(cima)

		var letra := Button.new()
		letra.custom_minimum_size = Vector2(34, 34)
		letra.focus_mode = Control.FOCUS_NONE
		letra.add_theme_font_size_override("font_size", 21)
		letra.pressed.connect(_selecionar.bind(i))
		coluna.add_child(letra)
		letra_botoes.append(letra)

		var baixo := _criar_botao_seta(SETA_BAIXO)
		baixo.pressed.connect(_mudar_letra.bind(i, -1))
		coluna.add_child(baixo)

		slots.add_child(coluna)
	_atualizar_letras()


func _criar_botao_seta(icone: Texture2D) -> Button:
	var botao := Button.new()
	botao.icon = icone
	botao.flat = true
	botao.focus_mode = Control.FOCUS_NONE # Para as setas do teclado não mexerem no foco
	botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botao.custom_minimum_size = Vector2(34, 18)
	return botao


func _mudar_letra(slot: int, direcao: int) -> void:
	slot_atual = slot
	indices[slot] = wrapi(indices[slot] + direcao, 0, LETRAS.length())
	_atualizar_letras()


func _selecionar(slot: int) -> void:
	# Clicar na letra seleciona ela; clicar de novo passa para a próxima letra do alfabeto
	if slot == slot_atual:
		_mudar_letra(slot, 1)
	else:
		slot_atual = slot
		_atualizar_letras()


func _atualizar_letras() -> void:
	for i in letra_botoes.size():
		letra_botoes[i].text = LETRAS[indices[i]]
		# A letra selecionada fica amarela
		var cor := Color(1, 0.85, 0.2) if i == slot_atual else Color(1, 1, 1)
		letra_botoes[i].add_theme_color_override("font_color", cor)
		letra_botoes[i].add_theme_color_override("font_hover_color", cor)
		letra_botoes[i].add_theme_color_override("font_pressed_color", cor)


func _nome_escolhido() -> String:
	var nome := ""
	for i in indices:
		nome += LETRAS[i]
	return nome


func _piscar_titulo() -> void:
	tween_piscar = create_tween().set_loops()
	tween_piscar.tween_property(titulo_recorde, "modulate:a", 0.3, 0.4)
	tween_piscar.tween_property(titulo_recorde, "modulate:a", 1.0, 0.4)


# Teclado: digitar a letra, setas para trocar/andar, Enter para confirmar
func _input(event: InputEvent) -> void:
	if not nome_box.visible or not (event is InputEventKey) or not event.pressed:
		return

	var tecla: Key = event.keycode
	var caractere := char(event.unicode).to_upper() if event.unicode > 0 else ""

	if tecla == KEY_ENTER or tecla == KEY_KP_ENTER:
		# Marca a tecla como usada ANTES de trocar de cena
		get_viewport().set_input_as_handled()
		_on_ok_pressed()
		return
	elif tecla == KEY_UP:
		_mudar_letra(slot_atual, 1)
	elif tecla == KEY_DOWN:
		_mudar_letra(slot_atual, -1)
	elif tecla == KEY_LEFT or tecla == KEY_BACKSPACE:
		slot_atual = maxi(slot_atual - 1, 0)
		_atualizar_letras()
	elif tecla == KEY_RIGHT:
		slot_atual = mini(slot_atual + 1, TAMANHO_NOME - 1)
		_atualizar_letras()
	elif caractere != "" and LETRAS.contains(caractere):
		# Digitou uma letra: coloca no lugar e pula para a próxima
		indices[slot_atual] = LETRAS.find(caractere)
		slot_atual = mini(slot_atual + 1, TAMANHO_NOME - 1)
		_atualizar_letras()
	else:
		return
	get_viewport().set_input_as_handled()


func _on_ok_pressed() -> void:
	if not nome_box.visible:
		return
	Globals.adicionar_ao_ranking(_nome_escolhido())
	nome_box.hide() # Evita salvar duas vezes
	get_tree().change_scene_to_file("res://Scenes/ranking.tscn")


# ---------- Botões ----------

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/play_game.tscn")


func _on_ranking_pressed() -> void:
	Globals.ultima_posicao = -1 # Ninguém novo para piscar
	get_tree().change_scene_to_file("res://Scenes/ranking.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
