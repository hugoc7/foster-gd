extends Node2D


func _ready():
	$ParticleEmitter.emitting = true
	$ParticleEmitter.one_shot = true
	
