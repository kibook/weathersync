Config = {}

-- Default time when the resource starts
--
-- Can be specified in seconds out of a week (0-604799) or with the DHMSToTime
-- function as follows:
--
-- DHMSToTime(day, hour, minute, second)
--
-- day		0 (Sun) - 6 (Sat)
-- hour		0-23
-- minute	0-59
-- second	0-59
Config.Time = DHMSToTime(0, 6, 0, 0)

-- Default ratio of in-game seconds to real seconds. Standard game time is 30:1, or 1 in-game minute = 2 real seconds
Config.Timescale = 30

-- Whether time is frozen when the resource starts
Config.TimeIsFrozen = false

-- Default weather when the resource starts
Config.Weather = 'sunny'

-- The interval (in-game time) between weather changes
Config.WeatherInterval = DHMSToTime(0, 1, 0, 0)

-- Whether weather is frozen when the resource starts
Config.WeatherIsFrozen = false

-- Whether to permanently add snow on the ground, or only during snowy weather
Config.PermanentSnow = false

-- Whether to add snow on the ground when:
-- 	a) in the snowy area of the map
-- 	b) in the northern part of the map with snowy weather
Config.DynamicSnow = true

-- Number of weather intervals to queue up
Config.MaxForecast = 23

-- Default wind direction when the resource starts
Config.WindDirection = 0.0

-- Default base wind speed when the resource starts
Config.WindSpeed = 0.0

-- Degrees by which wind direction changes at higher altitudes
Config.WindShearDirection = 45

-- Amount by which base wind speed increases at higher altitudes
Config.WindShearSpeed = 2.0

-- Interval in metres above sea level where wind direction/speed changes
Config.WindShearInterval = 50.0

-- Whether wind direction is frozen when the resource starts
Config.WindIsFrozen = false

-- How often in milliseconds to sync with clients
Config.SyncDelay = 5000

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
Config.WeatherPattern = {
	['sunny'] = {
		['sunny']  = 60,
		['clouds'] = 40
	},

	['clouds'] = {
		['clouds']       = 25,
		['sunny']        = 40,
		['misty']        = 10,
		['fog']          = 10,
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
		['overcast']     = 5,
		['overcastdark'] = 40,
		['drizzle']      = 30,
		['shower']       = 10,
		['rain']         = 15,
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
		['overcastdark'] = 55,
		['drizzle']      = 20,
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
		['rain']      = 30,
		['drizzle']   = 65
	},

	['shower'] = {
		['shower']       = 5,
		['overcast']     = 10,
		['overcastdark'] = 85
	}
}
