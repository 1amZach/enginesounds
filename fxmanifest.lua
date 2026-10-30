fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'enginesounds'
description 'Swap engine sounds in-game with live preview, synced to everyone'
version '1.0.0'
author 'IamZach'
discord 'https://discord.gg/agn'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/sounds.lua',
    'client/store.lua',
    'client/sync.lua',
    'client/menu.lua',
}

server_script 'server/main.lua'

dependency 'ox_lib'
