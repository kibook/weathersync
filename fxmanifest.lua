fx_version "cerulean"
games {"gta5", "rdr3"}
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

name "weathersync"
author "kibukj"
description "Time and weather synchronization for FiveM and RedM"
url "https://github.com/kibook/weathersync"

ui_page "ui/index.html"

files {
	"ui/index.html",
	"ui/style.css",
	"ui/script.js",
	"ui/CHINESER.TTF"
}

shared_scripts {
	"shared.lua",
	"config.lua"
}

client_scripts {
	"client.lua"
}

server_scripts {
	"server.lua"
}
