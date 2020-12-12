ESX = nil
local connectedMedic = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Count Medics
function CountMedic()
	local xPlayers = ESX.GetPlayers()
	connectedMedic = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'ambulance' then
			connectedMedic = connectedMedic + 1
		end
	end
	
	TriggerClientEvent('esx_advancedhospital:connectedMedic', -1, connectedMedic)
	SetTimeout(60000, CountMedic)
end

-- Pay for Healing
ESX.RegisterServerCallback('esx_advancedhospital:payHealing', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.HealingPrice

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		xPlayer.showNotification(_U('healing_paid', ESX.Math.GroupDigits(price)))
		cb(true)
	else
		cb(false)
	end
end)

-- Pay for Surgery
ESX.RegisterServerCallback('esx_advancedhospital:paySurgery', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.SurgeryPrice

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		xPlayer.showNotification(_U('surgery_paid', ESX.Math.GroupDigits(price)))
		cb(true)
	else
		cb(false)
	end
end)

CountMedic()
