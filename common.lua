function TimeToHMS(time)
	local hour = math.floor(time / 60 / 60)
	local minute = math.floor(time / 60) % 60
	local second = time % 60

	return hour, minute, second
end

function HMSToTime(hour, minute, second)
	return hour * 3600 + minute * 60 + second
end
