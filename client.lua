local meanSeaLevel = Config.isRDR and 40.0 or 0.0

local currentWeather = nil
local currentWindDirection = 0.0
local snowOnGround = false
local syncEnabled = true

local forecastIsDisplayed = false
local adminUiIsOpen = false

local currentTime
local currentTimescale = Config.timescale

RegisterNetEvent("weathersync:changeWeather")
RegisterNetEvent("weathersync:changeTime")
RegisterNetEvent("weathersync:changeTimescale")
RegisterNetEvent("weathersync:changeWind")
RegisterNetEvent("weathersync:toggleForecast")
RegisterNetEvent("weathersync:updateForecast")
RegisterNetEvent("weathersync:openAdminUi")
RegisterNetEvent("weathersync:updateAdminUi")
RegisterNetEvent("weathersync:toggleSync")
RegisterNetEvent("weathersync:setSyncEnabled")
RegisterNetEvent("weathersync:setMyTime")
RegisterNetEvent("weathersync:setMyWeather")

local function SetSnowCoverageType(type)
	return Citizen.InvokeNative(0xF02A9C330BBFC5C7, type)
end

local function setWeather(weatherType, transitionTime)
	if Config.isRDR then
		Citizen.InvokeNative(0x59174F1AFE095B5A, GetHashKey(weatherType), true, false, true, transitionTime, false)
	else
		SetWeatherOwnedByNetwork(false)
		SetWeatherTypeOvertimePersist(weatherType, transitionTime)
	end
end

local function setTime(hour, minute, second, transitionTime, freeze)
	if Config.isRDR then
		Citizen.InvokeNative(0x669E223E64B1903C, hour, minute, second, transitionTime, true)
	else
		if currentTimescale == 30 then
			currentTime = freeze and {hour = hour, minute = minute}

			local h = GetClockHours()
			local m = GetClockMinutes()
			local s = GetClockSeconds()

			if hour ~= h or (math.abs(minute - m) > 5) then
				NetworkOverrideClockTime(hour, minute, 0)
			end
		else
			currentTime = {hour = hour, minute = minute}
		end
	end
end

local function isInSnowyRegion(x, y, z)
	return (x <= -700.0 and y >= 1090.0) or (x <= -500.0 and y >= 2388.0)
end

local function isInDesertRegion(x, y, z)
	return x <= -2050 and y <= -1750
end

local function isInNorthernRegion(x, y, z)
	return y >= 1050
end

local function isInGuarma(x, y, z)
	return x >= 0 and y <= -4096
end

local function isInCayoPerico(x, y, z)
	return x >= 2000 and y <= -3500 and x <= 6500 and y >= -7000
end

local function translateWeatherForRegion(weather, x, y, z)
	if Config.isRDR then
		local temp = GetTemperatureAtCoords(x, y, z)

		if weather == "rain" then
			if isInSnowyRegion(x, y, z) then
				return "snow"
			elseif isInNorthernRegion(x, y, z) and temp < 0.0 then
				return "snow"
			elseif isInDesertRegion(x, y, z) then
				return "thunder"
			end
		elseif weather == "thunderstorm" then
			if isInSnowyRegion(x, y, z) then
				return "blizzard"
			elseif isInNorthernRegion(x, y, z) and temp < 0.0 then
				return "blizzard"
			elseif isInDesertRegion(x, y, z) then
				return "rain"
			end
		elseif weather == "hurricane" then
			if isInSnowyRegion(x, y, z) then
				return "whiteout"
			elseif isInNorthernRegion(x, y, z) and temp < 0.0 then
				return "whiteout"
			elseif isInDesertRegion(x, y, z) then
				return "sandstorm"
			end
		elseif weather == "drizzle" then
			if isInSnowyRegion(x, y, z) then
				return "snowlight"
			elseif isInNorthernRegion(x, y, z) and temp < 0.0 then
				return "snowlight"
			elseif isInDesertRegion(x, y, z) then
				return "sunny"
			end
		elseif weather == "shower" then
			if isInSnowyRegion(x, y, z) then
				return "groundblizzard"
			elseif isInNorthernRegion(x, y, z) and temp < 0.0 then
				return "groundblizzard"
			elseif isInDesertRegion(x, y, z) then
				return "sunny"
			end
		elseif weather == "fog" then
			if isInSnowyRegion(x, y, z) then
				return "snowlight"
			end
		elseif weather == "misty" then
			if isInSnowyRegion(x, y, z) then
				return "snowlight"
			end
		elseif weather == "snow" then
			if isInGuarma(x, y, z) then
				return "sunny"
			end
		elseif weather == "snowlight" then
			if isInGuarma(x, y, z) then
				return "sunny"
			end
		elseif weather == "blizzard" then
			if isInGuarma(x, y, z) then
				return "sunny"
			end
		end
	else
		if Config.disableSnowOnCayoPerico then
			if weather == "blizzard" or weather == "snow" or weather == "snowlight" or weather == "xmas" then
				if isInCayoPerico(x, y, z) then
					return "clear"
				end
			end
		end
	end

	return weather
