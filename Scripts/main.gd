extends Node2D

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
@onready var generatedkey = $GeneratedKey
@onready var key = $EnterKey
@onready var playerCount = $Panel/Playercount
@onready var playerList = $Panel/Players
@onready var ms = $MultiplayerSpawner
var LOBBY_MEMBERS = []
var lid = 0

func _ready():
	ms.spawn_function = spawn_level
	$GeneratedKey.hide()
	peer.lobby_created.connect(_on_lobby_created)
	peer.lobby_joined.connect(_on_Lobby_Joined)
	
func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
	
func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	$GeneratedKey.show()
	$Host.hide()
	$Join.hide()
	$EnterKey.hide()
	
func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(generatedkey.text))
		Steam.setLobbyJoinable(lobby_id,true)
		get_Lobby_Members()
		generatedkey.text = str(lobby_id)

func _on_join_pressed():
	lobby_id = int(key.text)
	print(lobby_id)
	Steam.joinLobby(lobby_id)
	await get_tree().create_timer(.5).timeout
	get_Lobby_Members()
	
	
func _on_Lobby_Joined(id):
	lobby_id = id
	get_Lobby_Members()
	
func get_Lobby_Members():
	LOBBY_MEMBERS.clear()
	var MEMBERCOUNT = Steam.getNumLobbyMembers(lobby_id)
	playerCount.set_text("Players (" +str(MEMBERCOUNT) + ")")
	
	for MEMBER in range(0, MEMBERCOUNT):
		var MEMBER_STEAM_ID = Steam.getLobbyMemberByIndex(lobby_id, MEMBER)
		var MEMBER_STEAM_NAME = Steam.getFriendPersonaName(MEMBER_STEAM_ID)
		add_Player_List(MEMBER_STEAM_ID, MEMBER_STEAM_NAME)

func add_Player_List(steam_id, steam_name):
	LOBBY_MEMBERS.append({"steam_id":steam_id, "steam_name":steam_name})
	playerList.clear()
	for MEMBER in LOBBY_MEMBERS:
		playerList.add_text(str(MEMBER['steam_name']) + "\n")
	
func _on_refresh_pressed():
		get_Lobby_Members()

func _on_start_pressed():
	if lobby_id:
		$Host.hide()
		$Join.hide()
		$Start.hide()
		$Refresh.hide()
		$GeneratedKey.hide()
		$EnterKey.hide()
		$Panel.hide()
		ms.spawn("res://Scenes/level.tscn")
	
