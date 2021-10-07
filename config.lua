Config = {}

-- Determine if game is GTA V or RDR 2
if IsDuplicityVersion() then
	Config.isRDR = GetConvar("gamename", "gta5") == "rdr3"
else
	Config.isRDR = not TerraingridActivate
end

-- Select relevant list of valid weather types
Config.weatherTypes = Config.isRDR and RDR2WeatherTypes or GTAVWeatherTypes

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
Config.time = DHMSToTime(0, 6, 0, 0)

-- Default ratio of in-game seconds to real seconds. Standard game time is 30:1, or 1 in-game minute = 2 real seconds. A value of 0 means time will be synced with the real server time.
Config.timescale = 30

-- If Config.timescale is 0, offset the real server time by this many seconds.
Config.realTimeOffset = 0

-- Whether time is frozen when the resource starts
Config.timeIsFrozen = false

-- Default weather when the resource starts
Config.weather = Config.isRDR and "sunny" or "clear"

-- The interval (in-game time) between weather changes
Config.weatherInterval = DHMSToTime(0, 1, 0, 0)

-- Whether weather is frozen when the resource starts
Config.weatherIsFrozen = false

-- Whether to permanently add snow on the ground, or only during snowy weather
Config.permanentSnow = false

-- Whether to add snow on the ground when:
-- 	a) in the snowy area of the map
-- 	b) in the northern part of the map with snowy weather
Config.dynamicSnow = false

-- Number of weather intervals to queue up
Config.maxForecast = 23

-- Default wind direction when the resource starts
Config.windDirection = 0.0

-- Default base wind speed when the resource starts
Config.windSpeed = 0.0

-- Degrees by which wind direction changes at higher altitudes
Config.windShearDirection = 45

-- Amount by which base wind speed increases at higher altitudes
Config.windShearSpeed = 2.0

-- Interval in metres where wind direction/speed changes
Config.windShearInterval = 50.0

-- Whether wind direction is frozen when the resource starts
Config.windIsFrozen = false

-- How often in milliseconds to sync with clients
Config.syncDelay = 5000

-- The following tables describe the weather pattern of the world. For every type of weather that may occur, the types of weather that may follow are given with a number representing the percentage of their likeliness. For example:
--
--     ["sunny"] = {
--         ["sunny"] = 50
--         ["clouds"] = 50
--     }
--
-- means that when the weather is sunny, the next stage is 50% likely to be sunny or 50% likely to be cloudy.
--
-- All the numbers for the next stages must add up to 100.

Config.defaultGtaWeatherPattern = {
	["clear"] = {
		["clear"]      = 50,
		["clouds"]     = 30,
		["extrasunny"] = 20
	},

	["clouds"] = {
		["clouds"]   = 30,
		["clear"]    = 40,
		["foggy"]    = 10,
		["overcast"] = 20
	},

	["foggy"] = {
		["foggy"]    = 10,
		["clouds"]   = 50,
		["overcast"] = 40
	},

	["overcast"] = {
		["overcast"] = 5,
		["clearing"] = 70,
		["rain"]     = 25,
	},

	["clearing"] = {
		["clearing"] = 10,
		["overcast"] = 10,
		["rain"]     = 20,
		["clouds"]   = 60
	},

	["rain"] = {
		["rain"]     = 10,
		["overcast"] = 20,
		["clearing"] = 55,
		["thunder"]  = 15
	},

	["thunder"] = {
		["thunder"]  = 30,
		["rain"]     = 40,
		["clearing"] = 30
	},

	["extrasunny"] = {
		["extrasunny"] = 25,
		["clear"]      = 75
	}
}

Config.defaultRdrWeatherPattern = {
	["sunny"] = {
		["sunny"]  = 60,
		["clouds"] = 40
	},

	["clouds"] = {
		["clouds"]       = 25,
		["sunny"]        = 40,
		["misty"]        = 10,
		["fog"]          = 10,
		["overcastdark"] = 15
	},

	["overcastdark"] = {
		["overcastdark"] = 5,
		["clouds"]       = 60,
		["overcast"]     = 30,
		["thunder"]      = 5
	},

	["misty"] = {
		["misty"]  = 25,
		["clouds"] = 50,
		["fog"]    = 25
	},

	["fog"] = {
		["fog"]      = 25,
		["clouds"]   = 25,
		["misty"]    = 25,
		["overcast"] = 25
	},

	["overcast"] = {
		["overcast"]     = 5,
		["overcastdark"] = 40,
		["drizzle"]      = 30,
		["shower"]       = 10,
		["rain"]         = 15,
	},

	["drizzle"] = {
		["drizzle"]      = 10,
		["overcast"]     = 10,
		["rain"]         = 10,
		["shower"]       = 10,
		["overcastdark"] = 30,
		["clouds"]       = 30
	},

	["rain"] = {
		["rain"]         = 5,
		["overcastdark"] = 55,
		["drizzle"]      = 20,
		["shower"]       = 5,
		["thunderstorm"] = 10,
		["hurricane"]    = 5
	},

	["thunder"] = {
		["thunder"]      = 10,
		["overcastdark"] = 50,
		["thunderstorm"] = 40
	},

	["thunderstorm"] = {
		["thunderstorm"] = 5,
		["thunder"]      = 35,
		["rain"]         = 30,
		["drizzle"]      = 20,
		["shower"]       = 10
	},

	["hurricane"] = {
		["hurricane"] = 5,
		["rain"]      = 30,
		["drizzle"]   = 65
	},

	["shower"] = {
		["shower"]       = 5,
		["overcast"]     = 10,
		["overcastdark"] = 85
	}
}

Config.weatherPattern = Config.isRDR and Config.defaultRdrWeatherPattern or Config.defaultGtaWeatherPattern

-- Disable snowy weather and snow on ground when on Cayo Perico
Config.disableSnowOnCayoPerico = false
