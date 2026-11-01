extends Node
## Autoload "Globals" (registrado no project.godot em Projeto > Configurações > Globais).
## Guarda os dados que precisam sobreviver à troca de cena
## as configurações do jogo (música, volume, tela cheia) e o RANKING.

const CENA_GAME_OVER := "res://Scenes/game_over.tscn"
const ARQUIVO_CONFIG := "user://config.cfg" # Onde as configurações ficam salvas
const BUS_MUSICA := "Musica" # Canal de áudio das músicas (default_bus_layout.tres)
const ARQUIVO_RANKING := "user://ranking.cfg" # Onde o ranking fica salvo
const MAX_RANKING := 10 # Quantas pessoas aparecem no ranking

var coffe := 0 # Pontos acumulados (cafés coletados)
var fase := 1 # Fase atual da partida
var tempo := 0.0 # Segundos que o jogador sobreviveu (desempate no ranking)
var fim_de_jogo := false # Evita chamar o game over várias vezes no mesmo frame

# Ranking: lista de {"nome", "cafes", "fase", "tempo"}, do melhor para o pior
var ranking: Array = []
var ultimo_nome := "AAA" # Lembra o último nome digitado, para não ter que digitar de novo
var ultima_posicao := -1 # Posição de quem acabou de entrar (para piscar na tela de ranking)

# Configurações
var musica_ligada := true
var volume_musica := 0.8 # De 0.0 (mudo) a 1.0 (máximo)
var tela_cheia := false


func _ready() -> void:
	carregar_config()
	aplicar_config()
	carregar_ranking()


# Chamado quando uma partida nova começa
func reiniciar() -> void:
	coffe = 0
	fase = 1
	tempo = 0.0
	fim_de_jogo = false


# Vai para a tela de game over (de forma segura, fora do processamento da física)
func game_over() -> void:
	if fim_de_jogo:
		return
	fim_de_jogo = true
	get_tree().call_deferred("change_scene_to_file", CENA_GAME_OVER)


# ---------- Configurações ----------

# Aplica as configurações no jogo (áudio e janela)
func aplicar_config() -> void:
	var bus := AudioServer.get_bus_index(BUS_MUSICA)
	if bus != -1:
		AudioServer.set_bus_mute(bus, not musica_ligada or volume_musica <= 0.0)
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume_musica, 0.001)))

	# Tela cheia só faz sentido no computador (no celular já é tela cheia)
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		if tela_cheia:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Salva as configurações num arquivo, para lembrar da próxima vez que abrir o jogo
func salvar_config() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "musica_ligada", musica_ligada)
	config.set_value("audio", "volume_musica", volume_musica)
	config.set_value("video", "tela_cheia", tela_cheia)
	config.save(ARQUIVO_CONFIG)


func carregar_config() -> void:
	var config := ConfigFile.new()
	if config.load(ARQUIVO_CONFIG) != OK:
		return # Primeira vez abrindo o jogo: usa os valores padrão
	musica_ligada = config.get_value("audio", "musica_ligada", musica_ligada)
	volume_musica = config.get_value("audio", "volume_musica", volume_musica)
	tela_cheia = config.get_value("video", "tela_cheia", tela_cheia)


# ---------- Ranking ----------

# Quem pegou mais café fica na frente; se empatar, quem sobreviveu mais tempo
func _e_melhor(a: Dictionary, b: Dictionary) -> bool:
	if a["cafes"] != b["cafes"]:
		return a["cafes"] > b["cafes"]
	return a["tempo"] > b["tempo"]


# A partida que acabou de terminar entra no ranking?
func entra_no_ranking() -> bool:
	if coffe <= 0:
		return false # Precisa ter pegado pelo menos 1 café
	if ranking.size() < MAX_RANKING:
		return true
	return _e_melhor({"cafes": coffe, "tempo": tempo}, ranking[-1])


# Coloca a partida atual no ranking com o nome escolhido e devolve a posição (0 = primeiro)
func adicionar_ao_ranking(nome: String) -> int:
	var entrada := {"nome": nome, "cafes": coffe, "fase": fase, "tempo": snappedf(tempo, 0.1)}

	# Acha a posição certa (a lista já está em ordem)
	var posicao := ranking.size()
	for i in ranking.size():
		if _e_melhor(entrada, ranking[i]):
			posicao = i
			break
	ranking.insert(posicao, entrada)

	if ranking.size() > MAX_RANKING:
		ranking.resize(MAX_RANKING)

	ultimo_nome = nome
	ultima_posicao = posicao if posicao < MAX_RANKING else -1
	salvar_ranking()
	return ultima_posicao


func salvar_ranking() -> void:
	var arquivo := ConfigFile.new()
	arquivo.set_value("ranking", "lista", ranking)
	arquivo.set_value("ranking", "ultimo_nome", ultimo_nome)
	arquivo.save(ARQUIVO_RANKING)


func carregar_ranking() -> void:
	var arquivo := ConfigFile.new()
	if arquivo.load(ARQUIVO_RANKING) != OK:
		return # Ainda não existe ranking
	ranking = arquivo.get_value("ranking", "lista", [])
	ultimo_nome = arquivo.get_value("ranking", "ultimo_nome", ultimo_nome)
