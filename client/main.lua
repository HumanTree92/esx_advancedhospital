local CurrentActionData = {}
local HasAlreadyEnteredMarker, IsInMainMenu = false, false
local LastZone, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

-- Open Healing Menu
function OpenHealingMenu()
	IsInMainMenu = true

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'healing_confirm', {
		title = _U('buy_health', ESX.Math.GroupDigits(Config.HealingPrice)),
		align = 'top-left',
		elements = {
			{label = _U('no'),  value = 'no'},
			{label = _U('yes'), value = 'yes'}
	}}, function(data, menu)
		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('esx_advancedhospital:payHealing', function(success)
				if success then
					IsInMainMenu = false
					menu.close()
					SetEntityHealth(GetPlayerPed(-1), 200)
				else
					ESX.ShowNotification(_U('not_enough_money'))
					IsInMainMenu = false
					menu.close()
				end
			end)
		else
			IsInMainMenu = false
			menu.close()
		end
	end, function(data, menu)
		IsInMainMenu = false
		menu.close()
	end)
end

-- Open Surgery Menu
function OpenSurgeryMenu()
	IsInMainMenu = true

	TriggerEvent('esx_skin:openSaveableMenu', function(data, menu)
		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'surgery_confirm', {
			title = _U('buy_surgery', ESX.Math.GroupDigits(Config.SurgeryPrice)),
			align = 'top-left',
			elements = {
				{label = _U('no'),  value = 'no'},
				{label = _U('yes'), value = 'yes'}
		}}, function(data, menu)
			menu.close()

			if data.current.value == 'yes' then
				ESX.TriggerServerCallback('esx_advancedhospital:paySurgery', function(success)
					if success then
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)

						IsInMainMenu = false
						menu.close()
					else
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin) 
						end)

						ESX.ShowNotification(_U('not_enough_money'))
						IsInMainMenu = false
						menu.close()
					end
				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin) 
				end)

				IsInMainMenu = false
				menu.close()
			end
		end, function(data, menu)
			IsInMainMenu = false
			menu.close()
		end)
	end, function(data, menu)
		IsInMainMenu = false
		menu.close()
	end)
end

-- Entered Marker
AddEventHandler('esx_advancedhospital:hasEnteredMarker', function(zone)
	if zone == 'HealingLocation' then
		CurrentAction     = 'healing_menu'
		CurrentActionMsg  = _U('healing_menu')
		CurrentActionData = {}
	elseif zone == 'SurgeryLocation' then
		CurrentAction     = 'surgery_menu'
		CurrentActionMsg  = _U('surgery_menu')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedhospital:hasExitedMarker', function(zone)
	if not IsInMainMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInMainMenu then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	if Config.UseHospital then
		for k,v in pairs(Config.HealingLocations) do
			local blip = AddBlipForCoord(v.Coords)

			SetBlipSprite (blip, Config.BlipsHospital.Sprite)
			SetBlipColour (blip, Config.BlipsHospital.Color)
			SetBlipDisplay(blip, Config.BlipsHospital.Display)
			SetBlipScale  (blip, Config.BlipsHospital.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('healing_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end

	if Config.UseSurgeon then
		for k,v in pairs(Config.SurgeryLocations) do
			local blip = AddBlipForCoord(v.Coords)

			SetBlipSprite (blip, Config.BlipsSurgery.Sprite)
			SetBlipColour (blip, Config.BlipsSurgery.Color)
			SetBlipDisplay(blip, Config.BlipsSurgery.Display)
			SetBlipScale  (blip, Config.BlipsSurgery.Scale)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('surgery_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Create Peds
Citizen.CreateThread(function()
	if Config.EnablePeds then
		if Config.UseHospital then
			RequestModel(GetHashKey("s_m_m_doctor_01"))

			while not HasModelLoaded(GetHashKey("s_m_m_doctor_01")) do
				Wait(1)
			end

			for k,v in pairs(Config.HealingLocations) do
				local npc = CreatePed(4, 0xd47303ac, v.Coords, v.Heading, false, true)

				SetEntityHeading(npc, v.Heading)
				FreezeEntityPosition(npc, true)
				SetEntityInvincible(npc, true)
				SetBlockingOfNonTemporaryEvents(npc, true)
			end
		end

		if Config.UseSurgeon then
			RequestModel(GetHashKey("s_m_y_autopsy_01"))

			while not HasModelLoaded(GetHashKey("s_m_y_autopsy_01")) do
				Wait(1)
			end

			for k,v in pairs(Config.SurgeryLocations) do
				local npc = CreatePed(4, 0xB2273D4E, v.Coords, v.Heading, false, true)

				SetEntityHeading(npc, v.Heading)
				FreezeEntityPosition(npc, true)
				SetEntityInvincible(npc, true)
				SetBlockingOfNonTemporaryEvents(npc, true)
			end
		end
	end
end)

-- Enter / Exit marker events & Draw Markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		if Config.UseHospital then
			for k,v in pairs(Config.HealingLocations) do
				local distance = #(playerCoords - v.Coords)

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.MarkerType ~= -1 then
						DrawMarker(Config.MarkerType, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentZone = true, k
					end
				end
			end
		end

		if Config.UseSurgeon then
			for k,v in pairs(Config.SurgeryLocations) do
				local distance = #(playerCoords - v.Coords)

				if distance < Config.DrawDistance then
					letSleep = false

					if Config.MarkerType ~= -1 then
						DrawMarker(Config.MarkerType, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					end

					if distance < Config.MarkerSize.x then
						isInMarker, currentZone = true, k
					end
				end
			end
		end
		
		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('esx_advancedhospital:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_advancedhospital:hasExitedMarker', LastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'healing_menu' then
					OpenHealingMenu()
				elseif CurrentAction == 'surgery_menu' then
					OpenSurgeryMenu()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)
