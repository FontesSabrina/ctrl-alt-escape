class_name Boss extends Area2D
## O chefe fica escondido a maior parte do tempo.
## De tempos em tempos: avisa que está chegando, entra pela borda da tela
## mais longe do jogador, persegue por alguns segundos e depois vai embora.

signal chegando # Avisa o HUD para mostrar "BOSS INCOMING!"
signal foi_embora

enum Estado { ESCONDIDO, AVISO, PERSEGUINDO, SAINDO }

@export var speed: float = 70.0 # Velocidade perseguindo o jogador
@export var speed_saida: float = 140.0 # Velocidade indo embora
@export var primeira_aparicao: float = 25.0 # Segundos até a primeira visita
@export var intervalo_min: float = 20.0 # Tempo mínimo entre uma visita e outra
@export var intervalo_max: float = 35.0 # Tempo máximo entre uma visita e outra
@export var tempo_aviso: float = 2.0 # Tempo do aviso antes de ele entrar
@export var tempo_perseguindo: float = 8.0 # Quanto tempo ele persegue

var estado := Estado.ESCONDIDO
var cronometro := 0.0
var destino_saida := Vector2.ZERO
var target: Node2D = null # Referência ao jogador


func _ready() -> void:
	target = get_parent().get_node_or_null("Jogador")
	_esconder()
	cronometro = primeira_aparicao


func _process(delta: float) -> void:
	match estado:
		Estado.ESCONDIDO:
			cronometro -= delta
			if cronometro <= 0:
				estado = Estado.AVISO
				cronometro = tempo_aviso
				chegando.emit()

		Estado.AVISO:
			cronometro -= delta
			if cronometro <= 0:
				_entrar()

		Estado.PERSEGUINDO:
			if is_instance_valid(target):
				# Move o Boss em direção ao jogador
				var direction := global_position.direction_to(target.global_position)
				global_position += direction * speed * delta
			cronometro -= delta
			if cronometro <= 0:
				estado = Estado.SAINDO
				destino_saida = _borda_mais_proxima()

		Estado.SAINDO:
			global_position = global_position.move_toward(destino_saida, speed_saida * delta)
			if global_position.distance_to(destino_saida) < 1.0:
				_esconder()
				cronometro = randf_range(intervalo_min, intervalo_max)
				foi_embora.emit()


# Some da tela e para de colidir
func _esconder() -> void:
	estado = Estado.ESCONDIDO
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)


# Aparece fora da tela, na borda mais longe do jogador, e começa a perseguir
func _entrar() -> void:
	var tela := get_viewport_rect().size
	var opcoes := [
		Vector2(-30, randf_range(80, tela.y - 40)), # Esquerda
		Vector2(tela.x + 30, randf_range(80, tela.y - 40)), # Direita
		Vector2(randf_range(30, tela.x - 30), tela.y + 30), # Embaixo
	]
	var melhor: Vector2 = opcoes[0]
	if is_instance_valid(target):
		for p in opcoes:
			if p.distance_to(target.global_position) > melhor.distance_to(target.global_position):
				melhor = p
	global_position = melhor

	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	estado = Estado.PERSEGUINDO
	cronometro = tempo_perseguindo


# Ponto fora da tela mais perto do chefe (por onde ele vai sair)
func _borda_mais_proxima() -> Vector2:
	var tela := get_viewport_rect().size
	var p := global_position
	var distancias := {
		"esquerda": p.x,
		"direita": tela.x - p.x,
		"baixo": tela.y - p.y,
	}
	var lado: String = distancias.keys()[0]
	for k in distancias:
		if distancias[k] < distancias[lado]:
			lado = k
	match lado:
		"esquerda":
			return Vector2(-40, p.y)
		"direita":
			return Vector2(tela.x + 40, p.y)
		_:
			return Vector2(p.x, tela.y + 40)


# Colisão com jogador
func _on_area_entered(area: Area2D) -> void:
	if estado == Estado.PERSEGUINDO and area is Jogador:
		Globals.game_over()
