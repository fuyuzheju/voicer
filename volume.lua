-- adjust volume via the knob

function volume_task()
	local volume_gpio = 27
	local MAX_VOLTAGE = 3300
	gpio.setup(volume_gpio, 1)
	adc.setRange(adc.ADC_RANGE_MAX)
	adc.open(0)
	local volume_num = 50
	while true do
		sys.wait(500)
		local voltage = adc.get(0)
		local new_volume_num = math.floor(voltage / MAX_VOLTAGE * 100)
		if math.abs(new_volume_num - volume_num) > 2 then
			volume_num = new_volume_num
			exaudio.vol(new_volume_num)
			log.info("volume", new_volume_num)
		end
	end
end

return {
	volume_task = volume_task
}