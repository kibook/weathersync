function toggleDisplay(e, display) {
	if (e.style.display == display) {
		e.style.display = 'none';
	} else {
		e.style.display = display;
	}
}

function toggleForecast() {
	toggleDisplay(document.querySelector('#forecast'), 'table');
	toggleDisplay(document.querySelector('#temperature'), 'block');
}

function updateForecast(data) {
	var f = document.querySelector('#forecast');
	var t = document.querySelector('#temperature');

	var forecastData = JSON.parse(data.forecast)

	f.innerHTML = '';

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
		f.appendChild(hour);
	}

	t.innerHTML = data.temperature;
}

window.addEventListener('message', function (event) {
	switch (event.data.action) {
		case 'toggleForecast':
			toggleForecast();
			break;
		case 'updateForecast':
			updateForecast(event.data);
			break;
	}
});
