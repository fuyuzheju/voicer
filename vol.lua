function vol_task()
	local vol_gpio = 27
	local MAX_VOLTAGE = 3300
	gpio.setup(vol_gpio, 1)
	adc.setRange(adc.ADC_RANGE_MAX)
	adc.open(0)
	local vol_num = 50
	while true do
		sys.wait(500)
		local voltage = adc.get(0)
		local new_vol_num = math.floor(voltage / MAX_VOLTAGE * 100)
		if math.abs(new_vol_num - vol_num) > 2 then
			vol_num = new_vol_num
			exaudio.vol(new_vol_num)
			log.info("vol", new_vol_num)
		end
	end
end

return {
	vol_task = vol_task
}