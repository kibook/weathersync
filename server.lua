function TimeToHMS(time)
	local hour = math.floor(time / 60 / 60)
	local minute = math.floor(time / 60) % 60
	local second = time % 60

	return hour, minute, second
end

function HMSToTime(hour, minute, second)
	return hour * 3600 + minute * 60 + second
end

-- CONFIGURATION

-- Default weather when the server starts
local CurrentWeather = 'sunny'

-- Default time when the server starts
local CurrentTime = HMSToTime(6, 0, 0)

-- Default ratio of in-game seconds to real seconds. Standard game time is 30:1, or 1 in-game minute = 2 real seconds
local CurrentTimescale = 30.0

-- The interval between weather changes
local WeatherInterval = HMSToTime(1, 0, 0)

-- Whether time is frozen at server start
local TimeIsFrozen = false

-- Whether weather is frozen at serer start
local WeatherIsFrozen = false

-- Number of weather intervals to queue weather for
local MaxForecast = 23

-- How often in ms to sync with clients
local SyncDelay = 5000

-- The following table describes the weather pattern of the world. For every type of weather that may occur, the types of weather that may follow are given with a number representing the percentage of their likeliness. For example:
--
--     ['sunny'] = {
--         ['sunny'] = 50
--         ['clouds'] = 50
--     }
--
-- means that when the weather is sunny, the next stage is 50% likely to be sunny or 50% likely to be cloudy.
--
-- All the numbers for the next stages must add up to 100.
local WeatherPattern = {
	['sunny'] = {
		['sunny']  = 60,
		['clouds'] = 40
	},

	['clouds'] = {
		['clouds']       = 20,
		['sunny']        = 35,
		['misty']        = 15,
		['fog']          = 15,
		['overcastdark'] = 15
	},

	['overcastdark'] = {
		['overcastdark'] = 5,
		['clouds']       = 60,
		['overcast']     = 30,
		['thunder']      = 5
	},

	['misty'] = {
		['misty']  = 25,
		['clouds'] = 50,
		['fog']    = 25
	},

	['fog'] = {
		['fog']      = 25,
		['clouds']   = 25,
		['misty']    = 25,
		['overcast'] = 25
	},

	['overcast'] = {
		['overcast']     = 4,
		['overcastdark'] = 40,
		['drizzle']      = 30,
		['shower']       = 10,
		['rain']         = 15,
		['snow']         = 1
	},

	['drizzle'] = {
		['drizzle']      = 10,
		['overcast']     = 10,
		['rain']         = 10,
		['shower']       = 10,
		['overcastdark'] = 30,
		['clouds']       = 30
	},

	['rain'] = {
		['rain']         = 5,
		['overcastdark'] = 60,
		['drizzle']      = 25,
		['shower']       = 5,
		['thunderstorm'] = 10,
		['hurricane']    = 5
	},

	['thunder'] = {
		['thunder']      = 10,
		['overcastdark'] = 50,
		['thunderstorm'] = 40
	},

	['thunderstorm'] = {
		['thunderstorm'] = 5,
		['thunder']      = 35,
		['rain']         = 30,
		['drizzle']      = 20,
		['shower']       = 10
	},

	['hurricane'] = {
		['hurricane'] = 5,
		['rain']      = 40,
		['drizzle']   = 65
	},

	['shower'] = {
		['shower']       = 5,
		['overcast']     = 10,
		['overcastdark'] = 85
	},

	['snow'] = {
		['snow'] = 1,
		['overcastdark'] = 98
	}
}

-- END OF CONFIGURATION

local WeatherTypes = {
	'blizzard',
	'clouds',
	'drizzle',
	'fog',
	'groundblizzard',
	'hail',
	'highpressure',
	'hurricane',
	'misty',
	'overcast',
	'overcastdark',
	'rain',
	'sandstorm',
	'shower',
	'sleet',
	'snow',
	'snowlight',
	'sunny',
	'thunder',
	'thunderstorm',
	'whiteout'
}

local WeatherTicks = 0
local WeatherForecast = {}

RegisterNetEvent('weatherSync:requestUpdatedForecast')

function NextWeather(weather)
	if WeatherIsFrozen then
		return weather
	end

	local choices = WeatherPattern[weather]

	if not choices then
		choices = WeatherPattern['sunny']
	end

	local c = 0
	local r = math.random(1, 100)

	for weatherType, chance in pairs(choices) do
		c = c + chance
		if r <= c then
			return weatherType
		end
	end
end

function GenerateForecast()
	local weather = NextWeather(CurrentWeather)

	WeatherForecast = {weather}

	for i = 2, MaxForecast do
		weather = NextWeather(weather)
		WeatherForecast[i] = weather
	end
end

function Contains(t, x)
	for _, v in pairs(t) do
		if v == x then
			return true
		end
	end
	return false
end

