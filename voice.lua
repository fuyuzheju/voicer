local button_gpio = 23
local filename = "/udata/record.amr"

function on_button()
    if gpio.get(button_gpio) == 0 then
        -- down
        local total_time = 0
        local flag = false
        while total_time < 400 do
            sys.wait(100)
            if gpio.get(button_gpio) == 1 then
                flag = true
                break
            end
            total_time = total_time + 100
        end
        
        if flag then
            -- play
            if playing then
                sys.sendMsg("sound_task", "execute", "play_stop_wait", {})
            else
                sys.sendMsg("sound_task", "execute", "play_voice", {filename=filename})
            end
        else
            -- record
            sys.sendMsg("sound_task", "execute", "record_voice", {filename=filename})
        end
    else
        -- release
        if recording then
            sys.sendMsg("sound_task", "execute", "record_stop_wait", {})
        end
    end
end

function voice_task()
    gpio.setup(button_gpio,
               function() sys.sendMsg("voice_task", "on_button") end,
               gpio.PULLUP)
    gpio.debounce(button_gpio, 100, 1)
    while true do
        sys.waitMsg("voice_task", "on_button")
        on_button()
    end
end

return {
    voice_task = voice_task
}