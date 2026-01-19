FYZJ_NUMBER = "15258899632"
local button_gpio = 2

ready = false
function cc_callback(event)
    log.info("call", event)

    if event == "READY" then
        ready = true
        return
    end

    if not ready then return end
    if event == "INCOMINGCALL" then
        calling = 3
        sys.sendMsg("sound_task", "execute", "beep")
    
    elseif event == "SPEECH_START" then
        calling = 1
        sys.sendMsg("sound_task", "execute", "stop_toot")
    
    elseif event == "DISCONNECTED" or event == "HANGUP_CALL_DONE" then
        calling = 0
        sys.sendMsg("sound_task", "execute", "stop_toot")
        sys.sendMsg("sound_task", "execute", "hangup_toot")

    elseif event == "MAKE_CALL_OK" then
        calling = 2
    
    elseif event == "MAKE_CALL_FAILED" then
        calling = 0
        sys.sendMsg("sound_task", "execute", "stop_toot")
        sys.sendMsg("sound_task", "execute", "call_failed_beep")

    elseif event == "ANSWER_CALL_DONE" then
        calling = 1
    
    elseif event == "PLAY" then
        
    end

end

function call_task()
    gpio.setup(button_gpio, 
               function() sys.sendMsg("call_task", "on_button") end,
               gpio.PULLUP,
               gpio.RISING)
    gpio.debounce(button_gpio, 100, 1)

    sys.subscribe("CC_IND", cc_callback)
    cc.init(0)
    while true do
        sys.waitMsg("call_task", "on_button")
        if not ready then goto continue end
        -- on button
        log.info("call", "on_button")
        if calling == 0 then
            sys.sendMsg("sound_task", "execute", "dial", {number = FYZJ_NUMBER})
        elseif calling == 1 then
            sys.sendMsg("sound_task", "execute", "hangup")
        elseif calling == 2 then
            sys.sendMsg("sound_task", "execute", "hangup")
        elseif calling == 3 then
            sys.sendMsg("sound_task", "execute", "accept_call")
        end
        ::continue::
    end
end

return {
    call_task = call_task
}