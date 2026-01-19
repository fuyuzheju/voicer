PROJECT = "demo"
VERSION = "1.0.0"

-- constants
SERVER_CERT = io.readFile("/luadb/ca.crt")
CLIENT_CERT = io.readFile("/luadb/voicer.crt")
CLIENT_KEY = io.readFile("/luadb/voicer.key")
RECORD_FILE = "/udata/record.amr"
RECORD_TIME = 60
TOOT_FILE = "/luadb/toot.amr"
BEEP_FILE = "/luadb/beep.amr"

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