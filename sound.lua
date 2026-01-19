-- process all interactions with the mic and speaker

exaudio = require("exaudio")

audio_params = {
	model = "es8311",
	i2c_id = 0,
	pa_ctrl = gpio.AUDIOPA_EN,
	dac_ctrl = 20
}

playing = false
recording = false
calling = 0
-- 0: no call
-- 1: on call
-- 2: dialing
-- 3: incoming
toot_timer = nil

function play_voice(args)
	if recording then return false end
	if calling ~= 0 then return false end

	playing = true
	exaudio.play_start({
		type = 0,
		content = args.filename,
		cbfnc = function() playing = false end,
	})
	return true
end

function record_voice(args)
	if playing then return false end
	if calling ~= 0 then return false end

	recording = true
	exaudio.mic_vol(100)
	exaudio.record_start({
		format = exaudio.AMR_NB,
		time = RECORD_TIME,
		path = args.filename,
		cbfnc = function() recording = false end,
	})
	return true
end

function play_stop_wait(args)
	if calling ~= 0 then return false end
	if playing then
		exaudio.play_stop()
		while playing do
			sys.wait(50)
		end
	end
	return true
end

function record_stop_wait(args)
	if calling ~= 0 then return false end
	if recording then
		exaudio.record_stop()
		while recording do
			sys.wait(50)
		end
	end
	return true
end


function dial(args)
	if calling ~= 0 then return end
	record_stop_wait()
	play_stop_wait()

	cc.dial(0, args.number)
	toot_timer = sys.timerLoopStart(function()
		sys.sendMsg("sound_task", "execute", "toot")
	end, 5000)
end

function toot(args)
	if calling ~= 2 then return end
	record_stop_wait()
	play_stop_wait()

	playing = true
	exaudio.play_start({
		type = 0,
		content = TOOT_FILE,
		cbfnc = function() playing = false end,
	})
end

function stop_toot(args)
	if toot_timer then
		sys.timerStop(toot_timer)
		toot_timer = nil
	end
	play_stop_wait()
end

function beep(args)
	if calling ~= 3 then return end
	record_stop_wait()
	play_stop_wait()

	playing = true
	exaudio.play_start({
		type = 0,
		content = BEEP_FILE,
		cbfnc = function() playing = false end,
	})
end

function accept_call(args)
	if calling ~= 3 then return end
	record_stop_wait()
	play_stop_wait()

	cc.accept(0)
end

function hangup(args)
	if calling == 0 then return end
	cc.hangUp(0)
end

function hangup_toot(args)
	log.info("sound", "hangup_toot")
end

function call_failed_beep(args)
	log.info("sound", "call_failed_beep")
end


function sound_task()
	exaudio.setup(audio_params)
	while true do
		local message = sys.waitMsg("sound_task", "execute")
		local cmd = message[2]
		local args = message[3]
		log.info("sound", cmd, args)
		if COMMANDS[cmd] == nil then
			log.error("sound", "unknown command", cmd)
		else
			local code = COMMANDS[cmd](args)
			sys.publish("sound_finish")
			log.info("sound", cmd, "finished", code)
		end
	end
end

COMMANDS = {
	play_voice = play_voice,
	record_voice = record_voice,
	play_stop_wait = play_stop_wait,
	record_stop_wait = record_stop_wait,
	dial = dial,
	toot = toot,
	stop_toot = stop_toot,
	beep = beep,
	accept_call = accept_call,
	hangup = hangup,
	hangup_toot = hangup_toot,
	call_failed_beep = call_failed_beep,
}

return {
	sound_task = sound_task
}