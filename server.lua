local currentWeather = Config.weather
local currentTime = Config.time
local currentTimescale = Config.timescale
local weatherPattern = Config.weatherPattern
local weatherInterval = Config.weatherInterval
local timeIsFrozen = Config.timeIsFrozen
local weatherIsFrozen = Config.weatherIsFrozen
local maxForecast = Config.maxForecast
local syncDelay = Config.syncDelay
local currentWindDirection = Config.windDirection
local currentWindSpeed = Config.windSpeed
local windIsFrozen = Config.windIsFrozen
local permanentSnow = Config.permanentSnow

local weatherTicks = 0
local weatherForecast = {}

local dayLength = 86400
local weekLength = 604800

local logColors = {
	["default"] = "\x1B[0m",
	["error"] = "\x1B[31m",
	["success"] = "\x1B[32m"
}

RegisterNetEvent("weathersync:init")
RegisterNetEvent("weathersync:requestUpdatedForecast")
RegisterNetEvent("weathersync:requestUpdatedAdminUi")
RegisterNetEvent("weathersync:setTime")
RegisterNetEvent("weathersync:resetTime")
RegisterNetEvent("weathersync:setTimescale")
RegisterNetEvent("weathersync:resetTimescale")
RegisterNetEvent("weathersync:setWeather")
RegisterNetEvent("weathersync:resetWeather")
RegisterNetEvent("weathersync:setWeatherPattern")
RegisterNetEvent("weathersync:resetWeatherPattern")
RegisterNetEvent("weathersync:setWind")
RegisterNetEvent("weathersync:resetWind")
RegisterNetEvent("weathersync:setSyncDelay")
RegisterNetEvent("weathersync:resetSyncDelay")

local function nextWeather(weather)
	if weatherIsFrozen then
		return weather
	end

	local choices = weatherPattern[weather]

	if not choices then
		return weather
	end

	local c = 0
	local r = math.random(1, 100)

	for weatherType, chance in pairs(choices) do
		c = c + chance
		if r <= c then
			return weatherType
		end
	end

	return weather
end

local function nextWindDirection(direction)
	if windIsFrozen then
		return direction
	end

	return ((direction + math.random(0, 90) - 45) % 360) * 1.0
end

local function generateForecast()
	local weather = nextWeather(currentWeather)
	local wind = nextWindDirection(currentWindDirection)

	weatherForecast = {{weather = weather, wind = wind}}

	for i = 2, maxForecast do
		weather = nextWeather(weather)
		wind = nextWindDirection(wind)
		weatherForecast[i] = {weather = weather, wind = wind}
	end
end

local function contains(t, x)
	for _, v in pairs(t) do
		if v == x then
			return true
		end
	end
	return false
end

local function printMessage(target, message)
	if target and target > 0 then
		TriggerClientEvent("chat:addMessage", target, message)
	else
		print(table.concat(message.args, ": "))
	end
end

local function setWeather(weather, transition, freeze, permSnow)
	TriggerClientEvent("weathersync:changeWeather", -1, weather, transition, permSnow)
	currentWeather = weather
	weatherIsFrozen = freeze
	permanentSnow = permSnow
	generateForecast()
end

local function getWeather()
	return currentWeather
end

local function resetWeather()
	currentWeather = Config.weather
	weatherIsFrozen = Config.weatherIsFrozen
	permanentSnow = Config.permanentSnow
	generateForecast()
end

local function log(label, message)
	local color = logColors[label]

	if not color then
		color = logColors.default
	end

	print(string.format("%s[%s]%s %s", color, label, logColors.default, message))
end

local function validateWeatherPattern(pattern)
	for weather, choices in pairs(pattern) do
		if not pattern[weather] then
			log("error", weather .. " is missing from the weather pattern table")
		end

		local sum = 0

		for nextWeather, chance in pairs(choices) do
			sum = sum + chance
		end

		if sum ~= 100 then
			log("error", weather .. " next stages do not add up to 100")
		end
	end
end

local function setWeatherPattern(pattern)
	validateWeatherPattern(pattern)
	weatherPattern = pattern
	generateForecast()
end

local function resetWeatherPattern()
	weatherPattern = Config.weatherPattern
	generateForecast()
end

local function setTime(d, h, m, s, t, f)
	TriggerClientEvent("weathersync:changeTime", -1, h, m, s, t, f)
	currentTime = DHMSToTime(d, h, m, s)
	timeIsFrozen = f
end

local function resetTime()
	currentTime = Config.time
	timeIsFrozen = Config.timeIsFrozen
end

local function getTime()
	local d, h, m, s = TimeToDHMS(currentTime)
	return {day = d, hour = h, minute = m, second = s}
