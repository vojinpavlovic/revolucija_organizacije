fx_version 'adamant'
games { 'gta5' }

author 'Vojin Pavlovic <vojinpavlovic@outlook.com>'
description 'Organisation resource based on ESX framework'
version '1.0.0'

client_scripts {
    'config.lua',
    'markerconf.lua',

    'client/common.lua',
    'client/functions.lua',
    'client/markers.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'@es_extended',
    '@es_extended/config.lua',
    
    'config.lua',
    'markerconf.lua',
    'server/common.lua',

    'server/classes/organisation.lua',
    'server/classes/teritory.lua',

    'server/functions.lua',
    'server/commands.lua',
    'server/main.lua'
}

files {
    'html/index.html',

    'html/stylesheets/styles.css',
    'html/stylesheets/responsive.css',

    'html/javascript/common.js',

    'html/javascript/classes/announce.js',
    'html/javascript/classes/poll.js',
    'html/javascript/classes/teritory.js',
    'html/javascript/inputbox.js',

    'html/javascript/functions.js',
    'html/javascript/main.js',

    'html/images/*'
}

ui_page 'html/index.html'
