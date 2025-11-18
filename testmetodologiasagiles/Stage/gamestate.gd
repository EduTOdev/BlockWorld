extends Node

var game = null
var hud: CanvasLayer = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var levelTimer = null
var currentLevel = null
var currentLevelNumber = null
var totalHP = 5
var actualHP = 5
var totalMana = 5
var actualMana = 5

var lastRespawnPosition: Vector2 = Vector2.ZERO

func setRespawn(position: Vector2):
	lastRespawnPosition = position

func respawnPlayer():
	if player:
		player.global_position = lastRespawnPosition
