FYZJ_NUMBER = "15258899632"

ready = false

function cc_callback(event)
    if not ready then return end

    log.info("call", event)
    if event == "READY" then
        ready = true
    
    elseif event == "INCOMINGCALL" then
        calling = 3
        sys.sendMsg("sound_task", "execute", "beep")
    
    elseif event == "CONNECTED" then
        calling = 1
        sys.sendMsg("sound_task", "execute", "stop_toot")
    
    elseif event == "DISCONNECTED" or event == "HANGUP_CALL_DOEN" then
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
    local button_gpio = 2
    gpio.setup(button_gpio, 
               function() sys.sendMsg("call_task", "on_button") end,
               gpio.PULLUP,
               gpio.RISING)

    sys.waitUntil("CC_READY")
    sys.subscribe("CC_IND", cc_callback)
    cc.init(0)
    while true do
        sys.waitMsg("call_task", "on_button")
        -- on button
        if calling == 0 then
            sys.sendMsg("sound_task", "execute", "dial")
        elseif calling == 1 then
            sys.sendMsg("sound_task", "execute", "hangup")
        elseif calling == 2 then
            sys.sendMsg("sound_task", "execute", "hangup")
        elseif calling == 3 then
            sys.sendMsg("sound_task", "execute", "accept_call")
        end
    end
end

return {
    call_task = call_task
}