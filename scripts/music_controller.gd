extends Node2D
class_name MusicController

@onready var midi_player: MidiPlayer = $MidiPlayer

func _notification(what: int):
	if midi_player:
		if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			midi_player.playing = false
			midi_player._stop_all_notes( )
		elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			midi_player.playing = true
			midi_player._stop_all_notes( )
