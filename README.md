# RedM weather and time sync

## Features

- Syncs time and weather for all players

- Configurable weather pattern

- Weather is queued so players can get a forecast of upcoming weather

- Different weather for different regions

- Adjustable timescale

- Players can temporarily disable sync and set local time/weather

## Examples

| Forecast and admin UI | Region-specific weather | Adjustable timescale |
|---|---|---|
| [![Forecast and admin UI](https://i.imgur.com/Scn0z0Em.jpg)](https://imgur.com/Scn0z0E) | [![Region-specific weather](https://i.imgur.com/Loif9SMm.jpg)](https://imgur.com/Loif9SM) | [![Adjustable timescale](https://i.imgur.com/WkqHAs4m.jpg)](https://imgur.com/WkqHAs4) |

## Installation

1. Create a `weathersync` folder within your resources directory, for example, `resources/[local]/weathersync`.

2. Copy the files from this repository into the `weathersync` folder.

3. Add the following to your `server.cfg`:

```
exec resources/[local]/weathersync/permissions.cfg
start weathersync
```

## Commands

| Command        | Description                                               |
|----------------|-----------------------------------------------------------|
| `/forecast`    | Displays a forecast of upcoming weather.                  |
| `/mytime`      | Set local time (if sync is off).                          |
| `/myweather`   | Set local weather (if sync is off).                       |
| `/syncdelay`   | Set how often the server syncs with clients.              |
| `/time`        | Set the server time.                                      |
| `/timescale`   | Set the ratio of in-game seconds to real-time seconds.    |
| `/weather`     | Set the server weather.                                   |
| `/weathersync` | Toggle time/weather sync on/off.                          |
| `/weatherui`   | Opens the admin UI for changing the time/weather/wind.    |
| `/wind`        | Set the wind direction and base speed.                    |

## Configuration

| Variable                 | Description                                         | Example                                   |
|--------------------------|-----------------------------------------------------|-------------------------------------------|
| `Config.Time`            | Default time when the resource starts.              | `DHMSToTime(0, 6, 0, 0)` (Sun 06:00:00)   |
| `Config.Timescale`       | Default timescale when the resource starts          | `30.0` (30 in-game secs per real sec)     |
| `Config.TimeIsFrozen`    | Whether time is frozen when the resource starts.    | `false`                                   |
| `Config.Weather`         | Default weather when the resource starts.           | `"sunny"`                                 |
| `Config.WeatherInterval` | How often the weather changes.                      | `DHMSToTime(0, 1, 0, 0)` (1 in-game hour) |
| `Config.WeatherIsFrozen` | Whether weather is frozen when the resource starts. | `false`                                   |
| `Config.PermanentSnow`   | Whether to permanently add snow on the ground.      | `false`                                   |
| `Config.DynamicSnow`     | Whether to dynamically add snow on the ground.      | `true`                                    |
| `Config.MaxForecast`     | Number of weather intervals to queue up.            | `23` (24-hour forecast)                   |
| `Config.WindDirection`   | Default wind direction when the resource starts.    | `0.0` (North)                             |
| `Config.WindSpeed`       | Default base wind speed when the resource starts.   | `0.0`                                     |
| `Config.WindIsFrozen`    | Whether wind direction is frozen.                   | `false`                                   |
| `Config.SyncDelay`       | How often in ms to sync with clients.               | `5000`                                    |
| `Config.WeatherPattern`  | A table describing the the weather pattern.         | See [config.lua](config.lua)              |

## Exports

### getTime
Get the current server time.

#### Usage
```lua
exports.weathersync:getTime()
```

#### Return value
A table with the current day, hour, minute and second:

```lua
{
	day = 0,
	hour = 6,
	minute = 0,
	second = 0
}
```
### setTime
Set the current time.

#### Usage
```lua
exports.weathersync:setTime(day, hour, minute, second, transition, freeze)
```

### resetTime
Reset the time to the default configured time.

#### Usage
```lua
exports.weathersync:resetTime()
```

### setTimescale
Set the ratio of in-game seconds to real seconds.

#### Usage
```lua
exports.weathersync:setTimescale(timescale)
```

### resetTimescale
Reset the timescale to the default configured value.

#### Usage
```lua
exports.weathersync:resetTimescale()
```

### getWeather
Get the current weather.

#### Usage
```lua
exports.weathersync:getWeather()
```

#### Return value
The name of the current weather type.

### setWeather
Set the current weather.

#### Usage
```lua
exports.weathersync:setWeather()
```

### resetWeather
Reset the weather to the default configured weather type.

#### Usage
```lua
exports.weathersync:resetWeather()
```

### setWeatherPattern
Set the weather pattern.

#### Usage
```lua
exports.weathersync:setWeatherPattern(pattern)
```

### resetWeatherPattern
Reset the weather pattern to the default configured pattern.

#### Usage
```lua
exports.weathersync:resetWeatherPattern()
```

### getWind
Get the current wind direction and base speed.

#### Usage
```lua
exports.weathersync:getWind()
```

#### Return value
A table containing the wind direction and base speed:

```lua
{
	direction = 180.0,
	speed = 0.0
}
```

### setWind
Set the current wind direction and base speed.

#### Usage
```lua
exports.weathersync:setWind(direction, speed)
```

### resetWind
Reset the wind direction and speed to the default configured values.

#### Usage
```lua
exports.weathersync:resetWind()
```

### setSyncDelay
Set the current synchronization interval.

#### Usage
```lua
exports.weathersync:setSyncDelay(delay)
```

### resetSyncDelay
Reset the sync delay to the default configured value.

#### Usage
```lua
exports.weathersync:resetSyncDelay()
```

### getForecast
Get the current weather forecast.

#### Usage
```lua
exports.weathersync:getForecast()
```

#### Return value
A table containing the weather forecast:

```lua
{
	{
		day = 0,
		hour = 6,
		minute = 0,
		second = 0,
		weather = "sunny",
		wind = 0.0
	},
	{
		day = 0,
		hour = 7,
		minute = 0,
		second = 0,
		weather = "clouds",
		wind = 10.0
	},
	...
}
```
