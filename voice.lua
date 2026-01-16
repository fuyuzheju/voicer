httpplus = require("httpplus")

playing = false
recording = false

local filename = "/record.amr"
function play_voice()
	playing = true
	if io.exists(filename) then
		log.info("voice", "file play start")
		exaudio.play_start({
			type = 0,
			content = filename,
			cbfnc = function()
				log.info("voice", "play end")
				playing = false
			end
		})
	else
		log.info("voice", "tts play start")
		exaudio.play_start({
			type = 1,
			content = "没有录音",
			cbfnc = function()
				playing = false
				log.info("voice", "play end")
			end
		})
	end
end

function record_voice()
	recording = true
	log.info("voice", "record start")
	exaudio.mic_vol(100)
	exaudio.record_start({
		format = exaudio.AMR_NB,
		time = 30,
		path = filename,
		cbfnc = function()
			recording = false
			log.info("voice", "record end")
			sys.sendMsg("network_task", "upload")
		end
	})
end

function execute()
	if playing then
		exaudio.play_stop()
		-- playing = false
		log.info("voice", "play stop")
	elseif recording then
		exaudio.record_stop()
		-- recording = false
		log.info("voice", "record stop")
	else
		play_voice()
	end
end

function voice_task()
	local button_gpio = 23
	local button_down_time_h = 100
	local button_down_time_l = 999999 -- a large num to avoid unexpected audio playing when initing
	exaudio.setup(audio_params)

	gpio.setup(button_gpio, function() sys.sendMsg("voice_task", "on_button") end, gpio.PULLUP)
	gpio.debounce(button_gpio, 60, 1)
	while true do
		sys.waitMsg("voice_task", "on_button")
		if calling ~= 0 then
			goto continue
		end

		if gpio.get(button_gpio) == 0 then
			-- down
			log.info("voice", "button down")
			sys.wait(500) -- longer than 500ms regarded as long press
			if gpio.get(button_gpio) == 0 then
				if playing or recording then
					log.warn("voice", "record repeated")
				else
					record_voice()
				end
			else
				execute()
			end
		else
			-- release
			if recording then
				exaudio.record_stop()
				log.info("voice", "record stop")
			end
		end

		::continue::
	end
end

return {
	voice_task = voice_task
}