end

local function setTimescale(scale)
	TriggerClientEvent("weathersync:changeTimescale", -1, scale)
	currentTimescale = scale
end

local function resetTimescale()
	currentTimescale = Config.timescale
end

local function setSyncDelay(delay)
	syncDelay = delay
end

local function resetSyncDelay()
	syncDelay = Config.syncDelay
end

local function setWind(direction, speed, frozen)
	currentWindDirection = direction
	currentWindSpeed = speed
	windIsFrozen = frozen
	generateForecast()
end

local function resetWind()
	currentWindDirection = Config.windDirection
	currentWindSpeed = Config.windSpeed
	windIsFrozen = Config.windIsFrozen
	generateForecast()
end

local function getWind()
	return {direction = currentWindDirection, speed = currentWindSpeed}
end

local function createForecast()
	local forecast = {}

	for i = 0, #weatherForecast do
		local d, h, m, s, weather, wind

		if i == 0 then
			d, h, m, s = TimeToDHMS(currentTime)
			weather = currentWeather
			wind = currentWindDirection
		else
			local time = (timeIsFrozen and currentTime or (currentTime + weatherInterval * i) % weekLength)
			d, h, m, s = TimeToDHMS(time - time % weatherInterval)
			weather = weatherForecast[i].weather
			wind = weatherForecast[i].wind
		end

		table.insert(forecast, {day = d, hour = h, minute = m, second = s, weather = weather, wind = wind})
	end

	return forecast
end

local function syncTime(player, tick)
	-- Ensure time doesn"t wrap around when transitioning from ~23:59:59 to ~00:00:00
	local timeTransition = ((dayLength - (currentTime % dayLength) + tick) % dayLength <= tick and 0 or syncDelay)
	local day, hour, minute, second = TimeToDHMS(currentTime)
	TriggerClientEvent("weathersync:changeTime", player, hour, minute, second, timeTransition, timeIsFrozen)
end

local function syncTimescale(player)
	TriggerClientEvent("weathersync:changeTimescale", player, currentTimescale)
end

local function syncWeather(player)
	local scale = currentTimescale > 0 and currentTimescale or 1
	TriggerClientEvent("weathersync:changeWeather", player, currentWeather, weatherInterval / scale / 4, permanentSnow)
end

local function syncWind(player)
	TriggerClientEvent("weathersync:changeWind", player, currentWindDirection, currentWindSpeed)
end

exports("getTime", getTime)
exports("setTime", setTime)
exports("resetTime", resetTime)
exports("setTimescale", setTimescale)
exports("resetTimescale", resetTimescale)
exports("getWeather", getWeather)
exports("setWeather", setWeather)
exports("resetWeather", resetWeather)
exports("setWeatherPattern", setWeatherPattern)
exports("resetWeatherPattern", resetWeatherPattern)
exports("getWind", getWind)
exports("setWind", setWind)
exports("resetWind", resetWind)
exports("setSyncDelay", setSyncDelay)
exports("resetSyncDelay", resetSyncDelay)
exports("getForecast", createForecast)

AddEventHandler("weathersync:setWeather", setWeather)
AddEventHandler("weathersync:resetWeather", resetWeather)
AddEventHandler("weathersync:setWeatherPattern", setWeatherPattern)
AddEventHandler("weathersync:resetWeatherPattern", resetWeatherPattern)
AddEventHandler("weathersync:setTime", setTime)
AddEventHandler("weathersync:resetTime", resetTime)
AddEventHandler("weathersync:setTimescale", setTimescale)
AddEventHandler("weathersync:resetTimescale", resetTimescale)
AddEventHandler("weathersync:setSyncDelay", setSyncDelay)
AddEventHandler("weathersync:resetSyncDelay", resetSyncDelay)
AddEventHandler("weathersync:setWind", setWind)
AddEventHandler("weathersync:resetWind", resetWind)

AddEventHandler("weathersync:requestUpdatedForecast", function()
	TriggerClientEvent("weathersync:updateForecast", source, createForecast())
end)

AddEventHandler("weathersync:requestUpdatedAdminUi", function()
	TriggerClientEvent("weathersync:updateAdminUi", source, currentWeather, currentTime, currentTimescale, currentWindDirection, currentWindSpeed, syncDelay)
end)

AddEventHandler("weathersync:init", function()
	syncTime(source, 0)
	syncWeather(source)
	syncWind(source)
	syncTimescale(source)
end)

