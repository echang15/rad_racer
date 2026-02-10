extends Node

@export var turbo_sfx: AudioStreamPlayer
@export var pass_sfx: AudioStreamPlayer
@export var puddle_sfx: AudioStreamPlayer
@export var crash_sfx: AudioStreamPlayer

func play_turbo():
	if turbo_sfx: turbo_sfx.play()

func play_pass():
	if pass_sfx: pass_sfx.play()

func play_puddle():
	if puddle_sfx: puddle_sfx.play()

func play_crash():
	if crash_sfx: crash_sfx.play()