function PrintMessage(target, message)
	if target and target > 0 then
		TriggerClientEvent('chat:addMessage', target, message)
	else
		print(table.concat(message.args, ': '))
	end
end

function SetWeather(weather, transition, freeze)
	TriggerClientEvent('weatherSync:changeWeather', -1, weather, transition)
	CurrentWeather = weather
	WeatherIsFrozen = freeze
	GenerateForecast()
end

RegisterCommand('weather', function(source, args, raw)
	local weather = (args[1] and args[1] or CurrentWeather)
	local transition = (args[2] and tonumber(args[2]) or 10.0)
	local freeze = args[3] == '1'

	if Contains(WeatherTypes, weather) then
		SetWeather(weather, transition * 1.0, freeze)
	else
		PrintMessage(source, {color = {255, 0, 0}, args = {'Error', 'Unknown weather type: ' .. weather}})
	end
end, true)

function SetTime(h, m, s, t, f)
	TriggerClientEvent('weatherSync:changeTime', -1, h, m, s, t, true)
	CurrentTime = HMSToTime(h, m, s)
	TimeIsFrozen = f
end

RegisterCommand('time', function(source, args, raw)
	if #args > 0 then
		local h = (args[1] and tonumber(args[1]) or 0)
		local m = (args[2] and tonumber(args[2]) or 0)
		local s = (args[3] and tonumber(args[3]) or 0)
		local t = (args[4] and tonumber(args[4]) or 0)
		local f = args[5] == '1'

		SetTime(h, m, s, t, f)
	else
		local h, m, s = TimeToHMS(CurrentTime)
		PrintMessage(source, {color = {255, 255, 128}, args = {'Time', string.format('%.2d:%.2d:%.2d', h, m, s)}})
	end
end, true)

function SetTimescale(scale)
	CurrentTimescale = scale
end

RegisterCommand('timescale', function(source, args, raw)
	if args[1] then
		SetTimescale(tonumber(args[1]) * 1.0)
	else
		PrintMessage(source, {color = {255, 255, 128}, args = {'Timescale', CurrentTimescale}})
	end
end, true)

function SetSyncDelay(delay)
	SyncDelay = delay
end

RegisterCommand('syncdelay', function(source, args, raw)
	if args[1] then
		SetSyncDelay(tonumber(args[1]))
	else
		PrintMessage(source, {color = {255, 255, 128}, args = {'Sync delay', SyncDelay}})
	end
end, true)

function CreateForecast()
	local forecast = {}

	for i = 0, #WeatherForecast do
		local time = (TimeIsFrozen and CurrentTime or (CurrentTime + WeatherInterval * i) % 86400)
		local h, m, s = TimeToHMS(time - time % WeatherInterval)
		local weather = (i == 0 and CurrentWeather or WeatherForecast[i])
		table.insert(forecast, {time = string.format('%.2d:%.2d', h, m), weather = weather})
	end

	return forecast
end

RegisterCommand('forecast', function(source, args, raw)
	if source and source > 0 then
		TriggerClientEvent('weatherSync:toggleForecast', source)
	else
		local forecast = CreateForecast()
		PrintMessage(source, {args = {'WEATHER FORECAST'}})
		PrintMessage(source, {args = {'================'}})
		for i = 1, #forecast do
			PrintMessage(source, {args = {forecast[i].time, forecast[i].weather}})
		end
		PrintMessage(source, {args = {'================'}})
	end
end, false)

AddEventHandler('weatherSync:requestUpdatedForecast', function()
	TriggerClientEvent('weatherSync:updateForecast', source, CreateForecast())
end)

function SyncTime(tick)
	-- Ensure time doesn't wrap around when transitioning from ~23:59:59 to ~00:00:00
	local timeTransition = ((86400 - CurrentTime + tick) % 86400 <= tick and 0 or SyncDelay)
	local hour, minute, second = TimeToHMS(CurrentTime)
	TriggerClientEvent('weatherSync:changeTime', -1, hour, minute, second, timeTransition, false)
end

function SyncWeather()
	TriggerClientEvent('weatherSync:changeWeather', -1, CurrentWeather, WeatherInterval / CurrentTimescale / 4)
end

GenerateForecast()

CreateThread(function()
	while true do
		Wait(SyncDelay)

		local tick = CurrentTimescale * (SyncDelay / 1000)

		if not TimeIsFrozen then
			CurrentTime = math.floor(CurrentTime + tick) % 86400
		end

		if not WeatherIsFrozen then
			if WeatherTicks >= WeatherInterval then
				CurrentWeather = table.remove(WeatherForecast, 1)
				table.insert(WeatherForecast, NextWeather(WeatherForecast[#WeatherForecast]))
				WeatherTicks = 0
			else
				WeatherTicks = WeatherTicks + tick
			end
		end

		SyncTime(tick)
		SyncWeather()
	end
end)
