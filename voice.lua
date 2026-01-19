network = require("network")

local button_gpio = 23
local record_uploaded = true

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
            if record_uploaded then
                sys.sendMsg("sound_task", "execute", "record_ding")
                sys.sendMsg("sound_task", "execute", "record_voice", {filename=filename})
                record_uploaded = false
            end
        end
    else
        -- release
        if recording then
            sys.sendMsg("sound_task", "execute", "record_stop_wait", {})
            sys.waitUntil("sound_finish")
            local result = network.upload()
            local wait_time = 10000
            while not result do
                sys.wait(wait_time)
                result = network.upload()
                if wait_time < 5 * 60 * 1000 then
                    wait_time = wait_time * 2
                else
                    wait_time = 5 * 60 * 1000
                end
            end

            record_uploaded = true
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