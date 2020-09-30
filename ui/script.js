function displayForecast(data) {
	var forecastData = JSON.parse(data.forecast);
	var temperature = data.temperature;

	var e = document.querySelector('#forecast');

	e.innerHTML = '';

	for (var i = 0; i < forecastData.length; ++i) {
		var hour = document.createElement('div');
		hour.className = 'forecast-hour';
		
		var time = document.createElement('div');
		time.className = 'forecast-time';
		time.innerHTML = forecastData[i].time;
		
		var weather = document.createElement('div');
		weather.className = 'forecast-weather';
		weather.innerHTML = forecastData[i].weather;

		hour.appendChild(time);
		hour.appendChild(weather);
		e.appendChild(hour);
	}

	var t = document.querySelector('#temperature');

	t.innerHTML = temperature;

	document.querySelector('#forecast-parent').style.display = 'block';
	document.querySelector('#temperature').style.display = 'block';
}

function closeForecast() {
	document.querySelector('#forecast-parent').style.display = 'none';
	document.querySelector('#temperature').style.display = 'none';
	fetch(`https://${GetParentResourceName()}/closeForecast`, {
		method: 'POST'
	});
}

window.addEventListener('message', function (event) {
	switch (event.data.action) {
		case 'display':
			displayForecast(event.data);
			break;
	}
});

document.addEventListener('keydown', function (event) {
	closeForecast();
});
