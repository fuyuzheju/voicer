PROJECT = "demo"
VERSION = "1.0.0"

sys = require("sys")

if wdt then
	wdt.init(9000)
	sys.timerLoopStart(wdt.feed, 3000)
end

volume = require("volume")
sound = require("sound")
voice = require("voice")

sys.taskInitEx(volume.volume_task, "volume_task")
sys.taskInitEx(sound.sound_task, "sound_task")
sys.taskInitEx(voice.voice_task, "voice_task")
sys.run()