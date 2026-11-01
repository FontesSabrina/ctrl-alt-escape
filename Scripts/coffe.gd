class_name Coffe extends Area2D

signal collected # Sinal emitido quando o café é coletado

# Caminho da cena do café. Usa load() e não preload(), porque a cena usa este
# mesmo script e o preload criava uma referência circular.
const CENA_CAFE := "res://Prefabs/coffe.tscn"

@export var margin: float = 30.0 # Margem para o café não nascer colado nas bordas
@export var limite_topo: float = 45.0 # Não nascer em cima do contador
@export var distancia_jogador: float = 50.0 # Não nascer em cima do jogador

var coletado := false # Evita contar o mesmo café duas vezes


# Gera um café novo em um local aleatório
func spawn_new_coffee() -> void:
	var new_coffee: Node2D = load(CENA_CAFE).instantiate()
	var tela := get_viewport_rect().size
	var jogador := get_parent().get_node_or_null("Jogador") as Node2D

	var posicao := Vector2.ZERO
	for tentativa in 10:
		posicao = Vector2(
			randf_range(margin, tela.x - margin),
			randf_range(limite_topo, tela.y - margin)
		)
		if jogador == null or posicao.distance_to(jogador.position) > distancia_jogador:
			break

	new_coffee.position = posicao
	# Adicionar uma Area2D durante uma colisão dá erro na física,
	# por isso o call_deferred (adiciona no fim do frame)
	get_parent().call_deferred("add_child", new_coffee)


func _on_area_entered(area: Area2D) -> void:
	if coletado:
		return
	if area is Jogador: # Só o jogador coleta (obstáculos e o chefe não)
		coletado = true
		Globals.coffe += 1 # Adiciona 1 ao total global
		collected.emit()
		spawn_new_coffee()
		queue_free() # Remove o café atual
