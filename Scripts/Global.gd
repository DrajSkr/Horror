extends Node

signal hiddeninbush
signal nothiddeninbush
signal correct_pass_entered
signal lock_screen
signal not_lock_screen


var in_lock_screen = false
var safe_open = false
var dir = Vector2.ZERO
var player_pos = Vector3.ZERO
var PlayerGotGun = false
var PlayerGotMedikit = false
var PlayerGotTorch = false
var PlayerGotMask = false
var hiddeninsidebush = false
var inbush = false
var ghost_on_hunt = false
var password = ""
