fx_version 'adamant'

game 'gta5'

description 'ESX Advanced Hospital'

version '1.0.0'

server_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'config.lua',
  'client/main.lua'
}

dependency 'es_extended'
