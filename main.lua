PROJECT = "demo"
VERSION = "1.0.0"

sys = require("sys")

if wdt then
	wdt.init(9000)
	sys.timerLoopStart(wdt.feed, 3000)
end

DATA_DIR = "/udata"
io.mkdir(DATA_DIR)

volume = require("volume")
sound = require("sound")
voice = require("voice")
call = require("call")

sys.taskInitEx(volume.volume_task, "volume_task")
sys.taskInitEx(sound.sound_task, "sound_task")
sys.taskInitEx(voice.voice_task, "voice_task")
sys.taskInitEx(call.call_task, "call_task")
sys.run()