end

local function isSnowyWeather(weather)
	return weather == "blizzard" or weather == "groundblizzard" or weather == "snow" or weather == "whiteout" or weather == "snowlight"
end

local function translateWindForAltitude(direction, speed)
	local ped = PlayerPedId()
	local altitudeSea = GetEntityCoords(ped).z - meanSeaLevel
	local altitudeTerrain = GetEntityHeightAboveGround(ped)

	local directionMultiplier = math.floor(altitudeSea / Config.windShearInterval)
	local speedMultiplier = math.floor(altitudeTerrain / Config.windShearInterval)

	direction = (direction + directionMultiplier * Config.windShearDirection) % 360
	speed = speed + speedMultiplier * Config.windShearSpeed

	return direction, speed
end

local function updateForecast(forecast)
	local h24 = Config.isRDR and ShouldUse_24HourClock() or true

	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	local x, y, z = table.unpack(pos)

	for i = 1, #forecast do
		if h24 then
			forecast[i].time = string.format(
				"%.2d:%.2d",
				forecast[i].hour,
				forecast[i].minute)
		else
			local h = forecast[i].hour % 12
			forecast[i].time = string.format(
				"%d:%.2d %s",
				h == 0 and 12 or h,
				forecast[i].minute,
				forecast[i].hour > 12 and "PM" or "AM")
		end

		forecast[i].weather = translateWeatherForRegion(forecast[i].weather, x, y, z)
		forecast[i].wind = GetCardinalDirection(forecast[i].wind)
	end

	-- Get local temperature
	local metric = Config.isRDR and ShouldUseMetricTemperature() or ShouldUseMetricMeasurements()
	local temperature
	local temperatureUnit
	local windSpeed
	local windSpeedUnit
	local tempStr

	if Config.isRDR then
		if metric then
			temperature = math.floor(GetTemperatureAtCoords(x, y, z))
			temperatureUnit = "C"
		else
			temperature = math.floor(GetTemperatureAtCoords(x, y, z) * 9/5 + 32)
			temperatureUnit = "F"
		end

		tempStr = string.format("%d °%s", temperature, temperatureUnit)
	end

	if metric then
		windSpeed = math.floor(GetWindSpeed() * 3.6)
		windSpeedUnit = "kph"
	else
		windSpeed = math.floor(GetWindSpeed() * 3.6 * 0.621371)
		windSpeedUnit = "mph"
	end

	local windStr = string.format("🌬️ %d %s %s", windSpeed, windSpeedUnit, GetCardinalDirection(currentWindDirection))

	local altitudeSea = string.format("%d", math.floor(pos.z - meanSeaLevel))
	local altitudeTerrain = string.format("%d", math.floor(GetEntityHeightAboveGround(ped)))

	SendNUIMessage({
		action = "updateForecast",
		forecast = json.encode(forecast),
		temperature = tempStr,
		wind = windStr,
		syncEnabled = syncEnabled,
		altitudeSea = altitudeSea,
		altitudeTerrain = altitudeTerrain
	})
end

local function toggleSync()
	currentWeather = nil

	syncEnabled = not syncEnabled

	TriggerEvent("chat:addMessage", {
		color = {255, 255, 128},
		args = {"Weather Sync", syncEnabled and "on" or "off"}
	})
end

local function setSyncEnabled(toggle)
	if syncEnabled ~= toggle then
		toggleSync()
	end
end

local function setMyWeather(weather, transition, permanentSnow)
	if syncEnabled then
		toggleSync()
	end

	if transition <= 0.0 then
		transition = 0.1
	end

	setWeather(weather, transition)

	if permanentSnow then
		if Config.isRDR then
			SetSnowCoverageType(3)
		end

		snowOnGround = true
	else
		if Config.isRDR then
			SetSnowCoverageType(0)
		end

		snowOnGround = false
	end
