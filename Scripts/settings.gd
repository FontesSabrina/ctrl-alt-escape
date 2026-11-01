class_name Settings extends Control
## Tela de configurações: liga/desliga música, volume e tela cheia.
## Tudo é salvo automaticamente pelo Globals.

const PASSO_VOLUME := 0.1 # Quanto o volume muda a cada clique no DOWN ou UP

@onready var musica_btn: Button = $MarginContainer/VBoxContainer/musica_btn
@onready var volume_label: Label = $MarginContainer/VBoxContainer/volume_label
@onready var menos_btn: Button = $MarginContainer/VBoxContainer/volume_box/menos_btn
@onready var mais_btn: Button = $MarginContainer/VBoxContainer/volume_box/mais_btn
@onready var tela_cheia_btn: Button = $MarginContainer/VBoxContainer/tela_cheia_btn


func _ready() -> void:
	# No celular não existe "janela", então esconde o botão de tela cheia
	if OS.has_feature("mobile") or OS.has_feature("web"):
		tela_cheia_btn.hide()
	_atualizar_textos()


func _atualizar_textos() -> void:
	musica_btn.text = "MUSIC ON" if Globals.musica_ligada else "MUSIC OFF"
	volume_label.text = "VOLUME %d" % roundi(Globals.volume_musica * 100)
	tela_cheia_btn.text = "FULLSCREEN ON" if Globals.tela_cheia else "FULLSCREEN OFF"
	# Sem música, os botões de volume ficam desativados
	menos_btn.disabled = not Globals.musica_ligada or Globals.volume_musica <= 0.0
	mais_btn.disabled = not Globals.musica_ligada or Globals.volume_musica >= 1.0


func _mudou() -> void:
	Globals.aplicar_config()
	Globals.salvar_config()
	_atualizar_textos()


func _on_musica_btn_pressed() -> void:
	Globals.musica_ligada = not Globals.musica_ligada
	_mudou()


func _on_menos_btn_pressed() -> void:
	Globals.volume_musica = clampf(snappedf(Globals.volume_musica - PASSO_VOLUME, 0.1), 0.0, 1.0)
	_mudou()


func _on_mais_btn_pressed() -> void:
	Globals.volume_musica = clampf(snappedf(Globals.volume_musica + PASSO_VOLUME, 0.1), 0.0, 1.0)
	_mudou()


func _on_tela_cheia_btn_pressed() -> void:
	Globals.tela_cheia = not Globals.tela_cheia
	_mudou()


# Volta para o menu
func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Prefabs/menu.tscn")
