-- process all interactions with the mic and speaker

audio_params = {
	model = "es8311",
	i2c_id = 0,
	pa_ctrl = gpio.AUDIOPA_EN,
	dac_ctrl = 20
}

playing = false
recording = false
calling = 0

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
	exaudio.record_start({
		format = exaudio.AMR_NB,
		time = 60,
		path = args.filename,
		cbfnc = function() recording = false end,
	})
	return true
end

function play_stop_wait(args)
	if playing then
		exaudio.play_stop()
	end
	while playing do
		sys.wait(50)
	end
	return true
end

function record_stop_wait(args)
	if recording then
		exaudio.record_stop()
	end
	while recording do
		sys.wait(50)
	end
	return true
end

function sound_task()
	exaudio.setup(audio_params)
	while true do
		local message = sys.waitMsg("sound_task", "execute")
		local cmd = message[2]
		local args = message[3]
		log.info("sound", cmd, args)
		if COMMANDS[cmd] == nil then
			log.error("sound", "unknown command")
		else
			local code = COMMANDS[cmd](args)
			log.info("sound", cmd, "finished", code)
		end
	end
end

COMMANDS = {
	play_voice = play_voice,
	record_voice = record_voice,
	play_stop_wait = play_stop_wait,
	record_stop_wait = record_stop_wait,
}

return {
	sound_task = sound_task
}