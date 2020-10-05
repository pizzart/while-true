extends Node

var song_dict = {
	"dancing_square": "res://audio/music/Dancing Square.wav",
	"song1": "res://audio/music/ld47_1.wav"
}
var playing_music = ""
var config = ConfigFile.new()
var err = config.load("user://wt_settings.cfg")
var mus_vol
var sfx_vol
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if err != OK:
		config.set_value("volume", "music", 50)
		config.set_value("volume", "sound", 50)
		config.save("user://wt_settings.cfg")
	else:
		mus_vol = config.get_value("volume", "music")
		sfx_vol = config.get_value("volume", "sound")


func _process(delta):
	config = ConfigFile.new()
	err = config.load("user://wt_settings.cfg")
	mus_vol = linear2db(config.get_value("volume", "music"))
	sfx_vol = linear2db(config.get_value("volume", "sound"))
	AudioServer.set_bus_volume_db(1, mus_vol)
	AudioServer.set_bus_volume_db(2, sfx_vol)


func play(audio: String, volume = 0, pitch = 0, loop = false):
	var audio_player = AudioStreamPlayer.new()
	var audio_file = load(audio)
	audio_player.stream = audio_file
	audio_player.name = audio.split("/")[-1].split(".")[0]
	audio_player.volume_db = volume
	audio_player.pitch_scale = rng.randfn(1, pitch)
	if "music" in audio:
		audio_player.bus = "Music"
		if playing_music:
			get_node(playing_music).queue_free()
		playing_music = audio_player.name
	elif "sounds" in audio:
		audio_player.bus = "Sound"
	
	add_child(audio_player)
	audio_player.play()
	
	yield(audio_player, "finished")
	if !"music" in audio:
		audio_player.queue_free()


func stop_music():
	if playing_music:
		get_node(playing_music).queue_free()
		playing_music = ""
