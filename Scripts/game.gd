class_name Game extends Control
## Script da cena principal do jogo (play_game.tscn)
## Liga os avisos do Spawner (fases) e do Boss ao HUD.

@onready var spawner: Spawner = $Level/Spawner
@onready var boss: Boss = $Level/Boss
@onready var hud: HUD = $HUD/control


func _ready() -> void:
	# Zera a pontuação toda vez que uma partida começa
	Globals.reiniciar()
	spawner.fase_mudou.connect(hud._on_fase_mudou)
	boss.chegando.connect(hud._on_chefe_chegando)