end

local function setMyTime(h, m, s, t)
	if syncEnabled then
		toggleSync()
	end

	if not Config.isRDR then
		currentTime = {hour = h, minute = m}
	end

	setTime(h, m, s, t, true)
end

exports("toggleSync", toggleSync)
exports("setSyncEnabled", setSyncEnabled)
exports("setMyWeather", setMyWeather)
exports("setMyTime", setMyTime)

exports("isSnowOnGround", function()
	return snowOnGround or IsNextWeatherType("XMAS")
end)

AddEventHandler("weathersync:changeWeather", function(weather, transitionTime, permanentSnow)
	if not syncEnabled then
		return
	end

	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

	local translatedWeather = translateWeatherForRegion(weather, x, y, z)

	if Config.isRDR then
		if not currentWeather then
			transitionTime = 1.0
			SetSnowCoverageType(0)
			snowOnGround = false
		end

		local inSnowyRegion = isInSnowyRegion(x, y, z)

		if permanentSnow or (Config.dynamicSnow and (inSnowyRegion or isSnowyWeather(translatedWeather))) then
			if not snowOnGround then
				snowOnGround = true
				SetSnowCoverageType(3)
			end
		else
			if snowOnGround then
				snowOnGround = false
				SetSnowCoverageType(0)
			end
		end
	else
		snowOnGround = (permanentSnow and not (Config.disableSnowOnCayoPerico and isInCayoPerico(x, y, z))) or (Config.dynamicSnow and isSnowyWeather(translatedWeather))
	end

	if translatedWeather ~= currentWeather then
		setWeather(translatedWeather, transitionTime)
		currentWeather = translatedWeather
	end
end)

AddEventHandler("weathersync:changeTime", function(hour, minute, second, transitionTime, freezeTime)
	if not syncEnabled then
		return
	end

	setTime(hour, minute, second, transitionTime, freezeTime)
end)

AddEventHandler("weathersync:changeTimescale", function(scale)
	currentTimescale = scale
end)

AddEventHandler("weathersync:changeWind", function(direction, speed)
	direction, speed = translateWindForAltitude(direction, speed)

	SetWindDirection(direction)
	currentWindDirection = direction

	if Config.isRDR then
		SetWindSpeed(speed)
	end
end)

AddEventHandler("weathersync:toggleForecast", function()
	forecastIsDisplayed = not forecastIsDisplayed

	Citizen.CreateThread(function()
		while forecastIsDisplayed do
			TriggerServerEvent("weathersync:requestUpdatedForecast")
			Citizen.Wait(1000)
		end
	end)

	SendNUIMessage({
		action = "toggleForecast"
	})
end)

AddEventHandler("weathersync:updateForecast", updateForecast)

AddEventHandler("weathersync:openAdminUi", function()
	adminUiIsOpen = true

	Citizen.CreateThread(function()
		while adminUiIsOpen do
			TriggerServerEvent("weathersync:requestUpdatedAdminUi")
			Citizen.Wait(1000)
		end
	end)

	SetNuiFocus(true, true)

	SendNUIMessage({
		action = "openAdminUi"
	})
end)

AddEventHandler("weathersync:updateAdminUi", function(weather, time, timescale, windDirection, windSpeed, syncDelay)
	local d, h, m, s = TimeToDHMS(time)

	SendNUIMessage({
		action = "updateAdminUi",
		weatherTypes = json.encode(Config.weatherTypes),
		weather = weather,
		day = d,
		hour = h,
		min = m,
		sec = s,
		timescale = timescale,
		windSpeed = windSpeed,
		windDirection = windDirection,
		syncDelay = syncDelay
	})
end)

RegisterNUICallback("getGameName", function(data, cb)
	cb({gameName = Config.isRDR and "rdr3" or "gta5"})
end)

RegisterNUICallback("setTime", function(data, cb)
	TriggerServerEvent("weathersync:setTime", data.day, data.hour, data.min, data.sec, data.transition, data.freeze)
	cb({})
end)

RegisterNUICallback("setTimescale", function(data, cb)
	TriggerServerEvent("weathersync:setTimescale", data.timescale * 1.0)
	cb({})
end)

