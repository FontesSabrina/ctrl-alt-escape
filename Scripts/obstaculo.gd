class_name Obstaculo extends Area2D
## Objeto que cai do topo da tela (pasta, hora extra, telefone, dinheiro).
## Ele só cai e mata o jogador; quem cria os objetos é o Spawner.

# Velocidade de queda (pode mudar em cada cena pelo Inspetor)
@export var speed: float = 100.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position.y += speed * delta

	# Remove o objeto quando ele sai por baixo da tela
	if position.y > get_viewport_rect().size.y + 40:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Se o jogador colidir com o objeto, vai para a cena de game over
	if area is Jogador:
		Globals.game_over()
