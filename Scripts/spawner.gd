class_name Spawner extends Node2D
## Cria os obstáculos no topo da tela, em FASES que mudam com o tempo.
## O jogo começa calmo (só pastas, devagar) e a cada fase entra um objeto novo,
## os objetos caem mais rápido e aparecem com mais frequência.

signal fase_mudou(numero: int) # Avisa o HUD quando sobe de fase

# Cenas dos obstáculos NA ORDEM em que vão sendo liberados
# (0 = pasta, 1 = hora extra, 2 = telefone, 3 = dinheiro)
@export var cenas: Array[PackedScene] = []

@export var espera_inicial: float = 3.0 # Segundos de calma antes do primeiro objeto
@export var duracao_fase: float = 20.0 # Segundos para subir de fase
@export var distancia_minima: float = 32.0 # Distância mínima entre objetos que acabaram de nascer
@export var margem: float = 16.0 # Não nascer cortado na lateral da tela
@export var altura_inicial: float = -32.0 # Nasce um pouco acima da tela

# Tabela das fases. Cada linha é uma fase:
#   objetos   = quantos tipos de objeto já foram liberados
#   intervalo = segundos entre um objeto e outro
#   velocidade = multiplica a velocidade de queda de cada objeto
#   maximo    = número máximo de objetos na tela ao mesmo tempo
# Depois da última fase, ela continua valendo até o fim.
var fases := [
	{"objetos": 1, "intervalo": 1.6, "velocidade": 1.0, "maximo": 3},  # Fase 1: só pastas
	{"objetos": 2, "intervalo": 1.3, "velocidade": 1.15, "maximo": 4}, # Fase 2: + hora extra
	{"objetos": 3, "intervalo": 1.1, "velocidade": 1.3, "maximo": 5},  # Fase 3: + telefone
	{"objetos": 4, "intervalo": 0.9, "velocidade": 1.45, "maximo": 6}, # Fase 4: + dinheiro
	{"objetos": 4, "intervalo": 0.7, "velocidade": 1.6, "maximo": 7},  # Fase 5
	{"objetos": 4, "intervalo": 0.55, "velocidade": 1.8, "maximo": 8}, # Fase 6 em diante
]

var tempo_jogo := 0.0 # Quanto tempo a partida já está rodando
var fase_atual := 0 # Índice na tabela (0 = fase 1)
var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(_spawn_objeto)
	add_child(timer)
	# Primeiro objeto só depois da espera inicial
	timer.start(espera_inicial)
	Globals.fase = 1


func _process(delta: float) -> void:
	tempo_jogo += delta
	Globals.tempo = tempo_jogo

	# Calcula em qual fase deveria estar pelo tempo de jogo
	var nova_fase := mini(int(tempo_jogo / duracao_fase), fases.size() - 1)
	if nova_fase != fase_atual:
		fase_atual = nova_fase
		Globals.fase = fase_atual + 1
		timer.wait_time = fases[fase_atual]["intervalo"]
		fase_mudou.emit(fase_atual + 1)


func _contar_objetos() -> int:
	var total := 0
	for child in get_children():
		if child is Obstaculo:
			total += 1
	return total


func _spawn_objeto() -> void:
	var fase: Dictionary = fases[fase_atual]
	# Depois do primeiro objeto, o timer passa a usar o intervalo da fase
	timer.wait_time = fase["intervalo"]

	if cenas.is_empty() or _contar_objetos() >= fase["maximo"]:
		return

	var largura := get_viewport_rect().size.x

	# Tenta achar uma posição que não fique em cima de outro objeto
	for tentativa in 10:
		var x := randf_range(margem, largura - margem)
		if _posicao_livre(x):
			# Sorteia só entre os objetos já liberados nesta fase
			var liberados := mini(fase["objetos"], cenas.size())
			var objeto: Obstaculo = cenas[randi() % liberados].instantiate()
			objeto.position = Vector2(x, altura_inicial)
			objeto.speed *= fase["velocidade"]
			add_child(objeto)
			return


func _posicao_livre(x: float) -> bool:
	for child in get_children():
		# Só compara com objetos que ainda estão perto do topo
		if child is Obstaculo and child.position.y < 80:
			if absf(child.position.x - x) < distancia_minima:
				return false
	return true
