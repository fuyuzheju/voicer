calling = 0
-- 0 no call
-- 1 calling
-- 2 incoming call
-- 3 dialing

fyzj = "15258899632"
BEEP1 = "/luadb/beep1.amr"

function stop_voice()
	if playing then
		exaudio.play_stop()
		sys.wait(200) -- wait to stop
	elseif recording then
		exaudio.record_stop()
		sys.wait(200) -- wait to stop
	end
end

function toggle() -- toggle calling state
	stop_voice()
	if calling == 0 then
		cc.dial(0, fyzj)

	elseif calling == 1 then
		cc.hangUp(0)

	elseif calling == 2 then
		log.info("call", "before accepting, playing:", playing)
		cc.accept(0)

	elseif calling == 3 then
		cc.hangUp(0)

	end
end

function beep(filename)
	stop_voice()
	playing = true
	log.info("call", "beep")
	exaudio.play_start({
		type = 0,
		content = filename,
		cbfnc = function() playing = false end,
	})
end

function handle_cc(status)
	log.info("call", "handle", status)

	if status == "READY" then
		sys.publish("CC_READY")

	elseif status == "INCOMINGCALL" then
		local number = cc.lastNum() or "unknown"
		log.info("call", "incoming", number)
		if number ~= fyzj then
			cc.hangUp(0)
			return
		end
		log.info("call", "fyzj incoming")
		beep(BEEP1)
		calling = 2

	elseif status == "SPEECH_START" then
		log.info("call", "speech start, playing:", playing)
		calling = 1

	elseif status == "MAKE_CALL_OK" then
		log.info("call", "make call ok")
		calling = 3

	elseif status == "MAKE_CALL_FAILED" then
		log.warn("call", "make call failed")
		calling = 0

	elseif status == "HANGUP_CALL_DONE" or status == "DISCONNECTED" then
		log.info("call", "finish")
		calling = 0

	end
end

function call_task()
	local button_gpio = 2
	gpio.setup(button_gpio, function() sys.sendMsg("call_task", "on_button") end, gpio.PULLUP, gpio.RISING)
	gpio.debounce(button_gpio, 300, 1)
	cc.init(0)

	sys.subscribe("CC_IND", handle_cc)
	sys.waitUntil("CC_READY")
	sys.waitMsg("call_task", "on_button") -- process the first trigger when initing

	while true do
		sys.waitMsg("call_task", "on_button")
		toggle()
	end
end

return {
	call_task = call_task
}