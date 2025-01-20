fx_version 'cerulean'
game 'gta5'

name 'CrimDoc'
author 'Nicky'
description "AI Doc Script by Nicky of SG Scripts"
version '1.0.0'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_script {
	'server/main.lua',
}