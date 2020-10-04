local CurrentWeather = ''

function IsInSnowyRegion(x, y, z)
	return GetDistanceBetweenCoords(x, y, z, -1361.63, 2393.23, 306.62, false) <= 1400
end

function IsInDesertRegion(x, y, z)
	return x <= -2050 and y <= -2200
end

function TranslateWeatherForRegion(weather)
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

	if weather == 'rain' then
		if IsInSnowyRegion(x, y, z) then
			return 'snow'
		elseif IsInDesertRegion(x, y, z) then
			return 'thunder'
		end
	elseif weather == 'thunderstorm' then
		if IsInSnowyRegion(x, y, z) then
			return 'blizzard'
		elseif IsInDesertRegion(x, y, z) then
			return 'rain'
		end
	elseif weather == 'hurricane' then
		if IsInSnowyRegion(x, y, z) then
			return 'whiteout'
		elseif IsInDesertRegion(x, y, z) then
			return 'sandstorm'
		end
	elseif weather == 'drizzle' then
		if IsInSnowyRegion(x, y, z) then
			return 'snowlight'
		elseif IsInDesertRegion(x, y, z) then
			return 'sunny'
		end
	elseif weather == 'shower' then
		if IsInSnowyRegion(x, y, z) then
			return 'groundblizzard'
		elseif IsInDesertRegion(x, y, z) then
			return 'sunny'
		end
	elseif weather == 'fog' then
		if IsInSnowyRegion(x, y, z) then
			return 'snowlight'
		end
	elseif weather == 'misty' then
		if IsInSnowyRegion(x, y, z) then
			return 'snowlight'
		end
	end

	return weather
end

function SetWeatherType(weatherHash, p1, p2, overrideNetwork, transitionTime, p5)
	Citizen.InvokeNative(0x59174F1AFE095B5A, weatherHash, true, false, true, transitionTime, false)
end

RegisterNetEvent('weatherSync:changeWeather')
AddEventHandler('weatherSync:changeWeather', function(weather, transitionTime)
	local translatedWeather = TranslateWeatherForRegion(weather)

	if translatedWeather ~= CurrentWeather then
		SetWeatherType(GetHashKey(translatedWeather), true, false, true, transitionTime, false)
		CurrentWeather = translatedWeather
	end
end)

function NetworkOverrideClockTime(hour, minute, second, transitionTime, freezeTime)
	Citizen.InvokeNative(0x669E223E64B1903C, hour, minute, second, transitionTime, freezeTime)
end

RegisterNetEvent('weatherSync:changeTime')
AddEventHandler('weatherSync:changeTime', function(hour, minute, second, transitionTime, freezeTime)
	NetworkOverrideClockTime(hour, minute, second, transitionTime, freezeTime)
end)

local WeatherIcons = {
	['blizzard']       = '❄️',
	['clouds']         = '⛅',
	['drizzle']        = '🌧️',
	['fog']            = '🌫️',
	['groundblizzard'] = '❄️',
	['hail']           = '🌨️',
	['highpressure']   = '☀️',
	['hurricane']      = '🌪️',
	['misty']          = '🌫️',
	['overcast']       = '☁️',
	['overcastdark']   = '☁️',
	['rain']           = '🌧️',
	['sandstorm']      = '🌬️',
	['shower']         = '🌧️',
	['sleet']          = '🌧️',
	['snow']           = '🌨️',
	['snowlight']      = '🌨️',
	['sunny']          = '☀️',
	['thunder']        = '🌩️',
	['thunderstorm']   = '⛈️',
	['whiteout']       = '❄️'
}

RegisterNetEvent('weatherSync:displayForecast')
AddEventHandler('weatherSync:displayForecast', function(forecast)
	for i = 1, #forecast do
		forecast[i].weather = WeatherIcons[TranslateWeatherForRegion(forecast[i].weather)]
	end

	-- Get local temperature
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	local temperature = GetTemperatureAtCoords(x, y, z)
	local metric = ShouldUseMetricTemperature();
	local tempStr = string.format('%d °%s', math.floor(temperature), (metric and 'C' or 'F'))

	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'display',
		forecast = json.encode(forecast),
		temperature = tempStr
	})
end)

RegisterNUICallback('closeForecast', function()
	SetNuiFocus(false, false)
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/forecast', 'Display upcoming weather', {})

	TriggerEvent('chat:addSuggestion', '/time', 'Change the time of day', {
		{name = 'h', help = 'Hour, 0-23'},
		{name = 'm', help = 'Minute, 0-59'},
		{name = 's', help = 'Second, 0-59'},
		{name = 'transition', help = 'Transition time in milliseconds'},
		{name = 'freeze', help = '0 = don\'t freeze time, 1 = freeze time'}
	})

	TriggerEvent('chat:addSuggestion', '/timescale', 'Change the rate at which time passes', {
		{name = 'scale', help = 'Number of in-game seconds per real-time second'}
	})

	TriggerEvent('chat:addSuggestion', '/weather', 'Change the weather', {
		{name = 'type', help = 'The type of weather to change to'},
		{name = 'freeze', help = '0 = don\'t freeze weather, 1 = freeze weather'}
	})
end)