RegisterNUICallback("setWeather", function(data, cb)
	TriggerServerEvent("weathersync:setWeather", data.weather, data.transition * 1.0, data.freeze, data.permanentSnow)
	cb({})
end)

RegisterNUICallback("setWind", function(data, cb)
	TriggerServerEvent("weathersync:setWind", data.windDirection * 1.0, data.windSpeed * 1.0, data.freeze)
	cb({})
end)

RegisterNUICallback("setSyncDelay", function(data, cb)
	TriggerServerEvent("weathersync:setSyncDelay", data.syncDelay)
	cb({})
end)

RegisterNUICallback("closeAdminUi", function(data, cb)
	SetNuiFocus(false, false)
	adminUiIsOpen = false
	cb({})
end)

AddEventHandler("weathersync:setSyncEnabled", setSyncEnabled)
AddEventHandler("weathersync:toggleSync", toggleSync)
AddEventHandler("weathersync:setMyWeather", setMyWeather)
AddEventHandler("weathersync:setMyTime", setMyTime)

Citizen.CreateThread(function()
	SetNuiFocus(false, false)

	TriggerEvent("chat:addSuggestion", "/forecast", "Toggle display of weather forecast", {})

	TriggerEvent("chat:addSuggestion", "/syncdelay", "Change how often time/weather are synced.", {
		{name = "delay", help = "The time in milliseconds between syncs"}
	})

	TriggerEvent("chat:addSuggestion", "/time", "Change the time", {
		{name = "day", help = "0 = Sun, 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat"},
		{name = "hour", help = "0-23"},
		{name = "minute", help = "0-59"},
		{name = "second", help = "0-59"},
		{name = "transition", help = "Transition time in milliseconds"},
		{name = "freeze", help = "0 = don\"t freeze time, 1 = freeze time"}
	})

	TriggerEvent("chat:addSuggestion", "/timescale", "Change the rate at which time passes", {
		{name = "scale", help = "Number of in-game seconds per real-time second"}
	})

	TriggerEvent("chat:addSuggestion", "/weather", "Change the weather", {
		{name = "type", help = "The type of weather to change to"},
		{name = "transition", help = "Transition time in seconds"},
		{name = "freeze", help = "0 = don\"t freeze weather, 1 = freeze weather"},
		{name = "snow", help = "0 = temporary snow coverage, 1 = permanent snow coverage"}
	})

	TriggerEvent("chat:addSuggestion", "/weatherui", "Open weather admin UI", {})

	TriggerEvent("chat:addSuggestion", "/wind", "Change wind direction and speed", {
		{name = "direction", help = "Direction of the wind in degrees"},
		{name = "speed", help = "Minimum wind speed"},
		{name = "freeze", help = "0 don\"t freeze wind, 1 = freeze wind"}
	})

	TriggerEvent("chat:addSuggestion", "/weathersync", "Enable/disable weather and time sync", {})

	TriggerEvent("chat:addSuggestion", "/mytime", "Change local time (if weathersync is off)", {
		{name = "hour", help = "0-23"},
		{name = "minute", help = "0-59"},
		{name = "second", help = "0-59"},
		{name = "transition", help = "Transition time in milliseconds"}
	})

	TriggerEvent("chat:addSuggestion", "/myweather", "Change local weather (if weathersync is off)", {
		{name = "type", help = "The type of weather to change to"},
		{name = "transition", help = "Transition time in seconds"},
		{name = "snow", help = "0 = no snow on ground, 1 = snow on ground"}
	})

	TriggerServerEvent("weathersync:init")
end)

if not Config.isRDR then
	Citizen.CreateThread(function()
		while true do
			if currentTime then
				NetworkOverrideClockTime(currentTime.hour, currentTime.minute, 0)
				Citizen.Wait(5)
			else
				Citizen.Wait(1000)
			end
		end
	end)

	Citizen.CreateThread(function()
		while true do
			ForceSnowPass(snowOnGround)
			SetForceVehicleTrails(snowOnGround)
			SetForcePedFootstepsTracks(snowOnGround)

			if snowOnGround then
				if not HasNamedPtfxAssetLoaded("core_snow") then
					RequestNamedPtfxAsset("core_snow")

					while not HasNamedPtfxAssetLoaded("core_snow") do
						Citizen.Wait(0)
					end
				end

				UseParticleFxAssetNextCall("core_snow")
			else
				RemoveNamedPtfxAsset("core_snow")
			end

			Citizen.Wait(1000)
		end
	end)
end
