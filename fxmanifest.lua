game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'ui/index.html'

files {
	'ui/index.html',
	'ui/style.css',
	'ui/script.js',
	'ui/CHINESER.TTF'
}

client_script 'client.lua'

server_script 'server.lua'
server_export 'SetTime'
server_export 'SetWeather'
