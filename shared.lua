GTAVWeatherTypes = {
	"blizzard",
	"clear",
	"clearing",
	"clouds",
	"extrasunny",
	"foggy",
	"halloween",
	"neutral",
	"overcast",
	"rain",
	"smog",
	"snow",
	"snowlight",
	"thunder",
	"xmas"
}

RDR2WeatherTypes = {
	"blizzard",
	"clouds",
	"drizzle",
	"fog",
	"groundblizzard",
	"hail",
	"highpressure",
	"hurricane",
	"misty",
	"overcast",
	"overcastdark",
	"rain",
	"sandstorm",
	"shower",
	"sleet",
	"snow",
	"snowlight",
	"sunny",
	"thunder",
	"thunderstorm",
	"whiteout"
}

function TimeToDHMS(time)
	local day = math.floor(time / 86400)
	local hour = math.floor(time / 60 / 60) % 24
	local minute = math.floor(time / 60) % 60
	local second = time % 60

	return day, hour, minute, second
end

function DHMSToTime(day, hour, minute, second)
	return day * 86400 + hour * 3600 + minute * 60 + second
end

function GetCardinalDirection(h)
	if h <= 22.5 then
		return "N"
	elseif h <= 67.5 then
		return "NE"
	elseif h <= 112.5 then
		return "E"
	elseif h <= 157.5 then
		return "SE"
	elseif h <= 202.5 then
		return "S"
	elseif h <= 247.5 then
		return "SW"
	elseif h <= 292.5 then
		return "W"
	elseif h <= 337.5 then
		return "NW"
	else
		return "N"
	end
end

function GetDayOfWeek(day)
	return ({"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"})[day + 1]
end
