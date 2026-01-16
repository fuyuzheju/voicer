PROJECT = "demo"
VERSION = "1.0.0"

sys = require("sys")
exaudio = require("exaudio")
audio_params = {
	model = "es8311",
	i2c_id = 0,
	pa_ctrl = gpio.AUDIOPA_EN,
	dac_ctrl = 20
}

if wdt then
	wdt.init(9000)
	sys.timerLoopStart(wdt.feed, 3000)
end

vol = require("vol")
voice = require("voice")
network = require("network")
call = require("call")

sys.taskInitEx(vol.vol_task, "vol_task")
sys.taskInitEx(voice.voice_task, "voice_task")
sys.taskInitEx(network.network_task, "network_task")
sys.taskInitEx(call.call_task, "call_task")
sys.run()