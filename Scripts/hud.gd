class_name HUD extends Control
## Mostra os cafés coletados e a fase atual na barra azul do topo,
## e os avisos (LEVEL, BOSS INCOMING!) no meio da tela.

@onready var coffe_couter: Label = $coffe_couter
@onready var fase_label: Label = $fase_label
@onready var aviso_label: Label = $aviso_label

var tween_aviso: Tween


func _ready() -> void:
	aviso_label.hide()
	_atualizar()


func _process(_delta: float) -> void:
	_atualizar()


func _atualizar() -> void:
	coffe_couter.text = "%04d" % Globals.coffe
	fase_label.text = "LEVEL %d" % Globals.fase


# Mostra um texto piscando no meio da tela por alguns segundos
func mostrar_aviso(texto: String, cor: Color = Color.WHITE, duracao: float = 2.0) -> void:
	if tween_aviso:
		tween_aviso.kill()
	aviso_label.text = texto
	aviso_label.modulate = cor
	aviso_label.show()
	tween_aviso = create_tween()
	var piscadas := int(duracao / 0.5)
	for i in piscadas:
		tween_aviso.tween_property(aviso_label, "modulate:a", 0.2, 0.25)
		tween_aviso.tween_property(aviso_label, "modulate:a", 1.0, 0.25)
	tween_aviso.tween_callback(aviso_label.hide)


func _on_fase_mudou(numero: int) -> void:
	mostrar_aviso("LEVEL %d" % numero, Color(1, 0.9, 0.3))


func _on_chefe_chegando() -> void:
	mostrar_aviso("BOSS INCOMING!", Color(1, 0.35, 0.3))
