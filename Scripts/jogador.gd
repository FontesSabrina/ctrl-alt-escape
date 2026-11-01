class_name Jogador extends Area2D
#criando o script do jogador
# O personagem anda sozinho e cada clique muda a direção.
# Ele tem sempre o mesmo tamanho: o objetivo é pegar cafés e desviar dos objetos.

# Define a velocidade de movimento do jogador
@export var velocidade: float = 120.0

# define o eixo que o jogador vai andar
var direcao_index := 0
# Movimento nas direções: cima, esquerda, baixo, direita respectivamente
var direcoes := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]

# Faixa do topo da tela ocupada pelo contador de café
@export var limite_topo: float = 30.0


# Inicializa a direção do jogador
func _ready() -> void:
	# O jogador começa se movendo para cima
	direcao_index = 0


# Atualiza a posição do jogador com base na direção atual
func _process(delta: float) -> void:
	position += direcoes[direcao_index] * velocidade * delta

	# Verifica se o jogador ultrapassou as bordas da tela
	var tela := get_viewport_rect().size
	if position.x < 0 or position.x > tela.x or position.y < limite_topo or position.y > tela.y:
		# Caso ultrapasse, vai para a tela de game over
		Globals.game_over()


func _input(event: InputEvent) -> void:
	# Só o clique ESQUERDO (ou toque na tela) muda a direção
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Muda a direção na ordem desejada (cima, esquerda, baixo, direita)
		direcao_index = (direcao_index + 1) % direcoes.size()
