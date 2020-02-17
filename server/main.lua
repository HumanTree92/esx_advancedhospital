ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Pay for Healing
ESX.RegisterServerCallback('esx_advancedhospital:payHealing', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.HealingPrice then
		xPlayer.removeMoney(Config.HealingPrice)
		cb(true)
	else
		cb(false)
	end
end)

-- Pay for Surgery
ESX.RegisterServerCallback('esx_advancedhospital:paySurgery', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.SurgeryPrice then
		xPlayer.removeMoney(Config.SurgeryPrice)
		cb(true)
	else
		cb(false)
	end
end)