RegisterCommand("weather", function(source, args, raw)
	local weather = args[1] and args[1] or currentWeather
	local transition = tonumber(args[2]) or 10.0
	local freeze = args[3] == "1"
	local permanentSnow = args[4] == "1"

	if transition <= 0.0 then
		transition = 0.1
	end

	if contains(Config.weatherTypes, weather) then
		setWeather(weather, transition + 0.0, freeze, permanentSnow)
	else
		printMessage(source, {color = {255, 0, 0}, args = {"Error", "Unknown weather type: " .. weather}})
	end
end, true)

RegisterCommand("time", function(source, args, raw)
	if #args > 0 then
		local d = tonumber(args[1]) or 0
		local h = tonumber(args[2]) or 0
		local m = tonumber(args[3]) or 0
		local s = tonumber(args[4]) or 0
		local t = tonumber(args[5]) or 0
		local f = args[6] == "1"

		setTime(d, h, m, s, t, f)
	else
		local d, h, m, s = TimeToDHMS(currentTime)
		printMessage(source, {color = {255, 255, 128}, args = {"Time", string.format("%s %.2d:%.2d:%.2d", GetDayOfWeek(d), h, m, s)}})
	end
end, true)

RegisterCommand("timescale", function(source, args, raw)
	if args[1] then
		setTimescale(tonumber(args[1]) + 0.0)
	else
		printMessage(source, {color = {255, 255, 128}, args = {"Timescale", currentTimescale}})
	end
end, true)

RegisterCommand("syncdelay", function(source, args, raw)
	if args[1] then
		setSyncDelay(tonumber(args[1]))
	else
		printMessage(source, {color = {255, 255, 128}, args = {"Sync delay", SyncDelay}})
	end
end, true)

RegisterCommand("wind", function(source, args, raw)
	if #args > 0 then
		local direction = tonumber(args[1]) + 0.0 or 0.0
		local speed = tonumber(args[2]) + 1.0 or 0.0
		local frozen = args[3] == "1"
		setWind(direction, speed, frozen)
	end
end, true)

RegisterCommand("forecast", function(source, args, raw)
	if source and source > 0 then
		TriggerClientEvent("weathersync:toggleForecast", source)
	else
		local forecast = createForecast()
		printMessage(source, {args = {"WEATHER FORECAST"}})
		printMessage(source, {args = {"================"}})
		for i = 1, #forecast do
			local time = string.format("%s %.2d:%.2d", GetDayOfWeek(forecast[i].day), forecast[i].hour, forecast[i].minute)
			printMessage(source, {args = {time, forecast[i].weather}})
		end
		printMessage(source, {args = {"================"}})
	end
end, true)

RegisterCommand("weatherui", function(source, args, raw)
	TriggerClientEvent("weathersync:openAdminUi", source)
end, true)

RegisterCommand("weathersync", function(source, args, raw)
	TriggerClientEvent("weathersync:toggleSync", source)
end, true)

RegisterCommand("mytime", function(source, args, raw)
	local h = (args[1] and tonumber(args[1]) or 0)
	local m = (args[2] and tonumber(args[2]) or 0)
	local s = (args[3] and tonumber(args[3]) or 0)
	local t = (args[4] and tonumber(args[4]) or 0)
	TriggerClientEvent("weathersync:setMyTime", source, h, m, s, t)
end, true)

RegisterCommand("myweather", function(source, args, raw)
	local weather = (args[1] and args[1] or currentWeather)
	local transition = (args[2] and tonumber(args[2]) or 5.0)
	local permanentSnow = args[3] == "1"
	TriggerClientEvent("weathersync:setMyWeather", source, weather, transition, permanentSnow)
end, true)

Citizen.CreateThread(function()
	validateWeatherPattern(weatherPattern)

	generateForecast()

	while true do
		local tick

		if currentTimescale == 0 then
			tick = syncDelay / 1000

			if not timeIsFrozen then
				local now = os.date("*t", os.time() + Config.realTimeOffset)
				currentTime = now.sec + now.min * 60 + now.hour * 3600 + (now.wday - 1) * dayLength
			end
		else
			tick = currentTimescale * (syncDelay / 1000)

			if not timeIsFrozen then
				currentTime = math.floor(currentTime + tick) % weekLength
			end
		end

		if not weatherIsFrozen then
			if weatherTicks >= weatherInterval then
				local next = table.remove(weatherForecast, 1)
				local last = weatherForecast[#weatherForecast]

				currentWeather = next.weather
				currentWindDirection = next.wind

				table.insert(weatherForecast, {
					weather = nextWeather(last.weather),
					wind = nextWindDirection(last.wind)
				})

				weatherTicks = 0
			else
				weatherTicks = weatherTicks + tick
			end
		end

		syncTime(-1, tick)
		syncWeather(-1)
		syncWind(-1)
		syncTimescale(-1)

		Citizen.Wait(syncDelay)
	end
end)
