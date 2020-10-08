# RedM weather and time sync

## Features

- Syncs time and weather for all players

- Configurable weather pattern

- Weather is queued so players can get a forecast of upcoming weather

- Different weather for different regions

- Adjustable timescale

## Examples

| Forecast UI | Region-specific weather |
|---|---|
| [![Forecast UI](https://i.imgur.com/pXPTwnUm.jpg)](https://imgur.com/pXPTwnU) | [![Region-specific weather](https://i.imgur.com/Loif9SMm.jpg)](https://imgur.com/Loif9SM) |

## Commands

| Command      | Description                                               |
|--------------|-----------------------------------------------------------|
| `/forecast`  | Displays a forecast of upcoming weather.                  |
| `/syncdelay` | Set how often the server syncs with clients.              |
| `/time`      | Set the server time.                                      |
| `/timescale` | Set the ratio of in-game seconds to real-time seconds.    |
| `/weather`   | Set the server weather.                                   |

## Configuration

| Variable           | Description | Example |
|--------------------|-----------------------------------------------------|---------------------------------------|
| `CurrentWeather`   | Initial weather when the resource starts.           | `'sunny'`                             |
| `CurrentTime`      | Initial time when the resource starts.              | `HMSToTime(6, 0, 0)` (06:00:00)       |
| `CurrentTimescale` | Initial timescale when the resource starts          | `30.0` (30 in-game secs per real sec) |
| `WeatherInterval`  | How often the weather changes.                      | `HMSToTime(1, 0, 0)` (1 in-game hour) |
| `TimeIsFrozen`     | Whether time is frozen when the resource starts.    | `false`                               |
| `WeatherIsFrozen`  | Whether weather is frozen when the resource starts. | `false`                               |
| `MaxForecast`      | Number of weather intervals to queue up.            | `23` (24-hour forecast)               |
| `SyncDelay`        | How often in ms to sync with clients.               | `5000`                                |
| `WeatherPattern`   | A table describing the the weather pattern.         | See [server.lua](server.lua)          |
